
module generator(i_clk, o_clk, phase_step, pll_ok);

input i_clk;
input [31:0] phase_step;

output wire o_clk;
output wire pll_ok;

wire CLOCK_200;

my_pll pll_0(i_clk, CLOCK_200, pll_ok);       // this moment works in chip
nco nco_0(CLOCK_200, phase_step, o_clk, 1);   // but I had some troubles with simulation and PLL

//nco nco_0(i_clk, phase_step, o_clk, 1);

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

module nco(i_clk, phase_step, o_clk, n_rst);

input i_clk;
input n_rst;
input [31:0] phase_step;

output o_clk;

reg [31:0]  phase = 0;
reg [31:0]  freq_step = 0;

wire sys_clk = i_clk;

assign o_clk = phase[31];

always @(posedge sys_clk, negedge n_rst) begin
    if(!n_rst) begin
        freq_step <= 0;
    end 
	 else begin
		 freq_step <= phase_step;
    end
end

always @(posedge sys_clk, negedge n_rst) begin
    if(~n_rst) begin
        phase <= 0;
    end else begin
        phase <= phase + freq_step;
    end
end

endmodule
