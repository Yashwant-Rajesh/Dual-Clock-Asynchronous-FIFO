`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2026 20:22:28
// Design Name: 
// Module Name: test_6
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
// When reader is faster than writer, FIFO drains and rempty correctly throttles the reader
// No data corruption - everything written comes out correctly
// Once writer adds more data, reader can resume

module test_6();
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

    // block 1 - slow writer, one item every 4 wclk cycles
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

        // write item 1, then pause
        @(posedge wclk); #1; winc=1; wdata=8'hA1;
        @(posedge wclk); #1; winc=0;
        repeat(20) @(posedge wclk);

        // write item 2, then pause
        @(posedge wclk); #1; winc=1; wdata=8'hB2;
        @(posedge wclk); #1; winc=0;
        repeat(20) @(posedge wclk);

        // write item 3, then pause
        @(posedge wclk); #1; winc=1; wdata=8'hC3;
        @(posedge wclk); #1; winc=0;
        repeat(20) @(posedge wclk);

        // write item 4
        @(posedge wclk); #1; winc=1; wdata=8'hD4;
        @(posedge wclk); #1; winc=0;
    end

    // block 2 - fast reader
    initial begin
        repeat(4) @(posedge wclk);
        repeat(4) @(posedge rclk);
        repeat(6) @(posedge rclk);    // reset settle
        repeat(2) @(posedge wclk);    // first write lands
        repeat(6) @(posedge rclk);    // wptr sync into read domain

        // read A1
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hA1) $display("PASS - read[0]=0x%h", rdata);
        else               $display("FAIL - read[0] got 0x%h expected 0xA1", rdata);

        // FIFO empty now - wait for rempty to settle
        repeat(8) @(posedge rclk);
        if (rempty===1'b1)
            $display("PASS - rempty asserted, reader throttled");
        else
            $display("FAIL - rempty should be high after draining");

        // spurious read
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
       // repeat(4) @(posedge rclk);    // short wait only
        if (rempty===1'b1)
            $display("PASS - rempty still high after spurious read");
        else
            $display("FAIL - rempty dropped after spurious read");

        // wait for B2 - total elapsed ~14 rclk since A1 read
        // block 1 gap = 20 wclk = 200ns, need ~14 rclk more
        repeat(12) @(posedge rclk);

        // read B2
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hB2) $display("PASS - read[1]=0x%h", rdata);
        else               $display("FAIL - read[1] got 0x%h expected 0xB2", rdata);

        // wait for C3
        repeat(14) @(posedge rclk);

        // read C3
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hC3) $display("PASS - read[2]=0x%h", rdata);
        else               $display("FAIL - read[2] got 0x%h expected 0xC3", rdata);

        // wait for D4
        repeat(14) @(posedge rclk);

        // read D4
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hD4) $display("PASS - read[3]=0x%h", rdata);
        else               $display("FAIL - read[3] got 0x%h expected 0xD4", rdata);

        repeat(6) @(posedge rclk);
        if (rempty===1'b1)
            $display("PASS - rempty high after all reads");
        else
            $display("FAIL - rempty should be high");

        $finish;
    end
endmodule
