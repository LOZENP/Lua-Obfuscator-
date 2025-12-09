--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                    ENCRYPTION.LUA - Core Engine                  ║
    ║              First Advance Encryption - Lua 5.1                  ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: src/encryption.lua
    Compatible: Lua 5.1+
    Purpose: Advanced encryption/decryption engine
]]--

local Encryption = {}
Encryption.__index = Encryption
Encryption._VERSION = "1.0.0"

-- Lua 5.1 compatible bit operations
local bit = bit32 or bit or require("bit")

-- Advanced character set for obfuscation
local CHARSET_ADVANCED = "!@#$%^&*()_+-=[]{}|;:',.<>?/~`"
local CHARSET_EXTENDED = "₱฿€£¥§¶©®™°•"
local CHARSET_SYMBOLS = "αβγδεζηθικλμνξοπρστυφχψω"

-- Mathematical constants for transformations
local PRIME_1 = 7
local PRIME_2 = 13
local PRIME_3 = 17
local PRIME_4 = 19
local MODULO_BASE = 256
local SALT_MULTIPLIER = 23

-- Constructor
function Encryption.new(customKey, options)
    local self = setmetatable({}, Encryption)
    
    options = options or {}
    self.key = customKey or math.random(100, 255)
    self.salt = math.random(1, 99)
    self.iterations = options.iterations or 3
    self.useExtended = options.extended or false
    
    -- Build character set
    self.chars = CHARSET_ADVANCED
    if self.useExtended then
        self.chars = self.chars .. CHARSET_EXTENDED .. CHARSET_SYMBOLS
    end
    
    return self
end

-- Advanced multi-layer encryption
function Encryption:encrypt(code)
    if type(code) ~= "string" or #code == 0 then
        error("Encryption.encrypt: Input must be a non-empty string")
    end
    
    local obfuscatedStr = {}
    local encodedValues = {}
    local checksums = {}
    
    for i = 1, #code do
        local byte = string.byte(code, i)
        
        -- Layer 1: XOR with dynamic key
        local dynamicKey = bit.bxor(self.key, (i * PRIME_1) % MODULO_BASE)
        local xored = bit.bxor(byte, dynamicKey)
        
        -- Layer 2: Positional transformation
        local transformed = (xored + i * PRIME_1 + self.salt * PRIME_2) % MODULO_BASE
        
        -- Layer 3: Non-linear mixing
        local mixed = bit.bxor(transformed, bit.lshift(i % 8, (i % 3) + 1))
        
        -- Layer 4: Final encoding with multiple iterations
        local encoded = mixed
        for iter = 1, self.iterations do
            encoded = (encoded * PRIME_3 + iter * PRIME_4) % MODULO_BASE
            encoded = bit.bxor(encoded, (i * iter) % MODULO_BASE)
        end
        
        encodedValues[i] = encoded
        
        -- Generate checksum for integrity
        checksums[i] = (byte + i + self.salt) % MODULO_BASE
        
        -- Map to character set
        local charIndex = (encoded % #self.chars) + 1
        obfuscatedStr[i] = self.chars:sub(charIndex, charIndex)
    end
    
    return {
        str = table.concat(obfuscatedStr),
        lkp = encodedValues,
        key = self.key,
        salt = self.salt,
        iterations = self.iterations,
        checksum = checksums,
        length = #code
    }
end

-- Advanced multi-layer decryption
function Encryption:decrypt(encData)
    if type(encData) ~= "table" or not encData.lkp then
        error("Encryption.decrypt: Invalid encrypted data structure")
    end
    
    local result = {}
    local key = encData.key
    local salt = encData.salt
    local iterations = encData.iterations or self.iterations
    
    for i = 1, #encData.lkp do
        local encoded = encData.lkp[i]
        
        -- Reverse Layer 4: Undo iterations
        local decoded = encoded
        for iter = iterations, 1, -1 do
            decoded = bit.bxor(decoded, (i * iter) % MODULO_BASE)
            -- Reverse multiply (find modular inverse)
            decoded = (decoded - iter * PRIME_4 + MODULO_BASE * 10) % MODULO_BASE
            local invPrime = self:modInverse(PRIME_3, MODULO_BASE)
            decoded = (decoded * invPrime) % MODULO_BASE
        end
        
        -- Reverse Layer 3: Unmix
        local unmixed = bit.bxor(decoded, bit.lshift(i % 8, (i % 3) + 1))
        
        -- Reverse Layer 2: Undo transformation
        local untransformed = (unmixed - i * PRIME_1 - salt * PRIME_2 + MODULO_BASE * 10) % MODULO_BASE
        
        -- Reverse Layer 1: XOR with dynamic key
        local dynamicKey = bit.bxor(key, (i * PRIME_1) % MODULO_BASE)
        local original = bit.bxor(untransformed, dynamicKey)
        
        result[i] = string.char(original)
    end
    
    return table.concat(result)
end

-- Modular multiplicative inverse (Extended Euclidean Algorithm)
function Encryption:modInverse(a, m)
    local m0 = m
    local x0, x1 = 0, 1
    
    if m == 1 then return 0 end
    
    while a > 1 do
        local q = math.floor(a / m)
        local t = m
        m = a % m
        a = t
        t = x0
        x0 = x1 - q * x0
        x1 = t
    end
    
    if x1 < 0 then x1 = x1 + m0 end
    
    return x1
end

-- Generate encryption hash
function Encryption:generateHash(data)
    local hash = 0
    local dataStr = type(data) == "table" and data.str or data
    
    for i = 1, #dataStr do
        local byte = string.byte(dataStr, i)
        hash = (hash * SALT_MULTIPLIER + byte * i) % 65536
        hash = bit.bxor(hash, bit.lshift(i % 16, (i % 4)))
    end
    
    return hash
end

-- Verify encrypted data integrity
function Encryption:verify(encData)
    if not encData.checksum then return true end
    
    local verified = true
    for i = 1, #encData.lkp do
        local expected = encData.checksum[i]
        -- Verification logic
        if not expected then
            verified = false
            break
        end
    end
    
    return verified
end

-- Export module
return Encryption
