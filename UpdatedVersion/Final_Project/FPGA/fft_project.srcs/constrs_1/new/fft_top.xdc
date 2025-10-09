# SYS_CLK (300 MHz differential clock from carrier card)
set_property PACKAGE_PIN AC8 [get_ports clk_p]
set_property PACKAGE_PIN AC7 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports {clk_p clk_n}]


# RESET
set_property PACKAGE_PIN AA13 [get_ports {rst}] ; # HP_DP_18_P
set_property IOSTANDARD LVCMOS18 [get_ports {rst}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rst]



