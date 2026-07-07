`timescale 1ns / 1ps
/// this testbench is to test out whether the rst signal is working correctly 
/// for both the write and read sides, basically u let 4 cycles of each go on when rst is low
/// giving ample time for it to make wfull and rempty as 0 and 1 then u change it
/// and see if it works as inteded

/// and it does work as intended


module tb_async_fifo;
    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg winc, rinc;
    reg [7:0] wdata;
    wire [7:0] rdata;
    wire wfull, rempty;
    
    async_fifo_top DUT(wclk, wrst_n, winc, wdata, wfull, rclk, rrst_n, rinc, rdata, rempty);
   
    initial begin
        wclk  = 0;  rclk   = 0;
        wrst_n = 0; rrst_n = 0;
        winc  = 0;  rinc   = 0;
        wdata = 8'h00;
    end
    
    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;
       
    initial begin
        repeat(4) @(posedge wclk);
        repeat(4) @(posedge rclk);     
        @(posedge wclk); #1; wrst_n=1;
        @(posedge rclk); #1; rrst_n=1;
        
        repeat(6) @(posedge rclk);
        
        if (wfull === 1'b0)
            $display("PASS - wfull=0 after reset");
        else
            $display("FAIL - wfull should be 0 after reset");
        if (rempty === 1'b1)
            $display("PASS - rempty=1 after reset");
        else
            $display("FAIL - rempty should be 1 after reset");

       $finish;
    end
    

    
    
    
    
    
    
endmodule 
