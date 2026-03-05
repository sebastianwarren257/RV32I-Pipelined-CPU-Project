module dmem(
    input wire Clk,
    input wire [2:0]funct3,
    input wire [31:0] addr,
    input wire [31:0] wri_data,
    output reg [31:0] read_data,
    input wire Memread, Memwrite //look into assigning memread to 0 at beginning of every access so that there is a posedge whenever memread is 1
);
    reg [7:0] memory [65535:0];//byte addressable 
    reg Memread_internal = 1'b0;
    /*always @(posedge Clk) begin
        if (Memwrite) begin
            $display("*** DMEM WRITE: addr=0x%h, data=0x%h, funct3=%h @ time=%0t", 
                     addr, wri_data, funct3, $time);
        end
        if (Memread) begin
            $display("*** DMEM READ: addr=0x%h, funct3=%h @ time=%0t", 
                     addr, funct3, $time);
        end
    end
    always @(posedge Clk) begin
    $display("DMEM MemRead=%b @ time=%0t", Memread, $time);
    $display("MEM[0x10..0x13] = %h%h%h%h",
             memory[19], memory[18], memory[17], memory[16]);
    end*/
    integer i;
    initial begin
    for (i = 0; i < 65536; i = i + 1) begin
        memory[i] = 8'h00;
    end
    end
    always @(posedge Clk or posedge Memread)begin
        if(Memread) begin
        Memread_internal = #1 Memread && !Memread_internal;
        Memread_internal = #5 1'b0;
        end
    end
    always_ff @(posedge Clk) begin
        if(Memwrite) begin
            case (funct3)
                3'h0:begin //SB
                    memory[addr] <=  wri_data[7:0];
                end
                3'h1:begin //SH
                    memory[addr] <=  wri_data[7:0];
                    memory[addr+1] <=  wri_data[15:8];
                end
                3'h2:  begin //SW
                    memory[addr] <=  wri_data[7:0];
                    memory[addr+1] <=  wri_data[15:8];
                    memory[addr+2] <=  wri_data[23:16];
                    memory[addr+3] <= wri_data[31:24];
                end
            endcase
        end
    end

    always_ff @(posedge Memread_internal or posedge Clk) begin //works like this but reads a cycle late so everything is pushed back and messes up. Ask if should be combinational or not and how to fix.
        if(Memread_internal) begin
            case (funct3)
                3'h0:begin //LB
                    read_data[7:0] <= #1 memory[addr];
                    read_data[31:8] <= #1 {24{memory[addr][7]}};
                end
                3'h1:begin  //LH
                    read_data[7:0] <= #1 memory[addr];
                    read_data[15:8] <= #1 memory[addr+1];
                    read_data[31:16] <= #1 {16{memory[addr+1][7]}};
                end
                3'h2:begin //LW
                    read_data[7:0] <= #1 memory[addr];
                    read_data[15:8] <= #1 memory[addr+1];
                    read_data[23:16] <= #1 memory[addr+2];
                    read_data[31:24] <= #1 memory[addr+3];
                end
                 3'h4: begin //LBU
                    read_data[7:0] <= #1 memory[addr];
                    read_data[31:8] <= #1 24'b0;
                 end
                 3'h5:begin //LHU
                    read_data[7:0] <= #1 memory[addr];
                    read_data[15:8] <= #1 memory[addr+1];
                    read_data[31:16] <= #1 16'b0;
                 end
            endcase
        end
        else read_data<= #1 32'b0;
    end
endmodule