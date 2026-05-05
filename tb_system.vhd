  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Asignatura: Sistemas Digitales II
-- Proyecto: Sistema de Gestión de Memorias (ROM a RAM)
-- Módulo: Testbench (Banco de Pruebas)
--
-- Descripción: 
-- Entorno de simulación diseñado para validar la integración de la FSM, 
-- las memorias y los decodificadores. Genera estímulos de reloj y señales 
-- de control para verificar el flujo de datos sin necesidad de hardware físico.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tb_system is
-- Los Testbenches no tienen puertos de entrada ni salida
end entity;

architecture sim of tb_system is
    -- SEÑALES DE ESTÍMULO: Conectadas a las entradas de la Unidad Bajo Prueba (UUT)
    signal clk_fpga  : std_logic := '0'; -- Reloj inicializado en '0'
    signal rst       : std_logic := '1'; -- Reset inicializado en '1' (inactivo)
    signal start     : std_logic := '1'; -- Start inicializado en '1' (inactivo)
    
    -- SEÑALES DE MONITOREO: Conectadas a las salidas de la UUT para observar en el Waveform
    signal disp_high : std_logic_vector(6 downto 0);
    signal disp_low  : std_logic_vector(6 downto 0);
    signal disp_mode : std_logic_vector(6 downto 0);
    signal done      : std_logic;

begin
    -- INSTANCIACIÓN DE LA UNIDAD BAJO PRUEBA (UUT):
    -- Se conecta el Top-Level al banco de pruebas.
    uut: entity work.top_system
        port map (
            clk_fpga  => clk_fpga,
            rst       => rst,
            start     => start,
            disp_high => disp_high,
            disp_low  => disp_low,
            disp_mode => disp_mode,
            done      => done
        );

    -- GENERACIÓN DEL RELOJ MAESTRO:
    -- Crea una señal cuadrada con un periodo de 20ns (50 MHz).
    -- Este reloj es el que impulsa toda la lógica sincrónica y el divisor.
    clk_fpga <= not clk_fpga after 10 ns;

    -- PROCESO DE ESTÍMULOS (stim_proc):
    -- Simula las acciones de un usuario operando la FPGA.
    stim_proc: process
    begin		
        -- 1. SECUENCIA DE RESET:
        -- Se genera un pulso de reset activo en bajo para limpiar el sistema.
        rst <= '1'; wait for 100 ns;
        rst <= '0'; wait for 100 ns; -- Pulso de reset presionado
        rst <= '1'; wait for 200 ns; -- Sistema listo para operar
        
        -- 2. DISPARO DEL SISTEMA (START):
        -- Simula la pulsación del botón Start para que la FSM salga de ST_IDLE.
        -- Como se usa lógica de "not start" en el Top, aquí se envía un '0' para activar.
        start <= '0'; wait for 100 ns; 
        start <= '1'; -- Botón soltado
        
        -- 3. ESPERA DE FINALIZACIÓN:
        -- La simulación se detiene automáticamente cuando la señal 'done' llega a '1'.
        -- Esto confirma que la transferencia ROM a RAM terminó exitosamente.
        wait until done = '1';
        
        -- Fin de la simulación
        wait;
    end process;
end architecture;
