--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                    UTILS.LUA - Utility Functions                 ║
    ║              Helper Functions Library - Lua 5.1                  ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: src/utils.lua
    Compatible: Lua 5.1+
    Purpose: Common utility functions and helpers
]]--

local Utils = {}
Utils._VERSION = "1.0.0"

-- Lua 5.1 compatibility layer
local unpack = unpack or table.unpack
local loadstring = loadstring or load

-- ============================================================================
-- BIT OPERATIONS (Lua 5.1 fallback)
-- ============================================================================

if not bit32 and not bit then
    Utils.bit = {}
    
    function Utils.bit.bxor(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            local aa = a % 2
            local bb = b % 2
            if aa ~= bb then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
    
    function Utils.bit.band(a, b)
        local result = 0
        local bitval = 1
        while a > 0 and b > 0 do
            if a % 2 == 1 and b % 2 == 1 then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
    
    function Utils.bit.bor(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if a % 2 == 1 or b % 2 == 1 then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
    
    function Utils.bit.lshift(a, n)
        return math.floor(a * (2 ^ n)) % (2 ^ 32)
    end
    
    function Utils.bit.rshift(a, n)
        return math.floor(a / (2 ^ n))
    end
    
    -- Make it globally available
    _G.bit32 = Utils.bit
end

-- ============================================================================
-- STRING UTILITIES
-- ============================================================================

-- Convert string to hex
function Utils.stringToHex(str)
    local hex = {}
    for i = 1, #str do
        table.insert(hex, string.format("%02x", string.byte(str, i)))
    end
    return table.concat(hex)
end

-- Convert hex to string
function Utils.hexToString(hex)
    local str = {}
    for i = 1, #hex, 2 do
        local byte = tonumber(hex:sub(i, i + 1), 16)
        table.insert(str, string.char(byte))
    end
    return table.concat(str)
end

-- Escape special characters for patterns
function Utils.escapePattern(str)
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Split string by delimiter
function Utils.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", Utils.escapePattern(delimiter))
    
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    
    return result
end

-- Trim whitespace
function Utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- ============================================================================
-- TABLE UTILITIES
-- ============================================================================

-- Deep copy table
function Utils.deepCopy(orig, copies)
    copies = copies or {}
    local copy
    
    if type(orig) == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for k, v in next, orig, nil do
                copy[Utils.deepCopy(k, copies)] = Utils.deepCopy(v, copies)
            end
            setmetatable(copy, Utils.deepCopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    
    return copy
end

-- Merge tables
function Utils.merge(...)
    local result = {}
    local tables = {...}
    
    for _, t in ipairs(tables) do
        if type(t) == "table" then
            for k, v in pairs(t) do
                result[k] = v
            end
        end
    end
    
    return result
end

-- Table contains value
function Utils.contains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Get table keys
function Utils.keys(table)
    local result = {}
    for k, _ in pairs(table) do
        table.insert(result, k)
    end
    return result
end

-- Get table values
function Utils.values(table)
    local result = {}
    for _, v in pairs(table) do
        table.insert(result, v)
    end
    return result
end

-- Table size
function Utils.tableSize(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- ============================================================================
-- FILE UTILITIES
-- ============================================================================

-- Check if file exists
function Utils.fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Read file content
function Utils.readFile(path)
    local file, err = io.open(path, "r")
    if not file then
        return nil, err
    end
    
    local content = file:read("*all")
    file:close()
    
    return content
end

-- Write file content
function Utils.writeFile(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return false, err
    end
    
    file:write(content)
    file:close()
    
    return true
end

-- Append to file
function Utils.appendFile(path, content)
    local file, err = io.open(path, "a")
    if not file then
        return false, err
    end
    
    file:write(content)
    file:close()
    
    return true
end

-- Get file size
function Utils.fileSize(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    
    local size = file:seek("end")
    file:close()
    
    return size
end

-- ============================================================================
-- MATH UTILITIES
-- ============================================================================

-- Clamp value between min and max
function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Linear interpolation
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Map value from one range to another
function Utils.map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

-- Round number to decimals
function Utils.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Random integer between min and max (inclusive)
function Utils.randomInt(min, max)
    return math.random(min, max)
end

-- Random float between min and max
function Utils.randomFloat(min, max)
    return min + math.random() * (max - min)
end

-- ============================================================================
-- HASH AND CHECKSUM
-- ============================================================================

-- Simple hash function (DJB2)
function Utils.hash(str)
    local hash = 5381
    
    for i = 1, #str do
        hash = ((hash * 33) + string.byte(str, i)) % (2 ^ 32)
    end
    
    return hash
end

-- Checksum (simple additive)
function Utils.checksum(data)
    local sum = 0
    
    if type(data) == "string" then
        for i = 1, #data do
            sum = (sum + string.byte(data, i)) % 256
        end
    elseif type(data) == "table" then
        for _, v in pairs(data) do
            if type(v) == "number" then
                sum = (sum + v) % 256
            end
        end
    end
    
    return sum
end

-- CRC32 hash (simplified)
function Utils.crc32(str)
    local crc = 0xFFFFFFFF
    
    for i = 1, #str do
        local byte = string.byte(str, i)
        crc = bit32.bxor(crc, byte)
        
        for j = 1, 8 do
            if bit32.band(crc, 1) == 1 then
                crc = bit32.bxor(bit32.rshift(crc, 1), 0xEDB88320)
            else
                crc = bit32.rshift(crc, 1)
            end
        end
    end
    
    return bit32.bxor(crc, 0xFFFFFFFF)
end

-- ============================================================================
-- ENCODING/DECODING
-- ============================================================================

-- Base64 encoding table
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- Base64 encode
function Utils.base64Encode(data)
    local result = {}
    local padding = ""
    
    for i = 1, #data, 3 do
        local a, b, c = string.byte(data, i, i + 2)
        b = b or 0
        c = c or 0
        
        local n = a * 65536 + b * 256 + c
        
        local c1 = bit32.band(bit32.rshift(n, 18), 0x3F) + 1
        local c2 = bit32.band(bit32.rshift(n, 12), 0x3F) + 1
        local c3 = bit32.band(bit32.rshift(n, 6), 0x3F) + 1
        local c4 = bit32.band(n, 0x3F) + 1
        
        table.insert(result, b64chars:sub(c1, c1))
        table.insert(result, b64chars:sub(c2, c2))
        table.insert(result, i + 1 <= #data and b64chars:sub(c3, c3) or "=")
        table.insert(result, i + 2 <= #data and b64chars:sub(c4, c4) or "=")
    end
    
    return table.concat(result)
end

-- ============================================================================
-- DEBUG AND LOGGING
-- ============================================================================

-- Print table recursively
function Utils.printTable(t, indent, done)
    indent = indent or 0
    done = done or {}
    
    if done[t] then
        print(string.rep("  ", indent) .. "<circular reference>")
        return
    end
    
    done[t] = true
    
    for k, v in pairs(t) do
        local key = tostring(k)
        if type(v) == "table" then
            print(string.rep("  ", indent) .. key .. " = {")
            Utils.printTable(v, indent + 1, done)
            print(string.rep("  ", indent) .. "}")
        else
            print(string.rep("  ", indent) .. key .. " = " .. tostring(v))
        end
    end
end

-- Create timestamp
function Utils.timestamp()
    return os.time()
end

-- Format timestamp
function Utils.formatTime(time)
    return os.date("%Y-%m-%d %H:%M:%S", time)
end

-- Measure execution time
function Utils.measure(func)
    local start = os.clock()
    local result = {func()}
    local elapsed = os.clock() - start
    
    return elapsed, unpack(result)
end

-- ============================================================================
-- VALIDATION
-- ============================================================================

-- Check if value is empty
function Utils.isEmpty(value)
    if value == nil then
        return true
    end
    
    if type(value) == "string" and #value == 0 then
        return true
    end
    
    if type(value) == "table" and next(value) == nil then
        return true
    end
    
    return false
end

-- Type checking
function Utils.isString(value)
    return type(value) == "string"
end

function Utils.isNumber(value)
    return type(value) == "number"
end

function Utils.isTable(value)
    return type(value) == "table"
end

function Utils.isFunction(value)
    return type(value) == "function"
end

-- ============================================================================
-- Export module
-- ============================================================================

return Utils
