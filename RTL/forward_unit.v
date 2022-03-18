module forward_unit(
	input wire [4:0] rs1_ex,
	input wire [4:0] rs2_ex,
	input wire [4:0] rd_mem,
	input wire [4:0] rd_wb,
	input wire mem_read,
	input wire mem_2_reg,
		
	output reg [1:0] mux_alu_1,
	output reg [1:0] mux_alu_2
);
	always @(*) begin	
		if((rs1_ex == rd_mem || rs2_ex == rd_mem)) begin
			mux_alu_1 = 2'b0;
			mux_alu_2 = 2'b10;
		end else if((rs1_ex == rd_wb || rs2_ex == rd_wb)) begin
			mux_alu_1 = 2'b1;
			mux_alu_2 = 2'b1;
		end else begin
			mux_alu_1 = 2'b00;
			mux_alu_2 = 2'b00;
		end
	end

endmodule
