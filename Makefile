PROJ=hdmi_testing
TRELLIS?=/usr/local/share/trellis

all: ${PROJ}.bit

${PROJ}.json: top.v pll.v tmds_decoder_dvi.v cdr.v token_detector.v
	yosys -p "synth_ecp5 -json $@ -top top" top.v pll.v tmds_decoder_dvi.v cdr.v token_detector.v

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --um5g-85k --package CABGA381 --lpf ecp5evn.lpf

%.bit: %_out.config
	ecppack --svf ${PROJ}.svf $< $@

${PROJ}.svf : ${PROJ}.bit

flash: ${PROJ}.bit
	openFPGALoader -b ecp5_evn -f $<

test: ${PROJ}.bit
	openFPGALoader -b ecp5_evn $<

clean:
	rm -f *.svf *.bit *.config *.json

.PHONY: prog clean
