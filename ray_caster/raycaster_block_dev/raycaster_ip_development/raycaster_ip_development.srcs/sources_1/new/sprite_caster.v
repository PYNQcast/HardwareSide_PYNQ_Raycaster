`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2026 17:31:41
// Design Name: 
// Module Name: sprite_caster
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


module sprite_caster(
    input clk,
    input start,
    input rst,
    
    input [15:0] sprite_x, //6.10
    input [15:0] sprite_y,
    input [15:0] pos_x, //6.10
    input [15:0] pos_y,
    input [15:0] dir_x, //2.14
    input [15:0] dir_y,
    input [15:0] plane_x, //2.14
    input [15:0] plane_y,
    
    //input [9:0] sprite_dist_lookup_result, // remember 240/distance - and comes one cycle after //height up from centre
    

    output reg [9:0] sprite_half_height,
    output reg [9:0] sprite_half_width,
    output reg signed [10:0] sprite_start_x,
    output reg signed [10:0] sprite_end_x,
    output reg [15:0] sprite_distance,
    output reg sprite_off_screen,
    

    output reg done,

    
    //output wire [11:0] sprite_dist_lookup,
    
    
    
    
    output wire [9:0]  v_sprite_half_height,
    output wire [9:0]  v_sprite_half_width,
    output wire [9:0]  v_sprite_start_x,
    output wire [9:0]  v_sprite_end_x,
    output wire [15:0] v_sprite_distance,
    output wire [9:0]  v_sprite_screen_x,
    output [15:0] v_transform_x,
    output [15:0] v_transform_y

    );
    
localparam INV_DET = 16'hFC00; // example Q6.10 for the inv matrix det = -cot(fov/2)   
// for a fov of 90' this is = -1 
localparam inverse_half_height = 16'b0000000100010001; //this is 1/240 in q0.16 format
//to get transformy/transformx     we take out result from the lut (240/transformy) and then multiply by transformx/240
// wich is transform x * 1/240
localparam half_screen_width = 10'b0101000000; //half screen width (640/2) in q10.0 form

localparam            
           IDLE = 3'd0,
           START_LET_MULT    = 3'd1,
           HEIGHT_DIV    = 3'd2,
           HEIGHT_DIV_WAIT = 3'd3,
           SCREEN_X_DIV    = 3'd4,
           SCREEN_X_DIV_WAIT    = 3'd5,
           DONE = 3'd6;



reg [15:0] transform_x;
reg [15:0] transform_y;


wire [15:0] sprite_diff_x;
wire [15:0] sprite_diff_y;

assign sprite_diff_x = sprite_x - pos_x; // neat little trick - since bit15 is never used in position variables (as it represents 32)
assign sprite_diff_y = sprite_y - pos_y; // we can assume the results are q6.10 twos compliment

wire [31:0] mat_multiply_x ;
wire [31:0] mat_multiply_y ;

wire [31:0] det_multiply_x ;
wire [31:0] det_multiply_y ;

//assign mat_multiply_x = $signed(dir_y) * $signed(sprite_diff_x) - $signed(dir_x) * $signed(sprite_diff_y);
assign mat_multiply_x = $signed(dir_x) * $signed(sprite_diff_y) - $signed(dir_y) * $signed(sprite_diff_x);
    //8.24                     2.14               6.10                        2.14             6.10
assign mat_multiply_y = $signed(plane_x) * $signed(sprite_diff_y) - $signed(plane_y) * $signed(sprite_diff_x);

assign det_multiply_x = $signed(INV_DET) * $signed(mat_multiply_x[31:16]); //6.10 * 8.8 = 14.18
assign det_multiply_y = $signed(INV_DET) * $signed(mat_multiply_y[31:16]);



reg [2:0] control_state;



/*
wire [11:0] sprite_dist_lookup_bits = transform_y[15:4];


assign sprite_dist_lookup = sprite_dist_lookup_bits;
//assign sprite_dist_lookup = {6'b0, transform_y[15:10]};


wire signed [31:0] sprite_screen_multiply_1 =  $signed(transform_x) * $signed(inverse_half_height);
              //6.26                              //6.10                      0.16 


wire signed [41:0] sprite_screen_multiply_2 = $signed({1'b0,sprite_dist_lookup_result}) * $signed(sprite_screen_multiply_1) + {1'b1,26'd0};
           // q17.26                    q11.0                                       6.26
wire signed [51:0] sprite_screen_x_calc = $signed(sprite_screen_multiply_2) * $signed(half_screen_width);
  
                //q27.26                  //q17.26                       q10.0
*/


// divider controls ---

reg div_start;
reg [31:0] div_dividend;
reg [31:0] div_divisor;
wire [31:0] div_quotient;
wire [31:0] div_remainder;
wire div_done;

wire [15:0] abs_transform_y = transform_y[15] ? (~transform_y + 1) : transform_y;
wire [15:0] abs_transform_x = transform_x[15] ? (~transform_x + 1) : transform_x;

// ----








reg [9:0] sprite_height; //these are the half widths and half heights remember!!!!!!
reg [9:0] sprite_width;
reg signed [10:0]      sprite_screen_x; /// the centre x coord of the sprite
reg [9:0] start_x;
reg [9:0] end_x;

wire tx_sign = transform_x[15];
wire ty_sign = transform_y[15];
wire result_sign = tx_sign ^ ty_sign;
wire signed [16:0] signed_ratio = result_sign ? (~div_quotient[16:0] + 1) : div_quotient[16:0];    
                
reg signed [16:0] r_signed_ratio;




wire signed [25:0] sprite_screen_x_calc = ($signed(r_signed_ratio) + 16'sd16384) * 10'sd320;
//                                         Q2.14                    1.0 in Q2.14       Q10.0




// Result is Q12.14, screen_x = sprite_screen_x_calc[23:14]




assign v_sprite_screen_x = sprite_screen_x;

always @(posedge clk) begin
    if(rst) begin
        transform_x <= 16'h0;
        transform_y <= 16'h0;
        control_state <= IDLE;
    end
    else begin
        transform_x <= det_multiply_x[23:8]; //q6.10
        transform_y <= det_multiply_y[23:8];
        
        if(start) begin
            control_state <= START_LET_MULT;
            done <= 1'b0;
        end
        
        
        else begin
        
        case (control_state)
            START_LET_MULT: begin
                control_state <= HEIGHT_DIV;
            end
            HEIGHT_DIV: begin
                    div_dividend <= 32'd245760;               // 240 * 2^10 : this puts the height in 6.10 so that we get integer out
                    div_divisor  <= {16'd0, abs_transform_y}; // raw Q6.10 bits
                    div_start    <= 1;
                    
                    control_state <= HEIGHT_DIV_WAIT;
                    
                    
            end
            HEIGHT_DIV_WAIT: begin
                div_start <= 0;
                if(div_done) begin
                    sprite_half_height <= div_quotient;
                    sprite_half_width <= div_quotient;
                    control_state <= SCREEN_X_DIV;
                end
            end 
            
            SCREEN_X_DIV: begin
                div_dividend <= {2'd0, abs_transform_x, 14'd0};  // shift left 14
                div_divisor  <= {16'd0, abs_transform_y};
                div_start    <= 1;
                
                control_state <= SCREEN_X_DIV_WAIT;               
            end
            
            SCREEN_X_DIV_WAIT: begin
                div_start <= 0;
                if(div_done) begin
                    r_signed_ratio <= signed_ratio;
                
                
                    // saving logic
                    
                    control_state <= DONE;
                end
            end 
            
            
            
            DONE: begin
                sprite_screen_x <= sprite_screen_x_calc >>> 14;
                //sprite_start_x <= (sprite_screen_x_calc[23:14] > (sprite_half_width)) ? sprite_screen_x_calc[23:14] - sprite_half_width : 10'd0;
                //sprite_end_x   <= (({1'b0, sprite_screen_x_calc[23:14]} + {1'b0, sprite_half_width}) > 11'h3FF) ? 10'h3FF : sprite_screen_x_calc[23:14] + sprite_half_width;
                //11bit comparison prevents wraparound in assesment of conditional
                
                
                sprite_start_x  <= (sprite_screen_x_calc >>> 14) - sprite_half_width;
                sprite_end_x    <= (sprite_screen_x_calc >>> 14) + sprite_half_width;
                
                sprite_off_screen <= (div_quotient > 32'd16794) || transform_y[15];
                
                sprite_distance<= transform_y << 1;
            
                control_state <= IDLE;
                done <= 1'b1;
            end       
        endcase
        end
    end

end




// divider instance


sequential_divider #(.WIDTH(32)) div (
    .clk(clk),
    .rst(rst),
    .start(div_start),
    .dividend(div_dividend),
    .divisor(div_divisor),
    .quotient(div_quotient),
    .remainder(div_remainder),
    .done(div_done)
);


assign v_sprite_half_height = sprite_half_height;
assign v_sprite_half_width  = sprite_half_width;
assign v_sprite_start_x     = sprite_start_x;
assign v_sprite_end_x       = sprite_end_x;
assign v_sprite_distance    = sprite_distance;
assign v_sprite_screen_x    = sprite_screen_x;
assign v_transform_x = transform_x;
assign v_transform_y = transform_y;





endmodule
