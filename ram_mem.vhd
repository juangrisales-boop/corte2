----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Módulo: Memoria RAM (Random Access Memory)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_memories.all;

entity ram_mem is
    port(
        clk  : in std_logic;
        we   : in std_logic; -- Write Enable (Habilita escritura)
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        di   : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Data Input
        do   : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Data Output
    );
end entity;

architecture rtl of ram_mem is
    -- Creamos la señal que actuará como el bloque de memoria RAM
    signal ram_block : mem_type := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                -- Escritura: Guardamos el dato de entrada en la dirección indicada
                ram_block(to_integer(unsigned(addr))) <= di;
            end if;
            -- Lectura: El dato de salida siempre muestra lo que hay en addr
            do <= ram_block(to_integer(unsigned(addr)));
        end if;
    end process;
end architecture;