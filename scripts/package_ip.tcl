# package_ip.tcl — Re-package the raycaster IP after modifying RTL
#
# Only needed if you EDIT the Verilog/SystemVerilog source files.
# If you just want to build the bitstream from the repo as-is,
# skip this — the committed component.xml already works.
#
# Usage:
#   cd /path/to/pynq_raycaster
#   vivado -mode batch -source scripts/package_ip.tcl

set repo_root [file normalize [file dirname [info script]]/..]
set ip_root   ${repo_root}/ray_caster/raycaster_block_dev/raycaster_ip_development
set src_dir   ${ip_root}/raycaster_ip_development.srcs/sources_1/new
set sim_dir   ${ip_root}/raycaster_ip_development.srcs/sim_1/new
set build_dir ${repo_root}/build/ip_packaging

if {[file exists ${build_dir}]} {
    file delete -force ${build_dir}
}

# ─── Create temporary project ────────────────────────────────
create_project raycaster_ip_dev ${build_dir} -part xc7z020clg400-1 -force

# ─── Add RTL sources ─────────────────────────────────────────
add_files -norecurse [glob ${src_dir}/*.v ${src_dir}/*.sv]
add_files -norecurse [glob ${src_dir}/*.mem]

# ─── Add LUT .mem files from generator directories ───────────
foreach lut_file [list \
    ${ip_root}/bar_height_lookup_gen_script/bar_height_lut.mem \
    ${ip_root}/reciprocal_lookup_gen_script/delta_lut.mem \
    ${ip_root}/gen_fine_lut/recip_fine.mem \
    ${ip_root}/cos_lookup_gen_script/cos_lut.hex \
] {
    if {[file exists ${lut_file}]} {
        add_files -norecurse ${lut_file}
    }
}

# ─── Add simulation sources ──────────────────────────────────
set sim_files [glob -nocomplain ${sim_dir}/*.v ${sim_dir}/*.sv ${sim_dir}/*.mem]
if {[llength $sim_files] > 0} {
    add_files -fileset sim_1 -norecurse ${sim_files}
}

# ─── Set top module ──────────────────────────────────────────
set_property top ray_caster [current_fileset]

# ─── Package IP (updates component.xml in-place) ─────────────
ipx::package_project -root_dir ${ip_root} -vendor xilinx.com -library user \
    -taxonomy /UserIP -import_files -set_current true -force

set core [ipx::current_core]
set_property name ray_caster $core
set_property version 1.0 $core
set_property display_name "DDA Raycaster Engine" $core
set_property description "Real-time DDA raycaster with AXI4-Stream HDMI output" $core

ipx::check_integrity $core
ipx::save_core $core

close_project

puts "============================================"
puts " IP re-packaged at: ${ip_root}/component.xml"
puts " Now run: vivado -mode batch -source scripts/create_project.tcl"
puts "============================================"
