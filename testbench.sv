module testbench;
  
  reg [5:0] A, B;           
  reg sel, clk;             
  wire E1, G1, S1;          
  wire E2, G2, S2;          
  integer i, j , k;             

  // create check_comparator instance
  check_comparator uut1 (.A(A),.B(B),.sel(sel),.clk(clk),.E(E1),.G(G1),.S(S1));

  // create full_circuit instance
  full_circuit uut2 (.A(A),.B(B), .clk(clk), .sel(sel),.E(E2),.G(G2),.S(S2));

  // Clock generation
  initial begin
    clk = 0;
    forever #25 clk = ~clk; 
  end

  // Test logic
  initial begin
    $display("Verification started...");
    for (i = 0; i < 64; i = i + 1) begin
      for (j = 0; j < 64; j = j + 1) begin  
        for (k = 0 ; k <2 ; k=k +1)begin
          @(posedge clk)
          sel = k;
          A = i[5:0];
          B = j[5:0];
          @(posedge clk)
          if ((E1 !== E2) || (G1 !== G2) || (S1 !== S2)) begin
           $display("========================================TEST FAILED========================================");
            $display("sel = %b, A = %b, B = %b", sel, A, B);
            $display("check_comparator: E = %b, G = %b, S = %b", E1, G1, S1);
            $display("full_circuit: E = %b, G = %b, S = %b", E2, G2, S2);
          end 
        end
      end
    end
    $finish;	
  end
endmodule