onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /soc_tb/soc_inst/cpu/clk
add wave -noupdate /soc_tb/soc_inst/cpu/core/current_state
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/acc
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/index
add wave -noupdate -radix unsigned /soc_tb/soc_inst/cpu/pc
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/pm_data
add wave -noupdate -divider Bus
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/av_address
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/av_byteenable
add wave -noupdate /soc_tb/soc_inst/cpu/av_read
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/av_readdata
add wave -noupdate /soc_tb/soc_inst/cpu/av_write
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/av_writedata
add wave -noupdate /soc_tb/soc_inst/cpu/av_waitrequest
add wave -noupdate -divider {Data memory}
add wave -noupdate -radix unsigned /soc_tb/soc_inst/cpu/data_ram/addr
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/data_ram/wr_data
add wave -noupdate /soc_tb/soc_inst/cpu/data_ram/wr
add wave -noupdate -radix hexadecimal /soc_tb/soc_inst/cpu/data_ram/rd_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3642483 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {3528041 ps} {3945171 ps}
