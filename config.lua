{
   source = "/Markdown/Source/Path",
   bulid = "/Html/Output/Path",
   program = "cmark-gfm",
   params = " -t html --unsafe --github-pre-lang ",
   tmpfile = "/tmp/MarkdownProjectCompositorTempFile",
   projs = {
      [1] = {
         dir = "scratch",
         files = {
            -- file names filled by compositor
         },
         preProcess = function( config, proj, filename, inFile )
            -- replace private syntax to cmark's
         end,
         header = function( config, proj, filename )
            return ""
         end,
         footer = function( config, proj, filename )
            return ""
         end,
      },
   },
   -- 
   -- user defined below
   -- 
   user = {
      projNames = nil,
      mdGetTitle = function( config, proj, filename )
         -- generate header, footer dynamic
      end,
      mdReplaceTag = function( config, proj, content )
         -- replace [[WikiTag][Desc]] as cmarks syntax
      end,
      readFile = function( path )
         local f = io.open(path, "r")
         if f then
            local content = f:read("a")
            f:close(f)
            return content
         else
            return ""
         end
      end,
      writeFile = function( path, content )
         local f = io.open(path, "w")
         if f then
            f:write( content )
            f:close()
         end
      end,
      siteHeader = function( config, proj, filename )
         return ""
      end,
      siteFooter = function( config, proj, filename )
         return ""
      end,
   }
}
