# Rules: how to explain and document

Applies to technical explanations in responses and to all documentation text.

## Language

- **Spanish only when talking to the user**: responses and explanations in the conversation.
- **English everywhere else**: documentation, code comments, commits, issues, pull requests.
- The rules below apply the same in both languages.

## Style

- **Lead with what matters.** If there is room for confusion, state in the first sentence what was done and what was not.
- **Plain language.** Short sentences, one idea per sentence. No long sentences chained with parentheses and semicolons.
- **Technical terms in Spanish**: keep established English terms in English (*split brain*, *circuit breaker*, *cache miss*, *TTL*). Translate those with a natural Spanish equivalent (member -> nodo del clúster).
- **In documentation, use the impersonal form**: do not address the reader directly. "The application must set..." instead of "You must set...", "the application declares..." instead of "you write...".
- **One concrete example**, numbered step by step, with a real case (an application, a cache, a piece of data).
- **Separate** what was wrong, what has been fixed and what is still pending.
- If something already written does not follow this style, offer to rewrite it.
