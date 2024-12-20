library ieee;
use ieee.std_logic_1164.all;
use work.dlx_types.all;         
use work.bv_arithmetic.all;     

entity tb_reg_file is
end entity tb_reg_file;

architecture test of tb_reg_file is
    signal data_in : bit_vector(31 downto 0);  
    signal data_out : bit_vector(31 downto 0); 
    signal clock : bit := '0';                
    signal readnotwrite : bit;                 
    signal reg_number : bit_vector(4 downto 0); 

    component reg_file is
        port (
            data_in : in bit_vector(31 downto 0);
            readnotwrite, clock : in bit;
            data_out : out bit_vector(31 downto 0);
            reg_number : in bit_vector(4 downto 0)
        );
    end component;

begin
   
    uut: reg_file
        port map(
            data_in => data_in,
            readnotwrite => readnotwrite,
            clock => clock,
            data_out => data_out,
            reg_number => reg_number
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
        -- Write data to register 1
        readnotwrite <= '0';  
        reg_number <= "00001";  
        data_in <= x"12345678";  
        wait for 20 ns;

        -- Read data from register 1
        readnotwrite <= '1';  
        wait for 20 ns;

        -- Write data to register 2
        reg_number <= "00010";  
        data_in <= x"87654321";  
        readnotwrite <= '0';  
        wait for 20 ns;

        -- Read data from register 2
        readnotwrite <= '1';  
        wait for 20 ns;

       
        wait;
    end process;
end architecture test;

