  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Asignatura: Sistemas Digitales II
-- Proyecto: Sistema de Gestión de Memorias (ROM a RAM)
-- Módulo: Memoria ROM (Read Only Memory) Síncrona
--
-- Descripción: 
-- Este módulo actúa como la fuente de datos persistente del sistema. 
-- Almacena valores predefinidos en un arreglo de constantes que serán 
-- transferidos a una memoria RAM bajo el control de una FSM.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all; -- Estándar para señales lógicas y buses
use IEEE.NUMERIC_STD.all;    -- Necesaria para la conversión de tipos (vector -> entero)
use work.pkg_memories.all;   -- Importación de parámetros ADDR_WIDTH y DATA_WIDTH

entity rom_mem is
    port(
        clk  : in std_logic; -- Reloj del sistema (sincroniza la salida del dato)
        
        -- Bus de direcciones: Determina la posición específica a leer.
        -- Su ancho está definido globalmente en el paquete de memorias.
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        
        -- Bus de datos: Puerto de salida que entrega el valor almacenado.
        data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of rom_mem is
    -- DEFINICIÓN DEL CONTENIDO DE LA MEMORIA:
    -- Se utiliza el tipo 'mem_type' definido en el paquete para asegurar 
    -- compatibilidad de dimensiones con la memoria RAM del sistema.
    -- Los valores están expresados en formato hexadecimal (x"FF").
    
    constant ROM_DATA : mem_type := (
        0  => x"11", 1  => x"22", 2  => x"33", 3  => x"44",
        4  => x"55", 5  => x"66", 6  => x"77", 7  => x"88",
        8  => x"99", 9  => x"AA", 10 => x"BB", 11 => x"CC",
        12 => x"DD", 13 => x"EE", 14 => x"FF", 15 => x"00"
    );

begin
    -- LÓGICA DE LECTURA SÍNCRONA:
    -- Se implementa un proceso sensible al flanco de subida del reloj (rising_edge).
    -- Esto garantiza que el dato en el bus 'data' sea estable y se actualice
    -- únicamente en sincronía con el resto del sistema digital.
    
    process(clk)
    begin
        if rising_edge(clk) then
            -- CONVERSIÓN DE DIRECCIONAMIENTO:
            -- 1. Se recibe el bus 'addr' como std_logic_vector.
            -- 2. Se castea a 'unsigned' para interpretación numérica.
            -- 3. Se convierte a 'integer' para indexar el arreglo de la ROM.
            data <= ROM_DATA(to_integer(unsigned(addr)));
        end if;
    end process;

end architecture;
