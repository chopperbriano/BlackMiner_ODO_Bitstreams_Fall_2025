# Reconstruction Plan

## Phase 0 - Evidence
Known-good files show a common Xilinx/Vivado container but substantially different encrypted/compressed configuration payloads. Treat each 10-day epoch as a fresh implementation build, not a timestamp patch.

## Phase 1 - Board skeleton
- Target part: xc7vx415tffg1157
- Top module: fpgaminer_top
- Acquire/adapt upstream 415t.xdc.
- Map clocks, reset, host communications and status signals from the F2 schematic/upstream cgminer interface.
- Produce a minimal Vivado project that elaborates and synthesizes.

## Phase 2 - Algorithm correctness
- Preserve the public OdoCrypt algorithm semantics.
- Separate epoch-derived generated constants from static datapath RTL.
- Add deterministic test vectors generated from a software reference.
- Simulate one complete hash path before hardware testing.

## Phase 3 - F2 integration
- Connect work input, nonce search, result output and control/status to the F2 host interface.
- Start with one slow core.
- Verify accepted shares before optimization.

## Phase 4 - Performance
- Measure LUT, FF, BRAM and routing pressure.
- Explore S-box implementation choices and replication.
- Pipeline/unroll only after functional equivalence is proven.
- Add timing constraints and implementation strategies for Virtex-7.

## Phase 5 - Epoch automation
Input: Unix epoch boundary.
Output: generated RTL/constants + Vivado bitstream + manifest.
The generator must enforce 864000-second OdoCrypt epoch alignment and record source/tool versions.

## Success criteria
A newly generated epoch bitstream boots on an F2, communicates with the host miner, computes OdoCrypt correctly, and produces pool/node-accepted work.
