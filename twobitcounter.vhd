entity twobitcounter is
    generic(prop_delay: Time := 10 ns);
    port(
        increment: in bit;
        reset: in bit; -- Extra credit ?
        count: out bit_vector(1 downto 0) --should always be (00, 01, 10, 11)
    );
end entity twobitcounter;

architecture behavior of twobitcounter is
    signal state: bit_vector(1 downto 0) := "00";
begin
   
    process(increment, reset)
    begin
	
        if reset'event and reset = '0' then -- extra credit 
            state <= "00";
            count <= "00" after prop_delay;
        
        -- end extra credit
        elsif increment'event and increment = '0' then
            if state = "00" then
                state <= "01";
		
            elsif state = "01" then
                state <= "10";
		
            elsif state = "10" then            
		state <= "11";
		else
                state <= "00";
		-- covers 00, 01, 10, 11
            end if;
              count <= state after prop_delay;
        end if;
	 -- count <= state after prop_delay;

    end process;
end architecture behavior;
