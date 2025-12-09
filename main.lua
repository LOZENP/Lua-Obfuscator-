--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║              MAIN.LUA - Advanced VM System Entry Point          ║
    ║           First Advance Encryption - Lua 5.1 Compatible         ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: main.lua
    Compatible: Lua 5.1+
    
    GitHub Project Structure:
    ├── main.lua                 (this file)
    ├── src/
    │   ├── encryption.lua
    │   ├── vm_core.lua
    │   ├── obfuscator.lua
    │   ├── compiler.lua
    │   └── utils.lua
    ├── examples/
    │   ├── basic_usage.lua
    │   └── advanced_usage.lua
    ├── tests/
    │   └── test_all.lua
    ├── LICENSE
    └── README.md
    
    Usage:
        local VM = require("main")
        local result = VM.obfuscate(yourCode)
]]--

-- ============================================================================
-- MODULE LOADER (Simulated for demonstration)
-- ============================================================================
-- In real GitHub repo, use: local Encryption = require("src.encryption")

local function simulateRequire(moduleName)
    -- This simulates the module loading
    -- In real usage, this would be: require("src." .. moduleName)
    print("[INFO] Loading module: " .. moduleName)
    return {}
end

-- Load all modules
local Encryption = simulateRequire("encryption")
local VMCore = simulateRequire("vm_core")
local Obfuscator = simulateRequire("obfuscator")
local Compiler = simulateRequire("compiler")
local Utils = simulateRequire("utils")

-- ============================================================================
-- MAIN VM SYSTEM
-- ============================================================================

local AdvancedVM = {}
AdvancedVM._VERSION = "1.0.0"
AdvancedVM._AUTHOR = "First Advance Encryption"
AdvancedVM._LICENSE = "MIT"

-- Initialize system
function AdvancedVM.init(options)
    options = options or {}
    
    local system = {
        encryption = Encryption.new(options.key, options.encryptionOpts),
        vm = VMCore.new(options.vmOpts),
        obfuscator = nil,
        compiler = nil,
        utils = Utils,
        options = options
    }
    
    -- Create obfuscator with encryption
    system.obfuscator = Obfuscator.new(system.encryption, options.obfuscatorOpts)
    
    -- Create compiler with encryption and obfuscator
    system.compiler = Compiler.new(
        system.encryption,
        system.obfuscator,
        options.compilerOpts
    )
    
    return system
end

-- Quick obfuscation (single function)
function AdvancedVM.obfuscate(sourceCode, options)
    local system = AdvancedVM.init(options)
    return system.obfuscator:obfuscate(sourceCode)
end

-- Quick compilation (single function)
function AdvancedVM.compile(sourceCode, outputPath, options)
    local system = AdvancedVM.init(options)
    return system.compiler:compile(sourceCode, outputPath)
end

-- Quick encryption (single function)
function AdvancedVM.encrypt(data, key)
    local enc = Encryption.new(key)
    return enc:encrypt(data)
end

-- Quick decryption (single function)
function AdvancedVM.decrypt(encData, key)
    local enc = Encryption.new(key)
    return enc:decrypt(encData)
end

-- Create standalone obfuscator
function AdvancedVM.createObfuscator(options)
    local enc = Encryption.new(options and options.key)
    return Obfuscator.new(enc, options)
end

-- Create standalone compiler
function AdvancedVM.createCompiler(options)
    local enc = Encryption.new(options and options.key)
    local obf = Obfuscator.new(enc, options)
    return Compiler.new(enc, obf, options)
end

-- Create VM instance
function AdvancedVM.createVM(options)
    return VMCore.new(options)
end

-- Batch process files
function AdvancedVM.batchProcess(files, options)
    local system = AdvancedVM.init(options)
    return system.compiler:compileBatch(files, options and options.outputDir)
end

-- ============================================================================
-- CLI INTERFACE
-- ============================================================================

function AdvancedVM.cli(args)
    if not args or #args == 0 then
        AdvancedVM.printUsage()
        return
    end
    
    local command = args[1]
    
    if command == "obfuscate" then
        if #args < 2 then
            print("Error: Input file required")
            return
        end
        
        local inputFile = args[2]
        local outputFile = args[3] or inputFile .. ".obf"
        
        local source = Utils.readFile(inputFile)
        if not source then
            print("Error: Cannot read input file")
            return
        end
        
        local obfuscated = AdvancedVM.obfuscate(source)
        
        if Utils.writeFile(outputFile, obfuscated) then
            print("Success: Obfuscated to " .. outputFile)
        else
            print("Error: Cannot write output file")
        end
        
    elseif command == "compile" then
        if #args < 2 then
            print("Error: Input file required")
            return
        end
        
        local inputFile = args[2]
        local outputFile = args[3] or inputFile .. ".compiled"
        
        local success, result = AdvancedVM.compile(nil, outputFile, {
            inputFile = inputFile
        })
        
        if success then
            print("Success: " .. result)
        else
            print("Error: " .. result)
        end
        
    elseif command == "encrypt" then
        if #args < 2 then
            print("Error: Data required")
            return
        end
        
        local data = args[2]
        local key = tonumber(args[3])
        
        local encrypted = AdvancedVM.encrypt(data, key)
        print("Encrypted string:", encrypted.str)
        print("Key:", encrypted.key)
        print("Salt:", encrypted.salt)
        
    elseif command == "version" then
        AdvancedVM.printVersion()
        
    elseif command == "help" then
        AdvancedVM.printUsage()
        
    else
        print("Error: Unknown command '" .. command .. "'")
        AdvancedVM.printUsage()
    end
end

function AdvancedVM.printUsage()
    print([[
Advanced VM System - First Advance Encryption

Usage:
    lua main.lua <command> [options]

Commands:
    obfuscate <input> [output]     Obfuscate Lua file
    compile <input> [output]       Compile with optimizations
    encrypt <data> [key]           Encrypt string
    version                        Show version
    help                           Show this help

Examples:
    lua main.lua obfuscate script.lua script.obf
    lua main.lua compile mycode.lua output.lua
    lua main.lua encrypt "Hello World" 150

For programmatic usage:
    local VM = require("main")
    local result = VM.obfuscate(code)
]])
end

function AdvancedVM.printVersion()
    print(string.format([[
Advanced VM System
Version: %s
Author: %s
License: %s
Lua Version: %s
]], 
        AdvancedVM._VERSION,
        AdvancedVM._AUTHOR,
        AdvancedVM._LICENSE,
        _VERSION
    ))
end

-- ============================================================================
-- DEMONSTRATION EXAMPLES
-- ============================================================================

function AdvancedVM.runDemo()
    print("=" :rep(70))
    print("ADVANCED VM SYSTEM - DEMONSTRATION")
    print("=" :rep(70))
    
    -- Demo 1: Basic Obfuscation
    print("\n[Demo 1: Basic Obfuscation]")
    local testCode = [[
print("Hello from VM!")
local x = 10
local y = 20
print("Sum:", x + y)
]]
    
    local obfuscated = AdvancedVM.obfuscate(testCode)
    print("Original length:", #testCode)
    print("Obfuscated length:", #obfuscated)
    print("\nObfuscated preview (first 200 chars):")
    print(obfuscated:sub(1, 200) .. "...")
    
    -- Demo 2: Encryption
    print("\n[Demo 2: Encryption]")
    local plaintext = "Secret data 123"
    local encrypted = AdvancedVM.encrypt(plaintext, 150)
    print("Plaintext:", plaintext)
    print("Encrypted:", encrypted.str)
    print("Key:", encrypted.key)
    
    local decrypted = AdvancedVM.decrypt(encrypted, 150)
    print("Decrypted:", decrypted)
    print("Match:", plaintext == decrypted)
    
    -- Demo 3: Complex Code
    print("\n[Demo 3: Complex Code Obfuscation]")
    local complexCode = [[
local function fibonacci(n)
    if n <= 1 then return n end
    return fibonacci(n-1) + fibonacci(n-2)
end

for i = 1, 10 do
    print("Fib(" .. i .. ") =", fibonacci(i))
end
]]
    
    local obfComplex = AdvancedVM.obfuscate(complexCode)
    print("Complex code obfuscated!")
    print("Size: " .. #obfComplex .. " bytes")
    
    print("\n" .. "=" :rep(70))
    print("DEMONSTRATION COMPLETED")
    print("=" :rep(70))
end

-- ============================================================================
-- AUTO-RUN
-- ============================================================================

-- If running as main script
if not pcall(debug.getlocal, 4, 1) then
    -- Check if CLI args provided
    local args = {...}
    
    if #args > 0 then
        AdvancedVM.cli(args)
    else
        -- Run demo
        AdvancedVM.runDemo()
    end
end

-- ============================================================================
-- EXPORT MODULE
-- ============================================================================

return AdvancedVM
