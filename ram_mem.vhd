  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Módulo: Memoria RAM (Random Access Memory) - Single Port
-- Descripción: Memoria volátil que permite almacenar temporalmente los datos
--              transferidos desde la ROM para su posterior visualización.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all; -- Manejo de lógica multinivel
use IEEE.NUMERIC_STD.all;    -- Aritmética de vectores para el manejo de índices
use work.pkg_memories.all;   -- Importación de parámetros ADDR_WIDTH y DATA_WIDTH

entity ram_mem is
    port(
        clk  : in std_logic; -- Reloj maestro para sincronizar operaciones
        we   : in std_logic; -- Write Enable: Si es '1', escribe; si es '0', solo lee
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Dirección de acceso
        di   : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Bus de entrada (desde ROM)
        do   : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Bus de salida (hacia Displays)
    );
end entity;

architecture rtl of ram_mem is
    -- Definición de la matriz de memoria. Se inicializa en '0' para evitar
    -- estados de alta impedancia o basura en la simulación inicial.
    --
    signal ram_block : mem_type := (others => (others => '0'));
begin

    -- Proceso de Memoria: Controla el flujo de datos según el estado de 'we'.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            -- Lógica de Escritura: Solo se activa cuando la FSM lo ordena mediante 'we'.
            --
            if we = '1' then
                -- Se convierte la dirección de std_logic_vector a entero para indexar.
                ram_block(to_integer(unsigned(addr))) <= di;
            end if;
            
            -- Lógica de Lectura Síncrona: El dato de salida se actualiza en cada ciclo
            -- reflejando el contenido de la dirección actual en el bus 'addr'.
            --
            do <= ram_block(to_integer(unsigned(addr)));
        end if;
    end process;

end architecture;
