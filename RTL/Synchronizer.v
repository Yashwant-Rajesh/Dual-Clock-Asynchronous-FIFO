`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 21:21:36
// Design Name: 
// Module Name: Synchronizer
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


module Synchronizer(
    input clk,
    input rst_n,
    input [3:0] din,
    output reg [3:0] dout
    );
    
    reg [3:0] q1;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            q1<=4'd0;
            dout<=4'd0;
        end  
        
        else begin
            q1<=din;
            dout<=q1;
        end
    end  
endmodule
