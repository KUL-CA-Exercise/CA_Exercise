set_driving_cell -lib_cell INVX0_RVT  [all_inputs]

set period_ns  100



set clock_uncertainty      0.1


create_clock -name clk  -period $period_ns [list "clk"]


set_clock_uncertainty      $clock_uncertainty     [get_clocks]

set half_cycle_delay [expr $period_ns/2]

#set_input_delay  $half_cycle_delay [ all_inputs ] -clock clk 
#set_output_delay $half_cycle_delay [ all_outputs]                             -clock clk



set_load 0.1 [all_outputs]



set dont_touch_network clk
set dont_touch_network arst_n
