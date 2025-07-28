`include "defines.sv"
class alu_reference_model;
        //PROPERTIES
        //alu transaction class handle
        alu_transaction ref_trans;
        //Mailbox for driver to reference model connection
        mailbox #(alu_transaction) mbx_dr;
        //Mailbox for refernce model to scoreboard  connection
        mailbox #(alu_transaction) mbx_rs;
        //Virtual interface with driver modport and it's instance
        virtual alu_if.REF_SB vif;
//=======================================================================
        bit got_input;
        alu_transaction temp_trans;
        logic [2:0] amount;
//======================================================================
        //METHODS
        //Explicitly overriding the constructor to make the mailbox connection from diver to reference model
        //to make the mailbox connection from reference model to scoreboard
        //To connect the virtual interface from reference model to environment
        function new(mailbox #(alu_transaction) mbx_dr,
                     mailbox #(alu_transaction) mbx_rs,
                     virtual alu_if.REF_SB vif);
                this.mbx_dr = mbx_dr;
                this.mbx_rs = mbx_rs;
                this.vif = vif;
        endfunction

                        function void reset_outputs();
                                ref_trans.RES   = 0;
                                ref_trans.COUT  = 0;
                                ref_trans.OFLOW = 0;
                                ref_trans.E     = 0;
                                ref_trans.G     = 0;
                                ref_trans.L     = 0;
                                ref_trans.ERR   = 0;
                        endfunction

        //task which mimics the functionality of the ALU
        task start();
                for(int i=0; i<`no_of_trans;i++)begin
                        ref_trans = new();
                        //Getting the driver transaction from mailbox
                        mbx_dr.get(ref_trans);
                         amount = ref_trans.OPB[2:0];
                         $display("time[%0t] REFERENCE GOT THE DATA FROM DRIVER OPA=%0d, OPB= %0d CMD=%0d, MODE=%0b, INP_VALID=%0b, CE=%0b, CIN=%0b",$time,ref_trans.OPA,ref_trans.OPB,ref_trans.CMD,ref_trans.MODE,ref_trans.INP_VALID,ref_trans.CE,ref_trans.CIN);

                        repeat(1) @(posedge vif.CLK)
//=========================================================================================================================
                        if(vif.RST) begin  // or vif.ref_cb.RST if declared in ref_cb
                                reset_outputs();
                                continue;
                        end


                        // === Handle multicycle path (partial or full input) ===
                        else if (((ref_trans.INP_VALID inside {2'b01, 2'b10}) && ref_trans.CE &&((ref_trans.MODE && ref_trans.CMD inside {0, 1, 2, 3, 8, 9, 10}) ||(!ref_trans.MODE && ref_trans.CMD inside {0, 1, 2, 3, 4, 5, 12, 13})))) begin

                        got_input = 0;

                        for (int j = 0; j < 16; j++) begin
                                @(posedge vif.CLK);
                                if (mbx_dr.try_get(temp_trans)) begin
                                        ref_trans = temp_trans;
                                        if (ref_trans.INP_VALID == 2'b11) begin
                                                got_input = 1;
                                                        break;
                                        end
                                end
                        end

                        if (got_input == 0) begin
                                 ref_trans.ERR = 1;  // Input never completed
                        end
                end
//=====================================================================================================

                        // Only process when INP_VALID is valid and CE = 1
                        if (ref_trans.INP_VALID == 2'b11 && ref_trans.CE) begin
                                case (ref_trans.MODE)
                                        1'b1: begin // Arithmetic mode
                                        case (ref_trans.CMD)
                                                4'b0000: begin // ADD
                                                {ref_trans.COUT, ref_trans.RES} = ref_trans.OPA + ref_trans.OPB;
                                                end

                                                4'b0001: begin // SUB
                                                ref_trans.RES = ref_trans.OPA - ref_trans.OPB;
                                                ref_trans.OFLOW = (ref_trans.OPA < ref_trans.OPB)? 1'b1: 1'b0;
                                                end

                                                4'b0010: begin // ADD_CIN
                                                {ref_trans.COUT, ref_trans.RES} = ref_trans.OPA + ref_trans.OPB + ref_trans.CIN;
                                                end

                                                4'b0011: begin // SUB_CIN
                                                ref_trans.RES = ref_trans.OPA - ref_trans.OPB - ref_trans.CIN;
                                                ref_trans.OFLOW = (ref_trans.OPA < ref_trans.OPB + ref_trans.CIN)  ? 1'b1: 1'b0;
                                                end

                                                4'b1000: begin //CMP
                                                if(ref_trans.OPA == ref_trans.OPB)
                                                        ref_trans.E = 1'b1;
                                                else if(ref_trans.OPA > ref_trans.OPB)
                                                        ref_trans.G = 1'b1;
                                                else
                                                        ref_trans.L = 1'b1;
                                                end

                                                4'b1001: begin // INC_MUL
                                                repeat(1) begin @(posedge vif.CLK); end
                                                ref_trans.RES = (ref_trans.OPA +1) * (ref_trans.OPB +1) ;
                                                end

                                                4'b1010: begin // SHIFT_MUL
                                                repeat(1) begin @(posedge vif.CLK); end
                                                ref_trans.RES = (ref_trans.OPA << 1) * ref_trans.OPB ;
                                                end

                                                default: reset_outputs();
                                        endcase
                                        end
                                        1'b0: begin // Logical/Comparison/Shift/Rotate mode
                                        case (ref_trans.CMD)
                                                4'b0000: ref_trans.RES = {1'b0,ref_trans.OPA & ref_trans.OPB};//and
                                                4'b0001: ref_trans.RES = {1'b0,~(ref_trans.OPA & ref_trans.OPB)};//nand
                                                4'b0010: ref_trans.RES = {1'b0,ref_trans.OPA | ref_trans.OPB};//or
                                                4'b0011: ref_trans.RES = {1'b0,~(ref_trans.OPA | ref_trans.OPB)};//nor
                                                4'b0100: ref_trans.RES = {1'b0,ref_trans.OPA ^ ref_trans.OPB};//xor
                                                4'b0101: ref_trans.RES = {1'b0,~(ref_trans.OPA ^ ref_trans.OPB)};//xnor
                                                4'b1100:begin
                                                        if (amount == 0)
                                                                ref_trans.RES = {1'b0, ref_trans.OPA};
                                                        else
                                                                ref_trans.RES = {1'b0, (ref_trans.OPA << amount) | (ref_trans.OPA >> (`width - amount))};
                                                        ref_trans.ERR = (`width > 3 && | ref_trans.OPB[`width-1:3]) ? 1'b1 : 1'b0;
                                                end
                                                4'b1101:begin
                                                        if (amount == 0)
                                                                ref_trans.RES = {1'b0, ref_trans.OPA};
                                                        else
                                                                ref_trans.RES = {1'b0, (ref_trans.OPA >> amount) | (ref_trans.OPA << (`width - amount))};
                                                        ref_trans.ERR = (`width > 3 && |ref_trans.OPB[`width-1:3]) ? 1'b1 : 1'b0;
                                                end
                                                default: reset_outputs();
                                        endcase
                                        end
                                endcase

                        end
//==========================================================================================================
                        //only OPA is valid
                        else if ((ref_trans.INP_VALID == 2'b01 || ref_trans.INP_VALID == 2'b11) && ref_trans.CE) begin
                                case (ref_trans.MODE)
                                        1'b1: begin // Arithmetic mode
                                        case (ref_trans.CMD)
                                                4'b0100: begin // INC_A
                                                ref_trans.RES = ref_trans.OPA + 1;
                                                end

                                                4'b0101: begin // DEC_A
                                                ref_trans.RES = ref_trans.OPA - 1;
                                                end

                                                default: reset_outputs();
                                        endcase
                                        end
                                        1'b0: begin // Logical
                                        case (ref_trans.CMD)
                                                4'b0110: ref_trans.RES = {1'b0,~(ref_trans.OPA)};//NOT_A
                                                4'b1000: ref_trans.RES = {1'b0,ref_trans.OPA>>1};//SHR1_A
                                                4'b1001: ref_trans.RES = {1'b0,ref_trans.OPA << 1};//SHL1_A
                                                default: reset_outputs();
                                        endcase
                                        end
                                endcase

                        end
//===============================================================================================================
                        //only OPB is valid
                        else if ((ref_trans.INP_VALID == 2'b10 || ref_trans.INP_VALID == 2'b11) && ref_trans.CE) begin
                                case (ref_trans.MODE)
                                        1'b1: begin // Arithmetic mode
                                        case (ref_trans.CMD)
                                                4'b0110: begin // INC_B
                                                ref_trans.RES = ref_trans.OPB + 1;
                                                end

                                                4'b0111: begin // DEC_B
                                                ref_trans.RES = ref_trans.OPB - 1;
                                                end

                                                default: reset_outputs();

                                        endcase
                                        end
                                        1'b0: begin // Logical
                                        case (ref_trans.CMD)
                                                4'b0111: ref_trans.RES = {1'b0,~(ref_trans.OPB)};//NOT_B
                                                4'b1010: ref_trans.RES = {1'b0,ref_trans.OPB>>1};//SHR1_B
                                                4'b1011: ref_trans.RES = {1'b0,ref_trans.OPB << 1};//SHL1_B
                                                default: reset_outputs();

                                        endcase
                                        end
                                endcase

                        end
//============================================================================
                repeat(2) @(posedge vif.CLK);//#%^&&@*(
                 mbx_rs.put(ref_trans);

                 $display("time[%0t] REFERENCE PASSING THE DATA TO SCOREBOARD RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%0b, E=%0b, G=%0b, L=%0b",$time,ref_trans.RES,ref_trans.COUT,ref_trans.OFLOW,ref_trans.ERR,ref_trans.E,ref_trans.G,ref_trans.L);
                end
        endtask
endclass
~                                                                                                                     
