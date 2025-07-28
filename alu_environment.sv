`include "defines.sv"
class alu_environment;
        //PROPERTIES
        //virtual intefraces for driver, moniotr and reference model
        virtual alu_if drv_vif;
        virtual alu_if mon_vif;
        virtual alu_if ref_vif;
        //mailbox for generator to driver connection
        mailbox #(alu_transaction) mbx_gd;
        //mailbox for driver to reference model connection
        mailbox #(alu_transaction) mbx_dr;
        //mailboc for reference model to scoreboard connection
        mailbox #(alu_transaction) mbx_rs;
        //mailbox to monitor to scoreboard connection
        mailbox #(alu_transaction) mbx_ms;

        //declaring handles for component
        //generator, driver,monitor reference model and scoreboard
        alu_generator gen;
        alu_driver drv;
        alu_monitor mon;
        alu_reference_model ref_sb;
        alu_scoreboard scb;

        //Methods
        //Explicitly overriding the constructor to connect the virtual interface
        //from driver,monitor and reference model to test
        function new(virtual alu_if drv_vif,
                        virtual alu_if mon_vif,
                        virtual alu_if ref_vif);
                this.drv_vif=drv_vif;
                this.mon_vif=mon_vif;
                this.ref_vif=ref_vif;
        endfunction
        //Task which creates for all the mailoxes and components
        task build();
        begin
        //Creating objects for mailboxes
        mbx_gd=new();
        mbx_dr=new();
        mbx_rs=new();
        mbx_ms=new();
        //Creating objects for componets and passing the arguments in the function new()i,e the constructor


        gen=new(mbx_gd);
        drv=new(mbx_gd,mbx_dr,drv_vif);
        mon=new(mbx_ms,mon_vif);
        ref_sb=new(mbx_dr,mbx_rs,ref_vif);
        scb=new(mbx_rs,mbx_ms);

        end
        endtask

        //task which calls the start module of each component
        //and also calss the compare and report method
        task start();
        fork
                gen.start();
                drv.start();
                mon.start();
                scb.start();
                ref_sb.start();
        join
        scb.compare_report();
        endtask


endclass
