# BlackMiner F2 OdoCrypt Rebuild

Goal: reconstruct a reproducible OdoCrypt bitstream build for the BlackMiner F2 (Xilinx Virtex-7 XC7VX415T FFG1157).

## Known reference
- Top-level design name observed in known-good bitstreams: fpgaminer_top
- Target FPGA: xc7vx415tffg1157
- Original toolchain metadata: Vivado 2018.3
- Reference bitstreams are encrypted and compressed.
- Epoch filenames advance in 864000-second (10-day) intervals.

## Strategy
1. Preserve known-good reference bitstreams on main; do development on this branch.
2. Import/adapt the public BlackMiner 415T constraints and F2 board information.
3. Port the open OdoCrypt HDL/generation flow to a Xilinx/Vivado-compatible core.
4. Build a minimal F2 top-level and establish the board/host interface.
5. Add one correctness-first OdoCrypt core.
6. Validate against software reference vectors for a known epoch.
7. Only after correctness: pipeline/parallelize and optimize timing/resource use.
8. Generate future epoch bitstreams automatically.

## External upstreams
- https://github.com/black1225/blackminer
- https://github.com/MentalCollatz/odo-miner

Do not overwrite or modify the archived known-good .bit files.
