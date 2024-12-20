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
