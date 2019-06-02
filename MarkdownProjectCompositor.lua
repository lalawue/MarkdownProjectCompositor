--
--
-- Markdown Project Compositor
--
-- base on cmark-gfm, lfs, by lalawue, 2019/06/02

local lfs = require "lfs"

local kCMarkProgram = "cmark-gfm"
local kCMarkParams = " -t html --unsafe --github-pre-lang "
local kTmpFilePath = "/tmp/MarkdownSiteGeneratorTempFile"

local argConfigFile = ...

local fs = {}                   -- fs interface
local dbg = {}                  -- debug interface
local cmark = {}                -- cmark interface
local site = {}                 -- site inteface

-- config file example
-- {
--    source = "/Markdown/Source/Path",
--    bulid = "/Html/Output/Path",
--    projs = {
--       [1] = {
--          dir = "SourceSubPath",
--          files = {
--             -- file names filled by compositor
--          },         
--          preProcess = function( config, proj, filename, inFile )
--             -- process temp inputFile
--          end,
--          header = function( config, porj, filename )
--             -- return content append in head
--          end,
--          footer = function( config, proj, filename )
--             -- return content append in tail
--          end,
--       },
--    },
--    -- user defines below
--    user = {
--       myTable = {},
--       readFile = function( path )
--       end,
--       writeFile = function( path, content )
--       end,
--       siteHeader = function( config, proj, filename )
--       end,
--       siteFooter = function( config, proj, filename )
--       end,
--    },
-- }

--
-- debug function
--
function dbg.print( value, key, level, onlyipairs )
   
   if type(value) == "table" then
      if level then
         print(string.rep(".", level) .. key .. " <table>")
      end

      if onlyipairs then
         for k, v in ipairs(value) do
            dbg.print( v, k, level and (level + 1) or 0 )            
         end
      else
         for k, v in pairs(value) do
            dbg.print( v, k, level and (level + 1) or 0 )
         end
      end
   else
      if level then
         io.write(string.rep(".", level))
      end
      
      if key then
         print( key .. " " .. tostring(value))
      else
         print( tostring(value) )
      end
   end
end

--
-- fs function
--

function fs.isDir( path )
   local attr = lfs.attributes(path)
   return (type(attr) == "table") and (attr.mode == "directory")
end

function fs.makeDir( path )
   if type(path) == "string" then
      os.execute("mkdir -p " .. path)
   end
end

function fs.readContent( path )
   if not fs.isDir( path ) then
      local f = io.open( path, "r" )
      if f then
         local content = f:read("a")
         f:close()
         return content
      end
   end
   return nil
end

function fs.writeContent(path, content, append)
   if not fs.isDir( path ) and type(content) == "string" then
      local f = io.open( path, append and "a+" or "w")
      if f then
         local valid, errString = f:write(content)
         f:close()
         return valid ~= nil, errString
      end
   end
   return false
end

function fs.copyFile(pathFrom, pathTo)
   if fs.isDir(pathFrom) or fs.isDir(pathTo) then
      return
   end
   fs.writeContent(pathTo, fs.readContent(pathFrom))
end

function fs.listFiles(path, inputTable)
   if not path then
      return nil
   end

   local tbl = inputTable
   if type(tbl) ~= "table" then
      tbl = {}
   end

   for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
         local f = path..'/'..file
         local attr = lfs.attributes (f)
         assert (type(attr) == "table")
         if attr.mode == "directory" then
            fs.listFiles( f )
         else
            tbl[#tbl + 1] = file -- no path
         end
      end
   end

   return tbl
end

function fs.fillProjFiles( config )
   local validProjs = 0   
   if config then
      local i = 0
      for _, proj in ipairs(config.projs) do
         proj.files = fs.listFiles(config.source .. '/' .. proj.dir)
         validProjs = validProjs + #proj.files
      end
   end
   return validProjs > 0
end

--
-- cmark function
--

function cmark.compositeHeader( config, proj, filename, outFile )
   if type(proj.header) == "function" then
      local content = proj.header(config, proj, filename)
      if type(content) == "string" then      
         assert( fs.writeContent(outFile, content) )
      end
   end
end

function cmark.compositeFooter( config, proj, filename, outFile )
   if type(proj.footer) == "function" then
      local content = proj.footer(config, proj, filename)
      if type(content) == "string" then
         assert( fs.writeContent(outFile, content, true) )
      end
   end
end

function cmark.compositeBody( config, proj, filename, inFile, outFile )
   dbg.print("output: " .. outFile )
   os.execute( kCMarkProgram .. kCMarkParams .. inFile .. " >> " .. outFile )
end

function cmark.preProcess( config, proj, filename, inFile, outFile )
   fs.copyFile(inFile, outFile)
   if type(proj.preProcess) == "function" then
      proj.preProcess( config, proj, filename, outFile)
   end
end

--
-- site function
--

function site.isArgsValid( config )
   if not config then
      print("Usage: CONFIG_FILE")
      os.exit(0)
   end
   return true
end

function site.loadConfig( path )
   if fs.isDir( path ) then
      dbg.print("invalid config path")
      return nil
   end

   local content = fs.readContent(path)
   if type(content) ~= "string" then
      dbg.print("invalid config content")
      return nil
   end
   
   local func = load("return " .. content)
   if type(func) ~= "function" then
      dbg.print("invalid config return type")
      return nil
   end

   local result, config = pcall(func)
   assert(result)
   assert(type(config) == "table")
   assert(type(config.source) == "string")
   assert(type(config.build) == "string")
   assert(type(config.projs) == "table")
   assert(#config.projs > 0)
   for _, proj in ipairs(config.projs) do
      assert(type(proj) == "table")
      assert(type(proj.dir) == "string")
      assert(type(proj.header) == "function")
      assert(type(proj.footer) == "function")
   end
   return config
end

function site.processProjects( config )
   assert( type(config) == "table")
   if fs.fillProjFiles( config ) then
      
      -- 
      dbg.print("----- using config -----")
      dbg.print( config )
      dbg.print("----- ----- ----- -----")
      --
      
      for _, proj in ipairs(config.projs) do
         
         local inPath = config.source .. "/" .. proj.dir .. "/"         
         local outPath = config.build .. "/" .. proj.dir .. "/"

         fs.makeDir( outPath )

         local i = 0
         while true do
            i = i + 1
            
            if i > #proj.files then
               break
            end
            
            local filename = proj.files[i]
            local inFile = kTmpFilePath
            local outFile = outPath .. filename .. ".html"

            cmark.preProcess( config, proj, filename, inPath .. filename, inFile )
            cmark.compositeHeader( config, proj, filename, outFile)
            cmark.compositeBody( config, proj, filename, inFile, outFile)
            cmark.compositeFooter( config, proj, filename, outFile)
         end
      end
   end
end

function site.main( configFile )
   if site.isArgsValid( configFile ) then
      local config = site.loadConfig( configFile )
      assert(config)
      site.processProjects( config )
   end
end

--
-- Main
--
site.main( argConfigFile )
