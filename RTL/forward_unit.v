module forward_unit(input wire [4:0] rs1_ex,
                    input wire [4:0] rs2_ex,
                    input wire [4:0] rd_mem,
                    input wire [4:0] rd_wb,
                    input wire reg_write_mem,
                    input wire reg_write_wb,

                    output reg [1:0] mux_alu_1,
                    output reg [1:0] mux_alu_2);

	always @(*) begin
	    // EX hazard
	    if (reg_write_mem && (rs1_ex == rd_mem)) begin
	        mux_alu_1 = 2'b10;
	        mux_alu_2 = 2'b0;
	    end else if (reg_write_mem && (rs2_ex == rd_mem)) begin
	        mux_alu_1 = 2'b0;
	        mux_alu_2 = 2'b10;
	    end else if (reg_write_wb && (rs1_ex == rd_wb)) begin
	    	// MEM hazard
	   		mux_alu_1 = 2'b1;
	   		mux_alu_2 = 2'b0;
	   	end else if (reg_write_wb && (rs2_ex == rd_wb)) begin
	   		mux_alu_1 = 2'b0;
	   		mux_alu_2 = 2'b1;
	   	end else begin
	   		mux_alu_1 = 2'b00;
	   		mux_alu_2 = 2'b00;
	   	end	
	end

endmodule
