`timescale 1ns / 1ps

// we are testing out three things
// Can we successfully write data into the FIFO
//Does the data come out in the correct order (FIFO, not LIFO)
//Do the flags behave correctly during the process (rempty drops after write, wfull stays low since we're not filling it up)
module test_1();
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

        // --- WRITE 3 VALUES ---
        @(posedge wclk); #1; winc=1; wdata=8'hA1;
        @(posedge wclk); #1; winc=1; wdata=8'hB2;
        @(posedge wclk); #1; winc=1; wdata=8'hC3;
        @(posedge wclk); #1; winc=0;

        // wait for wptr to cross into read domain
        repeat(6) @(posedge rclk);

        // --- READ BACK AND CHECK (one cycle after rinc for BRAM latency) ---
        @(posedge rclk); #1; rinc=1;          // request read 1
        @(posedge rclk); #1; rinc=1;          // data A1 appears, request read 2
        if (rdata===8'hA1) $display("PASS - got 0xA1");
        else               $display("FAIL - got 0x%h, expected 0xA1", rdata);

        @(posedge rclk); #1; rinc=1;          // data B2 appears, request read 3
        if (rdata===8'hB2) $display("PASS - got 0xB2");
        else               $display("FAIL - got 0x%h, expected 0xB2", rdata);

        @(posedge rclk); #1; rinc=0;          // data C3 appears, stop reading
        if (rdata===8'hC3) $display("PASS - got 0xC3");
        else               $display("FAIL - got 0x%h, expected 0xC3", rdata);

        // check rempty goes high again
        repeat(4) @(posedge rclk);
        if (rempty===1'b1) $display("PASS - rempty high after drain");
        else               $display("FAIL - rempty should be high");

        $finish;
    end
endmodule