--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                 OBFUSCATOR.LUA - Code Obfuscator                 ║
    ║         Advanced VM Wrapper Generator - Lua 5.1                  ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: src/obfuscator.lua
    Compatible: Lua 5.1+
    Purpose: Generate complex VM wrappers with deep control flow
]]--

local Obfuscator = {}
Obfuscator.__index = Obfuscator
Obfuscator._VERSION = "1.0.0"

-- Lua 5.1 compatibility
local bit = bit32 or bit or require("bit")

-- Random variable name generators
local function randomVarName(prefix, length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local name = prefix or "_"
    length = length or math.random(3, 8)
    
    for i = 1, length do
        local idx = math.random(1, #chars)
        name = name .. chars:sub(idx, idx)
    end
    
    return name
end

-- Generate random hex variable names
local function hexVarName()
    return string.format("_0x%x%x%x", math.random(0, 15), math.random(0, 15), math.random(0, 15))
end

-- Constructor
function Obfuscator.new(encryption, options)
    local self = setmetatable({}, Obfuscator)
    
    if not encryption then
        error("Obfuscator requires encryption module")
    end
    
    self.encryption = encryption
    options = options or {}
    
    -- Obfuscation settings
    self.complexityLevel = options.complexity or 5
    self.useHexNames = options.hexNames ~= false
    self.minifyOutput = options.minify or false
    self.addAntiDebug = options.antiDebug ~= false
    self.controlFlowDepth = options.flowDepth or 7
    
    return self
end

-- Generate mathematical operation chains (TOP LAYER)
function Obfuscator:generateMathChains()
    local chains = {}
    
    -- Division chains
    table.insert(chains, string.format(
        "local %s=function(a,b)return((a*7+b*13)%%%%256)end;",
        hexVarName()
    ))
    
    -- Subtraction chains  
    table.insert(chains, string.format(
        "local %s=function(a,b)return((a-b+256)%%%%256)end;",
        hexVarName()
    ))
    
    -- Multiplication chains
    table.insert(chains, string.format(
        "local %s=function(a,b)return((a+b)*17%%%%256)end;",
        hexVarName()
    ))
    
    -- XOR chains
    table.insert(chains, string.format(
        "local %s=function(a,b)return bit32.bxor(a,b)end;",
        hexVarName()
    ))
    
    -- Complex transform chains
    for i = 1, self.complexityLevel do
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

-- Generate deep control flow (MIDDLE LAYER)
function Obfuscator:generateControlFlow(encData)
    local varVM = hexVarName()
    local varDecode = hexVarName()
    local varStage = {}
    
    -- Generate stage variable names
    for i = 1, self.controlFlowDepth do
        varStage[i] = hexVarName()
    end
    
    local flow = string.format([[
local %s={};
%s[1]="%s";
%s[2]={%s};
%s[3]=%d;
%s[4]=%d;
]], 
        varVM,
        varVM, encData.str:gsub('\\', '\\\\'):gsub('"', '\\"'),
        varVM, table.concat(encData.lkp, ","),
        varVM, encData.key,
        varVM, encData.salt or 0
    )
    
    -- Stage 1: Pre-processing with loops
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
    
    -- Stage 2: XOR operations with nested conditions
    flow = flow .. string.format([[
local %s=function(_buf)
local _r={};
for _i=1,#_buf do
local _v=_buf[_i];
local _s1=(_v-_i*7-%s[4]+512)%%%%256;
local _s2=bit32.bxor(_s1,%s[3]);
if _i%%%%3==0 then
_s2=bit32.bxor(_s2,0x5A);
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
    
    -- Stage 3: Deep nested control flow
    flow = flow .. string.format([[
local %s=function(_buf)
local _o={};
for _i=1,#_buf do
local _v=_buf[_i];
for _j=1,2 do
_v=bit32.bxor(_v,bit32.lshift(_j,2));
_v=(_v*3+_j*5)%%%%256;
_v=math.floor(_v/2)+(_j*7);
_v=_v%%%%256;
end
local _n=function(val)
local _t=val;
for _k=1,3 do
if _k%%%%2==0 then
_t=bit32.bxor(_t,_k*11);
else
_t=(_t+_k*7)%%%%256;
end
_t=(_t-_k+256)%%%%256;
end
return _t;
end;
_v=_n(_v);
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
_v=bit32.bxor(_v,0xAA);
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
local _dec=bit32.bxor(_xor,%s[3]);
_c[_i]=string.char(_dec);
end
return table.concat(_c);
end;
]], varStage[5], varVM, varVM, varVM)
    
    -- Main decode function that chains all stages
    flow = flow .. string.format([[
local %s=function()
local _b1=%s();
local _b2=%s(_b1);
local _b3=%s(_b2);
local _b4=%s(_b3);
return %s(_b4);
end;
]], varDecode, varStage[1], varStage[2], varStage[3], varStage[4], varStage[5])
    
    return flow, varDecode, varVM
end

-- Generate bottom layer with more math operations
function Obfuscator:generateBottomLayer(varDecode)
    local varExec = hexVarName()
    local varCheck = hexVarName()
    local varVerify = hexVarName()
    
    local bottom = string.format([[
local %s=function()
local _code=%s();
local _cs=0;
for _i=1,#_code do
local _b=string.byte(_code,_i);
_cs=(_cs*31+_b)%%%%65536;
_cs=(_cs-_i*7+65536)%%%%65536;
_cs=bit32.bxor(_cs,_i*13);
end
local %s=function(c)
local _h=0;
for _i=1,#c do
_h=(_h+string.byte(c,_i)*_i)%%%%256;
_h=(_h*17-_i*3+512)%%%%256;
end
return _h;
end;
local _h=%s(_code);
local _fn=loadstring(_code);
if _fn then return _fn()end;
end;
]], varExec, varDecode, varVerify, varVerify)
    
    return bottom, varExec
end

-- Generate complete obfuscated wrapper
function Obfuscator:obfuscate(sourceCode)
    if type(sourceCode) ~= "string" or #sourceCode == 0 then
        error("Source code must be non-empty string")
    end
    
    -- Encrypt the source code
    local encrypted = self.encryption:encrypt(sourceCode)
    
    -- Build the VM wrapper
    local parts = {}
    
    -- Add header comment
    table.insert(parts, "-- VM Obfuscated - First Advance Encryption\n")
    table.insert(parts, "-- Lua 5.1 Compatible\n")
    
    -- TOP: Mathematical operation chains
    table.insert(parts, self:generateMathChains())
    
    -- MIDDLE: Deep control flow
    local flowCode, varDecode, varVM = self:generateControlFlow(encrypted)
    table.insert(parts, flowCode)
    
    -- BOTTOM: Execution with more math operations
    local bottomCode, varExec = self:generateBottomLayer(varDecode)
    table.insert(parts, bottomCode)
    
    -- Wrap everything in return function
    local wrapper = string.format([[
return(function(...)
%s
return %s();
end)(...);
]], table.concat(parts, ""), varExec)
    
    return wrapper
end

-- Generate standalone executable
function Obfuscator:generateStandalone(sourceCode, options)
    options = options or {}
    
    local obfuscated = self:obfuscate(sourceCode)
    
    if options.addShebang then
        obfuscated = "#!/usr/bin/env lua\n" .. obfuscated
    end
    
    if options.addMetadata then
        local metadata = string.format([[
--[[
Generated by Advanced VM Obfuscator
Version: %s
Date: %s
Encryption: First Advance Encryption
]]--
]], self._VERSION, os.date("%Y-%m-%d %H:%M:%S"))
        obfuscated = metadata .. obfuscated
    end
    
    return obfuscated
end

-- Export module
return Obfuscator
