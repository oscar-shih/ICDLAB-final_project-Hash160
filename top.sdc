###################################################################

# Created by write_sdc on Sun Jun  5 17:00:41 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c
set_max_fanout 6 [current_design]
set_max_area 0
set_load -pin_load 1 [get_ports o_valid]
set_load -pin_load 1 [get_ports {o_answer[15]}]
set_load -pin_load 1 [get_ports {o_answer[14]}]
set_load -pin_load 1 [get_ports {o_answer[13]}]
set_load -pin_load 1 [get_ports {o_answer[12]}]
set_load -pin_load 1 [get_ports {o_answer[11]}]
set_load -pin_load 1 [get_ports {o_answer[10]}]
set_load -pin_load 1 [get_ports {o_answer[9]}]
set_load -pin_load 1 [get_ports {o_answer[8]}]
set_load -pin_load 1 [get_ports {o_answer[7]}]
set_load -pin_load 1 [get_ports {o_answer[6]}]
set_load -pin_load 1 [get_ports {o_answer[5]}]
set_load -pin_load 1 [get_ports {o_answer[4]}]
set_load -pin_load 1 [get_ports {o_answer[3]}]
set_load -pin_load 1 [get_ports {o_answer[2]}]
set_load -pin_load 1 [get_ports {o_answer[1]}]
set_load -pin_load 1 [get_ports {o_answer[0]}]
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_latency 0.5  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  -max 1  [get_ports clk]
set_input_delay -clock clk  -max 1  [get_ports rst_n]
set_input_delay -clock clk  -max 1  [get_ports i_valid]
set_input_delay -clock clk  -max 1  [get_ports {i_text[7]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[6]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[5]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[4]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[3]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[2]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[1]}]
set_input_delay -clock clk  -max 1  [get_ports {i_text[0]}]
set_output_delay -clock clk  -min 0.5  [get_ports o_valid]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[15]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[14]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[13]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[12]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[11]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[10]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[9]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[8]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[7]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[6]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[5]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[4]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[3]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[2]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[1]}]
set_output_delay -clock clk  -min 0.5  [get_ports {o_answer[0]}]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst_n]
set_drive 1  [get_ports i_valid]
set_drive 1  [get_ports {i_text[7]}]
set_drive 1  [get_ports {i_text[6]}]
set_drive 1  [get_ports {i_text[5]}]
set_drive 1  [get_ports {i_text[4]}]
set_drive 1  [get_ports {i_text[3]}]
set_drive 1  [get_ports {i_text[2]}]
set_drive 1  [get_ports {i_text[1]}]
set_drive 1  [get_ports {i_text[0]}]
