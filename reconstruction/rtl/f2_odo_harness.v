`timescale 1ns / 1ps

// Synthesis/fit harness only. This is intentionally not the final stock
// BlackMiner host protocol wrapper.
module f2_odo_harness(
    input  wire       osc_clk,
    input  wire       RI,
    output wire       RO,
    input  wire       CI,
    output wire       CO,
    input  wire       BI,
    output wire       BO,
    output wire       FX1_FPGA1_2_P,
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

    // Preserve known board-side digital paths while exposing core activity.
    assign RO = RI;
    assign CO = CI;
    assign BO = BI;
    assign Xil_LED[0] = nonce[22] ^ ADDR[0];
    assign Xil_LED[1] = nonce[23] ^ ADDR[1] ^ ADDR[2];
    assign FX1_FPGA1_2_P = nonce[0];

endmodule
