  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Asignatura: Sistemas Digitales II
-- Módulo: Memoria ROM (Read Only Memory) Síncrona
-- Descripción: Almacena datos constantes que serán transferidos a una RAM.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all; -- Librería estándar para señales lógicas (0, 1, Z)
use IEEE.NUMERIC_STD.all;    -- Necesaria para conversiones de vectores a enteros
use work.pkg_memories.all;   -- Uso del paquete global para mantener la modularidad

entity rom_mem is
    port(
        clk  : in std_logic; -- Reloj del sistema para sincronización de lectura
        -- Bus de direcciones: define qué posición de memoria consultar
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        -- Bus de datos: saca el valor almacenado hacia el sistema
        data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of rom_mem is
    -- Definición del contenido de la memoria. 
    -- Se usa 'constant' porque la ROM no cambia su valor en tiempo de ejecución.
    -- 'mem_type' permite organizar los datos como un arreglo (array).
    constant ROM_DATA : mem_type := (
        0 => x"10", 1 => x"20", 2 => x"30", 3 => x"40",
        4 => x"50", 5 => x"60", 6 => x"70", 7 => x"80",
        others => x"00" -- Llena el resto de las 16 posiciones con ceros por seguridad
    );

begin
    -- Proceso síncrono: La lectura solo ocurre en los flancos de subida del reloj.
    -- Esto evita ruidos (glitches) en los buses de datos.
    process(clk)
    begin
        if rising_edge(clk) then
            -- 1. Tomamos el vector 'addr' (binario).
            -- 2. Lo tratamos como número sin signo (unsigned).
            -- 3. Lo convertimos a entero (integer) para poder buscar en el array ROM_DATA.
            data <= ROM_DATA(to_integer(unsigned(addr)));
        end if;
    end process;

end architecture;
