`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 15:07:19
// Design Name: 
// Module Name: ray_caster
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


module ray_caster #(
parameter MAP_WIDTH = 32,
parameter MAP_HEIGHT = 32,
parameter COORD_SIZE = 32,
parameter COORD_FRAC_BITS = 16,
parameter angle_width = 12, //0 to 4095 maps whole circle
parameter dinf_bits = 14, //Q2.14 enables precise decimal mapping, only need 2 at the top because only need to map from -1 to 1
parameter dwidth = 16,
parameter fov = 90
)(
input clk,
input rst,
input tready,

output reg last_h,



output wire [15:0] distance,
output wire [4:0] wall_x,
output wire ray_done,
 
output reg [9:0] vert_height, // 9 bits
output reg [15:0] wall_distance,
output reg vert_height_valid,

output wire [23:0] pxl_val,
output wire frame,
output wire start_line,
output wire last_pixel,

output wire start_frame,

output wire tlast,

//bram

output wire [31:0] addr,

input [31:0] bram_data,






// testing viewing wires

    output [dwidth-1:0] v_raydir_x,
    output [dwidth-1:0] v_raydir_y,
    
    output [16:0] v_i,
    output [15:0] v_ray_no,
   
    output [15:0] v_deltadistx, // Q6.10 unisgned
    output [15:0] v_deltadisty,
    
    output [15:0] v_sidedistx,
    output [15:0] v_sidedisty,
    
    output v_step_x, // 1'b0 = -1, 1'b1 = 1
    output v_step_y,
    
    output [dwidth-1:0] v_map_x, //q6.10 signed
    output [dwidth-1:0] v_map_y,
    
    output v_frame_in_progress,
    output v_start,
    output v_new_ray,
    output v_new_ray_d, // new_ray delayed by one tick
    output v_new_ray_dd, // new_ray delayed by two-ticks
    output v_new_ray_ddd,
    output v_ray_finished,
    
    output v_dda_start,
    
    output [15:0] v_dir_x_r,
    
    
    output wire [9:0]  v_sprite_half_height,
    output wire [9:0]  v_sprite_half_width,
    output wire [9:0]  v_sprite_start_x,
    output wire [9:0]  v_sprite_end_x,
    output wire [15:0] v_sprite_distance,
    output wire [9:0]  v_sprite_screen_x,
    output [15:0] v_transform_x,
    output [15:0] v_transform_y,
    output [9:0] v_r_sprite_half_height,
    output [9:0] v_r_sprite_half_width,
    output [9:0] v_r_sprite_start_x,
    output [9:0] v_r_sprite_end_x,
    output [15:0] v_r_sprite_distance,
    
    output [33:0] v_wall_X_calc_y,
    output [33:0] v_wall_X_calc_x 
    



  
);



    wire internal_pulse;
    reg started;

    assign internal_pulse = ~started;
    
    assign start_pulse = internal_pulse;

    reg [15:0] cell_offset_x;
    reg [15:0] cell_offset_y;



    wire [4:0] cell_check_x;
    wire [4:0] cell_check_y;

    reg [4:0] cell_check_x_d;

    reg [dwidth-1:0] raydir_x;
    reg [dwidth-1:0] raydir_y;
    
    reg [16:0] i; // 17 bits for best accuracy
    reg [15:0] ray_no;
    
    wire [17:0] deltadistx; // Q6.12 unisgned
    wire [17:0] deltadisty;
    
    reg [20:0] sidedistx;
    reg [20:0] sidedisty;
    
    reg step_x; // 1'b0 = -1, 1'b1 = 1
    reg step_y;
    
        
    wire [dwidth-1:0] map_x; //q6.10 signed
    wire [dwidth-1:0] map_y;
    
    reg [dwidth-1:0] dir_x_r, dir_y_r;
    reg [dwidth-1:0] plane_x_r, plane_y_r;
    reg [dwidth-1:0] pos_x_r, pos_y_r;
    
    
    
    
    assign v_raydir_x = raydir_x;
    assign v_raydir_y = raydir_y;
    
    assign v_i = i;
    assign v_ray_no = ray_no;
    
    assign v_deltadistx = deltadistx;
    assign v_deltadisty = deltadisty;
    
    assign v_sidedistx = sidedistx;
    assign v_sidedisty = sidedisty;
    
    assign v_step_x = step_x;
    assign v_step_y = step_y;
    
    assign v_map_x = map_x;
    assign v_map_y = map_y;
    
    assign map_x = {pos_x_r[15:10],10'b0000000000};
    assign map_y = {pos_y_r[15:10],10'b0000000000};
    
    assign v_dir_x_r = dir_x_r;
    
    
    wire [33:0] neg_side_distx_multiply;
    wire [33:0] pos_side_distx_multiply;
    wire [33:0] neg_side_disty_multiply;
    wire [33:0] pos_side_disty_multiply;
    
    
    assign neg_side_distx_multiply = (pos_x_r-map_x) * (deltadistx); //remember deltadist is now 6.12
    assign pos_side_distx_multiply = (map_x + {1'b1,10'h0} - pos_x_r) * deltadistx;
    assign neg_side_disty_multiply = (pos_y_r-map_y) * (deltadisty);
    assign pos_side_disty_multiply = (map_y + {1'b1,10'h0} - pos_y_r) * deltadisty;
    
    
    
    
// bram controller
reg [1:0] load_from_bram; //11 load angle, 10 load position
reg load_stage;
    
    
assign addr = (load_stage ? ( (load_from_bram == 2'b11) ? 32'h00000021: ((load_from_bram == 2'b10) ? 32'h00000020 : 32'h00000022)) 
    : {26'h0,cell_check_y}) << 2;
    
// three cycles: (1) update i, (2) update raydir, (3) BRAM output valid ? latch step/sidedist + assert dda_start
    
    always @(posedge clk) begin
        if(raydir_x[dwidth-1]) begin
            step_x <= 1'b0;
            sidedistx <= |neg_side_distx_multiply[33:28] ? 21'h1FFFFF : neg_side_distx_multiply[27:10];
            cell_offset_x <= (pos_x_r-map_x);
        end
        else begin
            step_x <= 1'b1;
            sidedistx <= |pos_side_distx_multiply[33:28] ? 21'h1FFFFF : pos_side_distx_multiply[27:10];
            cell_offset_x <= (map_x + {1'b1,10'h0} - pos_x_r);
        end
        
        if(raydir_y[dwidth-1]) begin
            step_y <= 1'b0;
            sidedisty <= |neg_side_disty_multiply[33:28] ? 21'h1FFFFF : neg_side_disty_multiply[27:10];
            cell_offset_y <= (pos_y_r-map_y);
        end
        else begin
            step_y <= 1'b1;
            sidedisty <= |pos_side_disty_multiply[33:28] ? 21'h1FFFFF : pos_side_disty_multiply[27:10];
            cell_offset_y <= (map_y + {1'b1,10'h0} - pos_y_r);
        end
    end
   

    abs_reciprocal_f deltadist_calc (
    .clk(clk),
    .in_x(raydir_x),
    .in_y(raydir_y),
    .out_x(deltadistx),
    .out_y(deltadisty)
    );
    


    //raycaster control logic
    
    reg frame_in_progress;
    reg start;
    reg new_ray;
    reg new_ray_d; // new_ray delayed by one tick
    reg new_ray_dd; // new_ray delayed by two-ticks
    reg new_ray_ddd;
    reg ray_finished;
    
    reg dda_start;
    
//saved values for the frame    
    

    
assign v_frame_in_progress = frame_in_progress;
assign v_start = start;
assign v_new_ray = new_ray;
assign v_new_ray_d = new_ray_d; 
assign v_new_ray_dd = new_ray_dd; 
assign v_new_ray_ddd = new_ray_ddd;
assign v_ray_finished = ray_finished;
    
assign v_dda_start = dda_start;

       wire start_frame_internal = start_pulse | last_pixel;  
    
wire [15:0] dir_wire_x;
wire [15:0] dir_wire_y;
wire [15:0] plane_wire_x;
wire [15:0] plane_wire_y;

    
        wire sprite_done;   

reg [15:0] sprite_x_position;
reg [15:0] sprite_y_position;


dir_vectors dir_v_lookup(
.clk,
.angle_in(bram_data[11:0]), //12 bits
.dir_x(dir_wire_x),
.dir_y(dir_wire_y),
.plane_x(plane_wire_x),
.plane_y(plane_wire_y)
);    
    
    
    
    always @(posedge clk) begin
    
        if(rst) begin
            frame_in_progress <= 1'b0;
            start <= 1'b0;
            new_ray <= 1'b0;
            ray_finished <= 1'b0; 
            new_ray_d <= 1'b0;
            dda_start <= 1'b0;
            new_ray_dd <= 1'b0;   
            new_ray_ddd <= 1'b0; 
            vert_height_valid <= 1'b0;  
            load_from_bram <= 2'b00;
            load_stage <= 1'b0;
            started <= 1'b0;
        end
        else if(load_stage) begin
        
        
            if(load_from_bram == 2'b11) begin
                load_from_bram <= 2'b10; 
                //looking up angle
            end
            else if(load_from_bram == 2'b10) begin
                //lookup from vector generater from the read angle
                
                //looking up positions
                load_from_bram <= 2'b01;
            end
            else if(load_from_bram == 2'b01) begin
                //load the returned dir and plane vectors from the vector modules
                
                //looking up sprite positions
                pos_x_r   <= bram_data[31:16];
                pos_y_r   <= bram_data[15:0];
                
                
                 dir_x_r   <= dir_wire_x;
                 dir_y_r   <= dir_wire_y;
                 plane_x_r <= plane_wire_x;
                 plane_y_r <=plane_wire_y;
                   
                   

                
                load_from_bram <= 2'b00;

                
               
                
            end
            
            else if(load_from_bram == 2'b00) begin
                //save sprite positions
                sprite_y_position <= bram_data[15:0];
                sprite_x_position <= bram_data[31:16];
            
                load_stage <= 1'b0;
                new_ray_d   <= 1'b0;
                new_ray_dd  <= 1'b0;
                new_ray_ddd <= 1'b0;
                                
                            
                frame_in_progress <= 1'b1;
                start <= 1'b1;
                new_ray <= 1'b1;
            end
            
        end
        else begin
            if(internal_pulse) begin
                started <= 1'b1;
            end
        
            new_ray_d  <= new_ray;
            new_ray_dd <= new_ray_d;
            new_ray_ddd <= new_ray_dd;
            vert_height_valid <= (ray_done);
            
            if(new_ray_ddd && frame_in_progress && !last_h) begin
                dda_start <= 1'b1; 
            end
            if(dda_start) begin
                dda_start <= 1'b0;
            end
            
            
        
            if(start_frame_internal & ~frame_in_progress) begin
                load_stage <= 1'b1;
                load_from_bram <= 2'b11;
            
            end

            
            if(start) begin
                start <= 1'b0; // these dont offer race conditions because they can only occur when frame_in_progress = 1
            end
            if(new_ray) begin
                new_ray <= 1'b0;
            end
            
            if (last_h) begin
                frame_in_progress <= 1'b0;
            end
            
            if(ray_done) begin
                new_ray <= 1'b1;
                ray_finished <= 1'b0;
            end
        end
        
        
    end
    
    
    
    wire [31:0] prod_i_x;
    wire [31:0] prod_i_y;
    
    assign prod_i_x = ($signed(i[16:1]) * $signed(plane_x_r));
    assign prod_i_y = ($signed(i[16:1]) * $signed(plane_y_r));    
    
    
    
    always @(posedge clk) begin
            if (last_h) begin
                last_h <= 1'b0;
            end
        
        
        
        
        if(new_ray) begin    
        
            //rays might sweep from right to left - check out later    
        
            if(start) begin
                i <= 17'b01000000000000000; // setting to 11
                //i <= 16'h0; // setting to 0 for testing purposes on dda
                ray_no <= 16'b0;
                last_h <= 1'b0;
            end
            else if(ray_no == 16'd639) begin // this is the last ray
                last_h <= 1'b1;
            end
            
            else begin
                i <= i - 17'b00000000001100110; // approx 2/640 in our current q2.15 representation
                ray_no <= ray_no + 1'b1; // testing purposes - un-comment later
                

                
                last_h <= 1'b0;
            end        
        end
        if(new_ray_d) begin
            raydir_x <= dir_x_r + prod_i_x[29:14];
            raydir_y <= dir_y_r + prod_i_y[29:14]; 
        end

    end  

    wire side_wire;
    reg side;
    
    always @(posedge clk) begin
        cell_check_x_d <= cell_check_x;
    end
    
    
    wire cell_status;
    assign cell_status = bram_data[cell_check_x_d];
    
    
    dda_main_body dda (
        .clk(clk),
        .start(dda_start),
        .rst(rst),
        
        .pos_x(pos_x_r),
        .pos_y(pos_y_r),
        .dir_x(dir_x_r),
        .dir_y(dir_y_r),
        
        .cell_check_x(cell_check_x),
        .cell_check_y(cell_check_y), 
        
        .initial_cell_offset_x(cell_offset_x),
        .initial_cell_offset_y(cell_offset_y),
        
        .cell_status(cell_status), //from bram
        
        .side_disty(sidedisty),
        .delta_disty(deltadisty),
        .map_y(map_y),
        .stepy(step_y),
        .side_distx(sidedistx),
        .delta_distx(deltadistx),
        .map_x(map_x),
        .stepx(step_x),
        
        .distance(distance),
        .wall_x(wall_x),
        .ray_done(ray_done),
        .side_out(side_wire),
        
        .v_wall_X_calc_y(v_wall_X_calc_y),
        .v_wall_X_calc_x(v_wall_X_calc_x)
    );  
    
    
    // final bar half-height calculation
    
    reg [9:0] bar_half_height_lut [0:4097];
    

       reg [15:0] completed_ray_no; 

    initial $readmemh("bar_height_lut.mem", bar_half_height_lut);
    
    
    // from the sprite caster
    
    wire [11:0] sprite_transform_y;
    
    reg [4:0] wall_x_r;
    reg  [10:0] sprite_result; // remember this is 240/distance
    
    
    //
    
    
    // does 240/distance to find the height of a half a bar
    always @(posedge clk) begin
        if(1) begin
            vert_height <= bar_half_height_lut[distance[15:4]];
            wall_distance <= distance;
            wall_x_r <= wall_x;
            sprite_result <= bar_half_height_lut[sprite_transform_y];
            completed_ray_no <= ray_no;
            side <= side_wire;
        end
    end
    // sprite heights mut be a division of 2 of 480, aka, 480,240,120,60 - because then can just shift the result of this lut to get half height
    

    
        wire [9:0] sprite_half_height;
        wire [9:0] sprite_half_width;
        wire signed [10:0] sprite_start_x;
        wire signed [10:0] sprite_end_x;
        wire [15:0] sprite_distance;
        wire sprite_off_screen;
        
 
      

    
    // hdmi output
    
    hdmi_pixel_stream_gen hdmi_control(
    .clk(clk),
    .rst(rst),
    .tready(tready),
    .vert_half_height(vert_height),
    .vert_height_valid(vert_height_valid),
    .ray_no(completed_ray_no),
    .last_h(last_h),
    .side_in(side),
    
    .wall_x(wall_x_r),
    
    
    .wall_distance(wall_distance),
    //for sprites
    
    .sprite_half_height(sprite_half_height),
    .sprite_half_width(sprite_half_width),
    .sprite_start_x(sprite_start_x),
    .sprite_end_x(sprite_end_x),
    .sprite_distance(sprite_distance),
    .sprite_off_screen(sprite_off_screen),
    
    
    
    
    .pxl_val(pxl_val),
    .frame_d(frame),
    .start_line_d(start_line),
    .last_pixel(last_pixel),
    .start_frame(start_frame),
    .tlast(tlast),
    
    
    
    
    
    .v_r_sprite_half_height(v_r_sprite_half_height),
.v_r_sprite_half_width(v_r_sprite_half_width),
.v_r_sprite_start_x(v_r_sprite_start_x),
.v_r_sprite_end_x(v_r_sprite_end_x),
.v_r_sprite_distance(v_r_sprite_distance)
    
    
    
    
    );
    


    
    
    sprite_caster sprite (
        .clk(clk),
        .start(start),
        .rst(rst),
        
        .sprite_x(sprite_x_position), //6.10
        .sprite_y(sprite_y_position),
        .pos_x(pos_x_r), //6.10
        .pos_y(pos_y_r),
        .dir_x(dir_x_r), //2.14
        .dir_y(dir_y_r),
        .plane_x(plane_x_r), //2.14
        .plane_y(plane_y_r),
        
        //.sprite_dist_lookup_result(sprite_result), // remember 240/distance - and comes one cycle after //height up from centre
        
    
    .v_sprite_half_height(v_sprite_half_height),
    .v_sprite_half_width(v_sprite_half_width),
    .v_sprite_start_x(v_sprite_start_x),
    .v_sprite_end_x(v_sprite_end_x),
    .v_sprite_distance(v_sprite_distance),
    .v_sprite_screen_x(v_sprite_screen_x),
    .v_transform_x(v_transform_x),
    .v_transform_y(v_transform_y),
    
    
    .sprite_half_height(sprite_half_height),
    .sprite_half_width(sprite_half_width),
    .sprite_start_x(sprite_start_x),
    .sprite_end_x(sprite_end_x),
    .sprite_distance(sprite_distance),
    .sprite_off_screen(sprite_off_screen)

        
    
    
    
    );
    
    
    


    assign v_sprite_start_x = sprite_start_x;
    assign v_sprite_end_x = sprite_end_x;
    

endmodule
