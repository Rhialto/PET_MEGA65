#set_property port_width 1 [get_debug_ports u_ila_0/trig_out]
#connect_debug_port u_ila_0/trig_out [get_nets [list trig_out_u_ila_1]]



# create_debug_port u_ila_0 trig_out
# set_property port_width 1 [get_debug_ports u_ila_0/trig_out]
# create_debug_port u_ila_1 trig_in
# connect_debug_port u_ila_1/trig_in u_ila_0/trig_out
# connect_debug_port u_ila_0/trig_out u_ila_1/trig_in
# connect_debug_port u_ila_0/trig_out [get_nets [list trig_out_u_ila_1]]





create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_framework/i_clk_m2m/hr_clk_o]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[0]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[1]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[2]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[3]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[4]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[5]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[6]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[7]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[8]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[9]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[10]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[11]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[12]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[13]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[14]} {i_framework/i_qnice_wrapper/QNICE_SOC/cpu/PC[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 28 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {CORE/qnice_dev_addr_i[0]} {CORE/qnice_dev_addr_i[1]} {CORE/qnice_dev_addr_i[2]} {CORE/qnice_dev_addr_i[3]} {CORE/qnice_dev_addr_i[4]} {CORE/qnice_dev_addr_i[5]} {CORE/qnice_dev_addr_i[6]} {CORE/qnice_dev_addr_i[7]} {CORE/qnice_dev_addr_i[8]} {CORE/qnice_dev_addr_i[9]} {CORE/qnice_dev_addr_i[10]} {CORE/qnice_dev_addr_i[11]} {CORE/qnice_dev_addr_i[12]} {CORE/qnice_dev_addr_i[13]} {CORE/qnice_dev_addr_i[14]} {CORE/qnice_dev_addr_i[15]} {CORE/qnice_dev_addr_i[16]} {CORE/qnice_dev_addr_i[17]} {CORE/qnice_dev_addr_i[18]} {CORE/qnice_dev_addr_i[19]} {CORE/qnice_dev_addr_i[20]} {CORE/qnice_dev_addr_i[21]} {CORE/qnice_dev_addr_i[22]} {CORE/qnice_dev_addr_i[23]} {CORE/qnice_dev_addr_i[24]} {CORE/qnice_dev_addr_i[25]} {CORE/qnice_dev_addr_i[26]} {CORE/qnice_dev_addr_i[27]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {CORE/qnice_dev_id_i[0]} {CORE/qnice_dev_id_i[1]} {CORE/qnice_dev_id_i[2]} {CORE/qnice_dev_id_i[3]} {CORE/qnice_dev_id_i[4]} {CORE/qnice_dev_id_i[5]} {CORE/qnice_dev_id_i[6]} {CORE/qnice_dev_id_i[7]} {CORE/qnice_dev_id_i[8]} {CORE/qnice_dev_id_i[9]} {CORE/qnice_dev_id_i[10]} {CORE/qnice_dev_id_i[11]} {CORE/qnice_dev_id_i[12]} {CORE/qnice_dev_id_i[13]} {CORE/qnice_dev_id_i[14]} {CORE/qnice_dev_id_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_read_pos[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_read_pos[1]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_read_pos[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 3 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_write_pos[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_write_pos[1]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_write_pos[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 8 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[1]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[2]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[3]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[4]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[5]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[6]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_burstcount_o[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_byteenable_o[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_byteenable_o[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[1]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[2]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[3]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[4]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[5]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[6]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[7]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[8]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[9]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[10]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[11]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[12]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[13]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[14]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_byteenable[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[1]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[2]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[3]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[4]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[5]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[6]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_burstcount[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 2 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/state[0]} {i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 8 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_framework/hr_core_burstcount_i[0]} {i_framework/hr_core_burstcount_i[1]} {i_framework/hr_core_burstcount_i[2]} {i_framework/hr_core_burstcount_i[3]} {i_framework/hr_core_burstcount_i[4]} {i_framework/hr_core_burstcount_i[5]} {i_framework/hr_core_burstcount_i[6]} {i_framework/hr_core_burstcount_i[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 2 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_framework/hr_byteenable[0]} {i_framework/hr_byteenable[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 32 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_framework/hr_core_address_i[0]} {i_framework/hr_core_address_i[1]} {i_framework/hr_core_address_i[2]} {i_framework/hr_core_address_i[3]} {i_framework/hr_core_address_i[4]} {i_framework/hr_core_address_i[5]} {i_framework/hr_core_address_i[6]} {i_framework/hr_core_address_i[7]} {i_framework/hr_core_address_i[8]} {i_framework/hr_core_address_i[9]} {i_framework/hr_core_address_i[10]} {i_framework/hr_core_address_i[11]} {i_framework/hr_core_address_i[12]} {i_framework/hr_core_address_i[13]} {i_framework/hr_core_address_i[14]} {i_framework/hr_core_address_i[15]} {i_framework/hr_core_address_i[16]} {i_framework/hr_core_address_i[17]} {i_framework/hr_core_address_i[18]} {i_framework/hr_core_address_i[19]} {i_framework/hr_core_address_i[20]} {i_framework/hr_core_address_i[21]} {i_framework/hr_core_address_i[22]} {i_framework/hr_core_address_i[23]} {i_framework/hr_core_address_i[24]} {i_framework/hr_core_address_i[25]} {i_framework/hr_core_address_i[26]} {i_framework/hr_core_address_i[27]} {i_framework/hr_core_address_i[28]} {i_framework/hr_core_address_i[29]} {i_framework/hr_core_address_i[30]} {i_framework/hr_core_address_i[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_framework/hr_address[0]} {i_framework/hr_address[1]} {i_framework/hr_address[2]} {i_framework/hr_address[3]} {i_framework/hr_address[4]} {i_framework/hr_address[5]} {i_framework/hr_address[6]} {i_framework/hr_address[7]} {i_framework/hr_address[8]} {i_framework/hr_address[9]} {i_framework/hr_address[10]} {i_framework/hr_address[11]} {i_framework/hr_address[12]} {i_framework/hr_address[13]} {i_framework/hr_address[14]} {i_framework/hr_address[15]} {i_framework/hr_address[16]} {i_framework/hr_address[17]} {i_framework/hr_address[18]} {i_framework/hr_address[19]} {i_framework/hr_address[20]} {i_framework/hr_address[21]} {i_framework/hr_address[22]} {i_framework/hr_address[23]} {i_framework/hr_address[24]} {i_framework/hr_address[25]} {i_framework/hr_address[26]} {i_framework/hr_address[27]} {i_framework/hr_address[28]} {i_framework/hr_address[29]} {i_framework/hr_address[30]} {i_framework/hr_address[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 2 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_framework/hr_core_byteenable_i[0]} {i_framework/hr_core_byteenable_i[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 16 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {i_framework/hr_core_readdata_o[0]} {i_framework/hr_core_readdata_o[1]} {i_framework/hr_core_readdata_o[2]} {i_framework/hr_core_readdata_o[3]} {i_framework/hr_core_readdata_o[4]} {i_framework/hr_core_readdata_o[5]} {i_framework/hr_core_readdata_o[6]} {i_framework/hr_core_readdata_o[7]} {i_framework/hr_core_readdata_o[8]} {i_framework/hr_core_readdata_o[9]} {i_framework/hr_core_readdata_o[10]} {i_framework/hr_core_readdata_o[11]} {i_framework/hr_core_readdata_o[12]} {i_framework/hr_core_readdata_o[13]} {i_framework/hr_core_readdata_o[14]} {i_framework/hr_core_readdata_o[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 16 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {i_framework/hr_readdata[0]} {i_framework/hr_readdata[1]} {i_framework/hr_readdata[2]} {i_framework/hr_readdata[3]} {i_framework/hr_readdata[4]} {i_framework/hr_readdata[5]} {i_framework/hr_readdata[6]} {i_framework/hr_readdata[7]} {i_framework/hr_readdata[8]} {i_framework/hr_readdata[9]} {i_framework/hr_readdata[10]} {i_framework/hr_readdata[11]} {i_framework/hr_readdata[12]} {i_framework/hr_readdata[13]} {i_framework/hr_readdata[14]} {i_framework/hr_readdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 16 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {i_framework/hr_writedata[0]} {i_framework/hr_writedata[1]} {i_framework/hr_writedata[2]} {i_framework/hr_writedata[3]} {i_framework/hr_writedata[4]} {i_framework/hr_writedata[5]} {i_framework/hr_writedata[6]} {i_framework/hr_writedata[7]} {i_framework/hr_writedata[8]} {i_framework/hr_writedata[9]} {i_framework/hr_writedata[10]} {i_framework/hr_writedata[11]} {i_framework/hr_writedata[12]} {i_framework/hr_writedata[13]} {i_framework/hr_writedata[14]} {i_framework/hr_writedata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 16 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {i_framework/hr_core_writedata_i[0]} {i_framework/hr_core_writedata_i[1]} {i_framework/hr_core_writedata_i[2]} {i_framework/hr_core_writedata_i[3]} {i_framework/hr_core_writedata_i[4]} {i_framework/hr_core_writedata_i[5]} {i_framework/hr_core_writedata_i[6]} {i_framework/hr_core_writedata_i[7]} {i_framework/hr_core_writedata_i[8]} {i_framework/hr_core_writedata_i[9]} {i_framework/hr_core_writedata_i[10]} {i_framework/hr_core_writedata_i[11]} {i_framework/hr_core_writedata_i[12]} {i_framework/hr_core_writedata_i[13]} {i_framework/hr_core_writedata_i[14]} {i_framework/hr_core_writedata_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 8 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {i_framework/hr_burstcount[0]} {i_framework/hr_burstcount[1]} {i_framework/hr_burstcount[2]} {i_framework/hr_burstcount[3]} {i_framework/hr_burstcount[4]} {i_framework/hr_burstcount[5]} {i_framework/hr_burstcount[6]} {i_framework/hr_burstcount[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 4 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {i_framework/i_hyperram/hyperram_ctrl_inst/state[0]} {i_framework/i_hyperram/hyperram_ctrl_inst/state[1]} {i_framework/i_hyperram/hyperram_ctrl_inst/state[2]} {i_framework/i_hyperram/hyperram_ctrl_inst/state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_framework/i_hyperram/hyperram_ctrl_inst/avm_read_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_framework/i_hyperram/hyperram_ctrl_inst/avm_waitrequest_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_framework/i_hyperram/hyperram_rx_inst/ctrl_dq_ie]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_framework/i_hyperram/hyperram_ctrl_inst/hb_dq_ie_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_framework/i_hyperram/hyperram_ctrl_inst/hb_read_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_framework/hr_core_read_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list CORE/hr_core_read_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list CORE/hr_core_readdatavalid_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list i_framework/hr_core_readdatavalid_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list hr_core_waitrequest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list CORE/hr_core_waitrequest_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list i_framework/hr_core_waitrequest_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list i_framework/hr_core_write_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list CORE/hr_core_write_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list i_framework/hr_dig_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list i_framework/hr_dig_readdatavalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list i_framework/hr_dig_waitrequest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list i_framework/hr_dig_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list CORE/hr_disk0_readdatavalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list CORE/hr_disk0_waitrequest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list i_framework/hr_qnice_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list i_framework/hr_qnice_readdatavalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list i_framework/hr_qnice_waitrequest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list i_framework/hr_qnice_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list i_framework/hr_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list i_framework/hr_readdatavalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list i_framework/hr_rst_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list i_framework/hr_waitrequest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list i_framework/hr_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 1 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_read_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 1 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list i_framework/i_qnice_wrapper/i_qnice2hyperram/m_avm_read_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 1 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list CORE/i_qnice2hyperram_d1/m_avm_read_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe53]
set_property port_width 1 [get_debug_ports u_ila_0/probe53]
connect_debug_port u_ila_0/probe53 [get_nets [list CORE/i_qnice2hyperram_d0/m_avm_read_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe54]
set_property port_width 1 [get_debug_ports u_ila_0/probe54]
connect_debug_port u_ila_0/probe54 [get_nets [list CORE/i_qnice2hyperram_d1/m_avm_readdatavalid_d]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe55]
set_property port_width 1 [get_debug_ports u_ila_0/probe55]
connect_debug_port u_ila_0/probe55 [get_nets [list CORE/i_qnice2hyperram_d0/m_avm_readdatavalid_d]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe56]
set_property port_width 1 [get_debug_ports u_ila_0/probe56]
connect_debug_port u_ila_0/probe56 [get_nets [list i_framework/i_qnice_wrapper/i_qnice2hyperram/m_avm_readdatavalid_d]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe57]
set_property port_width 1 [get_debug_ports u_ila_0/probe57]
connect_debug_port u_ila_0/probe57 [get_nets [list CORE/i_qnice2hyperram_d1/m_avm_readdatavalid_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe58]
set_property port_width 1 [get_debug_ports u_ila_0/probe58]
connect_debug_port u_ila_0/probe58 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_readdatavalid_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe59]
set_property port_width 1 [get_debug_ports u_ila_0/probe59]
connect_debug_port u_ila_0/probe59 [get_nets [list i_framework/i_qnice_wrapper/i_qnice2hyperram/m_avm_readdatavalid_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe60]
set_property port_width 1 [get_debug_ports u_ila_0/probe60]
connect_debug_port u_ila_0/probe60 [get_nets [list CORE/i_qnice2hyperram_d0/m_avm_readdatavalid_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe61]
set_property port_width 1 [get_debug_ports u_ila_0/probe61]
connect_debug_port u_ila_0/probe61 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_waitrequest_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe62]
set_property port_width 1 [get_debug_ports u_ila_0/probe62]
connect_debug_port u_ila_0/probe62 [get_nets [list i_framework/i_qnice_wrapper/i_qnice2hyperram/m_avm_waitrequest_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe63]
set_property port_width 1 [get_debug_ports u_ila_0/probe63]
connect_debug_port u_ila_0/probe63 [get_nets [list CORE/i_qnice2hyperram_d1/m_avm_waitrequest_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe64]
set_property port_width 1 [get_debug_ports u_ila_0/probe64]
connect_debug_port u_ila_0/probe64 [get_nets [list CORE/i_qnice2hyperram_d0/m_avm_waitrequest_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe65]
set_property port_width 1 [get_debug_ports u_ila_0/probe65]
connect_debug_port u_ila_0/probe65 [get_nets [list CORE/i_qnice2hyperram_d1/m_avm_write_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe66]
set_property port_width 1 [get_debug_ports u_ila_0/probe66]
connect_debug_port u_ila_0/probe66 [get_nets [list i_framework/i_qnice_wrapper/i_qnice2hyperram/m_avm_write_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe67]
set_property port_width 1 [get_debug_ports u_ila_0/probe67]
connect_debug_port u_ila_0/probe67 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/m_avm_write_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe68]
set_property port_width 1 [get_debug_ports u_ila_0/probe68]
connect_debug_port u_ila_0/probe68 [get_nets [list CORE/i_qnice2hyperram_d0/m_avm_write_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe69]
set_property port_width 1 [get_debug_ports u_ila_0/probe69]
connect_debug_port u_ila_0/probe69 [get_nets [list i_framework/main_qnice_reset_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe70]
set_property port_width 1 [get_debug_ports u_ila_0/probe70]
connect_debug_port u_ila_0/probe70 [get_nets [list i_framework/main_reset_core_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe71]
set_property port_width 1 [get_debug_ports u_ila_0/probe71]
connect_debug_port u_ila_0/probe71 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe72]
set_property port_width 1 [get_debug_ports u_ila_0/probe72]
connect_debug_port u_ila_0/probe72 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe73]
set_property port_width 1 [get_debug_ports u_ila_0/probe73]
connect_debug_port u_ila_0/probe73 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe74]
set_property port_width 1 [get_debug_ports u_ila_0/probe74]
connect_debug_port u_ila_0/probe74 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_3]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe75]
set_property port_width 1 [get_debug_ports u_ila_0/probe75]
connect_debug_port u_ila_0/probe75 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_4]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe76]
set_property port_width 1 [get_debug_ports u_ila_0/probe76]
connect_debug_port u_ila_0/probe76 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_5]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe77]
set_property port_width 1 [get_debug_ports u_ila_0/probe77]
connect_debug_port u_ila_0/probe77 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_6]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe78]
set_property port_width 1 [get_debug_ports u_ila_0/probe78]
connect_debug_port u_ila_0/probe78 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_7]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe79]
set_property port_width 1 [get_debug_ports u_ila_0/probe79]
connect_debug_port u_ila_0/probe79 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_8]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe80]
set_property port_width 1 [get_debug_ports u_ila_0/probe80]
connect_debug_port u_ila_0/probe80 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_9]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe81]
set_property port_width 1 [get_debug_ports u_ila_0/probe81]
connect_debug_port u_ila_0/probe81 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_10]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe82]
set_property port_width 1 [get_debug_ports u_ila_0/probe82]
connect_debug_port u_ila_0/probe82 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_11]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe83]
set_property port_width 1 [get_debug_ports u_ila_0/probe83]
connect_debug_port u_ila_0/probe83 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_12]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe84]
set_property port_width 1 [get_debug_ports u_ila_0/probe84]
connect_debug_port u_ila_0/probe84 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_13]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe85]
set_property port_width 1 [get_debug_ports u_ila_0/probe85]
connect_debug_port u_ila_0/probe85 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_14]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe86]
set_property port_width 1 [get_debug_ports u_ila_0/probe86]
connect_debug_port u_ila_0/probe86 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_15]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe87]
set_property port_width 1 [get_debug_ports u_ila_0/probe87]
connect_debug_port u_ila_0/probe87 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_16]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe88]
set_property port_width 1 [get_debug_ports u_ila_0/probe88]
connect_debug_port u_ila_0/probe88 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_17]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe89]
set_property port_width 1 [get_debug_ports u_ila_0/probe89]
connect_debug_port u_ila_0/probe89 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_18]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe90]
set_property port_width 1 [get_debug_ports u_ila_0/probe90]
connect_debug_port u_ila_0/probe90 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_19]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe91]
set_property port_width 1 [get_debug_ports u_ila_0/probe91]
connect_debug_port u_ila_0/probe91 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_20]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe92]
set_property port_width 1 [get_debug_ports u_ila_0/probe92]
connect_debug_port u_ila_0/probe92 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_21]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe93]
set_property port_width 1 [get_debug_ports u_ila_0/probe93]
connect_debug_port u_ila_0/probe93 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_22]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe94]
set_property port_width 1 [get_debug_ports u_ila_0/probe94]
connect_debug_port u_ila_0/probe94 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/n_0_23]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe95]
set_property port_width 1 [get_debug_ports u_ila_0/probe95]
connect_debug_port u_ila_0/probe95 [get_nets [list CORE/qnice_dev_ce_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe96]
set_property port_width 1 [get_debug_ports u_ila_0/probe96]
connect_debug_port u_ila_0/probe96 [get_nets [list CORE/qnice_dev_wait_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe97]
set_property port_width 1 [get_debug_ports u_ila_0/probe97]
connect_debug_port u_ila_0/probe97 [get_nets [list CORE/qnice_dev_we_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe98]
set_property port_width 1 [get_debug_ports u_ila_0/probe98]
connect_debug_port u_ila_0/probe98 [get_nets [list CORE/qnice_disk0_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe99]
set_property port_width 1 [get_debug_ports u_ila_0/probe99]
connect_debug_port u_ila_0/probe99 [get_nets [list CORE/qnice_disk0_readdatavalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe100]
set_property port_width 1 [get_debug_ports u_ila_0/probe100]
connect_debug_port u_ila_0/probe100 [get_nets [list CORE/qnice_disk0_waitrequest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe101]
set_property port_width 1 [get_debug_ports u_ila_0/probe101]
connect_debug_port u_ila_0/probe101 [get_nets [list CORE/qnice_disk0_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe102]
set_property port_width 1 [get_debug_ports u_ila_0/probe102]
connect_debug_port u_ila_0/probe102 [get_nets [list CORE/qnice_pet_mount0_buf_ram_ce]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe103]
set_property port_width 1 [get_debug_ports u_ila_0/probe103]
connect_debug_port u_ila_0/probe103 [get_nets [list CORE/qnice_pet_mount0_buf_ram_wait]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe104]
set_property port_width 1 [get_debug_ports u_ila_0/probe104]
connect_debug_port u_ila_0/probe104 [get_nets [list CORE/qnice_pet_mount0_buf_ram_we]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe105]
set_property port_width 1 [get_debug_ports u_ila_0/probe105]
connect_debug_port u_ila_0/probe105 [get_nets [list CORE/i_qnice2hyperram_d0/reading]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe106]
set_property port_width 1 [get_debug_ports u_ila_0/probe106]
connect_debug_port u_ila_0/probe106 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe107]
set_property port_width 1 [get_debug_ports u_ila_0/probe107]
connect_debug_port u_ila_0/probe107 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_read_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe108]
set_property port_width 1 [get_debug_ports u_ila_0/probe108]
connect_debug_port u_ila_0/probe108 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_readdatavalid_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe109]
set_property port_width 1 [get_debug_ports u_ila_0/probe109]
connect_debug_port u_ila_0/probe109 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_waitrequest_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe110]
set_property port_width 1 [get_debug_ports u_ila_0/probe110]
connect_debug_port u_ila_0/probe110 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe111]
set_property port_width 1 [get_debug_ports u_ila_0/probe111]
connect_debug_port u_ila_0/probe111 [get_nets [list i_framework/i_av_pipeline/i_digital_pipeline/i_avm_decrease/s_avm_write_i]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets hr_clk]
