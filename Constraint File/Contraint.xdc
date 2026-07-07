# wclk - 100 MHz (period 10ns, matches your #5 TB)
create_clock -period 10.000 -name wclk [get_ports wclk]

# rclk - ~71 MHz (period 14ns, matches your #7 TB)
create_clock -period 14.000 -name rclk [get_ports rclk]

# tell Vivado these are async clocks - don't try to time paths between them
set_clock_groups -asynchronous -group [get_clocks wclk] -group [get_clocks rclk]
