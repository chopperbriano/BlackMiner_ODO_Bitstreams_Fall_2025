param()

$ErrorActionPreference = 'Continue'
$Failures = 0

function Test-CommandVersion {
    param(
        [string]$Name,
        [string[]]$Arguments
    )
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Host "[FAIL] $Name not found" -ForegroundColor Red
        $script:Failures++
        return
    }
    Write-Host "[PASS] $Name -> $($cmd.Source)" -ForegroundColor Green
    try {
        & $cmd.Source @Arguments | Select-Object -First 3 | ForEach-Object { Write-Host "       $_" }
    } catch {
        Write-Warning $_
    }
}

Write-Host "=== F2 ODOCRYPT BUILD ENVIRONMENT ===" -ForegroundColor Cyan

Test-CommandVersion -Name 'git.exe' -Arguments @('--version')
if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
    Test-CommandVersion -Name 'git' -Arguments @('--version')
}

Test-CommandVersion -Name 'g++.exe' -Arguments @('--version')
if (-not (Get-Command g++.exe -ErrorAction SilentlyContinue)) {
    Test-CommandVersion -Name 'g++' -Arguments @('--version')
}

$Vivado = $null
if ($env:VIVADO_HOME) {
    $Candidate = Join-Path $env:VIVADO_HOME 'bin\vivado.bat'
    if (Test-Path $Candidate) { $Vivado = $Candidate }
}

if (-not $Vivado) {
    $Candidate = 'C:\Xilinx\Vivado\2018.3\bin\vivado.bat'
    if (Test-Path $Candidate) { $Vivado = $Candidate }
}

if ($Vivado) {
    Write-Host "[PASS] Vivado -> $Vivado" -ForegroundColor Green
    & $Vivado -version | Select-Object -First 6 | ForEach-Object { Write-Host "       $_" }
} else {
    Write-Host "[FAIL] Vivado 2018.3 not found" -ForegroundColor Red
    $Failures++
}

Write-Host ""
Write-Host "VIVADO_HOME = $env:VIVADO_HOME"
Write-Host "PATH contains MSYS2 UCRT64: $([bool](($env:Path -split ';') -match 'msys64\\ucrt64\\bin'))"

Write-Host ""
if ($Failures -eq 0) {
    Write-Host "Environment verification PASSED." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Environment verification FAILED: $Failures required component(s) missing." -ForegroundColor Red
    exit 1
}
