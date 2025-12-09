#!/usr/bin/env lua
--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║         OBFUSCATE.LUA - Termux Command Line Interface           ║
    ║              Advanced Lua VM Obfuscator - CLI Tool              ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: obfuscate.lua
    Purpose: Command-line tool for Termux
    Usage: lua obfuscate.lua <input.lua> [output.lua] [options]
    
    Termux Installation:
    1. pkg install lua git -y
    2. git clone https://github.com/LOZENP/Lua-Obfuscator.git
    3. cd Lua-Obfuscator
    4. chmod +x obfuscate.lua
    5. lua obfuscate.lua myfile.lua
]]--

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local VERSION = "1.0.0"
local AUTHOR = "First Advance Encryption"

-- Colors for Termux (ANSI codes)
local COLORS = {
    RESET = "\27[0m",
    RED = "\27[31m",
    GREEN = "\27[32m",
    YELLOW = "\27[33m",
    BLUE = "\27[34m",
    MAGENTA = "\27[35m",
    CYAN = "\27[36m",
    WHITE = "\27[37m",
    BOLD = "\27[1m"
}

-- Default options
local DEFAULT_OPTIONS = {
    complexity = 7,
    depth = 10,
    key = nil,
    verbose = false,
    minify = false,
    output = nil
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function printf(format, ...)
    print(string.format(format, ...))
end

local function colored(color, text)
    return color .. text .. COLORS.RESET
end

local function printSuccess(msg)
    print(colored(COLORS.GREEN, "✓ " .. msg))
end

local function printError(msg)
    print(colored(COLORS.RED, "✗ " .. msg))
end

local function printWarning(msg)
    print(colored(COLORS.YELLOW, "⚠ " .. msg))
end

local function printInfo(msg)
    print(colored(COLORS.CYAN, "ℹ " .. msg))
end

local function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function readFile(path)
    local file, err = io.open(path, "r")
    if not file then
        return nil, err
    end
    local content = file:read("*all")
    file:close()
    return content
end

local function writeFile(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return false, err
    end
    file:write(content)
    file:close()
    return true
end

-- ============================================================================
-- ENCRYPTION ENGINE (Embedded)
-- ============================================================================

local bit = bit32 or bit or (function()
    local bit = {}
    function bit.bxor(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if (a % 2) ~= (b % 2) then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
    function bit.lshift(a, n)
        return math.floor(a * (2 ^ n)) % (2 ^ 32)
    end
    function bit.rshift(a, n)
        return math.floor(a / (2 ^ n))
    end
    return bit
end)()

local Encryption = {}
Encryption.__index = Encryption

function Encryption.new(key)
    local self = setmetatable({}, Encryption)
    self.key = key or math.random(100, 255)
    self.salt = math.random(1, 99)
    self.chars = "!@#$%^&*()_+-=[]{}|;:',.<>?/~`₱฿€£¥"
    return self
end

function Encryption:encrypt(code)
    local obfStr = {}
    local lookup = {}
    
    for i = 1, #code do
        local byte = string.byte(code, i)
        local xored = bit.bxor(byte, self.key)
        local encoded = (xored + i * 7 + self.salt) % 256
        lookup[i] = encoded
        local charIdx = (encoded % #self.chars) + 1
        obfStr[i] = self.chars:sub(charIdx, charIdx)
    end
    
    return {
        str = table.concat(obfStr),
        lkp = lookup,
        key = self.key,
        salt = self.salt
    }
end

-- ============================================================================
-- OBFUSCATOR ENGINE (Embedded)
-- ============================================================================

local function hexVarName()
    return string.format("_0x%x%x%x", math.random(0, 15), math.random(0, 15), math.random(0, 15))
end

local function generateMathChains(complexity)
    local chains = {}
    
    table.insert(chains, string.format(
        "local %s=function(a,b)return((a*7+b*13)%%%%256)end;",
        hexVarName()
    ))
    
    table.insert(chains, string.format(
        "local %s=function(a,b)return((a-b+256)%%%%256)end;",
        hexVarName()
    ))
    
    table.insert(chains, string.format(
        "local %s=function(a,b)return((a+b)*17%%%%256)end;",
        hexVarName()
    ))
    
    table.insert(chains, string.format(
        "local %s=function(a,b)return bit.bxor(a,b)end;",
        hexVarName()
    ))
    
    for i = 1, complexity do
        local ops = {"+", "-", "*", "%%"}
        local op1 = ops[math.random(#ops)]
        local op2 = ops[math.random(#ops)]
        
        table.insert(chains, string.format(
            "local %s=function(x)return((x%s%d)%s%d)%%%%256 end;",
            hexVarName(),
            op1, math.random(3, 19),
            op2, math.random(3, 23)
        ))
    end
    
    return table.concat(chains, "")
end

local function generateControlFlow(encData, depth)
    local varVM = hexVarName()
    local varDecode = hexVarName()
    local varStage = {}
    
    for i = 1, math.min(depth, 10) do
        varStage[i] = hexVarName()
    end
    
    local lookupStr = table.concat(encData.lkp, ",")
    local encStr = encData.str:gsub('\\', '\\\\'):gsub('"', '\\"')
    
    local flow = string.format([[
local %s={};
%s[1]="%s";
%s[2]={%s};
%s[3]=%d;
%s[4]=%d;
]], 
        varVM,
        varVM, encStr,
        varVM, lookupStr,
        varVM, encData.key,
        varVM, encData.salt
    )
    
    -- Stage 1: Pre-processing
    flow = flow .. string.format([[
local %s=function()
local _b={};
local _l=#%s[1];
for _i=1,_l do
local _e=%s[2][_i];
local _t=_e;
for _j=1,3 do
_t=(_t*11+_j*7)%%%%256;
_t=(_t/2)+(_j*3);
_t=math.floor(_t)%%%%256;
end
_b[_i]=_t;
end
return _b;
end;
]], varStage[1], varVM, varVM)
    
    -- Stage 2: XOR with conditions
    flow = flow .. string.format([[
local %s=function(_buf)
local _r={};
for _i=1,#_buf do
local _v=_buf[_i];
local _s1=(_v-_i*7-%s[4]+512)%%%%256;
local _s2=bit.bxor(_s1,%s[3]);
if _i%%%%3==0 then
_s2=bit.bxor(_s2,0x5A);
elseif _i%%%%3==1 then
_s2=(_s2+13)%%%%256;
else
_s2=(_s2-7+256)%%%%256;
end
_r[_i]=_s2;
end
return _r;
end;
]], varStage[2], varVM, varVM)
    
    -- Stage 3: Nested operations
    flow = flow .. string.format([[
local %s=function(_buf)
local _o={};
for _i=1,#_buf do
local _v=_buf[_i];
for _j=1,2 do
_v=bit.bxor(_v,bit.lshift(_j,2));
_v=(_v*3+_j*5)%%%%256;
_v=math.floor(_v/2)+(_j*7);
_v=_v%%%%256;
end
_o[_i]=_v;
end
return _o;
end;
]], varStage[3])
    
    -- Stage 4: Reverse operations
    flow = flow .. string.format([[
local %s=function(_buf)
local _f={};
for _i=#_buf,1,-1 do
local _v=_buf[_i];
_v=bit.bxor(_v,0xAA);
_v=(_v*7+13)%%%%256;
_v=math.floor(_v/3);
_f[#_f+1]=_v;
end
local _rev={};
for _i=#_f,1,-1 do
_rev[#_rev+1]=_f[_i];
end
return _rev;
end;
]], varStage[4])
    
    -- Stage 5: Final decryption
    flow = flow .. string.format([[
local %s=function(_buf)
local _c={};
for _i=1,#_buf do
local _enc=%s[2][_i];
local _xor=(_enc-_i*7-%s[4]+512)%%%%256;
local _dec=bit.bxor(_xor,%s[3]);
_c[_i]=string.char(_dec);
end
return table.concat(_c);
end;
]], varStage[5], varVM, varVM, varVM)
    
    -- Main decode
    flow = flow .. string.format([[
local %s=function()
local _b1=%s();
local _b2=%s(_b1);
local _b3=%s(_b2);
local _b4=%s(_b3);
return %s(_b4);
end;
]], varDecode, varStage[1], varStage[2], varStage[3], varStage[4], varStage[5])
    
    return flow, varDecode
end

local function generateBottomLayer(varDecode)
    local varExec = hexVarName()
    
    local bottom = string.format([[
local %s=function()
local _code=%s();
local _cs=0;
for _i=1,#_code do
local _b=string.byte(_code,_i);
_cs=(_cs*31+_b)%%%%65536;
_cs=(_cs-_i*7+65536)%%%%65536;
_cs=bit.bxor(_cs,_i*13);
end
local _fn=loadstring(_code);
if _fn then return _fn()end;
end;
]], varExec, varDecode)
    
    return bottom, varExec
end

local function obfuscate(code, options)
    local enc = Encryption.new(options.key)
    local encrypted = enc:encrypt(code)
    
    local parts = {}
    
    -- Header
    table.insert(parts, "-- VM Obfuscated - First Advance Encryption\n")
    
    -- Bit library check
    table.insert(parts, "local bit=bit32 or bit or(function()local b={}function b.bxor(a,c)local r=0;local v=1;while a>0 or c>0 do if(a%2)~=(c%2)then r=r+v end;v=v*2;a=math.floor(a/2);c=math.floor(c/2)end;return r end;function b.lshift(a,n)return math.floor(a*(2^n))%(2^32)end;function b.rshift(a,n)return math.floor(a/(2^n))end;return b end)();\n")
    
    -- TOP: Math chains
    table.insert(parts, generateMathChains(options.complexity))
    
    -- MIDDLE: Control flow
    local flowCode, varDecode = generateControlFlow(encrypted, options.depth)
    table.insert(parts, flowCode)
    
    -- BOTTOM: Execution
    local bottomCode, varExec = generateBottomLayer(varDecode)
    table.insert(parts, bottomCode)
    
    -- Wrapper
    local wrapper = string.format([[
return(function(...)
%s
return %s();
end)(...);
]], table.concat(parts, ""), varExec)
    
    return wrapper
end

-- ============================================================================
-- CLI FUNCTIONS
-- ============================================================================

local function printBanner()
    print(colored(COLORS.CYAN .. COLORS.BOLD, [[
╔══════════════════════════════════════════════════════════════════╗
║        Advanced Lua VM Obfuscator - Termux Edition              ║
║              First Advance Encryption System                     ║
╚══════════════════════════════════════════════════════════════════╝
]]))
    printf("Version: %s | Author: %s\n", VERSION, AUTHOR)
end

local function printUsage()
    print([[
Usage: lua obfuscate.lua <input.lua> [output.lua] [options]

Arguments:
  input.lua              Input Lua file to obfuscate
  output.lua             Output file (default: input.lua.obf)

Options:
  --complexity <1-10>    Obfuscation complexity level (default: 7)
  --depth <1-15>         Control flow depth (default: 10)
  --key <number>         Custom encryption key (default: random)
  --verbose, -v          Verbose output
  --minify               Minify output (remove whitespace)
  --help, -h             Show this help message
  --version              Show version information

Examples:
  lua obfuscate.lua script.lua
  lua obfuscate.lua input.lua output.lua
  lua obfuscate.lua script.lua --complexity 10 --depth 15
  lua obfuscate.lua script.lua --key 200 --verbose

Termux Quick Start:
  1. pkg install lua git -y
  2. git clone https://github.com/LOZENP/Lua-Obfuscator.git
  3. cd Lua-Obfuscator
  4. chmod +x obfuscate.lua
  5. lua obfuscate.lua myfile.lua

For more info: https://github.com/LOZENP/Lua-Obfuscator
]])
end

local function parseArgs(args)
    local options = {}
    for k, v in pairs(DEFAULT_OPTIONS) do
        options[k] = v
    end
    
    local inputFile = nil
    local outputFile = nil
    local i = 1
    
    while i <= #args do
        local arg = args[i]
        
        if arg == "--help" or arg == "-h" then
            printUsage()
            os.exit(0)
        elseif arg == "--version" then
            printf("Version %s", VERSION)
            os.exit(0)
        elseif arg == "--complexity" then
            i = i + 1
            options.complexity = tonumber(args[i]) or DEFAULT_OPTIONS.complexity
        elseif arg == "--depth" then
            i = i + 1
            options.depth = tonumber(args[i]) or DEFAULT_OPTIONS.depth
        elseif arg == "--key" then
            i = i + 1
            options.key = tonumber(args[i])
        elseif arg == "--verbose" or arg == "-v" then
            options.verbose = true
        elseif arg == "--minify" then
            options.minify = true
        elseif not inputFile then
            inputFile = arg
        elseif not outputFile then
            outputFile = arg
        end
        
        i = i + 1
    end
    
    if not inputFile then
        printError("No input file specified")
        printInfo("Use --help for usage information")
        os.exit(1)
    end
    
    options.input = inputFile
    options.output = outputFile or (inputFile .. ".obf")
    
    return options
end

-- ============================================================================
-- MAIN FUNCTION
-- ============================================================================

local function main(args)
    printBanner()
    
    if #args == 0 then
        printUsage()
        os.exit(1)
    end
    
    local options = parseArgs(args)
    
    -- Validate input file
    if not fileExists(options.input) then
        printError(string.format("Input file not found: %s", options.input))
        os.exit(1)
    end
    
    if options.verbose then
        printInfo(string.format("Input file: %s", options.input))
        printInfo(string.format("Output file: %s", options.output))
        printInfo(string.format("Complexity: %d", options.complexity))
        printInfo(string.format("Depth: %d", options.depth))
        if options.key then
            printInfo(string.format("Encryption key: %d", options.key))
        end
    end
    
    print(colored(COLORS.YELLOW, "\n⏳ Reading source file..."))
    local source, err = readFile(options.input)
    if not source then
        printError(string.format("Failed to read file: %s", err))
        os.exit(1)
    end
    
    printSuccess(string.format("Read %d bytes", #source))
    
    print(colored(COLORS.YELLOW, "\n⏳ Obfuscating code..."))
    local startTime = os.clock()
    local obfuscated = obfuscate(source, options)
    local elapsed = os.clock() - startTime
    
    printSuccess(string.format("Obfuscation complete in %.3f seconds", elapsed))
    printInfo(string.format("Output size: %d bytes (%.1fx)", #obfuscated, #obfuscated/#source))
    
    print(colored(COLORS.YELLOW, "\n⏳ Writing output file..."))
    local success, writeErr = writeFile(options.output, obfuscated)
    if not success then
        printError(string.format("Failed to write file: %s", writeErr))
        os.exit(1)
    end
    
    printSuccess(string.format("Saved to: %s", options.output))
    
    -- Test execution
    if options.verbose then
        print(colored(COLORS.YELLOW, "\n⏳ Testing obfuscated code..."))
        local testFunc, loadErr = loadstring(obfuscated)
        if testFunc then
            printSuccess("Code is valid and executable")
        else
            printWarning("Code validation failed: " .. tostring(loadErr))
        end
    end
    
    print(colored(COLORS.GREEN .. COLORS.BOLD, "\n✓ All done! Your code is now protected.\n"))
end

-- ============================================================================
-- ENTRY POINT
-- ============================================================================

-- Run main with error handling
local success, err = pcall(main, {...})

if not success then
    print(colored(COLORS.RED .. COLORS.BOLD, "\n✗ ERROR: " .. tostring(err) .. "\n"))
    os.exit(1)
end
