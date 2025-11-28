// No Reset
module shift #(
  parameter width_p = 4
)(input logic reset_i, 
  input logic data_i, 
  input logic en_i,
  output logic [width_p-1:0] data_o,
  input logic clk_i
);

always_ff @(posedge clk_i) begin
  if (en_i) begin
    data_o <= {data_o[width_p - 2:0], data_i};
  end
end

endmodule