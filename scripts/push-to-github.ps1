#!/usr/bin/env pwsh
# ============================================================
# push-to-github.ps1
# Script giup push code len GitHub de trigger build iOS IPA
# Chay: .\push-to-github.ps1 -RepoURL "https://github.com/USER/REPO.git"
# ============================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$RepoURL = "",
    [string]$Message = "Update ShinobiCraft"
)

$ErrorActionPreference = "Stop"
$GREEN = "`e[32m"; $YELLOW = "`e[33m"; $RED = "`e[31m"; $NC = "`e[0m"

Write-Host "${GREEN}Phan bo ShinobiCraft len GitHub...${NC}"

# Kiem tra git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "${RED}Chua cai Git! Tai tai https://git-scm.com${NC}"
    exit 1
}

# Huong dan neu chua co repo URL
if (-not $RepoURL) {
    Write-Host ""
    Write-Host "${YELLOW}=== HUONG DAN TAO GITHUB REPO ===${NC}"
    Write-Host "1. Vao https://github.com/new"
    Write-Host "2. Ten repo: ShinobiCraft"
    Write-Host "3. Chon Public (de co nhieu build minutes)"
    Write-Host "4. Bam 'Create repository'"
    Write-Host "5. Copy URL dang: https://github.com/TEN_BAN/ShinobiCraft.git"
    Write-Host ""
    $RepoURL = Read-Host "Dan URL repo vao day"
}

Set-Location "d:\MINECRAFT_TOOL\luanti-ios"

# Kiem tra da co remote chua
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "${YELLOW}Da co remote: $existingRemote${NC}"
    $change = Read-Host "Doi thanh $RepoURL? (y/n)"
    if ($change -eq "y") {
        git remote set-url origin $RepoURL
    }
} else {
    git remote add origin $RepoURL
}

# Copy mods vao luanti-ios de push cung
Write-Host "${YELLOW}Copy Naruto mod...${NC}"
if (-not (Test-Path "..\luanti-ios\mods")) {
    New-Item -ItemType SymbolicLink -Path "mods" -Target "..\mods" -ErrorAction SilentlyContinue
    # Fallback: copy
    if (-not (Test-Path "mods")) {
        Copy-Item -Recurse "..\mods" ".\mods" -Force
    }
}

# Git add + commit + push
Write-Host "${YELLOW}Push code len GitHub...${NC}"
git add -A
git status --short

$commitMsg = "$Message - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git commit -m $commitMsg 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "${YELLOW}Khong co gi thay doi, push lai...${NC}"
    git commit --allow-empty -m $commitMsg
}

git push -u origin main
if ($LASTEXITCODE -ne 0) {
    git push -u origin master
}

Write-Host ""
Write-Host "${GREEN}=== PUSH THANH CONG! ===${NC}"
Write-Host "${GREEN}Vao GitHub -> Tab Actions de theo doi qua trinh build${NC}"
Write-Host "${GREEN}Build mat khoang 20-40 phut tren May Mac ao mien phi${NC}"
Write-Host ""
Write-Host "URL Actions: $($RepoURL -replace '\.git$', '')/actions"

# Mo trinh duyet
$openBrowser = Read-Host "Mo tab Actions tren trinh duyet? (y/n)"
if ($openBrowser -eq "y") {
    $actionsURL = $RepoURL -replace '\.git$', '/actions'
    Start-Process $actionsURL
}
