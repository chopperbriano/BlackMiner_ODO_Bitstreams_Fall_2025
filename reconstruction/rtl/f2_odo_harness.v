`timescale 1ns / 1ps

// Synthesis/fit harness only. This is intentionally not the final stock
// BlackMiner host protocol wrapper.
module f2_odo_harness(
    input  wire       osc_clk,
    input  wire       RI,
    inout  wire       RO,
    input  wire       CI,
    inout  wire       CO,
    input  wire       BI,
    inout  wire       BO,
    inout  wire       FX1_FPGA1_2_P,
    output wire [1:0] Xil_LED,
    input  wire [2:0] ADDR
);

    // Fixed synthesis stimulus. The purpose of this top is to force the
    // complete generated OdoCrypt + Keccak datapath through Vivado on the
    // XC7VX415T. Functional host work injection comes in the next phase.
    wire [607:0] test_header = 608'd0;
    wire [255:0] test_target = {256{1'b1}};

    (* keep = "true" *) wire [31:0] nonce;

    miner u_miner(
        .clk    (osc_clk),
        .header (test_header),
        .target (test_target),
        .nonce  (nonce)
    );

    // Do not drive transport/unknown board pins until their protocol and
    // direction are confirmed from hardware/firmware.
    assign RO = 1'bz;
    assign CO = 1'bz;
    assign BO = 1'bz;
    assign FX1_FPGA1_2_P = 1'bz;

    // Expose activity only on the known LED outputs.
    assign Xil_LED[0] = nonce[22] ^ ADDR[0];
    assign Xil_LED[1] = nonce[23] ^ ADDR[1] ^ ADDR[2];

endmodule
