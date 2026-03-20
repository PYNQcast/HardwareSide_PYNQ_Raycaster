//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Thu Mar  5 15:32:22 2026
//Host        : Lucca-Laptop running 64-bit major release  (build 9200)
//Command     : generate_target bd_hdmi.bd
//Design      : bd_hdmi
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd_hdmi,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_hdmi,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=8,numReposBlks=8,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=1,da_board_cnt=3,da_clkrst_cnt=3,da_ps7_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "bd_hdmi.hwdef" *) 
module bd_hdmi
   (TMDS_0_clk_n,
    TMDS_0_clk_p,
    TMDS_0_data_n,
    TMDS_0_data_p,
    clk_in,
    clk_out1_1,
    locked,
    peripheral_aresetn,
    reset,
    underflow_0,
    video_in_0_tdata,
    video_in_0_tlast,
    video_in_0_tready,
    video_in_0_tuser,
    video_in_0_tvalid,
    video_locked_led);
  (* X_INTERFACE_INFO = "digilentinc.com:interface:tmds:1.0 TMDS_0 CLK_N" *) output TMDS_0_clk_n;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:tmds:1.0 TMDS_0 CLK_P" *) output TMDS_0_clk_p;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:tmds:1.0 TMDS_0 DATA_N" *) output [2:0]TMDS_0_data_n;
  (* X_INTERFACE_INFO = "digilentinc.com:interface:tmds:1.0 TMDS_0 DATA_P" *) output [2:0]TMDS_0_data_p;
  input clk_in;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_OUT1_1 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_OUT1_1, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 25178571, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk_out1_1;
  output locked;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.PERIPHERAL_ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.PERIPHERAL_ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output [0:0]peripheral_aresetn;
  input reset;
  output underflow_0;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 video_in_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME video_in_0, FREQ_HZ 25178571, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 3, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1" *) input [23:0]video_in_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 video_in_0 TLAST" *) input video_in_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 video_in_0 TREADY" *) output video_in_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 video_in_0 TUSER" *) input video_in_0_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 video_in_0 TVALID" *) input video_in_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.VIDEO_LOCKED_LED DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.VIDEO_LOCKED_LED, LAYERED_METADATA undef" *) output [0:0]video_locked_led;

  wire clk_in_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_clk_out2;
  wire clk_wiz_0_locked;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire [0:0]proc_sys_reset_1_peripheral_reset;
  wire reset_1;
  wire rgb2dvi_0_TMDS_CLK_N;
  wire rgb2dvi_0_TMDS_CLK_P;
  wire [2:0]rgb2dvi_0_TMDS_DATA_N;
  wire [2:0]rgb2dvi_0_TMDS_DATA_P;
  wire v_axi4s_vid_out_0_locked;
  wire v_axi4s_vid_out_0_underflow;
  wire v_axi4s_vid_out_0_vid_io_out_ACTIVE_VIDEO;
  wire [23:0]v_axi4s_vid_out_0_vid_io_out_DATA;
  wire v_axi4s_vid_out_0_vid_io_out_HSYNC;
  wire v_axi4s_vid_out_0_vid_io_out_VSYNC;
  wire v_axi4s_vid_out_0_vtg_ce;
  wire v_tc_0_vtiming_out_ACTIVE_VIDEO;
  wire v_tc_0_vtiming_out_HBLANK;
  wire v_tc_0_vtiming_out_HSYNC;
  wire v_tc_0_vtiming_out_VBLANK;
  wire v_tc_0_vtiming_out_VSYNC;
  wire [23:0]video_in_0_1_TDATA;
  wire video_in_0_1_TLAST;
  wire video_in_0_1_TREADY;
  wire video_in_0_1_TUSER;
  wire video_in_0_1_TVALID;
  wire [0:0]xlconstant_0_dout;
  wire [0:0]xlconstant_1_dout;

  assign TMDS_0_clk_n = rgb2dvi_0_TMDS_CLK_N;
  assign TMDS_0_clk_p = rgb2dvi_0_TMDS_CLK_P;
  assign TMDS_0_data_n[2:0] = rgb2dvi_0_TMDS_DATA_N;
  assign TMDS_0_data_p[2:0] = rgb2dvi_0_TMDS_DATA_P;
  assign clk_in_1 = clk_in;
  assign clk_out1_1 = clk_wiz_0_clk_out1;
  assign locked = clk_wiz_0_locked;
  assign peripheral_aresetn[0] = proc_sys_reset_0_peripheral_aresetn;
  assign reset_1 = reset;
  assign underflow_0 = v_axi4s_vid_out_0_underflow;
  assign video_in_0_1_TDATA = video_in_0_tdata[23:0];
  assign video_in_0_1_TLAST = video_in_0_tlast;
  assign video_in_0_1_TUSER = video_in_0_tuser;
  assign video_in_0_1_TVALID = video_in_0_tvalid;
  assign video_in_0_tready = video_in_0_1_TREADY;
  assign video_locked_led[0] = v_axi4s_vid_out_0_locked;
  bd_hdmi_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(clk_in_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_0_clk_out2),
        .locked(clk_wiz_0_locked),
        .reset(1'b0));
  bd_hdmi_proc_sys_reset_0_0 proc_sys_reset_0
       (.aux_reset_in(1'b1),
        .dcm_locked(clk_wiz_0_locked),
        .ext_reset_in(reset_1),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .slowest_sync_clk(clk_wiz_0_clk_out1));
  bd_hdmi_proc_sys_reset_1_0 proc_sys_reset_1
       (.aux_reset_in(1'b1),
        .dcm_locked(clk_wiz_0_locked),
        .ext_reset_in(reset_1),
        .mb_debug_sys_rst(1'b0),
        .peripheral_reset(proc_sys_reset_1_peripheral_reset),
        .slowest_sync_clk(clk_wiz_0_clk_out2));
  bd_hdmi_rgb2dvi_0_0 rgb2dvi_0
       (.PixelClk(clk_wiz_0_clk_out1),
        .SerialClk(clk_wiz_0_clk_out2),
        .TMDS_Clk_n(rgb2dvi_0_TMDS_CLK_N),
        .TMDS_Clk_p(rgb2dvi_0_TMDS_CLK_P),
        .TMDS_Data_n(rgb2dvi_0_TMDS_DATA_N),
        .TMDS_Data_p(rgb2dvi_0_TMDS_DATA_P),
        .aRst(proc_sys_reset_1_peripheral_reset),
        .vid_pData(v_axi4s_vid_out_0_vid_io_out_DATA),
        .vid_pHSync(v_axi4s_vid_out_0_vid_io_out_HSYNC),
        .vid_pVDE(v_axi4s_vid_out_0_vid_io_out_ACTIVE_VIDEO),
        .vid_pVSync(v_axi4s_vid_out_0_vid_io_out_VSYNC));
  bd_hdmi_v_axi4s_vid_out_0_0 v_axi4s_vid_out_0
       (.aclk(clk_wiz_0_clk_out1),
        .aclken(xlconstant_0_dout),
        .aresetn(proc_sys_reset_0_peripheral_aresetn),
        .fid(xlconstant_1_dout),
        .locked(v_axi4s_vid_out_0_locked),
        .s_axis_video_tdata(video_in_0_1_TDATA),
        .s_axis_video_tlast(video_in_0_1_TLAST),
        .s_axis_video_tready(video_in_0_1_TREADY),
        .s_axis_video_tuser(video_in_0_1_TUSER),
        .s_axis_video_tvalid(video_in_0_1_TVALID),
        .underflow(v_axi4s_vid_out_0_underflow),
        .vid_active_video(v_axi4s_vid_out_0_vid_io_out_ACTIVE_VIDEO),
        .vid_data(v_axi4s_vid_out_0_vid_io_out_DATA),
        .vid_hsync(v_axi4s_vid_out_0_vid_io_out_HSYNC),
        .vid_io_out_ce(xlconstant_0_dout),
        .vid_vsync(v_axi4s_vid_out_0_vid_io_out_VSYNC),
        .vtg_active_video(v_tc_0_vtiming_out_ACTIVE_VIDEO),
        .vtg_ce(v_axi4s_vid_out_0_vtg_ce),
        .vtg_field_id(1'b0),
        .vtg_hblank(v_tc_0_vtiming_out_HBLANK),
        .vtg_hsync(v_tc_0_vtiming_out_HSYNC),
        .vtg_vblank(v_tc_0_vtiming_out_VBLANK),
        .vtg_vsync(v_tc_0_vtiming_out_VSYNC));
  bd_hdmi_v_tc_0_0 v_tc_0
       (.active_video_out(v_tc_0_vtiming_out_ACTIVE_VIDEO),
        .clk(clk_wiz_0_clk_out1),
        .clken(xlconstant_0_dout),
        .gen_clken(v_axi4s_vid_out_0_vtg_ce),
        .hblank_out(v_tc_0_vtiming_out_HBLANK),
        .hsync_out(v_tc_0_vtiming_out_HSYNC),
        .resetn(proc_sys_reset_0_peripheral_aresetn),
        .sof_state(xlconstant_1_dout),
        .vblank_out(v_tc_0_vtiming_out_VBLANK),
        .vsync_out(v_tc_0_vtiming_out_VSYNC));
  bd_hdmi_xlconstant_1_0 xlconstant_0
       (.dout(xlconstant_1_dout));
  bd_hdmi_xlconstant_0_1 xlconstant_1
       (.dout(xlconstant_0_dout));
endmodule
