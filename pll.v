// Ownasaurus

/*fIN
Input Clock Frequency (CLKI, CLKFB)
8
400
MHz

fOUT
Output Clock Frequency (CLKOP, CLKOS)
3.125
400
MHz

fVCO
PLL VCO Frequency
400
800
MHz

fPFD3
Phase Detector Input Frequency
10
400
MHz*/
`default_nettype none
module pll_12_25(input clki, output clk25, output locked);
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
    wire clkop;

    EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .CLKOP_FPHASE(0),
        .CLKOP_CPHASE(0),
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOP_DIV(25),
        .CLKOS_DIV(20),
        .CLKFB_DIV(5),
        .CLKI_DIV(3),
        .FEEDBK_PATH("CLKOP")
    ) pll_i (
        .CLKI(clki),
        .CLKFB(clkop),
        .CLKOP(clkop),
        .CLKOS(clk25),
        .RST(1'b0),
        .STDBY(1'b0),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b0),
        .PHASESTEP(1'b0),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .ENCLKOS(1'b1),
        .ENCLKOS2(1'b0),
        .LOCK(locked)
    );

endmodule

// VCO = 500MHz for 25MHz pixel clock
module pixel_clock_reconstruct(input clki, output clko, output clko2, output clko3, output locked);
    wire clkop;
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
    EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .CLKOP_FPHASE(0),
        .CLKOP_CPHASE(0),
        .CLKOS_FPHASE(1),  // 11.25 deg phase shift per adjustment
        .CLKOS2_FPHASE(1), // 11.25 deg phase shift per adjustment
        .CLKOS3_FPHASE(1), // 11.25 deg phase shift per adjustment
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOP_DIV(20),
        .CLKOS_DIV(4),
        .CLKOS2_DIV(4),
        .CLKOS3_DIV(4),
        .CLKFB_DIV(1),
        .CLKI_DIV(1),
        .FEEDBK_PATH("CLKOP")
    ) pll_i (
        .CLKI(clki),
        .CLKFB(clkop),
        .CLKOP(clkop),
        .CLKOS(clko),
        .CLKOS2(clko2),
        .CLKOS3(clko3),
        .RST(1'b0),
        .STDBY(1'b0),
        .PHASESEL1(1'b0),
        .PHASESEL0(1'b0),
        .PHASEDIR(1'b0),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .ENCLKOS(1'b1),
        .ENCLKOS2(1'b1),
        .ENCLKOS3(1'b1),
        .LOCK(locked)
    );

endmodule

