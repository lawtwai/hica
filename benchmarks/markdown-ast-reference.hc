// benchmarks/markdown-ast-reference.hc
// Idiomatic reference solution for benchmarks/markdown-ast-prompt.md.

type Block {
  Header(level: int, text: string),
  Paragraph(text: string),
  CodeBlock(lang: string, code: string)
}

struct Document { blocks: list<Block> }

fun parse_line(line: string) : Block =>
  if starts_with(line, "## ") {
    Header(2, line[3:])
  } else if starts_with(line, "# ") {
    Header(1, line[2:])
  } else if starts_with(line, "```") {
    CodeBlock(line[3:], "")
  } else {
    Paragraph(line)
  }

fun extract_inline_code(line: string) : maybe<string> {
  let start = index_of(line, "`")?
  let after = line[start+1:]
  let end_rel = index_of(after, "`")?
  Some(after[:end_rel])
}

fun render_block(b: Block) : string => match b {
  Header(level, text) => match level {
    1 => "<h1>" + text + "</h1>",
    _ => "<h2>" + text + "</h2>"
  },
  Paragraph(text) => "<p>" + text + "</p>",
  CodeBlock(lang, code) => "<pre><code class=\"" + lang + "\">" + code + "</code></pre>"
}

fun render_html(doc: Document) : string =>
  doc.blocks
    |> map(render_block)
    |> join("")

fun main() {
  let lines = ["# Hica Benchmark", "This paragraph has inline code in it.", "```python"]
  let doc = Document { blocks: map(lines, parse_line) }
  println(render_html(doc))
}

test "parses and renders a 3-line markdown document" {
  let lines = ["# Hica Benchmark", "This paragraph has inline code in it.", "```python"]
  let doc = Document { blocks: map(lines, parse_line) }
  let html = render_html(doc)
  assert(html == "<h1>Hica Benchmark</h1><p>This paragraph has inline code in it.</p><pre><code class=\"python\"></code></pre>")
}

test "header level 2 parses correctly" {
  let block = parse_line("## Subheading")
  assert(block == Header(2, "Subheading"))
}

test "extract_inline_code finds text between backticks" {
  let result = extract_inline_code("see `let x = 1` here")
  assert(result == Some("let x = 1"))
}

test "extract_inline_code returns none without backticks" {
  let result = extract_inline_code("no code here")
  assert(result == None)
}
