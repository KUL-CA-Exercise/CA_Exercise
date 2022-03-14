//Module: ALU control
//Function: ALU control is a combinational circuit that takes the ALU control signals from the Control unit as well as the function field of the instruction, and generates the control signals for the ALU

module alu_control(
      input wire       func7_5,
      input wire       func7_0,
      input wire [2:0] func3,
		input wire [1:0] alu_op,
		output reg [3:0] alu_control
   );

   
   //The ALUOP codes can be found
   //in chapter 4.4 of the book.
   parameter [1:0] ADD_OPCODE    = 2'b00;
   parameter [1:0] SUB_OPCODE    = 2'b01;
   parameter [1:0] R_TYPE_OPCODE = 2'b10;

   //The ALU control codes can be found
   //in chapter 4.4 of the book.
   parameter [3:0] AND_OP        = 4'd0;
   parameter [3:0] OR_OP         = 4'd1;
   parameter [3:0] ADD_OP        = 4'd2;
   parameter [3:0] SLL_OP        = 4'd3;
   parameter [3:0] SRL_OP        = 4'd4;
   parameter [3:0] SUB_OP        = 4'd6;
   parameter [3:0] SLT_OP        = 4'd7;
   parameter [3:0] MUL_OP        = 4'd8;

   //The decoding of the instruction funtion field into the desired
   //alu operation can be found in Figure 4.12 of the Patterson Book,
   //section 4.4
   wire [4:0] function_field = {func7_5, func7_0, func3};
   parameter [4:0] FUNC_ADD      = 5'b00000;
   parameter [4:0] FUNC_SUB      = 5'b10000;
   parameter [4:0] FUNC_AND      = 5'b00111;
   parameter [4:0] FUNC_OR       = 5'b00110;
   parameter [4:0] FUNC_SLT      = 5'b00010;
   parameter [4:0] FUNC_SLL      = 5'b00001;
   parameter [4:0] FUNC_SRL      = 5'b00101;
   parameter [4:0] FUNC_MUL      = 5'b01000;

	reg [3:0] rtype_op;
   
   always @(*) begin
		case(function_field)
		   FUNC_ADD	:  rtype_op = ADD_OP;
		   FUNC_SUB	:  rtype_op = SUB_OP;
		   FUNC_AND	:  rtype_op = AND_OP;
		   FUNC_OR 	:  rtype_op = OR_OP; 
		   FUNC_SLT	:  rtype_op = SLT_OP;
		   FUNC_SLL	:  rtype_op = SLL_OP;
		   FUNC_SRL	:  rtype_op = SRL_OP;
         FUNC_MUL	:  rtype_op = MUL_OP;
			default:    rtype_op = 4'd0;
		endcase
	end

	always @(*) begin
		case(alu_op)
			ADD_OPCODE    : alu_control = ADD_OP;	/* add */
			SUB_OPCODE    : alu_control = SUB_OP;	/* sub */
			R_TYPE_OPCODE : alu_control = rtype_op;
			default       : alu_control = 'b0;
		endcase
	end

endmodule

