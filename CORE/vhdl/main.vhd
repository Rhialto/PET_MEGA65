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
use work.vdrives_pkg.all;
use work.globals.C_MENU_MODEL_2001_BLANK;
use work.globals.C_MENU_MODEL_2001_WHITE;


entity main is
   generic (
      G_VDNUM                 : natural         -- amount of virtual drives
   );
   port (
      clk_main_i              : in  std_logic;  -- 56 MHz
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;

      -- On-screen-menu selection
      osm_i                   : in  std_logic_vector(255 downto 0);

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

      -- 2031 drive led (color is RGB)
      drive_led_o            : out std_logic;
      drive_led_col_o        : out std_logic_vector(23 downto 0);

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
      pot2_y_i                : in  std_logic_vector(7 downto 0);

      -- C64 IEC handled by QNICE
      pet_clk_sd_i           : in  std_logic;                -- QNICE "sd card write clock" for floppy drive internal dual clock RAM buffer
      pet_qnice_addr_i       : in  std_logic_vector(27 downto 0);
      pet_qnice_data_i       : in  std_logic_vector(15 downto 0);
      pet_qnice_data_o       : out std_logic_vector(15 downto 0);
      pet_qnice_ce_i         : in  std_logic;
      pet_qnice_we_i         : in  std_logic;

		-- Access custom Kernal: PET's Basic and character ROM (in QNICE clock domain via pet_clk_sd_i)
      petrom_we_i            : in  std_logic;
      petchars_ce_i          : in  std_logic;
      petrom_addr_i          : in  std_logic_vector(14 downto 0);
      petrom_data_i          : in  std_logic_vector(7 downto 0);
      petrom_data_o          : out std_logic_vector(7 downto 0);

      -- Access custom DOS for the simulated C2031 (in QNICE clock domain via pet_clk_sd_i)
      c2031rom_we_i          : in  std_logic;
      c2031rom_addr_i        : in  std_logic_vector(15 downto 0);
      c2031rom_data_i        : in  std_logic_vector(7 downto 0);
      c2031rom_data_o        : out std_logic_vector(7 downto 0)
   );
end entity main;

architecture synthesis of main is

   -- Generic MiSTer PET signals
   --signal pet_pause            : std_logic;
    signal pet_drive_led        : std_logic_vector(G_VDNUM-1 downto 0);

    signal divby7 : INTEGER range 0 to 7 := 0;          -- 3 bits
    signal cpu_div : INTEGER range 0 to 127 := 0;       -- 7 bits
    signal cpu_rate : INTEGER range 0 to 127 := 55;     -- 7 bits
    type cpu_rates_array is array (0 to 3) of INTEGER range 0 to 127 ;  -- 7 bits each
    constant cpu_rates : cpu_rates_array := (55, 27, 13, 6);
    signal ce_8mp : STD_LOGIC;
    signal ce_8mn : STD_LOGIC;
    signal ce_1m : STD_LOGIC;

    signal addr : std_logic_vector(15 downto 0);
    signal addr_unused : std_logic_vector(23 downto 16);
    signal cpu_data_out : std_logic_vector(7 downto 0);
    signal cpu_data_in : std_logic_vector(7 downto 0);
    signal rnw : std_logic;
    signal irq : std_logic;

    signal pix : std_logic;
    signal HBlank : std_logic;
    signal VBlank : std_logic;
    --signal HSync : std_logic;
    --signal VSync : std_logic;
    signal audioDat : std_logic ;
    signal tape_audio : std_logic;

    -- Directly connect the PET's PIA1 to the emulated keyboard matrix within keyboard.vhd
    signal keyb_row_select : std_logic_vector(3 downto 0);
    signal keyb_column_selected : std_logic_vector(7 downto 0);
    signal diag_sense : std_logic;

    -- PET's IEEE connector to the bus
    signal ieee488_pet_data_i  : std_logic_vector(7 downto 0);
    signal ieee488_pet_data_o  : std_logic_vector(7 downto 0);
    signal ieee488_pet_atn_i   : std_logic;
    signal ieee488_pet_atn_o   : std_logic;
    signal ieee488_pet_ifc_o   : std_logic;
    signal ieee488_pet_srq_i   : std_logic;
    signal ieee488_pet_dav_i   : std_logic;
    signal ieee488_pet_dav_o   : std_logic;
    signal ieee488_pet_eoi_i   : std_logic;
    signal ieee488_pet_eoi_o   : std_logic;
    signal ieee488_pet_nrfd_i  : std_logic;
    signal ieee488_pet_nrfd_o  : std_logic;
    signal ieee488_pet_ndac_i  : std_logic;
    signal ieee488_pet_ndac_o  : std_logic;

    -- The disk's IEEE connector to the bus
    signal ieee488_d01_data_i  : std_logic_vector(7 downto 0);
    signal ieee488_d01_data_o  : std_logic_vector(7 downto 0);
    signal ieee488_d01_atn_i   : std_logic;
    signal ieee488_d01_atn_o   : std_logic;
    signal ieee488_d01_ifc_i   : std_logic;
    signal ieee488_d01_srq_o   : std_logic;
    signal ieee488_d01_dav_i   : std_logic;
    signal ieee488_d01_dav_o   : std_logic;
    signal ieee488_d01_eoi_i   : std_logic;
    signal ieee488_d01_eoi_o   : std_logic;
    signal ieee488_d01_nrfd_i  : std_logic;
    signal ieee488_d01_nrfd_o  : std_logic;
    signal ieee488_d01_ndac_i  : std_logic;
    signal ieee488_d01_ndac_o  : std_logic;

   -- Simulated IEEE-488 drives
   signal iec_drive_ce         : std_logic;      -- chip enable for iec_drive (clock divider, see generate_drive_ce below)
   signal iec_dce_sum          : integer := 0;   -- caution: we expect 32-bit integers here and we expect the initialization to 0

   signal iec_img_mounted      : std_logic_vector(G_VDNUM - 1 downto 0);
   signal iec_img_readonly     : std_logic;
   signal iec_img_size         : std_logic_vector(31 downto 0);
   signal iec_img_type         : std_logic_vector( 1 downto 0);

   signal iec_drives_reset     : std_logic_vector(G_VDNUM - 1 downto 0);
   signal vdrives_mounted      : std_logic_vector(G_VDNUM - 1 downto 0);
   signal cache_dirty          : std_logic_vector(G_VDNUM - 1 downto 0);
   signal prevent_reset        : std_logic;

   signal iec_sd_lba           : vd_vec_array(G_VDNUM - 1 downto 0)(31 downto 0);
   signal iec_sd_blk_cnt       : vd_vec_array(G_VDNUM - 1 downto 0)( 5 downto 0);
   signal iec_sd_rd            : vd_std_array(G_VDNUM - 1 downto 0);
   signal iec_sd_wr            : vd_std_array(G_VDNUM - 1 downto 0);
   signal iec_sd_ack           : vd_std_array(G_VDNUM - 1 downto 0);
   signal iec_sd_buf_addr      : std_logic_vector(13 downto 0);
   signal iec_sd_buf_data_in   : std_logic_vector( 7 downto 0);
   signal iec_sd_buf_data_out  : vd_vec_array(G_VDNUM - 1 downto 0)(7 downto 0);
   signal iec_sd_buf_wr        : std_logic;
   --signal iec_par_stb_in       : std_logic;
   --signal iec_par_stb_out      : std_logic;
   --signal iec_par_data_in      : std_logic_vector(7 downto 0);
   --signal iec_par_data_out     : std_logic_vector(7 downto 0);

   -- RESET SEMANTICS
   --
   -- The C64 core implements core specific semantics: A standard reset of the core is a soft reset and
   -- will not interfere with any "reset protections". This also means that a soft reset will start
   -- soft- and hardware cartridges. A hard reset on the other hand does circumvent "reset protections"
   -- and will therefore also exit games which prevent you from exitting them via reset and you can
   -- also exit from simulated cartridges using a hard reset.
   --
   -- When pulsing reset_soft_i from the outside (mega65.vhd), then you need to ensure that this
   -- pulse is at least 32 clock cycles long. Currently (see mega65.vhd) there are two sources that
   -- trigger reset_soft_i: The M2M reset manager and sw_cartridge_wrapper. Both are ensuring that
   -- the rest pulse is at least 32 clock cycles long.
   --
   -- A reset that is coming from a hardware cartridge via cart_reset_i (which is low active) is treated
   -- just like reset_soft_i. We can assume that the pulse will be long enough because cartridges are
   -- aware of minimum reset durations. (Example: The EF3 pulses the reset for 7xphi2, which is way longer
   -- then 32 cycles.)
   --
   -- CAUTION: NEVER DIRECTLY USE THE INPUT SIGNALS
   --       reset_soft_i and
   --       reset_hard_i
   -- IN MAIN.VHD AS YOU WILL RISK DATA CORRUPTION!
   -- Exceptions are the processes "hard_reset" and "handle_cartridge_triggered_resets",
   -- which "know what they are doing".
   --
   -- The go-to signal for all standard reset situations within main.vhd:
   --       reset_core_n
   -- To prevent data corruption, there is a protected version of reset_soft_i called reset_core_n.
   -- Data corruption can for example occur, when a user presses the reset button while a simulated
   -- disk drive is still writing to the disk image on the SD card. Therefore reset_core_n is
   -- protected by using the signal prevent_reset.
   --
   -- hard_reset_n IS NOT MEANT TO BE USED IN MAIN.VHD
   -- with the exception of the "cpu_data_in" the reset input of "i_cartridge".
   signal reset_core_n         : std_logic := '1';
   signal reset_core_int_n     : std_logic := '1';
   signal hard_reset_n         : std_logic := '1';

   constant C_HARD_RST_DELAY   : natural   := 100_000; -- roundabout 1/30 of a second
   signal hard_rst_counter     : natural   := 0;
   signal hard_reset_n_d       : std_logic := '1';
   signal cold_start_done      : std_logic := '0';

   signal sound_sample         : signed(15 downto 0);	-- low-passed sound

begin

   -- prevent data corruption by not allowing a soft reset to happen while the cache is still dirty
   -- since we can have more than one cache that might be dirty, we convert the std_logic_vector of length G_VDNUM
   -- into an unsigned and check for zero
   prevent_reset <= '0' when unsigned(cache_dirty) = 0 else
                    '1';

   -- the color of the drive led is green normally, but it turns yellow
   -- when the cache is dirty and/or currently being flushed
   drive_led_col_o <= x"00FF00" when unsigned(cache_dirty) = 0 else
                      x"FFFF00";

   -- the drive led is on if either the C64 is writing to the virtual disk (cached in RAM)
   -- or if the dirty cache is dirty and/orcurrently being flushed to the SD card
   drive_led_o <= pet_drive_led(0) when unsigned(cache_dirty) = 0 else
                  '1';
   --------------------------------------------------------------------------------------------------
   -- Hard reset
   --------------------------------------------------------------------------------------------------

   hard_reset_proc : process (clk_main_i)
   begin
      if rising_edge(clk_main_i) then
         if reset_soft_i = '1' or reset_hard_i = '1'  then
            -- Due to sw_cartridge_wrapper's logic, reset_soft_i stays high longer than reset_hard_i.
            -- We need to make sure that this is not interfering with hard_reset_n
            if reset_hard_i = '1' then
               hard_rst_counter  <= C_HARD_RST_DELAY;
               hard_reset_n      <= '0';
            end if;

            -- reset_core_n is low-active, so prevent_reset = 0 means execute reset
            -- but a hard reset can override
            reset_core_int_n     <= prevent_reset and (not reset_hard_i);
         else
            -- The idea of the hard reset is, that while reset_core_n is back at '1' and therefore the core is
            -- running (not being reset any more), hard_reset_n stays low for C_HARD_RST_DELAY clock cycles.
            -- Reason: We need to give the KERNAL time to execute the routine $FD02 where it checks for the
            -- cartridge signature "CBM80" in $8003 onwards. In case reset_n = '0' during these tests (i.e. hard
            -- reset active) we will return zero instead of "CBM80" and therefore perform a hard reset.
            reset_core_int_n <= '1';
            if hard_rst_counter = 0 then
               hard_reset_n <= '1';
            else
               hard_rst_counter <= hard_rst_counter - 1;
            end if;
         end if;
      end if;
   end process hard_reset_proc;

   -- Combined reset signal to be used throughout main.vhd: reset triggered by the MEGA65's reset button (reset_core_int_n)
   -- and reset triggered by an external cartridge.
   combined_reset_proc : process (all)
   begin
      reset_core_n <= '1';

      -- cart_reset_i becomes cart_reset_o as soon as cart_reset_oe_o = '1', and the latter one becomes '1' as soon
      -- as reset_core_int_n = '0' so we need to ignore cart_reset_i in this case
      if reset_core_int_n = '0' then
         reset_core_n <= '0';
      end if;
   end process combined_reset_proc;

   -- To make sure that cartridges in the Expansion Port start properly, we must not do a hard reset and mask the $8000 memory area,
   -- when the core is launched for the first time (cold start).
   handle_cold_start_proc : process (clk_main_i)
   begin
      if rising_edge(clk_main_i) then
         hard_reset_n_d <= hard_reset_n;
         -- detect the rising edge of hard_reset_n_d
         if hard_reset_n = '1' and hard_reset_n_d = '0' and cold_start_done = '0' then
            cold_start_done <= '1';
         end if;
      end if;
   end process handle_cold_start_proc;

     -- Clock enable signals process
     process(clk_main_i)
     begin
         if rising_edge(clk_main_i) then
             -- Divide 56 MHz by 7 to get 8 Mhz.
             divby7 <= divby7 + 1;
             if divby7 = 6 then
                 divby7 <= 0;
             end if;
             ce_8mp <= '1' when divby7 = 0 else '0';
             ce_8mn <= '1' when divby7 = 3 else '0';

             -- Divide 56 MHz by 56 to get 1 MHz (other factors potentially available).
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
             Res_n => reset_core_n,
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
             DIn => cpu_data_in,
             DOut => cpu_data_out
         );


    pet2001hw_inst : entity work.pet2001hw
    port map (
        addr        => addr,
        data_out    => cpu_data_in,
        data_in     => cpu_data_out,
        we          => not rnw,
        irq         => irq,

        pix         => pix,
        HSync       => video_hs_o,
        VSync       => video_vs_o,
        HBlank      => HBlank,                -- delayed to video_hblank_o,
        VBlank      => VBlank,                -- delayed to video_vblank_o,
        eoi_blanks  => osm_i(C_MENU_MODEL_2001_BLANK),

        keyrow      => keyb_row_select,       -- keyboard scanning (row select)
        keyin       => keyb_column_selected,  -- keyboard scanning (pressed keys)

        cass_motor_n    => open,              -- output? not connected?
        cass_write      => open,              -- tape_write,
        audio           => audioDat,          -- sound from CB2: 1 MHz, 1 bit
        cass_sense_n    => 0,
        cass_read       => tape_audio,

        -- IEEE-488 bus
        ieee488_data_i  => ieee488_pet_data_i,
        ieee488_data_o  => ieee488_pet_data_o,
        ieee488_atn_i   => ieee488_pet_atn_i,
        ieee488_atn_o   => ieee488_pet_atn_o,
        ieee488_ifc_o   => ieee488_pet_ifc_o,
        ieee488_srq_i   => ieee488_pet_srq_i,
        ieee488_dav_i   => ieee488_pet_dav_i,
        ieee488_dav_o   => ieee488_pet_dav_o,
        ieee488_eoi_i   => ieee488_pet_eoi_i,
        ieee488_eoi_o   => ieee488_pet_eoi_o,
        ieee488_nrfd_i  => ieee488_pet_nrfd_i,
        ieee488_nrfd_o  => ieee488_pet_nrfd_o,
        ieee488_ndac_i  => ieee488_pet_ndac_i,
        ieee488_ndac_o  => ieee488_pet_ndac_o,

        -- QNICE clock domain via pet_clk_sd_i
        dma_clk         => pet_clk_sd_i,
        dma_addr        => petrom_addr_i, -- 0,
        dma_din         => petrom_data_i, -- 0,
        dma_dout        => petrom_data_o, -- open,
        dma_we          => petrom_we_i, --0,
        dma_char_ce     => petchars_ce_i, --0,

        clk_speed       => 0,
        clk_stop        => 0,
        diag_l          => diag_sense,
        clk             => clk_main_i,
        ce_8mp          => ce_8mp,
        ce_8mn          => ce_8mn,
        ce_1m           => ce_1m,
        reset           => not reset_core_n
     ); -- hw_inst

    ieee488_bus : entity work.ieee488_bus_1
    port map (
        pet_data_o => ieee488_pet_data_i,
        pet_data_i => ieee488_pet_data_o,
        pet_atn_o  => ieee488_pet_atn_i,
        pet_atn_i  => ieee488_pet_atn_o,
        pet_ifc_i  => ieee488_pet_ifc_o,
        pet_srq_o  => ieee488_pet_srq_i,
        pet_dav_o  => ieee488_pet_dav_i,
        pet_dav_i  => ieee488_pet_dav_o,
        pet_eoi_o  => ieee488_pet_eoi_i,
        pet_eoi_i  => ieee488_pet_eoi_o,
        pet_nrfd_o => ieee488_pet_nrfd_i,
        pet_nrfd_i => ieee488_pet_nrfd_o,
        pet_ndac_o => ieee488_pet_ndac_i,
        pet_ndac_i => ieee488_pet_ndac_o,

        d01_data_o => ieee488_d01_data_i,
        d01_data_i => ieee488_d01_data_o,
        d01_atn_i  => ieee488_d01_atn_o,
        d01_atn_o  => ieee488_d01_atn_i,
        d01_ifc_o  => ieee488_d01_ifc_i,
        d01_srq_i  => ieee488_d01_srq_o,
        d01_dav_o  => ieee488_d01_dav_i,
        d01_dav_i  => ieee488_d01_dav_o,
        d01_eoi_o  => ieee488_d01_eoi_i,
        d01_eoi_i  => ieee488_d01_eoi_o,
        d01_nrfd_o => ieee488_d01_nrfd_i,
        d01_nrfd_i => ieee488_d01_nrfd_o,
        d01_ndac_o => ieee488_d01_ndac_i,
        d01_ndac_i => ieee488_d01_ndac_o

--        d01_data_o => open,
--        d01_data_i => (others => 'H'),
--        d01_atn_i  => 'H',
--        d01_atn_o  => open,
--        d01_ifc_o  => open,
--        d01_srq_i  => 'H',
--        d01_dav_o  => open,
--        d01_dav_i  => 'H',
--        d01_eoi_o  => open,
--        d01_eoi_i  => 'H',
--        d01_nrfd_o => open,
--        d01_nrfd_i => 'H',
--        d01_ndac_o => open,
--        d01_ndac_i => 'H'

    ); -- ieee488_bus

     process (clk_main_i)
     begin
         if rising_edge(clk_main_i) then
            if ce_8mn then  -- was ce_7mn
                if osm_i(C_MENU_MODEL_2001_WHITE) then
                    video_red_o   <= x"AA" when pix = '1' else "00011111"; -- test signal
                    video_green_o <= x"AA" when pix = '1' else "00000000";
                    video_blue_o  <= x"FF" when pix = '1' else "00000000";
                else
                    video_red_o   <= "00011111"; -- test signal
                    video_green_o <= "11111111" when pix = '1' else "00000000";
                    video_blue_o  <= "00000000";
                end if;
                video_hblank_o <= HBlank;
                video_vblank_o <= VBlank;
            end if;
            video_ce_o <= ce_8mn;   -- was ce_7mn
        end if;
     end process;

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

   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         row_select_i         => keyb_row_select,
         column_selected_o    => keyb_column_selected,

         diag_sense_o         => diag_sense
      ); -- i_keyboard


   -- 16 MHz chip enable for the IEC drives, so that ph2_r and ph2_f can be 1 MHz (C1541's CPU runs with 1 MHz)
   -- Uses a counter to compensate for clock drift, because the input clock is not exactly at 32 MHz
   --
   -- It is important that also in the HDMI-Flicker-Free-mode we are using the vanilla clock speed given by
   -- CORE_CLK_SPEED_PAL (or CORE_CLK_SPEED_NTSC) and not a speed-adjusted version of this speed. Reason:
   -- Otherwise the drift-compensation in generate_drive_ce will compensate for the slower clock speed and
   -- ensure an exact 32 MHz frequency even though the system has been slowed down by the HDMI-Flicker-Free.
   -- This leads to a different frequency ratio C64 vs 1541 and therefore to incompatibilities such as the
   -- one described in this GitHub issue:
   -- https://github.com/MJoergen/C64MEGA65/issues/2
   iec_drive_ce_proc : process (all)
      variable msum, nextsum: integer;
   begin
      msum    := clk_main_speed_i;
      nextsum := iec_dce_sum + 16000000;

      if rising_edge(clk_main_i) then
         iec_drive_ce <= '0';
         if reset_core_n = '0' then
            iec_dce_sum <= 0;
         else
            iec_dce_sum <= nextsum;
            if nextsum >= msum then
               iec_dce_sum <= nextsum - msum;
               iec_drive_ce <= '1';
            end if;
         end if;
      end if;
   end process iec_drive_ce_proc;

   -- Drive is held to reset if the core is held to reset or if the drive is not mounted, yet
   -- @TODO: MiSTer also allows these options when it comes to drive-enable:
   --        "P2oPQ,Enable Drive #8,If Mounted,Always,Never;"
   --        "P2oNO,Enable Drive #9,If Mounted,Always,Never;"
   --        This code currently only implements the "If Mounted" option
   iec_drv_reset_gen : for i in 0 to G_VDNUM - 1 generate
      -- iec_drives_reset(i) <= (not reset_core_n) or (not vdrives_mounted(i));
       iec_drives_reset(i) <= (not reset_core_n); -- for now allow empty drives...
   end generate iec_drv_reset_gen;

------------------------------------------
-- Let's connect some drives!
------------------------------------------
   iec_drive_inst : entity work.iec_drive
      generic map (
         IEEE           => 1,                -- PETs only have an IEEE-488 bus, not IEC.
         PARPORT        => 0,                -- which implies there is no custom parallel cable needed or possible
         DUALROM        => 0,                -- and there is just one DOS as well.
         DRIVES         => G_VDNUM
      )
      port map (
         clk            => clk_main_i,
         ce             => iec_drive_ce,
         reset          => iec_drives_reset,
         pause          => pause_i,

         -- IEC interface to the C64 core
         iec_clk_i      => 'H',
         iec_clk_o      => open,
         iec_atn_i      => 'H',
         iec_data_i     => 'H',
         iec_data_o     => open,

         -- Device connected to IEEE-488 bus

        ieee_data_i     => ieee488_d01_data_i,
        ieee_data_o     => ieee488_d01_data_o,
        ieee_atn_o      => ieee488_d01_atn_o ,
        ieee_atn_i      => ieee488_d01_atn_i ,
        ieee_ifc_i      => ieee488_d01_ifc_i ,
        ieee_srq_o      => ieee488_d01_srq_o ,
        ieee_dav_i      => ieee488_d01_dav_i ,
        ieee_dav_o      => ieee488_d01_dav_o ,
        ieee_eoi_i      => ieee488_d01_eoi_i ,
        ieee_eoi_o      => ieee488_d01_eoi_o ,
        ieee_nrfd_i     => ieee488_d01_nrfd_i,
        ieee_nrfd_o     => ieee488_d01_nrfd_o,
        ieee_ndac_i     => ieee488_d01_ndac_i,
        ieee_ndac_o     => ieee488_d01_ndac_o,

         -- disk image status
         img_mounted    => iec_img_mounted,
         img_readonly   => iec_img_readonly,
         img_size       => iec_img_size,
         img_type       => iec_img_type,         -- 00=1541 emulated GCR(D64), 01=1541 real GCR mode (G64,D64), 10=1581 (D81)

         -- QNICE SD-Card/FAT32 interface
         clk_sys        => pet_clk_sd_i,         -- "SD card" clock for writing to the drives' internal data buffers

         sd_lba         => iec_sd_lba,
         sd_blk_cnt     => iec_sd_blk_cnt,
         sd_rd          => iec_sd_rd,
         sd_wr          => iec_sd_wr,
         sd_ack         => iec_sd_ack,
         sd_buff_addr   => iec_sd_buf_addr,
         sd_buff_dout   => iec_sd_buf_data_in,   -- data from SD card to the buffer RAM within the drive ("dout" is a strange name)
         sd_buff_din    => iec_sd_buf_data_out,  -- read the buffer RAM within the drive
         sd_buff_wr     => iec_sd_buf_wr,

         -- drive led
         led            => pet_drive_led,

         -- Parallel C1541 port, not connected on a 2031, at least not in this way
         par_stb_i      => 'H',
         par_stb_o      => open,
         par_data_i     => (others => 'H'),
         par_data_o     => open,

         -- Access custom rom (DOS): All in QNICE clock domain but rom_std_i is in main clock domain
         rom_std_i      => '1',  -- pet_rom_i(0) or pet_rom_i(1), -- 1=use the factory default ROM
         rom_addr_i     => c2031rom_addr_i,
         rom_data_i     => c2031rom_data_i,
         rom_wr_i       => c2031rom_we_i,
         rom_data_o     => c2031rom_data_o
      ); -- iec_drive_inst

   -- and the virtual counterpart...

   vdrives_inst : entity work.vdrives
      generic map (
         VDNUM                => G_VDNUM,             -- amount of virtual drives
         BLKSZ                => 1                    -- 1 = 256 bytes block size
      )
      port map (
         clk_qnice_i          => pet_clk_sd_i,
         clk_core_i           => clk_main_i,
         reset_core_i         => not reset_core_n,

         -- MiSTer's "SD config" interface, which runs in the core's clock domain
         img_mounted_o        => iec_img_mounted,
         img_readonly_o       => iec_img_readonly,
         img_size_o           => iec_img_size,
         img_type_o           => iec_img_type,      -- 00=1541 emulated GCR(D64), 01=1541 real GCR mode (G64,D64), 10=1581 (D81)

         -- While "img_mounted_o" needs to be strobed, "drive_mounted" latches the strobe in the core's clock domain,
         -- so that it can be used for resetting (and unresetting) the drive.
         drive_mounted_o      => vdrives_mounted,

         -- Cache output signals: The dirty flags is used to enforce data consistency
         -- (for example by ignoring/delaying a reset or delaying a drive unmount/mount, etc.)
         -- and to signal via "the yellow led" to the user that the cache is not yet
         -- written to the SD card, i.e. that writing is in progress
         cache_dirty_o        => cache_dirty,
         cache_flushing_o     => open,

         -- MiSTer's "SD block level access" interface, which runs in QNICE's clock domain
         -- using dedicated signal on Mister's side such as "clk_sys"
         sd_lba_i             => iec_sd_lba,
         sd_blk_cnt_i         => iec_sd_blk_cnt,    -- number of blocks-1
         sd_rd_i              => iec_sd_rd,
         sd_wr_i              => iec_sd_wr,
         sd_ack_o             => iec_sd_ack,

         -- MiSTer's "SD byte level access": the MiSTer components use a combination of the drive-specific sd_ack and the sd_buff_wr
         -- to determine, which RAM buffer actually needs to be written to (using the clk_qnice_i clock domain)
         sd_buff_addr_o       => iec_sd_buf_addr,
         sd_buff_dout_o       => iec_sd_buf_data_in,
         sd_buff_din_i        => iec_sd_buf_data_out,
         sd_buff_wr_o         => iec_sd_buf_wr,

         -- QNICE interface (MMIO, 4k-segmented)
         -- qnice_addr is 28-bit because we have a 16-bit window selector and a 4k window: 65536*4096 = 268.435.456 = 2^28
         qnice_addr_i         => pet_qnice_addr_i,
         qnice_data_i         => pet_qnice_data_i,
         qnice_data_o         => pet_qnice_data_o,
         qnice_ce_i           => pet_qnice_ce_i,
         qnice_we_i           => pet_qnice_we_i
      ); -- vdrives_inst

    -- Use a low-pass filter to convert the 1-bit sound at 1 MHz to signed 16-bit data.
    -- Presumably this is being used at 48 kHz but it's available at 1 MHz anyway.

    lowpass_inst : entity work.lowpass
    generic map(
                N => 3,
                DIVISOR => 32
    )
    port map(
                clock => clk_main_i,
                sample_clock => ce_1m,
                sample_bit => audioDat,
                sample_out => sound_sample
    );

    audio_left_o <= sound_sample;
    audio_right_o <= sound_sample;

end architecture synthesis;

