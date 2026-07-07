`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 11:56:30
// Design Name: 
// Module Name: async_fifo_top
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


module async_fifo_top(
    input wclk,
    input wrst_n,
    input winc,
    input [7:0] wdata,
    output wfull,
    input rclk,
    input rrst_n,
    input rinc,
    output [7:0] rdata,
    output rempty
    );
    
    
    wire [3:0] rptr, wptr, wq2_rptr, rq2_wptr;
    wire wren;
    wire [2:0] waddr, raddr;
    
    assign wren = (~wfull) & winc;

    wptr_full write (wclk, wrst_n, winc, wq2_rptr, wptr, waddr, wfull);
    rptr_empty read (rclk, rrst_n, rinc, rq2_wptr, rptr, raddr, rempty);
    
    Synchronizer sync_w2r (rclk, rrst_n, wptr, rq2_wptr);
    Synchronizer sync_r2w (wclk, wrst_n, rptr, wq2_rptr);
    
    fifomem mem (wclk, rclk, wren, waddr, raddr, wdata, rdata);
endmodule
