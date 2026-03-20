`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 11:31:57
// Design Name: 
// Module Name: dir_vec
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


module dir_vectors #(
    parameter angle_width = 12, //0 to 4095 maps whole circle
    parameter doutf_bits = 14, //Q2.14 enables precise decimal mapping, only need 2 at the top because only need to map from -1 to 1
    parameter dwidth = 16,
    parameter fov = 90 // currently at 90 because plane vector isnt scaled
)
(
    input clk,
    input [angle_width-1:0] angle_in,
    // angle in is the angle anticlockwise from x axis it goes from 0 to 4095 to map full rotation - and also simplifies wraparound
    
    output reg [dwidth-1:0] dir_x, // cos(a)
    output reg [dwidth-1:0] dir_y,  // sin(a)
    
    output reg [dwidth-1:0] plane_x, // the plane vector is the dir vector rotated 90' anticlockwise
    output reg [dwidth-1:0] plane_y
    
     

    );
    
    reg [dwidth-1:0] cos_lookup [0:2**angle_width-1];
    
    wire [angle_width-1:0] sin_offset;
    
    initial $readmemh("cos_lut.hex", cos_lookup);
    
    assign sin_offset = angle_in - {2'b01,{(angle_width-2){1'b0}}}; // shifts by quarter cycle to get sin - as cycle maps to angle width wrapparound is free
    
    always @(posedge clk) begin
        dir_x <= cos_lookup[angle_in];
        dir_y <= cos_lookup[sin_offset];
        plane_x <= -cos_lookup[sin_offset];
        plane_y <= cos_lookup[angle_in];
    end
    
    
    
    
endmodule
