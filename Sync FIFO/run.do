# vlib work
# vlog -f fifo_files.list +cover -covercells +define+SIM
# vsim -voptargs=+acc work.fifo_top -cover
# add wave /fifo_top/fifoif/*
# add wave -position insertpoint \
# /fifo_top/DUT/mem \
# /fifo_top/DUT/wr_ptr \
# /fifo_top/DUT/rd_ptr \
# /fifo_top/DUT/count
# coverage save fifo.ucdb -onexit
# run -all
# # vcover report fifo.ucdb -details -annotate -all -output coverage_rpt.txt

# ==========================================================================
#                           CONFIGURATION
# ==========================================================================
# 1. File List containing all RTL & TB files (paths inside)
set FILE_LIST "fifo_files.list"

# 2. The Top Module Name (The one containing run_test())
set TOP_MODULE "fifo_top"

# ==========================================================================
#                              COMPILATION
# ==========================================================================
vlib work

# Compile using the file list (-f)
# +cover: Enable code coverage
# -covercells: Enable coverage for library cells (optional)
vlog -f $FILE_LIST +cover -covercells


# ==========================================================================
#                          ARGUMENT PARSING
# ==========================================================================
# Argument 1: UVM Test Name (Class Name)
# Example: do run.do alsu_fifo_test
if {$argc > 0} {
    set UVM_TEST_NAME $1
}

# Argument 2: Action (debug or report)
# Example: do run.do alsu_fifo_test report
set action "debug"
if {$argc > 1} {
    set action $2
}

# ==========================================================================
#                             SIMULATION
# ==========================================================================
echo "Starting Simulation for: $TOP_MODULE"

# Launch simulation with optimization args and coverage
vsim -voptargs=+acc work.$TOP_MODULE -cover


# --- Waveform Setup (Debug Mode Only) ---
if {$action == "debug"} {
    # Clear previous waves
    delete wave *
    
    # Add your standard waves here 
    # You can also use 'do wave.do' if you have a saved wave file
    add wave /fifo_top/fifoif/*
    
    # Example: Adding assertions
    add wave -position insertpoint \
    /fifo_top/DUT/mem \
    /fifo_top/DUT/wr_ptr \
    /fifo_top/DUT/rd_ptr \
    /fifo_top/DUT/count
}

# Run Simulation
run -all


# ==========================================================================
#                        REPORTING & EXIT
# ==========================================================================

# Save Coverage Database (Name it after the Test Case)
coverage save ${TOP_MODULE}.ucdb

# If the user requested "report" mode
if {$action == "report"} {
    echo "Generating Coverage Report..."
    
    # Generate the text report
    vcover report ${TOP_MODULE}.ucdb -details -all -output coverage_rpt.txt
    
    echo "Report Generated: coverage_rpt.txt"
    echo "Exiting Simulation..."
    
    # Quit simulation to finish the batch process
    quit -sim
} else {
    echo "Simulation finished. Waveform is ready for debugging."
}