# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "COORD_FRAC_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "COORD_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAP_HEIGHT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAP_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "angle_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "dinf_bits" -parent ${Page_0}
  ipgui::add_param $IPINST -name "dwidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "fov" -parent ${Page_0}


}

proc update_PARAM_VALUE.COORD_FRAC_BITS { PARAM_VALUE.COORD_FRAC_BITS } {
	# Procedure called to update COORD_FRAC_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COORD_FRAC_BITS { PARAM_VALUE.COORD_FRAC_BITS } {
	# Procedure called to validate COORD_FRAC_BITS
	return true
}

proc update_PARAM_VALUE.COORD_SIZE { PARAM_VALUE.COORD_SIZE } {
	# Procedure called to update COORD_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COORD_SIZE { PARAM_VALUE.COORD_SIZE } {
	# Procedure called to validate COORD_SIZE
	return true
}

proc update_PARAM_VALUE.MAP_HEIGHT { PARAM_VALUE.MAP_HEIGHT } {
	# Procedure called to update MAP_HEIGHT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAP_HEIGHT { PARAM_VALUE.MAP_HEIGHT } {
	# Procedure called to validate MAP_HEIGHT
	return true
}

proc update_PARAM_VALUE.MAP_WIDTH { PARAM_VALUE.MAP_WIDTH } {
	# Procedure called to update MAP_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAP_WIDTH { PARAM_VALUE.MAP_WIDTH } {
	# Procedure called to validate MAP_WIDTH
	return true
}

proc update_PARAM_VALUE.angle_width { PARAM_VALUE.angle_width } {
	# Procedure called to update angle_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.angle_width { PARAM_VALUE.angle_width } {
	# Procedure called to validate angle_width
	return true
}

proc update_PARAM_VALUE.dinf_bits { PARAM_VALUE.dinf_bits } {
	# Procedure called to update dinf_bits when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.dinf_bits { PARAM_VALUE.dinf_bits } {
	# Procedure called to validate dinf_bits
	return true
}

proc update_PARAM_VALUE.dwidth { PARAM_VALUE.dwidth } {
	# Procedure called to update dwidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.dwidth { PARAM_VALUE.dwidth } {
	# Procedure called to validate dwidth
	return true
}

proc update_PARAM_VALUE.fov { PARAM_VALUE.fov } {
	# Procedure called to update fov when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.fov { PARAM_VALUE.fov } {
	# Procedure called to validate fov
	return true
}


proc update_MODELPARAM_VALUE.MAP_WIDTH { MODELPARAM_VALUE.MAP_WIDTH PARAM_VALUE.MAP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAP_WIDTH}] ${MODELPARAM_VALUE.MAP_WIDTH}
}

proc update_MODELPARAM_VALUE.MAP_HEIGHT { MODELPARAM_VALUE.MAP_HEIGHT PARAM_VALUE.MAP_HEIGHT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAP_HEIGHT}] ${MODELPARAM_VALUE.MAP_HEIGHT}
}

proc update_MODELPARAM_VALUE.COORD_SIZE { MODELPARAM_VALUE.COORD_SIZE PARAM_VALUE.COORD_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COORD_SIZE}] ${MODELPARAM_VALUE.COORD_SIZE}
}

proc update_MODELPARAM_VALUE.COORD_FRAC_BITS { MODELPARAM_VALUE.COORD_FRAC_BITS PARAM_VALUE.COORD_FRAC_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COORD_FRAC_BITS}] ${MODELPARAM_VALUE.COORD_FRAC_BITS}
}

proc update_MODELPARAM_VALUE.angle_width { MODELPARAM_VALUE.angle_width PARAM_VALUE.angle_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.angle_width}] ${MODELPARAM_VALUE.angle_width}
}

proc update_MODELPARAM_VALUE.dinf_bits { MODELPARAM_VALUE.dinf_bits PARAM_VALUE.dinf_bits } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.dinf_bits}] ${MODELPARAM_VALUE.dinf_bits}
}

proc update_MODELPARAM_VALUE.dwidth { MODELPARAM_VALUE.dwidth PARAM_VALUE.dwidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.dwidth}] ${MODELPARAM_VALUE.dwidth}
}

proc update_MODELPARAM_VALUE.fov { MODELPARAM_VALUE.fov PARAM_VALUE.fov } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.fov}] ${MODELPARAM_VALUE.fov}
}

