`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 11:38:44
// Design Name: 
// Module Name: fifomem
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


module fifomem(
    input wclk,
    input rclk,
    input wren,
    input [2:0] waddr,
    input [2:0] raddr,
    input [7:0] wdata,
    output reg [7:0] rdata
    );
    
    reg [7:0] memory [0:7]; // basically creating 8 rows of data with each row being 8 bits long to hold data, that is the 'memory'
    
    always @(posedge wclk) begin
        if(wren)
           memory[waddr] <= wdata;
    end  
    always @(posedge rclk) begin
        rdata<=memory[raddr];
    end
    
endmodule
