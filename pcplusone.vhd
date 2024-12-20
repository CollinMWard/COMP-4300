
library ieee;
use ieee.std_logic_1164.all;
use work.dlx_types.all;  
use work.bv_arithmetic.all;  


entity pcplusone is
    generic(prop_delay: Time := 5 ns);  
    port (
        input : in dlx_word;  -- Changed to dlx_word for consistency
        clock : in bit;                      
        output : out dlx_word -- Changed to dlx_word for consistency
    );
end entity pcplusone;


architecture behavior of pcplusone is
begin
    process(clock)
    begin
        if rising_edge(clock) then
            
            output <= input + natural_to_bv(1, 32) after prop_delay;
        end if;
    end process;
end architecture behavior;


