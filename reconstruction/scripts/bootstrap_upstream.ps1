param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$ThirdParty = Join-Path $Root 'third_party'
$RepoDir = Join-Path $ThirdParty 'odo-miner'
$ToolsBin = Join-Path $Root 'tools-bin'
$Commit = 'fb1bd94892e3b1893bfc2439ebec877b25856b18'
$RepoUrl = 'https://github.com/MentalCollatz/odo-miner.git'

New-Item -ItemType Directory -Force -Path $ThirdParty | Out-Null
New-Item -ItemType Directory -Force -Path $ToolsBin | Out-Null

if ($Force -and (Test-Path $RepoDir)) {
    Remove-Item -Recurse -Force $RepoDir
}

if (-not (Test-Path (Join-Path $RepoDir '.git'))) {
    Write-Host "Cloning pinned OdoCrypt source..."
    & git clone $RepoUrl $RepoDir
    if ($LASTEXITCODE -ne 0) { throw 'git clone failed' }
}

& git -C $RepoDir fetch origin
if ($LASTEXITCODE -ne 0) { throw 'git fetch failed' }
& git -C $RepoDir checkout --detach $Commit
if ($LASTEXITCODE -ne 0) { throw 'git checkout failed' }

$OdoGen = Join-Path $RepoDir 'src\verilog\odo_gen.cpp'
$OdoCpp = Join-Path $RepoDir 'src\crypto\odocrypt.cpp'
$Exe = Join-Path $ToolsBin 'odo_gen.exe'

$Gpp = Get-Command g++.exe -ErrorAction SilentlyContinue
if (-not $Gpp) { $Gpp = Get-Command g++ -ErrorAction SilentlyContinue }

if ($Gpp) {
    Write-Host "Building odo_gen with g++..."
    & $Gpp.Source -std=c++11 -O2 $OdoGen $OdoCpp -o $Exe
    if ($LASTEXITCODE -ne 0) { throw 'g++ failed to build odo_gen' }
} else {
    $Cl = Get-Command cl.exe -ErrorAction SilentlyContinue
    if (-not $Cl) {
        throw 'No C++ compiler found. Install MinGW/MSYS2 g++ or run from a Visual Studio developer shell with cl.exe available.'
    }
    Write-Host "Building odo_gen with cl.exe..."
    & $Cl.Source /nologo /EHsc /O2 $OdoGen $OdoCpp ("/Fe:" + $Exe)
    if ($LASTEXITCODE -ne 0) { throw 'cl.exe failed to build odo_gen' }
}

Write-Host "Pinned upstream ready: $Commit"
Write-Host "Generator: $Exe"
