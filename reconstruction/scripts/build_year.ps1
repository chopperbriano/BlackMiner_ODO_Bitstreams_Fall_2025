param(
    [UInt64]$StartSeed = 0,
    [ValidateRange(1, 100)]
    [int]$Count = 37,
    [ValidateRange(1, 64)]
    [int]$Throughput = 4,
    [string]$Part = '',
    [double]$OscMHz = 0
)

$ErrorActionPreference = 'Stop'
$EpochLength = [UInt64]864000
$Build = Join-Path $PSScriptRoot 'build.ps1'

if ($StartSeed -eq 0) {
    $Now = [UInt64][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $StartSeed = $Now - ($Now % $EpochLength)
}

if (($StartSeed % $EpochLength) -ne 0) {
    throw "StartSeed $StartSeed is not aligned to a 10-day OdoCrypt epoch."
}

$Common = @{ Mode='epoch'; Throughput=$Throughput; OscMHz=$OscMHz }
if (-not [string]::IsNullOrWhiteSpace($Part)) { $Common.Part = $Part }

$Manifest = @()
for ($i = 0; $i -lt $Count; $i++) {
    $Seed = $StartSeed + ([UInt64]$i * $EpochLength)
    $StartUtc = [DateTimeOffset]::FromUnixTimeSeconds([Int64]$Seed)
    $EndUtc = [DateTimeOffset]::FromUnixTimeSeconds([Int64]($Seed + $EpochLength))
    Write-Host ("[{0}/{1}] Building epoch {2}: {3:u} -> {4:u}" -f ($i+1), $Count, $Seed, $StartUtc, $EndUtc)

    & $Build @Common -Seed $Seed
    if ($LASTEXITCODE -ne 0) { throw "Build failed for epoch $Seed" }

    $Manifest += [pscustomobject]@{
        Index = $i + 1
        Seed = $Seed
        StartUtc = $StartUtc.ToString('o')
        EndUtc = $EndUtc.ToString('o')
        Bitstream = ("build/epoch-{0}/f2_odo_harness_{0}.bit" -f $Seed)
    }
}

$Root = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $Root ("build/year_manifest_{0}_{1}.csv" -f $StartSeed, $Count)
$Manifest | Export-Csv -NoTypeInformation -Encoding ASCII -Path $ManifestPath

Write-Host "Completed $Count sequential 10-day epoch builds."
Write-Host "Manifest: $ManifestPath"
