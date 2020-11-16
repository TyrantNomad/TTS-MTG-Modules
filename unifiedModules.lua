--Easy Modules Unified
--by @TyrantNomad
--based on Power and Toughness by Tipsy Hobbit (steamid: 13465982)

moduleVersion = "1.5"
pID = "_MTG_Simplified_UNIFIED"

isRegistered = false

function onload(saved_data)
    local dataTable = {recursiveCall=false}
    processSavedData(saved_data)
    initializeDeckTables()
    tryAutoRegister(dataTable)
    createModuleChipButtons()
end

function onSave()
    local data_to_save = {autoActivateModule,autoActivateCounter,autoActivatePowTou,autoActivatePlusOne}
    local saved_data = JSON.encode(data_to_save)
    return saved_data
end

autoActivateModule = true
autoActivateCounter = true
autoActivatePowTou = true
autoActivatePlusOne = true
function processSavedData(saved_data)
    if saved_data ~= nil and saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        autoActivateModule = loaded_data.autoActivateModule ~= nil and loaded_data.autoActivateModule or true
        autoActivateCounter = loaded_data.autoActivateCounter ~= nil and loaded_data.autoActivateCounter or true
        autoActivatePowTou = loaded_data.autoActivatePowTou ~= nil and loaded_data.autoActivatePowTou or true
        autoActivatePlusOne = loaded_data.autoActivatePlusOne ~= nil and loaded_data.autoActivatePlusOne or true
    end
end

function tryAutoRegister(data)
    if data.recursiveCall then
        registerModule()
    else
        local dataTable = {recursiveCall=true}
        Timer.create({
            identifier = "unifiedModuleAutoRegister",
            function_name = "tryAutoRegister",
            function_owner = self,
            parameters = dataTable,
            delay = 5
        })
    end
end

function forceEncoderUpdate(encoderCode)
    local encoderCode = encoderCode.text

    local encoder = Global.getVar('Encoder')
    encoder.script_code = encoderCode
    encoder.reload()
end

function forcePlaceholderEncoder(encoderCode)
    local encoderCode = encoderCode.text
    spawnParams = {
        type = "rpg_TROLL",
        position = {0, 5, 0},
        scale = {0.5, 0.5, 0.5},
        sound = false,
        callback_function = function(obj) attachEncoderToPlaceholder(obj, encoderCode) end
    }

    spawnObject(spawnParams)
end

function attachEncoderToPlaceholder (placeholderObject, encoderCode)
    placeholderObject.script_code = encoderCode
    placeholderObject.reload()
end

function createModuleChipButtons()
    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        isRegistered = enc.call("APIpropertyExists",{propID = pID})
    else
        isRegistered = false
    end

    self.createButton({
        label = "TyrantNomad's",
        click_function=("doNothing"),
        function_owner=self,

        position={0,0.15,-0.4},
        rotation = {0,0,0},

        height=0,
        width=0,

        font_size = 60,
        font_color = {1,156/255,196/255}
    })

    self.createButton({
        click_function="doNothing",
        function_owner=self,
        position={0,0.15,-0.155},
        rotation={180,0,0},

        height= 116,
        width= 800,

        color = {90/255,24/255,51/255}
    })

    self.createButton({
        label= "EASY MODULES",
        click_function="doNothing",
        function_owner=self,
        position={0,0.15,-0.155},

        height= 0,
        width= 0,

        color = {90/255,24/255,51/255},

        font_size = 100,
        font_color = {1,156/255,196/255}
    })

    self.createButton({
        label = "VERSION "..moduleVersion,
        click_function=("doNothing"),
        function_owner=self,

        position={0,0.15,0.075},
        rotation = {0,0,0},

        height=0,
        width=0,

        font_size = 60,
        font_color = {1,156/255,196/255}
    })

    self.createButton({
        label=(isRegistered and "REGISTERED" or "ADD MODULE"),
        click_function="doNothing",
        function_owner=self,

        position={0,0.15,0.33},

        height=0,
        width=0,

        font_size = 60,
        font_color = (isRegistered and {1,156/255,196/255} or {90/255,24/255,51/255})
    })

    self.createButton({
        click_function=(isRegistered and "doNothing" or "registerModule"),
        function_owner=self,

        position={0,0.15,0.33},
        rotation = (isRegistered and {180,0,0} or {0,0,0}),

        color = (isRegistered and {238/255, 25/255, 110/255} or {1,156/255,196/255}),
        hover_color = {90/255,24/255,51/255},

        height=60,
        width=450,
    })

    self.createButton({
        label = "AUTO "..(autoActivateModule and "ON" or "OFF"),
        tooltip = "When ON, automatically activates the module,\nshowing the easy-toggle menu on the left side of cards",

        click_function = "toggleAutoActivate",
        function_owner = self,

        font_color = (autoActivateModule and {1,156/255,196/255} or {90/255,24/255,51/255}),
        color = (autoActivateModule and {238/255, 25/255, 110/255} or {1,156/255,196/255}),
        hover_color = {90/255,24/255,51/255},

        position={0,-0.15,0},
        rotation = {180,180,0},

        width = 600,
        height = 80
    })
end

function clearModuleChipButtons()
    local chipButtons = self.getButtons()
    for index,button in pairs(chipButtons) do
        self.removeButton(index -1)
    end
end

function refreshModuleChipButtons()
    clearModuleChipButtons()
    createModuleChipButtons()
end

function registerModule()
    if isRegistered then return end

    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        if tonumber(enc.getVar("version")) < 3.18 then 
            broadcastToAll("Encoder version too old. To use this module, manually upgrade it to v3.18+ or type 'force encoder update' to attempt a forced update")
            return
        end
    
        local properties = {
            propID = pID,
            name = " Easy Modules Unified",
            dataStruct = {
                hasParsed = false,

                power=0, toughness=0,
                plusOneCounters=0,
                genericCount = 0, hasLoyalty = false, hasOtherCounter = false,

                displayCounters = false,
                displayPowTou = false,
                displayPlusOne = false,
            
                ownerColor = "Grey",
                controllerColor = "Grey"},

            funcOwner = self,
            callOnActivate = false,
            activateFunc =''
        }
        enc.call("APIregisterProperty",properties)

        refreshModuleChipButtons()
    else
        broadcastToAll("No encoder found. You need Encoder v3.18+ by Tipsy Hobbit (steamid: 13465982) to use the module")
        broadcastToAll("Get the Encoder from the Steam Workshop or type 'force encoder temporary' to spawn a placeholder")
    end
end

function onChat(message, player)
    local message = string.lower(message)

    if string.find(message,'force encoder') ~= nil then
        if string.find (message,'encoder update') ~= nil then
            WebRequest.get("https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Encoder%20Core.lua", self, "forceEncoderUpdate")
        elseif string.find (message,'encoder temporary') ~= nil then
            WebRequest.get("https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Encoder%20Core.lua", self, "forcePlaceholderEncoder")
        end
    end
end

function toggleAutoActivate()
    autoActivateModule = not autoActivateModule
    refreshModuleChipButtons()
end


function createButtons(t)
    enc = Global.getVar('Encoder')

    if enc ~= nil then
        parseCardData(t.object)
        
        local data = enc.call("APIgetObjectData",{obj=t.object,propID=pID})
        local flip = enc.call("APIgetFlip",{obj=t.object})
        local scaler = {x=1,y=1,z=1}--t.object.getScale()

        if true then --toggle display buttons collapsible section
            local buttonBackgroundColorOff = {0,0,0,  0.7}
            local buttonBackgroundColorOn = {0,0,0, 0.9}

            local buttonTextColorOff = {0.8,0.8,0.8, 0.8}
            local buttonTextColorOn = {1,0.8,0.4, 0.7}
            local buttonTextSize = 55

            local buttonHoverColor = {0,0,0,1}

            local verticalSpacing = 0.2
            local buttonDimensions = 90

            t.object.createButton({
                click_function = 'ToggleDisplayCounter',
                function_owner = self,

                label = "[1]",
                font_size = buttonTextSize,
                font_color = data.displayCounters and buttonTextColorOn or buttonTextColorOff,
                tooltip = "Click to "..(data.displayCounters and "HIDE" or "SHOW").."\nCounters/Loyalty",

                height = buttonDimensions,
                width = buttonDimensions,

                color = data.displayCounters and buttonBackgroundColorOn or buttonBackgroundColorOff,
                hover_color = buttonHoverColor,

                position=
                {
                    -1.035, 0.35, -0.36 + 2 * verticalSpacing
                }
            })

            t.object.createButton({
                click_function = 'ToggleDisplayPowTou',
                function_owner = self,

                label = "1/",
                font_size = buttonTextSize,
                font_color = data.displayPowTou and buttonTextColorOn or buttonTextColorOff,
                tooltip = "Click to "..(data.displayPowTou and "HIDE" or "SHOW").."\nPow/Tou",

                height = buttonDimensions,
                width = buttonDimensions,

                color = data.displayPowTou and buttonBackgroundColorOn or buttonBackgroundColorOff,
                hover_color = buttonHoverColor,

                position=
                {
                    -1.035, 0.35, -0.36 + 1 * verticalSpacing
                }
            })

            t.object.createButton({
                click_function = 'ToggleDisplayPlusOne',
                function_owner = self,

                label = "+1 ",
                font_size = buttonTextSize,
                font_color = data.displayPlusOne and buttonTextColorOn or buttonTextColorOff,
                tooltip = "Click to "..(data.displayCounters and "HIDE" or "SHOW").."\n+1/+1 Counters",

                height = buttonDimensions,
                width = buttonDimensions,

                color = data.displayPlusOne and buttonBackgroundColorOn or buttonBackgroundColorOff,
                hover_color = buttonHoverColor,

                position=
                {
                    -1.035, 0.35, -0.36 + 0 * verticalSpacing
                }
            })
        end
        
        local loyaltyOffset = (data.displayCounters and data.hasLoyalty) and -0.3 or 0
        local colorLightGrey = {133/255,133/255,133/255}
        local colorDarkGrey = {55/255,55/255,55/255}
        local colorCardBorderBlack = {19/255,16/255,12/255}

        local hexTooltipLowlight = "[BBBBBB]"
        local hexTooltipMidlight = "[DDDDDD]"
        local hexTooltipHighlight = "[FFCC00]"

        --tooltips
        local multiSelectTooltip = hexTooltipMidlight.."\nBUTTONS AFFECT ALL SELECTED CARDS[-]"

        local buttonTooltipOwnershipGem =
            "CONTROLLER: ["..controlColorHex.."]"..cardController.."[-]\n"..
            "OWNER: ["..ownerColorHex.."]"..cardOwner.."[-]\n"..
            hexTooltipLowlight.."L-Click: Become CONTROLLER\n"..
            "R-Click: Become OWNER[-]\n"..
            multiSelectInstruction
        
        local buttonTooltipCounterSingleClick = 
            hexTooltipLowlight.."L-Click: +1      R-Click: -1[-]\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract 10[-]\n"..
            multiSelectInstruction
         
        local buttonTooltipCounterTenClick = 
            hexTooltipLowlight.."L-Click: +10     R-Click: -10[-]\n"..
            multiSelectInstruction

        local buttonTooltipPowerrSingleClick = 
            hexTooltipLowlight.."L-Click: +1     R-Click: -1[-]\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract BOTH[-]\n"..
            multiSelectInstruction

        local buttonTooltipToughnessSingleClick = 
            hexTooltipLowlight.."L-Click: +1     R-Click: -1[-]\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract BOTH[-]\n"..
            multiSelectInstruction

        local buttonTooltipPowTouSingleClick = 
            hexTooltipLowlight.."L-Click: +1/+1     R-Click: -1/-1[-]\n"..
            multiSelectInstruction

        local buttonTooltipPlusOneSingleClick = 
            hexTooltipLowlight.."L-Click: +1/+1      R-Click: -1/-1[-]\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract 10[-]\n"..
            multiSelectInstruction
         
        local buttonTooltipCounterTenClick = 
            hexTooltipLowlight.."L-Click: +10/+10     R-Click: -10/-10[-]\n"..
            multiSelectInstruction

        local buttonTooltipToggleDisplayCounters =
            hexTooltipHighlight..(data.displayCounters == true and "HIDE" or "SHOW").."[-]"..hexTooltipLowlight.." LOYALTY/NUMBER COUNTER\n"..
            hexTooltipLowlight.."Toggles a simple numeric counter on the card\n"
            multiSelectInstruction

        local buttonTooltipToggleDisplayPlusOne =

        local buttonTooltipToggleDisplayPowTou =

        --simplecounter buttons
        if data.displayCounters then
            local verticalSize = 130
            local horizontalSize = 145
            local rimSize = 30


            local horizontalOffset = -0.81
            local flipHorizontal = data.hasLoyalty and -1 or 1
            local verticalOffset = 1.275
            --tile size is about 500 for 1 unit

            --bg
            t.object.createButton({
                click_function = 'doNothing',
                function_owner = self,

                height = verticalSize + rimSize,
                width = horizontalSize + rimSize,

                color = colorLightGrey,

                position=
                {
                    flipHorizontal * ((horizontalOffset)*flip*scaler.x),
                    0.28*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                rotation={0,0,-90-90*flip}
            })

            --counter button
            t.object.createButton({
                label=" "..data.genericCount.." ",
                tooltip = "Right-Click to Subtract",

                click_function='receiveCounterClick',
                function_owner=self,

                position=
                {
                    flipHorizontal * ((horizontalOffset)*flip*scaler.x),
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                height= verticalSize,
                width= horizontalSize,
                color = colorDarkGrey,

                font_size=fSize,
                font_color = {1,1,1},

                rotation={0,0,90-90*flip}
            })

            --delta 10 button
            t.object.createButton({
                tooltip = "Increase by 10\nRight-Click to Subtract",
                click_function='receiveTenCounterClick',
                function_owner=self,

                position=
                {
                    flipHorizontal * (horizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    0.20 + (verticalOffset)*scaler.y
                },

                height= 80,
                width= horizontalSize,
                color = {0.3,0.3,0.3, 0.3},

                scale = {1,1,0.5},

                rotation={0,0,90-90*flip}
            })
        end

        --powtou buttons
        if data.displayPowTou then
            local widthPerDigit = 25
            local baseWidth = 250
            --size for double digit 320
            --size for single digit 270?

            local verticalSize = 130
            --local horizontalSize = baseWidth + (string.len(data.power..data.toughness) * widthPerDigit)
            horizontalSize = 320
            
            local rimSize = 30

            local horizontalOffset = 0.69
            local verticalOffset = 1.275  + loyaltyOffset
            --tile size is about 500 for 1 unit

            --powtou increase both button
            t.object.createButton({
                tooltip = "Change Both\nRight-Click to Subtract",
                click_function='receivePowTouClick',
                function_owner=self,

                position=
                {
                    (horizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    0.20 + (verticalOffset)*scaler.y
                },

                height= 60,
                width= horizontalSize-40,
                color = {0.3,0.3,0.3, 0.3},

                scale = {1,1,0.5},

                rotation={0,0,90-90*flip}
            })

            --powtou slash
            t.object.createButton({
                label = "/",
                font_color = {1,1,1},
                font_size= 80,

                click_function = 'doNothing',
                function_owner = self,

                height = 0,
                width = 0,

                color = {133/255,133/255,133/255},
                hover_color = {133/255,133/255,133/255},

                position=
                {
                    (horizontalOffset)*flip*scaler.x,
                    0.28*flip*scaler.z,
                    (verticalOffset)*scaler.y
                }
            })

            --powtou BG right
            t.object.createButton({
                click_function='doNothing',
                function_owner=self,

                position=
                {
                    (horizontalOffset + 20/500 - (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                height= verticalSize + 26,
                width= horizontalSize/2.1 + 26,
                color = colorLightGrey,

                rotation={0,0,-90-90*flip}
            })

            --powtou BG left
            t.object.createButton({
                click_function='doNothing',
                function_owner=self,

                position=
                {
                    (horizontalOffset - 20/500 + (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                height= verticalSize + 26,
                width= horizontalSize/2.1 + 26,
                color = colorLightGrey,

                rotation={0,0,-90-90*flip}
            })

            --powtou pow
            t.object.createButton({
                label=data.power.." ",

                click_function='receivePowerClick',
                tooltip = "Right-Click to Subtract",
                function_owner=self,

                position=
                {
                    (horizontalOffset + 20/500 - (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                height= verticalSize,
                width= horizontalSize/2.1,
                color = colorDarkGrey,

                font_size= 80,
                font_color = {1,1,1},

                rotation={0,0,90-90*flip}
            })

            --powtou tou
            t.object.createButton({
                label=" "..data.toughness,

                click_function='receiveToughnessClick',
                tooltip = "Right-Click to Subtract",
                function_owner=self,

                position=
                {
                    (horizontalOffset - 20/500 + (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                height= verticalSize,
                width= horizontalSize/2.1,
                color = colorDarkGrey,

                font_size= 80,
                font_color = {1,1,1},

                rotation={0,0,90-90*flip}
            })
        end

        --plusone buttons
        if data.displayPlusOne then
            local widthPerDigit = 25
            local baseWidth = 250
            --size for double digit 320
            --size for single digit 270?

            local verticalSize = 130
            local horizontalSize = baseWidth + (string.len(math.abs(data.plusOneCounters)..math.abs(data.plusOneCounters)) * widthPerDigit)

            local rimSize = 30

            local horizontalOffset = 0.69
            local verticalOffset = 0.99 + loyaltyOffset
            --tile size is about 500 for 1 unit

            plusOneLabelString = ""..((data.plusOneCounters >= 0) and "+" or "")..data.plusOneCounters..'/'..((data.plusOneCounters >= 0) and "+" or "")..data.plusOneCounters.." "

            -- delta 10 button
            t.object.createButton({
                tooltip = "Add +10/+10\nRight-Click to Subtract",
                click_function='receiveTenPlusOneClick',
                function_owner=self,

                position=
                {
                    (horizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    -0.2 + (verticalOffset)*scaler.y
                },

                height= 60,
                width= horizontalSize-40,
                color = {0.3,0.3,0.3, 0.4},
                hover_color = {1,1,1, 0.66},

                scale = {1,1,0.5},

                rotation={0,0,90-90*flip}
            })

            --bg button
            t.object.createButton({
                click_function = 'doNothing',
                function_owner = self,

                height = verticalSize + rimSize + 16,
                width = horizontalSize + rimSize,

                color = colorLightGrey,

                position=
                {
                    (horizontalOffset)*flip*scaler.x,
                    0.28*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                rotation={0,0,-90-90*flip}
            })

            --plus one button
            t.object.createButton({
                label=plusOneLabelString,
                tooltip = "Right-Click to Subtract",

                click_function='receivePlusOneClick',
                function_owner=self,

                position=
                {
                    (horizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                height= verticalSize,
                width= horizontalSize,
                color = colorDarkGrey,

                font_size= 80,
                font_color = {1,1,1},

                rotation={0,0,90-90*flip}
            })
        end

        if true then --toggle ownership buttons collapsible section
            local verticalOffset = 1.345
            local verticalSize = 280
            local horizontalSize = 500
            local buttonScale = {0.375,0.375,0.375} -- used to fix weird scaling issues on small size values
            
            local cardOwner = data.ownerColor == nil and "Grey" or data.ownerColor
            local ownershipColor = Color.fromString(cardOwner)
            local ownerColorHex = ownershipColor:toHex(false)
            
            local cardController = data.controllerColor == nil and "Grey" or data.controllerColor
            local controlColor = Color.fromString(cardController)
            local controlColorHex = controlColor:toHex(false)

            

            --bg with ownership function
            t.object.createButton({
                tooltip =   buttonTooltipOwnershipGem,
                click_function= "ReceiveGemClick",
                function_owner=self,

                position=
                {
                    0,
                    0.35*flip*scaler.z,
                    verticalOffset
                },

                height= verticalSize,
                width= horizontalSize,
                color = colorCardBorderBlack,

                rotation={0,0,90-90*flip},
                scale = buttonScale
            })

            --ownership gem
            t.object.createButton({
                click_function='doNothing',
                function_owner=self,

                position=
                {
                    0,
                    0.4*flip*scaler.z,
                    verticalOffset
                },

                height= verticalSize * 0.7,
                width= horizontalSize * 0.85,
                color = Color.Black:lerp(ownershipColor, 0.33),

                rotation={180,0,90-90*flip},
                scale = buttonScale
            })

            --control gem
            t.object.createButton({
                click_function= "doNothing",
                function_owner=self,

                position=
                {
                    0,
                    0.45*flip*scaler.z,
                    verticalOffset
                },

                height= verticalSize * 0.4,
                width= horizontalSize * 0.66,
                color = Color.White:lerp(controlColor, 0.66),

                rotation={180,0,90-90*flip},
                scale = buttonScale
            })
        end
    end
end

--Propagatable Value Change Functions
function PropagateValueChange (dataTable)
    --dataTable needs target, player, varName & varDelta
    -- so for bools we want to set and for floats we want to add
    local enc = Global.getVar('Encoder')

    if type(dataTable.player) == "string" then
        local selection = Player[dataTable.player].getSelectedObjects()

        if next(selection) ~= nil then
            for key, value in pairs(selection) do
                if enc.call("APIobjectExist",{obj=value}) == true then
                    dataTable.target = value
                    UpdateEncoderDataValue (dataTable)
                end
            end
        else
            UpdateEncoderDataValue (dataTable)
        end
    end
end

function UpdateEncoderDataValue (dataTable)
    local objectData = dataTable.encoder.call("APIgetObjectData",{obj = dataTable.target, propID = pID})

    if objectData[dataTable.varName] ~= nil then
        if type(dataTable.varDelta) == "number" then
            if type(objectData[dataTable.varName]) ==  "number" then
                objectData[dataTable.varName] = objectData[dataTable.varName] + dataTable.varDelta
            else
                broadcastToAll("Type mismatch in value update attempt, received "..tostring(dataTable.varDelta).." against "..tostring(objectData[dataTable.varName]))
                broadcastToAll(type(dataTable.varDelta).."  "..type(objectData[dataTable.varName]))
            end
        elseif type(dataTable.varDelta) == "boolean" then
            if type(objectData[dataTable.varName]) ==  "boolean" then
                objectData[dataTable.varName] = dataTable.varDelta
            else
                broadcastToAll("Type mismatch in value update attempt, received "..tostring(dataTable.varDelta).." against "..tostring(objectData[dataTable.varName]))
            end
        elseif type(dataTable.varDelta) == "string" then
            if type(objectData[dataTable.varName]) ==  "string" then
                objectData[dataTable.varName] = dataTable.varDelta
            else
                broadcastToAll("Type mismatch in value update attempt, received "..tostring(dataTable.varDelta).." against "..tostring(objectData[dataTable.varName]))
            end
        else
            broadcastToAll("Error in value update attempt, received "..tostring(dataTable.varDelta))
        end
    else
        broadcastToAll("Overriding nil value")
        objectData[dataTable.varName] = dataTable.varDelta
    end

    dataTable.encoder.call("APIsetObjectData",{obj = dataTable.target, propID = pID, data = objectData})
    enc.call("APIrebuildButtons",{obj = dataTable.target})
end

function ToggleDisplayCounter (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local data = dataTable.encoder.call("APIgetObjectData",{obj=tar,propID=pID})
    dataTable.varDelta = not data.displayCounters
    dataTable.varName = "displayCounters"
    PropagateValueChange(dataTable)
end

function ToggleDisplayPowTou (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local data = dataTable.encoder.call("APIgetObjectData",{obj=tar,propID=pID})
    dataTable.varDelta = not data.displayPowTou
    dataTable.varName = "displayPowTou"
    PropagateValueChange(dataTable)
end

function ToggleDisplayPlusOne (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local data = dataTable.encoder.call("APIgetObjectData",{obj=tar,propID=pID})
    dataTable.varDelta = not data.displayPlusOne
    dataTable.varName = "displayPlusOne"
    PropagateValueChange(dataTable)
end

function ReceiveGemClick (tar, ply, alt)
    if alt == false then ReceiveControllerClick(tar, ply, alt)
    else ReceiveOwnershipClick(tar, ply, alt) end
end

function ReceiveOwnershipClick (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local data = dataTable.encoder.call("APIgetObjectData",{obj=tar,propID=pID})
    dataTable.varDelta = ply
    dataTable.varName = "ownerColor"
    PropagateValueChange(dataTable)
end

function ReceiveControllerClick (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local data = dataTable.encoder.call("APIgetObjectData",{obj=tar,propID=pID})
    dataTable.varDelta = ply
    dataTable.varName = "controllerColor"
    PropagateValueChange(dataTable)
end

function GetClickdataTable (tar, ply, alt)
    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        local dataTable = {encoder = enc, target = tar, player = ply, alt_click = alt, varName, varDelta}
        return dataTable
    else
        tryAutoRegister()
    end
end

function receiveCounterClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "genericCount"
    PropagateValueChange(dataTable)
end

function receiveTenCounterClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -10 or 10
    dataTable.varName = "genericCount"
    PropagateValueChange(dataTable)
end

function receivePowerClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "power"
    PropagateValueChange(dataTable)
end

function receiveToughnessClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "toughness"
    PropagateValueChange(dataTable)
end

function receivePowTouClick(tar,ply,alt)
    receivePowerClick(tar,ply,alt)
    receiveToughnessClick(tar,ply,alt)
    --inefficient but propagating doesn't support changing two values atm
end

function receivePlusOneClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "plusOneCounters"
    PropagateValueChange(dataTable)
end

function receiveTenPlusOneClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -10 or 10
    dataTable.varName = "plusOneCounters"
    PropagateValueChange(dataTable)
end

--Parse Functions
function parseCardData(object, enc)
    if enc ~= nil then
        local data = enc.call("APIgetObjectData",{obj=object,propID=pID})

        if data == nil then
            local datatTable = {obj = object}
            data = autoActivate(dataTable)
            return
        end
        
        if data.hasParsed == false then
            data.hasParsed = true

            local description = object.getDescription()

            local loyaltyValue = getLoyaltyFromCard(description)

            if loyaltyValue ~= nil then
                data.genericCount = tonumber(loyaltyValue)
                data.hasLoyalty = true
            else
                data.hasLoyalty = false
                data.hasOtherCounter = hasKeywordOrNamedCounter(object)
            end
            data.displayCounters = autoActivateCounter and (data.hasLoyalty or data.hasOtherCounter)

            local power = getPowerFromCard(description)
            local toughness = getToughnessFromCard(description)

            if power ~= nil and toughness ~= nil then
                data.power = tonumber(power)
                data.toughness = tonumber(toughness)

                data.displayPowTou = autoActivatePowTou
            else
                data.displayPowTou = false
            end
            
            if true then --just using this to make the plusone section collapsible
                local typeLine = string.match(object.getName(),"\n.*")
                if typeLine ~= nil and string.find(typeLine, "Creature") == nil then
                    data.displayPlusOne = false
                else
                    local selfReferralString = {"it", object.getName():gsub('\n.*','')}

                    local parsedValue
                    for index, nameString in ipairs (selfReferralString) do
                        parsedValue = string.match(description, "[%+%-]1/[%+%-]1 counters? on "..nameString)
                        if parsedValue ~= nil then
                            data.displayPlusOne = autoActivatePlusOne
                            break
                        end
                    end
                end
            end

            enc.call("APIsetObjectData",{obj=object,propID=pID,data=data})
        end
    end
end

function getLoyaltyFromCard(description)
    local parsedValue = string.match(description,"]%d+%[")
    local loyaltyValue
    if parsedValue ~= nil then
        loyaltyValue = string.match(parsedValue,"%d+")
    end
    return loyaltyValue
end

function hasKeywordOrNamedCounter(object)
    local keywordCounters = {"Cumulative upkeep", "Suspend", "Vanishing", "Fading", "after III"}
    local description = object.getDescription()

    for index, keywordString in ipairs(keywordCounters) do
        if string.find(description, keywordString) then
                return true
        end
    end
    local namedCounterCheckParse
    namedCounterCheckParse = string.match(object.getDescription(), "[pP]ut %a+ %a+ counters? on %a+")
    if namedCounterCheckParse == nil then namedCounterCheckParse = string.match(object.getDescription(), "with %a+ %a+ counters? on %a+") end

    local cardNameFirstWord = string.match(object.getName(), "%a+")

    if namedCounterCheckParse ~= nil and (string.find(namedCounterCheckParse, " it") ~= nil or (cardNameFirstWord ~= nil and string.find(namedCounterCheckParse, " "..cardNameFirstWord)) ) ~= nil then
        --this checks if it puts counters on itself, the space is to avoid false hits for other words
        namedCounters = {"charge", "storage", "quest", "spore", "depletion", "ki", "verse"}

        for index, counterName in ipairs(namedCounters) do
            if string.find(namedCounterCheckParse, counterName) ~= nil then
                return true
            end
        end
    end
    
    return false
end

function getPowerFromCard(description)
    local parsedValue = string.match(description,"]([%d%*xX]+)/")
    local powerValue
    if parsedValue ~= nil then
        powerValue = parsedValue
    end
    return powerValue
end

function getToughnessFromCard(description)
    local parsedValue = string.match(description,"/([%d%*xX]+)%[")
    local toughnessValue
    if parsedValue ~= nil then
        toughnessValue = parsedValue
    end
    return toughnessValue
end

--Auto Functions
function onObjectDropped (player, object)
    TryTimedEncoding(object)
end

function TryTimedEncoding(object)
    if object.tag ~= "Card" then return end

    local enc = Global.getVar('Encoder')
    if enc == nil or autoActivateModule == false then return end

    if enc.call("APIobjectExist",{obj=object}) == false and object.getVar('noencode') == nil then
        enc.call("APIaddObject",{obj=object})
    end

    if enc.call("APIpropertyExists",{propID = pID}) == false then return end

    if enc.call("APIcheckEnabled", {obj=object, propID = pID}) == false then
        enc.call("APItoggleProperty",{obj=object, propID = pID})

        InitializeCardData(object, enc)

        enc.call("APIrebuildButtons",{obj=object})
        return
    end
end

function autoActivate(dataTable)
    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        if enc.call("APIpropertyExists",{propID = pID}) == false then
            return
        
        elseif enc.call("APIobjectExist", {obj=dataTable.obj}) ~= nil then
            local data = enc.call("APIgetObjectData",{obj=dataTable.obj,propID=pID})
            if data ~= nil and data.hasStats ~= nil then return data end

            if enc.call("APIcheckEnabled", {obj=dataTable.obj, propID = pID}) == false then
                enc.call("APItoggleProperty",{obj=dataTable.obj, propID = pID})

                parseCardData(dataTable.obj)

                enc.call("APIrebuildButtons",{obj=dataTable.obj})
                return data
            end
        end
    end
end

function InitializeCardData(object, enc)
    parseCardData(object, enc)
    TryAssignOwnership(object, enc)
end

function TryAssignOwnership(object, enc)
    local owner = deckPlayerPairs[object.getVar("sourceContainer")]

    if type(owner) == "string" then
        local data = enc.call("APIgetObjectData",{obj = object, propID = pID})

        data.ownerColor = owner
        data.controllerColor = owner

        enc.call("APIsetObjectData",{obj = object, propID = pID, data = data})
    end
end

--Deck Tracking Functions
deckCandidateTracker = {}
deckPlayerPairs = {}
function initializeDeckTables()
    local colorList = Color.list

    for key, value in pairs(colorList) do
        deckCandidateTracker[value] = {}
    end
end

function onObjectLeaveContainer (container, object)
    if object.tag ~= "Card" then return end

    object.setVar("sourceContainer", container.guid)
end

--[[ doesn't work
function onObjectNumberTyped (container, player, number)
    
end--]]

function onObjectEnterScriptingZone(zone, object)
    if object == nil or object.tag ~= "Card" then return end

    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        encoderZones = enc.getTable("Zones")
        if encoderZones[zone.getGUID()] ~= nil then
            local containerGUID = object.getVar("sourceContainer")
            if containerGUID == nil then return end

            local playerColor = encoderZones[zone.getGUID()].color
            if (deckCandidateTracker[playerColor][containerGUID]) ~= nil then
                deckCandidateTracker[playerColor][containerGUID].count = deckCandidateTracker[playerColor][containerGUID].count + 1;
                --jesus christ why does lua not have increment operators
            else
                deckCandidateTracker[playerColor][containerGUID] = {count = 1}
            end
            --broadcastToAll(tostring(deckCandidateTracker[playerColor][containerGUID].count))
            if deckCandidateTracker[playerColor][containerGUID].count == 7 then
                --deckCandidateTracker[playerColor][containerGUID].count = 0 --wonky workaround

                deck = getObjectFromGUID(containerGUID)
                deck.createButton({
                    click_function='doNothing',
                    function_owner=self,
    
                    position=
                    {
                        3,
                        0,
                        0,
                    },
    
                    height= 300,
                    width= 900,
                    color = {0,0,0},
    
                    rotation={0,0,45}
                })
                
                addPlayerDeck(playerColor, containerGUID)
            end
        end
    end
end

function addPlayerDeck(playerColor, containerGUID)
    if deckPlayerPairs[containerGUID] ~= nil then
        deckCandidateTracker[deckPlayerPairs[containerGUID]][containerGUID].count = 0
        broadcastToAll("Overriding deck ownership")
    end
    deckPlayerPairs[containerGUID] = playerColor
end

function doNothing()
end