//Branch Unit
//Function: Calculate the next pc in the case of a control instruction (branch or jump).
//Inputs:
//instruction: Instruction currently processed. The least significant bits are used for the calcualting the target pc in the case of a jump instruction. 
//branch_offset: Offset for a branch instruction. 
//updated_pc:  Current PC + 4.
//Outputs: 
//branch_pc: Target PC in the case of a branch instruction.
//jump_pc: Target PC in the case of a jump instruction.

module branch_unit#(
   parameter integer DATA_W     = 16
   )(
      input  wire signed [DATA_W-1:0]  updated_pc,
      input  wire signed [DATA_W-1:0]  instruction,
      input  wire signed [DATA_W-1:0]  branch_offset,
      output reg  signed [DATA_W-1:0]  branch_pc,
      output reg  signed [DATA_W-1:0]  jump_pc
   );

   reg signed [DATA_W-1:0] shifted_offset;
   reg signed [DATA_W-1:0] shifted_instruction;

 
   always@(*) shifted_offset      = branch_offset<<2;
   always@(*) shifted_instruction = instruction<<2;
   always@(*) branch_pc           = shifted_offset+updated_pc;
   always@(*) jump_pc             = {updated_pc[31:28],shifted_instruction[27:0]};
  
endmodule



