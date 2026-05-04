  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Módulo: top_system (Nivel Superior / Integración)
-- Descripción: Este módulo actúa como el chasis del sistema. Instancia y conecta
--              el divisor de reloj, la FSM, las memorias y los decodificadores
--              de 7 segmentos para formar el sistema completo.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.pkg_memories.all; -- Importa las constantes globales ADDR_WIDTH y DATA_WIDTH

entity top_system is
    port(
        -- Entradas físicas (Botones y Oscilador de la FPGA)
        clk_fpga  : in  std_logic; -- Reloj maestro de la placa (ej. 50MHz)
        rst       : in  std_logic; -- Pulsador de Reset (Validación D)
        start     : in  std_logic; -- Pulsador de inicio de operación
        
        -- Salidas físicas (LEDs y Displays)
        done      : out std_logic; -- LED indicador de proceso finalizado
        disp_high : out std_logic_vector(6 downto 0); -- Segmentos del display izquierdo
        disp_low  : out std_logic_vector(6 downto 0)  -- Segmentos del display derecho
    );
end entity;

architecture structural of top_system is

    -- SEÑALES INTERNAS (Cables que interconectan los módulos)
    signal clk_slow      : std_logic; -- Reloj de baja frecuencia generado por el divisor
    signal addr_wire     : std_logic_vector(ADDR_WIDTH-1 downto 0); -- Bus de direcciones común
    signal rom_to_ram    : std_logic_vector(DATA_WIDTH-1 downto 0); -- Bus de datos ROM -> RAM
    signal data_internal : std_logic_vector(DATA_WIDTH-1 downto 0); -- Bus de salida de la RAM
    signal we_wire       : std_logic; -- Señal de control de escritura (Write Enable)

begin

    -- 1. DIVISOR DE RELOJ: Reduce la velocidad para visualización humana
    u_divisor : entity work.clk_divider
        port map(
            clk_in  => clk_fpga, 
            rst     => rst, 
            clk_out => clk_slow
        );

    -- 2. UNIDAD DE CONTROL (FSM): Orquesta la transferencia y visualización
    u_control : entity work.fsm_control
        port map(
            clk    => clk_slow, 
            rst    => rst, 
            start  => start, 
            addr   => addr_wire, 
            we_ram => we_wire, 
            done   => done
        );

    -- 3. MEMORIA ROM: Fuente de los datos constantes
    u_rom : entity work.rom_mem
        port map(
            clk  => clk_slow, 
            addr => addr_wire, 
            data => rom_to_ram
        );

    -- 4. MEMORIA RAM: Almacén volátil del sistema
    u_ram : entity work.ram_mem
        port map(
            clk  => clk_slow, 
            we   => we_wire, 
            addr => addr_wire, 
            di   => rom_to_ram, 
            do   => data_internal
        );

    -- 5. DECODIFICADORES DE 7 SEGMENTOS: Interfaz visual
    -- Se divide el dato de 8 bits (data_internal) en dos nibbles de 4 bits
    
    -- Nibble superior (Bits 7 a 4): Display de mayor peso
    u_disp_high : entity work.dec7seg
        port map(
            hex_digit => data_internal(7 downto 4), 
            segments  => disp_high
        );

    -- Nibble inferior (Bits 3 a 0): Display de menor peso
    u_disp_low : entity work.dec7seg
        port map(
            hex_digit => data_internal(3 downto 0), 
            segments  => disp_low
        );

end architecture;
