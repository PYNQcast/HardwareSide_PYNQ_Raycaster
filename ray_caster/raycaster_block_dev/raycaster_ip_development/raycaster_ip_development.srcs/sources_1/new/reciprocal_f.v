`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 17:35:18
// Design Name: 
// Module Name: reciprocal_f
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


module abs_reciprocal_f
#(
parameter SCREEN_HEIGHT = 480,
parameter SCREEN_WIDTH = 720,
parameter MAP_WIDTH = 32,
parameter MAP_HEIGHT = 32,
parameter COORD_SIZE = 32,
parameter COORD_FRAC_BITS = 16,
parameter angle_width = 12, //0 to 4095 maps whole circle
parameter dinf_bits = 14, //Q2.14 enables precise decimal mapping, only need 2 at the top because only need to map from -1 to 1
parameter dwidth = 16,
//input it Q2.14
parameter outwidth = 16,
parameter outf_bits = 10,
//out is Q6.10
parameter fov = 90,


//parameters for LUT
//map uses Q1.9 - we clip any smaller fractional bits.
//it has one integer bit because we do it unsigned
parameter lookup_f_bits = 9

)
(
    input clk,
    input [dwidth-1:0] in_x,
    input [dwidth-1:0] in_y,
    
    output reg [17:0] out_x,
    output reg [17:0] out_y
    
    
    );
    
    
    reg [17:0] recip_lookup [0:4095];
   
    
    initial $readmemh("delta_lut.mem", recip_lookup);
    
    wire [dwidth-1:0] mag_x;
    wire [dwidth-1:0] mag_y;
    wire [lookup_f_bits:0] clipped_index_x;
    wire [lookup_f_bits:0] clipped_index_y;
    
    
    assign mag_x = in_x[15] ? (~in_x + 1'b1) : in_x; //getting magnitude
    assign mag_y = in_y[15] ? (~in_y + 1'b1) : in_y;
    
    assign clipped_index_x = mag_x[14:5]; //clipping to Q1.9
    assign clipped_index_y = mag_y[14:5]; //will clamp and saturate at FFFF = ~64 bigger that 32x32 grid
    
    
        
    always @(posedge clk) begin
        out_x <= recip_lookup[clipped_index_x]; //outputs are q6.12
        out_y <= recip_lookup[clipped_index_y];
        
    end
    
    
endmodule
