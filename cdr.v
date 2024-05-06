//Ownasaurus

`default_nettype none
module clock_and_data_recovery(input tmds_data, input bit_clk, output reg [9:0] tmds_word, output valid_data);

localparam STATE_INITIAL = 0;
localparam STATE_PHASE_ALIGNED = 1;
localparam STATE_WORD_ALIGNED = 2;

reg [1:0] state = 2'b00;
reg [2:0] substate = 3'd0;

reg [1:0] vals = 2'b00;
reg [19:0] word_buffer = 20'b00000000000000000000;

wire [3:0] token_offset;
reg [3:0] word_offset; // defining d15 as undefined
reg [4:0] shifts_since_eye_open = 5'd0;

localparam WORD_COUNT_LIMIT = 1200;
reg [4:0] counter = 5'b00000;
reg [10:0] word_count = 11'd0; // max 2048, which is well above 1080p + control tokens, which is max supported resolution
reg [4:0] consecutive_token_count = 5'd0;
reg attempt_number = 1'b0;

IDDRX1F twofer(.D(tmds_data), .SCLK(bit_clk), .RST(), .Q0(vals[0]), .Q1(vals[1]));

token_detector td(.buffer(word_buffer), .token_loc(token_offset));

assign valid_data = (word_offset == 4'd15) ? 1'b0 : 1'b1; // data is valid iff our offset is defined

// always shift the two latest values into the word_buffer per bit_clk cycle
always @(posedge bit_clk) begin
    word_buffer <= {vals[1:0], word_buffer[19:2]};

    // keep track of every 5 cycles
    if(counter == 5'b10000) begin
        counter <= 5'b00001;
    end
    else if(counter == 5'b00000) begin // special case to skip first iteration
        counter <= 5'b00010;
    end
    else begin
        counter <= (counter << 1);
    end

    // process the word logic once every word aka 5 cycles
    if(counter == 5'b00001) begin
        if(state == STATE_INITIAL) begin
            // if timeout period, assume we're in jitter
            // if find control token before timeout period, assume we're somewhere in the eye
            // let timeout period be based on word count, let's say 1200 words

            // determine if we are in jitter or not
            if(consecutive_token_count >= 12) begin // conclude not in jitter!
                // logic depending on where in algorithm we are
                // TODO: center the eye nicely
                // for now, just move on to the next phase and reset initial variables
                state <= STATE_PHASE_ALIGNED;
                word_count <= 0;
                consecutive_token_count <= 0;
                attempt_number <= 0;
            end
            else if(token_offset != 4'd15) begin // not undefined means we found a token!
                consecutive_token_count <= consecutive_token_count + 1;

            end
            else begin // not a token
                word_count <= word_count + 1;

                // check for two failure cases that indicate we're in jitter
                // 1) we broke a streak prematurely
                // 2) we've gone too many words without seeing a token
                if(consecutive_token_count > 0 || word_count >= WORD_COUNT_LIMIT) begin
                    if(attempt_number == 0) begin // first attempt means we can reset
                        consecutive_token_count <= 5'd0; //
                    end
                    else begin // second attempt means we should change phase and reset state
                        // signal to PLL to change
                        // wait enough cycles
                        // resume with a reset state
                    end
                end
            end

            // Logic:
            // 0. (only if in eye) advance towards jitter
            // 1. we are in jitter
            // 2. advance clock phase until we are no longer in jitter. record phase offset as O1
            // 3. advance clock phase slowly until we are in jitter again. record phase offset as O2
            // 4. set clock phase to the average of O1 and O2
            // 5. we are now in the center of the eye
            // Source: Xilinx xapp460
            
        end
        else if(state == STATE_PHASE_ALIGNED) begin
            // need to align to word boundaries
            if(token_offset != 4'd15) begin // not undefined means we found a token!
                word_offset <= token_offset; // save the offset
                state <= STATE_WORD_ALIGNED; // not we are aligned
            end
        end
        else if(state == STATE_WORD_ALIGNED) begin
            // assign tmds_word based on the word boundary
            case(word_offset)
                4'd0: tmds_word <= word_buffer[9:0];
                4'd1: tmds_word <= word_buffer[10:1];
                4'd2: tmds_word <= word_buffer[11:2];
                4'd3: tmds_word <= word_buffer[12:3];
                4'd4: tmds_word <= word_buffer[13:4];
                4'd5: tmds_word <= word_buffer[14:5];
                4'd6: tmds_word <= word_buffer[15:6];
                4'd7: tmds_word <= word_buffer[16:7];
                4'd8: tmds_word <= word_buffer[17:8];
                4'd9: tmds_word <= word_buffer[18:9];
                default: tmds_word <= 10'b1111111111; // undefined state
            endcase
        end
    end
end

endmodule
