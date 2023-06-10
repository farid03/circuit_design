`timescale 1ns / 1ps

module sim;
    reg clk_reg, start, in_rst;
    reg [7:0] in_a;
    reg [7:0] in_b;
    wire [15:0] out;
    wire out_busy;
    reg[8:0] i;
    reg[8:0] j;

ab ab_inst(
    .clk_i(clk_reg),
    .rst_i(in_rst),
    .a_i(in_a),
    .b_i(in_b),
    .start_i(start),
    .y_bo(out),
    .busy_o(out_busy)
 );

initial begin
    clk_reg = 1;
    forever
        begin
            #1
            clk_reg = ~clk_reg;
        end
end

initial begin
    in_rst = 'd1;
    #1
    in_rst = 'd0;
    start = 'd0;
    #1

    for (i = 0; i <= 255; i = i + 1) begin // all test
        for (j = 0; j <= 255; j = j + 1) begin
            if (~out_busy && ~start) begin
                in_a = i;
                in_b = j;
                start = 1;
                # 5
                start = 0;
                # 500
                start = 0;
            end
        end
    end
end

always @(negedge out_busy)
    begin
        # 2
        $display("a = 0x%h, b = 0x%h, output: 0x%h", i, j, out);
    end

endmodule
