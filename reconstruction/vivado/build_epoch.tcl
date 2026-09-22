set script_dir [file normalize [file dirname [info script]]]
set root [file normalize [file join $script_dir ".."]]

foreach required {F2_PART ODO_SEED ODO_THROUGHPUT} {
    if {![info exists ::env($required)] || $::env($required) eq ""} {
        error "Required environment variable $required is not set"
    }
}

set part $::env(F2_PART)
set seed $::env(ODO_SEED)
set throughput $::env(ODO_THROUGHPUT)
set upstream [file join $root "third_party" "odo-miner"]
set generated [file join $root "generated" "odo_${seed}.v"]
set out_dir [file join $root "build" "epoch-${seed}"]
file mkdir $out_dir

set keccak [file join $upstream "src" "verilog" "keccak800.v"]
set miner [file join $upstream "src" "verilog" "miner.v"]
foreach required_file [list $keccak $miner $generated] {
    if {![file exists $required_file]} {
        error "Missing required source: $required_file"
    }
}

set defs [list "THROUGHPUT=$throughput" "ODOKEY=$seed"]
read_verilog $keccak
read_verilog $generated
read_verilog -define $defs $miner
read_verilog [file join $root "rtl" "f2_odo_harness.v"]
read_xdc [file join $root "constraints" "415t.xdc"]

synth_design -top f2_odo_harness -part $part

if {[info exists ::env(F2_OSC_MHZ)] && $::env(F2_OSC_MHZ) ne ""} {
    set mhz [expr {double($::env(F2_OSC_MHZ))}]
    set period_ns [expr {1000.0 / $mhz}]
    create_clock -name osc_clk -period $period_ns [get_ports osc_clk]
}

opt_design
place_design
phys_opt_design
route_design

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
report_utilization -hierarchical -file [file join $out_dir "utilization.rpt"]
report_timing_summary -max_paths 20 -file [file join $out_dir "timing_summary.rpt"]
report_drc -file [file join $out_dir "drc.rpt"]
write_checkpoint -force [file join $out_dir "f2_odo_harness_${seed}_routed.dcp"]
write_bitstream -force [file join $out_dir "f2_odo_harness_${seed}.bit"]

puts "F2 OdoCrypt epoch harness build complete: [file join $out_dir f2_odo_harness_${seed}.bit]"
