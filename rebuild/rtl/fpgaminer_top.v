// BlackMiner F2 OdoCrypt reconstruction skeleton.
// Target: Xilinx Virtex-7 XC7VX415T-FFG1157.
//
// Ports are intentionally NOT guessed. Populate these only after the
// upstream 415t.xdc and F2 schematic/host interface have been mapped.
module fpgaminer_top (
    input wire clk_stub,
    input wire reset_stub,
    output wire alive_stub
);

    reg [31:0] heartbeat = 32'd0;

    always @(posedge clk_stub) begin
        if (reset_stub)
            heartbeat <= 32'd0;
        else
            heartbeat <= heartbeat + 1'b1;
    end

    assign alive_stub = heartbeat[31];

endmodule
