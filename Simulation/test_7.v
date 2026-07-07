`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2026 20:47:57
// Design Name: 
// Module Name: test_7
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
// we are testing
//Asserting reset mid-operation clears both pointers correctly
//After reset, wfull=0 and rempty=1 - clean slate
//Fresh writes and reads work correctly after reset - design fully recovers

module test_7();

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

    always #5  wclk = ~wclk;   // keep same as other tests
    always #7  rclk = ~rclk;
    
    initial begin
        wclk=0; rclk=0;
        wrst_n=0; rrst_n=0;
        winc=0; rinc=0;
        wdata=8'h00;

        repeat(4) @(posedge wclk);
        repeat(4) @(posedge rclk);
        @(posedge wclk); #1; wrst_n=1;
        @(posedge rclk); #1; rrst_n=1;
        repeat(6) @(posedge rclk);
        
        @(posedge wclk); #1; winc=1; wdata=8'hA1;
        @(posedge wclk); #1; winc=1; wdata=8'hb1;
        @(posedge wclk); #1; winc=1; wdata=8'hc1;
        @(posedge wclk); #1; winc=1; wdata=8'hd1;
        @(posedge wclk); #1; winc=0;
        
        @(posedge wclk); #1; wrst_n=0;
        @(posedge rclk); #1; rrst_n=0;
        repeat(4) @(posedge wclk);
        repeat(4) @(posedge rclk);
        
        @(posedge wclk); #1; wrst_n=1;
        @(posedge rclk); #1; rrst_n=1;
        repeat(6) @(posedge wclk);
        repeat(6) @(posedge rclk);
        
        if (rempty===1'b1)
            $display("PASS - rempty high after reset");
        else
            $display("FAIL - rempty not high after reset");
        if (wfull===1'b0)
            $display("PASS - wfull low after reset");
        else
            $display("FAIL - wfull high after reset");
            
        @(posedge wclk); #1; winc=1; wdata=8'hA2;
        @(posedge wclk); #1; winc=1; wdata=8'hb2;
        @(posedge wclk); #1; winc=1; wdata=8'hc2;
        @(posedge wclk); #1; winc=0;
        
        repeat(6) @(posedge rclk);

        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=1;
        if (rdata===8'ha2) $display("PASS - read[0]=0x%h", rdata);
        else               $display("FAIL - read[0] got 0x%h expected 0xB2", rdata);
        @(posedge rclk); #1; rinc=1;
        if (rdata===8'hb2) $display("PASS - read[0]=0x%h", rdata);
        else               $display("FAIL - read[0] got 0x%h expected 0xB2", rdata);
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hc2) $display("PASS - read[0]=0x%h", rdata);
        else               $display("FAIL - read[0] got 0x%h expected 0xB2", rdata);
        repeat(4) @(posedge rclk);
        if (rempty===1'b1)
            $display("PASS - rempty high after reading all items");
        else
            $display("FAIL - rempty not high after reading all items");
        $finish;
     end
endmodule
