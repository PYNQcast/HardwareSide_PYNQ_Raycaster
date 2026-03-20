`timescale 1ns / 1ps

module sprite_caster_tb;

    reg clk;
    reg start;
    reg rst;
    reg [15:0] sprite_x;
    reg [15:0] sprite_y;
    reg [15:0] pos_x;
    reg [15:0] pos_y;
    reg [15:0] dir_x;
    reg [15:0] dir_y;
    reg [15:0] plane_x;
    reg [15:0] plane_y;
    reg [9:0]  sprite_dist_lookup_result;

    wire [9:0]  sprite_half_height;
    wire [9:0]  sprite_half_width;
    wire [9:0]  sprite_start_x;
    wire [9:0]  sprite_end_x;
    wire [15:0] sprite_distance;
    wire        done;
    wire [11:0] sprite_dist_lookup;
    
   

    sprite_caster uut (
        .clk(clk), .start(start), .rst(rst),
        .sprite_x(sprite_x), .sprite_y(sprite_y),
        .pos_x(pos_x), .pos_y(pos_y),
        .dir_x(dir_x), .dir_y(dir_y),
        .plane_x(plane_x), .plane_y(plane_y),
        .sprite_dist_lookup_result(sprite_dist_lookup_result),
        .sprite_half_height(sprite_half_height),
        .sprite_half_width(sprite_half_width),
        .sprite_start_x(sprite_start_x),
        .sprite_end_x(sprite_end_x),
        .sprite_distance(sprite_distance),
        .done(done),
        .sprite_dist_lookup(sprite_dist_lookup)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sprite_caster_tb.vcd");
        $dumpvars(0, sprite_caster_tb);

        clk = 0; rst = 1; start = 0;
        sprite_x = 0; sprite_y = 0;
        pos_x = 0; pos_y = 0;
        dir_x = 0; dir_y = 0;
        plane_x = 0; plane_y = 0;
        sprite_dist_lookup_result = 0;

        #10; rst = 0;
        #10;

        // Test 1: Sprite 2 units directly ahead
        // Q6.10: 2.0=2048, 4.0=4096 | Q2.14: 1.0=16384, 0.66=10813
        sprite_x = 16'd4096;  sprite_y = 16'd2048;
        pos_x    = 16'd2048;  pos_y    = 16'd2048;
        dir_x    = 16'd16384; dir_y    = 16'd0;
        plane_x  = 16'd0;     plane_y  = 16'd10813;
        start = 1; #10; start = 0;
        #10; sprite_dist_lookup_result = 10'd120; // 240/2
        #10; #10; #10;
        $display("T1 ahead 2u: hh=%0d hw=%0d sx=%0d ex=%0d dist=%0d",
            sprite_half_height, sprite_half_width,
            sprite_start_x, sprite_end_x, sprite_distance);
        #10;

        // Test 2: Sprite to the right, 1 unit
        sprite_x = 16'd2048;  sprite_y = 16'd3072;
        pos_x    = 16'd2048;  pos_y    = 16'd2048;
        dir_x    = 16'd16384; dir_y    = 16'd0;
        plane_x  = 16'd0;     plane_y  = 16'd10813;
        start = 1; #10; start = 0;
        #10; sprite_dist_lookup_result = 10'd240; // 240/1
        #10; #10; #10;
        $display("T2 right  1u: hh=%0d hw=%0d sx=%0d ex=%0d dist=%0d",
            sprite_half_height, sprite_half_width,
            sprite_start_x, sprite_end_x, sprite_distance);
        #10;

        // Test 3: Sprite far, 8 units ahead
        sprite_x = 16'd10240; sprite_y = 16'd2048;
        pos_x    = 16'd2048;  pos_y    = 16'd2048;
        dir_x    = 16'd16384; dir_y    = 16'd0;
        plane_x  = 16'd0;     plane_y  = 16'd10813;
        start = 1; #10; start = 0;
        #10; sprite_dist_lookup_result = 10'd30; // 240/8
        #10; #10; #10;
        $display("T3 far    8u: hh=%0d hw=%0d sx=%0d ex=%0d dist=%0d",
            sprite_half_height, sprite_half_width,
            sprite_start_x, sprite_end_x, sprite_distance);
        #10;

        // Test 4: Sprite very close, 0.5 units - expect clamping
        sprite_x = 16'd2560;  sprite_y = 16'd2048;
        pos_x    = 16'd2048;  pos_y    = 16'd2048;
        dir_x    = 16'd16384; dir_y    = 16'd0;
        plane_x  = 16'd0;     plane_y  = 16'd10813;
        start = 1; #10; start = 0;
        #10; sprite_dist_lookup_result = 10'd480; // 240/0.5
        #10; #10; #10;
        $display("T4 close 0.5u: hh=%0d hw=%0d sx=%0d ex=%0d dist=%0d",
            sprite_half_height, sprite_half_width,
            sprite_start_x, sprite_end_x, sprite_distance);

        #20;
        $display("All tests done.");
        $finish;
    end

endmodule