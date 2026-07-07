`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2026 20:02:12
// Design Name: 
// Module Name: test_5
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

// we are testing writer faster than reader
//When writer is faster than reader, FIFO fills up and wfull correctly throttles the writer
//No data is lost or corrupted - everything written before wfull asserted comes out correctly
//Once reader catches up and drains some slots, writer can resume

module test_5();
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

    // block 1 - fast writer
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

        // write all 8 back to back at full wclk speed
        @(posedge wclk); #1; winc=1; wdata=8'hA1;
        @(posedge wclk); #1; winc=1; wdata=8'hB2;
        @(posedge wclk); #1; winc=1; wdata=8'hC3;
        @(posedge wclk); #1; winc=1; wdata=8'hD4;
        @(posedge wclk); #1; winc=1; wdata=8'hE5;
        @(posedge wclk); #1; winc=1; wdata=8'hF6;
        @(posedge wclk); #1; winc=1; wdata=8'hAC;
        @(posedge wclk); #1; winc=1; wdata=8'hBF;
        @(posedge wclk); #1; winc=0;

        // check wfull - FIFO should be full now
        repeat(2) @(posedge wclk);
        if (wfull===1'b1)
            $display("PASS - wfull asserted, writer correctly throttled");
        else
            $display("FAIL - wfull should be high after 8 fast writes");
    end

    // block 2 - slow reader (one read every 4 rclk cycles)
    initial begin
        // mirror reset timing
        repeat(4) @(posedge wclk);
        repeat(4) @(posedge rclk);
        repeat(6) @(posedge rclk);   // reset settle
        repeat(8) @(posedge wclk);   // wait for all 8 writes
        repeat(6) @(posedge rclk);   // wptr sync into read domain

        // read slowly - check data integrity and wfull de-asserts
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;   // A1 appears
        if (rdata===8'hA1) $display("PASS - read[0]=0x%h", rdata);
        else               $display("FAIL - read[0] got 0x%h expected 0xA1", rdata);
        repeat(4) @(posedge wclk);      // rptr syncs back, wfull should drop
        if (wfull===1'b0)
            $display("PASS - wfull de-asserted after reader freed a slot");
        else
            $display("FAIL - wfull should drop after read");

        repeat(3) @(posedge rclk);      // slow read gap
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;   // B2 appears
        if (rdata===8'hB2) $display("PASS - read[1]=0x%h", rdata);
        else               $display("FAIL - read[1] got 0x%h expected 0xB2", rdata);

        repeat(3) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;   // C3 appears
        if (rdata===8'hC3) $display("PASS - read[2]=0x%h", rdata);
        else               $display("FAIL - read[2] got 0x%h expected 0xC3", rdata);

        repeat(3) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hD4) $display("PASS - read[3]=0x%h", rdata);
        else               $display("FAIL - read[3] got 0x%h expected 0xD4", rdata);

        repeat(3) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hE5) $display("PASS - read[4]=0x%h", rdata);
        else               $display("FAIL - read[4] got 0x%h expected 0xE5", rdata);

        repeat(3) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hF6) $display("PASS - read[5]=0x%h", rdata);
        else               $display("FAIL - read[5] got 0x%h expected 0xF6", rdata);

        repeat(3) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hAC) $display("PASS - read[6]=0x%h", rdata);
        else               $display("FAIL - read[6] got 0x%h expected 0xAC", rdata);

        repeat(3) @(posedge rclk);
        @(posedge rclk); #1; rinc=1;
        @(posedge rclk); #1; rinc=0;
        if (rdata===8'hBF) $display("PASS - read[7]=0x%h", rdata);
        else               $display("FAIL - read[7] got 0x%h expected 0xBF", rdata);

        // final check
        repeat(4) @(posedge rclk);
        if (rempty===1'b1)
            $display("PASS - rempty high after draining all items");
        else
            $display("FAIL - rempty should be high");

        $finish;
    end
endmodule