// Ownasaurus

`default_nettype none
module tmds_decoder_dvi(
    input clk,
    input rst, // high to enable processing data, low to latch/lock data
    input [9:0] tmds,
    output reg [7:0] data,
    output reg [1:0] ctrl,
    output reg de
);

wire inverted;
wire enc_xor;

assign inverted = tmds[9]; // 1 means the 8-bit data was bit flipped
assign enc_xor = tmds[8]; // 1 menas xor encoding was used, 0 means xnor encoding was used

wire [7:0] d;

assign d = inverted ? ~tmds[7:0] : tmds[7:0];

always @ (posedge clk) begin
    if (rst) begin
        case (tmds)
            10'b1101010100: begin
                ctrl <= 2'b00;
                de <= 1'b0;
    
                data = 8'b00000000;
            end
            10'b0010101011: begin
                ctrl <= 2'b01;
                de <= 1'b0;
    
                data = 8'b00000000;
            end
            10'b0101010100: begin
                ctrl <= 2'b10;
                de <= 1'b0;
    
                data = 8'b00000000;
            end
            10'b1010101011: begin
                ctrl <= 2'b11;
                de <= 1'b0;
    
                data = 8'b00000000;
            end
            default: begin // actual pixel data!
                de <= 1'b1;
                ctrl = 2'b00;
    
                data[0] = d[0];
                data[1] = enc_xor ? d[1] ^ d[0] : ~d[1] ^ d[0];
                data[2] = enc_xor ? d[2] ^ d[1] : ~d[2] ^ d[1];
                data[3] = enc_xor ? d[3] ^ d[2] : ~d[3] ^ d[2];
                data[4] = enc_xor ? d[4] ^ d[3] : ~d[4] ^ d[3];
                data[5] = enc_xor ? d[5] ^ d[4] : ~d[5] ^ d[4];
                data[6] = enc_xor ? d[6] ^ d[5] : ~d[6] ^ d[5];
                data[7] = enc_xor ? d[7] ^ d[6] : ~d[7] ^ d[6];
            end
        endcase
    end
end

endmodule
