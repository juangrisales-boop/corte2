 ----------------------------------------------------------------------------------
-- Universidad del Cauca
-- Facultad de Ingeniería Electrónica y Telecomunicaciones
-- Asignatura: Sistemas Digitales II
-- Proyecto: Sistema de Gestión de Memorias (ROM a RAM)
-- Módulo: Entidad Superior (Top-Level)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_memories.all; 

entity top_system is
    port (
        -- ENTRADAS (Los botones y el pulso principal del sistema)
        clk_fpga  : in  std_logic; -- El motor principal que hace fluir todo a gran velocidad.
        rst       : in  std_logic; -- El botón de emergencia (vacía las tuberías y reinicia todo).
        start     : in  std_logic; -- El botón que le da la orden al operario de empezar a trabajar.
        
        -- SALIDAS (Las pantallas y luces donde vemos los resultados)
        disp_high : out std_logic_vector(6 downto 0); -- Muestra la mitad superior de los datos.
        disp_low  : out std_logic_vector(6 downto 0); -- Muestra la mitad inferior de los datos.
        disp_mode : out std_logic_vector(6 downto 0); -- Letra o símbolo que indica el modo actual.
        done      : out std_logic                     -- Luz que se enciende cuando el tanque RAM ya se llenó.
    );
end entity;

architecture behavior of top_system is

    -- SEÑALES INTERNAS (Piensa en ellas como los cables internos o tuberías 
    -- que conectan un bloque con otro dentro del chip, no salen al exterior).
    signal s_rst_n   : std_logic; -- Versión negada (acondicionada) del reset.
    signal s_start_n : std_logic; -- Versión negada (acondicionada) del start.
    signal clk_slow  : std_logic; -- Reloj más lento (el operario no puede trabajar a la velocidad pura de la FPGA).
    signal addr_fsm  : std_logic_vector(ADDR_WIDTH-1 downto 0); -- La dirección o "coordenada" de la memoria.
    signal data_rom  : std_logic_vector(DATA_WIDTH-1 downto 0); -- La tubería por donde viaja el agua de la ROM.
    signal data_ram  : std_logic_vector(DATA_WIDTH-1 downto 0); -- La tubería por donde entra el agua a la RAM.
    signal we_ram_en : std_logic; -- La válvula "Write Enable": si es 1, deja entrar agua a la RAM.
    
    -- SEÑALES PARA EL CONTROL DEL DISPLAY
    signal mux_data   : std_logic_vector(DATA_WIDTH-1 downto 0); -- Tubería final que va hacia los displays.
    signal display_en : std_logic := '0'; -- Memoria (Flip-Flop) que recuerda si debemos encender las pantallas.

begin

    -- 1. ACONDICIONAMIENTO DE BOTONES
    -- Los botones en las FPGA suelen mandar un '0' cuando se presionan.
    -- Aquí invertimos esa lógica con un 'not' para que cuando se presionen, 
    -- el sistema interno reciba un '1' (lógica positiva, más fácil de entender).
    s_rst_n   <= not rst;   
    s_start_n <= not start; 

    -- 2. CANDADO DE VISUALIZACIÓN (LATCH / FLIP-FLOP)
    -- Imagina esto como un interruptor de luz inteligente.
    -- Si alguien presiona 'start', la luz se queda encendida (display_en <= '1') 
    -- para siempre, aunque sueltes el botón. Solo se apaga si presionan 'reset'.
    process(clk_fpga)
    begin
        if rising_edge(clk_fpga) then
            if s_rst_n = '1' then       -- Si presionan reset...
                display_en <= '0';      -- Apaga las pantallas.
            elsif s_start_n = '1' then  -- Si presionan start...
                display_en <= '1';      -- Enciende las pantallas y mantenlas así.
            end if;
        end if;
    end process;

    -- 3. MULTIPLEXOR MEJORADO (La válvula de los displays)
    -- Un multiplexor es como una tubería en forma de "Y" con una llave selectora. 
    -- Si 'display_en' es 1, deja pasar los datos de la RAM hacia las pantallas.
    -- Si es 0, bloquea el paso y manda puros ceros (x"00", apaga los números).
    mux_data <= data_ram when display_en = '1' else x"00";

    -- 4. DIVISOR DE RELOJ (La caja de cambios)
    -- La FPGA va a millones de ciclos por segundo (muy rápido). Este bloque 
    -- reduce esa velocidad para que podamos ver el proceso y las memorias respondan bien.
    u_divisor : entity work.clk_divider
        port map(
            clk_in  => clk_fpga,  -- Entra reloj rápido
            rst     => s_rst_n,   
            clk_out => clk_slow   -- Sale reloj lento
        );

    -- 5. MÁQUINA DE ESTADOS (El operario supervisor)
    -- Es el cerebro del traslado. Le dice a las memorias en qué dirección (addr) 
    -- ubicarse, cuándo escribir en la RAM (we_ram) y avisa cuándo terminó (done).
    u_fsm : entity work.fsm_control
        port map(
            clk    => clk_slow,   -- Trabaja al ritmo del reloj lento
            rst    => s_rst_n,
            start  => s_start_n, 
            addr   => addr_fsm,   -- Genera la dirección (Ej: 0, 1, 2, 3...)
            we_ram => we_ram_en,  -- Abre la válvula de escritura de la RAM
            done   => done        -- Levanta la bandera de "proceso terminado"
        );

    -- 6. MEMORIA ROM (El tanque de lectura)
    -- Recibe la dirección (addr_fsm) y automáticamente saca los datos guardados en esa posición.
    u_rom : entity work.rom_mem
        port map(
            clk  => clk_fpga,
            addr => addr_fsm,     -- ¿Qué posición quieres leer?
            data => data_rom      -- Aquí tienes el dato (sale por esta tubería)
        );

    -- 7. MEMORIA RAM (El tanque de escritura)
    -- Recibe el dato de la ROM y lo guarda en la dirección indicada, PERO solo 
    -- si la FSM le da permiso activando 'we_ram_en'.
    u_ram : entity work.ram_mem
        port map(
            clk  => clk_fpga,
            we   => we_ram_en,    -- Permiso para escribir (Write Enable)
            addr => addr_fsm,     -- ¿En qué posición lo guardo?
            di   => data_rom,     -- Dato de entrada (viene de la ROM)
            do   => data_ram      -- Dato de salida (lo que acabamos de guardar)
        );

    -- 8. DECODIFICADORES DE 7 SEGMENTOS (Traductores visuales)
    -- Toman los datos binarios en bruto (ceros y unos) y los convierten en las 
    -- señales necesarias para encender los palitos (segmentos) de las pantallas LED.

    -- Display de Modo: Siempre muestra la letra 'A' (x"A" en hexadecimal).
    u_hex_mode : entity work.dec7seg
        port map(hex_digit => x"A", segments => disp_mode);

    -- Display Alto: Toma los 4 bits más significativos del dato (7 al 4).
    u_hex_high : entity work.dec7seg
        port map(hex_digit => mux_data(7 downto 4), segments => disp_high);

    -- Display Bajo: Toma los 4 bits menos significativos del dato (3 al 0).
    u_hex_low : entity work.dec7seg
        port map(hex_digit => mux_data(3 downto 0), segments => disp_low);

end architecture;
