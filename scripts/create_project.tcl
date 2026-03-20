# create_project.tcl — Recreate the system integration Vivado project
#
# This creates the top-level project that instantiates:
#   - PS7 (ARM Cortex-A9)
#   - AXI BRAM Controller (shared player/map state)
#   - ray_caster IP (pre-packaged from raycaster_ip_development/)
#   - hdmi_480p_220hz IP (Digilent rgb2dvi + clocking)
#   - AXI GPIO (button inputs)
#
# The raycaster IP is already packaged (component.xml in the repo).
# If you modify the RTL, re-package first: scripts/package_ip.tcl
#
# Usage:
#   cd /path/to/pynq_raycaster
#   vivado -mode batch -source scripts/create_project.tcl

set repo_root [file normalize [file dirname [info script]]/..]
set build_dir ${repo_root}/build

# ─── Sanity checks ───────────────────────────────────────────
if {![file exists ${repo_root}/vivado-library-master/ip]} {
    puts "ERROR: vivado-library-master/ not found."
    puts "       Run: git submodule update --init"
    return -code error
}

set ip_component ${repo_root}/ray_caster/raycaster_block_dev/raycaster_ip_development/component.xml
if {![file exists ${ip_component}]} {
    puts "ERROR: Raycaster IP not packaged (component.xml missing)."
    puts "       Run: vivado -mode batch -source scripts/package_ip.tcl"
    return -code error
}

# ─── Clean previous build ────────────────────────────────────
if {[file exists ${build_dir}]} {
    file delete -force ${build_dir}
}

# ─── Create project ──────────────────────────────────────────
create_project ray_caster ${build_dir} -part xc7z020clg400-1 -force

# ─── Set IP repository paths ─────────────────────────────────
# Order matters — Vivado resolves IPs by scanning these directories:
#   1. raycaster_ip_development/   → ray_caster IP (component.xml)
#   2. ip_repos/                   → hdmi_480p_220hz IP
#   3. vivado-library-master/      → Digilent IPs (rgb2dvi, etc.)
#   4. .../sources_1/new/          → alternate packaging location
set_property ip_repo_paths [list \
    ${repo_root}/ray_caster/raycaster_block_dev/raycaster_ip_development \
    ${repo_root}/ray_caster/raycaster_block_dev/raycaster_ip_development/raycaster_ip_development.srcs/sources_1/new \
    ${repo_root}/ip_repos \
    ${repo_root}/vivado-library-master \
] [current_project]
update_ip_catalog

# ─── Import block design ─────────────────────────────────────
set bd_file ${repo_root}/ray_caster/ray_caster.srcs/sources_1/bd/design_1/design_1.bd
if {[file exists ${bd_file}]} {
    add_files -norecurse ${bd_file}
    open_bd_design ${bd_file}
    set wrapper [make_wrapper -files [get_files design_1.bd] -top]
    add_files -norecurse ${wrapper}
    set_property top design_1_wrapper [current_fileset]
} else {
    puts "ERROR: Block design not found at ${bd_file}"
    return -code error
}

# ─── Add constraints ─────────────────────────────────────────
set xdc_file ${repo_root}/ray_caster/ray_caster.srcs/constrs_1/new/constraint_pins.xdc
if {[file exists ${xdc_file}]} {
    add_files -fileset constrs_1 -norecurse ${xdc_file}
}

# ─── Add .coe file ───────────────────────────────────────────
set coe_file ${repo_root}/ray_caster/raycaster_block_dev/raycaster_ip_development/test_map.coe
if {[file exists ${coe_file}]} {
    add_files -norecurse ${coe_file}
}

# ─── Project settings ────────────────────────────────────────
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

puts "=========================================="
puts " Project created at: ${build_dir}"
puts ""
puts " Next steps:"
puts "   1. Open: vivado ${build_dir}/ray_caster.xpr"
puts "   2. Generate Bitstream"
puts "   3. Export Hardware (Include bitstream)"
puts "=========================================="
