# TCL File Generated by Component Editor 18.1
# Wed Apr 14 11:20:12 BST 2021
# DO NOT MODIFY


# 
# PraxosM "Praxos CPU" v1.0
#  2021.04.14.11:20:12
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module PraxosM
# 
set_module_property DESCRIPTION ""
set_module_property NAME PraxosM
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Praxos CPU"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL praxos_cpu
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file ../ip/praxos/praxos_cpu.vhd VHDL PATH praxos_cpu.vhd TOP_LEVEL_FILE
add_fileset_file ../ip/praxos/praxos_alu.vhd VHDL PATH praxos_alu.vhd
add_fileset_file ../ip/praxos/praxos_application_image.vhd VHDL PATH praxos_application_image.vhd
add_fileset_file ../ip/praxos/praxos_decode.vhd VHDL PATH praxos_decode.vhd
add_fileset_file ../ip/praxos/praxos_dm.vhd VHDL PATH praxos_dm.vhd
add_fileset_file ../ip/praxos/praxos_pm.vhd VHDL PATH praxos_pm.vhd

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL praxos_cpu
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file ../ip/praxos/praxos_cpu.vhd VHDL PATH praxos_cpu.vhd
add_fileset_file ../ip/praxos/praxos_alu.vhd VHDL PATH praxos_alu.vhd
add_fileset_file ../ip/praxos/praxos_application_image.vhd VHDL PATH praxos_application_image.vhd
add_fileset_file ../ip/praxos/praxos_decode.vhd VHDL PATH praxos_decode.vhd
add_fileset_file ../ip/praxos/praxos_dm.vhd VHDL PATH praxos_dm.vhd
add_fileset_file ../ip/praxos/praxos_pm.vhd VHDL PATH praxos_pm.vhd


# 
# parameters
# 
add_parameter DM_WIDTH INTEGER 8 ""
set_parameter_property DM_WIDTH DEFAULT_VALUE 8
set_parameter_property DM_WIDTH DISPLAY_NAME "Data memory address width[8..32]"
set_parameter_property DM_WIDTH WIDTH ""
set_parameter_property DM_WIDTH TYPE INTEGER
set_parameter_property DM_WIDTH UNITS BITS
set_parameter_property DM_WIDTH ALLOWED_RANGES 5:28
set_parameter_property DM_WIDTH DESCRIPTION ""
set_parameter_property DM_WIDTH HDL_PARAMETER true
add_parameter PM_WIDTH INTEGER 8
set_parameter_property PM_WIDTH DEFAULT_VALUE 8
set_parameter_property PM_WIDTH DISPLAY_NAME "Program memory address width[8..32]"
set_parameter_property PM_WIDTH TYPE INTEGER
set_parameter_property PM_WIDTH UNITS BITS
set_parameter_property PM_WIDTH ALLOWED_RANGES 8:32
set_parameter_property PM_WIDTH HDL_PARAMETER true
add_parameter IO_FLAG_WIDTH INTEGER 1
set_parameter_property IO_FLAG_WIDTH DEFAULT_VALUE 1
set_parameter_property IO_FLAG_WIDTH DISPLAY_NAME "IO flag width[1..32]"
set_parameter_property IO_FLAG_WIDTH TYPE INTEGER
set_parameter_property IO_FLAG_WIDTH UNITS BITS
set_parameter_property IO_FLAG_WIDTH ALLOWED_RANGES 1:32
set_parameter_property IO_FLAG_WIDTH HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1

# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset resetn reset_n Input 1


# 
# connection point pm
# 
add_interface pm avalon start
set_interface_property pm addressUnits SYMBOLS
set_interface_property pm associatedClock clock
set_interface_property pm associatedReset reset
set_interface_property pm bitsPerSymbol 8
set_interface_property pm burstOnBurstBoundariesOnly false
set_interface_property pm burstcountUnits WORDS
set_interface_property pm doStreamReads false
set_interface_property pm doStreamWrites false
set_interface_property pm holdTime 0
set_interface_property pm linewrapBursts false
set_interface_property pm maximumPendingReadTransactions 0
set_interface_property pm maximumPendingWriteTransactions 0
set_interface_property pm readLatency 0
set_interface_property pm readWaitTime 1
set_interface_property pm setupTime 0
set_interface_property pm timingUnits Cycles
set_interface_property pm writeWaitTime 0
set_interface_property pm ENABLED true
set_interface_property pm EXPORT_OF ""
set_interface_property pm PORT_NAME_MAP ""
set_interface_property pm CMSIS_SVD_VARIABLES ""
set_interface_property pm SVD_ADDRESS_GROUP ""

add_interface_port pm av_address address Output 32
add_interface_port pm av_readdata readdata Input 32
add_interface_port pm av_writedata writedata Output 32
add_interface_port pm av_byteenable byteenable Output 4
add_interface_port pm av_write write Output 1
add_interface_port pm av_read read Output 1
add_interface_port pm av_waitrequest waitrequest Input 1


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock clock
set_interface_property conduit_end associatedReset ""
set_interface_property conduit_end ENABLED true
set_interface_property conduit_end EXPORT_OF ""
set_interface_property conduit_end PORT_NAME_MAP ""
set_interface_property conduit_end CMSIS_SVD_VARIABLES ""
set_interface_property conduit_end SVD_ADDRESS_GROUP ""

add_interface_port conduit_end port_addr port_addr Output 16
add_interface_port conduit_end port_in port_in Input 32
add_interface_port conduit_end port_out port_out Output 32
add_interface_port conduit_end port_rd port_rd Output 1
add_interface_port conduit_end port_wr port_wr Output 1



