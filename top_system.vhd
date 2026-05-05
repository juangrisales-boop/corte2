  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Asignatura: Sistemas Digitales II
-- Proyecto: Sistema de Gestión de Memorias (ROM a RAM)
-- Módulo: Entidad Superior (Top-Level)
--
-- Descripción: 
-- Este archivo integra todos los módulos del sistema (ROM, RAM, FSM, Divisor 
-- y Decodificadores). Define las interconexiones físicas con la FPGA Cyclone III
-- y gestiona el flujo de datos desde la lectura de ROM hasta la visualización.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_memories.all; 

entity top_system is
    port (
        -- ENTRADAS FÍSICAS (Pines de la FPGA)
        clk_fpga  : in  std_logic; -- Reloj base de 50 MHz
        rst       : in  std_logic; -- Botón de reset (Push-button)
        start     : in  std_logic; -- Botón de inicio de operación
        
        -- SALIDAS FÍSICAS (Displays de 7 segmentos y LEDs)
        disp_high : out std_logic_vector(6 downto 0); -- Display para Nibble Alto
        disp_low  : out std_logic_vector(6 downto 0); -- Display para Nibble Bajo
        disp_mode : out std_logic_vector(6 downto 0); -- Indica el modo ('A' de Automático)
        done      : out std_logic                     -- LED indicador de fin de proceso
    );
end entity;

architecture behavior of top_system is

    -- SEÑALES INTERNAS (Interconexiones o "Cables" virtuales)
    signal s_rst_n   : std_logic; -- Reset sincronizado (negado para lógica interna)
    signal s_start_n : std_logic; -- Start sincronizado
    signal clk_slow  : std_logic; -- Reloj de baja frecuencia para la FSM
    signal addr_fsm  : std_logic_vector(ADDR_WIDTH-1 downto 0); -- Bus de direcciones compartido
    signal data_rom  : std_logic_vector(DATA_WIDTH-1 downto 0); -- Dato saliendo de ROM
    signal data_ram  : std_logic_vector(DATA_WIDTH-1 downto 0); -- Dato saliendo de RAM
    signal we_ram_en : std_logic; -- Permiso de escritura generado por la FSM

begin

    -- GESTIÓN DE BOTONES:
    -- Los botones en muchas placas FPGA son activos en bajo. Aquí se normaliza
    -- la lógica para que el resto del sistema trabaje con lógica positiva.
    s_rst_n   <= not rst;   
    s_start_n <= not start; 

    -- INSTANCIACIÓN DEL DIVISOR DE RELOJ:
    -- Reduce la frecuencia de la FPGA para que la transición entre datos 
    -- sea visible en los displays.
    u_divisor : entity work.clk_divider
        port map(
            clk_in  => clk_fpga,
            rst     => s_rst_n,
            clk_out => clk_slow
        );

    -- INSTANCIACIÓN DE LA FSM (Unidad de Control):
    -- Gobierna el sistema usando el reloj lento para las transiciones de estado.
    u_fsm : entity work.fsm_control
        port map(
            clk    => clk_slow,
            rst    => s_rst_n,
            start  => s_start_n, 
            addr   => addr_fsm,
            we_ram => we_ram_en,
            done   => done 
        );

    -- INSTANCIACIÓN DE MEMORIA ROM:
    -- Fuente de datos. Nota: Se usa clk_fpga para máxima velocidad de lectura.
    u_rom : entity work.rom_mem
        port map(
            clk  => clk_fpga,
            addr => addr_fsm,
            data => data_rom
        );

    -- INSTANCIACIÓN DE MEMORIA RAM:
    -- Destino de datos. Se conecta directamente a la salida de la ROM (di => data_rom).
    u_ram : entity work.ram_mem
        port map(
            clk  => clk_fpga,
            we   => we_ram_en,
            addr => addr_fsm,
            di   => data_rom,
            do   => data_ram
        );

    -- ETAPA DE VISUALIZACIÓN (Decodificadores):
    -- Convierte los nibbles de la RAM y caracteres estáticos a formato de 7 segmentos.
    
    -- Muestra una 'A' constante para indicar funcionamiento Automático.
    u_hex_mode : entity work.dec7seg
        port map(hex_digit => x"A", segments => disp_mode);

    -- Decodifica la parte alta (bits 7-4) del dato recuperado de la RAM.
    u_hex_high : entity work.dec7seg
        port map(hex_digit => data_ram(7 downto 4), segments => disp_high);

    -- Decodifica la parte baja (bits 3-0) del dato recuperado de la RAM.
    u_hex_low : entity work.dec7seg
        port map(hex_digit => data_ram(3 downto 0), segments => disp_low);

end architecture;
