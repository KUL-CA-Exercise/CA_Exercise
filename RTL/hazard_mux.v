module hazard_mux(input wire sel,
                  input wire [8:0] ctrl_unit_out,
                  output reg [8:0] hazard_mux_out);

    always @(*) begin
        if (sel == 1'b0) begin
            // No hazard
            hazard_mux_out = ctrl_unit_out;
        end else begin
            hazard_mux_out = 9'b0;
        end
    end
    
endmodule
