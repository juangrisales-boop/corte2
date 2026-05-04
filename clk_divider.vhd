  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Módulo: clk_divider (Divisor de Frecuencia)
-- Descripción: Reduce la frecuencia del reloj maestro de la FPGA para obtener
--              una señal de sincronización más lenta, permitiendo la visualización
--              de datos en los displays de 7 segmentos.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- Manejo de señales lógicas estándar
use IEEE.NUMERIC_STD.ALL;    -- Necesaria si se realizaran operaciones con vectores numéricos

entity clk_divider is
    port (
        clk_in  : in  std_logic; -- Reloj rápido proveniente del oscilador de la FPGA
        rst     : in  std_logic; -- Reset asíncrono para inicializar el contador
        clk_out : out std_logic  -- Reloj lento resultante para el resto del sistema
    );
end clk_divider;

architecture rtl of clk_divider is
    -- Señal interna para contar los flancos del reloj rápido.
    -- Para 50MHz a 1Hz, el contador debería llegar a 25,000,000.
    signal counter : integer := 0;
    
    -- Registro interno para mantener el estado del reloj de salida.
    signal temporal: std_logic := '0';
begin

    -- Proceso de división: Incrementa un contador hasta alcanzar un umbral definido.
    --
    process(clk_in, rst)
    begin
        -- Reset asíncrono: Reinicia el contador y el estado de la señal a cero.
        if rst = '1' then
            counter <= 0;
            temporal <= '0';
        
        -- Sensible al flanco de subida del reloj rápido (FPGA).
        elsif rising_edge(clk_in) then
            -- Cuando el contador llega al límite (ej. 10 para simulación rápida),
            -- la señal de salida conmuta su estado (Toggle).
            if counter = 10 then
                temporal <= not temporal; -- Inversión de estado (0 a 1 o 1 a 0)
                counter <= 0;             -- Reinicio del conteo
            else
                -- Incremento progresivo del contador en cada ciclo de clk_in.
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Asignación continua del registro interno al puerto de salida.
    clk_out <= temporal;

end rtl;
