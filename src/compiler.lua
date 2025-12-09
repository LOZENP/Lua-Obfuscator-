--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                  COMPILER.LUA - Bytecode Compiler                ║
    ║            Advanced Compilation System - Lua 5.1                 ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: src/compiler.lua
    Compatible: Lua 5.1+
    Purpose: Compile Lua source to obfuscated bytecode
]]--

local Compiler = {}
Compiler.__index = Compiler
Compiler._VERSION = "1.0.0"

-- Lua 5.1 compatibility
local loadstring = loadstring or load

-- Compiler options
local DEFAULT_OPTIONS = {
    optimize = true,
    stripDebug = true,
    obfuscateNames = true,
    inlineFunctions = false,
    deadCodeElimination = true,
    constantFolding = true
}

-- Constructor
function Compiler.new(encryption, obfuscator, options)
    local self = setmetatable({}, Compiler)
    
    if not encryption or not obfuscator then
        error("Compiler requires encryption and obfuscator modules")
    end
    
    self.encryption = encryption
    self.obfuscator = obfuscator
    self.options = options or DEFAULT_OPTIONS
    
    -- Compiler state
    self.source = nil
    self.ast = nil
    self.bytecode = nil
    self.symbols = {}
    self.constants = {}
    
    return self
end

-- Syntax validation
function Compiler:validate(source)
    if type(source) ~= "string" or #source == 0 then
        return false, "Source must be non-empty string"
    end
    
    -- Try to load to check syntax
    local func, err = loadstring(source)
    if not func then
        return false, "Syntax error: " .. tostring(err)
    end
    
    return true
end

-- Pre-processing: Strip comments and whitespace
function Compiler:preprocess(source)
    local processed = source
    
    -- Remove single-line comments
    processed = processed:gsub("%-%-[^\n]*", "")
    
    -- Remove multi-line comments
    processed = processed:gsub("%-%-%[%[.-%]%]", "")
    
    -- Strip unnecessary whitespace if minify enabled
    if self.options.stripDebug then
        processed = processed:gsub("%s+", " ")
        processed = processed:gsub("%s*([%+%-%*/%%=<>~%(%)%[%]{}:;,%.])%s*", "%1")
    end
    
    return processed
end

-- Constant folding optimization
function Compiler:foldConstants(source)
    if not self.options.constantFolding then
        return source
    end
    
    -- Simple constant folding (can be extended)
    local folded = source
    
    -- Fold simple arithmetic
    folded = folded:gsub("(%d+)%s*%+%s*(%d+)", function(a, b)
        return tostring(tonumber(a) + tonumber(b))
    end)
    
    folded = folded:gsub("(%d+)%s*%-%s*(%d+)", function(a, b)
        return tostring(tonumber(a) - tonumber(b))
    end)
    
    folded = folded:gsub("(%d+)%s*%*%s*(%d+)", function(a, b)
        return tostring(tonumber(a) * tonumber(b))
    end)
    
    return folded
end

-- Dead code elimination
function Compiler:eliminateDeadCode(source)
    if not self.options.deadCodeElimination then
        return source
    end
    
    -- Remove unreachable code after return statements
    local eliminated = source:gsub("return%s+[^\n]+\n[^\n]+", function(match)
        return match:match("return[^\n]+")
    end)
    
    -- Remove empty blocks
    eliminated = eliminated:gsub("do%s*end", "")
    eliminated = eliminated:gsub("then%s*end", "then end")
    
    return eliminated
end

-- Name obfuscation
function Compiler:obfuscateNames(source)
    if not self.options.obfuscateNames then
        return source
    end
    
    -- Build symbol table
    local symbols = {}
    local counter = 0
    
    -- Find all local variable declarations
    for var in source:gmatch("local%s+([%a_][%w_]*)") do
        if not symbols[var] then
            counter = counter + 1
            symbols[var] = string.format("_l%x", counter)
        end
    end
    
    -- Find all function names
    for func in source:gmatch("function%s+([%a_][%w_]*)") do
        if not symbols[func] then
            counter = counter + 1
            symbols[func] = string.format("_f%x", counter)
        end
    end
    
    -- Replace symbols
    local obfuscated = source
    for original, replacement in pairs(symbols) do
        -- Use word boundaries to avoid partial replacements
        obfuscated = obfuscated:gsub("%f[%w_]" .. original .. "%f[^%w_]", replacement)
    end
    
    self.symbols = symbols
    return obfuscated
end

-- Optimize source code
function Compiler:optimize(source)
    if not self.options.optimize then
        return source
    end
    
    local optimized = source
    
    -- Apply optimizations in order
    optimized = self:foldConstants(optimized)
    optimized = self:eliminateDeadCode(optimized)
    optimized = self:obfuscateNames(optimized)
    
    return optimized
end

-- Compile source to obfuscated output
function Compiler:compile(source, outputPath)
    -- Validate source
    local valid, err = self:validate(source)
    if not valid then
        return false, err
    end
    
    self.source = source
    
    -- Pre-process
    local processed = self:preprocess(source)
    
    -- Optimize
    local optimized = self:optimize(processed)
    
    -- Obfuscate with VM wrapper
    local obfuscated = self.obfuscator:obfuscate(optimized)
    
    self.bytecode = obfuscated
    
    -- Write to file if path provided
    if outputPath then
        local success, writeErr = self:writeToFile(outputPath, obfuscated)
        if not success then
            return false, writeErr
        end
        
        return true, "Compiled successfully to: " .. outputPath
    end
    
    return true, obfuscated
end

-- Compile with advanced options
function Compiler:compileAdvanced(source, options)
    options = options or {}
    
    -- Merge options
    for k, v in pairs(options) do
        self.options[k] = v
    end
    
    -- Compile
    return self:compile(source, options.output)
end

-- Batch compile multiple files
function Compiler:compileBatch(sources, outputDir)
    if type(sources) ~= "table" then
        return false, "Sources must be table of {name, code} pairs"
    end
    
    local results = {}
    local errors = {}
    
    for i, entry in ipairs(sources) do
        local name = entry.name or string.format("output_%d.lua", i)
        local code = entry.code
        
        local outputPath = outputDir and (outputDir .. "/" .. name) or nil
        local success, result = self:compile(code, outputPath)
        
        if success then
            table.insert(results, {name = name, output = result})
        else
            table.insert(errors, {name = name, error = result})
        end
    end
    
    return {
        success = #errors == 0,
        results = results,
        errors = errors,
        total = #sources,
        compiled = #results,
        failed = #errors
    }
end

-- Write compiled output to file
function Compiler:writeToFile(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return false, "Failed to open file: " .. tostring(err)
    end
    
    local success, writeErr = file:write(content)
    file:close()
    
    if not success then
        return false, "Failed to write file: " .. tostring(writeErr)
    end
    
    return true
end

-- Read source from file
function Compiler:readFromFile(path)
    local file, err = io.open(path, "r")
    if not file then
        return nil, "Failed to open file: " .. tostring(err)
    end
    
    local content = file:read("*all")
    file:close()
    
    return content
end

-- Compile file to file
function Compiler:compileFile(inputPath, outputPath)
    local source, err = self:readFromFile(inputPath)
    if not source then
        return false, err
    end
    
    return self:compile(source, outputPath)
end

-- Get compilation statistics
function Compiler:getStats()
    if not self.source or not self.bytecode then
        return nil
    end
    
    return {
        sourceSize = #self.source,
        outputSize = #self.bytecode,
        compression = string.format("%.2f%%", 
            (1 - #self.bytecode / #self.source) * 100),
        symbolsRenamed = self:countTable(self.symbols),
        constantsFolded = self:countTable(self.constants),
        optimizationLevel = self.options.optimize and "High" or "None"
    }
end

-- Utility: Count table entries
function Compiler:countTable(t)
    local count = 0
    for _ in pairs(t or {}) do
        count = count + 1
    end
    return count
end

-- Reset compiler state
function Compiler:reset()
    self.source = nil
    self.ast = nil
    self.bytecode = nil
    self.symbols = {}
    self.constants = {}
end

-- Export module
return Compiler
