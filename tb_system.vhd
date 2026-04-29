 library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.pkg_memories.all;

entity tb_system is
-- Los testbenches no tienen puertos
end entity;

architecture sim of tb_system is

    -- Señales locales del testbench
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '0';
    signal start_tb    : std_logic := '0';
    signal done_tb     : std_logic;
    signal data_bus_tb : std_logic_vector(DATA_WIDTH-1 downto 0);

    constant T_CLK : time := 10 ns;

begin

    -- UNIÓN CON EL TOP SYSTEM
    uut: entity work.top_system
        port map(
            clk_fpga => clk_tb,   -- ANTES decía 'clk', ahora debe ser 'clk_fpga'
            rst      => rst_tb,
            start    => start_tb,
            done     => done_tb,
            data_bus => data_bus_tb
        );

    -- Generador de reloj
    clk_tb <= not clk_tb after T_CLK / 2;

    -- Estímulos
    process
    begin
        rst_tb   <= '1';
        start_tb <= '0';
        wait for 20 ns;
        
        rst_tb   <= '0';
        wait for 20 ns;
        
        start_tb <= '1';
        wait for T_CLK;
        start_tb <= '0';
        
        -- IMPORTANTE: Si tu divisor es muy grande (ej. 25 millones)
        -- la simulación tardará mucho en llegar aquí.
        wait until done_tb = '1';
        
        wait for 100 ns;
        assert false report "Simulación terminada" severity note;
        wait;
    end process;

end architecture;