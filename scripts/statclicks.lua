-- statclicks v1.0 by Skyfeather
--
-- Repeatedly performs tasks based on required stat attributes. Can perform several tasks
-- at once as long as they use different attributes.
--
dofile("common.inc");

stirMaster = false; -- TODO: Make this an optional selection when choosing the Stir Cement option

items = {
        --strength
        {"",
            "Coconuts",
        },
        --end
        {"",
            "Churn Butter",
            "Flax Comb",
            "Dig Hole",
            "Excavate Blocks",
            "Hackling Rake",
            "Pump Aqueduct",
            "Stir Cement",
            "Weave Canvas",
            "Weave Linen",
            "Weave Silk",
            "Weave Wool Cloth",
            "Water Insects",
        },
        --con
        {"",
            "Gun Powder",
        },
        --foc
        {"",
            "Rawhide Strips",
            "Barrel Tap",
            "Bottle Stopper",
            "Crudely Carved Handle",
            "Large Crude Handle",
            "Personal Chit",
            "Sharpened Stick",
            "Tap Rods",
            "Tinder",
            "Wooden Peg",
            "Wooden Pestle"
        },
};

local lagBound = {};
lagBound["Dig Hole"] = true;
lagBound["Survey (Uncover)"] = true;

--Set this to True if you want to take everything from flax comb/hackling rake
-- otherwise false.   Usually only true when using flax comb.
takeAllWhenCombingFlax = false;

local textLookup = {};
textLookup["Coconuts"] = "Separate Coconut Meat";
textLookup["Gun Powder"] = "Gunpowder";
textLookup["Pump Aqueduct"] = "Pump the Aqueduct";

statNames = {"strength", "endurance", "constitution", "focus"};
statTimer = {};
askText = singleLine([[
   Statclicks v 1.0 by Skyfeather.
   Repeatedly performs stat-dependent tasks. Can perform several tasks at once as long as they use different attributes.
   Will also eat food from a kitchen grilled veggies once food is up if a kitchen is pinned.
   Ensure that windows of tasks you are performing are pinned and press shift.
]]

);
function getClickActions()
    local scale = 1.4;
    local z = 0;
    local done = false;
    -- initializeTaskList
    tasks = {};
    for i = 1, 4 do
        tasks[i] = 1;
    end

    while not done do
        checkBreak();
        y = 10;
        lsSetCamera(0, 0, lsScreenX * 1.7, lsScreenY * 1.7);
        lsPrint(5, y, z, 1.2, 1.2, 0xFFFFFFff, "Ensure that all menus are pinned!");
        y = y + 50;
        for i = 1, #statNames do
            lsPrint(5, y, z, 1, 1, 0xFFFFFFff, statNames[i]:gsub("^%l", string.upper) .. ":");
            y = y + 24;
            tasks[i] = lsDropdown(statNames[i], 5, y, 0, 200, tasks[i], items[i]);
            y = y + 32;
        end
        lsDoFrame();
        lsSleep(tick_delay);
        if lsButtonText(150, 58, z, 100, 0xFFFFFFff, "OK") then
            done = true;
        end
    end
end

function weave(clothType)
    if clothType == "Canvas" then
        srcType = "Twine";
        srcQty = "60";
    elseif clothType == "Linen" then
        srcType = "Thread";
        srcQty = "400";
    elseif clothType == "Wool" then
        srcType = "Yarn";
        srcQty = "60";
    elseif clothType == "Silk" then
        srcType = "Raw Silk";
        srcQty = "50";
    end

    --   lsPrintln("Weaving " .. srcType);
    -- find our loom type
    loomReg = findText(" Loom", nil, REGION);
    if loomReg == nil then
        --    lsPrintln("Couldn't find loom");
        return;
    end
    studReg = findText("This is [a-z]+ Student's Loom", nil, REGION + REGEX);

    if clothType == "Linen" then
        weaveText = findText("Weave Thread into Linen Cloth", loomReg);
    else
        weaveText = findText("Weave " .. srcType, loomReg);
    end
    if weaveText ~= nil then
        clickText(weaveText);
        lsSleep(per_tick);
        --Close the error window if a student's loom
        if studReg then
            lsSleep(500);
            srReadScreen();
            --closeEmptyAndErrorWindows();
            closePopUp();
        end
        -- reload the loom
        loadText = findText("Load the Loom with " .. srcType, loomReg);
        if loadText ~= nil then
            clickText(loadText);
            local t = waitForText("Load how much", 2000);
            if t ~= nil then
                srCharEvent(srcQty .. "\n");
            end
            --closeEmptyAndErrorWindows(); --This should just be a func to close the error region, but lazy.
            closePopUp();
        end
    end

    -- Restring student looms
    srReadScreen();
    if studReg then
        --      lsPrintln("Restringing");
        srReadScreen();
        t = findText("Re-String", studReg);
        if t ~= nil then
            clickText(t);
            lsSleep(per_tick);
            srReadScreen();
            --closeEmptyAndErrorWindows(); --This should just be a func to close the error region, but lazy.
            closePopUp();
            lsSleep(per_tick);
        end
    end
end

function carve(item)
    if item == "Tinder" then
         carveText = findText("Carve Wood into " .. item);
      elseif item == "Wooden Peg" then
         carveText = findText("Carve a small " .. item);
      elseif item == "Rawhide Strips" then
         carveText = findText("Carve Leather into " .. item);
      else
         carveText = findText("Carve a " .. item);
   end

    if carveText ~= nil then
        clickText(carveText);
        lsSleep(per_tick);
        srReadScreen();
        closePopUp();
        lsSleep(per_tick);
    end
end

function digHole()
    digText = findText("Dig Deeper");
    grilledOnion = findText("Grilled Onions");
    if digText ~= nil then
        if grilledOnion then
            eatOnion();
        end
        clickText(digText);
        lsSleep(per_tick);
        srReadScreen();
        closePopUp();
        lsSleep(per_tick);
    end
end

function waterInsects()
  centerMouse()
  drawWater()
  local escape = "\27"
  local pos = nil
    while (not pos) do
      lsSleep(100)
      srKeyEvent(escape)
      lsSleep(100)
      srReadScreen()
      pos = findText("Skills...")
    end
    clickText(pos)
    lsSleep(100)
    srReadScreen()
    pos = findText("Empty Containers")
      if pos then
        clickText(pos)
        lsSleep(100)
        srReadScreen()
        pos = findText("Jugs of Water")
          if pos then
            clickText(pos)
            lsSleep(100)
            srReadScreen()
            if not clickMax() then
              fatalError("Unable to find the Max button.")
            end
          end
      end
end

function combFlax()
    flaxReg = findText("This is [a-z]+ Flax Comb", nil, REGION + REGEX);
    if flaxReg == nil then
        return;
    end
    flaxText = findText("This is [a-z]+ Flax Comb", flaxReg, REGEX);
    clickText(flaxText);
    lsSleep(per_tick);
    srReadScreen();
    local fix = findText("Repair", flaxReg);
    if (fix) then
        repairRake();
    end
    grilledOnion = findText("Grilled Onions");
    if grilledOnion then
        eatOnion();
    end
    s1 = findText("Separate Rotten", flaxReg);
    s23 = findText("Continue processing", flaxReg);
    clean = findText("Clean the");
    if s1 then
        clickText(s1);
    elseif s23 then
        clickText(s23);
    elseif clean then
        if takeAllWhenCombingFlax == true then
            clickText(findText("Take...", flaxReg));
            everythingObj = waitForText("Everything", 1000);
            if everythingObj == nil then
                return;
            end
            clickText(everythingObj);
            lsSleep(150);
        end
        clickText(clean);
    else
        lsPrint(5, 0, 10, 1, 1, "Found Stats");
        lsDoFrame();
        lsSleep(2000);
    end
end


function hacklingRake()
    expressionToFind = "This is [a-z]+[ Improved]* Hackling Rake";
    flaxReg = findText(expressionToFind, nil, REGION + REGEX);
    if flaxReg == nil then
        return;
    end
    flaxText = findText(expressionToFind, flaxReg, REGEX);
    clickText(flaxText);
    lsSleep(per_tick);
    srReadScreen();
    local fix = findText("Repair", flaxReg);
    if (fix) then
        repairRake();
    end
    grilledOnion = findText("Grilled Onions");
    if grilledOnion then
        eatOnion();
    end
    s1 = findText("Separate Rotten", flaxReg);
    s23 = findText("Continue processing", flaxReg);
    clean = findText("Clean the");
    if s1 then
        clickText(s1);
    elseif s23 then
        clickText(s23);
    elseif clean then
        if takeAllWhenCombingFlax == true then
            clickText(findText("Take...", flaxReg));
            everythingObj = waitForText("Everything", 1000);
            if everythingObj == nil then
                return;
            end
            clickText(everythingObj);
            lsSleep(150);
        end
        clickText(clean);
    else
        lsPrint(5, 0, 10, 1, 1, "Found Stats");
        lsDoFrame();
        lsSleep(2000);
    end
end

function repairRake()
    step = 1;
    lsPlaySound("fail.wav");
    sleepWithStatus(1000, "Attempting to Repair Rake !")
    local repair = findText("Repair")
    local material;
    local plusButtons;
    local maxButton;

    if repair then
        clickText(waitForText("Repair", 1000));
        clickText(waitForText("Load Materials", 1000));
        lsSleep(500);
        srReadScreen();
        plusButtons = findAllImages("plus.png");

        for i = 1, #plusButtons do
            local x = plusButtons[i][0];
            local y = plusButtons[i][1];
            srClickMouseNoMove(x, y);
            lsSleep(100);

            if i == 1 then
                material = "Boards";
            elseif i == 2 then
                material = "Bricks";
            elseif i == 3 then
                material = "Thorns";
            else
                material = "What the heck?";
            end

            srReadScreen();
            OK = srFindImage("ok.png")
            if OK then

                sleepWithStatus(5000, "You don\'t have any \'" .. material .. "\', Aborting !\n\nClosing Build Menu and Popups ...", nil, 0.7)
                srClickMouseNoMove(OK[0], OK[1]);
                srReadScreen();
                blackX = srFindImage("blackX.png");
                srClickMouseNoMove(blackX[0], blackX[1]);
                num_loops = nil;
                break;

            else -- No OK button, Load Material

                srReadScreen();
                maxButton = srFindImage("max.png");
                if maxButton then
                    srClickMouseNoMove(maxButton[0], maxButton[1]);
                end
                sleepWithStatus(1000, "Loaded " .. material, nil, 0.7);
                lsSleep(100);
            end -- if OK
        end -- for loop
    end -- if repair
end


function eatOnion()
    srReadScreen();
    local buffed = srFindImage("foodBuff.png");
        if not buffed then
            clickAllText("Grilled Onions");
        end
end

function stirCement()
    t = waitForText("Stir the cement", 1000);
    if t then
        clickText(t);
    else
        clickText(findText("This is [a-z]+ Clinker Vat", nil, REGEX));
        if stirMaster then
            clickText(waitForText("Take..."));
            clickText(waitForText("Everything"));
            clickText(waitForText("Load the vat with Bauxite"));
            waitForText("how much");
            srCharEvent("10\n");
            waitForNoText("how much");
            clickText(waitForText("Load the vat with Gypsum"));
            waitForText("how much");
            srCharEvent("10\n");
            waitForNoText("how much");
            clickText(waitForText("Load the vat with Clinker"));
            waitForText("how much");
            srCharEvent("800\n");
            waitForNoText("how much");
            clickText(waitForText("Load the vat with Petroleum"));
            waitForText("much fuel");
            srCharEvent("40\n");
            waitForNoText("how much");
            clickText(waitForText("Make a batch of Cement"));
        end
    end
end

local function tapRods()
    local window = findText("This is [a-z]+ Bore Hole", nil, REGION + REGEX);
    if window == nil then
        return;
    end
    local t = findText("Tap the Bore Rod", window);
    local foundOne = false;
    if t then
        clickText(t);
        foundOne = true;
    end
    t = waitForText("Crack an outline", 300);
    if t then
        clickText(t);
        foundOne = true;
    end
    if foundOne == false then
        t = findText("Retrieve the bore", window);
        if t then
            clickText(t);
        end
    end
end

local function excavateBlocks()
    local window = findAllText("This is [a-z]+ Pyramid Block(Roll", nil, REGION + REGEX);
    if window then
        for i = 1, #window do
            unpinWindow(window[i]);
        end
        lsSleep(50);
        srReadScreen();
    end
    window = findText("This is [a-z]+ Tooth Limestone Bl", nil, REGION + REGEX);
    if window == nil then
        return;
    end
    local t = findText("Dig around", window);
    if t then
        clickText(t);
    end
    t = waitForText("Slide a rolling rack", 300);
    if t then
        clickText(t);
        t = waitForText("This is [a-z]+ Pyramid Block(Roll", 300, nil, nil, REGION + REGEX);
        if t then
            unpinWindow(t);
        end
    end
    return;
end

function churnButter()
    local t = srFindImage("statclicks/churn.png");
    if t then
        srClickMouseNoMove(t[0]+5, t[1]);
    end
end

function doTasks()
    didTask = false;
    for i = 1, 4 do
        curTask = items[i][tasks[i]];
        if curTask ~= "" then
            srReadScreen();
            statImg = srFindImage("statclicks/" .. statNames[i] .. "_black_small.png");
            if statTimer[i] ~= nil then
                timeDiff = lsGetTimer() - statTimer[i];
            else
                timeDiff = 999999999;
            end
            local delay = 1400;
            if lagBound[curTask] then
                delay = 3000;
            end
            if statImg and timeDiff > delay then
                --check for special cases, like flax.
                lsPrint(10, 10, 0, 0.7, 0.7, 0xB0B0B0ff, "Working on " .. curTask);
                lsDoFrame();
                if curTask == "Flax Comb" then
                    combFlax();
                elseif curTask == "Hackling Rake" then
                    hacklingRake();
                elseif curTask == "Weave Canvas" then
                    weave("Canvas");
                elseif curTask == "Weave Linen" then
                    weave("Linen");
                elseif curTask == "Weave Wool Cloth" then
                    weave("Wool");
                elseif curTask == "Weave Silk" then
                    weave("Silk");
                elseif curTask == "Push Pyramid" then
                    pyramidPush();
                elseif curTask == "Excavate Blocks" then
                    excavateBlocks();
                elseif curTask == "Tap Rods" then
                    tapRods();
                elseif curTask == "Stir Cement" then
                    stirCement();
                elseif curTask == "Churn Butter" then
                    churnButter();
                elseif curTask == "Barrel Tap" then
                    carve(curTask);
                 elseif curTask == "Rawhide Strips" then
                     carve(curTask);
                elseif curTask == "Bottle Stopper" then
                    carve(curTask);
                elseif curTask == "Crudely Carved Handle" then
                    carve(curTask);
                elseif curTask == "Large Crude Handle" then
                    carve(curTask);
                elseif curTask == "Personal Chit" then
                    carve(curTask);
                elseif curTask == "Sharpened Stick" then
                    carve(curTask);
                elseif curTask == "Tinder" then
                    carve(curTask);
                elseif curTask == "Wooden Peg" then
                    carve(curTask);
                elseif curTask == "Wooden Pestle" then
                    carve(curTask);
                elseif curTask == "Dig Hole" then
                    digHole();
                elseif curTask == "Water Insects" then
                    waterInsects();
                end
                statTimer[i] = lsGetTimer();
                didTask = true;
            end
        end
    end
    if didTask == false then
        lsPrint(10, 10, 0, 0.7, 0.7, 0xB0B0B0ff, "Waiting for task to be ready.");

        if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
            "End script") then
            error "Clicked End Script button";
        end

        lsDoFrame();
    else
        srReadScreen();
        --closeEmptyAndErrorWindows();
        closePopUp();
        lsSleep(per_tick);
    end
end

--Returns true if it can find a stat, false if it can't find any.
function checkStatsPane()
    -- try to find at least one of the various stats.
    found = false;
    srReadScreen();
    for i = 1, #statNames do
        if srFindImage("statclicks/" .. statNames[i] .. "_black_small.png") then
            return true;
        end
    end
    return false;
end

function checkAndEat()
    if foodTimer == nil or lsGetTimer() - foodTimer > 3000 then
        srReadScreen();
        invLoc = srFindInvRegion();

        invLoc[0] = invLoc[0] + 1;
        invLoc[2] = invLoc[2] - 2;
        stripRegion(invLoc);
        inv = parseRegion(invLoc);
        if inv == nil then
            return;
        end
        onFood = false;
        allStatsVisible = true;
        for i = 1, #statNames do
            foundStat = false;
            for j = 1, #inv do
                -- Check for a stat with an unparseable number. if so, on food.
                if string.find(inv[j][2], statNames[i]:gsub("^%l", string.upper)) and
                    string.find(inv[j][2], statNames[i]:gsub("^%l", string.upper) .. "%s+%d") == nil then
                    onFood = true;
                end
                if string.find(inv[j][2], statNames[i]:gsub("^%l", string.upper)) then
                    foundStat = true;
                end
            end
            if foundStat == false then
                allStatsVisible = false;
            end
        end

        if onFood == false and allStatsVisible == true then
            lsPrint(10, 10, 0, 0.7, 0.7, 0xB0B0B0ff, "Eating food");
            lsDoFrame();
            parse = findText("Enjoy the food")
            if parse then
                clickText(parse)
            else
                clickText(findText("Eat some Grilled"));
            end
            foodTimer = lsGetTimer();
        end
    end
end

function closePopUp()
    lsSleep(100);
    while 1 do
        checkBreak();
        srReadScreen()
        local ok = srFindImage("OK.png")
        if ok then
            srClickMouseNoMove(ok[0] + 5, ok[1], 1);
            lsSleep(100);
        else
            break;
        end
    end
end

function doit()
    getClickActions();
    if items[3][tasks[3]] == "Push Pyramid" then
        pyramidXCoord = promptNumber("Pyramid x coordinate:");
        pyramidYCoord = promptNumber("Pyramid y coordinate:");
    end
    local mousePos = askForWindow(askText);
    windowSize = srGetWindowSize();
    done = false;
    while done == false do
        checkAndEat();
        doTasks();
        checkBreak();
        lsSleep(80);
    end
end
