//Register File
//Function: This block has 2 main functions (1) Read the registers pointed by the incoming addresses (raddr_1 and raddr_2) into the outputs rdata_1 and rdata_2 respectively. (2) Write the desired writing data (wdata) into the address pointed by the write address (waddr) if write enable (reg_write) is asserted.
//clk: System clock
//arst_n: Asynchronous Reset
//reg_write: Write enable signal. If reg_write is asserted the register file is written in the next clock cycle.
//Raddr_1 (5 bits): Address of the first register aimed to read.
//Raddr_2 (5 bits): Address of the second register aimed to read
//waddr (5 bits): Address of the register to be written.
//Wdata (16 bits): Incoming data to write.
//Outputs:
//rdata_1: Data read from address 1.
//rdata_2: Data read from address 2.

module register_file#(
   parameter integer DATA_W     = 16
)(
      input  wire              clk,
      input  wire              arst_n,
      input  wire              reg_write,
      input  wire [       4:0] raddr_1,
      input  wire [       4:0] raddr_2,
      input  wire [       4:0] waddr,
      input  wire [DATA_W-1:0] wdata,
      output reg  [DATA_W-1:0] rdata_1,
      output reg  [DATA_W-1:0] rdata_2
   );

   parameter integer N_REG      = 32;

   
   
   reg [DATA_W-1:0] reg_array     [0:N_REG-1];
   reg [DATA_W-1:0] reg_array_nxt [0:N_REG-1];


   integer idx;


   always@(*) begin
         rdata_1 = reg_array[raddr_1];
         rdata_2 = reg_array[raddr_2];
   end


   //Register file write process
   always@(*) begin
      for(idx=0; idx<N_REG; idx =idx+1)begin
         if((reg_write == 1'b1) && (waddr == idx)) begin
            reg_array_nxt[idx] = wdata;
         end else begin
            reg_array_nxt[idx] = reg_array[idx];
         end
      end
   end

   always@(posedge clk, negedge arst_n) begin
      if(arst_n == 1'b0)begin
         for(idx=0; idx<N_REG; idx =idx+1)begin
            reg_array[idx] <= 'b0;
         end
      end else begin
         for(idx=1; idx<N_REG; idx =idx+1)begin  // start from reg[1], as x0 should be constant-0.
            reg_array[idx] <= reg_array_nxt[idx];
         end
      end
   end

    
    
endmodule



