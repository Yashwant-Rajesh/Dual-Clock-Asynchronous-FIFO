`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2026 14:36:21
// Design Name: 
// Module Name: test_3
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
// we are testing out the following here
//rempty asserts exactly after all 8 items are read out
//A read attempted while rempty=1 is completely ignored - pointer doesn't move, rdata holds its last value
module test_3();

reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg winc, rinc;
    reg [7:0] wdata;
    wire [7:0] rdata;
    wire wfull, rempty;

    async_fifo_top DUT1 (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .rdata(rdata), .rempty(rempty)
    );
    
    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;
    
     initial begin
        // initialise all signals
        wclk=0; rclk=0;
        wrst_n=0; rrst_n=0;
        winc=0; rinc=0;
        wdata=8'h00;

        // hold reset
        repeat(4) @(posedge wclk);
        repeat(4) @(posedge rclk);

        // de-assert reset
        @(posedge wclk); #1; wrst_n=1;
        @(posedge rclk); #1; rrst_n=1;
        // let synchronizers settle
        repeat(6) @(posedge rclk);
        
        @(posedge wclk); #1; winc=1; wdata=8'hA1;
        @(posedge wclk); #1; winc=1; wdata=8'hB2;
        @(posedge wclk); #1; winc=1; wdata=8'hC3;
        @(posedge wclk); #1; winc=1; wdata=8'hD4;
        @(posedge wclk); #1; winc=1; wdata=8'hE5;
        @(posedge wclk); #1; winc=1; wdata=8'hF6;
        @(posedge wclk); #1; winc=1; wdata=8'hA7;
        @(posedge wclk); #1; winc=1; wdata=8'hB8;
        @(posedge wclk); #1; winc=0; 
        
        repeat(4) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        repeat(6) @(posedge rclk);
        if (rempty === 1'b1)
            $display("PASS - rempty asserted after reading all 8 elements");
        else
            $display("FAIL - rempty still low after 8 reads");
        //reading an empty fifo to check for the data and the rempty value    
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        repeat(6) @(posedge rclk);
        
        if (rempty === 1'b1)
            $display("PASS - rempty still high when trying to read an empty FIFO");
        else
            $display("FAIL - rempty low even though FIFO is empty");
    end

endmodule
