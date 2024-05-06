//Ownasaurus

`default_nettype none
module token_detector(input [19:0] buffer, output reg [3:0] token_loc);

localparam CT0 = 10'b1101010100;
localparam CT1 = 10'b0010101011;
localparam CT2 = 10'b0101010100;
localparam CT3 = 10'b1010101011;

always @(*) begin
    // need to align to word boundaries
    if(buffer[9:0] == CT0 || buffer[9:0] == CT1 || buffer[9:0] == CT2 || buffer[9:0] == CT3) begin
        token_loc = 4'd0;
    end else if(buffer[10:1] == CT0 || buffer[10:1] == CT1 || buffer[10:1] == CT2 || buffer[10:1] == CT3) begin
        token_loc = 4'd1;
    end else if(buffer[11:2] == CT0 || buffer[11:2] == CT1 || buffer[11:2] == CT2 || buffer[11:2] == CT3) begin
        token_loc = 4'd2;
    end else if(buffer[12:3] == CT0 || buffer[12:3] == CT1 || buffer[12:3] == CT2 || buffer[12:3] == CT3) begin
        token_loc = 4'd3;
    end else if(buffer[13:4] == CT0 || buffer[13:4] == CT1 || buffer[13:4] == CT2 || buffer[13:4] == CT3) begin
        token_loc = 4'd4;
    end else if(buffer[14:5] == CT0 || buffer[14:5] == CT1 || buffer[14:5] == CT2 || buffer[14:5] == CT3) begin
        token_loc = 4'd5;
    end else if(buffer[15:6] == CT0 || buffer[15:6] == CT1 || buffer[15:6] == CT2 || buffer[15:6] == CT3) begin
        token_loc = 4'd6;
    end else if(buffer[16:7] == CT0 || buffer[16:7] == CT1 || buffer[16:7] == CT2 || buffer[16:7] == CT3) begin
        token_loc = 4'd7;
    end else if(buffer[17:8] == CT0 || buffer[17:8] == CT1 || buffer[17:8] == CT2 || buffer[17:8] == CT3) begin
        token_loc = 4'd8;
    end else if(buffer[18:9] == CT0 || buffer[18:9] == CT1 || buffer[18:9] == CT2 || buffer[18:9] == CT3) begin
        token_loc = 4'd9;
    end else begin
        token_loc = 4'd15; // no token found
    end
end

endmodule
