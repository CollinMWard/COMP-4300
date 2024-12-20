library ieee;
use ieee.std_logic_1164.all;
use work.dlx_types.all;         
use work.bv_arithmetic.all;     
entity tb_mux is
end entity tb_mux;

architecture test of tb_mux is
    signal input_0, input_1, output_val : bit_vector(31 downto 0);  
    signal which : bit;                                              

   
    component mux is
        port (
            input_0, input_1 : in bit_vector(31 downto 0);
            which : in bit;
            output : out bit_vector(31 downto 0)
        );
    end component;

begin
    
    uut: mux
        port map(
            input_0 => input_0,
            input_1 => input_1,
            which => which,
            output => output_val
        );

    -- Test 
    stimulus_process : process
    begin
        -- Initialize inputs
        input_0 <= x"AAAAAAAA";  
        input_1 <= x"55555555";  

        -- Test case 1: Select input_0
        which <= '0';
        wait for 20 ns;

        -- Test case 2: Select input_1
        which <= '1';
        wait for 20 ns;

        -- Test case 3: Change back to input_0
        which <= '0';
        wait for 20 ns;

        
        wait;
    end process;
end architecture test;

