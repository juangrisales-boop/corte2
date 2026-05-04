 ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Proyecto: Sistema Digital ROM-RAM con FSM
-- Descripción: Paquete de definiciones globales (Constantes y Tipos)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pkg_memories is

    -- 1. CONSTANTES GLOBALES
    -- Modificando estos valores aquí, se actualiza todo el sistema automáticamente
    constant ADDR_WIDTH : integer := 4; -- 4 bits = 16 posiciones de memoria
    constant DATA_WIDTH : integer := 8; -- 8 bits = 1 byte por posición

    -- 2. DEFINICIÓN DE TIPOS
    -- Creamos un tipo de dato "memoria" que es un arreglo de vectores
    -- Va desde la posición 0 hasta 15 (en este caso)
    type mem_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

end package pkg_memories;

package body pkg_memories is
    -- (En este caso no necesitamos cuerpo del paquete, pero se deja la estructura)
end package body pkg_memories;
