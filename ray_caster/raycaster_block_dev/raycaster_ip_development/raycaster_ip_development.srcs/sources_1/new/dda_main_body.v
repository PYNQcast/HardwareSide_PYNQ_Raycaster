`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2026 19:42:15
// Design Name: 
// Module Name: dda_main_body
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


module dda_main_body(
    input clk,
    input start,
    input rst,
    
    input cell_status, //from bram
    
    input [15:0] pos_x,
    input [15:0] pos_y,
    
    input [15:0] dir_y,
    input [15:0] dir_x,
    
    input [15:0] initial_cell_offset_x,
    input [15:0] initial_cell_offset_y,
    
    input [20:0] side_disty,
    input [17:0] delta_disty, //6.12
    input [15:0] map_y,
    input stepy,
    input [20:0] side_distx,
    input [17:0] delta_distx,  //6.12
    input [15:0] map_x,
    input stepx,
    
    output reg [15:0] distance,
    output reg [4:0] wall_x,
    output reg ray_done,
    output reg side_out,
    
    output wire [4:0] cell_check_x,
    output wire [4:0] cell_check_y,
    
    
    output [33:0] v_wall_X_calc_y,
    output [33:0] v_wall_X_calc_x 
    

    );
    
    reg dda_in_progress;
    reg bram_check_cycle;
    reg dda_load_cycle;

    reg [15:0] r_pos_x;
    reg [15:0] r_pos_y;
    reg [15:0] r_dir_x;
    reg [15:0] r_dir_y;
    reg [22:0] r_side_disty;
    reg [17:0] r_delta_disty;
    reg [15:0] r_map_y;
    reg r_stepy;
    reg [22:0] r_side_distx;
    reg [17:0] r_delta_distx;
    reg [15:0] r_map_x;
    reg r_stepx;
    reg [9:0] r_initial_cell_offset_x;
    reg [9:0] r_initial_cell_offset_y;
    
    reg side;
    
    
    
wire near_parallel_y = (r_delta_disty > 18'h3FFFE);
wire near_parallel_x = (r_delta_distx > 18'h3FFFE);

wire step_x = near_parallel_y || (!near_parallel_x && (r_side_distx < r_side_disty));

wire [15:0] next_map_x = step_x ? 
    r_map_x + (r_stepx ? 16'h0400 : 16'hFC00) : r_map_x;
wire [15:0] next_map_y = step_x ? 
    r_map_y : r_map_y + (r_stepy ? 16'h0400 : 16'hFC00);
 
assign cell_check_x = next_map_x[14:10];
assign cell_check_y = next_map_y[14:10];

wire [22:0] distance_sub_x;
wire [22:0] distance_sub_y;
    
assign distance_sub_y = (r_side_disty - r_delta_disty);
assign distance_sub_x = (r_side_distx - r_delta_distx);

wire [15:0] perp_distance_y = |distance_sub_y[22:18] ? 16'hFFFF : distance_sub_y[17:2];
wire [15:0] perp_distance_x = |distance_sub_x[22:18] ? 16'hFFFF : distance_sub_x[17:2];

wire [17:0] precise_perp_distance_y = |distance_sub_y[22:18] ? 18'h3FFFF : distance_sub_y[17:0];
wire [17:0] precise_perp_distance_x = |distance_sub_x[22:18] ? 18'h3FFFF : distance_sub_x[17:0];


wire signed [33:0] wall_X_calc_y = ($signed({1'b0,perp_distance_y}) * $signed(r_dir_x)) + $signed({9'd0,r_pos_x[9:5], 19'd0});
//         9.26                             7.10                           2.14

wire signed [33:0] wall_X_calc_x = ($signed({1'b0,perp_distance_x}) * $signed(r_dir_y)) + $signed({9'd0,r_pos_y[9:5], 19'd0});
//         9.26                             7.10                           2.14

assign v_wall_X_calc_x = wall_X_calc_x;
assign v_wall_X_calc_y = wall_X_calc_y;
    
    always @(posedge clk) begin
        if(rst) begin
            dda_in_progress <= 1'b0;
            bram_check_cycle <= 1'b0;
            ray_done <= 1'b0;
            dda_load_cycle <= 1'b0;
            ray_done <= 1'b0;
        end
        else
            if(start) begin
                dda_load_cycle <= 1'b1;
                dda_in_progress <= 1'b0;

                bram_check_cycle <= 1'b0;
                ray_done <= 1'b0;
                
                r_side_disty <= side_disty;
                r_delta_disty <= delta_disty;
                r_map_y <= map_y;
                r_stepy <= stepy;
                r_side_distx <= side_distx;
                r_delta_distx <= delta_distx;
                r_map_x <= map_x;
                r_stepx <= stepx;
                r_dir_x <= dir_x;
                r_dir_y <= dir_y;
                r_pos_x <= pos_x;
                r_pos_y <= pos_y;
                r_initial_cell_offset_x <= initial_cell_offset_x[9:0];
                r_initial_cell_offset_y <= initial_cell_offset_y[9:0];
      
            end
            else if (ray_done) begin
                ray_done <= 1'b0;
                
                
                
                
                
            end
            
            else if(dda_load_cycle) begin // this stops us from reading stale map values
                dda_load_cycle <= 1'b0;
                dda_in_progress <= 1'b1;
            end
            
            else if(dda_in_progress) begin
                if(bram_check_cycle) begin
                        // check if wall hit
                    bram_check_cycle <= 1'b0;
                    
                    if(cell_status) begin // wall hit
                        dda_in_progress <= 1'b0;
                        ray_done <= 1'b1;
                        side_out <= side;
                        
                        if(side) begin
                            distance <= perp_distance_y;
                            wall_x <= wall_X_calc_y[21:17]; //original 21:17
                        end
                        else begin
                            distance <= perp_distance_x;
                            wall_x <= wall_X_calc_x[21:17];
                        end
                        
                    end
                end
                else begin
                    r_map_x <= next_map_x;
                    r_map_y <= next_map_y;
                    bram_check_cycle <= 1'b1;
                    
                    if(r_delta_disty > 18'h3FFFE) begin
                        // near-parallel to Y: only step in X
                        r_side_distx <= r_side_distx + r_delta_distx;
                        side <= 1'b0;
                    end
                    else if(r_delta_distx > 18'h3FFFE) begin
                        // near-parallel to X: only step in Y
                        r_side_disty <= r_side_disty + r_delta_disty;
                        side <= 1'b1;
                    end
                    else if(r_side_distx < r_side_disty) begin
                        r_side_distx <= r_side_distx + r_delta_distx;
                        side <= 1'b0;
                    end
                    else begin
                        r_side_disty <= r_side_disty + r_delta_disty;
                        side <= 1'b1;
                    end
                
                end
            end
        end
    
    
    
    
    
    
    
endmodule
