
module counter(clk, out, arst_n);

input clk;
input arst_n;

output reg [6:0] out;

always @(posedge clk or negedge arst_n)
begin
	if(!arst_n) out = 0;
	else out = out + 1;
end

endmodule
