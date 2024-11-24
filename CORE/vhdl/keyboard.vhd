---------------------------------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Custom keyboard controller for your core
--
-- Runs in the clock domain of the core.
--
-- This is how MiSTer2MEGA65 provides access to the MEGA65 keyboard:
--
-- MiSTer2MEGA65 provides a very simple and generic interface to the MEGA65 keyboard:
-- kb_key_num_i is running through the key numbers 0 to 79 with a frequency of 1 kHz, i.e. the whole
-- keyboard is scanned 1000 times per second. kb_key_pressed_n_i is already debounced and signals
-- low active, if a certain key is being pressed right now.
--
-- This PET keyboard offers a very symbolic mapping. A Mega-65 keyboard has all characters
-- on the keys that a PET has, but unfortunately most are in the wrong place. The numeric
-- keypad is also missing.
--
-- So we try to map all symbols on the keyboard to equivalent PET key presses.
-- Exception: there is no separate OFF/RVS key, which is used to delay scrolling.
-- The CTRL key is used in its place.
-- Another exception: the cursor up and left keys generate down and right, plus shift.
-- Some keys need to be shifted on the Mega-65 while being not shifted on the PET,
-- such as the shifted digits. This is handled by forcing the shift key to be un-pressed
-- while the '!' key (etc) are pressed. The PET may see unneeded shift key presses and
-- releases, though.
-- TODO: how to handle the graphics symbols we cannot get because of this.
-- for now I have a temporary version where the Mega key alwasy acts as a shift key for the PET:
-- 1 -> 1, shift+1 -> !, mega+1 -> petshift+1, mega+shift+1 -> petshift+! .
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
---------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
   port (
      clk_main_i           : in std_logic;               -- core clock

      -- Interface to the MEGA65 keyboard
      key_num_i            : in integer range 0 to 79;   -- cycles through all MEGA65 keys
      key_pressed_n_i      : in std_logic;               -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- Interface to the PET's PIA.
        --E810    PORT A  7   Diagnostic sense (pin 5 on the user port)
        --                6   IEEE EOI in
        --                5   Cassette sense #2
        --                4   Cassette sense #1
        --                3-0 Keyboard row select (through 4->10 decoder)
        --E811    CA2         output to blank the screen (old PETs only)
        --                    IEEE EOI out
        --        CA1         cassette #1 read line
        --E812    PORT B  7-0 Contents of keyboard row
        --                    Usually all or all but one bits set.
        --E813    CB2         output to cassette #1 motor: 0=on, 1=off
        --        CB1         screen retrace detection in
        --
        --
        --         Control
        --
        -- 7    CA1 active transition flag. 1= 0->1, 0= 1->0
        -- 6    CA2 active transition flag. 1= 0->1, 0= 1->0
        -- 5    CA2 direction           1 = out        | 0 = in
        --                    ------------+------------+---------------------
        -- 4    CA2 control   Handshake=0 | Manual=1   | Active: High=1 Low=0
        -- 3    CA2 control   On Read=0   | CA2 High=1 | IRQ on=1, IRQ off=0
        --                    Pulse  =1   | CA2 Low=0  |
        --
        -- 2    Port A control: DDRA = 0, IORA = 1
        -- 1    CA1 control: Active High = 1, Low = 0
        -- 0    CA1 control: IRQ on=1, off = 0
      row_select_i      : in  std_logic_vector(3 downto 0);
      column_selected_o : out std_logic_vector(7 downto 0);
      
      diag_sense_o      : out  std_logic
   );
end keyboard;

architecture beh of keyboard is

-- MEGA65 key codes that kb_key_num_i is using while
-- kb_key_pressed_n_i is signalling (low active) which key is pressed
constant m65_ins_del       : integer := 0;
constant m65_return        : integer := 1;
constant m65_horz_crsr     : integer := 2;   -- means cursor right in C64 terminology
constant m65_f7            : integer := 3;
constant m65_f1            : integer := 4;
constant m65_f3            : integer := 5;
constant m65_f5            : integer := 6;
constant m65_vert_crsr     : integer := 7;   -- means cursor down in C64 terminology
constant m65_3             : integer := 8;
constant m65_w             : integer := 9;
constant m65_a             : integer := 10;
constant m65_4             : integer := 11;
constant m65_z             : integer := 12;
constant m65_s             : integer := 13;
constant m65_e             : integer := 14;
constant m65_left_shift    : integer := 15;
constant m65_5             : integer := 16;
constant m65_r             : integer := 17;
constant m65_d             : integer := 18;
constant m65_6             : integer := 19;
constant m65_c             : integer := 20;
constant m65_f             : integer := 21;
constant m65_t             : integer := 22;
constant m65_x             : integer := 23;
constant m65_7             : integer := 24;
constant m65_y             : integer := 25;
constant m65_g             : integer := 26;
constant m65_8             : integer := 27;
constant m65_b             : integer := 28;
constant m65_h             : integer := 29;
constant m65_u             : integer := 30;
constant m65_v             : integer := 31;
constant m65_9             : integer := 32;
constant m65_i             : integer := 33;
constant m65_j             : integer := 34;
constant m65_0             : integer := 35;
constant m65_m             : integer := 36;
constant m65_k             : integer := 37;
constant m65_o             : integer := 38;
constant m65_n             : integer := 39;
constant m65_plus          : integer := 40;
constant m65_p             : integer := 41;
constant m65_l             : integer := 42;
constant m65_minus         : integer := 43;
constant m65_dot           : integer := 44;
constant m65_colon         : integer := 45;
constant m65_at            : integer := 46;
constant m65_comma         : integer := 47;
constant m65_gbp           : integer := 48;
constant m65_asterisk      : integer := 49;
constant m65_semicolon     : integer := 50;
constant m65_clr_home      : integer := 51;
constant m65_right_shift   : integer := 52;
constant m65_equal         : integer := 53;
constant m65_arrow_up      : integer := 54;  -- symbol, not cursor
constant m65_slash         : integer := 55;
constant m65_1             : integer := 56;
constant m65_arrow_left    : integer := 57;  -- symbol, not cursor
constant m65_ctrl          : integer := 58;
constant m65_2             : integer := 59;
constant m65_space         : integer := 60;
constant m65_mega          : integer := 61;
constant m65_q             : integer := 62;
constant m65_run_stop      : integer := 63;
constant m65_no_scrl       : integer := 64;
constant m65_tab           : integer := 65;
constant m65_alt           : integer := 66;
constant m65_help          : integer := 67;
constant m65_f9            : integer := 68;
constant m65_f11           : integer := 69;
constant m65_f13           : integer := 70;
constant m65_esc           : integer := 71;
constant m65_capslock      : integer := 72;
constant m65_up_crsr       : integer := 73;  -- cursor up
constant m65_left_crsr     : integer := 74;  -- cursor left
constant m65_restore       : integer := 75;

signal key_pressed_n : std_logic_vector(79 downto 0);

-- 4-to-10 decoder for keyboard row selection.
signal row_n : std_logic_vector(9 downto 0);
signal shift_n : std_logic;
signal mega_n : std_logic;
signal unshift_n: std_logic;

begin

    keyboard_state : process(clk_main_i)
    begin
        if rising_edge(clk_main_i) then
            key_pressed_n(key_num_i) <= key_pressed_n_i;
        end if;
    end process;

    diag_sense_o <= key_pressed_n(m65_mega);

    -- 4-to-10 decoder for keyboard row selection. Active low.
    -- We should probaly use variables for these intermediate calulations,
    -- but nobody would detect a clock of delay?!?
    row_n(0) <= '0' when to_integer(unsigned(row_select_i)) = 0 else '1';
    row_n(1) <= '0' when to_integer(unsigned(row_select_i)) = 1 else '1';
    row_n(2) <= '0' when to_integer(unsigned(row_select_i)) = 2 else '1';
    row_n(3) <= '0' when to_integer(unsigned(row_select_i)) = 3 else '1';
    row_n(4) <= '0' when to_integer(unsigned(row_select_i)) = 4 else '1';
    row_n(5) <= '0' when to_integer(unsigned(row_select_i)) = 5 else '1';
    row_n(6) <= '0' when to_integer(unsigned(row_select_i)) = 6 else '1';
    row_n(7) <= '0' when to_integer(unsigned(row_select_i)) = 7 else '1';
    row_n(8) <= '0' when to_integer(unsigned(row_select_i)) = 8 else '1';
    row_n(9) <= '0' when to_integer(unsigned(row_select_i)) = 9 else '1';

    -- Since we use "negative logic" we swap 'and' and 'or' too; De Morgan.
    shift_n <= key_pressed_n(m65_left_shift) and key_pressed_n(m65_right_shift);
    mega_n <= key_pressed_n(m65_mega);
    -- Mark the keys where we press SHIFT on the M65 keyboard, but which do not
    -- have shift on the PET keyboard.
    unshift_n <= shift_n or (key_pressed_n(m65_1) and           -- !
                             key_pressed_n(m65_2) and           -- "
                             key_pressed_n(m65_3) and           -- #
                             key_pressed_n(m65_4) and           -- $
                             key_pressed_n(m65_5) and           -- %
                             key_pressed_n(m65_6) and           -- &
                             key_pressed_n(m65_7) and           -- '
                             key_pressed_n(m65_8) and           -- (
                             key_pressed_n(m65_9) and           -- )
                             key_pressed_n(m65_comma) and       -- <
                             key_pressed_n(m65_dot) and         -- >
                             key_pressed_n(m65_slash) and       -- ?
                             key_pressed_n(m65_colon) and       -- [
                             key_pressed_n(m65_semicolon)       -- ]
                            );

    -- TODO: @ * + - \ are a special cases: they have different characters when
    -- shifted on both keyboards.
    -- TODO: everything with MEGA pressed.

    column_selected_o(0) <=
        (row_n(0) or key_pressed_n(m65_1)          or shift_n      ) and     -- !
        (row_n(1) or key_pressed_n(m65_2)          or shift_n      ) and     -- "
        (row_n(2) or key_pressed_n(m65_q)                          ) and     -- q
        (row_n(3) or key_pressed_n(m65_w)                          ) and     -- w
        (row_n(4) or key_pressed_n(m65_a)                          ) and     -- a
        (row_n(5) or key_pressed_n(m65_s)                          ) and     -- s
        (row_n(6) or key_pressed_n(m65_z)                          ) and     -- z
        (row_n(7) or key_pressed_n(m65_x)                          ) and     -- x
        (row_n(8) or (mega_n and                                             -- mega is *always* shift
                      (key_pressed_n(m65_left_shift) or not unshift_n) and   -- left shift unless !"<> etc
                      key_pressed_n(m65_up_crsr) and                         --   or up
                      key_pressed_n(m65_left_crsr))                ) and     --   or left
        (row_n(9) or key_pressed_n(m65_ctrl)                       );        -- off/rvs

    column_selected_o(1) <=
        (row_n(0) or key_pressed_n(m65_3)          or shift_n      ) and     -- #
        (row_n(1) or key_pressed_n(m65_4)          or shift_n      ) and     -- $
        (row_n(2) or key_pressed_n(m65_e)                          ) and     -- e
        (row_n(3) or key_pressed_n(m65_r)                          ) and     -- r
        (row_n(4) or key_pressed_n(m65_d)                          ) and     -- d
        (row_n(5) or key_pressed_n(m65_f)                          ) and     -- f
        (row_n(6) or key_pressed_n(m65_c)                          ) and     -- c
        (row_n(7) or key_pressed_n(m65_v)                          ) and     -- v
        (row_n(8) or key_pressed_n(m65_at)                         ) and     -- @
        (row_n(9) or key_pressed_n(m65_colon)      or shift_n      );        -- [

    column_selected_o(2) <=
        (row_n(0) or key_pressed_n(m65_5)          or shift_n      ) and     -- %
        (row_n(1) or key_pressed_n(m65_7)          or shift_n      ) and     -- '
        (row_n(2) or key_pressed_n(m65_t)                          ) and     -- t
        (row_n(3) or key_pressed_n(m65_y)                          ) and     -- y
        (row_n(4) or key_pressed_n(m65_g)                          ) and     -- g
        (row_n(5) or key_pressed_n(m65_h)                          ) and     -- h
        (row_n(6) or key_pressed_n(m65_b)                          ) and     -- b
        (row_n(7) or key_pressed_n(m65_n)                          ) and     -- n
        (row_n(8) or key_pressed_n(m65_semicolon)  or shift_n      ) and     -- ]
        (row_n(9) or key_pressed_n(m65_space)                      );        -- space

    column_selected_o(3) <=
        (row_n(0) or key_pressed_n(m65_6)          or shift_n      ) and     -- &
        (row_n(1) or key_pressed_n(m65_gbp)                        ) and     -- \ or pound
        (row_n(2) or key_pressed_n(m65_u)                          ) and     -- u
        (row_n(3) or key_pressed_n(m65_i)                          ) and     -- i
        (row_n(4) or key_pressed_n(m65_j)                          ) and     -- j
        (row_n(5) or key_pressed_n(m65_k)                          ) and     -- k
        (row_n(6) or key_pressed_n(m65_m)                          ) and     -- m
        (row_n(7) or key_pressed_n(m65_comma)      or not shift_n  ) and     -- ,
        (row_n(8) or '1'                                           ) and     -- n/c
        (row_n(9) or key_pressed_n(m65_comma)      or shift_n      );        -- <

    column_selected_o(4) <=
        (row_n(0) or key_pressed_n(m65_8)          or shift_n      ) and     -- (
        (row_n(1) or key_pressed_n(m65_9)          or shift_n      ) and     -- )
        (row_n(2) or key_pressed_n(m65_o)                          ) and     -- o
        (row_n(3) or key_pressed_n(m65_p)                          ) and     -- p
        (row_n(4) or key_pressed_n(m65_l)                          ) and     -- l
        (row_n(5) or key_pressed_n(m65_colon)      or not shift_n  ) and     -- :
        (row_n(6) or key_pressed_n(m65_semicolon)  or not shift_n  ) and     -- ;
        (row_n(7) or key_pressed_n(m65_slash)      or     shift_n  ) and     -- ?
        (row_n(8) or key_pressed_n(m65_dot)        or     shift_n  ) and     -- >
        (row_n(9) or key_pressed_n(m65_run_stop)                   );        -- run/stop

    column_selected_o(5) <=
        (row_n(0) or key_pressed_n(m65_arrow_left)                 ) and     -- <-
        (row_n(1) or '1'                                           ) and     -- n/c
        (row_n(2) or key_pressed_n(m65_arrow_up)                   ) and     -- ^
        (row_n(3) or '1'                                           ) and     -- n/c
        (row_n(4) or '1'                                           ) and     -- n/c
        (row_n(5) or '1'                                           ) and     -- n/c
        (row_n(6) or key_pressed_n(m65_return)                     ) and     -- return
        (row_n(7) or '1'                                           ) and     -- n/c
        (row_n(8) or key_pressed_n(m65_right_shift) or not unshift_n) and    -- right shift
        (row_n(9) or '1'                                           );        -- n/c

    column_selected_o(6) <=
        (row_n(0) or key_pressed_n(m65_clr_home)                   ) and     -- clr/home
        (row_n(1) or (key_pressed_n(m65_vert_crsr) and
                      key_pressed_n(m65_up_crsr))                  ) and     -- crsr down (or up)
        (row_n(2) or key_pressed_n(m65_7)          or not shift_n  ) and     -- 7
        (row_n(3) or key_pressed_n(m65_8)          or not shift_n  ) and     -- 8
        (row_n(4) or key_pressed_n(m65_4)          or not shift_n  ) and     -- 4
        (row_n(5) or key_pressed_n(m65_5)          or not shift_n  ) and     -- 5
        (row_n(6) or key_pressed_n(m65_1)          or not shift_n  ) and     -- 1
        (row_n(7) or key_pressed_n(m65_2)          or not shift_n  ) and     -- 2
        (row_n(8) or key_pressed_n(m65_0)                          ) and     -- 0
        (row_n(9) or key_pressed_n(m65_dot)        or not shift_n  );        -- .

    column_selected_o(7) <=
        (row_n(0) or (key_pressed_n(m65_horz_crsr) and
                      key_pressed_n(m65_left_crsr))                ) and     -- crsr => (or <=)
        (row_n(1) or key_pressed_n(m65_ins_del)                    ) and     -- inst/del
        (row_n(2) or key_pressed_n(m65_9)          or not shift_n  ) and     -- 9
        (row_n(3) or key_pressed_n(m65_slash)      or not shift_n  ) and     -- /
        (row_n(4) or key_pressed_n(m65_6)          or not shift_n  ) and     -- 6
        (row_n(5) or key_pressed_n(m65_asterisk)                   ) and     -- *
        (row_n(6) or key_pressed_n(m65_3)          or not shift_n  ) and     -- 3
        (row_n(7) or key_pressed_n(m65_plus)                       ) and     -- +
        (row_n(8) or key_pressed_n(m65_minus)                      ) and     -- -
        (row_n(9) or key_pressed_n(m65_equal)                      );        -- =

end beh;
