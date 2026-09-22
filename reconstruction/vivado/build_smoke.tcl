set script_dir [file normalize [file dirname [info script]]]
set root [file normalize [file join $script_dir ".."]]
set out_dir [file join $root "build" "smoke"]
file mkdir $out_dir

if {[info exists ::env(F2_PART)]} {
    set part $::env(F2_PART)
} else {
    set part "xc7vx415tffg1157-2"
}

read_verilog [file join $root "rtl" "f2_smoke_top.v"]
read_xdc [file join $root "constraints" "415t.xdc"]
synth_design -top f2_smoke_top -part $part

if {[info exists ::env(F2_OSC_MHZ)] && $::env(F2_OSC_MHZ) ne ""} {
    set mhz [expr {double($::env(F2_OSC_MHZ))}]
    set period_ns [expr {1000.0 / $mhz}]
    create_clock -name osc_clk -period $period_ns [get_ports osc_clk]
}

opt_design
place_design
route_design

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
report_utilization -file [file join $out_dir "utilization.rpt"]
report_timing_summary -file [file join $out_dir "timing_summary.rpt"]
write_checkpoint -force [file join $out_dir "f2_smoke_routed.dcp"]
write_bitstream -force [file join $out_dir "f2_smoke.bit"]

puts "F2 smoke build complete: [file join $out_dir f2_smoke.bit]"
