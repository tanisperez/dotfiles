#!/usr/bin/env bash
# Claude Code status line: RGB gradient, dynamic emoji, cost, code velocity

input=$(cat)

# Force C numeric locale so printf %f parses dot-decimal numbers from jq
export LC_NUMERIC=C

# ── Colors ──
CYAN='\033[38;5;31m'
BRGREEN='\033[38;5;76m'
GREEN='\033[38;5;76m'
YELLOW='\033[38;5;214m'
RED='\033[31m'
LTBLUE='\033[38;5;75m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Truecolor helper ──
rgb() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }

# ── Parse JSON fields ──
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
lines_add=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_del=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
tokens=$(echo "$input" | jq -r '(.context_window.current_usage // {}) | ((.input_tokens//0)+(.output_tokens//0)+(.cache_creation_input_tokens//0)+(.cache_read_input_tokens//0))')
tokens_fmt=$(awk -v t="${tokens:-0}" 'BEGIN{ if(t>=1000) printf "%.1fk", t/1000; else printf "%d", t }')

# ── Git info ──
branch=""
repo=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  repo=$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
fi

# ── Context bar: RGB gradient, full blocks only ──
BAR_WIDTH=20

if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")

  # Round to nearest block
  filled=$(( (used_int * BAR_WIDTH + 50) / 100 ))

  bar=""
  for (( i=0; i<BAR_WIDTH; i++ )); do
    pos=$(( i * 100 / (BAR_WIDTH - 1) ))

    if [ "$pos" -le 50 ]; then
      r=$(( 0 + 220 * pos / 50 ))
      g=200
      b=$(( 80 - 80 * pos / 50 ))
    else
      adj=$(( pos - 50 ))
      r=220
      g=$(( 200 - 160 * adj / 50 ))
      b=$(( 0 + 20 * adj / 50 ))
    fi

    if [ "$i" -lt "$filled" ]; then
      bar="${bar}$(rgb $r $g $b)█"
    else
      bar="${bar}\033[38;2;60;60;60m░"
    fi
  done
  bar="${bar}${RESET}"

  if [ "$used_int" -ge 90 ]; then pct_color="$RED"
  elif [ "$used_int" -ge 70 ]; then pct_color="$YELLOW"
  else pct_color="$GREEN"; fi

  ctx_part="⚡${pct_color} ${tokens_fmt} ${bar} ${used_int}%${RESET}"
else
  ctx_part="⚡${BRGREEN} ${tokens_fmt} \033[38;2;60;60;60m░░░░░░░░░░░░░░░░░░░░${RESET} --%"
fi

# ── Cost ──
cost_part="${YELLOW}$(printf '$%.2f' "$cost")${RESET}"

# ── Code velocity ──
velocity="${GREEN}+${lines_add}${RESET} ${RED}-${lines_del}${RESET}"

# ── Path (~/..) ──
dir="$cwd"
[ "${cwd#$HOME}" != "$cwd" ] && dir="~${cwd#$HOME}"

# ── Single line ──
out="${CYAN}${dir}${RESET}"
[ -n "$branch" ] && out="${out} ${BRGREEN} ${branch}${RESET}"
out="${out:+$out ${DIM}|${RESET} }${ctx_part}"
out="${out} ${DIM}|${RESET} ${cost_part}"
out="${out} ${DIM}|${RESET} ${velocity}"
out="${out} ${DIM}|${RESET} ${LTBLUE}🤖 ${model}${RESET}"

printf '%b' "$out"
