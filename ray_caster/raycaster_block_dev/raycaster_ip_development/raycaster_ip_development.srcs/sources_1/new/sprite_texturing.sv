`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 22:34:23
// Design Name: 
// Module Name: sprite_texturing
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


module sprite_texturing(
input [9:0] x_coord,
input [9:0] y_coord,
input signed [10:0] sprite_start_x,
input signed [10:0] sprite_end_x,
input [9:0] sprite_top_y,
input [9:0] sprite_bottom_y,

output [23:0] sprite_pixel_val,

output invisible_pixel


    );
    
reg [11:0] sprite_map [0:255];
// data is 12 bits - 4 bits per colour - then append each with 0s to get 24bit pixel val


initial begin
    $readmemh("ghost_bits.mem", sprite_map);
end

wire [7:0] sprite_addr = {tex_y, tex_x};


wire signed [10:0] width_height = sprite_end_x - sprite_start_x + 1;

wire signed [10:0] x_far_through = x_coord - sprite_start_x;
wire [9:0] y_far_through = y_coord - sprite_top_y;

wire [13:0] x_numerator = x_far_through[9:0] << 4;

wire [3:0] tex_x = (x_numerator) / width_height;

wire [13:0] y_numerator = y_far_through << 4;

wire [3:0] tex_y = ((y_numerator) / width_height);



wire [11:0] selected_pixel = sprite_map[sprite_addr];

assign sprite_pixel_val = {{selected_pixel[11:8],4'd0},{selected_pixel[7:4],4'd0},{selected_pixel[3:0],4'd0}};

assign invisible_pixel = (selected_pixel == 12'hF0F); //magenta - typical invisible colour    
    
    
    
    
    
endmodule
