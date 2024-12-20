-- simpleRisc_datapath_lab4.vhd

use work.dlx_types.all;
use work.bv_arithmetic.all;

entity reg_file is
    port (
        data_in : in dlx_word;           -- Input data
        readnotwrite, clock : in bit;    -- Control signals
        data_out : out dlx_word;         -- Output data
        reg_number : in register_index   -- Register index
    );
end entity reg_file;

architecture behavior of reg_file is
    type regArray is array (0 to 31) of dlx_word; 
begin
    regProcess : process(readnotwrite, clock, data_in, reg_number)
        variable registers : regArray := (others => (others => '0')); 
    begin
        if clock = '1' then
            if readnotwrite = '1' then
                -- Read operation
                data_out <= registers(bv_to_natural(reg_number)) after 5 ns;
            else
                -- Write operation
                registers(bv_to_natural(reg_number)) := data_in;
            end if;
        end if;
    end process regProcess;
end architecture behavior;





-- end entity regfile
-- entity simple_alu (correct for simple risc, different from Aubie)
use work.dlx_types.all;
use work.bv_arithmetic.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlx_types.all; 
use work.bv_arithmetic.all;


entity simple_alu is
	generic(prop_delay : Time := 0 ns);
	port(operand1, operand2: in dlx_word; operation: in alu_operation_code;
		result: out dlx_word; error: out error_code);
end entity simple_alu;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bv_arithmetic.all; 
use work.dlx_types.all; 

architecture behavior of simple_alu is
    signal result_signal : dlx_word;
    signal error_signal : error_code;
begin
    process(operand1, operand2, operation)
        variable temp_result : bit_vector(31 downto 0);
        variable overflow : boolean := false;
        variable div_by_zero : boolean := false;
    begin
        overflow := false;
        div_by_zero := false;
        error_signal <= "0000"; -- Default: no error

        -- ALU operation cases
        case operation is
            when "0000" => -- Unsigned add
                bv_addu(operand1, operand2, temp_result, overflow);

            when "0001" => -- Unsigned subtract
                bv_subu(operand1, operand2, temp_result, overflow);

            when "0010" => -- Two?s complement add
                bv_add(operand1, operand2, temp_result, overflow);

            when "0011" => -- Two?s complement subtract
                bv_sub(operand1, operand2, temp_result, overflow);

            when "0100" => -- Two?s complement multiply
                bv_mult(operand1, operand2, temp_result, overflow);

            when "0101" => -- Two?s complement divide
                bv_div(operand1, operand2, temp_result, div_by_zero, overflow);
                if div_by_zero then
                    error_signal <= "0010"; -- Divide by zero error
                end if;

            when "0111" => -- Bitwise AND
                temp_result := operand1 and operand2;

            when "1001" => -- Bitwise OR
                temp_result := operand1 or operand2;

            when "1011" => -- Bitwise NOT of operand1
                temp_result := not operand1;

            when "1100" => -- Pass operand1
                temp_result := operand1;

            when "1101" => -- Pass operand2
                temp_result := operand2;

            when "1110" => -- Output all zeros
                temp_result := (others => '0');

            when "1111" => -- Output all ones
                temp_result := (others => '1');

            when others => -- Invalid operation
                temp_result := (others => '0');
                error_signal <= "1111"; -- Custom error for invalid operation
        end case;

        -- Handle overflow error
        if overflow then
            error_signal <= "0001";
        end if;

        -- Assign computed results to signals with propagation delay
        result_signal <= temp_result;
        error_signal <= error_signal;
    end process;

    -- Map signals to entity outputs
    result <= result_signal;
    error <= error_signal;

end architecture behavior;








-- alu_operation_code values (simpleRisc)
-- 0000 unsigned add
-- 0001 unsigned sub
-- 0010 2's compl add
-- 0011 2's compl sub
-- 0100 2's compl mul
-- 0101 2's compl divide
-- 0110 logical and
-- 0111 bitwise and
-- 1001 bitwise or
-- 1011 bitwise not (op1)
-- 1100 copy op1 to output
-- 1101 copy op2 to output
-- 1110 output all zero's
-- 1111 output all one's
-- error code values
-- 0000 = no error
-- 0001 = overflow (too big or too small)
-- 0011 = divide by zero
-- end entity simple_alu
-- entity dlx_register
use work.dlx_types.all;

entity dlx_register is
	generic(prop_delay : Time := 10 ns);
	port(in_val: in dlx_word; clock: in bit; out_val: out dlx_word);
end entity dlx_register;

library ieee;
use ieee.std_logic_1164.all;

architecture behavior of dlx_register is
    signal stored_value: dlx_word := (others => '0');
begin
    process(clock)
    begin
        if rising_edge(clock) then
            stored_value <= in_val after prop_delay;
        end if;
    end process;
    
    out_val <= stored_value;
end architecture behavior;
-- end entity dlx_register

-- entity pcplusone (correct for simpleRisc)
use work.dlx_types.all;
use work.bv_arithmetic.all;


entity pcplusone is
	generic(prop_delay: Time := 5 ns);
	port (input: in dlx_word; clock: in bit; output: out dlx_word);
end entity pcplusone;


architecture behavior of pcplusone is
begin
    output <= input + natural_to_bv(1, 32) after prop_delay; -- Increment PC
end architecture behavior;

-- entity mux
use work.dlx_types.all;


entity mux is
    generic(prop_delay : Time := 5 ns); 
    port (
        input_0, input_1 : in dlx_word;
        which : in bit;                 
        output : out dlx_word          
    );
end entity mux;

architecture behavior of mux is
begin
    process(which, input_0, input_1)
    begin
        if which = '0' then
            output <= input_0 after prop_delay;
        else
            output <= input_1 after prop_delay; 
        end if;
    end process;
end architecture behavior;
-- end entity mux

-- entity memory
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity memory is
	port (
	address : in dlx_word;
	readnotwrite: in bit;
	data_out : out dlx_word;
	data_in: in dlx_word;
	clock: in bit);
end memory;

architecture behavior of memory is
 
begin  -- behavior

  mem_behav: process(address,clock) is
    -- note that there is storage only for the first 1k of the memory, to speed
    -- up the simulation
    type memtype is array (0 to 1024) of dlx_word;
    variable data_memory : memtype;
  begin
    -- fill this in by hand to put some values in there
    -- some instructions
   data_memory(0) :=  "00000000000000000000100000000000";   -- LD R1,R0(100)
   data_memory(1) :=  "00000000000000000000000100000000";
   data_memory(2) :=  "00000000000000000001000000000000";   -- LD R2,R0(101)
   data_memory(3) :=  "00000000000000000000000100000001";
   data_memory(4) :=  "00001000001000100001100100000000";   -- ADD R3,R1,R2
   data_memory(5) :=  "00000100011000000000000000000000";   -- STO R3,R0(102)
   data_memory(6) :=  "00000000000000000000000100000010";
   -- if the 3 instructions above run correctly for you, you get full credit for the assignment


   -- data for the first two loads to use
    data_memory(256) := X"55550000"; 
    data_memory(257) := X"00005555";
    data_memory(258) := X"ffffffff";

    -- testing for extra credit 
    -- code to test JZ , should be taken unless value of R1 changed
    data_memory(7) := "00001100100000000000000000000000";         -- JMP R4(00000010)
    data_memory(8) := X"00000010";

    data_memory(16):=  "00010000100001010000000000000000";        -- JZ R5,R4(00000000)
    data_memory(17) := X"00000000";

   
    if clock = '1' then
      if readnotwrite = '1' then
        -- do a read
        data_out <= data_memory(bv_to_natural(address)) after 5 ns;
      else
        -- do a write
        data_memory(bv_to_natural(address)) := data_in; 
      end if;
    end if;


  end process mem_behav; 

end behavior;
-- end entity memory


