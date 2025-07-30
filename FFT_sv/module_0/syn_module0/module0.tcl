#operation condition : BC / TC / WC
set min_cond "BC"
set max_cond "WC"
set used_vt  {"hvt" "svt" "lvt"}
set designName "sdf1"
set revName     "module0_0"
set outputName "${revName}"
set file_script  "module0.tcl"
set file_sdc_input "module0.sdc"
set file_hdl_list "module0.list"

source scripts/set_var.tcl
set file_script_bak [list $file_script $file_sdc_input]
source scripts/file_works.tcl
define_design_lib WORK -path $dir_out/work
source scripts/env.tcl

source $file_hdl_list
DATE_STAMP "start" $file_stamp

elaborate $designName

source scripts/condition.tcl
source $file_sdc_input
set_svf $file_svf
set_host_options -max_cores 6

check_design >> ${file_check_design}.pre
check_timing >> ${file_check_timing}.pre

compile_ultra -scan -gate_clock -no_autoungroup

DATE_STAMP "  end : synth of TOP" $file_stamp
source scripts/report.tcl
DATE_STAMP "end" $file_stamp

#exit

