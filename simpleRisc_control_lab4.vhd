use work.bv_arithmetic.all;
use work.dlx_types.all;

entity simpleRisc_controller is
    port(
        ir_control: in dlx_word;
        alu_out_control: in dlx_word;
        regfile_out_bus_control: in dlx_word;
        alu_error_control: in error_code;
        clock_control: in bit;
        control_regfile_mux: out bit;
        control_mem_addr_mux: out bit;
        control_pc_mux: out bit;
        control_writeback_mux: out bit;
        control_op2r_mux: out bit;
        control_alu_func: out alu_operation_code;
        control_regfile_index: out register_index;
        control_regfile_readnotwrite: out bit;
        control_regfile_clk: out bit;
        control_mem_clk: out bit;
        control_mem_readnotwrite: out bit;
        control_ir_clk: out bit;
        control_pc_clk: out bit;
        control_op1r_clk: out bit;
        control_op2r_clk: out bit;
        control_alu_out_reg_clk: out bit
    );
end simpleRisc_controller;

architecture behavior of simpleRisc_controller is
begin
    behav: process(clock_control) is
        type state_type is range 1 to 20;
        variable state: state_type := 1;
        variable opcode: opcode_type;
        variable destination, operand1, operand2 : register_index;
        variable func_code : alu_operation_code;
        variable condition: dlx_word;
    begin
        if clock_control'event and clock_control = '1' then
            case state is
                when 1 => -- Fetch the instruction for all types
                    control_mem_readnotwrite <= '1' after 5 ns; -- Read from memory
                    control_mem_clk <= '1' after 5 ns;
                    control_mem_addr_mux <= '0' after 5 ns; -- Instruction address comes from PC
                    control_ir_clk <= '1' after 25 ns; -- Latch the instruction into IR
                    state := 2;

                when 2 =>
                    -- Decode the instruction
                    opcode := ir_control(31 downto 26);
                    operand1 := ir_control(25 downto 21);
                    operand2 := ir_control(20 downto 16);
                    destination := ir_control(15 downto 11);
                    func_code := ir_control(10 downto 7);

                    -- Determine the next state based on the opcode
                    if opcode = "000000" then -- LOAD
                        state := 6;
                    elsif opcode = "000001" then -- STORE
                        state := 10;
                    elsif opcode = "000010" then -- ALU
                        state := 3;
                    elsif opcode = "000011" or opcode = "000100" or opcode = "000101" then -- Jumps
                        state := 14;
                    else -- Unsupported opcode
                        -- Handle error or unsupported instruction
                        state := 1; -- For simplicity, reset to state 1
                    end if;

                when 3 => -- ALU instruction: Read operand1
                    control_regfile_readnotwrite <= '1' after 15 ns; -- Read operation
                    control_regfile_index <= operand1 after 15 ns;
                    control_regfile_clk <= '1' after 15 ns;
                    control_op1r_clk <= '1' after 30 ns; -- Latch into op1r
                    state := 4;

                when 4 => -- ALU instruction: Read operand2
                    control_regfile_readnotwrite <= '1' after 15 ns; -- Read operation
                    control_regfile_index <= operand2 after 15 ns;
                    control_regfile_clk <= '1' after 15 ns;
		    control_op2r_mux <= '0' after 20 ns; -- set mux
                    control_op2r_clk <= '1' after 30 ns; -- Latch into op2r
                    state := 5;

                when 5 => -- ALU instruction: Execute ALU operation and write back
                    control_alu_func <= func_code after 5 ns; -- Set ALU function
                    control_alu_out_reg_clk <= '1' after 15 ns; -- Latch ALU result
                    control_regfile_readnotwrite <= '0' after 25 ns; -- Write operation
                    control_regfile_index <= destination after 25 ns;
                    control_regfile_clk <= '1' after 25 ns;
                    control_writeback_mux <= '0' after 5 ns; -- Select ALU output for writeback
                    -- Increment PC
                    control_pc_mux <= '0' after 5 ns; -- Select PC + 1
                    control_pc_clk <= '1' after 10 ns; -- Clock PC
                    state := 1;

                when 6 => -- LOAD instruction: Increment PC to fetch address
                    -- Increment PC
		    
                    control_pc_mux <= '0' after 30 ns; -- Select PC + 1
                    control_pc_clk <= '1' after 45 ns; -- Clock PC
                    state := 7;

                when 7 =>
    			-- Load offset into op2r
    		    control_mem_readnotwrite <= '1';       -- Memory read operation
   		    control_mem_addr_mux <= '0';           -- Address source is PC
   		    control_mem_clk <= '1' after 15 ns;              -- Latch memory data
   		    control_op2r_mux <= '1';               -- Select memory data for op2r
   		    control_op2r_clk <= '1' after 30 ns;   -- Latch memory data into op2r

    -- Load base register value into op1r
    		    control_regfile_readnotwrite <= '1';   -- Register file read operation
    		    control_regfile_index <= Operand1;     -- Select base register (R0)
    		    control_regfile_clk <= '1';            -- Trigger register file read
    		    control_op1r_clk <= '1' after 30 ns;   -- Latch register file output into op1r

    -- Transition to State 8
   		    state := 8;

 
                when 8 => -- LOAD instruction: Calculate effective address
                    -- Latch offset from memory into op2r
                    control_op2r_mux <= '1' after 5 ns; -- Select memory output
                    control_op2r_clk <= '1' after 30 ns; -- Latch into op2r
                    -- Set ALU function to unsigned add
                    control_alu_func <= "0000" after 5 ns; -- Unsigned add
                    control_alu_out_reg_clk <= '1' after 15 ns; -- Latch ALU result
                    state := 9;

                when 9 => -- LOAD instruction: Load value into destination register
                    -- Read memory at effective address
                    control_mem_readnotwrite <= '1' after 5 ns; -- Read operation
                    control_mem_clk <= '1' after 5 ns;
                    control_mem_addr_mux <= '1' after 5 ns; -- Address from ALU output
                    -- Write memory data into destination register
                    control_regfile_readnotwrite <= '0' after 25 ns; -- Write operation
                    control_regfile_index <= destination after 25 ns;
                    control_regfile_clk <= '1' after 25 ns;
                    control_writeback_mux <= '1' after 5 ns; -- Select memory output for writeback
                    -- Increment PC
                    control_pc_mux <= '0' after 30 ns; -- Select PC + 1
                    control_pc_clk <= '1' after 45 ns; -- Clock PC
			
                    state := 1;

                when 10 => -- STORE instruction: Increment PC to fetch address
                    -- Increment PC
                    control_pc_mux <= '0' after 5 ns; -- Select PC + 1
                    control_pc_clk <= '1' after 5 ns; -- Clock PC
                    state := 11;

                when 11 => -- STORE instruction: Read address and destination
                    -- Read memory at PC (store address)
                    control_mem_readnotwrite <= '1' after 5 ns; -- Read operation
                    control_mem_clk <= '1' after 5 ns;
                    control_mem_addr_mux <= '0' after 5 ns; -- Address from PC
                    -- Read destination register (base address)
                    control_regfile_readnotwrite <= '1' after 15 ns; -- Read operation
                    control_regfile_index <= destination after 15 ns;
                    control_regfile_clk <= '1' after 15 ns;
                    control_op1r_clk <= '1' after 30 ns; -- Latch into op1r
                    state := 12;

                when 12 => -- STORE instruction: Calculate effective address
                    -- Latch offset from memory into op2r
                    control_op2r_mux <= '1' after 5 ns; -- Select memory output
                    control_op2r_clk <= '1' after 30 ns; -- Latch into op2r
                    -- Set ALU function to unsigned add
                    control_alu_func <= "0000" after 5 ns; -- Unsigned add
                    control_alu_out_reg_clk <= '1' after 15 ns; -- Latch ALU result
                    state := 13;

                when 13 => -- STORE instruction: Write operand1 to memory
                    -- Read operand1 from regfile
                    control_regfile_readnotwrite <= '1' after 15 ns; -- Read operation
                    control_regfile_index <= operand1 after 15 ns;
                    control_regfile_clk <= '1' after 15 ns;
                    -- Write to memory at effective address
                    control_mem_readnotwrite <= '0' after 25 ns; -- Write operation
                    control_mem_clk <= '1' after 25 ns;
                    control_mem_addr_mux <= '1' after 5 ns; -- Address from ALU output
                    -- Data to write comes from regfile output bus
                    -- Increment PC
                    control_pc_mux <= '0' after 5 ns; -- Select PC + 1
                    control_pc_clk <= '1' after 5 ns; -- Clock PC
                    state := 1;

                when 14 => -- JMP, JZ, JNZ instructions: Increment PC to fetch address
                    -- Increment PC
                    control_pc_mux <= '0' after 5 ns; -- Select PC + 1
                    control_pc_clk <= '1' after 5 ns; -- Clock PC
                    state := 15;

                when 15 => -- JMP, JZ, JNZ: Read address and operand1
                    -- Read memory at PC (jump address)
                    control_mem_readnotwrite <= '1' after 5 ns; -- Read operation
                    control_mem_clk <= '1' after 5 ns;
                    control_mem_addr_mux <= '0' after 5 ns; -- Address from PC
                    -- Read operand1 from regfile
                    control_regfile_readnotwrite <= '1' after 15 ns; -- Read operation
                    control_regfile_index <= operand1 after 15 ns;
                    control_regfile_clk <= '1' after 15 ns;
                    control_op1r_clk <= '1' after 30 ns; -- Latch into op1r
                    state := 16;

                when 16 => -- JMP, JZ, JNZ: Calculate jump address
                    -- Latch offset from memory into op2r
                    control_op2r_mux <= '1' after 5 ns; -- Select memory output
                    control_op2r_clk <= '1' after 30 ns; -- Latch into op2r
                    -- Set ALU function to unsigned add
                    control_alu_func <= "0000" after 5 ns; -- Unsigned add
                    control_alu_out_reg_clk <= '1' after 15 ns; -- Latch ALU result
                    state := 17;

                when 17 => -- JMP, JZ, JNZ: Read condition register (operand2)
                    -- Read operand2 from regfile
                    control_regfile_readnotwrite <= '1' after 15 ns; -- Read operation
                    control_regfile_index <= operand2 after 15 ns;
                    control_regfile_clk <= '1' after 15 ns;
                    control_op2r_clk <= '1' after 30 ns; -- Latch into op2r (used for condition)
                    state := 18;

                when 18 => -- JMP, JZ, JNZ: Update PC based on condition
                    if opcode = "000100" then -- JZ
                        if regfile_out_bus_control = (regfile_out_bus_control'range => '0') then

                            -- Zero, perform jump
                            control_pc_mux <= '1' after 5 ns; -- Select ALU output
                            control_pc_clk <= '1' after 5 ns; -- Clock PC
                        else
                            -- Not zero, increment PC
                            control_pc_mux <= '0' after 5 ns; -- Select PC + 1
                            control_pc_clk <= '1' after 5 ns; -- Clock PC
                        end if;
                    elsif opcode = "000101" then -- JNZ
                        if regfile_out_bus_control /= (regfile_out_bus_control'range => '0') then
                            -- Not zero, perform jump
                            control_pc_mux <= '1' after 5 ns; -- Select ALU output
                            control_pc_clk <= '1' after 5 ns; -- Clock PC
                        else
                            -- Zero, increment PC
                            control_pc_mux <= '0' after 5 ns; -- Select PC + 1
                            control_pc_clk <= '1' after 5 ns; -- Clock PC
                        end if;
                    else -- JMP (opcode = "000011")
                        -- Unconditional jump
                        control_pc_mux <= '1' after 5 ns; -- Select ALU output
                        control_pc_clk <= '1' after 5 ns; -- Clock PC
                    end if;
                    state := 1;

                when others => null;
            end case;
        elsif clock_control'event and clock_control = '0' then
            -- Reset all the register clocks
            control_pc_clk <= '0';
            control_ir_clk <= '0';
            control_op1r_clk <= '0';
            control_op2r_clk <= '0';
            control_mem_clk <= '0';
            control_regfile_clk <= '0';
            control_alu_out_reg_clk <= '0';
        end if;
    end process behav;
end behavior;
