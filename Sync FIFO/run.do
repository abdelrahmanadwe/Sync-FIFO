vlib work
vlog -f fifo_files.list +cover -covercells +define+SIM
vsim -voptargs=+acc work.fifo_top -cover
add wave /fifo_top/fifoif/*
add wave -position insertpoint \
/fifo_top/DUT/mem \
/fifo_top/DUT/wr_ptr \
/fifo_top/DUT/rd_ptr \
/fifo_top/DUT/count
coverage save fifo.ucdb -onexit
run -all
# vcover report fifo.ucdb -details -annotate -all -output coverage_rpt.txt