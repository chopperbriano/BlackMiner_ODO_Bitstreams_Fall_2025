# Windows build VM setup

This VM is intended to reproduce the BlackMiner F2 OdoCrypt build environment as closely as practical.

## Recommended VM

- Hyper-V Generation 2
- Windows 10 x64
- 8 vCPU minimum; 12 vCPU preferred
- 32 GB fixed RAM minimum; 64 GB preferred
- 250 GB dynamically expanding VHDX minimum
- Standard virtual NIC during setup; disconnect or isolate after tools are installed if desired
- No GPU passthrough required

Vivado 2018.3 officially supported Windows 10 1803/1809 x64. A later Windows 10 build may work, but 1809 is the closest documented target. Use a legitimate ISO/license source available to your organization.

## Install order

### 1. Windows

Install Windows 10 x64. Create a local administrator account such as:

`fpga-build`

After Windows setup:

- Apply only the updates you intend to keep on this disposable VM.
- Set the computer name, e.g. `F2-VIVADO2018`.
- Create a short working directory: `C:\fpga`.

### 2. 7-Zip

Install 7-Zip. This is useful for the archived Vivado installer.

### 3. Git for Windows

Install Git for Windows with the normal defaults, including Git Credential Manager.

Verify in PowerShell:

```powershell
git --version
```

### 4. MSYS2 + GCC

Install current x64 MSYS2 to the default path:

`C:\msys64`

Open **MSYS2 UCRT64** and run:

```bash
pacman -Syu
pacman -S --needed mingw-w64-ucrt-x86_64-gcc
```

Add this to the Windows system PATH:

`C:\msys64\ucrt64\bin`

Open a new PowerShell window and verify:

```powershell
g++ --version
```

### 5. Vivado 2018.3

Install the archived **Vivado HLx 2018.3** full design tools, not Lab Edition and not WebPACK-only.

Install path:

`C:\Xilinx\Vivado\2018.3`

Required device/tool selection:

- Vivado HL Design Edition (or System Edition if that is what your license provides)
- 7 Series device support
- Virtex-7 device support

Not required for this project:

- Vitis
- SDK
- HLS
- Zynq device support
- UltraScale/UltraScale+ device families
- ModelSim
- Cable drivers/hardware server if this VM will only compile bitstreams

After installation, open a new PowerShell window and verify:

```powershell
C:\Xilinx\Vivado\2018.3\bin\vivado.bat -version
```

A valid Design/System Edition license that covers Virtex-7 may be required to synthesize/implement the XC7VX415T. Installation can be completed before licensing is resolved.

### 6. Clone the reconstruction branch

```powershell
cd C:\fpga

git clone -b reconstruct-f2-odocrypt https://github.com/chopperbriano/BlackMiner_ODO_Bitstreams_Fall_2025.git

cd C:\fpga\BlackMiner_ODO_Bitstreams_Fall_2025\reconstruction
```

Git Credential Manager may open a browser to authenticate to the private repository.

### 7. Set Vivado path

For the current PowerShell session:

```powershell
$env:VIVADO_HOME = 'C:\Xilinx\Vivado\2018.3'
```

Optional persistent machine variable, from elevated PowerShell:

```powershell
[Environment]::SetEnvironmentVariable('VIVADO_HOME','C:\Xilinx\Vivado\2018.3','Machine')
```

Open a new PowerShell window after setting a machine-level variable.

### 8. Verify the VM

Run:

```powershell
.\scripts\verify_environment.ps1
```

Do not proceed until Git, g++, and Vivado all pass.

### 9. Fetch/build the epoch generator

```powershell
.\scripts\bootstrap_upstream.ps1
```

Expected result:

`reconstruction\tools-bin\odo_gen.exe`

### 10. Generate HDL only

Before invoking Vivado, prove the OdoCrypt generator works:

```powershell
.\scripts\generate_epoch.ps1 -Seed 1788480000 -Throughput 4
```

Expected result:

`reconstruction\generated\odo_1788480000.v`

### 11. First Vivado smoke build

```powershell
.\scripts\build.ps1 -Mode smoke
```

Expected output:

`reconstruction\build\smoke\f2_smoke.bit`

This image is only a compile/constraint smoke test. Do not flash it to hardware yet.

### 12. First known-epoch synthesis

```powershell
.\scripts\build.ps1 -Mode epoch -Seed 1788480000 -Throughput 4
```

This uses a seed for which a known-good original BlackMiner bitstream is available for comparison.

## Full-year build

Do not run this until a single reconstructed epoch has been functionally validated on an F2.

Once validated:

```powershell
.\scripts\build_year.ps1 -Count 37 -Throughput 4
```

37 ten-day images cover 370 days.

## Important unresolved items

- Exact XC7VX415T speed grade is not yet confirmed. The scripts currently default to `xc7vx415tffg1157-2` only as a starting assumption.
- The public BlackMiner release does not include the original host/FPGA OdoCrypt transport HDL.
- The synthesis harness is not yet a drop-in stock-controller mining bitstream.
