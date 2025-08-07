simSetSimulator "-vcssv" -exec "./simv" -args " " -uvmDebug on
debImport "-i" "-simflow" "-dbdir" "./simv.daidir"
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiWindowResize -win $_Verdi_1 "1281" "31" "1278" "1360"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_fft_top.dut" -win $_nTrace1
srcSetScope "tb_fft_top.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvCreateWindow
verdiSetActWin -win $_nWave3
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
srcSetScope "tb_fft_top.dut.MODUL0" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -show -widget MTB_SOURCE_TAB_1
srcHBSelect "tb_fft_top.dut" -win $_nTrace1
srcSetScope "tb_fft_top.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 290305 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "rstn" -line 290305 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave3 "/tb_fft_top/dut/clk" "/tb_fft_top/dut/rstn"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 2)}
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
srcSetScope "tb_fft_top.dut.MODUL0" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -next -widget MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "SYNOPSYS_UNCONNECTED_101" -line 130424 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {1 1 1 1 1 19} -backward
verdiFindBar -pattern "do_count" -previous -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -previous -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -previous -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -previous -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -previous -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -previous -widget MTB_SOURCE_TAB_1
verdiFindBar -hide -widget MTB_SOURCE_TAB_1
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
srcSetScope "tb_fft_top.dut.MODUL0" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiFindBar -show -widget MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count" -next -widget MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvAddSignal -win $_nWave3 "/tb_fft_top/dut/MODUL0/do_count\[6:0\]"
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 3)}
srcHBSelect "tb_fft_top.dut.MODUL0.bf1_1" -win $_nTrace1
srcSetScope "tb_fft_top.dut.MODUL0.bf1_1" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut.MODUL0.bf1_1" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "x0_re" -line 687 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "x0_im" -line 688 -pos 1 -win $_nTrace1
srcSelect -signal "x1_re" -line 689 -pos 1 -win $_nTrace1
srcSelect -signal "x1_im" -line 690 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "in_en" -line 685 -pos 1 -win $_nTrace1
srcSelect -signal "x0_re" -line 687 -pos 1 -win $_nTrace1
srcSelect -signal "x0_im" -line 688 -pos 1 -win $_nTrace1
srcSelect -signal "x1_re" -line 689 -pos 1 -win $_nTrace1
srcSelect -signal "x1_im" -line 690 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvAddSignal -win $_nWave3 "/tb_fft_top/dut/MODUL0/bf1_1/in_en" \
           "/tb_fft_top/dut/MODUL0/bf1_1/x0_re\[143:0\]" \
           "/tb_fft_top/dut/MODUL0/bf1_1/x0_im\[143:0\]" \
           "/tb_fft_top/dut/MODUL0/bf1_1/x1_re\[143:0\]" \
           "/tb_fft_top/dut/MODUL0/bf1_1/x1_im\[143:0\]"
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G2" 5)}
wvSetPosition -win $_nWave3 {("G2" 5)}
verdiSetActWin -win $_nWave3
wvSelectGroup -win $_nWave3 {G2}
wvSelectSignal -win $_nWave3 {( "G2" 1 )} 
wvSelectSignal -win $_nWave3 {( "G2" 1 2 3 4 5 )} 
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G2" 5)}
wvSelectSignal -win $_nWave3 {( "G2" 1 )} 
wvSelectSignal -win $_nWave3 {( "G2" 1 2 3 )} 
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 3)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSetPosition -win $_nWave3 {("G1" 6)}
srcTBRunSim
wvSetCursor -win $_nWave3 3354424.205268 -snap {("G3" 0)}
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 0.000000 421645.186194
wvSelectSignal -win $_nWave3 {( "G1" 4 )} 
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvSetCursor -win $_nWave3 47487.741224 -snap {("G1" 1)}
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count_en" -next -widget MTB_SOURCE_TAB_1
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
srcSetScope "tb_fft_top.dut.MODUL0" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_top.dut.MODUL0" -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -pattern "do_count_en" -next -widget MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G2" 2)}
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvAddSignal -win $_nWave3 "/tb_fft_top/dut/MODUL0/do_count_en"
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 3)}
srcTBSimReset
srcTBRunSim
wvSelectSignal -win $_nWave3 {( "G2" 1 )} 
verdiSetActWin -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G2" 1 2 )} 
wvSetPosition -win $_nWave3 {("G2" 1)}
wvSetPosition -win $_nWave3 {("G2" 2)}
wvSetPosition -win $_nWave3 {("G3" 0)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("G3" 2)}
wvSetPosition -win $_nWave3 {("G3" 2)}
wvSetOptions -win $_nWave3 -hierName on
wvSelectGroup -win $_nWave3 {G4}
wvSetCursor -win $_nWave3 3346372.126195 -snap {("G4" 0)}
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 0.000000 207039.714868
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvSetCursor -win $_nWave3 54896.936613 -snap {("G1" 1)}
verdiFindBar -hide -win nWave_3
debExit
