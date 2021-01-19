
module sin_rom(addr, out_data);

input [6:0] addr;

output wire [6:0] out_data;

reg [6:0] sine [127:0];

assign out_data = sine[addr];

initial $readmemh("sin.hex", sine);

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module triangle_rom(addr, out_data);

input [6:0] addr;

output wire [6:0] out_data;

reg [6:0] triangle [127:0];

assign out_data = triangle[addr];

initial $readmemh("triangle.hex", triangle);

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module user_set(clk, addr, out_data, in_data, we);

input [6:0] addr;
input [6:0] in_data;
input we;
input clk;

output reg [6:0] out_data;

reg [6:0] user_mem [127:0];

initial $readmemh("user_test.hex", user_mem);

always @ (posedge clk)
begin
	if(we) 
		user_mem[addr] <= in_data;
		
	out_data <= user_mem[addr];		// it can be place with troubles
end

endmodule
