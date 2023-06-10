module cuberoot(
    input clk_i, //click
    input rst_i, //reset
    input [7:0] a_i, //input
    input start_i, //start
    output wire busy_o, //is buisy now
    output reg [3:0] y_bo
); //output value 255^(1/3) fits only 4 bits

localparam IDLE = 0,
           WORK = 1,
           MUL1_1 = 2,
           MUL1_2 = 3,
           MUL2 = 4,
           WAIT_MUL2 = 5,
           CHECK_X = 6,
           SUB_B = 7;

reg signed [15:0] s;
wire end_step;
reg [7:0] x;
reg [31:0] b, y, tmp1;
reg [4:0] state;


reg   [7:0] mult1_a;
reg   [7:0] mult1_b;
wire [15:0] mult1_y;
reg  mult1_start;
wire  mult1_busy;

multer mul1_inst(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .a_bi(mult1_a),
    .b_bi(mult1_b),
    .start_i(mult1_start),
    .busy_o(mult1_busy),
    .y_bo(mult1_y)
);

reg [31:0] sum_a;
reg [31:0] sum_b;
wire [31:0] sum_out;

summator sum_inst(
    .a(sum_a),
    .b(sum_b),
    .out(sum_out)
);

assign end_step = (s == 'hfffd); // s == -3
assign busy_o = (state != IDLE);

always @(posedge clk_i) begin
    if (rst_i) begin
        y_bo <= 0;
        s <= 0;
        mult1_start <= 0;
        state <= IDLE;
    end else begin
        case (state)
            IDLE:
                begin
                    if (start_i) begin
                        y_bo <= 0; 
                        mult1_start <= 0;
                        state <= WORK;
                        x <= a_i;
                        s <= 'd30; // s = 30
                        y <= 0;
                    end
                end
            WORK:
                begin
                    if (end_step) begin
                        state <= IDLE;
                        y_bo <= y;
                    end else begin
                        y <= y << 1;
                        state <= MUL1_1;
                    end
                end  
            MUL1_1:
                begin 
                    tmp1 <= y << 1; 
                    state <= MUL1_2;
                end
            MUL1_2:
                begin
                    sum_a <= tmp1;
                    sum_b <= y;
                    state <= MUL2;
                end
            MUL2:
                begin
                    mult1_a <= sum_out;
                    mult1_b <= y + 1;
                    mult1_start <= 1;
                    state <= WAIT_MUL2;
                 end
            WAIT_MUL2:
                 begin
                    mult1_start <= 0;
                    if(~mult1_busy && ~mult1_start) begin               
                        b <= mult1_y + 1 << s;
                        s <= s - 3; 
                        state <= CHECK_X;
                    end
                end
            CHECK_X:
                begin
                    if (x >= b) begin
                        sum_a <= x;
                        sum_b <= ~b + 1;
                        y <= y + 1;
                        state <= SUB_B;
                    end else begin
                        state <= WORK;
                    end
                end
            SUB_B: 
                begin 
                      x <= sum_out;
                      state <= WORK;
                end
        endcase
    end
end
endmodule