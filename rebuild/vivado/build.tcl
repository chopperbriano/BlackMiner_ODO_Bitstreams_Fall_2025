# BlackMiner F2 OdoCrypt reconstruction - Vivado build skeleton
# Original known-good bitstreams report Vivado 2018.3.

set project_name blackminer_f2_odocrypt
set part_name xc7vx415tffg1157-1

create_project -force $project_name ./work -part $part_name
add_files ../rtl/fpgaminer_top.v

# Do not add guessed pin constraints.
# The validated/adapted BlackMiner 415t.xdc belongs here once imported.
# add_files -fileset constrs_1 ../constraints/415t.xdc

set_property top fpgaminer_top [current_fileset]
update_compile_order -fileset sources_1

synth_design -top fpgaminer_top -part $part_name
report_utilization -file utilization_synth.rpt
report_timing_summary -file timing_synth.rpt

# Implementation/bitstream generation remains disabled until real F2
# constraints and interfaces replace the stub ports.
