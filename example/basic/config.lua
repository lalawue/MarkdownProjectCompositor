local config = {
   source = "source", -- will be modified by compositor
   publish = "publish",      -- will be modified by compositor
   suffix = ".html",                 -- output suffix
   program = "cmark-gfm",            -- program used
   params = " -t html --unsafe --github-pre-lang ",    -- params
   tmpfile = "/tmp/MarkdownProjectCompositorTempFile", -- temp file
   projs = {
      {
         dir = "www",
         files = {},            -- file names filled by compositor
         header = function( config, porj, filename )
            return [[<html><head><title>Basic Example</title></head><body>]]
         end,
         footer = function( config, proj, filename )
            return [[</body></html>]]
         end,
      },
      {
         dir = "blog",
         files = {},            -- file names filled by compositor
         header = function( config, porj, filename )
            return [[<html><head><title>Basic Example</title></head><body>]]
         end,
         footer = function( config, proj, filename )
            return [[</body></html>]]
         end,
      }
   },
}
return config
