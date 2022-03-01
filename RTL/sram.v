//Instruction Memory
//Function: The instruction memory pointed by the PC is retrieved. Taking into account the input address (addr) the data will be put in the read data output (rdata).
//Inputs:
//clk: System clock
//arst_n: Asynchronous Reset
//wen: Write Enable Signal. Since the instruction memory is not written after initialization, this input must be statically deasserted (wen=0).
//Ren: Read Enable Signal. Since the instruction memory must be continuouslly read, this input must be statically asserted (ren=1).
//Outputs:
//rdata: Instruction read taking into account the address pointed.



//Data Memory
//Function: The data memory has 2 main functions. (1) In the case of a LW instruction, read the value pointed by the read address (addr) and put its value into the read data (rdata) (2) In the case of a SW instruction, store a word into the address pointed by the write address (addr)
//Taking into account the input address (addr) the data will be put in the read data output (rdata).
//Inputs:
//clk: System clock
//arst_n: Asynchronous Reset
//wen: Write Enable Signal. Since the instruction memory is not written after initialization, this input must be statically deasserted (wen=0).
//Ren: Read Enable Signal. Since the instruction memory must be continuouslly read, this input must be statically asserted (ren=1).
//Outputs:
//rdata: Instruction read taking into account the address pointed.



module sram_BW32#(
   parameter integer ADDR_W      = 8,
   parameter integer DATA_W      = 16
) (
		input wire			       clk,
		input wire	      [63:0] addr,
		input wire	      [63:0] addr_ext,
      input wire               wen,
      input wire               wen_ext,
      input wire               ren,
      input wire               ren_ext,
		input wire 	[DATA_W-1:0] wdata,
		input wire 	[DATA_W-1:0] wdata_ext,
		output reg	[DATA_W-1:0] rdata,
		output reg	[DATA_W-1:0] rdata_ext

   );
parameter integer SEL_W       = ADDR_W-7;
parameter integer MACRO_DEPTH = 128;
parameter integer N_MEMS      = 2**(ADDR_W)/MACRO_DEPTH;


reg  [      6:0] addr_i, addr_ext_i;
reg  [SEL_W-1:0] mem_sel;
reg  [SEL_W-1:0] mem_sel_ext;
wire [     31:0] data_i     [0:(2**SEL_W)-1];
wire [     31:0] data_ext_i [0:(2**SEL_W)-1];
reg              cs_i       [0:(2**SEL_W)-1];
reg              cs_ext_i   [0:(2**SEL_W)-1];
 
reg wen_n, wen_ext_n;

always@(*)begin
   rdata     = data_i    [mem_sel][DATA_W-1:0];
   rdata_ext = data_ext_i[mem_sel_ext][DATA_W-1:0]; 
end 


always@(*)begin
   addr_i      = addr    [8:2];
   addr_ext_i  = addr_ext[8:2];
   wen_n       = ~wen;
   wen_ext_n   = ~wen_ext;
   mem_sel     = addr    [ADDR_W-1+2:ADDR_W-SEL_W+2];
   mem_sel_ext = addr_ext[ADDR_W-1+2:ADDR_W-SEL_W+2];
end

genvar index_depth;
generate
   for (index_depth = 0; index_depth < N_MEMS; index_depth = index_depth+1) begin: process_for_mem
         always@(*) begin
           if(mem_sel == index_depth) begin
               cs_i[index_depth] =1'b0;
            end else begin
               cs_i[index_depth] = 1'b1;
            end
         end
         always@(*) begin
           if(mem_sel_ext == index_depth) begin
               cs_ext_i[index_depth] =1'b0;
            end else begin
               cs_ext_i[index_depth] = 1'b1;
            end
         end
      
         SRAM2RW128x32 dram_inst (
            .A1  (addr_i                 ),
            .A2  (addr_ext_i             ),
            .CE1 (clk                    ),
            .CE2 (clk                    ),
            .WEB1(wen_n                  ),
            .WEB2(wen_ext_n              ),
            .OEB1(cs_i[index_depth]      ),
            .OEB2(cs_ext_i[index_depth]  ),
            .CSB1(cs_i[index_depth]      ),
            .CSB2(cs_ext_i[index_depth]  ),
            .I1  ($unsigned(wdata)       ),
            .I2  ($unsigned(wdata_ext)   ),
            .O1  (data_i[index_depth]    ),
            .O2  (data_ext_i[index_depth])
         );
   end
endgenerate
	
endmodule


module sram_BW64#(
   parameter integer ADDR_W      = 8,
   parameter integer DATA_W      = 16
) (
		input wire			       clk,
		input wire	      [63:0] addr,
		input wire	      [63:0] addr_ext,
      input wire               wen,
      input wire               wen_ext,
      input wire               ren,
      input wire               ren_ext,
		input wire 	[DATA_W-1:0] wdata,
		input wire 	[DATA_W-1:0] wdata_ext,
		output reg	[DATA_W-1:0] rdata,
		output reg	[DATA_W-1:0] rdata_ext

   );
parameter integer SEL_W       = ADDR_W-7;
parameter integer MACRO_DEPTH = 128;
parameter integer N_MEMS      = 2**(ADDR_W)/MACRO_DEPTH;


reg  [      6:0] addr_i, addr_ext_i;
reg  [SEL_W-1:0] mem_sel;
reg  [SEL_W-1:0] mem_sel_ext;
wire [     31:0] data_i_H     [0:(2**SEL_W)-1];
wire [     31:0] data_i_L     [0:(2**SEL_W)-1];
wire [     31:0] data_ext_i_H [0:(2**SEL_W)-1];
wire [     31:0] data_ext_i_L [0:(2**SEL_W)-1];
reg              cs_i       [0:(2**SEL_W)-1];
reg              cs_ext_i   [0:(2**SEL_W)-1];
 
reg wen_n, wen_ext_n;

always@(*)begin
   rdata     = {    data_i_H[mem_sel]    ,     data_i_L[mem_sel]    };
   rdata_ext = {data_ext_i_H[mem_sel_ext], data_ext_i_L[mem_sel_ext]}; 
end 


always@(*)begin
   addr_i      = addr    [9:3];
   addr_ext_i  = addr_ext[9:3];
   wen_n       = ~wen;
   wen_ext_n   = ~wen_ext;
   mem_sel     = addr    [ADDR_W-1+3:ADDR_W-SEL_W+3];
   mem_sel_ext = addr_ext[ADDR_W-1+3:ADDR_W-SEL_W+3];
end

genvar index_depth;
generate
   for (index_depth = 0; index_depth < N_MEMS; index_depth = index_depth+1) begin: process_for_mem
         always@(*) begin
           if(mem_sel == index_depth) begin
               cs_i[index_depth] =1'b0;
            end else begin
               cs_i[index_depth] = 1'b1;
            end
         end
         always@(*) begin
           if(mem_sel_ext == index_depth) begin
               cs_ext_i[index_depth] =1'b0;
            end else begin
               cs_ext_i[index_depth] = 1'b1;
            end
         end
      
         SRAM2RW128x32 spad_inst_H (
            .A1  (addr_i                 ),
            .A2  (addr_ext_i             ),
            .CE1 (clk                    ),
            .CE2 (clk                    ),
            .WEB1(wen_n                  ),
            .WEB2(wen_ext_n              ),
            .OEB1(cs_i[index_depth]      ),
            .OEB2(cs_ext_i[index_depth]  ),
            .CSB1(cs_i[index_depth]      ),
            .CSB2(cs_ext_i[index_depth]  ),
            .I1  ($unsigned(wdata[DATA_W-1:DATA_W/2])),
            .I2  ($unsigned(wdata_ext[DATA_W-1:DATA_W/2])),
            .O1  (data_i_H[index_depth]  ),
            .O2  (data_ext_i_H[index_depth])
         );

         SRAM2RW128x32 spad_inst_L (
            .A1  (addr_i                 ),
            .A2  (addr_ext_i             ),
            .CE1 (clk                    ),
            .CE2 (clk                    ),
            .WEB1(wen_n                  ),
            .WEB2(wen_ext_n              ),
            .OEB1(cs_i[index_depth]      ),
            .OEB2(cs_ext_i[index_depth]  ),
            .CSB1(cs_i[index_depth]      ),
            .CSB2(cs_ext_i[index_depth]  ),
            .I1  ($unsigned(wdata[DATA_W/2-1:0])),
            .I2  ($unsigned(wdata_ext[DATA_W/2-1:0])),
            .O1  (data_i_L[index_depth]  ),
            .O2  (data_ext_i_L[index_depth])
         );
   end
endgenerate
	
endmodule