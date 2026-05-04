  ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Módulo: fsm_control (Máquina de Estados Finitos)
-- Descripción: Controla el flujo de datos en tres fases:
--              1. Espera (IDLE)
--              2. Transferencia (ROM a RAM)
--              3. Visualización cíclica (Lectura constante de RAM)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_memories.all; -- Acceso a parámetros globales

entity fsm_control is
    port(
        clk      : in  std_logic; -- Reloj de operación (reloj lento)
        rst      : in  std_logic; -- Reset asíncrono para reiniciar la máquina
        start    : in  std_logic; -- Señal de inicio de transferencia
        addr     : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Dirección actual
        we_ram   : out std_logic; -- Habilitación de escritura en la RAM
        done     : out std_logic  -- Indicador de proceso finalizado
    );
end entity;

architecture rtl of fsm_control is
    -- Definición de los estados de la FSM
    type state_type is (
        ST_IDLE,      -- Estado de reposo inicial
        ST_READ_ROM,  -- Fase de captura de dato en ROM
        ST_WRITE_RAM, -- Fase de guardado de dato en RAM
        ST_CHECK,     -- Verificación de límite de memoria
        ST_DONE,      -- Pulso de finalización de transferencia
        ST_DISPLAY    -- Lectura cíclica para los displays de 7 segmentos
    );
    
    signal current_state, next_state : state_type;
    -- Registros para manejar la dirección de memoria de forma aritmética
    signal addr_reg, addr_next : unsigned(ADDR_WIDTH-1 downto 0);

begin

    ------------------------------------------------------------------------------
    -- PROCESO 1: Lógica Secuencial (Registros de Estado)
    -- Actualiza el estado actual y la dirección en cada flanco de reloj.
    ------------------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= ST_IDLE;
            addr_reg      <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            addr_reg      <= addr_next;
        end if;
    end process;

    ------------------------------------------------------------------------------
    -- PROCESO 2: Lógica Combinacional (Próximo Estado y Salidas)
    -- Define el comportamiento del sistema basándose en el estado actual.
    ------------------------------------------------------------------------------
    process(current_state, addr_reg, start)
    begin
        -- Valores por defecto para evitar latches indeseados
        next_state <= current_state;
        addr_next  <= addr_reg;
        we_ram     <= '0';
        done       <= '0';

        case current_state is
            -- Espera a que el usuario presione START para comenzar
            when ST_IDLE =>
                addr_next <= (others => '0');
                if start = '1' then
                    next_state <= ST_READ_ROM;
                end if;

            -- Da tiempo a la ROM para estabilizar el dato en el bus
            when ST_READ_ROM =>
                next_state <= ST_WRITE_RAM;

            -- Genera el pulso de escritura (we_ram) para guardar en RAM
            when ST_WRITE_RAM =>
                we_ram <= '1';
                next_state <= ST_CHECK;

            -- Decide si continúa con la siguiente dirección o termina
            when ST_CHECK =>
                if addr_reg = (2**ADDR_WIDTH) - 1 then -- ¿Llegamos al final (15)?
                    next_state <= ST_DONE;
                else
                    addr_next  <= addr_reg + 1; -- Incrementa puntero
                    next_state <= ST_READ_ROM;  -- Repite para el siguiente dato
                end if;

            -- Indica que la copia ROM -> RAM ha terminado con éxito
            when ST_DONE =>
                done <= '1';
                addr_next <= (others => '0'); -- Reinicia para empezar lectura visual
                next_state <= ST_DISPLAY;

            -- Mantiene el sistema leyendo la RAM infinitamente para la FPGA
            when ST_DISPLAY =>
                done <= '1';
                we_ram <= '0'; -- Protege la RAM: Solo lectura
                
                -- Ciclo de direcciones para que el usuario vea los datos cambiar
                if addr_reg = (2**ADDR_WIDTH) - 1 then
                    addr_next <= (others => '0'); -- Vuelve al inicio
                else
                    addr_next <= addr_reg + 1;
                end if;
                
                next_state <= ST_DISPLAY; -- Se mantiene aquí hasta el RESET

            when others =>
                next_state <= ST_IDLE;
        end case;
    end process;

    -- Conversión de tipo para la salida física del puerto addr
    addr <= std_logic_vector(addr_reg);

end architecture;
