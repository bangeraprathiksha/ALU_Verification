`include "alu_if.sv"
`include "alu_pkg.sv"
`include "alu.v"

module top();
    import alu_pkg::*;

    // Clock and Reset
    bit CLK = 0;
    bit RST = 0;

    // Clock generation
    initial forever #5 CLK = ~CLK;

    // Reset generation
    initial begin
        RST = 0;
        repeat(5) @(posedge CLK); // Hold reset for 2 cycles
        RST = 1;
    end

    // Instantiate interface
    alu_if intrf(CLK, RST);

    // Instantiate DUT
    ALU_DESIGN #(.DW(`width), .CW(`cwidth)) DUV (
        .OPA        (intrf.OPA),
        .OPB        (intrf.OPB),
        .CMD        (intrf.CMD),
        .MODE       (intrf.MODE),
        .CE         (intrf.CE),
        .CIN        (intrf.CIN),
        .INP_VALID  (intrf.INP_VALID),
        .RES        (intrf.RES),
        .COUT       (intrf.COUT),
        .OFLOW      (intrf.OFLOW),
        .ERR        (intrf.ERR),
        .E          (intrf.E),
        .G          (intrf.G),
        .L          (intrf.L),
        .CLK        (CLK),
        .RST        (RST)
    );

    // Instantiate test
    alu_test tb = new(intrf.DRV, intrf.MON, intrf.REF_SB);

    // Print DUT inputs every cycle (when CE and INP_VALID are high)
   /*always @(posedge CLK) begin
        if (intrf.CE && intrf.INP_VALID == 2'b11) begin
          $display("DUT INPUTS: OPA=%0d, OPB=%0d, CMD=%0d, MODE=%0b, CIN=%0b, INP_VALID=%b, CE=%b @%0t",
                      intrf.OPA, intrf.OPB, intrf.CMD, intrf.MODE, intrf.CIN, intrf.INP_VALID, intrf.CE, $time);
        end
    end*/

    // Print DUT outputs every clock edge
    /*always @(posedge CLK) begin
        $display("DUT OUTPUTS: RES=%0d, COUT=%0b, OFLOW=%0b, ERR=%0b, E=%0b, G=%0b, L=%0b @%0t",
                  intrf.RES, intrf.COUT, intrf.OFLOW, intrf.ERR, intrf.E, intrf.G, intrf.L, $time);
    end*/

    // Start test
    initial begin
        tb.run();
        #2000;
        $finish();
    end

endmodule
