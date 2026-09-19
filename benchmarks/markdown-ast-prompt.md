# Benchmark: Markdown AST Parser & Renderer

**Purpose:** Compare LLM code generation quality against hica's specific
syntax and standard-library constraints. Provide the model with `SKILL.md`
(repo root) as system/context material before giving it this task — do not
paste language rules inline, so the benchmark measures how well a model
follows the skill file on its own.

This task exercises: enum (`type`) definitions with named fields, struct
definitions, expression-based `if`/`match`, fallible `maybe<T>` chains with
`?`, string slicing, and left-to-right pipelines (`|>`) with `map`/`join`.

## Grading

A correct submission must satisfy all three:

1. `hica check <file>` — zero errors.
2. `hica analyse <file>` — FP Quality Index of **100/100** (no debt items).
3. `hica test <file>` — all `test` blocks pass.

## Task Prompt

> **Task:** Implement a Markdown AST Parser & Renderer in hica.
>
> **Requirements:**
>
> 1. Define an enum `Block` with variants:
>    - `Header(level: int, text: string)`
>    - `Paragraph(text: string)`
>    - `CodeBlock(lang: string, code: string)`
> 2. Define a struct `Document` holding `blocks: list<Block>`.
> 3. Write a function `parse_line(line: string) : Block` that classifies a
>    single line of input (this parser is line-at-a-time; it does not need
>    to track multi-line state):
>    - A line starting with `"## "` becomes `Header(2, text)`, where `text`
>      is everything after the marker.
>    - A line starting with `"# "` becomes `Header(1, text)`.
>    - A line starting with `` "```" `` becomes a `CodeBlock` **start
>      marker**: `lang` is whatever follows the backticks (may be empty),
>      and `code` is always `""` (this parser does not capture multi-line
>      code bodies).
>    - Any other line becomes `Paragraph(line)`.
> 4. Write a fallible function `extract_inline_code(line: string) :
>    maybe<string>` that uses the `?` operator to find the first pair of
>    backticks (`` ` ``) in `line` and return the text between them.
>    Return `None` if there are fewer than two backticks.
> 5. Write a function `render_html(doc: Document) : string` that converts
>    each block to an HTML fragment and joins them with no separator, using
>    a left-to-right pipeline (`|>`) with `map` and `join`:
>    - `Header(1, text)` → `<h1>text</h1>`
>    - `Header(2, text)` → `<h2>text</h2>`
>    - `Paragraph(text)` → `<p>text</p>`
>    - `CodeBlock(lang, code)` → `<pre><code class="lang">code</code></pre>`
> 6. Include `test` blocks that assert:
>    - Parsing and rendering a 3-line Markdown document (one `# ` header,
>      one paragraph, one `` ``` `` code-block marker) produces the exact
>      expected HTML string.
>    - `extract_inline_code` returns `Some(text)` when backticks are
>      present and `None` when they are absent.

## Notes for Evaluators

- The original draft of this prompt said CodeBlock parsing produces
  "empty CodeBlock start markers" without specifying what `lang`/`code`
  should contain — this revision pins both fields down so every model is
  graded against the same expected output.
- Do not accept solutions using `return`, `for`/`while`/`loop`, `var`, or
  Rust/Python-style syntax (`fn`, `->`, `and`/`or`) — these are exactly the
  failure modes `hica analyse` and `hica check` are meant to catch.
