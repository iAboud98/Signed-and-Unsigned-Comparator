//-> Full circuit that combines both comparator types and the output choosen based on sel value
//-> sel = 0 (unsigned)
//-> sel = 1 (signed)
module full_circuit ( A, B ,clk, sel, E, G, S );
  input [5:0] A, B;
  input sel , clk;
  wire [5:0] reg_A, reg_B;
  wire  WE,WG,WS;
  output  E,G,S;
  
  //-> save input into registers to syncronize the circuit results
  six_bit_register r1(reg_A,clk,A);
  six_bit_register r2(reg_B,clk,B);
 
  
  wire eq_signed, eq_unsigned, g_signed, g_unsigned, s_signed, s_unsigned;
  
  //-> add the input for both comparators
  comparatorForUnsigned c1 (.A(reg_A),.B(reg_B),.Equal(eq_unsigned),.Greater(g_unsigned),.Smaller(s_unsigned));
  comparatorForSigned c2 (.A(reg_A),.B(reg_B),.Equal(eq_signed),.Greater(g_signed),.Smaller(s_signed));
  
  //-> select the wanted value based on sel
  mux2to1 mux_E ( .unsigned_output(eq_unsigned), .signed_output(eq_signed), .sel(sel), .result(WE) );
  mux2to1 mux_G ( .unsigned_output(g_unsigned), .signed_output(g_signed), .sel(sel), .result(WG) );
  mux2to1 mux_S ( .unsigned_output(s_unsigned), .signed_output(s_signed), .sel(sel), .result(WS) );
  
  //-> save each output in one bit register (dff)
  DFF #(12) df1 (E,clk,WE);
  DFF #(12) df2 (G,clk,WG);
  DFF #(12) df3 (S,clk,WS);
  
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> module that combines Equal and Greater modules for unsigned cases
module comparatorForUnsigned ( A, B, Equal, Greater, Smaller );
 
  input [5:0] A, B;
  output reg Equal, Greater, Smaller;
  
  wire [5:0] reg_A, reg_B;  
    
  equal_comparator e1(.A(A), .B(B), .Equal(Equal));
  greater_comparator_unsigned g1(.A(A), .B(B), .A_Greater(Greater));
  nor #5 (Smaller, Equal, Greater);

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> module that combines Equal and Greater modules for signed cases
module comparatorForSigned (A, B, Equal, Greater, Smaller);

  input [5:0] A, B;
  output reg Equal, Greater, Smaller;

  equal_comparator e1 (.A(A), .B(B), .Equal(Equal));
  greater_comparator_signed g1 (.A(A), .B(B), .A_Greater(Greater));
  nor #5 (Smaller, Equal, Greater);

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> Simple module checks if A and B are the same
module equal_comparator( A, B, Equal );

  input [5:0] A, B;       
  output Equal;

  wire [5:0] xnor_result;

  genvar j;
  generate
    for (j = 0; j < 6; j = j + 1) begin : xnor_loop
      xnor #10 (xnor_result[j], A[j], B[j]);  
    end
  endgenerate

  and #8 (Equal, xnor_result[0], xnor_result[1], xnor_result[2], xnor_result[3], xnor_result[4], xnor_result[5]);

endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> Module given A and B inputs, result is 1 if A is greater and 0 if not, It is just used for unsigned numbers case
module greater_comparator_unsigned( A, B, A_Greater );

  input [5:0] A, B;       
  output A_Greater;
 
  wire [5:0] notB, prev, eq;
  wire [4:0] and_result;
  
  genvar i;
  generate
    for (i = 0; i < 6; i = i + 1) begin : xnor_loop
      not #3 (notB[i], B[i]);
      and #8 (prev[i], A[i], notB[i]);
      xnor #10 (eq[i], A[i], B[i]);
    end
  endgenerate
  
  and #8 (and_result[4], eq[5], prev[4]);
  and #8 (and_result[3], eq[5], eq[4], prev[3]);
  and #8 (and_result[2], eq[5], eq[4], eq[3], prev[2]);
  and #8 (and_result[1], eq[5], eq[4], eq[3], eq[2], prev[1]);
  and #8 (and_result[0], eq[5], eq[4], eq[3], eq[2], eq[1], prev[0]);
  
  or #8 (A_Greater, prev[5], and_result[4], and_result[3], and_result[2], and_result[1], and_result[0]);  

endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> Module given A and B inputs, result is 1 if A is greater and 0 if not, It is just used for signed numbers case
module greater_comparator_signed( A, B, A_Greater );
  
  input [5:0] A, B;
  output A_Greater;

  wire A_neg, B_neg;
  wire not_A_neg, not_B_neg;
  wire cond1, cond2, cond3;
  wire [4:0] and_result;

  //-> This for the last bit to distinguish between positive and negative numbers
  assign A_neg = A[5]; 
  assign B_neg = B[5]; 
  
  not #3 (not_A_neg, A_neg);
  not #3 (not_B_neg, B_neg);

  and #8 (cond1, A_neg, not_B_neg);

  and #8 (cond2, not_A_neg, B_neg);

  wire prev[5:0], eq[5:0], notB[5:0];
  
  genvar i;
  generate
    for (i = 0; i < 6; i = i + 1) begin
      not #3 (notB[i], B[i]);
      and #8 (prev[i], A[i], notB[i]);
      xnor #10 (eq[i], A[i], B[i]);
    end
  endgenerate

  and #8 (and_result[4], eq[5], prev[4]);
  and #8 (and_result[3], eq[5], eq[4], prev[3]);
  and #8 (and_result[2], eq[5], eq[4], eq[3], prev[2]);
  and #8 (and_result[1], eq[5], eq[4], eq[3], eq[2], prev[1]);
  and #8 (and_result[0], eq[5], eq[4], eq[3], eq[2], eq[1], prev[0]);

  or #8 (cond3, prev[5], and_result[4], and_result[3], and_result[2], and_result[1], and_result[0]);

  wire cond1_not, cond2_or_cond3;

  not #3 (cond1_not, cond1);               
  or #8 (cond2_or_cond3, cond2, cond3);   
  and #8 (A_Greater, cond1_not, cond2_or_cond3); 

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> simple 2-1 Mux built structuraly using gates, delays are added as well
module mux2to1 ( unsigned_output, signed_output, sel, result );
  
  input unsigned_output;
  input signed_output;
  input sel;
  output result;
  
  wire w1, w2, not_sel;
  
  not #3 ( not_sel, sel);
  and #8 ( w1, sel, signed_output );
  and #8 ( w2, not_sel, unsigned_output );
  or #8 ( result, w1, w2 );
  
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> Dff works as 1bit register
primitive DFF (q, clk, data);
  output q;
  input clk, data;
  reg q;

  table
    (01) 0 : ? : 0;
    (01) 1 : ? : 1;
    (0?) 1 : 1 : 1;
    (0?) 0 : 0 : 0;
    (?0) ? : ? : -;
    ?   (??) : ? : -;
  endtable
endprimitive

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> 6 dff together as 6bit register
module six_bit_register ( q, clk, data );
  output [5:0] q;
  input clk;
  input [5:0] data;

  DFF dff0 (q[0], clk, data[0]);
  DFF dff1 (q[1], clk, data[1]);
  DFF dff2 (q[2], clk, data[2]);
  DFF dff3 (q[3], clk, data[3]);
  DFF dff4 (q[4], clk, data[4]);
  DFF dff5 (q[5], clk, data[5]);

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-> This module is a behavioral comparator handels both signed/unsigned cases and is used to check the structural comparator results
module check_comparator ( A, B, sel, clk, E, G, S );
  input [5:0] A, B;
  input sel, clk;
  output E, G, S;

  wire [5:0] reg_A, reg_B;
  wire WE, WG, WS;

  // Input registers
  six_bit_register r1 (reg_A,clk ,A);
  six_bit_register r2 (reg_B,clk,B);

  reg neg_A, neg_B;
  reg eq, gt, lt;

  // Internal always block for combinational logic
  always @(*) begin
    neg_B = reg_B[5];
    neg_A = reg_A[5];

    if (reg_A == reg_B) begin
      eq = 1;
      gt = 0;
      lt = 0;
    end else begin
      if (sel == 0) begin // Unsigned comparison
        if (reg_A > reg_B) begin
          eq = 0;
          gt = 1;
          lt = 0;
        end else begin
          eq = 0;
          gt = 0;
          lt = 1;
        end
      end else begin // Signed comparison
        if (neg_A > neg_B) begin
          eq = 0;
          gt = 0;
          lt = 1;
        end else if (neg_B > neg_A) begin
          eq = 0;
          gt = 1;
          lt = 0;
        end else if (neg_A == 0 && neg_B == 0) begin
          if (reg_A[4:0] > reg_B[4:0]) begin
            eq = 0;
            gt = 1;
            lt = 0;
          end else begin
            eq = 0;
            gt = 0;
            lt = 1;
          end
        end else begin
          if (reg_A[4:0] > reg_B[4:0]) begin
            eq = 0;
            gt = 1;
            lt = 0;
          end else begin
            eq = 0;
            gt = 0;
            lt = 1;
          end
        end
      end
    end
  end

  // Output registers
  DFF #(12) df1 (E,clk,eq);
  DFF #(12) df2 (G, clk,gt);
  DFF #(12) df3 (S, clk,lt);

endmodule 