
# About

[MarkdownProjectCompositor](https://github.com/lalawue/MarkdownProjectCompositor) is a static markdown generator with compositor, using [CommonMark](https://github.com/commonmark/cmark), or [cmark-gfm](https://github.com/github/cmark-gfm) as its rendering engine.

# Require

- lua, only test under 5.3.4
- markdown rendering engine, like [cmark-gfm](https://github.com/github/cmark-gfm)

# Features

- composite markdown source with different header, footer or style sheet in different project dir
- with pre process body step, the compositor can exten your own markdown syntax

# Basic Example

```
$ lua MarkdownProjectCompositor.lua example/basic/config.lua example/basic
```

# Feature Example

support more markdown syntax as:
- '\#title' \<h1> title and html \<head>\<title>
- proj markdown file link as '\[desc]\(proj\#file\#anchor)'
- footnote with paired '\[desc]\(\#name)'
- contents with '\#contents depth'

```
$ lua MarkdownProjectCompositor.lua example/feature/config.lua example/feature
```

