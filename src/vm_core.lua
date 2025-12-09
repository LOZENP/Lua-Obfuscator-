--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                    VM_CORE.LUA - Virtual Machine                 ║
    ║              Advanced VM Engine - Lua 5.1                        ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    File: src/vm_core.lua
    Compatible: Lua 5.1+
    Purpose: Advanced virtual machine with stack operations
]]--

local VMCore = {}
VMCore.__index = VMCore
VMCore._VERSION = "1.0.0"

-- Lua 5.1 compatibility
local unpack = unpack or table.unpack
local loadstring = loadstring or load

-- VM Opcodes (bytecode instructions)
local OPCODES = {
    LOAD = 0x01,
    STORE = 0x02,
    ADD = 0x03,
    SUB = 0x04,
    MUL = 0x05,
    DIV = 0x06,
    MOD = 0x07,
    POW = 0x08,
    NEG = 0x09,
    PUSH = 0x0A,
    POP = 0x0B,
    CALL = 0x0C,
    RETURN = 0x0D,
    JUMP = 0x0E,
    JUMPIF = 0x0F,
    CMP = 0x10,
    HALT = 0xFF
}

-- Constructor
function VMCore.new(options)
    local self = setmetatable({}, VMCore)
    
    options = options or {}
    
    -- VM State
    self.stack = {}
    self.callStack = {}
    self.registers = {}
    self.memory = {}
    self.globals = {}
    self.locals = {}
    
    -- VM Control
    self.pc = 1  -- Program counter
    self.sp = 0  -- Stack pointer
    self.fp = 0  -- Frame pointer
    self.running = false
    self.halted = false
    
    -- VM Configuration
    self.maxStack = options.maxStack or 1024
    self.maxCallDepth = options.maxCallDepth or 256
    self.debugMode = options.debug or false
    
    -- Instruction set
    self.instructions = {}
    self.bytecode = {}
    
    return self
end

-- Stack Operations
function VMCore:push(value)
    if self.sp >= self.maxStack then
        error("Stack overflow: maximum stack size exceeded")
    end
    
    self.sp = self.sp + 1
    self.stack[self.sp] = value
    
    if self.debugMode then
        self:log("PUSH", value, "SP=" .. self.sp)
    end
end

function VMCore:pop()
    if self.sp <= 0 then
        error("Stack underflow: attempted to pop from empty stack")
    end
    
    local value = self.stack[self.sp]
    self.stack[self.sp] = nil
    self.sp = self.sp - 1
    
    if self.debugMode then
        self:log("POP", value, "SP=" .. self.sp)
    end
    
    return value
end

function VMCore:peek(offset)
    offset = offset or 0
    local index = self.sp - offset
    
    if index <= 0 then
        error("Stack peek error: invalid offset")
    end
    
    return self.stack[index]
end

function VMCore:stackSize()
    return self.sp
end

-- Register Operations
function VMCore:setRegister(reg, value)
    if type(reg) ~= "number" or reg < 0 or reg > 255 then
        error("Invalid register: " .. tostring(reg))
    end
    
    self.registers[reg] = value
    
    if self.debugMode then
        self:log("SETREG", "R" .. reg, value)
    end
end

function VMCore:getRegister(reg)
    if type(reg) ~= "number" or reg < 0 or reg > 255 then
        error("Invalid register: " .. tostring(reg))
    end
    
    return self.registers[reg]
end

-- Memory Operations
function VMCore:writeMemory(address, value)
    self.memory[address] = value
    
    if self.debugMode then
        self:log("WRITE", "M[" .. address .. "]", value)
    end
end

function VMCore:readMemory(address)
    return self.memory[address]
end

-- Variable Operations
function VMCore:setGlobal(name, value)
    if type(name) ~= "string" then
        error("Global variable name must be string")
    end
    
    self.globals[name] = value
end

function VMCore:getGlobal(name)
    return self.globals[name]
end

function VMCore:setLocal(name, value)
    if type(name) ~= "string" then
        error("Local variable name must be string")
    end
    
    if not self.locals[self.fp] then
        self.locals[self.fp] = {}
    end
    
    self.locals[self.fp][name] = value
end

function VMCore:getLocal(name)
    if not self.locals[self.fp] then
        return nil
    end
    
    return self.locals[self.fp][name]
end

-- Call Stack Operations
function VMCore:pushCall(returnAddr)
    if #self.callStack >= self.maxCallDepth then
        error("Call stack overflow: maximum call depth exceeded")
    end
    
    table.insert(self.callStack, {
        returnAddr = returnAddr,
        fp = self.fp,
        sp = self.sp
    })
    
    self.fp = self.sp
end

function VMCore:popCall()
    if #self.callStack == 0 then
        error("Call stack underflow: no function to return from")
    end
    
    local frame = table.remove(self.callStack)
    self.pc = frame.returnAddr
    self.fp = frame.fp
    
    -- Clean up local variables
    self.locals[self.fp] = nil
    
    return frame
end

-- Arithmetic Operations
function VMCore:executeArithmetic(op)
    local b = self:pop()
    local a = self:pop()
    local result
    
    if op == OPCODES.ADD then
        result = a + b
    elseif op == OPCODES.SUB then
        result = a - b
    elseif op == OPCODES.MUL then
        result = a * b
    elseif op == OPCODES.DIV then
        if b == 0 then
            error("Division by zero")
        end
        result = a / b
    elseif op == OPCODES.MOD then
        result = a % b
    elseif op == OPCODES.POW then
        result = a ^ b
    else
        error("Unknown arithmetic operation")
    end
    
    self:push(result)
    return result
end

-- Load and Execute Code
function VMCore:load(code, encrypted)
    if encrypted then
        -- Will be decrypted by encryption module
        self.encryptedCode = code
        return true
    end
    
    local func, err = loadstring(code)
    if not func then
        return false, "Load error: " .. tostring(err)
    end
    
    self.code = code
    self.func = func
    return true
end

function VMCore:execute(...)
    if not self.func then
        return false, "No code loaded"
    end
    
    self.running = true
    self.halted = false
    
    -- Set up environment
    local env = setmetatable({}, {
        __index = function(t, k)
            return self:getGlobal(k) or self:getLocal(k) or _G[k]
        end,
        __newindex = function(t, k, v)
            self:setGlobal(k, v)
        end
    })
    
    setfenv(self.func, env)
    
    -- Execute with error handling
    local success, result = pcall(self.func, ...)
    
    self.running = false
    
    if not success then
        return false, "Execution error: " .. tostring(result)
    end
    
    return true, result
end

-- VM Control
function VMCore:reset()
    self.stack = {}
    self.callStack = {}
    self.registers = {}
    self.memory = {}
    self.pc = 1
    self.sp = 0
    self.fp = 0
    self.running = false
    self.halted = false
end

function VMCore:halt()
    self.halted = true
    self.running = false
end

function VMCore:isRunning()
    return self.running and not self.halted
end

-- Debug Operations
function VMCore:log(operation, ...)
    if not self.debugMode then return end
    
    local args = {...}
    local msg = "[VM] " .. operation
    for i, v in ipairs(args) do
        msg = msg .. " | " .. tostring(v)
    end
    print(msg)
end

function VMCore:dumpStack()
    print("=== Stack Dump ===")
    print("SP:", self.sp)
    for i = self.sp, 1, -1 do
        print(string.format("  [%d] = %s", i, tostring(self.stack[i])))
    end
end

function VMCore:dumpRegisters()
    print("=== Register Dump ===")
    for reg, value in pairs(self.registers) do
        print(string.format("  R%d = %s", reg, tostring(value)))
    end
end

function VMCore:getState()
    return {
        pc = self.pc,
        sp = self.sp,
        fp = self.fp,
        running = self.running,
        halted = self.halted,
        stackSize = self.sp,
        callDepth = #self.callStack
    }
end

-- Export module
return VMCore
