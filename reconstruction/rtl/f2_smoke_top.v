`timescale 1ns / 1ps

module f2_smoke_top(
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

    reg [31:0] heartbeat = 32'd0;

    always @(posedge osc_clk)
        heartbeat <= heartbeat + 1'b1;

    // Non-destructive digital loopbacks for first board bring-up.
    assign RO = RI;
    assign CO = CI;
    assign BO = BI;

    // Slow activity indicators. ADDR is folded in so the strap pins are
    // retained by synthesis without assigning them any control function.
    assign Xil_LED[0] = heartbeat[24] ^ ADDR[0];
    assign Xil_LED[1] = heartbeat[25] ^ ADDR[1] ^ ADDR[2];
    assign FX1_FPGA1_2_P = heartbeat[23];

endmodule
