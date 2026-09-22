# BlackMiner F2 OdoCrypt reconstruction

This branch is an engineering reconstruction of the BlackMiner F2 OdoCrypt build path. It does **not** modify the known-good historical `.bit` files on `main`.

## What we know

- The reference OdoCrypt images target `7vx415tffg1157` (Virtex-7 XC7VX415T, FFG1157).
- Their readable Xilinx headers report `Vivado 2018.3`, `ENCRYPT=YES`, and `COMPRESS=TRUE`.
- The filenames advance by exactly `864000` seconds (10 days), matching the OdoCrypt mainnet epoch length.
- The sampled Aug 15, Aug 25, and Sep 4 2026 images were all generated on Oct 22 2025 in successive Vivado runs.
- The encrypted payload changes substantially between epochs, so this project treats each epoch as a fresh HDL implementation/build rather than a timestamp patch.
- BlackMiner published the F2/415T pin constraints. MentalCollatz published an OdoCrypt HDL generator and miner core. This branch joins those two pieces without modifying either upstream project.

## Layout

- `constraints/415t.xdc` - BlackMiner 415T pin constraints, copied from the public BlackMiner source release.
- `rtl/f2_smoke_top.v` - minimal board/pin smoke-test design.
- `rtl/f2_odo_harness.v` - synthesis harness that instantiates the generated OdoCrypt miner core on the F2 target.
- `scripts/bootstrap_upstream.ps1` - fetches the pinned OdoCrypt upstream source and builds its HDL generator.
- `scripts/generate_epoch.ps1` - generates epoch-specific `odo_encrypt` Verilog.
- `scripts/build.ps1` - Windows/PowerShell entry point for smoke or epoch builds.
- `vivado/build_smoke.tcl` - non-project-mode Vivado smoke build.
- `vivado/build_epoch.tcl` - non-project-mode Vivado OdoCrypt synthesis/implementation build.
- `notes/reference_bitstreams.md` - metadata/hashes for known-good reference images.

## Upstream pinning

`MentalCollatz/odo-miner` is pinned to commit:

`fb1bd94892e3b1893bfc2439ebec877b25856b18`

The BlackMiner constraints were taken from `black1225/blackminer` commit:

`15e3c9dd3bc86890bd36ede3c4a1ab1f522c5912`

Third-party HDL is fetched into `third_party/` and is intentionally not committed here. See `THIRD_PARTY.md`.

## Prerequisites

- Xilinx Vivado 2018.3 is preferred because that is the version recorded in the known-good bitstreams.
- Git.
- A C++ compiler (`g++`/MinGW is easiest; Visual Studio `cl.exe` is also supported by the bootstrap script).
- PowerShell 5.1 or later.

## 1. Build the smoke image first

From the `reconstruction` directory:

```powershell
$env:VIVADO_HOME = 'C:\Xilinx\Vivado\2018.3'
.\scripts\build.ps1 -Mode smoke
```

This produces `build/smoke/f2_smoke.bit`. The smoke top exercises the F2 pin constraints, oscillator path, counter, and LEDs. Transport/unknown board pins are deliberately tri-stated until their electrical role is positively mapped. It contains no mining logic.

### Part/speed grade

The historical `.bit` header identifies `XC7VX415T-FFG1157`, but does not expose the physical chip speed grade. The scripts currently default to the valid Vivado part `xc7vx415tffg1157-2` solely as a starting point. Override it when the actual marking is confirmed:

```powershell
$env:F2_PART = 'xc7vx415tffg1157-2'
```

Do not treat the default speed grade as verified hardware data.

## 2. Generate and synthesize an epoch core

Example using the known-good Sep 4 2026 epoch:

```powershell
.\scripts\build.ps1 -Mode epoch -Seed 1788480000 -Throughput 4
```

The script will:

1. Fetch the pinned `MentalCollatz/odo-miner` source.
2. Compile `odo_gen`.
3. Generate `generated/odo_1788480000.v` with the prefix `odo_`.
4. Read upstream `keccak800.v` and `miner.v` plus the generated OdoCrypt HDL.
5. Synthesize/place/route the design for the XC7VX415T FFG1157.
6. Write `build/epoch-1788480000/f2_odo_harness_1788480000.bit` and utilization/timing reports.

`Throughput=4` is deliberately conservative for the first fit attempt. The original F2 implementation's exact unrolling/throughput has not yet been recovered.

## Clock constraint

The public `415t.xdc` contains pin/IO constraints but no oscillator frequency. If the F2 oscillator frequency is confirmed, pass it to the build:

```powershell
.\scripts\build.ps1 -Mode smoke -OscMHz 50
```

or set `F2_OSC_MHZ`. Until then the build intentionally avoids inventing a timing requirement.

## Current limitation: host protocol

The epoch harness proves that a generated OdoCrypt core can be synthesized for the F2 silicon and constraints. It is **not yet a drop-in replacement for BlackMiner firmware** because the original host-to-FPGA work/nonce transport HDL is not public.

The next phase is to reproduce the F2 host protocol around the validated OdoCrypt core. The public BlackMiner cgminer source, F2 schematic, working miner software, and a running card can be used to recover that interface. Until that wrapper is complete, do not expect `f2_odo_harness_*.bit` to mine under the stock BlackMiner controller.

## Success criteria

1. Smoke build completes in Vivado 2018.3.
2. Epoch harness synthesizes and routes for XC7VX415T.
3. Generated HDL produces hashes/nonces matching the software OdoCrypt implementation for the same seed.
4. F2 transport wrapper accepts real work and returns valid nonces.
5. Only after those checks: optimize throughput and produce future 10-day images.
