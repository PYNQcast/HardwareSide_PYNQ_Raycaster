`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 21:41:57
// Design Name: 
// Module Name: wall_texturer
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


module wall_texturer(
input [9:0] x_coord,
input [9:0] y_coord,
input [4:0] wall_x,
input [8:0] wall_half_height,

output [23:0] wall_pixel_val



    );
    
    
wire [4:0] tex_x;   
    
    
reg [11:0] wall_texture [0:1023];
    
initial begin
    $readmemh("wall.mem", wall_texture);
end


    
assign tex_x = wall_x;

  
  
wire signed [10:0] wall_height  = wall_half_height << 1;
wire [9:0] sprite_top_y = 10'd240 - wall_half_height; 


wire [9:0] y_far_through = y_coord - sprite_top_y;

wire [14:0] y_numerator = y_far_through << 5;

wire [4:0] tex_y = ((y_numerator) / wall_height);

wire [9:0] pix_addr = {tex_y, tex_x};   



wire [11:0] selected_pixel = wall_texture[pix_addr];

assign wall_pixel_val = {{selected_pixel[11:8],4'd0},{selected_pixel[7:4],4'd0},{selected_pixel[3:0],4'd0}};

  
  
  
  
  
  
  
    
    
endmodule
