`include "defines.sv"
`include "alu.v"
`include "alu_pkg.sv"
`include "alu_if.sv"
module top( );
    import alu_pkg::*;
  //Declaring variables for clock and reset
    bit CLK;
    bit RST;

  //Generating the clock
  initial
    begin
     forever #10 CLK=~CLK;
    end
  //Asserting and de-asserting the reset
  initial begin
  	RST = 0;
  	repeat(20) @(posedge CLK); // Hold reset 5 cycles
  	RST = 1;
  end

  //Instantiating the interface
    alu_if intrf(CLK,RST);
  //Instantiating the DUV
    ALU_DESIGN #(.DW(`width),.CW(`cwidth))
        DUV (.OPA(intrf.OPA),
            .OPB(intrf.OPB),
            .MODE(intrf.MODE),
            .CMD(intrf.CMD),
            .CE(intrf.CE),
            .CIN(intrf.CIN),
            .INP_VALID(intrf.INP_VALID),
            .RES(intrf.RES),
            .COUT(intrf.COUT),
            .OFLOW(intrf.OFLOW),
            .ERR(intrf.ERR),
            .E(intrf.E),
            .G(intrf.G),
            .L(intrf.L),
            .CLK(CLK),
            .RST(RST)
           );
  //Instantiating the Test
    alu_test tb= new(intrf.DRV,intrf.MON,intrf.REF_SB);
    //test1 tb1= new(intrf.DRV,intrf.MON);
    //test2 tb2= new(intrf.DRV,intrf.MON);
    //test3 tb3= new(intrf.DRV,intrf.MON);
    //test4 tb4= new(intrf.DRV,intrf.MON);
    //test_regression tb_regression= new(intrf.DRV,intrf.MON,intrf.REF_SB);

//Calling the test's run task which starts the execution of the testbench architecture
  initial
   begin
   // tb_regression.run();
    tb.run();
    $finish();
   end
endmodule
                      
