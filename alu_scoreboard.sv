`include "defines.sv"
class alu_scoreboard;
        //PROPERTIES
        //alu transaction handle
        alu_transaction ref2sb_trans, mon2sb_trans;
        //Mailbox for from reference model to scoreboard connection
        mailbox #(alu_transaction) mbx_rs;
        //Mailbox for from monitor to scoreboard connection
        mailbox #(alu_transaction) mbx_ms;


        //Variables to indicate no:of matches and mismatches
        int MATCH,MISMATCH;

        //METHODS
        //Explicitly overriding the constructor to make mailbox connection from monitor
        //to scoreboard, to make mailbox connection from reference model to scoreboard
        function new(mailbox #(alu_transaction) mbx_rs,
                     mailbox #(alu_transaction) mbx_ms);
                this.mbx_rs=mbx_rs;
                this.mbx_ms=mbx_ms;
        endfunction

        //Task which collects data_out from reference model and scoreboard
        //and sotres them in their respective memories
        task start();
                for(int i=0;i<`no_of_trans;i++)
                begin
                        ref2sb_trans=new();
                        mon2sb_trans=new();
                        // fork
                        begin
                        	//getting the reference model transaction from mailbox
                                mbx_rs.get(ref2sb_trans);
                        end
                        begin
                        //getting the monitor transaction from mailbox
                                mbx_ms.get(mon2sb_trans);
                        end
                        compare_report();
                        //   join
                end
        endtask

        //Task which compares the memories and generates the report
        task compare_report();
                if((ref2sb_trans.RES == mon2sb_trans.RES) && (ref2sb_trans.COUT == mon2sb_trans.COUT) && (ref2sb_trans.OFLOW == mon2sb_trans.OFLOW) && (ref2sb_trans.E == mon2sb_trans.E) && (ref2sb_trans.G == mon2sb_trans.G) && (ref2sb_trans.L == mon2sb_trans.L)&& (ref2sb_trans.ERR == mon2sb_trans.ERR))
                begin
                        $display("SCOREBOARD REF RES[mon]=%0d, RES[ref]=%0d COUT[mon]=%0d, COUT[ref]=%0d OFLOW[mon]=%0d, OFLOW[ref]=%0d E[mon]=%0d, E[ref]=%0d G[mon]=%0d, G[ref]=%0d L[mon]=%0d, L[ref]=%0d ERR[mon]=%0d, ERR[ref]=%0d",mon2sb_trans.RES,ref2sb_trans.RES,mon2sb_trans.COUT,ref2sb_trans.COUT,mon2sb_trans.OFLOW,ref2sb_trans.OFLOW, mon2sb_trans.E,ref2sb_trans.E,mon2sb_trans.G,ref2sb_trans.G,mon2sb_trans.L,ref2sb_trans.L,mon2sb_trans.ERR,ref2sb_trans.ERR,$time);
                        MATCH++;
                        $display("DATA MATCH SUCCESSFUL MATCH=%d",MATCH);
                end
                else
                begin

                        MISMATCH++;
                        $display("DATA MATCH FAILED MISMATCH=%d",MISMATCH);
                end
  endtask
endclass
           
