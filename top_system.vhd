 ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Módulo: top_system (Integración con Divisor de Reloj)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.pkg_memories.all;

entity top_system is
    port(
        clk_fpga : in  std_logic; -- Reloj rápido de la placa (ej. 50MHz)
        rst      : in  std_logic;
        start    : in  std_logic;
        done     : out std_logic;
        data_bus : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture structural of top_system is

    -- SEÑALES INTERNAS
    signal clk_slow    : std_logic; -- El reloj ya dividido
    signal addr_wire   : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal rom_to_ram  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal we_wire     : std_logic;

begin

    -- 1. INSTANCIA DEL DIVISOR DE RELOJ
    -- Convierte la frecuencia de la FPGA a una frecuencia manejable
    u_divisor : entity work.clk_divider
        port map(
            clk_in  => clk_fpga,
            rst     => rst,
            clk_out => clk_slow
        );

    -- 2. INSTANCIA DE LA LÓGICA DE CONTROL (FSM)
    -- Ahora usa 'clk_slow'
    u_control : entity work.fsm_control
        port map(
            clk    => clk_slow,
            rst    => rst,
            start  => start,
            addr   => addr_wire,
            we_ram => we_wire,
            done   => done
        );

    -- 3. INSTANCIA DE LA MEMORIA ROM
    -- Ahora usa 'clk_slow'
    u_rom : entity work.rom_mem
        port map(
            clk  => clk_slow,
            addr => addr_wire,
            data => rom_to_ram
        );

    -- 4. INSTANCIA DE LA MEMORIA RAM
    -- Ahora usa 'clk_slow'
    u_ram : entity work.ram_mem
        port map(
            clk  => clk_slow,
            we   => we_wire,
            addr => addr_wire,
            di   => rom_to_ram,
            do   => data_bus
        );

end architecture;