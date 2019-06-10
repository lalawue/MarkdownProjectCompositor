--
--  by lalawue, 2019/06/10

local user = {
   projNames = nil,             -- table [projName][FileName]   
}

function user.writeFile( path, content )
   local f = io.open(path, "w")
   if f then
      f:write( content )
      f:close()
   end
end

function user.readFile( path )
   local f = io.open(path, "r")
   if f then
      local content = f:read("a")
      f:close(f)
      return content
   else
      return ""
   end
end

function user.mdGetTitle( config, proj, filename )
   -- '#title title', for <title> or <h1> tag
   local path = config.source .. "/" .. proj.dir .. "/" .. filename
   local content = config.user.readFile( path )
   content = content:len() > 1 and content or config.user.blogTempContent[filename]
   if content then
      local name = content:match("#title%s+([^\n]+)")
      if name then
         return name
      else
         return filename
      end
   end
   return ""
end

function user.mdGenContentDesc( config, proj, content )
   -- '#contents depth-number'
   local s, e = content:find("\n#contents%s*")
   if not s then
      return content
   end
   local depth = content:match("\n#contents%s*(%d*)")
   if not depth then
      return content
   end
   local pre = content:sub(1, s - 1)
   local sub = content:sub(e + 1 + depth:len(), content:len())
   local lastStack = {}
   local lastNum = 0
   local firstNum = 0
   local index = 1
   local desc = ""
   sub = sub:gsub("\n(#+%s+[^%c]+)", function( mark )
                     local num = mark:find("%s")
                     if lastNum > 0 and num > depth then
                        return mark
                     end
                     if lastNum <= 0 then
                        depth = num + tonumber(depth) - 1
                        lastNum = num
                        desc = "<dl class=\"contents\">"
                        lastStack[#lastStack + 1] = "</dl>"
                     elseif num > lastNum then
                        lastNum = num
                        desc = desc .. "<dd><dl class=\"contents\">"
                        lastStack[#lastStack + 1] = "</dl></dd>"
                     elseif num < lastNum then
                        while lastNum > num and #lastStack > 0 do
                           lastNum = lastNum - 1
                           desc = desc .. lastStack[#lastStack]
                           table.remove(lastStack)
                        end
                     end
                     local title = mark:match("#+%s+([^%c]+)")
                     desc = desc .. string.format("<dt class=\"contents\"><a href=\"#sec-%d\">%s</a></dt>",
                                                  index, title)
                     local ret = string.format("<a id=\"sec-%d\"></a>\n%s", index, mark)
                     index = index + 1                           
                     return ret
   end)
   while #lastStack > 0 do
      desc = desc .. lastStack[#lastStack]
      table.remove(lastStack)
   end
   return pre .. desc .. "\n" .. sub
end

function user.mdReplaceTag( config, proj, content )
   -- replace [Desc](#footnote) to html tag
   local tags = {}
   content = content:gsub("(%[[^%]]-%]%(#[^%)]-%))", function( mark )
                             local name, fntag = mark:match("%[(.-)%]%(%#([^%)]-)%)")
                             if fntag and not tags[fntag] then
                                tags[fntag] = fntag
                                return string.format("<sup><a href=\"#%s\">%s</a></sup>", fntag, name)
                             else
                                return string.format("<sup>&lsqb;<a id=\"%s\">%s</a>&rsqb;</sup>", fntag, name)
                             end
   end)
   local projNames = config.user.projNames
   -- 
   -- replace [Desc](WikiTag) as really links, WikiTag may contain
   -- '#' as project/source/anchor seperator, for example:
   -- 
   -- 1. [Desc](ProjectSourceName)
   -- 2. [Desc](OtherProject#SourceName)
   -- 3. [Desc](OtherProject#SourceName#Anchor)
   return content:gsub("(%[[^%]]+%]%([^%)]+%))", function( mark )
                          local name, tag = mark:match("%[([^%]]+)%]%(([^%)]+)%)")
                          local ptag, ftag, atag = tag:match("([^#]+)#([^#]+)#([^%c]+)")
                          if ptag and ftag and atag then
                             return string.format("[%s](../%s/%s.html#%s)", name, ptag, ftag, atag)
                          end
                          local ptag, ftag = tag:match("([^#]+)#([^%c#]+)")
                          if ptag and ftag then
                             if projNames[ptag] and projNames[ptag][ftag] then
                                ftag = projNames[ptag][ftag]
                                return string.format("[%s](../%s/%s)", name, ptag, ftag)
                             end
                          end
                          local projFile = projNames[proj.dir][tag]
                          if projFile then
                             return string.format("[%s](%s)", name, projFile)
                          end
                          return string.format("[%s](%s)", name, tag)
   end)
end

function user.mdGenAnchor( config, proj, content )
   return content:gsub("\n#([^#%s%c]+)", function(mark)
                             return string.format("<a id=\"%s\"></a>\n", mark)
   end)
end

function user.sitePrepare( config, proj )
   -- generage projNames[ProjDir][SourceName] = [Resouce | Source.html]
   local projNames = config.user.projNames
   if not projNames then
      projNames = {}
      for _, proj in ipairs(config.projs) do
         projNames[proj.dir] = {}
         for _, f in ipairs(proj.files) do
            if proj.res then
               projNames[proj.dir][f] = f
            else
               projNames[proj.dir][f] = f .. ".html"
            end
         end
      end
      config.user.projNames = projNames      
   end
end

function user.siteBody( config, proj, filename, content )
   if content then
      content = content:gsub("#title ", "# Site Title ~ ")
      content = config.user.mdGenContentDesc( config, proj, content )
      content = config.user.mdReplaceTag( config, proj, content )
      content = config.user.mdGenAnchor( config, proj, content )
      return content
   end
end

function user.siteHeader( config, proj, filename )
   local part1 = [[<html><head><title> Site Title -]]
   local part2 = config.user.mdGetTitle( config, proj, filename )
   local part3 = [[</title></head></html><body>]]
   return part1 .. part2 .. part3
end

function user.siteFooter( config, proj, filename )
   return [[<p>--------</p><p>Site Footer</p></body></html>]]
end

function user.blogPrepare( config, proj )
   config.user.sitePrepare( config, proj )
end

function user.blogBody( config, proj, filename, content )
   if content then
      content = content:gsub("#title ", "# Blog Title ~ ")
      content = config.user.mdReplaceTag( config, proj, content )
      content = config.user.mdGenAnchor( config, proj, content )
      return content
   end
   return content
end

function user.blogHeader( config, proj, filename )
   local part1 = [[<html><head><title> Blog Title -]]
   local part2 = config.user.mdGetTitle( config, proj, filename )
   local part3 = [[</title></head></html></body>]]
   return part1 .. part2 .. part3
end

function user.blogFooter( config, proj, filename )
   return [[<p>--------</p><p>Blog Footer</p></body></html>]]
end

local config = {
   source = "source", -- will be modified by compositor
   publish = "publish",      -- will be modified by compositor
   suffix = ".html",                 -- output suffix
   program = "cmark-gfm",            -- program used
   params = " -t html --unsafe --github-pre-lang ",    -- params
   tmpfile = "/tmp/MarkdownProjectCompositorTempFile", -- temp file
   projs = {},
   --
   user = user,
}

config.projs = {
   {
      res = true,               -- is resource dir
      dir = "images",
      files = {},               -- file names filled by compositor
   },   
   {
      dir = "www",
      files = {},            -- file names filled by compositor
      prepare = user.sitePrepare,
      body = user.siteBody,
      header = user.siteHeader,
      footer = user.siteFooter,
   },
   {
      dir = "blog",
      files = {},            -- file names filled by compositor
      prepare = user.blogPrepare,
      body = user.blogBody,
      header = user.blogHeader,
      footer = user.blogFooter,
   }
}

return config
