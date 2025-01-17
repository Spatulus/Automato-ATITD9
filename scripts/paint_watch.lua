--
-- 
--

--Cabbage        | 128, 64, 144   | 8      | Y | bulk    | 10
--Carrot         | 224, 112, 32   | 10     | Y | bulk    | 10
--Clay           | 128, 96, 32    | 4      | Y | bulk    | 20
--DeadTongue     | 112, 64, 64    | 500    | N | normal  | 4
--ToadSkin       | 48, 96, 48     | 500    | N | normal  | 4
--FalconBait     | 128, 240, 224  | 10000  | N | normal  | 4
--RedSand        | 144, 16, 24    | 10     | Y | bulk    | 20
--Lead           | 80, 80, 96     | 50     | Y | normal  | 6
--Silver         | 16, 16, 32     | 50     | N | normal  | 6
--Iron           | 96, 48, 32     | 30     | Y | normal  | 8
--Copper         | 64, 192, 192   | 30     | Y | normal  | 8

--Sulfur         | catalyst       | 10     | Y | normal  | 1
--Potash         | catalyst       | 50     | Y | normal  | 1
--Lime           | catalyst       | 20     | Y | normal  | 1
--Saltpeter      | catalyst       | 10     | Y | normal  | 1

-- 317, 55, 71
--                 cj   ca  cl   dt   ts   el   rs   le   si   ir   co   su  po li sp
paint_colourR = { 128, 224, 128, 112, 48,  128, 144, 80,  16,  96,  64  };
paint_colourG = { 64,  112, 96,  64,  96,  240, 16,  80,  16,  48, 192  };
paint_colourB = { 144, 32,  32,  64,  48,  224, 24,  96,  32,  32, 192  };
catalyst1 = 12;

anchor = nil;

dofile("screen_reader_common.inc");
dofile("ui_utils.inc");
dofile("common.inc");

button_names = {
"CabbageJ","Carrot","Clay","DeadTongue","ToadSkin","FalconBait","RedSand",
"Lead","SilverP","Iron","Copper","C:Sulfur","C:Potash","C:Lime","C:Saltpeter"}; 

per_paint_delay_time = 1000;
per_read_delay_time = 600;
per_click_delay = 10;

-- bar_width: This is how many pixels wide the Red, Green, Blue bars are in Pigment lab.
-- This used to be 307 until around Dec 2018.
-- We think the addition of Red/Green cloth to menus or Falcon Bait caused the window to be wider and causing the pixels to stretch

bar_width = 305; 

function doit()

    local paint_sum = {0,0,0};
    local paint_count = 0;
    local bar_colour = {0,0,0};
    local expected_colour = {0,0,0};
    local diff_colour = {0,0,0};
    local new_px = 0xffffffFF;
    local px_R = nil;
    local px_G = nil;
    local px_B = nil;
    local px_A = nil;
    local m_x = 0;
    local m_y = 0;
    local update_now = 1;
    local y=0;
    local button_push = 0;

    lsSetCaptureWindow();

    askForWindow("Open the paint window. Take any paint away so to start with 'Black'.\n\nNote you want to keep a supply of Red Sand (if you\'re testing reactions).\n\nClicking the 'Reset' button will convert your Pigment Lab 'back to Black' color, again, but it requires Red Sand to do so. It\'s Magic!");


    srReadScreen();
    xyWindowSize = srGetWindowSize();
		anchor = findImage("thisis.png");

    local colour_panel = findAllImages("paint_watch/paint-black.png");
    if (#colour_panel == 0) then
        m_x, m_y = srMousePos();
    else
        m_x = colour_panel[1][0];
        m_y = colour_panel[1][1]+5;    
    end

    local paint_buttons = findAllImages("plus.png");
    if (#paint_buttons == 0) then
        error "No buttons found";
    end


    while 1 do
        lsSetCamera(0,0,lsScreenX*1.5,lsScreenY*1.5);
        -- Where to start putting buttons/text on the screen.
        y=0;
        
        if lsButtonText(lsScreenX - 30, lsScreenY - 80, 0, 100, 0xFFFFFFff, "Reset") then
counter = 0
            for i= 1, 10 do
counter = counter + 1
                srClickMouseNoMove(paint_buttons[7][0]+2,paint_buttons[7][1]+2, right_click);
                lsSleep(per_click_delay);
            end

--sleepWithStatus(2000, counter);
            srReadScreen();
            lsSleep(100);
            clickAllText("Take the Paint");
            lsSleep(100);
            paint_sum = {0,0,0};
            paint_count = 0;
            bar_colour = {0,0,0};
            expected_colour = {0,0,0};
            diff_colour = {0,0,0};
            new_px = 0xffffffFF;
            px_R = nil;
            px_G = nil;
            px_B = nil;
            px_A = nil;
            m_x = 0;
            m_y = 0;
            update_now = 1;
        end

        -- Create each button and set the button push.
        for i=1, #button_names do
            if lsButtonText(10, y, 0, 250, 0xFFFFFFff, button_names[i]) then
                image_name = button_names[i];
                update_now = 1;
                button_push = i;
            end
            y = y + 26;
        end
        srReadScreen();


        -- read the bar pixels
        new_px = srReadPixel(m_x, m_y+5);
        px_R = (math.floor(new_px/256/256/256) % 256);
        px_G = (math.floor(new_px/256/256) % 256);
        px_B = (math.floor(new_px/256) % 256);
        px_A = (new_px % 256);

        if not(update_now==0) then
        --{
            if not (button_push==0) then
            --{
                -- click the appropriate button to add paint.
                srClickMouseNoMove(paint_buttons[button_push][0]+2,paint_buttons[button_push][1]+2, right_click);
                lsSleep(per_click_delay);
            
                if(button_push < catalyst1) then
                    -- add the paint estimate 
                    paint_sum[1] =     paint_sum[1] + paint_colourR[button_push];
                    paint_sum[2] =     paint_sum[2] + paint_colourG[button_push];
                    paint_sum[3] =     paint_sum[3] + paint_colourB[button_push];
                    paint_count = paint_count + 1.0;
                end
            --}
            end

            -- count up all the pixels.
            lsSleep(per_paint_delay_time);
            srReadScreen();

            bar_colour[1] = getBarSize(1); --#findAllImages("paint_watch/paint-redbarC.png");
            lsPrintln("Red: " .. bar_colour[1]);
            lsSleep(per_read_delay_time/3);
            bar_colour[2] = getBarSize(2); --#findAllImages("paint_watch/paint-greenbarC.png");
            lsPrintln("Green: " .. bar_colour[2]);
            lsSleep(per_read_delay_time/3);
            bar_colour[3] = getBarSize(3); --#findAllImages("paint_watch/paint-bluebarC.png");
            lsPrintln("Blue: " .. bar_colour[3]);
            lsSleep(per_read_delay_time/3);
            update_now = 0;

            -- tweak/hack because we miss the first pixel
            for i=1, 3 do
                if(bar_colour[i]>0)then                
                    --bar_colour[i]=bar_colour[i];
                    bar_colour[i]=((bar_colour[i]/bar_width)*256.0);
                end
            end


            
            -- New colour has been added, mix in the pot, and see if there's a difference from the expected value.
            if not (button_push==0) then
            --{                
                for i=1, 3 do
                    expected_colour[i] = paint_sum[i] / paint_count;
                    diff_colour[i] = math.floor(0.5+bar_colour[i]) - math.floor(0.5+expected_colour[i]);
                end

                button_push = 0;
            --}
            end
        --}
        end

        -- Display all the goodies
        lsPrintWrapped(0, y, 1, lsScreenX, 1, 1, 0xFFFFFFff,
            " Pixel   RGBA: " .. px_R .. "," .. px_G .. "," .. px_B .. "," .. px_A);
        y = y + 26;
        lsPrintWrapped(0, y, 1, lsScreenX, 1, 1, 0xFFFFFFff,
            " Bar read RGB: " .. math.floor(bar_colour[1]+0.5) .. "," .. math.floor(bar_colour[2]+0.5) .. "," .. math.floor(bar_colour[3]+0.5));
        y = y + 26;
        lsPrintWrapped(0, y, 1, lsScreenX, 1, 1, 0xFFFFFFff,
            " Expected RGB: " .. math.floor(expected_colour[1]+0.5) .. "," .. math.floor(expected_colour[2]+0.5) .. "," .. math.floor(expected_colour[3]+0.5) );
        y = y + 26;
        lsPrintWrapped(0, y, 1, lsScreenX, 1, 1, 0xFFFFFFff,
            " Reactions RGB: " .. math.floor(diff_colour[1]+0.5) .. "," .. math.floor(diff_colour[2]+0.5) .. "," .. math.floor(diff_colour[3]+0.5) );


        if lsButtonText(lsScreenX - 30, lsScreenY - 30, 0, 100, 0xFFFFFFff, "Exit") then
            error "Canceled";
        end

        lsDoFrame();
        lsSleep(10);
    end
end

function getBarSize(cIndex)
	local xLoc = anchor[0]-4;
	local yLoc = anchor[1] + 151 + ((cIndex-1)*10)
	local c = 0;
	
	for x=xLoc,xLoc+305 do
		local p = srReadPixelFromBuffer(x,yLoc);
  	local p_R = (math.floor(p/256/256/256) % 256);
  	local p_G = (math.floor(p/256/256) % 256);
  	local p_B = (math.floor(p/256) % 256);
  	local p_A = (p % 256);
		
		if cIndex == 1 then
			if p_R > 128 and p_G < 128 and p_B < 128 then
				c = c + 1;
			else
				break;
			end
		elseif cIndex == 2 then
			if p_G > 128 and  p_R < 128 and p_B < 128 then
			  c = c + 1;
			else
				break;
			end
		else
			if p_B > 128 and p_R < 128 and p_G < 128 then
				c = c + 1;
			else
				break;
			end
		end
	end
	
	lsPrintln("x:" .. xLoc .. ",y:" .. yLoc);
	lsPrintln("C:" .. c);
	
	return c;
end
