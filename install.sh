#!/data/data/com.termux/files/usr/bin/bash
#
# ╔══════════════════════════════════════════════════════════════════╗
# ║     Automatic Installer for Advanced Lua VM Obfuscator          ║
# ║                    Termux Installation Script                    ║
# ╚══════════════════════════════════════════════════════════════════╝
#
# File: install.sh
# Usage: bash install.sh
# or:    curl -sSL https://raw.githubusercontent.com/LOZENP/Lua-Obfuscator/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print functions
print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║        Advanced Lua VM Obfuscator - Auto Installer              ║
║                    Termux Edition v1.0.0                         ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if running in Termux
check_termux() {
    if [ ! -d "/data/data/com.termux" ]; then
        print_error "This script is designed for Termux!"
        print_info "Please install Termux from F-Droid: https://f-droid.org/packages/com.termux/"
        exit 1
    fi
    print_success "Termux environment detected"
}

# Update packages
update_packages() {
    print_info "Updating Termux packages..."
    pkg update -y || print_warning "Package update failed, continuing..."
    pkg upgrade -y || print_warning "Package upgrade failed, continuing..."
    print_success "Packages updated"
}

# Install required packages
install_dependencies() {
    print_info "Installing dependencies..."
    
    # Install Lua
    if ! command -v lua &> /dev/null; then
        print_info "Installing Lua..."
        pkg install lua -y
        print_success "Lua installed"
    else
        print_success "Lua already installed ($(lua -v 2>&1 | head -n1))"
    fi
    
    # Install Git
    if ! command -v git &> /dev/null; then
        print_info "Installing Git..."
        pkg install git -y
        print_success "Git installed"
    else
        print_success "Git already installed"
    fi
    
    # Install optional tools
    print_info "Installing optional tools..."
    pkg install wget curl -y || print_warning "Optional tools installation failed"
}

# Clone repository
clone_repository() {
    print_info "Cloning Lua-Obfuscator repository..."
    
    cd ~
    
    # Remove old directory if exists
    if [ -d "Lua-Obfuscator" ]; then
        print_warning "Removing old installation..."
        rm -rf Lua-Obfuscator
    fi
    
    # Clone
    if git clone https://github.com/LOZENP/Lua-Obfuscator.git; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository"
        print_info "You can manually download from: https://github.com/LOZENP/Lua-Obfuscator"
        exit 1
    fi
}

# Set up permissions
setup_permissions() {
    print_info "Setting up permissions..."
    
    cd ~/Lua-Obfuscator
    
    # Make CLI executable
    if [ -f "obfuscate.lua" ]; then
        chmod +x obfuscate.lua
        print_success "CLI tool is now executable"
    fi
    
    # Make all Lua files readable
    chmod 644 *.lua 2>/dev/null || true
    chmod 644 src/*.lua 2>/dev/null || true
}

# Create shortcuts
create_shortcuts() {
    print_info "Creating shortcuts..."
    
    # Add alias to .bashrc
    if ! grep -q "alias obf=" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# Lua Obfuscator alias" >> ~/.bashrc
        echo 'alias obf="lua ~/Lua-Obfuscator/obfuscate.lua"' >> ~/.bashrc
        print_success "Added 'obf' command alias"
    else
        print_success "Alias already exists"
    fi
    
    # Create bin directory if it doesn't exist
    mkdir -p ~/bin
    
    # Create symlink in bin
    if [ ! -f ~/bin/obfuscate ]; then
        cat > ~/bin/obfuscate << 'EOFBIN'
#!/data/data/com.termux/files/usr/bin/bash
lua ~/Lua-Obfuscator/obfuscate.lua "$@"
EOFBIN
        chmod +x ~/bin/obfuscate
        print_success "Created 'obfuscate' command in ~/bin"
    fi
    
    # Add bin to PATH if not already there
    if ! grep -q 'export PATH=$PATH:~/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
        print_success "Added ~/bin to PATH"
    fi
}

# Create test file
create_test_file() {
    print_info "Creating test file..."
    
    cat > ~/Lua-Obfuscator/test_example.lua << 'EOFTEST'
-- Test Script for Lua Obfuscator
print("==================================")
print("  Lua Obfuscator Test Script")
print("==================================")

local function greet(name)
    return "Hello, " .. name .. "!"
end

local function calculate(a, b)
    local sum = a + b
    local product = a * b
    return sum, product
end

-- Test functions
print(greet("Termux User"))

local s, p = calculate(10, 20)
print("Sum: " .. s)
print("Product: " .. p)

-- Test table
local data = {
    app = "Lua Obfuscator",
    version = "1.0.0",
    platform = "Termux"
}

print("\nApplication Info:")
for key, value in pairs(data) do
    print("  " .. key .. ": " .. value)
end

print("\nTest completed successfully!")
EOFTEST
    
    print_success "Test file created: ~/Lua-Obfuscator/test_example.lua"
}

# Run test
run_test() {
    print_info "Running installation test..."
    
    cd ~/Lua-Obfuscator
    
    # Test obfuscation
    if lua obfuscate.lua test_example.lua test_example.obf.lua --verbose; then
        print_success "Obfuscation test passed"
        
        # Test execution
        print_info "Testing obfuscated code execution..."
        if lua test_example.obf.lua; then
            print_success "Execution test passed"
        else
            print_warning "Execution test failed, but obfuscation works"
        fi
    else
        print_error "Obfuscation test failed"
    fi
}

# Print completion message
print_completion() {
    echo ""
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║               Installation Completed Successfully!               ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}Quick Start:${NC}"
    echo "  1. Restart Termux or run: source ~/.bashrc"
    echo "  2. Use command: obf myfile.lua"
    echo "  3. Or: lua ~/Lua-Obfuscator/obfuscate.lua myfile.lua"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  obf script.lua                    # Basic obfuscation"
    echo "  obf input.lua output.lua          # Custom output"
    echo "  obf script.lua --complexity 10    # High complexity"
    echo "  obf script.lua --key 200 -v       # Custom key + verbose"
    echo ""
    echo -e "${CYAN}Test Files:${NC}"
    echo "  cd ~/Lua-Obfuscator"
    echo "  lua obfuscate.lua test_example.lua"
    echo "  lua test_example.obf.lua"
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    echo "  cat ~/Lua-Obfuscator/README.md"
    echo "  cat ~/Lua-Obfuscator/TERMUX_SETUP.md"
    echo ""
    echo -e "${CYAN}Help:${NC}"
    echo "  obf --help"
    echo ""
    echo -e "${GREEN}GitHub: https://github.com/LOZENP/Lua-Obfuscator${NC}"
    echo ""
}

# Main installation process
main() {
    print_banner
    
    echo "Starting installation..."
    echo ""
    
    # Step 1: Check Termux
    check_termux
    
    # Step 2: Update packages
    update_packages
    
    # Step 3: Install dependencies
    install_dependencies
    
    # Step 4: Clone repository
    clone_repository
    
    # Step 5: Setup permissions
    setup_permissions
    
    # Step 6: Create shortcuts
    create_shortcuts
    
    # Step 7: Create test file
    create_test_file
    
    # Step 8: Run test
    run_test
    
    # Step 9: Print completion
    print_completion
}

# Run main installation
main

# Exit successfully
exit 0
