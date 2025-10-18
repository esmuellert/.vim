# Neovim Plugin Dependencies Installer for Windows
# This script installs all required dependencies for nvim-treesitter, telescope,
# mason, and other plugins used in this Neovim configuration.
#
# Usage: .\install-deps-windows.ps1
# Run as Administrator for best results
#
# IMPORTANT: After installation, you may need to restart your terminal or
# run Neovim from a Developer PowerShell/Command Prompt to use MSVC compiler.

#Requires -Version 5.1

$ErrorActionPreference = "Continue"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Neovim Plugin Dependencies Installer" -ForegroundColor Cyan
Write-Host "Platform: Windows (winget)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠ Not running as Administrator. Some installations might fail." -ForegroundColor Yellow
    Write-Host "  Consider running PowerShell as Administrator for best results." -ForegroundColor Yellow
    Write-Host ""
}

# Function to check if a command exists
function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# Function to install using winget
function Install-IfMissing {
    param(
        [string]$PackageName,
        [string]$WingetId,
        [string]$CheckCommand
    )
    
    if (Test-Command $CheckCommand) {
        Write-Host "✓ $PackageName is already installed" -ForegroundColor Green
    } else {
        Write-Host "→ Installing $PackageName..." -ForegroundColor Yellow
        try {
            winget install --id $WingetId --silent --accept-source-agreements --accept-package-agreements
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            if (Test-Command $CheckCommand) {
                Write-Host "✓ $PackageName installed successfully" -ForegroundColor Green
            } else {
                Write-Host "! $PackageName installed but not found in PATH. You may need to restart your terminal." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "✗ Failed to install $PackageName" -ForegroundColor Red
            Write-Host "  Error: $_" -ForegroundColor Red
        }
    }
}

# Check if winget is available
if (-not (Test-Command "winget")) {
    Write-Host "✗ winget is not installed!" -ForegroundColor Red
    Write-Host "  Please install winget from: https://aka.ms/getwinget" -ForegroundColor Yellow
    Write-Host "  Or install from Microsoft Store: App Installer" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== C Compiler (REQUIRED for nvim-treesitter) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "nvim-treesitter requires a C compiler. Choose ONE option:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: LLVM/Clang (Recommended - easiest setup)" -ForegroundColor White
Write-Host "Option 2: Visual Studio Build Tools (MSVC - more complex)" -ForegroundColor White
Write-Host "Option 3: MinGW-w64 (GCC for Windows)" -ForegroundColor White
Write-Host ""

# Check if any compiler is available
$hasCompiler = $false
if (Test-Command "clang") {
    Write-Host "✓ LLVM/Clang is already installed" -ForegroundColor Green
    $hasCompiler = $true
} elseif (Test-Command "cl") {
    Write-Host "✓ MSVC (cl.exe) is already installed" -ForegroundColor Green
    $hasCompiler = $true
} elseif (Test-Command "gcc") {
    Write-Host "✓ GCC (MinGW) is already installed" -ForegroundColor Green
    $hasCompiler = $true
}

if (-not $hasCompiler) {
    Write-Host "No C compiler detected. Installing LLVM/Clang (recommended)..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To use a different compiler:" -ForegroundColor Gray
    Write-Host "  - MSVC: Install Visual Studio Build Tools manually" -ForegroundColor Gray
    Write-Host "  - MinGW: Run 'winget install GnuWin32.MinGW'" -ForegroundColor Gray
    Write-Host ""
    
    # Install LLVM
    Install-IfMissing -PackageName "LLVM/Clang" -WingetId "LLVM.LLVM" -CheckCommand "clang"
    
    # Add LLVM to PATH if not there
    $llvmPath = "C:\Program Files\LLVM\bin"
    if (Test-Path $llvmPath) {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$llvmPath*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$llvmPath", "User")
            $env:Path += ";$llvmPath"
            Write-Host "✓ Added LLVM to PATH" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "=== Build Tools ===" -ForegroundColor Cyan
Write-Host ""

# CMake (required for telescope-fzf-native)
Install-IfMissing -PackageName "CMake" -WingetId "Kitware.CMake" -CheckCommand "cmake"

# Note: Make is not strictly required on Windows if using CMake
# But install it as backup
if (-not (Test-Command "make")) {
    Write-Host "! GNU Make not found (optional for Windows)" -ForegroundColor Yellow
    Write-Host "  CMake can build without make on Windows" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Version Control ===" -ForegroundColor Cyan
Write-Host ""

# Git (required by mason and nvim-treesitter)
Install-IfMissing -PackageName "Git" -WingetId "Git.Git" -CheckCommand "git"

Write-Host ""
Write-Host "=== Download Tools ===" -ForegroundColor Cyan
Write-Host ""

# curl comes with Windows 10+ (invoke-webrequest also works)
if (Test-Command "curl") {
    Write-Host "✓ curl is already available (built-in to Windows 10+)" -ForegroundColor Green
} else {
    Write-Host "! curl not found. This should be available on Windows 10+" -ForegroundColor Yellow
}

# wget (optional, mason can use Invoke-WebRequest)
if (-not (Test-Command "wget")) {
    Write-Host "! wget not installed (optional - mason can use Invoke-WebRequest)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Archive Tools ===" -ForegroundColor Cyan
Write-Host ""

# tar - comes with Windows 10+ (bsdtar)
if (Test-Command "tar") {
    Write-Host "✓ GNU tar is available (built-in to Windows 10+)" -ForegroundColor Green
} else {
    Write-Host "✗ tar not found. Installing GNU tar..." -ForegroundColor Red
    # If tar is missing, install it
    try {
        winget install --id GnuWin32.Tar --silent --accept-source-agreements --accept-package-agreements
        Write-Host "✓ GNU tar installed" -ForegroundColor Green
    } catch {
        Write-Host "! Failed to install tar. Mason requires tar for extracting packages." -ForegroundColor Yellow
    }
}

# 7-Zip or similar archiver (required by mason for some packages)
$has7zip = Test-Path "C:\Program Files\7-Zip\7z.exe"
if ($has7zip) {
    Write-Host "✓ 7-Zip is already installed" -ForegroundColor Green
    # Add to PATH if not there
    $7zipPath = "C:\Program Files\7-Zip"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$7zipPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$7zipPath", "User")
        $env:Path += ";$7zipPath"
    }
} else {
    Install-IfMissing -PackageName "7-Zip" -WingetId "7zip.7zip" -CheckCommand "7z"
}

Write-Host ""
Write-Host "=== Search Tools (for Telescope) ===" -ForegroundColor Cyan
Write-Host ""

# Ripgrep - REQUIRED for telescope live_grep and grep_string
Install-IfMissing -PackageName "ripgrep" -WingetId "BurntSushi.ripgrep.MSVC" -CheckCommand "rg"

# fd - optional but recommended for better find_files performance
Install-IfMissing -PackageName "fd" -WingetId "sharkdp.fd" -CheckCommand "fd"

Write-Host ""
Write-Host "=== Language Runtimes (for LSP servers via Mason) ===" -ForegroundColor Cyan
Write-Host ""

# Node.js and npm (required for many LSP servers)
Install-IfMissing -PackageName "Node.js" -WingetId "OpenJS.NodeJS.LTS" -CheckCommand "node"

# Python (required for Python-based tools and some LSP servers)
Install-IfMissing -PackageName "Python" -WingetId "Python.Python.3.12" -CheckCommand "python"

# Ensure pip is available
if (Test-Command "pip") {
    Write-Host "✓ pip is already installed" -ForegroundColor Green
} else {
    Write-Host "→ Installing pip..." -ForegroundColor Yellow
    try {
        python -m ensurepip --upgrade
        Write-Host "✓ pip installed" -ForegroundColor Green
    } catch {
        Write-Host "! Failed to install pip" -ForegroundColor Yellow
    }
}

# Cargo/Rust (optional but useful for some LSP servers and rust-analyzer)
Install-IfMissing -PackageName "Rust" -WingetId "Rustlang.Rust.MSVC" -CheckCommand "cargo"

Write-Host ""
Write-Host "=== PowerShell (for Mason) ===" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version (mason requires pwsh or powershell)
if ($PSVersionTable.PSVersion.Major -ge 5) {
    Write-Host "✓ PowerShell $($PSVersionTable.PSVersion) is available" -ForegroundColor Green
} else {
    Write-Host "! PowerShell version is below 5.0. Consider upgrading." -ForegroundColor Yellow
}

# PowerShell Core (pwsh) is optional but recommended
if (Test-Command "pwsh") {
    Write-Host "✓ PowerShell Core (pwsh) is installed" -ForegroundColor Green
} else {
    Write-Host "! PowerShell Core (pwsh) not found (optional)" -ForegroundColor Yellow
    Write-Host "  Install with: winget install Microsoft.PowerShell" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Additional Development Tools ===" -ForegroundColor Cyan
Write-Host ""

# Tree-sitter CLI (optional but useful for parser development)
if (Test-Command "tree-sitter") {
    Write-Host "✓ tree-sitter CLI is already installed" -ForegroundColor Green
} else {
    Write-Host "→ Installing tree-sitter CLI via npm..." -ForegroundColor Yellow
    try {
        npm install -g tree-sitter-cli
        if (Test-Command "tree-sitter") {
            Write-Host "✓ tree-sitter CLI installed" -ForegroundColor Green
        } else {
            Write-Host "! tree-sitter CLI installed but not in PATH. Restart terminal." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "! Failed to install tree-sitter CLI" -ForegroundColor Yellow
    }
}

# Lazygit (optional but very useful for git workflows)
Install-IfMissing -PackageName "lazygit" -WingetId "JesseDuffield.lazygit" -CheckCommand "lazygit"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Installation Complete! ✨" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed Dependencies:" -ForegroundColor White
Write-Host "  • C Compiler: LLVM/Clang (or MSVC/MinGW if you chose that)" -ForegroundColor Gray
Write-Host "  • Build tools: CMake" -ForegroundColor Gray
Write-Host "  • VCS: Git" -ForegroundColor Gray
Write-Host "  • Search: ripgrep (rg), fd" -ForegroundColor Gray
Write-Host "  • Languages: Node.js, Python, Rust" -ForegroundColor Gray
Write-Host "  • Archive: tar (Windows built-in), 7-Zip" -ForegroundColor Gray
Write-Host "  • PowerShell: Windows PowerShell 5.1+" -ForegroundColor Gray
Write-Host "  • Optional: tree-sitter CLI, lazygit" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANT Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. RESTART YOUR TERMINAL" -ForegroundColor White
Write-Host "   - Required to refresh PATH environment variables" -ForegroundColor Gray
Write-Host ""
Write-Host "2. For nvim-treesitter to work:" -ForegroundColor White
if (Test-Command "clang") {
    Write-Host "   ✓ LLVM/Clang detected - should work immediately" -ForegroundColor Green
} elseif (Test-Command "cl") {
    Write-Host "   ⚠ MSVC detected - launch Neovim from:" -ForegroundColor Yellow
    Write-Host "     • Developer PowerShell for VS 2022, OR" -ForegroundColor Gray
    Write-Host "     • Developer Command Prompt for VS 2022" -ForegroundColor Gray
    Write-Host "   Alternatively, set environment variables as per:" -ForegroundColor Gray
    Write-Host "   https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support" -ForegroundColor Gray
} else {
    Write-Host "   ⚠ No C compiler detected!" -ForegroundColor Red
    Write-Host "   Install one of:" -ForegroundColor Gray
    Write-Host "   • LLVM: winget install LLVM.LLVM" -ForegroundColor Gray
    Write-Host "   • Visual Studio Build Tools (install manually)" -ForegroundColor Gray
    Write-Host "   • MinGW: winget install GnuWin32.MinGW" -ForegroundColor Gray
}
Write-Host ""
Write-Host "3. Configure nvim-treesitter (if using MSVC):" -ForegroundColor White
Write-Host "   Add to your init.lua:" -ForegroundColor Gray
Write-Host "   require('nvim-treesitter.install').compilers = { 'clang', 'gcc', 'cl' }" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Verify installation:" -ForegroundColor White
Write-Host "   • Open Neovim and run: :checkhealth" -ForegroundColor Gray
Write-Host "   • Check telescope: :checkhealth telescope" -ForegroundColor Gray
Write-Host "   • Check treesitter: :checkhealth nvim-treesitter" -ForegroundColor Gray
Write-Host "   • Check mason: :checkhealth mason" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Install LSP servers:" -ForegroundColor White
Write-Host "   • Run :Mason in Neovim" -ForegroundColor Gray
Write-Host "   • Or install specific servers: :MasonInstall <server-name>" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Test telescope-fzf-native compilation:" -ForegroundColor White
Write-Host "   • Run :Lazy build telescope-fzf-native.nvim" -ForegroundColor Gray
Write-Host "   • This will test if CMake and compiler are working" -ForegroundColor Gray
Write-Host ""
Write-Host "Troubleshooting:" -ForegroundColor Yellow
Write-Host "  • Compiler not found: Ensure it's in PATH or use Developer Shell" -ForegroundColor Gray
Write-Host "  • :TSInstall fails: Check :checkhealth nvim-treesitter for errors" -ForegroundColor Gray
Write-Host "  • Mason fails: Ensure PowerShell, git, tar, and archiver are installed" -ForegroundColor Gray
Write-Host ""
Write-Host "For more help, see:" -ForegroundColor Yellow
Write-Host "  • nvim-treesitter Windows: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support" -ForegroundColor Gray
Write-Host "  • Mason requirements: :help mason-requirements" -ForegroundColor Gray
Write-Host ""
