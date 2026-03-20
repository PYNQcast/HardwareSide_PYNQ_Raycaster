`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 17:47:57
// Design Name: 
// Module Name: hdmi_pixel_stream_gen
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


module hdmi_pixel_stream_gen(
input clk,
input rst,

input tready,

input [9:0] vert_half_height,
input side_in,
input [4:0] wall_x,
input vert_height_valid,
input [15:0] ray_no,

input last_h,


input [15:0] wall_distance,
//for sprites

input [9:0] sprite_half_height,
input [9:0] sprite_half_width,
input signed [10:0] sprite_start_x,
input signed [10:0] sprite_end_x,
input [15:0] sprite_distance,

input sprite_off_screen,



//


output wire [23:0] pxl_val, //00 white, 01 grey, 10 green, 11 blue
output reg frame_d,
output reg start_line_d,
output reg last_pixel,
output reg tlast,

output wire start_frame,




//viewer wires for sprite related register

output [9:0] v_r_sprite_half_height,
output [9:0] v_r_sprite_half_width,
output [9:0] v_r_sprite_start_x,
output [9:0] v_r_sprite_end_x,
output [15:0] v_r_sprite_distance

 

    );
     
    
    
reg frame_dd;

assign start_frame = (!frame_dd) & frame_d;


    
wire frame;
reg start_line;
    
reg [8:0] next_heights [0:639];
reg [8:0] current_heights [0:639];
reg next_side [0:639];
reg current_side [0:639];


wire [23:0] t_wall_pixel_val;
// ADDED for sprites

reg [15:0] next_wall_distance [0:639];
reg [15:0] current_wall_distance [0:639];
reg [4:0] next_wall_x[0:639];
reg [4:0] current_wall_x[0:639];

reg [9:0] r_sprite_half_height;
reg [9:0] r_sprite_half_width;
reg signed [10:0] r_sprite_start_x;
reg signed [10:0] r_sprite_end_x;
reg [15:0]r_sprite_distance;
reg r_sprite_off_screen;

//

wire [9:0] r_sprite_top_y;
wire [9:0] r_sprite_bottom_y;

assign r_sprite_top_y    = 10'd240 - r_sprite_half_height;  /// this is NOT WRONG Y GROWS DOWNWARDS - 0 at top 480 at bottom
assign r_sprite_bottom_y = 10'd240 + r_sprite_half_height;

wire [23:0] t_wall_pxl_val;



reg [9:0] x_coord;
reg [9:0] y_coord;

reg in_frame;

reg stream_started;

reg frame_gap;

integer i;

wire [8:0] half_height_read;

wire strip_side;
wire [15:0] wall_dist;
wire [4:0] indiv_wall_x;
// new
reg [23:0] pxl_val_r;
assign pxl_val = pxl_val_r;

assign half_height_read = current_heights[x_coord];
assign strip_side = current_side[x_coord];
assign wall_dist = current_wall_distance[x_coord];
assign indiv_wall_x = current_wall_x[x_coord];

wire [23:0] sprite_pixel_val;
wire invis_pxl;


wire sprite_closer =  (wall_dist > r_sprite_distance);


wire sprite_behind  = r_sprite_distance[15];

wire in_wall = (y_coord >= (10'd240 - {1'b0, half_height_read}) && 
                y_coord <= (10'd240 + {1'b0, half_height_read})) || (half_height_read >= 10'd240);
                
wire [23:0] wall_pxl_val = in_wall ? 
                 (strip_side ? t_wall_pixel_val : t_wall_pixel_val) :
                 ((y_coord >= 10'd240) ?  {8'd20,8'd10,8'd10} :{8'd200,8'd200,8'd200});
                 
wire in_sprite = !r_sprite_off_screen & !invis_pxl & !sprite_behind & sprite_closer & (y_coord >= (10'd240 - {1'b0, r_sprite_half_height}) && 
                y_coord <= (10'd240 + {1'b0, r_sprite_half_height}) && ($signed({1'b0, x_coord}) >= $signed(r_sprite_start_x)) && ($signed({1'b0, x_coord}) <= $signed(r_sprite_end_x)));

   
 
   
   
always @(posedge clk) begin
   
    pxl_val_r <= (in_sprite) ?  sprite_pixel_val : wall_pxl_val;
    //pxl_val_r <= wall_pxl_val;
    
end

//

assign frame = in_frame;







/*
assign pxl_val = in_wall ? (strip_side ? 2'b01 : 2'b00) : (
                 (y_coord >= 10'd360) ? 2'b10: 2'b11);

*/
always @(posedge clk) begin
    if(rst) begin
        start_line <= 1'b0;
        last_pixel <= 1'b0;
        in_frame <= 1'b0;
        x_coord <= 10'h0;
        y_coord <= 10'h0;
        stream_started <= 1'b0;
        frame_gap <= 1'b0;
        frame_d <= 1'b0;
        start_line_d <= 1'b0;
        frame_dd <= 1'b0;
        tlast <= 1'b0;
    end
    
    else if (last_pixel) begin
        frame_dd <= frame_d;
        last_pixel <= 1'b0;
        in_frame <= 1'b0;
        frame_gap <= 1'b1;
        
        frame_d <= frame;
        start_line_d <= start_line;
        
        tlast<= 1'b0;
        
        
        
    end
    
    else begin
        frame_dd <= frame_d;
    
        frame_d <= frame;
        start_line_d <= start_line;
    
        if(vert_height_valid) begin
            next_heights[ray_no] <= vert_half_height;
            next_side[ray_no] <= side_in;
            next_wall_distance[ray_no] <= wall_distance;
            next_wall_x[ray_no] <= wall_x;
        end
        
        if(last_h && !stream_started) begin
            x_coord <= 10'h0;
            y_coord <= 10'h0;
            in_frame <= 1'b1;
            start_line <= 1'b1;
            stream_started <= 1'b1;

            for(i = 0; i < 640; i=i+1) begin
                current_heights[i] <= next_heights[i];
                current_side[i] <= next_side[i];
                current_wall_distance[i] <= next_wall_distance[i];
                current_wall_x[i] <= next_wall_x[i];
            end
            
            
            r_sprite_half_height <= sprite_half_height;
            r_sprite_half_width <= sprite_half_width;
            r_sprite_start_x <= sprite_start_x;
            r_sprite_end_x <= sprite_end_x;
            r_sprite_distance <= sprite_distance;
            r_sprite_off_screen <= sprite_off_screen;
        end
        if(frame_gap) begin
            frame_gap <= 1'b0;
            x_coord <= 10'h0;
            y_coord <= 10'h0;
            in_frame <= 1'b1;
            start_line <= 1'b1;

            for(i = 0; i < 640; i=i+1) begin
                current_heights[i] <= next_heights[i];
                current_side[i] <= next_side[i];
                current_wall_distance[i] <= next_wall_distance[i];
                current_wall_x[i] <= next_wall_x[i];
            end
            
            
            //for sprites
            
            r_sprite_half_height <= sprite_half_height;
            r_sprite_half_width <= sprite_half_width;
            r_sprite_start_x <= sprite_start_x;
            r_sprite_end_x <= sprite_end_x;
            r_sprite_distance <= sprite_distance;
            r_sprite_off_screen <= sprite_off_screen;
        end
        if(in_frame & tready) begin
            if(tlast) begin
                tlast<= 1'b0;
            end
            if(start_line) begin
                start_line <= 1'b0;
            end
            if(x_coord == 10'd639 && y_coord == 10'd479) begin
                in_frame <= 1'b0;
                last_pixel <= 1'b1;
                x_coord <= 10'h0;
                y_coord <= 10'h0;
                
                tlast <= 1'b1;
            end
            else if(x_coord == 10'd639) begin
                x_coord <= 10'd0;
                y_coord <= y_coord+1;
                start_line <= 1'b1;
                
                tlast<=1'b1;
                
            end
            else begin
                x_coord <= x_coord + 1;
            end
        
        
        
        
        end
    end
end
    
sprite_texturing sprite_texture(
.x_coord(x_coord),
.y_coord(y_coord),
.sprite_start_x(r_sprite_start_x),
.sprite_end_x(r_sprite_end_x),
.sprite_top_y(r_sprite_top_y),
.sprite_bottom_y(r_sprite_bottom_y),

.sprite_pixel_val(sprite_pixel_val),

.invisible_pixel(invis_pxl)


    );
    
    
    
wall_texturer wall_texture(
.x_coord(x_coord),
.y_coord(y_coord),
.wall_x(indiv_wall_x),
.wall_half_height(half_height_read),


.wall_pixel_val(t_wall_pixel_val)



    );




    
    
assign v_r_sprite_half_height = r_sprite_half_height;
assign v_r_sprite_half_width = r_sprite_half_width;
assign v_r_sprite_start_x = r_sprite_start_x;
assign v_r_sprite_end_x = r_sprite_end_x;
assign v_r_sprite_distance = r_sprite_distance;
    
    
    
    
    
    
    
    
endmodule
