###########
# general #
###########
clean:
	\rm -rf INCA_libs

sim:
	mkdir -p $(srcPath)/work/sim

all: without_delays run

without_delays: compile run
without_delays_gui: compile rg
with_delays: compile_postsynth run_postsynth
with_delays_gui: compile_postsynth run_postsynth_gui
gui: cg rg

###########
# compile #
###########
compile: clean
	reset; \
	cd $(srcPath)/work; \
	vcs -full64 -sverilog -timescale=1ns/10ps +notimingchecks +lint=TFIPC-L -debug_all +delay_mode_zero \
	-f $(srcPath)/lst/files_verilog_$(varName).txt  \
	-l $(srcPath)/work/sim/$(varName).log \
	-o $(srcPath)/work/sim/simv_$(varName)
	
compile_postsynth: clean
	reset; \
	cd $(srcPath)/work; \
	vcs -full64 -sverilog -debug_all +noIncrComp -sdfretain +sdfverbose  +neg_tchk +define+NTC +define+RECREM \
	-f $(srcPath)/lst/files_verilog_$(varName)_pnr_power_vcs.txt  \
	-o $(srcPath)/work/sim/simv_$(varName)_$(mode) \
	-sdf max:test_top.dut:$(sdfPath)/AV_LH_mode_lt_cbest_hold.sdf +csdf+precompile \
	-timescale=1ns/10ps +lint=TFIPC-L -l $(srcPath)/work/sim/top_synth.log 
	


nc_gui: 
	reset; \
	ncverilog +sv -f files_verilog.f  \
	+nc64bit +nctimescale+1ns/10ps +access+rwc -ALLOWREDEFINITION \
	-linedebug +gui &
	
nc: 
	reset; \
	ncverilog +sv -f files_verilog.f  \
	+nc64bit +nctimescale+1ns/10ps +access+rwc -ALLOWREDEFINITION \
