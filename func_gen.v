`define SIN_WAVE 	0
`define TRI_WAVE 	1
`define SAW_WAVE 	2
`define USR_WAVE	3


module func_gen(CLOCK_50, rx_pin, generation, out_data);
///////////////////////////////////////////////////////////////////////////////
input CLOCK_50;
input rx_pin;

output generation;
output [6:0] out_data;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
reg uart_rst;
reg [31:0] phase_step = 0;
reg [1:0] type_of_wave = 0;
reg enable_gen = 0;
reg user_set_we;
reg usr_mem_clk = 0;

assign generation = ~enable_gen;


wire [15:0] data_buf;
wire gen_clk;
wire [6:0] count;
wire [6:0] cnt_out [3:0];
wire rx_done;
wire [6:0] user_set_addr = user_set_we ? data_buf[14:8] : count;

assign cnt_out[`SAW_WAVE] = count;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
uart uart_0(CLOCK_50, rx_pin, data_buf, rx_done, uart_rst);

generator gen_0(CLOCK_50, gen_clk, phase_step, pll_ok);

counter cnt_0(gen_clk, count, enable_gen);

sin_rom sin_0(count, cnt_out[`SIN_WAVE]);

triangle_rom tri_0(count, cnt_out[`TRI_WAVE]);

user_set usr_0(usr_mem_clk, user_set_addr, cnt_out[`USR_WAVE], data_buf[6:0], user_set_we);

mux mux_o(type_of_wave, cnt_out[`SIN_WAVE], cnt_out[`TRI_WAVE], cnt_out[`SAW_WAVE], cnt_out[`USR_WAVE], out_data);
///////////////////////////////////////////////////////////////////////////////

always @(negedge rx_done)
begin
	if(!data_buf[15])
	begin
		user_set_we = 1;
	end
	else
	begin
		user_set_we = 0;
	
		casez(data_buf[14:12])
			3'b001: enable_gen = data_buf[11:8] ? 1 : 0;
			3'b010: type_of_wave = data_buf[9:8];
			3'b011: 	begin
							casez(data_buf[9:8])
								2'b00: phase_step[7:0] = data_buf[7:0];
								2'b01: phase_step[15:8] = data_buf[7:0];
								2'b10: phase_step[23:16] = data_buf[7:0];
								2'b11: phase_step[31:24] = data_buf[7:0];
							endcase
						end
			default: begin
				//phase_step = 32'h00000000;
			end
		endcase
	end
end


always @(posedge CLOCK_50)
begin
	if(rx_done) uart_rst = 0;
	else uart_rst = 1;

	if(usr_mem_clk) usr_mem_clk = 0;
	if(user_set_we) usr_mem_clk = 1;
end

endmodule
