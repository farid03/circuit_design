`timescale 1ns / 1ps
module summator(
    input [7:0] a,
    input [7:0] b,
    output [7:0] out
);

assign out = a + b;
endmodule
