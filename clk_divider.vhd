library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_divider is
    port (
        clk_in  : in  std_logic; -- Reloj rápido (FPGA)
        rst     : in  std_logic;
        clk_out : out std_logic  -- Reloj lento (Para tu sistema)
    );
end clk_divider;

architecture rtl of clk_divider is
    -- Para 50MHz a 1Hz, necesitamos contar hasta 25,000,000
    signal counter : integer := 0;
    signal temporal: std_logic := '0';
begin
    process(clk_in, rst)
    begin
        if rst = '1' then
            counter <= 0;
            temporal <= '0';
        elsif rising_edge(clk_in) then
            if counter = 2 then
                temporal <= not temporal;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_out <= temporal;
end rtl;