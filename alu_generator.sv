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
                for(int i=0; i<`no_of_trans;i++)
                begin
                        //Randomizing the inputs
                        blueprint.randomize();
                        //Putting the randomized inputs to mailbox
                        mbx_gd.put(blueprint.copy());
                        $display("GENERATOR Randomized transaction OPA= %0d, OPB=%0d, INP_VALID=%0b, CMD=%0b, MODE=%0b, CE=%0b, CIN=%0d",blueprint.OPA,blueprint.OPB,blueprint.INP_VALID,blueprint.CMD,blueprint.MODE,blueprint.CE,blueprint.CIN);
                end
        endtask
endclass
