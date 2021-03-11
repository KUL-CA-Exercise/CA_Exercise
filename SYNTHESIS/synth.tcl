set search_path       [concat $search_path ${synopsys_root}/libraries/syn]
set search_path       [concat $search_path ${synopsys_root}/dw/sim_ver]
set search_path       [concat $search_path /users/micas/micas/design/generic/synopsys_32nm/SAED32_EDK/lib/stdcell_rvt/db_ccs/]
set search_path       [concat $search_path /users/micas/micas/design/generic/synopsys_32nm/SAED32_EDK/lib/sram/db_ccs/]


#Set technology library, which you want you design to be mapped in

#set target_library    [list tcbn28hpcbwp35p140tt1v25c_ccs.db]
#set link_library      [list tcbn28hpcbwp35p140tt1v25c_ccs.db dw_foundation.sldb ]

#set target_library    [list ]
#set link_library      [list  dw_foundation.sldb ]
#dw_minpower.sldb

#dw_minpower.sldb
set target_library    [list saed32sram_tt1p05v25c.db saed32rvt_tt1p05v25c.db ]
set link_library      [list saed32sram_tt1p05v25c.db saed32rvt_tt1p05v25c.db dw_foundation.sldb ]
set synthetic_library [list dw_foundation.sldb]
set symbol_library    [list class.sdb]
set view_log_file     "./run_view.log"
set command_log_file  "./run_command.log"
set filename_log_file "./run_filename.log"

sh rm -rf WORK
sh mkdir WORK
define_design_lib work -path WORK
set search_path [concat "../src" $search_path]

set top_des_name cpu


source "./designlist.tcl"

# analyze verilog files
foreach verilog_file ${verilog_files} {
  set dc_shell_status [analyze -f verilog -library work "../RTL/${verilog_file}.v"]
  if { $dc_shell_status == 0 } {
    exit
  }
}

# elaborate design
elaborate -library work $top_des_name

current_design $top_des_name



read_sdc design_constraints.sdc -echo


#write -hierarchy -f ddc -output "./ddc/top_dig.ddcg"

#uniquify
check_design
check_timing

# constraint design for library: tcbn90lphphvttc0d7_ccsi
set_operating_conditions -library "saed32rvt_tt1p05v25c"  "tt1p05v25c"
set_operating_conditions -library "saed32sram_tt1p05v25c" "tt1p05v25c"

#set_wire_load_mode "segmented"

current_design $top_des_name
link
set_max_area 0
set_max_dynamic_power 0
#set_clock_gating_style -num_stages 3


#compile_ultra -no_autoungroup -no_seq_output_inversion -no_boundary_optimization -gate_clock
#set_ungroup top_core true
compile_ultra -no_autoungroup -no_seq_output_inversion  -gate_clock


report_resources -hierarchy -minpower


set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "A-Z a-z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "A-Z a-z 0-9 _" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule


check_design

## save ddc file
#write -hierarchy -f ddc -output "./ddc/${top_des_name}.ddc"
#
## write reports
set power_preserve_rtl_hier_names  true



#foreach_in_collection des_name [get_designs] {
  #current_design $des_name
#}
redirect "./rep/${current_design}.area"  { report_area -hierarchy -designware}
redirect "./rep/${current_design}.tim"   { report_timing }
redirect "./rep/${current_design}.power" { report_power -analysis_effort high -net -cell -hier -verbose }

#redirect "./rep/${current_design}.datapath_gating" {report_datapath_gating}
#redirect "./rep/${current_design}.dw_power" {analyze_dw_power}
#
## write gate level verilog file
#
current_design $top_des_name
#change_names -rule verilog -hierarchy
write -hierarchy -f verilog -output "./gate/${top_des_name}.v"
#write -hierarchy -f verilog -output "./../BACKEND/DESIGN_IN/NETLIST/${top_des_name}_ps.v"
#write -hierarchy -f verilog -output "./../NETLISTS/${top_des_name}_ps.v"
#write_sdc -nosplit  ../BACKEND/DESIGN_IN/${top_des_name}_synthesis.sdc
write_sdf  "./sdf/$top_des_name.sdf"
#write_sdf  ./../netlist/top_dig_ps.sdf
#
exit

