# From the Vivado Tcl Console: source {C:/path/to/repo/sim/run_branch_flush.tcl}
# Run a standalone XSim build in a new temporary directory.
namespace eval ::cpu_branch_test {
    proc run_tool {name args} {
        set command [auto_execok $name]
        if {$command eq "" && [info exists ::env(XILINX_VIVADO)]} {
            set filename $name
            if {$::tcl_platform(platform) eq "windows"} {append filename .bat}
            set command [auto_execok [file join $::env(XILINX_VIVADO) bin $filename]]
        }
        if {$command eq ""} {error "Cannot locate $name. Run this script inside Vivado."}
        puts [exec {*}$command {*}$args 2>@1]
    }

    proc run {repo} {
        set sources [lsort [glob -nocomplain [file join $repo rtl *.v]]]
        set bench [file join $repo tb cpu_branch_flush_tb.sv]
        if {![llength $sources] || ![file isfile $bench]} {
            error "Expected rtl/*.v and tb/cpu_branch_flush_tb.sv under $repo"
        }
        set token [file tempfile tempname]
        close $token
        set workdir "${tempname}-branch-flush"
        file mkdir $workdir
        file delete -- $tempname
        puts "XSim working directory: $workdir"
        set previous [pwd]
        set status [catch {
            cd $workdir
            run_tool xvlog -work work {*}$sources
            run_tool xvlog -sv -work work $bench
            run_tool xelab --timescale 1ns/1ps --snapshot branch_flush_snapshot work.cpu_branch_flush_tb
            run_tool xsim branch_flush_snapshot -R -log branch_flush_xsim.log
            set log [open branch_flush_xsim.log r]
            set transcript [read $log]
            close $log
            if {![regexp -line {^PASS cpu_branch_flush_tb[[:blank:]]*\r?$} $transcript]} {
                error "No PASS marker. Inspect $workdir/branch_flush_xsim.log"
            }
            puts "CPU branch test passed. Transcript: $workdir/branch_flush_xsim.log"
        } message options]
        cd $previous
        if {$status} {return -options $options $message}
    }
}

::cpu_branch_test::run [file dirname [file dirname [file normalize [info script]]]]
