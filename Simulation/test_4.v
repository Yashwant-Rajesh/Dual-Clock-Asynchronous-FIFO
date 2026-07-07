`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2026 14:52:13
// Design Name: 
// Module Name: test_4
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
// we are testing out if
//FIFO works correctly when both reading and writing happen at the same time
//Data integrity is maintained - what goes in comes out correctly even with concurrent access
//wfull and rempty never wrongly assert when FIFO is partially filled and both sides are active

module test_4();

reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg winc, rinc;
    reg [7:0] wdata;
    wire [7:0] rdata;
    wire wfull, rempty;
    reg [7:0] expected [0:7];

    async_fifo_top DUT1 (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .rdata(rdata), .rempty(rempty)
    );
    
    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;
    
    initial begin
    // initialise signals
    wclk=0; rclk=0;
    wrst_n=0; rrst_n=0;
    winc=0; rinc=0;
    wdata=8'h00;

    // reset sequence
    repeat(4) @(posedge wclk);
    repeat(4) @(posedge rclk);
    @(posedge wclk); #1; wrst_n=1;
    @(posedge rclk); #1; rrst_n=1;
    repeat(6) @(posedge rclk);

    // pre-fill 4 items
    expected[0]=8'hA1; @(posedge wclk); #1; winc=1; wdata=8'hA1;
    expected[1]=8'hB2; @(posedge wclk); #1; winc=1; wdata=8'hB2;
    expected[2]=8'hC3; @(posedge wclk); #1; winc=1; wdata=8'hC3;
    expected[3]=8'hD4; @(posedge wclk); #1; winc=1; wdata=8'hD4;

    // keep writing - these overlap with reader reading pre-fill
    expected[4]=8'hE5; @(posedge wclk); #1; winc=1; wdata=8'hE5;
    expected[5]=8'hF6; @(posedge wclk); #1; winc=1; wdata=8'hF6;
    expected[6]=8'hA7; @(posedge wclk); #1; winc=1; wdata=8'hA7;
    expected[7]=8'hB8; @(posedge wclk); #1; winc=1; wdata=8'hB8;
    @(posedge wclk); #1; winc=0;
     end

        
    initial begin
    // mirror the exact same time block 1 takes to reach
    // the point where pre-fill is done and synced
    // reset time
    repeat(4) @(posedge wclk);
    repeat(4) @(posedge rclk);
    repeat(6) @(posedge rclk);  // sync settle after reset
    // pre-fill write time (4 wclk cycles)
    repeat(4) @(posedge wclk);
    // sync latency for wptr to reach read domain
    repeat(6) @(posedge rclk);

    // NOW block 1 is writing E5,F6,A7,B8
    // and we start reading A1,B2,C3,D4 at the same time
    // this is the simultaneous overlap




   @(posedge rclk); #1; rinc=1;       // request read 0
    @(posedge rclk); #1; rinc=1;       // rdata=A1 appears, request read 1

    // check read[0] immediately while rdata is still valid
    if (rdata===expected[0]) $display("PASS - read[0]=0x%h", rdata);
    else                     $display("FAIL - read[0] got 0x%h expected 0x%h", rdata, expected[0]);

    @(posedge rclk); #1; rinc=1;       // rdata=B2 appears, request read 2
    if (rdata===expected[1]) $display("PASS - read[1]=0x%h", rdata);
    else                     $display("FAIL - read[1] got 0x%h expected 0x%h", rdata, expected[1]);

    @(posedge rclk); #1; rinc=1;
    if (rdata===expected[2]) $display("PASS - read[2]=0x%h", rdata);
    else                     $display("FAIL - read[2] got 0x%h expected 0x%h", rdata, expected[2]);

    @(posedge rclk); #1; rinc=1;
    if (rdata===expected[3]) $display("PASS - read[3]=0x%h", rdata);
    else                     $display("FAIL - read[3] got 0x%h expected 0x%h", rdata, expected[3]);

    @(posedge rclk); #1; rinc=1;
    if (rdata===expected[4]) $display("PASS - read[4]=0x%h", rdata);
    else                     $display("FAIL - read[4] got 0x%h expected 0x%h", rdata, expected[4]);

    @(posedge rclk); #1; rinc=0;       // stop reading after read 5 request
    if (rdata===expected[5]) $display("PASS - read[5]=0x%h", rdata);
    else                     $display("FAIL - read[5] got 0x%h expected 0x%h", rdata, expected[5]);

    // now pause and check wfull - 6 items read, 2 remain, should not be full
    repeat(4) @(posedge wclk);         // wait for rptr to sync into write domain
    if (wfull===1'b0)
        $display("PASS - wfull low during concurrent access");
    else
        $display("FAIL - wfull wrongly asserted");

    if (rempty===1'b0)
        $display("PASS - rempty low, 2 items still in FIFO");
    else
        $display("FAIL - rempty wrongly asserted");

    // read remaining 2 items
    @(posedge rclk); #1; rinc=1;
    @(posedge rclk); #1; rinc=1;
    if (rdata===expected[6]) $display("PASS - read[6]=0x%h", rdata);
    else                     $display("FAIL - read[6] got 0x%h expected 0x%h", rdata, expected[6]);

    @(posedge rclk); #1; rinc=0;
    if (rdata===expected[7]) $display("PASS - read[7]=0x%h", rdata);
    else                     $display("FAIL - read[7] got 0x%h expected 0x%h", rdata, expected[7]);

    // final check
    repeat(4) @(posedge rclk);
    if (rempty===1'b1) $display("PASS - rempty high after all reads");
    else               $display("FAIL - rempty should be high");

    $finish;
end

endmodule
