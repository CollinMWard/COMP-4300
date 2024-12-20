library ieee;
use ieee.std_logic_1164.all;
use work.dlx_types.all;         
use work.bv_arithmetic.all;     

entity tb_dlx_register is
end entity tb_dlx_register;

architecture test of tb_dlx_register is
    signal in_val : bit_vector(31 downto 0);  
    signal clock : bit := '0';                
    signal out_val : bit_vector(31 downto 0); 

    -- some issue here
    component dlx_register is
        port (
            in_val : in bit_vector(31 downto 0); 
            clock : in bit;
            out_val : out bit_vector(31 downto 0) 
        );
    end component;

begin
    
    uut: dlx_register
        port map(
            in_val => in_val,
            clock => clock,
            out_val => out_val
        );

    
    clock_process : process
    begin
        while true loop
            clock <= not clock;
            wait for 10 ns;  
        end loop;
    end process;

    
    stimulus_process : process
    begin
        
        in_val <= (others => '0');  
        wait for 20 ns;

        in_val <= x"12345678";  
        wait for 20 ns;

        in_val <= x"FFFFFFFF";  
        wait for 20 ns;

        
        wait;
    end process;
end architecture test;

