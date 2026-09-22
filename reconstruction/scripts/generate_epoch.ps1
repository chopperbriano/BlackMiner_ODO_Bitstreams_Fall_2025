param(
    [UInt64]$Seed = 0,
    [ValidateRange(1, 64)]
    [int]$Throughput = 4
)

$ErrorActionPreference = 'Stop'
$EpochLength = [UInt64]864000
$Root = Split-Path -Parent $PSScriptRoot
$Generated = Join-Path $Root 'generated'
$Generator = Join-Path $Root 'tools-bin\odo_gen.exe'

if ($Seed -eq 0) {
    $Now = [UInt64][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $Seed = $Now - ($Now % $EpochLength)
}

if ($Seed -gt [UInt32]::MaxValue) { throw 'Seed exceeds the uint32 range used by the upstream OdoCrypt generator.' }
if (($Seed % $EpochLength) -ne 0) { throw "Seed $Seed is not aligned to a 10-day (864000 second) OdoCrypt epoch." }

if (-not (Test-Path $Generator)) {
    & (Join-Path $PSScriptRoot 'bootstrap_upstream.ps1')
}

New-Item -ItemType Directory -Force -Path $Generated | Out-Null
$OutFile = Join-Path $Generated ("odo_{0}.v" -f $Seed)

$Psi = New-Object System.Diagnostics.ProcessStartInfo
$Psi.FileName = $Generator
$Psi.Arguments = ("{0} {1} odo_" -f $Seed, $Throughput)
$Psi.UseShellExecute = $false
$Psi.RedirectStandardOutput = $true
$Psi.RedirectStandardError = $true
$Proc = [System.Diagnostics.Process]::Start($Psi)
$StdOut = $Proc.StandardOutput.ReadToEnd()
$StdErr = $Proc.StandardError.ReadToEnd()
$Proc.WaitForExit()
if ($Proc.ExitCode -ne 0) { throw "odo_gen failed: $StdErr" }

[System.IO.File]::WriteAllText($OutFile, $StdOut, [System.Text.Encoding]::ASCII)

$Meta = [ordered]@{
    seed = $Seed
    epochLengthSeconds = $EpochLength
    throughput = $Throughput
    generator = 'MentalCollatz/odo-miner'
    generatorCommit = 'fb1bd94892e3b1893bfc2439ebec877b25856b18'
    generatedUtc = [DateTimeOffset]::UtcNow.ToString('o')
}
$MetaPath = Join-Path $Generated ("odo_{0}.json" -f $Seed)
$Meta | ConvertTo-Json | Set-Content -Encoding ASCII -Path $MetaPath

Write-Host "Generated: $OutFile"
Write-Output $OutFile
