`timescale 1ns / 1ps

module f2_smoke_top(
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

    reg [31:0] heartbeat = 32'd0;

    always @(posedge osc_clk)
        heartbeat <= heartbeat + 1'b1;

    // The public XDC identifies these pins but does not document their
    // electrical role. Leave them undriven until the F2 schematic/host
    // protocol has been positively mapped.
    assign RO = 1'bz;
    assign CO = 1'bz;
    assign BO = 1'bz;
    assign FX1_FPGA1_2_P = 1'bz;

    // LEDs are the only intentionally driven board outputs in the smoke top.
    assign Xil_LED[0] = heartbeat[24] ^ ADDR[0];
    assign Xil_LED[1] = heartbeat[25] ^ ADDR[1] ^ ADDR[2];

endmodule
