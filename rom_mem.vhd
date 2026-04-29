----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Módulo: Memoria ROM (Read Only Memory)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_memories.all; -- Importa ADDR_WIDTH, DATA_WIDTH y mem_type

entity rom_mem is
    port(
        clk  : in std_logic;
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of rom_mem is
    -- Inicializamos la ROM con valores constantes (ejemplo: números en Hex)
    constant ROM_DATA : mem_type := (
        0 => x"10", 1 => x"20", 2 => x"30", 3 => x"40",
        4 => x"50", 5 => x"60", 6 => x"70", 7 => x"80",
        others => x"00"
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Convertimos el vector de dirección a entero para indexar el array
            data <= ROM_DATA(to_integer(unsigned(addr)));
        end if;
    end process;
end architecture;