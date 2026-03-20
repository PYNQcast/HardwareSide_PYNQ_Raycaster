`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 11:57:04
// Design Name: 
// Module Name: divider_tb
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


module divider_tb;
 
    parameter WIDTH = 26;
 
    reg clk;
    reg rst;
    reg start;
    reg [WIDTH-1:0] dividend;
    reg [WIDTH-1:0] divisor;
    wire [WIDTH-1:0] quotient;
    wire [WIDTH-1:0] remainder;
    wire done;
 
    sequential_divider #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done)
    );
 
    always #5 clk = ~clk;
 
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        dividend = 0;
        divisor = 0;
 
        #20;
        rst = 0;
        #10;
 
        // Test 1: 240 / 1.0 ? expect 240.0
        $display("--- Test 1: 240 / 1.0 ---");
        @(posedge clk);
        dividend <= 26'd245760;
        divisor <= 26'd1024;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 2: 240 / 2.0 ? expect 120.0
        $display("--- Test 2: 240 / 2.0 ---");
        @(posedge clk);
        dividend <= 26'd245760;
        divisor <= 26'd2048;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 3: 240 / 0.5 ? expect 480.0
        $display("--- Test 3: 240 / 0.5 ---");
        @(posedge clk);
        dividend <= 26'd245760;
        divisor <= 26'd512;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 4: 240 / 3.5 ? expect ~68.57
        $display("--- Test 4: 240 / 3.5 ---");
        @(posedge clk);
        dividend <= 26'd245760;
        divisor <= 26'd3584;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 5: 1.5 / 3.0 ? expect 0.5
        $display("--- Test 5: 1.5 / 3.0 (transform_x/transform_y) ---");
        @(posedge clk);
        dividend <= 26'd1572864;
        divisor <= 26'd3072;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 6: 2.0 / 4.0 ? expect 0.5
        $display("--- Test 6: 2.0 / 4.0 ---");
        @(posedge clk);
        dividend <= 26'd2097152;
        divisor <= 26'd4096;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 7: 240 / 0.25 ? expect 960.0
        $display("--- Test 7: 240 / 0.25 ---");
        @(posedge clk);
        dividend <= 26'd245760;
        divisor <= 26'd256;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        // Test 8: 240 / 10.0 ? expect 24.0
        $display("--- Test 8: 240 / 10.0 ---");
        @(posedge clk);
        dividend <= 26'd245760;
        divisor <= 26'd10240;
        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge done);
        @(posedge clk);
        $display("  quotient = %0d (Q6.10: %0d.%0d)  remainder = %0d",
            quotient, quotient >> 10, quotient & 10'h3FF, remainder);
 
        $display("--- All tests complete ---");
        $finish;
    end
 
endmodule