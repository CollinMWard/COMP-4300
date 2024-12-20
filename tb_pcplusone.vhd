library ieee;
use ieee.std_logic_1164.all;
use work.dlx_types.all;         
use work.bv_arithmetic.all;     

entity tb_pcplusone is
end entity tb_pcplusone;

architecture test of tb_pcplusone is
    signal input_val : bit_vector(31 downto 0);  
    signal clock : bit := '0';                   
    signal output_val : bit_vector(31 downto 0); 

    
    component pcplusone is
        port (
            input : in bit_vector(31 downto 0);
            clock : in bit;
            output : out bit_vector(31 downto 0)
        );
    end component;

begin
   
    uut: pcplusone
        port map(
            input => input_val,
            clock => clock,
            output => output_val
        );

    
    clock_process : process
    begin
        while true loop
            clock <= not clock;
            wait for 10 ns;  
        end loop;
    end process;

    -- Test 
    stimulus_process : process
    begin
        
        input_val <= x"00000000";  -- Set input to 0
        wait for 20 ns;
        
        -- Increment to 1
        input_val <= x"00000001";  -- Set input to 1
        wait for 20 ns;

        -- Test a max
        input_val <= x"FFFFFFFE";  
        wait for 20 ns;

        
        wait;
    end process;
end architecture test;

