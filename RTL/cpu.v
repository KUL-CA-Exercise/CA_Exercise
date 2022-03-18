//Module: CPU
//Function: CPU is the top design of the RISC-V processor

//Inputs:
//	clk: main clock
//	arst_n: reset 
// enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory

// Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[63:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[63:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [63:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[63:0]  rdata_ext_2

   );

wire              zero_flag, zero_flag_mem;
wire [      63:0] branch_pc, updated_pc, current_pc, jump_pc,
                  updated_pc_id, updated_pc_ex, branch_pc_mem, jump_pc_mem, updated_pc_mem;
wire [      31:0] instruction, instruction_id, instruction_ex,
                  instruction_mem, instruction_wb;
wire [       1:0] alu_op, alu_op_ex
                  fwd_mux_1, fwd_mux_2;
wire [       3:0] alu_control;
wire              reg_dst, branch, mem_read, mem_2_reg,
                  mem_write, alu_src, reg_write, jump,
                  // ex stage
                  alu_src_ex, 
                  // mem stage
                  branch_ex, branch_mem, 
                  mem_read_ex, mem_read_mem, 
                  mem_write_ex, mem_write_mem,
                  // wb stage
                  mem_2_reg_ex, mem_2_reg_mem, mem_2_reg_wb,
                  reg_write_ex, reg_write_mem, reg_write_wb;
wire [       4:0] regfile_waddr;
wire [      63:0] regfile_wdata, mem_data, mem_data_wb, alu_out, alu_out_mem, alu_out_wb,
                  regfile_rdata_1, regfile_rdata_2,
                  regfile_rdata_1_ex, regfile_rdata_2_ex, regfile_rdata_2_mem,
                  alu_operand_2, fwd_mux_out_1, fwd_mux_out_2;

wire signed [63:0] immediate_extended, immediate_extended_ex;

pc #(
   .DATA_W(64)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (branch_pc_mem ),
   .jump_pc   (jump_pc_mem   ),
   .zero_flag (zero_flag_mem ),
   .branch    (branch_mem    ),
   .jump      (jump      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);

// The instruction memory.
sram_BW32 #(
   .ADDR_W(9 ),
   .DATA_W(32)
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);

// Pipeline: IF_ID stage
reg_arstn_en#(
   .DATA_W(96)
)
pipeline_IF_ID(
   .clk     (clk),
   .arst_n  (arst_n),
   .en      (enable),
   .din     ({current_pc, instruction}),
   .dout    ({updated_pc_id, instruction_id})
);

control_unit control_unit(
   .opcode   (instruction_id[6:0]),
   .alu_op   (alu_op          ), // EX
   .alu_src  (alu_src         ), // EX
   .branch   (branch          ), // MEM
   .mem_read (mem_read        ), // MEM
   .mem_write(mem_write       ), // MEM
   .mem_2_reg(mem_2_reg       ), // WB
   .reg_write(reg_write       ), // WB
   .reg_dst  (reg_dst         ), // NC? 
   .jump     (jump            )  // ???
);

register_file #(
   .DATA_W(64)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write_wb      ),
   .raddr_1  (instruction_id[19:15]),
   .raddr_2  (instruction_id[24:20]),
   .waddr    (instruction_wb[11:7] ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_rdata_1   ),
   .rdata_2  (regfile_rdata_2   )
);

immediate_extend_unit immediate_extend_u(
    .instruction         (instruction_id),
    .immediate_extended  (immediate_extended)
);

// Pipeline: ID_EX stage
reg_arstn_en#(
   .DATA_W(296)
)
pipeline_ID_EX(
   .clk     (clk),
   .arst_n  (arst_n),
   .en      (enable),
   .din     ({alu_op, alu_src, branch, mem_read, mem_write, mem_2_reg, reg_write,   // Ctrl Unit: 8 bits
              updated_pc_id, regfile_rdata_1, regfile_rdata_2,                      // 64 + 64 + 64 bits
              immediate_extended,                                                   // 64 bits
              instruction_id                                                        // 32 bits
            }),
   .dout    ({alu_op_ex, alu_src_ex, branch_ex, mem_read_ex, mem_write_ex, mem_2_reg_ex, reg_write_ex,
              updated_pc_ex, regfile_rdata_1_ex, regfile_rdata_2_ex,                // 64 + 64 + 64 bits
              immediate_extended_ex,                                                // 64 bits
              instruction_ex                                                        // 32 bits
            })
);

alu_control alu_ctrl(
   .func7_5        (instruction_ex[30]   ),
   .func7_0        (instruction_ex[25]   ),
   .func3          (instruction_ex[14:12]),
   .alu_op         (alu_op_ex            ),
   .alu_control    (alu_control       )
);

forward_unit fwd_u(
   .rs1_ex         (instruction_ex[19:15]),
   .rs2_ex         (instruction_ex[24:20]),
   .rd_mem         (instruction_mem[11:7]),
   .rd_wb          (instruction_wb[11:7] ),

   .mux_alu_1      (fwd_mux_1),
   .mux_alu_2      (fwd_mux_2)
);

mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (immediate_extended_ex ),
   .input_b (regfile_rdata_2_ex    ),
   .select_a(alu_src_ex         ),
   .mux_out (alu_operand_2     )
);

mux_3 #(
   .DATA_W(64)
) fwd_unit_alu_op1 (
   .input_a (regfile_rdata_1_ex    ),
   .input_b (regfile_wdata    ),
   .input_c (alu_out_mem      ),
   .sel     (fwd_mux_1        ),
   .mux_out (fwd_mux_out_1    )
);

mux_3 #(
   .DATA_W(64)
) fwd_unit_alu_op2 (
   .input_a (alu_operand_2    ),
   .input_b (regfile_wdata    ),
   .input_c (alu_out_mem      ),
   .sel     (fwd_mux_2        ),
   .mux_out (fwd_mux_out_2    )
);

alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (fwd_mux_out_1   ),
   .alu_in_1 (fwd_mux_out_2   ),
   .alu_ctrl (alu_control     ),
   .alu_out  (alu_out         ),
   .zero_flag(zero_flag       ),
   .overflow (                )
);

branch_unit#(
   .DATA_W(64)
)branch_unit(
   .updated_pc         (updated_pc_ex        ),
   .immediate_extended (immediate_extended_ex),
   .branch_pc          (branch_pc            ),
   .jump_pc            (jump_pc              )
);

// Pipeline: EX_MEM stage
reg_arstn_en#(
   .DATA_W(267)
)
pipeline_EX_MEM(
   .clk     (clk),
   .arst_n  (arst_n),
   .en      (enable),
   .din     ({branch_ex, mem_read_ex, mem_write_ex, mem_2_reg_ex, reg_write_ex,        // 5 bits
              branch_pc, jump_pc, alu_out, zero_flag,                                  // 64 + 64 + 64 + 1 bits
              regfile_rdata_2_ex,                                                      // 64 bits
              instruction_ex[11:7]                                                     // 5 bits
            }),
   .dout    ({branch_mem, mem_read_mem, mem_write_mem, mem_2_reg_mem, reg_write_mem,
              branch_pc_mem, jump_pc_mem, alu_out_mem, zero_flag_mem,
              regfile_rdata_2_mem,
              instruction_mem[11:7]
            })
);

// The data memory.
sram_BW64 #(
   .ADDR_W(10),
   .DATA_W(64)
) data_memory(
   .clk      (clk            ),
   .addr     (alu_out_mem        ),
   .wen      (mem_write_mem      ),
   .ren      (mem_read_mem       ),
   .wdata    (regfile_rdata_2_mem),
   .rdata    (mem_data       ),   
   .addr_ext (addr_ext_2     ),
   .wen_ext  (wen_ext_2      ),
   .ren_ext  (ren_ext_2      ),
   .wdata_ext(wdata_ext_2    ),
   .rdata_ext(rdata_ext_2    )
);

// Pipeline: MEM_WB stage
reg_arstn_en#(
   .DATA_W(135)
)
pipeline_MEM_WB(
   .clk     (clk),
   .arst_n  (arst_n),
   .en      (enable),
   .din     ({mem_2_reg_mem, reg_write_mem,  // 2 bits
              mem_data, alu_out_mem,         // 64 + 64 bits
              instruction_mem[11:7]          // 5 bits
            }),
   .dout    ({mem_2_reg_wb, reg_write_wb,
              mem_data_wb, alu_out_wb,
              instruction_wb[11:7]
            })
);

mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (mem_data_wb     ),
   .input_b  (alu_out_wb      ),
   .select_a (mem_2_reg_wb ),
   .mux_out  (regfile_wdata)
);

endmodule


