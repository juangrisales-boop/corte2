  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Asignatura: Sistemas Digitales II
-- Proyecto: Sistema de Gestión de Memorias (ROM a RAM)
-- Módulo: Memoria RAM  
--
-- Descripción: 
-- Memoria volátil de lectura o escritura síncrona. Actúa como el destino de los 
-- datos transferidos desde la ROM. Su comportamiento es fundamental para la 
-- visualización dinámica en los displays de 7 segmentos.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all; -- Manejo de lógica multinivel (0, 1, X, Z)
use IEEE.NUMERIC_STD.all;    -- Aritmética de vectores para el manejo de índices
use work.pkg_memories.all;   -- Importación de parámetros ADDR_WIDTH y DATA_WIDTH

entity ram_mem is
    port(
        clk  : in std_logic; -- Reloj maestro para la sincronización de flancos
        
        -- Señal de Control de Escritura (Write Enable):
        -- Controlada por la FSM. '1' habilita el guardado del dato de la ROM.
        we   : in std_logic; 
        
        -- Bus de direcciones: Define la posición de memoria para leer o escribir.
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0); 
        
        -- Bus de entrada (Data Input): Recibe el dato proveniente de la ROM.
        di   : in std_logic_vector(DATA_WIDTH-1 downto 0); 
        
        -- Bus de salida (Data Output): Entrega el dato almacenado hacia los decodificadores.
        do   : out std_logic_vector(DATA_WIDTH-1 downto 0)  
    );
end entity;

architecture rtl of ram_mem is
    -- DECLARACIÓN DE LA MATRIZ DE ALMACENAMIENTO:
    -- Se inicializa en '0' (others => '0') para garantizar un estado conocido 
    -- en la simulación inicial, evitando la presencia de estados "basura" (X).
    -- Utiliza el tipo 'mem_type' para asegurar simetría con la ROM.
    
    signal ram_block : mem_type := (others => (others => '0'));
begin

    -- PROCESO DE CONTROL DE MEMORIA:
    -- Implementa una arquitectura sincrónica de puerto único.
    
    process(clk)
    begin
        if rising_edge(clk) then
            -- LÓGICA DE ESCRITURA:
            -- Se ejecuta solo cuando la señal 'we' es validada por la FSM.
            -- La conversión (to_integer(unsigned)) permite direccionar físicamente 
            -- la matriz 'ram_block'.
            if we = '1' then
                ram_block(to_integer(unsigned(addr))) <= di;
            end if;
            
            -- LÓGICA DE LECTURA SÍNCRONA:
            -- El dato de salida se actualiza en cada ciclo de reloj.
             
            do <= ram_block(to_integer(unsigned(addr)));
        end if;
    end process;

end architecture;
