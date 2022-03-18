module forward_unit(
	input wire [4:0] rs1_ex,
	input wire [4:0] rs2_ex,
	input wire [4:0] rd_mem,
	input wire [4:0] rd_wb,
		
	output wire [1:0] mux_alu_1,
	output wire [1:0] mux_alu_2
);

	if(rs1_ex == rd_mem || rs2_ex == rd_mem) begin
		mux_alu_1 = 2'b10;
		mux_alu_2 = 2'b10;
	else if(rs1_ex == rd_wb || rs2_ex == rd_wb) begin
		mux_alu_1 = 2'b01;
		mux_alu_2 = 2'b01;
	else
		mux_alu_1 = 2'b00;
		mux_alu_2 = 2'b00;

endmodule
