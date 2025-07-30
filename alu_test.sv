`include "defines.sv"
class alu_test;
        //PROPERTIES
        //virtual interface for driver,monitor and reference model
        virtual alu_if drv_vif;
        virtual alu_if mon_vif;
        virtual alu_if ref_vif;
        //Declaring handle for environment
        alu_environment env;
        //Methods
        //Explicitly overriding the constructor to connect the virtual intefaces from driver,monitor, and reference model to test
        function new(virtual alu_if drv_vif,
                        virtual alu_if mon_vif,
                        virtual alu_if ref_vif);
                this.drv_vif = drv_vif;
                this.mon_vif = mon_vif;
                this.ref_vif = ref_vif;
        endfunction

        //Task which builds the object for environment handlie and calls the build and start methods of the environment
        task run();
                env=new(drv_vif,mon_vif,ref_vif);
                env.build();
                env.start();
        endtask
endclass
class test1 extends alu_test;
 alu_transaction1 trans_1;
  function new(virtual alu_if drv_vif,virtual alu_if mon_vif, virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans_1 = new();
    env.gen.blueprint= trans_1;
    end
    env.start;
  endtask
endclass

class test2 extends alu_test;
 alu_transaction2 trans_2;
 function new(virtual alu_if drv_vif,virtual alu_if mon_vif, virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    $display("child test");
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans_2 = new();
    env.gen.blueprint= trans_2;
    end
    env.start;
  endtask
endclass

class test3 extends alu_test;
 alu_transaction3 trans_3;
  function new(virtual alu_if drv_vif,virtual alu_if mon_vif, virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    $display("child test");
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans_3 = new();
    env.gen.blueprint= trans_3;
    end
    env.start;
  endtask
endclass

class test4 extends alu_test;
 alu_transaction4 trans_4;
  function new(virtual alu_if drv_vif,virtual alu_if mon_vif, virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
   // $display("child test");
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans_4 = new();
    env.gen.blueprint= trans_4;
    end
    env.start;
  endtask
endclass

class test_regression extends alu_test;
alu_transaction  trans;
alu_transaction1 trans1;
alu_transaction2 trans2;
alu_transaction3 trans3;
alu_transaction4 trans4;
  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    //$display("child test");
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
///////////////////////////////////////////////////////
    begin
    trans = new();
    env.gen.blueprint= trans;
    end
    env.start;
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    trans1 = new();
    env.gen.blueprint= trans1;
    end
    env.start;
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    trans2 = new();
    env.gen.blueprint= trans2;
    end
    env.start;
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    trans3 = new();
    env.gen.blueprint= trans3;
    end
    env.start;
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    trans4 = new();
    env.gen.blueprint= trans4;
    end
    env.start;
//////////////////////////////////////////////////////
  endtask
endclass
