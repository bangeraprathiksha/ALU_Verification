`include "defines.sv"
//`include "alu_transaction.sv"
class alu_generator;
        //PROPERTIES
        //alu transaction class handle
        alu_transaction blueprint;
        //mailbox for generator to driver connection
        mailbox #(alu_transaction)mbx_gd;

        //METHODS
        //Explicitly overriding the constructor to make maibox connection
        //from generator to driver
        function new(mailbox #(alu_transaction)mbx_gd);
                this.mbx_gd = mbx_gd;
                blueprint = new();
        endfunction

        //Task to generate the random stimuli
        task start();
         for (int i = 0; i < `no_of_trans; i++) begin
    if (!blueprint.randomize()) begin
      $display("ERROR: Randomization failed at i=%0d", i);
    end
    mbx_gd.put(blueprint.copy());

    $display("GENERATOR: txn[%0d] OPA=%0d, OPB=%0d, INP_VALID=%b, CMD=%0d, MODE=%0b, CE=%0b, CIN=%0b",i, blueprint.OPA, blueprint.OPB, blueprint.INP_VALID, blueprint.CMD, blueprint.MODE, blueprint.CE, blueprint.CIN);
  end
endtask

endclass
