// Ownasaurus
// HDMI/DVI vsync extractor
// Designed to work on the LFE5UM5G-85F-EVN development board by Lattice

`default_nettype none
module top #(parameter RESOLUTION=480) (
    input clk12,
    output [7:0] led,
    output tx_uart,
    input rx_uart,
    input button,
//    input tmds_r,
//    input tmds_g,
    input tmds_b,
    input tmds_c,
    output vsync,
    output [2:0] debug
);

wire tmds_b;

//These are not needed! Occurs automatically
//ILVDS tmds_blue(.A(tmds_b_p), .AN(tmds_b_n), .Z(tmds_b));
//ILVDS tmds_clock(.A(tmds_c_p), .AN(tmds_c_n), .Z(tmds_c));

// set up 25MHz to use as base clk ----------------------
wire clk25;
wire clk250;
wire pll_locked;
pll_12_25 pll(.clki(clk12), .clk25(clk25), .locked(pll_locked));

wire tmds_data_valid;
wire [9:0] tmds_data;

wire [7:0] b_data;
wire [1:0] b_ctrl;
wire b_de;

wire tmds_c_r;
wire tmds_c_g;
wire tmds_c_b;
wire pll_locked2;

// regen pixel clock
// TODO: and allow shifts per channel as needed
pixel_clock_reconstruct blah(.clki(tmds_c), .clko(tmds_c_b), .clko2(tmds_c_g), .clko3(tmds_c_r), .locked(pll_locked2));

// clock out the data
// TODO: center bit clock around data
clock_and_data_recovery cdr(.tmds_data(tmds_b), .bit_clk(tmds_c_b), .tmds_word(tmds_data), .valid_data(tmds_data_valid));

// decode tmds channel
tmds_decoder_dvi decode_blue(.clk(tmds_c_b), .rst(tmds_c), .tmds(tmds_b), .data(b_data), .ctrl(b_ctrl), .de(b_de));

// vsync is contained in ctrl channel 0 in the blue channel
// this channel only contains vsync data when (VIDEO) DATA ENABLE is low
assign vsync = b_de ? 1'b0 : b_ctrl[0];

assign debug[0] = clk25;
assign debug[1] = tmds_c_b;
assign debug[2] = pll_locked2;

// disable many of the the super bright LEDS on the dev board
assign led[7:0] = 8'b11111111;

endmodule
