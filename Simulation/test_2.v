`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2026 10:04:59
// Design Name: 
// Module Name: test_2
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

// we are testing out the following
//wfull asserts at the right time - exactly after 8 writes, not before, not after
//A write attempted while wfull=1 is completely ignored - data doesn't get written, pointer doesn't move

module test_2();

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
        
        // after 8 writes
        repeat(2) @(posedge wclk);
        if (wfull === 1'b1)
            $display("PASS - wfull asserted after 8 writes");
        else
            $display("FAIL - wfull should be high");
        // attempt 9th write
        @(posedge wclk); #1; winc=1; wdata=8'hFF;
        @(posedge wclk); #1; winc=0;
        repeat(2) @(posedge wclk);
        
        // wfull should still be high - pointer didn't move
        if (wfull === 1'b1)
            $display("PASS - wfull still high after ignored write");
        else
            $display("FAIL - wfull dropped, pointer may have corrupted");

        repeat(4) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        repeat(6) @(posedge wclk);     // wait for rptr to sync back into write domain
        if (wfull === 1'b0)
            $display("PASS - wfull de-asserted after read");
        else
            $display("FAIL - wfull still high after read");
   end
endmodule
