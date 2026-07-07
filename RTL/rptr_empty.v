`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 11:27:33
// Design Name: 
// Module Name: rptr_empty
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


module rptr_empty(
    input rclk,
    input rrst_n,
    input rinc,
    input [3:0] rq2_wptr,
    output reg [3:0] rptr,
    output [2:0] raddr,
    output reg rempty
    );
    reg [3:0] rbin;
    wire [3:0] rbinnext, rgraynext;
    wire rempty_val;
    
    assign rbinnext = rbin + (~rempty & rinc);
    assign rgraynext = (rbinnext>>1) ^ rbinnext;
    assign raddr = rbin [2:0];
    
    assign rempty_val = (rgraynext == rq2_wptr);
    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n) begin
            rempty<=1'd1;
            rptr<=4'd0;
            rbin<=4'd0;
        end
        
        else begin
            rempty<=rempty_val;
            rbin<=rbinnext;
            rptr<=rgraynext;
       end
   end
endmodule
