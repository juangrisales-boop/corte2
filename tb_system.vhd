  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Módulo: tb_system (Banco de Pruebas / Testbench)
-- Descripción: Entorno de simulación para verificar el comportamiento del
--              sistema completo sin necesidad de hardware físico.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.pkg_memories.all;

-- La entidad del Testbench siempre está vacía ya que no tiene entradas ni salidas físicas
entity tb_system is
end entity;

architecture sim of tb_system is

    -- SEÑALES DE ESTÍMULO: Cables virtuales para conectarlos a la UUT
    signal clk_tb       : std_logic := '0'; -- Reloj de simulación
    signal rst_tb       : std_logic := '0'; -- Reset de simulación
    signal start_tb     : std_logic := '0'; -- Pulso de inicio
    signal done_tb      : std_logic;        -- Salida de finalización observada
    
    -- Señales para observar el comportamiento de los displays en el simulador
    signal disp_high_tb : std_logic_vector(6 downto 0);
    signal disp_low_tb  : std_logic_vector(6 downto 0);

    -- Definición del periodo de reloj (10 ns = 100 MHz para la simulación)
    constant T_CLK : time := 10 ns;

begin

    -- INSTANCIACIÓN DE LA UUT (Unit Under Test)
    -- Conectamos nuestro diseño de nivel superior (top_system) al banco de pruebas
    uut: entity work.top_system
        port map(
            clk_fpga  => clk_tb,
            rst       => rst_tb,
            start     => start_tb,
            done      => done_tb,
            disp_high => disp_high_tb,
            disp_low  => disp_low_tb
        );

    ------------------------------------------------------------------------------
    -- GENERACIÓN AUTOMÁTICA DE RELOJ
    -- Crea una señal cuadrada infinita para que el sistema pueda operar.
    ------------------------------------------------------------------------------
    clk_tb <= not clk_tb after T_CLK / 2;

    ------------------------------------------------------------------------------
    -- PROCESO DE ESTÍMULOS: Guion de prueba paso a paso
    ------------------------------------------------------------------------------
    process
    begin
        -- Paso 1: Inicialización y aplicación de Reset asíncrono
        rst_tb   <= '1';
        start_tb <= '0';
        wait for 20 ns;
        
        -- Paso 2: Liberar el Reset para que la FSM salga de ST_IDLE
        rst_tb   <= '0';
        wait for 20 ns;
        
        -- Paso 3: Simular la pulsación del botón START por un ciclo de reloj
        start_tb <= '1';
        wait for T_CLK;
        start_tb <= '0';
        
        -- Paso 4: Esperar activamente hasta que el sistema indique que terminó
        -- Este comando detiene la ejecución del proceso hasta que done_tb sea '1'
        wait until done_tb = '1';
        
        -- Paso 5: Tiempo adicional para observar los datos en los displays (ST_DISPLAY)
        wait for 100 ns;
        
        -- Mensaje final en la consola del simulador (ModelSim)
        assert false report "Simulación terminada con éxito" severity note;
        
        -- El wait final sin tiempo detiene la simulación permanentemente
        wait;
    end process;

end architecture;
