`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 12:29:18
// Design Name: 
// Module Name: dir_vec_tb
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


module dir_vec_tb;

reg clk;
reg [11:0] angle_in;
wire [15:0] dir_x;
wire [15:0] dir_y;
wire [15:0] plane_x;
wire [15:0] plane_y;


dir_vectors dut(

    .clk(clk),
    .angle_in(angle_in),
    // angle in is the angle anticlockwise from x axis it goes from 0 to 4095 to map full rotation - and also simplifies wraparound
    
    .dir_x(dir_x), // cos(a)
    .dir_y(dir_y),  // sin(a)
    .plane_x(plane_x),
    .plane_y(plane_y)



);

initial begin
    clk = 1;
    forever #5 clk = ~clk;
end

initial begin
    angle_in = 12'h0;
    #10;
    angle_in = 12'b100000000000;
    #10;
    angle_in = 12'b010000000000;
    #10;
    angle_in = 12'b110000000000;
    #10;
    angle_in = 12'b001000000000;
    #50;
    
    $finish;
end

endmodule
