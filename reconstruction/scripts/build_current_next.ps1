param(
    [ValidateRange(1, 64)]
    [int]$Throughput = 4,
    [string]$Part = '',
    [double]$OscMHz = 0
)

$ErrorActionPreference = 'Stop'
$EpochLength = [UInt64]864000
$Now = [UInt64][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$Current = $Now - ($Now % $EpochLength)
$Next = $Current + $EpochLength
$Build = Join-Path $PSScriptRoot 'build.ps1'

Write-Host ("Current epoch: {0} ({1:u})" -f $Current, [DateTimeOffset]::FromUnixTimeSeconds([Int64]$Current))
Write-Host ("Next epoch:    {0} ({1:u})" -f $Next, [DateTimeOffset]::FromUnixTimeSeconds([Int64]$Next))

$Common = @{ Mode='epoch'; Throughput=$Throughput; OscMHz=$OscMHz }
if (-not [string]::IsNullOrWhiteSpace($Part)) { $Common.Part = $Part }

& $Build @Common -Seed $Current
& $Build @Common -Seed $Next

Write-Host 'Current and next epoch builds completed.'
