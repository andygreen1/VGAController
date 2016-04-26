library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--
-- Simple VGA Generator.
--

entity VGAController is
    ----
    -- VGA Timing constraints
    -- Refer to http://tinyvga.com/vga-timing for more info
    ----
    generic (
                -- 640x480 @ 60Hz
                --c_hActiveDisplay        : integer := 640-1;
                --c_hFrontPorch           : integer := 16-1;
                --c_hSyncPulse            : integer := 96-1;
                --c_hBackPorch            : integer := 48-1;
                --c_hPolarity             : std_logic := '0'; -- 1: positive polarity, 0: negative
                --c_vActiveDisplay        : integer := 480-1;
                --c_vFrontPorch           : integer := 10-1;
                --c_vSyncPulse            : integer := 2-1;
                --c_vBackPorch            : integer := 33-1;
                --c_vPolarity             : std_logic := '0'
                
                -- 1280x800 @ 60Hz
                --c_hActiveDisplay        : integer := 1280-1;
                --c_hFrontPorch           : integer := 64-1;
                --c_hSyncPulse            : integer := 136-1;
                --c_hBackPorch            : integer := 200-1;
                --c_hPolarity             : std_logic := '0';
                --c_vActiveDisplay        : integer := 800-1;
                --c_vFrontPorch           : integer := 1-1;
                --c_vSyncPulse            : integer := 3-1;
                --c_vBackPorch            : integer := 24-1;
                --c_vPolarity             : std_logic := '1'
                
                -- 1920x1200 @ 60Hz
                --c_hActiveDisplay        : integer := 1920-1;
                --c_hFrontPorch           : integer := 128-1;
                --c_hSyncPulse            : integer := 208-1;
                --c_hBackPorch            : integer := 336-1;
                --c_hPolarity             : std_logic := '0'; -- 1: positive polarity, 0: negative
                --c_vActiveDisplay        : integer := 1200-1;
                --c_vFrontPorch           : integer := 1-1;
                --c_vSyncPulse            : integer := 3-1;
                --c_vBackPorch            : integer := 38-1;
                --c_vPolarity             : std_logic := '1'
                
                -- 1920x1440 @ 75Hz
                --c_hActiveDisplay        : integer := 1920-1;
                --c_hFrontPorch           : integer := 144-1;
                --c_hSyncPulse            : integer := 224-1;
                --c_hBackPorch            : integer := 352-1;
                --c_hPolarity             : std_logic := '0'; -- 1: positive polarity, 0: negative
                --c_vActiveDisplay        : integer := 1440-1;
                --c_vFrontPorch           : integer := 1-1;
                --c_vSyncPulse            : integer := 3-1;
                --c_vBackPorch            : integer := 56-1;
                --c_vPolarity             : std_logic := '1'
                
                
                
                -- replace me!
                c_hActiveDisplay        : integer := 640-1;
                c_hFrontPorch           : integer := 16-1;
                c_hSyncPulse            : integer := 96-1;
                c_hBackPorch            : integer := 48-1;
                c_hPolarity             : std_logic := '0'; -- 1: positive polarity, 0: negative
                c_vActiveDisplay        : integer := 480-1;
                c_vFrontPorch           : integer := 10-1;
                c_vSyncPulse            : integer := 2-1;
                c_vBackPorch            : integer := 33-1;
                c_vPolarity             : std_logic := '0'
    );
    port ( 
                Clk     : in std_logic;
                Reset   : in std_logic;
                DisplayEnable : out std_logic;
                X : out integer range 0 to c_hActiveDisplay;
                Y : out integer range 0 to c_vActiveDisplay;
                HSync : out std_logic;
                VSync : out std_logic
            );
end VGAController;

architecture synth of VGAController is
    signal hsync_internal 	: std_logic := '0';
    signal vsync_internal 	: std_logic := '0';
    signal displayEnable_internal : std_logic := '0';
    signal row : integer range 0 to c_hActiveDisplay := 0;
    signal column : integer range 0 to c_vActiveDisplay := 0;

    type state_type is (Initial, BackPorch, DisplayActive, FrontPorch, SyncPulse);
    signal hState : state_type := Initial;
    signal vState : state_type := Initial;

    signal pixelCount : integer range c_hActiveDisplay downto 0 := 0;
    signal lineCount : integer range c_vActiveDisplay downto 0 := 0;

    signal hDisplayActive : std_logic := '0';
    signal vDisplayActive : std_logic := '0';
begin

DisplayEnable <= displayEnable_internal;
HSync <= hsync_internal;
VSync <= vsync_internal;
X <= row;
Y <= column;

----
-- Horizontal pixel counter
----
horizontal : process (Clk, Reset) is
begin
    if Reset = '1' then
        pixelCount <= 0;
        hState <= Initial;
    elsif (rising_edge(Clk)) then
        if (pixelCount = 0) then
            case hState is
                ----
                -- Initial State, we only enter this after a reset or system startup.
                ----
                when Initial =>
                    pixelCount <= c_hBackPorch;
                    hState <= BackPorch;
                    hDisplayActive <= '0';
                    hsync_internal <= not c_hPolarity;
                    
                ----
                -- In progress states
                ----
                when BackPorch =>
                    pixelCount <= c_hActiveDisplay;
                    hState <= DisplayActive;
                    hDisplayActive <= '1';
                    
                when DisplayActive =>
                    pixelCount <= c_hFrontPorch;
                    hState <= FrontPorch;
                    hDisplayActive <= '0';
                    
                when FrontPorch =>
                    pixelCount <= c_hSyncPulse;
                    hState <= SyncPulse;
                    hsync_internal <= c_hPolarity;
                    
                when SyncPulse =>
                    pixelCount <= c_hBackPorch;
                    hState <= BackPorch;
                    hsync_internal <= not c_hPolarity;
            end case;
        else
            pixelCount <= pixelCount - 1;
        end if;
    end if;
end process horizontal;

----
-- RGB Signal enable / address location
----
rgb_trigger  : process (Reset, hDisplayActive, vDisplayActive, pixelCount, lineCount) is
begin
    if (Reset = '1') then
        row <= 0;
        column <= 0;
        displayEnable_internal <= '0';
    else
        if (hDisplayActive = '1' and vDisplayActive = '1') then
            row <= c_hActiveDisplay - pixelCount;
            column <= c_vActiveDisplay - lineCount;
            displayEnable_internal <= '1';
        else
            row <= 0;
            column <= 0;
            displayEnable_internal <= '0';
        end if;
    end if;
end process rgb_trigger;

----
-- Vertical line counter
----
vertical : process (Clk, Reset) is
begin
    if (Reset = '1') then
        vState <= Initial;
        lineCount <= 0;
    elsif (rising_edge(Clk)) then
        if (pixelCount = 0 and hState = SyncPulse) then
            if (lineCount = 0) then
                case vState is
                    ----
                    -- Initial State, we only enter this after a reset or system startup.
                    ----
                    when Initial =>
                        lineCount <= c_vBackPorch;
                        vState <= BackPorch;
                        vDisplayActive <= '0';
                        vsync_internal <= not c_vPolarity;
                        
                    ----
                    -- In progress states
                    ----
                    when BackPorch =>
                        lineCount <= c_vActiveDisplay;
                        vState <= DisplayActive;
                        vDisplayActive <= '1';
                        
                    when DisplayActive =>
                        lineCount <= c_vFrontPorch;
                        vState <= FrontPorch;
                        vDisplayActive <= '0';
                        
                    when FrontPorch =>
                        lineCount <= c_vSyncPulse;
                        vState <= SyncPulse;
                        vsync_internal <= c_vPolarity;
                        
                    when SyncPulse =>
                        lineCount <= c_vBackPorch;
                        vState <= BackPorch;
                        vsync_internal <= not c_vPolarity;
                        
                end case;
            else
                lineCount <= lineCount - 1;
            end if; -- lineCount = 0
        end if; -- pixelCount = 0
    end if; -- rising_edge
end process vertical;

end synth;