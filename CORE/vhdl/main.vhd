----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural         -- amount of virtual drives
   );
   port (
      clk_main_i              : in  std_logic;  -- 56 MHz
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(7 downto 0);
      video_green_o           : out std_logic_vector(7 downto 0);
      video_blue_o            : out std_logic_vector(7 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0)
   );
end entity main;

architecture synthesis of main is

	signal reset : STD_LOGIC := '1';
	signal initRESET : INTEGER := 10000000;
	signal reset_cnt : INTEGER := 0;
	signal div : std_logic_vector(2 downto 0); -- range 0 to 7 := 0;		-- 3 bits
	signal cpu_div : INTEGER range 0 to 127 := 0;		-- 7 bits
	signal cpu_rate : INTEGER range 0 to 127 := 55;		-- 7 bits
	type cpu_rates_array is array (0 to 3) of INTEGER range 0 to 127 ;	-- 7 bits each
	constant cpu_rates : cpu_rates_array := (55, 27, 13, 6);
	signal ce_7mp : STD_LOGIC;
	signal ce_7mn : STD_LOGIC;
	signal ce_1m : STD_LOGIC;

	signal addr : std_logic_vector(15 downto 0);
	signal addr_unused : std_logic_vector(23 downto 16);
	signal cpu_data_out : std_logic_vector(7 downto 0);
	signal cpu_data_in : std_logic_vector(7 downto 0);
	signal rnw : std_logic;
	signal irq : std_logic;

	signal pix : std_logic;
	signal HSync : std_logic;
	signal VSync : std_logic;
	signal audioDat : std_logic ;
	signal tape_audio : std_logic;

	-- Directly connect the PET's PIA1 to the emulated keyboard matrix within keyboard.vhd
	signal keyb_row_select : std_logic_vector(3 downto 0);
	signal keyb_column_selected : std_logic_vector(7 downto 0);
begin

   -- @TODO: Add the actual MiSTer core here
------------------------------------------------------------

-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- 
-- entity ClockManagement is
--     Port (
--         CLK_50M : in STD_LOGIC;
--         RESET : in STD_LOGIC;
--         status : in STD_LOGIC_VECTOR(10 downto 0);
--         buttons : in STD_LOGIC_VECTOR(1 downto 0);
--         ioctl_download : in STD_LOGIC;
--         ioctl_index : in INTEGER;
--         tape_active : in STD_LOGIC;
--         ram_ready : in STD_LOGIC;
--         clk_sys : out STD_LOGIC;
--         pll_locked : out STD_LOGIC;
--         ce_7mp : out STD_LOGIC;
--         ce_7mn : out STD_LOGIC;
--         ce_1m : out STD_LOGIC
--     );
-- end ClockManagement;
-- 
-- architecture Behavioral of ClockManagement is
-- 
--     signal reset : STD_LOGIC := '1';
--     signal initRESET : INTEGER := 10000000;
--     signal reset_cnt : INTEGER := 0;
--     signal div : INTEGER range 0 to 7 := 0;		-- 3 bits
--     signal cpu_div : INTEGER range 0 to 127 := 0;		-- 7 bits
--     signal cpu_rate : INTEGER range 0 to 127 := 55;		-- 7 bits
--     type cpu_rates_array is array (0 to 3) of INTEGERrange 0 to 127 ;	-- 7 bits each
--     constant cpu_rates : cpu_rates_array := (55, 27, 13, 6);
-- 
--     -- PLL component declaration
--     component pll
--         Port (
--             refclk : in STD_LOGIC;
--             rst : in STD_LOGIC;
--             outclk_0 : out STD_LOGIC;
--             locked : out STD_LOGIC
--         );
--     end component;
-- 
-- begin
-- 
--     -- PLL instantiation
--     pll_inst : pll
--         Port map (
--             refclk => CLK_50M,
--             rst => '0',
--             outclk_0 => clk_sys,
--             locked => pll_locked
--         );
-- 
--     -- Reset logic process
--     process(clk_sys)
--     begin
--         if rising_edge(clk_sys) then
--             if (RESET = '0' or status(0) = '1' or buttons(1) = '1' or (ioctl_download = '1' and ioctl_index = 2) and reset_cnt = 14) and initRESET = 0 then
--                 reset <= '0';
--             else
--                 if initRESET > 0 then
--                     initRESET <= initRESET - 1;
--                 end if;
--                 reset <= '1';
--                 reset_cnt <= reset_cnt + 1;
--             end if;
--         end if;
--     end process;
-- 
--     process(clk_main_i)
--     begin
--         if rising_edge(clk_main_i) then
--             if (RESET = '0') and reset_cnt = 14) and initRESET = 0 then
--                 reset <= '0';
--             else
--                 if initRESET > 0 then
--                     initRESET <= initRESET - 1;
--                 end if;
--                 reset <= '1';
--                 reset_cnt <= reset_cnt + 1;
--             end if;
--         end if;
--     end process;
 
     -- Clock enable signals process
     process(clk_main_i)
     begin
         if rising_edge(clk_main_i) then
             div <= std_logic_vector(unsigned(div) + 1);
             ce_7mp <= not div(2) and not div(1) and not div(0);
             ce_7mn <=     div(2) and not div(1) and not div(0);
             
             cpu_div <= cpu_div + 1;
             if cpu_div = cpu_rate then
                 cpu_div <= 0;
                 --if tape_active = '1' and status(8 downto 7) = "00" then
                 --    cpu_rate <= 2;
                 --else
                     -- cpu_rate <= cpu_rates(to_integer(unsigned(status(10 downto 9))));
                     cpu_rate <= cpu_rates(0);
                 --end if;
             end if;
             -- ce_1m <= not (tape_active = '1' and ram_ready = '0') and (cpu_div = 0);
             ce_1m <= '1' when (cpu_div = 0) else '0';
         end if;
     end process;
-- 
-- end Behavioral;

----------------------------------------------------
-- RAM
-- we don't need this, all RAM and ROM is included in pet2001hw.
----------------------------------------------------

     cpu_inst : entity work.T65
         port map (
             Mode => "00", -- Assuming Mode is a 2-bit signal
             Res_n => not (reset_soft_i or reset_hard_i),
             Enable => ce_1m,
             Clk => clk_main_i,
             Rdy => '1',
             Abort_n => '1',
             IRQ_n => not irq,
             NMI_n => '1',
             SO_n => '1',
             R_W_n => rnw,
             A(23 downto 16) => addr_unused,
             A(15 downto 0) => addr,
             DI => cpu_data_in,
             DO => cpu_data_out
         );
 
-- end Behavioral;

    pet2001hw_inst : entity work.pet2001hw
    port map (
	addr        => addr,
	data_out    => cpu_data_in,
	data_in	    => cpu_data_out,
	we          => not rnw,
	irq         => irq,
	
	pix         => pix,
	HSync       => video_hs_o,
	VSync       => video_vs_o,
	HBlank      => video_hblank_o,
	VBlank      => video_vblank_o,
	
	keyrow      => keyb_row_select,       -- keyboard scanning (row select)
	keyin       => keyb_column_selected,  -- keyboard scanning (pressed keys)

	cass_motor_n	=> open,	      -- output? not connected?
	cass_write	=> open,              -- tape_write,
	audio		=> audioDat,
	cass_sense_n	=> 0,
	cass_read	=> tape_audio,

	dma_addr	=> 0, -- dl_addr,
	dma_din		=> 0, -- dl_data,
	dma_dout	=> open,
	dma_we		=> 0, -- dl_wr,

	clk_speed	=> 0,
	clk_stop	=> 0,
	diag_l		=> 1, -- !status[3],
	clk		=> clk_main_i,
	ce_7mp          => ce_7mp,
	ce_7mn          => ce_7mn,
	ce_1m           => ce_1m,
        reset           => (reset_soft_i or reset_hard_i)
     ); -- hw_inst
     
     process (clk_main_i)
     begin
         if rising_edge(clk_main_i) then
            if ce_7mn then
                video_red_o <= "00011111"; -- test signal
                video_green_o <= "11111111" when pix = '1' else "00000000";
                video_blue_o <= "00000000";
            end if;
            video_ce_o <= ce_7mn;
        end if;
     end process;

    -- port map (
    -- core_name => our name or expression
    -- ...
    -- ); -- i_petcore
   -- The demo core's purpose is to show a test image and to make sure, that the MiSTer2MEGA65 framework
   -- can be synthesized and run stand-alone without an actual MiSTer core being there, yet

   -- On video_ce_o and video_ce_ovl_o: You have an important @TODO when porting a core:
   -- video_ce_o: You need to make sure that video_ce_o divides clk_main_i such that it transforms clk_main_i
   --             into the pixelclock of the core (means: the core's native output resolution pre-scandoubler)
   -- video_ce_ovl_o: Clock enable for the OSM overlay and for sampling the core's (retro) output in a way that
   --             it is displayed correctly on a "modern" analog input device: Make sure that video_ce_ovl_o
   --             transforms clk_main_o into the post-scandoubler pixelclock that is valid for the target
   --             resolution specified by VGA_DX/VGA_DY (globals.vhd)
   -- video_retro15kHz_o: '1', if the output from the core (post-scandoubler) in the retro 15 kHz analog RGB mode.
   --             Hint: Scandoubler off does not automatically mean retro 15 kHz on.
   video_ce_ovl_o <= video_ce_o;

   -- @TODO: Keyboard mapping and keyboard behavior
   -- Each core is treating the keyboard in a different way: Some need low-active "matrices", some
   -- might need small high-active keyboard memories, etc. This is why the MiSTer2MEGA65 framework
   -- lets you define literally everything and only provides a minimal abstraction layer to the keyboard.
   -- You need to adjust keyboard.vhd to your needs
   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

	 row_select_i         => keyb_row_select,
	 column_selected_o    => keyb_column_selected
      ); -- i_keyboard

end architecture synthesis;

