module mux_2 
  #(
   parameter integer DATA_W = 16
   )(
      input  wire [DATA_W-1:0] input_a,
      input  wire [DATA_W-1:0] input_b,
      input  wire              select_a,
      output reg  [DATA_W-1:0] mux_out
   );

   always@(*)begin
      if(select_a == 1'b1)begin
         mux_out = input_a;
      end else begin
         mux_out = input_b;
      end
   end
endmodule

