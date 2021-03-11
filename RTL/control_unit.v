// module: Control
// Function: Generates the control signals for each one of the datapath resources

module control_unit(
      input  wire [5:0] opcode,
      output reg  [1:0] alu_op,
      output reg        reg_dst,
      output reg        branch,
      output reg        mem_read,
      output reg        mem_2_reg,
      output reg        mem_write,
      output reg        alu_src,
      output reg        reg_write,
      output reg        jump
   );

   //The opcode for these instructions can be found on the MIPS reference at the beginning of the textbook (Green cardboard page)
   parameter integer ALU_R      = 6'h0;
   parameter integer ADDI       = 6'h8;
   parameter integer BRANCH_EQ  = 6'h4;
   parameter integer JUMP       = 6'h2;
   parameter integer LOAD_WORD  = 6'h23;
   parameter integer STORE_WORD = 6'h2B;

   parameter [1:0] ADD_OPCODE     = 2'd0;
   parameter [1:0] SUB_OPCODE     = 2'd1;
   parameter [1:0] R_TYPE_OPCODE  = 2'd2;
  


   //The behavior of the control unit can be found in Chapter 4, Figure 4.18

   always@(*)begin

      case(opcode)
         ALU_R:begin
            reg_dst   = 1'b1;
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b1;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b0;
         end
    
	// Declare the control signals for each one of the instructions
	
         default:begin
            reg_dst   = 1'b0; 
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b0;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b0;
         end
      endcase
   end

endmodule



