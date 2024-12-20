library ieee;
use ieee.std_logic_1164.all;
use work.dlx_types.all;  -- Include the dlx_types package
use work.bv_arithmetic.all;  -- If needed for arithmetic functions

entity simple_alu is
    generic(prop_delay: Time := 5 ns);
    port(
        operand1, operand2: in dlx_word;
        operation: in alu_operation_code;
        result: out dlx_word;
        error: out error_code
    );
end simple_alu;

architecture behavior of simple_alu is
    signal overflow: boolean := false;
    signal div_by_zero: boolean := false;

begin
    process (operand1, operand2, operation)
	variable bv_result: dlx_word;
	variable bv_overflow: boolean := false;
    begin
        error <= "0000";  -- Default: No error
        overflow <= false;
        div_by_zero <= false;

        case operation is
            when "0000" =>  -- Unsigned Add
                result <= bv_addu(operand1, operand2);
                if overflow then
                    error <= "0001";  -- Overflow error
                end if;

            when "0001" =>  -- Unsigned Subtract
                result <= bv_subu(operand1, operand2);
                if overflow then
                    error <= "0001";  -- Overflow error
                end if;

            when "0010" =>  -- Two's Complement Add
                bv_add(operand1, operand2, bv_result, bv_overflow);  
                result <= bv_result;  -- Output the result
                if bv_overflow then
                    error <= "0001";  -- Overflow error
                end if;

            when "0011" =>  -- Two's Complement Subtract
                bv_sub(operand1, operand2, bv_result, bv_overflow);  
                result <= bv_result;  -- Output the result
                if bv_overflow then
                    error <= "0001";  -- Overflow error
                end if;

            when "0100" =>  -- Two's Complement Multiply
                result <= operand1 * operand2; 

            when "0101" =>  -- Two's Complement Divide
                if operand2 = "00000000000000000000000000000000" then 
                    result <= (others => '0');
                    div_by_zero <= true; 
                    error <= "0010";  -- Divide by zero error
                else
                    result <= operand1 / operand2;  
                end if;

            when "0111" =>  -- Bitwise AND
                result <= operand1 and operand2;

            when "1001" =>  -- Bitwise OR
                result <= operand1 or operand2;

            when "1011" =>  -- Bitwise NOT of operand1
                result <= not operand1;

            when "1100" =>  -- Pass operand1
                result <= operand1;

            when "1101" =>  -- Pass operand2
                result <= operand2;

            when "1110" =>  -- Output all zeros
                result <= (others => '0');

            when "1111" =>  -- Output all ones
                result <= (others => '1');

            when others =>
                result <= (others => '0');
                error <= "1111";  -- Undefined operation error
        end case;
    end process;
end architecture behavior;


