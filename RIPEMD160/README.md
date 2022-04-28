指令
source /usr/cadence/cshrc

source /usr/cad/synopsys/CIC/synthesis.cshrc

ncverilog +access+r stage_1_tb.v stage_1_test.v

ncverilog +access+r stage_1_tb.v stage_1_test_syn.v
