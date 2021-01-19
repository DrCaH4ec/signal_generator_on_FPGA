
module uart(CLOCK_50, rx, out_data, rx_done, arst_n);

///////////////////////////////////////////////////////////////////////////////
input CLOCK_50;
input rx;
input arst_n;

output reg [15:0] out_data;
output reg rx_done = 0; 
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
wire rx_clk;
wire tx_clk;
wire done;
wire [7:0] data_buf;
//reg [15:0] data;
reg cnt = 0;
reg rst;

//assign out_data = data;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
baud_rate_gen gen_0(CLOCK_50, rx_clk, tx_clk);

receiver receiver_0(rx, done, rst, CLOCK_50, rx_clk, data_buf);
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
always @ (posedge done)
begin
	
	if(cnt) out_data[15:8] = data_buf;
	else out_data[7:0] = data_buf;
	
	cnt = cnt + 1;

end

///////////////////////////////////////////////////////////////////////////////

always @ (negedge cnt or negedge arst_n)
begin

	if(!arst_n) rx_done = 0;
	else rx_done = 1;
	
end

///////////////////////////////////////////////////////////////////////////////

always @ (posedge CLOCK_50)
begin

	if(done) rst = 1;
	else		rst = 0;

end


endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * UART receiver and baud generator were taken on GitHub wit next link:
 * https://github.com/jamieiles/uart
 *
 * I have changed speed of receiving.
 */
///////////////////////////////////////////////////////////////////////////////////////////////////

module receiver(input wire rx,
		output reg rdy,
		input wire rdy_clr,
		input wire clk_50m,
		input wire clken,
		output reg [7:0] data);

initial begin
	rdy = 0;
	data = 8'b0;
end

parameter RX_STATE_START	= 2'b00;
parameter RX_STATE_DATA		= 2'b01;
parameter RX_STATE_STOP		= 2'b10;

reg [1:0] state = RX_STATE_START;
reg [3:0] sample = 0;
reg [3:0] bitpos = 0;
reg [7:0] scratch = 8'b0;

always @(posedge clk_50m) begin
	if (rdy_clr)
		rdy <= 0;

	if (clken) begin
		case (state)
		RX_STATE_START: begin
			/*
			* Start counting from the first low sample, once we've
			* sampled a full bit, start collecting data bits.
			*/
			if (!rx || sample != 0)
				sample <= sample + 4'b1;

			if (sample == 15) begin
				state <= RX_STATE_DATA;
				bitpos <= 0;
				sample <= 0;
				scratch <= 0;
			end
		end
		RX_STATE_DATA: begin
			sample <= sample + 4'b1;
			if (sample == 4'h8) begin
				scratch[bitpos[2:0]] <= rx;
				bitpos <= bitpos + 4'b1;
			end
			if (bitpos == 8 && sample == 15)
				state <= RX_STATE_STOP;
		end
		RX_STATE_STOP: begin
			/*
			 * Our baud clock may not be running at exactly the
			 * same rate as the transmitter.  If we thing that
			 * we're at least half way into the stop bit, allow
			 * transition into handling the next start bit.
			 */
			if (sample == 15 || (sample >= 8 && !rx)) begin
				state <= RX_STATE_START;
				data <= scratch;
				rdy <= 1'b1;
				sample <= 0;
			end else begin
				sample <= sample + 4'b1;
			end
		end
		default: begin
			state <= RX_STATE_START;
		end
		endcase
	end
end

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

module baud_rate_gen(input wire clk_50m,
		     output wire rxclk_en,
		     output wire txclk_en);

parameter RX_ACC_MAX = 50000000 / (115200 * 16);
parameter TX_ACC_MAX = 50000000 / 115200;
parameter RX_ACC_WIDTH = $clog2(RX_ACC_MAX);
parameter TX_ACC_WIDTH = $clog2(TX_ACC_MAX);
reg [RX_ACC_WIDTH - 1:0] rx_acc = 0;
reg [TX_ACC_WIDTH - 1:0] tx_acc = 0;

assign rxclk_en = (rx_acc == 5'd0);
assign txclk_en = (tx_acc == 9'd0);

always @(posedge clk_50m) begin
	if (rx_acc == RX_ACC_MAX[RX_ACC_WIDTH - 1:0])
		rx_acc <= 0;
	else
		rx_acc <= rx_acc + 5'b1;
end

always @(posedge clk_50m) begin
	if (tx_acc == TX_ACC_MAX[TX_ACC_WIDTH - 1:0])
		tx_acc <= 0;
	else
		tx_acc <= tx_acc + 9'b1;
end

endmodule
