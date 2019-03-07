set project_dir    "./eseq_zybo_z7-20.prj"
set project_name   "eseq"
set project_target "xc7z020clg400-1"
set source_files { \
		       ./sources/bloch_point_gen.vhd \
		       ./sources/xorshift32.vhd \
		       ./sources/qbit_op.vhd \
		       ./sources/qbit.vhd \
		   }
set ipcore_files { \
		       ./ip/zybo_z7-20/conv_float_to_int32.xci \
		       ./ip/zybo_z7-20/conv_uint32_to_float.xci \
		       ./ip/zybo_z7-20/fadd_single.xci \
		       ./ip/zybo_z7-20/fdiv_single.xci \
		       ./ip/zybo_z7-20/fmul_single.xci \
		   }
set testbench_files { \
		       ./sources/bloch_point_gen_sim.vhd \
		       ./sources/xorshift32_sim.vhd \
		       ./sources/qbit_sim.vhd \
		   }

#set constraint_files {./zybo_z7_20_audio_test.xdc}

create_project -force $project_name $project_dir -part $project_target
add_files -norecurse $source_files
#add_files -fileset constrs_1 -norecurse $constraint_files
import_ip -files $ipcore_files
update_compile_order -fileset sources_1
set_property top qbit [current_fileset]
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $testbench_files
update_compile_order -fileset sim_1

set_property top qbit_sim [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

reset_project

#launch_runs synth_1 -jobs 4
#wait_on_run synth_1

#launch_runs impl_1 -jobs 4
#wait_on_run impl_1
#
#open_run impl_1
#report_utilization -file [file join $project_dir "project.rpt"]
#report_timing -file [file join $project_dir "project.rpt"] -append
#
#launch_runs impl_1 -to_step write_bitstream -jobs 4
#wait_on_run impl_1
#
#close_project
#
#quit
