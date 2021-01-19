
module mux(addr, in_0, in_1, in_2, in_3, out);

input [1:0] addr;
input [6:0] in_0;
input [6:0] in_1;
input [6:0] in_2;
input [6:0] in_3;

output reg [6:0] out;

always @*
begin

	casez(addr)
		0: out = in_0;
		1: out = in_1;
		2: out = in_2;
		3: out = in_3;
	endcase

end

endmodule
