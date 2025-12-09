--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║            ADVANCED USAGE EXAMPLES - Advanced Lua VM             ║
    ║                  Complex and Powerful Examples                   ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: examples/advanced_usage.lua
    Purpose: Demonstrate advanced features of the VM system
]]--

-- Load the main module and sub-modules
local VM = require("main")
local Encryption = require("src.encryption")
local VMCore = require("src.vm_core")
local Obfuscator = require("src.obfuscator")
local Compiler = require("src.compiler")
local Utils = require("src.utils")

print("=" :rep(70))
print("ADVANCED USAGE EXAMPLES - ADVANCED LUA VM")
print("=" :rep(70))

-- ============================================================================
-- Example 1: Multi-Layer Encryption
-- ============================================================================

print("\n[Example 1: Multi-Layer Encryption]")
print("-" :rep(70))

local sensitiveData = "Top Secret Information"
print("Original data:", sensitiveData)

-- Create custom encryption with high security
local customEnc = Encryption.new(nil, {
    iterations = 10,
    extended = true
})

local encrypted1 = customEnc:encrypt(sensitiveData)
print("\nLayer 1 - Encrypted:", encrypted1.str:sub(1, 30) .. "...")
print("Iterations:", encrypted1.iterations)

-- Encrypt the encrypted data (double encryption)
local encrypted2 = customEnc:encrypt(encrypted1.str)
print("\nLayer 2 - Double encrypted:", encrypted2.str:sub(1, 30) .. "...")

-- Decrypt both layers
local decrypted2 = customEnc:decrypt(encrypted2)
local decrypted1 = customEnc:decrypt(encrypted1)

print("\nDecrypted Layer 1:", decrypted1)
print("Match:", sensitiveData == decrypted1 and "✓ SUCCESS" or "✗ FAILED")

-- ============================================================================
-- Example 2: Custom VM with Stack Operations
-- ============================================================================

print("\n[Example 2: Custom VM with Stack Operations]")
print("-" :rep(70))

local vm = VMCore.new({
    maxStack = 256,
    debugMode = true
})

print("Performing stack operations:")

vm:push(10)
vm:push(20)
vm:push(30)

print("Stack size:", vm:stackSize())
print("Top value:", vm:peek())

local val3 = vm:pop()
local val2 = vm:pop()
local val1 = vm:pop()

print("Popped values:", val1, val2, val3)
print("Stack empty:", vm:stackSize() == 0 and "YES" or "NO")

-- ============================================================================
-- Example 3: Complex Code Obfuscation
-- ============================================================================

print("\n[Example 3: Complex Code Obfuscation]")
print("-" :rep(70))

local complexCode = [[
-- Recursive Fibonacci
local function fib(n)
    if n <= 1 then return n end
    return fib(n-1) + fib(n-2)
end

-- Factorial with memoization
local factCache = {}
local function factorial(n)
    if n <= 1 then return 1 end
    if factCache[n] then return factCache[n] end
    local result = n * factorial(n-1)
    factCache[n] = result
    return result
end

-- Test functions
print("Fibonacci(10):", fib(10))
print("Factorial(10):", factorial(10))

-- Array operations
local numbers = {5, 2, 8, 1, 9}
table.sort(numbers)
print("Sorted:", table.concat(numbers, ", "))
]]

print("Original code length:", #complexCode, "bytes")

-- Obfuscate with maximum complexity
local maxObfuscated = VM.obfuscate(complexCode, {
    complexity = 10,
    flowDepth = 12,
    hexNames = true
})

print("Obfuscated length:", #maxObfuscated, "bytes")
print("Size increase:", math.floor((#maxObfuscated / #complexCode) * 100) .. "%")

print("\nExecuting obfuscated complex code:")
load(maxObfuscated)()

-- ============================================================================
-- Example 4: Batch Compilation
-- ============================================================================

print("\n[Example 4: Batch Compilation]")
print("-" :rep(70))

local scripts = {
    {
        name = "math_operations.lua",
        code = "print('2 + 2 =', 2 + 2)"
    },
    {
        name = "string_operations.lua",
        code = "print('Hello ' .. 'World')"
    },
    {
        name = "table_operations.lua",
        code = "local t = {1,2,3}; print('Length:', #t)"
    }
}

local batchResult = VM.batchProcess(scripts)

print("Batch compilation results:")
print("  Total files:", batchResult.total)
print("  Compiled:", batchResult.compiled)
print("  Failed:", batchResult.failed)
print("  Success rate:", math.floor((batchResult.compiled / batchResult.total) * 100) .. "%")

-- ============================================================================
-- Example 5: Custom Compiler with Optimizations
-- ============================================================================

print("\n[Example 5: Custom Compiler with Optimizations]")
print("-" :rep(70))

local enc = Encryption.new(180)
local obf = Obfuscator.new(enc, {complexity = 7})
local compiler = Compiler.new(enc, obf, {
    optimize = true,
    stripDebug = true,
    obfuscateNames = true,
    constantFolding = true,
    deadCodeElimination = true
})

local sourceWithConstants = [[
local x = 10 + 5
local y = 20 * 2
local z = x + y
print("Result:", z)
print("Constant:", 100 + 200 + 300)
]]

print("Compiling with optimizations...")

local success, compiled = compiler:compile(sourceWithConstants)

if success then
    print("Compilation successful!")
    local stats = compiler:getStats()
    print("\nCompilation statistics:")
    print("  Source size:", stats.sourceSize, "bytes")
    print("  Output size:", stats.outputSize, "bytes")
    print("  Symbols renamed:", stats.symbolsRenamed)
    print("  Optimization level:", stats.optimizationLevel)
end

-- ============================================================================
-- Example 6: Encryption Hash and Verification
-- ============================================================================

print("\n[Example 6: Encryption Hash and Verification]")
print("-" :rep(70))

local enc = Encryption.new(150)
local data = "Data with integrity check"

local encrypted = enc:encrypt(data)
local hash = enc:generateHash(encrypted)

print("Data:", data)
print("Hash:", hash)

-- Verify integrity
local verified = enc:verify(encrypted)
print("Integrity verified:", verified and "✓ YES" or "✗ NO")

-- Simulate tampering
print("\nSimulating data tampering...")
encrypted.lkp[1] = (encrypted.lkp[1] + 1) % 256

local tamperedVerify = enc:verify(encrypted)
print("Tampered data verified:", tamperedVerify and "✓ YES" or "✗ NO (as expected)")

-- ============================================================================
-- Example 7: Advanced Obfuscation Layers
-- ============================================================================

print("\n[Example 7: Advanced Obfuscation Layers]")
print("-" :rep(70))

local simpleCode = "print('Testing layers')"

print("Creating multiple obfuscation layers:")

-- Layer 1
local layer1 = VM.obfuscate(simpleCode, {complexity = 3})
print("  Layer 1 size:", #layer1)

-- Layer 2 (obfuscate the obfuscated)
local layer2 = VM.obfuscate(layer1, {complexity = 5})
print("  Layer 2 size:", #layer2)

-- Layer 3
local layer3 = VM.obfuscate(layer2, {complexity = 7})
print("  Layer 3 size:", #layer3)

print("\nSize progression:")
print("  Original →", #simpleCode, "bytes")
print("  Layer 1  →", #layer1, "bytes (", math.floor(#layer1/#simpleCode), "x)")
print("  Layer 2  →", #layer2, "bytes (", math.floor(#layer2/#simpleCode), "x)")
print("  Layer 3  →", #layer3, "bytes (", math.floor(#layer3/#simpleCode), "x)")

-- ============================================================================
-- Example 8: VM with Global and Local Variables
-- ============================================================================

print("\n[Example 8: VM with Global and Local Variables]")
print("-" :rep(70))

local vm = VMCore.new()

-- Set globals
vm:setGlobal("appName", "Advanced VM")
vm:setGlobal("version", "1.0.0")

-- Set locals
vm:setLocal("tempData", {1, 2, 3})
vm:setLocal("counter", 42)

print("Global variables:")
print("  appName:", vm:getGlobal("appName"))
print("  version:", vm:getGlobal("version"))

print("\nLocal variables:")
print("  tempData:", table.concat(vm:getLocal("tempData"), ", "))
print("  counter:", vm:getLocal("counter"))

-- ============================================================================
-- Example 9: Performance Measurement
-- ============================================================================

print("\n[Example 9: Performance Measurement]")
print("-" :rep(70))

local testCode = [[
local sum = 0
for i = 1, 1000 do
    sum = sum + i
end
return sum
]]

-- Measure original execution
local originalFunc = loadstring(testCode)
local startTime = os.clock()
originalFunc()
local originalTime = os.clock() - startTime

-- Measure obfuscated execution
local obfuscatedCode = VM.obfuscate(testCode)
local obfuscatedFunc = loadstring(obfuscatedCode)
startTime = os.clock()
obfuscatedFunc()
local obfuscatedTime = os.clock() - startTime

print("Performance comparison:")
print("  Original execution:", string.format("%.6f", originalTime), "seconds")
print("  Obfuscated execution:", string.format("%.6f", obfuscatedTime), "seconds")
print("  Overhead:", string.format("%.2f", (obfuscatedTime/originalTime - 1) * 100) .. "%")

-- ============================================================================
-- Example 10: Full System Integration
-- ============================================================================

print("\n[Example 10: Full System Integration]")
print("-" :rep(70))

-- Initialize complete system
local system = VM.init({
    key = 200,
    encryptionOpts = {
        iterations = 5,
        extended = true
    },
    vmOpts = {
        maxStack = 512,
        debugMode = false
    },
    obfuscatorOpts = {
        complexity = 8,
        flowDepth = 10
    },
    compilerOpts = {
        optimize = true,
        stripDebug = true
    }
})

print("System initialized with custom options")
print("  Encryption iterations:", 5)
print("  VM max stack:", 512)
print("  Obfuscator complexity:", 8)
print("  Compiler optimizations: enabled")

local finalCode = [[
local function greet(name)
    return "Hello, " .. name .. "!"
end

print(greet("Advanced VM"))
]]

-- Process through full pipeline
local encrypted = system.encryption:encrypt(finalCode)
local obfuscated = system.obfuscator:obfuscate(finalCode)
local success, compiled = system.compiler:compile(finalCode)

print("\nPipeline results:")
print("  Encrypted length:", #encrypted.str, "chars")
print("  Obfuscated length:", #obfuscated, "bytes")
print("  Compilation:", success and "✓ SUCCESS" or "✗ FAILED")

print("\nExecuting final compiled code:")
load(compiled)()

-- ============================================================================
-- Summary
-- ============================================================================

print("\n" .. "=" :rep(70))
print("ADVANCED EXAMPLES COMPLETED SUCCESSFULLY")
print("=" :rep(70))
print("\nYou've mastered:")
print("  ✓ Multi-layer encryption")
print("  ✓ VM stack operations")
print("  ✓ Complex code obfuscation")
print("  ✓ Batch compilation")
print("  ✓ Custom compiler optimizations")
print("  ✓ Integrity verification")
print("  ✓ Multiple obfuscation layers")
print("  ✓ VM variable management")
print("  ✓ Performance measurement")
print("  ✓ Full system integration")
print("\nReady for production use!")
print("=" :rep(70))
