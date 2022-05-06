###############################################################################
# Clocks.
create_clock -period 15.625 -name clk [get_ports clk]

# Define clock latency.  Using 5.79ps/mm * 34mm = 0.2ns.
set_clock_latency -source -late 0.3 [get_clocks clk]
set_clock_latency -source -early 0.1 [get_clocks clk]

#Asynchronous I/O
set_false_path -from [get_ports {port_in0}] -to *
set_false_path -from * -to [get_ports {port_out[*] port_rd port_wr port_addr[*]}]
