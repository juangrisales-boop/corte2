----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Módulo: fsm_control (Lógica de Control del Sistema)
-- Descripción: Genera las direcciones y señales de escritura automáticamente.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_memories.all; -- Para usar ADDR_WIDTH

entity fsm_control is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;                                 -- Inicia la transferencia
        addr     : out std_logic_vector(ADDR_WIDTH-1 downto 0);   -- Bus de direcciones
        we_ram   : out std_logic;                                 -- Habilitador de escritura RAM
        done     : out std_logic                                  -- Fin de la transferencia
    );
end entity;

architecture rtl of fsm_control is
    -- Definición de los estados según el diseño de 5 estados
    type state_type is (ST_IDLE, ST_READ_ROM, ST_WRITE_RAM, ST_CHECK, ST_DONE);
    signal current_state, next_state : state_type;
    
    -- Registros internos para la dirección actual
    signal addr_reg, addr_next : unsigned(ADDR_WIDTH-1 downto 0);

begin
    -- =========================================================
    -- PROCESO 1: Lógica Secuencial (Actualización de Estado)
    -- =========================================================
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

    -- =========================================================
    -- PROCESO 2: Lógica Combinacional (Transiciones y Salidas)
    -- =========================================================
    process(current_state, addr_reg, start)
    begin
        -- Valores por defecto para evitar latches
        next_state <= current_state;
        addr_next  <= addr_reg;
        we_ram     <= '0';
        done       <= '0';

        case current_state is
            when ST_IDLE =>
                addr_next <= (others => '0');
                if start = '1' then
                    next_state <= ST_READ_ROM;
                end if;

            when ST_READ_ROM =>
                -- En este ciclo la ROM recibe la dirección y prepara el dato
                next_state <= ST_WRITE_RAM;

            when ST_WRITE_RAM =>
                -- Activamos la escritura en la RAM
                we_ram <= '1';
                next_state <= ST_CHECK;

            when ST_CHECK =>
                we_ram <= '0';
                -- Si llegamos a la última dirección (1111 en 4 bits = 15)
                if addr_reg = (2**ADDR_WIDTH) - 1 then
                    next_state <= ST_DONE;
                else
                    addr_next  <= addr_reg + 1; -- Incrementar dirección
                    next_state <= ST_READ_ROM;
                end if;

            when ST_DONE =>
                done <= '1';
                -- Se mantiene en este estado hasta el próximo reset
                next_state <= ST_DONE;

            when others =>
                next_state <= ST_IDLE;
        end case;
    end process;

    -- Salida física del bus de direcciones
    addr <= std_logic_vector(addr_reg);

end architecture;