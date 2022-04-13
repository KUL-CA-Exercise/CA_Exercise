module hazard_detection(
    input [4:0] rs1_id,
    input [4:0] rs2_id,
    input [4:0] rd_ex,
    input wire mem_read_ex,

    output reg pc_w,
    output reg pipeline_id_en,
    output reg hazard_mux_sel
)

    always @(*) begin
        if(mem_read_ex && (rd_ex == rs1_id || rd_ex == rs2_id)) begin
            // Load-use hazard: stall
            pc_w = 1'b0;
            pipeline_id_en = 1'b0;
            hazard_mux_sel = 1'b1;
        end else begin
            // no hazard
            pc_w = 1'b1;
            pipeline_id_en = 1'b1;
            hazard_mux_sel = 1'b0
        end
    end

endmodule