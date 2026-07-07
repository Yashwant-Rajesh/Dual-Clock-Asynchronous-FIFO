`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 21:28:22
// Design Name: 
// Module Name: wptr_full
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


module wptr_full(
    input wclk,
    input wrst_n,
    input winc,
    input [3:0] wq2_rptr,
    output reg [3:0] wptr,
    output [2:0] waddr,
    output reg  wfull
    );
    
    reg [3:0] wbin;
    wire [3:0] wbinnext, wgraynext;
    wire wfull_val;
    
    assign wbinnext  = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;
    assign waddr     = wbin[2:0];
    
    assign wfull_val = (wgraynext == {~wq2_rptr[3:2], wq2_rptr[1:0]}); // this is the condition to check if the FIFO is full or not in GRAY CODE Encoding

    always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        wbin<=4'd0;
        wptr<=4'd0;
        wfull<=1'd0;
    end
    
    else begin
        wbin<=wbinnext;
        wptr<=wgraynext;
        wfull<=wfull_val;
    end
    
  end
        
endmodule
