# HDMI TMDS pins
set_property PACKAGE_PIN L17 [get_ports TMDS_0_0_clk_n]
set_property PACKAGE_PIN L16 [get_ports TMDS_0_0_clk_p]
set_property PACKAGE_PIN K18 [get_ports {TMDS_0_0_data_n[0]}]
set_property PACKAGE_PIN K17 [get_ports {TMDS_0_0_data_p[0]}]
set_property PACKAGE_PIN J19 [get_ports {TMDS_0_0_data_n[1]}]
set_property PACKAGE_PIN K19 [get_ports {TMDS_0_0_data_p[1]}]
set_property PACKAGE_PIN H18 [get_ports {TMDS_0_0_data_n[2]}]
set_property PACKAGE_PIN J18 [get_ports {TMDS_0_0_data_p[2]}]

set_property IOSTANDARD TMDS_33 [get_ports TMDS_0_0_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports TMDS_0_0_clk_n]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_0_0_data_p[*]}]
set_property IOSTANDARD TMDS_33 [get_ports {TMDS_0_0_data_n[*]}]

# PYNQ-Z1 Buttons mapping for gpio_rtl_0_tri_i
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_i[0] }]
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_i[1] }]
set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_i[2] }]
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_i[3] }]