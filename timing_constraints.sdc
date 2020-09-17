derive_clock_uncertainty

create_clock -name sYs-clock -period 20.000 [get_ports {i_Clock}]

set_false_path -from [get_ports {i_Echo i_Reset_n}]

set_false_path -to [get_ports {o_Sev_seg_1[*] o_Sev_seg_2[*] o_Sev_seg_3[*] o_Trigger}]

