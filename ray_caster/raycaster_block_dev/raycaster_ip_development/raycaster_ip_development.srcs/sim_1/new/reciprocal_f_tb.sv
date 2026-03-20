`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2026 17:29:18
// Design Name: 
// Module Name: reciprocal_f_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module abs_reciprocal_f_tb;

reg clk;
reg  [15:0] in_x;
reg  [15:0] in_y;
wire [15:0] out_x;
wire [15:0] out_y;

abs_reciprocal_f dut (
    .clk(clk),
    .in_x(in_x),
    .in_y(in_y),
    .out_x(out_x),
    .out_y(out_y)
);

initial begin
    clk = 1;
    forever #5 clk = ~clk;
end

// Q2.14 constants
// 1.0   = 16384 = 16'h4000
// 0.707 = 11585 = 16'h2D41  (45 deg diagonal)
// 0.5   =  8192 = 16'h2000
// 0.1   =  1638 = 16'h0666
// -1.0  = 16'hC000 (signed)
// -0.5  = 16'hE000 (signed)

initial begin
    $display("time    in_x      in_y      out_x  out_x_real  out_y  out_y_real");
    $monitor("%0t  %h  %h  %0d  %f  %0d  %f",
             $time, in_x, in_y,
             out_x, out_x / 1024.0,
             out_y, out_y / 1024.0);

    // horizontal ray: dirX=1.0, dirY=0 (should give 1.0, saturated)
    in_x = 16'h4000; in_y = 16'h0000; #10;

    // 45 deg: dirX=0.707, dirY=0.707 (should give ~1.414 both)
    in_x = 16'h2D41; in_y = 16'h2D41; #10;

    // dirX=0.5, dirY=0.5 (should give 2.0 both)
    in_x = 16'h2000; in_y = 16'h2000; #10;

    // negative inputs: dirX=-1.0, dirY=-0.707 (magnitude same as positive)
    in_x = 16'hC000; in_y = 16'hD2BF; #10;

    // mixed signs: dirX=-0.5, dirY=0.707
    in_x = 16'hE000; in_y = 16'h2D41; #10;

    // near-zero dirX (should clamp): dirX=0.01, dirY=1.0
    in_x = 16'h0028; in_y = 16'h4000; #10;

    // dirX=0.1, dirY=0.5
    in_x = 16'h0666; in_y = 16'h2000; #10;

    #20;
    $finish;
end

endmodule
