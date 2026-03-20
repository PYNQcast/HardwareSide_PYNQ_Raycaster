`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 11:51:30
// Design Name: 
// Module Name: dividor
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




//qutient is integer - to get fractional results need to shift dividend
module sequential_divider #(
    parameter WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    output reg  [WIDTH-1:0] quotient,
    output reg  [WIDTH-1:0] remainder,
    output reg  done
);
 
    reg [WIDTH-1:0] d;           // stored divisor
    reg [2*WIDTH-1:0] working;   // {remainder, quotient} shift register
    reg [4:0] count;             // bit counter (supports up to WIDTH=32)
    reg busy;
 
    wire [WIDTH:0] trial_sub = working[2*WIDTH-2:WIDTH-1] - {1'b0, d};
 
    always @(posedge clk) begin
        if (rst) begin
            busy <= 0;
            done <= 0;
        end
        else if (start) begin
            working <= {{WIDTH{1'b0}}, dividend};
            d <= divisor;
            count <= WIDTH;
            busy <= 1;
            done <= 0;
        end
        else if (busy) begin
            if (!trial_sub[WIDTH]) begin
                // Subtraction succeeded - shift in a 1
                working <= {trial_sub[WIDTH-1:0], working[WIDTH-2:0], 1'b1};
            end
            else begin
                // Subtraction failed - just shift in a 0
                working <= {working[2*WIDTH-2:0], 1'b0};
            end
 
            count <= count - 1;
 
            if (count == 1) begin
                busy <= 0;
                done <= 1;
                // Final results available next cycle from working reg,
                // but we can grab them directly here:
                if (!trial_sub[WIDTH])
                    quotient <= {working[WIDTH-2:0], 1'b1};
                else
                    quotient <= {working[WIDTH-2:0], 1'b0};
                    
                if (!trial_sub[WIDTH])
                    remainder <= trial_sub[WIDTH-1:0];
                else
                    remainder <= working[2*WIDTH-2:WIDTH-1];
            end
        end
        else begin
            done <= 0;
        end
    end
 
endmodule
