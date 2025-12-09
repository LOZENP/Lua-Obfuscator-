--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║              BASIC USAGE EXAMPLES - Advanced Lua VM              ║
    ║                    Simple and Easy Examples                      ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: examples/basic_usage.lua
    Purpose: Demonstrate basic usage of the VM system
]]--

-- Load the main module
local VM = require("main")

print("=" :rep(70))
print("BASIC USAGE EXAMPLES - ADVANCED LUA VM")
print("=" :rep(70))

-- ============================================================================
-- Example 1: Simple Code Obfuscation
-- ============================================================================

print("\n[Example 1: Simple Code Obfuscation]")
print("-" :rep(70))

local simpleCode = [[
print("Hello from obfuscated code!")
local message = "This is protected"
print("Message:", message)
]]

print("Original code:")
print(simpleCode)

local obfuscated = VM.obfuscate(simpleCode)

print("\nObfuscated code (first 300 chars):")
print(obfuscated:sub(1, 300) .. "...")

print("\nExecuting obfuscated code:")
load(obfuscated)()

-- ============================================================================
-- Example 2: Basic Encryption
-- ============================================================================

print("\n[Example 2: Basic Encryption]")
print("-" :rep(70))

local plaintext = "Secret Password 123"
print("Plaintext:", plaintext)

-- Encrypt with auto-generated key
local encrypted = VM.encrypt(plaintext)

print("Encrypted string:", encrypted.str)
print("Encryption key:", encrypted.key)
print("Salt:", encrypted.salt)
print("Length:", #encrypted.str, "chars")

-- Decrypt
local decrypted = VM.decrypt(encrypted)
print("Decrypted:", decrypted)
print("Match:", plaintext == decrypted and "✓ YES" or "✗ NO")

-- ============================================================================
-- Example 3: Custom Encryption Key
-- ============================================================================

print("\n[Example 3: Custom Encryption Key]")
print("-" :rep(70))

local myKey = 200
local data = "Custom key encryption"

print("Data:", data)
print("Custom key:", myKey)

local enc = VM.encrypt(data, myKey)
print("Encrypted:", enc.str)

local dec = VM.decrypt(enc, myKey)
print("Decrypted:", dec)
print("Match:", data == dec and "✓ YES" or "✗ NO")

-- ============================================================================
-- Example 4: Protect a Simple Function
-- ============================================================================

print("\n[Example 4: Protect a Simple Function]")
print("-" :rep(70))

local functionCode = [[
local function add(a, b)
    return a + b
end

local function multiply(a, b)
    return a * b
end

print("5 + 3 =", add(5, 3))
print("5 * 3 =", multiply(5, 3))
]]

print("Original function code:")
print(functionCode)

local protectedFunc = VM.obfuscate(functionCode)

print("\nProtected code length:", #protectedFunc, "bytes")
print("\nExecuting protected code:")
load(protectedFunc)()

-- ============================================================================
-- Example 5: Obfuscate with Options
-- ============================================================================

print("\n[Example 5: Obfuscate with Options]")
print("-" :rep(70))

local code = [[
local x = 10
local y = 20
print("Result:", x + y)
]]

-- Low complexity
local lowComplex = VM.obfuscate(code, {
    complexity = 2,
    flowDepth = 3
})

-- High complexity
local highComplex = VM.obfuscate(code, {
    complexity = 8,
    flowDepth = 10
})

print("Original code length:", #code, "bytes")
print("Low complexity:", #lowComplex, "bytes")
print("High complexity:", #highComplex, "bytes")
print("Increase:", math.floor((#highComplex / #code) * 100), "%")

-- ============================================================================
-- Example 6: String Manipulation
-- ============================================================================

print("\n[Example 6: String Manipulation]")
print("-" :rep(70))

local stringCode = [[
local str = "Hello World"
print("Original:", str)
print("Upper:", string.upper(str))
print("Lower:", string.lower(str))
print("Length:", #str)
]]

local obfStr = VM.obfuscate(stringCode)
print("Obfuscated string manipulation code")
print("\nExecuting:")
load(obfStr)()

-- ============================================================================
-- Example 7: Loops and Conditionals
-- ============================================================================

print("\n[Example 7: Loops and Conditionals]")
print("-" :rep(70))

local loopCode = [[
for i = 1, 5 do
    if i % 2 == 0 then
        print(i, "is even")
    else
        print(i, "is odd")
    end
end
]]

local obfLoop = VM.obfuscate(loopCode)
print("Obfuscated loop code")
print("\nExecuting:")
load(obfLoop)()

-- ============================================================================
-- Example 8: Table Operations
-- ============================================================================

print("\n[Example 8: Table Operations]")
print("-" :rep(70))

local tableCode = [[
local data = {
    name = "Lua VM",
    version = "1.0",
    features = {"encryption", "obfuscation", "vm"}
}

print("Name:", data.name)
print("Version:", data.version)
print("Features:")
for i, feature in ipairs(data.features) do
    print("  " .. i .. ".", feature)
end
]]

local obfTable = VM.obfuscate(tableCode)
print("Obfuscated table code")
print("\nExecuting:")
load(obfTable)()

-- ============================================================================
-- Example 9: Mathematical Operations
-- ============================================================================

print("\n[Example 9: Mathematical Operations]")
print("-" :rep(70))

local mathCode = [[
local a = 15
local b = 4

print("Addition:", a + b)
print("Subtraction:", a - b)
print("Multiplication:", a * b)
print("Division:", a / b)
print("Modulo:", a % b)
print("Power:", a ^ 2)
]]

local obfMath = VM.obfuscate(mathCode)
print("Obfuscated math code")
print("\nExecuting:")
load(obfMath)()

-- ============================================================================
-- Example 10: Multiple Encryptions
-- ============================================================================

print("\n[Example 10: Multiple Encryptions]")
print("-" :rep(70))

local secretData = "Important Information"

print("Original data:", secretData)
print("\nEncrypting with different keys:")

for i = 1, 3 do
    local key = math.random(100, 255)
    local enc = VM.encrypt(secretData, key)
    
    print(string.format(
        "  Round %d: Key=%d, Encrypted=%s...",
        i, key, enc.str:sub(1, 20)
    ))
end

-- ============================================================================
-- Summary
-- ============================================================================

print("\n" .. "=" :rep(70))
print("BASIC EXAMPLES COMPLETED SUCCESSFULLY")
print("=" :rep(70))
print("\nNext steps:")
print("  • Check advanced_usage.lua for complex examples")
print("  • Read README.md for full API documentation")
print("  • Run tests with: lua tests/test_all.lua")
print("=" :rep(70))
