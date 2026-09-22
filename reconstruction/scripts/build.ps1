param(
    [ValidateSet('smoke','epoch')]
    [string]$Mode = 'smoke',
    [UInt64]$Seed = 0,
    [ValidateRange(1, 64)]
    [int]$Throughput = 4,
    [string]$Part = '',
    [double]$OscMHz = 0
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($Part)) { $Part = $env:F2_PART }
if ([string]::IsNullOrWhiteSpace($Part)) {
    $Part = 'xc7vx415tffg1157-2'
    Write-Warning 'F2 speed grade has not yet been verified from the physical FPGA marking. Using -2 as a build starting point only.'
}

$Vivado = $null
if ($env:VIVADO_HOME) {
    $Candidate = Join-Path $env:VIVADO_HOME 'bin\vivado.bat'
    if (Test-Path $Candidate) { $Vivado = $Candidate }
}
if (-not $Vivado) {
    $Cmd = Get-Command vivado.bat -ErrorAction SilentlyContinue
    if (-not $Cmd) { $Cmd = Get-Command vivado -ErrorAction SilentlyContinue }
    if ($Cmd) { $Vivado = $Cmd.Source }
}
if (-not $Vivado) { throw 'Vivado not found. Set VIVADO_HOME to the Vivado install directory, preferably C:\Xilinx\Vivado\2018.3.' }

if ($Mode -eq 'epoch') {
    if ($Seed -eq 0) {
        $Now = [UInt64][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $Seed = $Now - ($Now % [UInt64]864000)
    }
    & (Join-Path $PSScriptRoot 'generate_epoch.ps1') -Seed $Seed -Throughput $Throughput | Out-Host
}

$env:F2_PART = $Part
if ($OscMHz -gt 0) { $env:F2_OSC_MHZ = $OscMHz.ToString([Globalization.CultureInfo]::InvariantCulture) }
elseif ($env:F2_OSC_MHZ) { }
else { Remove-Item Env:F2_OSC_MHZ -ErrorAction SilentlyContinue }

if ($Mode -eq 'smoke') {
    $Tcl = Join-Path $Root 'vivado\build_smoke.tcl'
} else {
    $env:ODO_SEED = $Seed.ToString()
    $env:ODO_THROUGHPUT = $Throughput.ToString()
    $Tcl = Join-Path $Root 'vivado\build_epoch.tcl'
}

Write-Host "Vivado: $Vivado"
Write-Host "Part:   $Part"
if ($env:F2_OSC_MHZ) { Write-Host "Clock:  $env:F2_OSC_MHZ MHz" } else { Write-Warning 'No oscillator timing constraint supplied yet.' }

& $Vivado -mode batch -notrace -source $Tcl
if ($LASTEXITCODE -ne 0) { throw "Vivado build failed with exit code $LASTEXITCODE" }
