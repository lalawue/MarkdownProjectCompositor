
# About

[MarkdownProjectCompositor](https://github.com/lalawue/MarkdownProjectCompositor) is a static markdown generator with compositor, using [CommonMark](https://github.com/commonmark/cmark), or [cmark-gfm](https://github.com/github/cmark-gfm) as its rendering engine.

and provide a pre-compiled windows version in [releases](https://github.com/lalawue/MarkdownProjectCompositor/releases), include cmark-gfm.exe, luajit.exe and lfs_ffi.lua.

[中文](http://suchang.net/blog/2019-06.html#p1)

# Require

- [Lua](https://www.lua.org/) or [LuaJIT](http://luajit.org/)
- [luafilesystem](https://github.com/keplerproject/luafilesystem) or [luafilesystem via LuaJIT FFI](https://github.com/sonoro1234/luafilesystem)
- markdown rendering engine, like [cmark-gfm](https://github.com/github/cmark-gfm)

# Features

- composite markdown source with different header, footer or style sheet in different project dir
- with pre process body step, the compositor can extend your own markdown syntax

# Basic Example

```
$ lua MarkdownProjectCompositor.lua example/basic/config.lua example/basic
```

# Feature Example

extend markdown syntax, '^' is newline:

- '^\#title' \<h1> title and html \<head>\<title>
- link anchor '^\#anchor'
- proj markdown file link as '\[desc]\(proj\#file\#anchor)'
- footnote with paired '\[desc]\(\#name)'
- contents with '^\#contents depth'

```
$ lua MarkdownProjectCompositor.lua example/feature/config.lua example/feature
```

# Live Example

<http://suchang.net>  
<http://suchang.net/blog>

with [config.lua](https://github.com/lalawue/homepage/blob/master/misc/config.lua)

# Markdown Editor

recommand <https://github.com/jbt/markdown-editor>, [try it online](jbt.github.io/markdown-editor)

