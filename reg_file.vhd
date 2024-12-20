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
    type regArray is array (0 to 31) of dlx_word; -- Register array type
begin
    regProcess : process(readnotwrite, clock, data_in, reg_number)
        variable registers : regArray := (others => (others => '0')); -- Initialize all to 0
    begin
        if clock = '1' then
            if readnotwrite = '1' then
                -- Read operation
                data_out <= registers(bv_to_natural(reg_number));
            else
                -- Write operation
                registers(bv_to_natural(reg_number)) := data_in;
            end if;
        end if;
    end process;
end architecture behavior;

