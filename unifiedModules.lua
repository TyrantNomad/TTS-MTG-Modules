moduleVersion = 2.78
pID = "_MTG_Simplified_UNIFIED"

--Easy Modules Unified
--by @TyrantNomad
--built around the Encoder by Tipsy Hobbit (steam_id: 13465982)
--using functions from Importer by Amuzet (steam_id: 42755365)

isRegistered = false

unifiedGithubLink = "https://raw.githubusercontent.com/TyrantNomad/TTS-MTG-Modules/master/unifiedModules.lua"

function onload(saved_data)
    WebRequest.get("https://raw.githubusercontent.com/TyrantNomad/TTS-MTG-Modules/master/unifiedModules.lua", self, "SelfUpdateCheck")

    local dataTable = {recursiveCall=false}
    ProcessSavedData(saved_data)
    InitializeDeckTables()
    TryAutoRegister(dataTable)
    CreateModuleChipButtons()

    Wait.time(BroadcastSettings, 6)
 end

function SelfUpdateCheck(webRequest)
    local gitVersion = tonumber(webRequest.text:match('moduleVersion%s=%s(%d+%.%d+)'))

    if gitVersion ~= nil and gitVersion > moduleVersion then
        self.script_code = webRequest.text
        self.reload()
    end
end

function onSave()
    local data_to_save = {
        autoActivateModule = autoActivateModule,
        autoActivatePlayerSettings = autoActivatePlayerSettings,
        autoActivateCounter = autoActivateCounter,
        autoActivatePowTou = autoActivatePowTou,
        autoActivatePlusOne = autoActivatePlusOne,
        autoActivateDFC = autoActivateDFC,
        autoActivateOwnership = autoActivateOwnership
    }
    local saved_data = JSON.encode(data_to_save)
    return saved_data
end

autoActivateModule = true
autoActivatePlayerSettings = {}
autoActivateCounter = true
autoActivatePowTou = true
autoActivatePlusOne = true
autoActivateDFC = true
autoActivateOwnership = true
scryfallCardCache = {}
parsedScryfallCache = {}
function ProcessSavedData(saved_data)
    if saved_data ~= nil and saved_data ~= "" then
        --print(saved_data)
        local loaded_data = JSON.decode(saved_data)
        --local loaded_data = LuaifyJSON(saved_data)
        autoActivateModule = loaded_data.autoActivateModule == nil and true or ToBool(loaded_data.autoActivateModule)
        autoActivatePlayerSettings = loaded_data.autoActivatePlayerSettings == nil and autoActivatePlayerSettings or loaded_data.autoActivatePlayerSettings
        autoActivateCounter = loaded_data.autoActivateCounter == nil and true or ToBool(loaded_data.autoActivateCounter)
        autoActivatePowTou = loaded_data.autoActivatePowTou == nil and true or ToBool(loaded_data.autoActivatePowTou)
        autoActivatePlusOne = loaded_data.autoActivatePlusOne == nil and true or ToBool(loaded_data.autoActivatePlusOne)
        autoActivateDFC = loaded_data.autoActivateDFC == nil and true or ToBool(loaded_data.autoActivateDFC)
        autoActivateOwnership = loaded_data.autoActivateOwnership == nil and true or ToBool(loaded_data.autoActivateOwnership)
    end
end

function TryAutoRegister(data)
    if data.recursiveCall then
        RegisterModule()
    else
        local dataTable = {recursiveCall=true}
        Timer.destroy("unifiedModuleAutoRegister")
        Timer.create({
            identifier = "unifiedModuleAutoRegister",
            function_name = "TryAutoRegister",
            function_owner = self,
            parameters = dataTable,
            delay = 2
        })
    end
end

function ForceEncoderUpdate(placeholderCode)
    local placeholderCode = placeholderCode.text

    local encoder = Global.getVar('Encoder')
    if encoder ~= nil then
        encoder.script_code = placeholderCode
        encoder.reload()

        local dataTable = {recursiveCall=false}
        TryAutoRegister(dataTable)
    else broadcastToAll("[888888][EASY MODULES][-]\nFailed to find Encoder to update") end
end

function ForceImporterUpdate(placeholderCode)
    local placeholderCode = placeholderCode.text

    local encoder = Global.getVar('Encoder')
    local importer = GetAmuzetsCardImporter()

    if encoder ~= nil then
        importer.script_code = placeholderCode
        importer.reload()
    else broadcastToAll("[888888][EASY MODULES][-]\nFailed to find Card Importer to update") end
end

function ForcePlaceholderDependency(placeholderCode, moduleName)
    local placeholderCode = placeholderCode.text
    local spawnParams = {
        type = "reversi_chip",
        name = "[FF0000]PLACEHOLDER [-]"..moduleName,
        description = "Just go [FFCC00]get the real thing on the Steam Workshop[-] already\n [FF0000]...YOU STINKY LAZY-BUTT",
        position = {0, 5, 0},
        scale = {4, 32, 4},
        sound = false,
        callback_function = function(obj) AttachCodeToPlaceholder(obj, placeholderCode) end
    }

    spawnObject(spawnParams)
end

function ForcePlaceholderEncoder(placeholderCode)
    ForcePlaceholderDependency(placeholderCode, "Encoder")

    local dataTable = {recursiveCall=false}
    TryAutoRegister(dataTable)
end

function ForcePlaceholderImporter(placeholderCode)
    ForcePlaceholderDependency(placeholderCode, "Card Importer")
end

function AttachCodeToPlaceholder (placeholderObject, placeholderCode)
    placeholderObject.script_code = placeholderCode
    placeholderObject.reload()
end

function CreateModuleChipButtons()
    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        isRegistered = enc.call("APIpropertyExists",{propID = pID})
    else
        isRegistered = false
    end

    self.createButton({
        label = "TyrantNomad's",
        click_function=("DoNothing"),
        function_owner=self,

        position={0,0.15,-0.4},
        rotation = {0,0,0},

        height=0,
        width=0,

        font_size = 60,
        font_color = {1,156/255,196/255}
    })

    self.createButton({
        click_function="DoNothing",
        function_owner=self,
        position={0,0.15,-0.155},
        rotation={180,0,0},

        height= 116,
        width= 800,

        color = {90/255,24/255,51/255}
    })

    self.createButton({
        label= "EASY MODULES",
        click_function="DoNothing",
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
        click_function=("DoNothing"),
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
        click_function="DoNothing",
        function_owner=self,

        position={0,0.15,0.33},

        height=0,
        width=0,

        font_size = 60,
        font_color = (isRegistered and {1,156/255,196/255} or {90/255,24/255,51/255})
    })

    self.createButton({
        click_function=(isRegistered and "DoNothing" or "RegisterModule"),
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
        tooltip = "When ON, automatically activates the module, showing the easy-toggle menu on the left side of cards",

        click_function = "ToggleAutoActivate",
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

function ClearModuleChipButtons()
    local chipButtons = self.getButtons()
    for index,button in pairs(chipButtons) do
        self.removeButton(index -1)
    end
end

function RefreshModuleChipButtons()
    ClearModuleChipButtons()
    CreateModuleChipButtons()
end

encVersion = 0
--external auto-registration compatibility
function registerModule() RegisterModule() end
function RegisterModule()
    --better to always try to register in case of object reloading
    --if isRegistered then return end

    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        RefreshEncoderVersion(enc)
        if encVersion < 4.2 then 
            broadcastToAll("[888888][EASY MODULES][-]\nEncoder version too old. To use this module, manually upgrade it to v4.20+ or type 'force encoder update' to attempt a forced update")
            return
        end
    
        local properties
        if encVersion < 4.4 then
            properties = {
                propID = pID,
                name = " Easy Modules Unified",
                values = {"tyrantUnified"},
                funcOwner = self,
                callOnActivate = false,
                activateFunc =''
            }
        else
            properties = {
                propID = pID,
                name = " Easy Modules Unified",
                values = {"tyrantUnified"},
                funcOwner = self,
                tags="basic,counter",
                activateFunc ='ModuleActivation'
            }
        end
        enc.call("APIregisterProperty",properties)

        local value = {
            valueID = 'tyrantUnified', 
            validType = 'nil',
            desc = "why do my values have descriptions",  
            default = {
                hasParsed = false,
                exactCopyOffset = 0,

                activeFace = 1,
                doubleFaceType = "none",
                doubleFaceStates = false,
                cardFaces = {
                    {basePower = 0, baseToughness = 0, isPlaneswalker = false, pwAbilities = {}, pwCount = 0},
                    {basePower = 0, baseToughness = 0, isPlaneswalker = false, pwAbilities = {}, pwCount = 0} --backface
                },

                --[[
                face types:
                "none", single-faced card
                "split", two cards in a single face side by side
                "flip", two cards in a single face in opposite orientations, sharing a central art
                "oldImport", DFC (!/null) - old importer DFC, button should reimport card
                "modal", DFC (^/^v) - at least one side is a non-legendary land
                "weredrazi", DFC(full moon/squid thing) - back side is type eldrazi
                "discovery", DFC(compass/land) - back side is type legendary land
                "ascendant", DFC(unlit PW symbol, lit PW symbol) - front side is a creature, back side is planeswalker
                "werecard", DFC(sun/crescent moon) - any other card that transforms
                --]]

                power = 0, toughness = 0,
                plusOneCounters = 0,
                namedCounters = 0, hasNonLoyaltyCounter = false,

                displayCounters = false,
                displayPlaneswalkerAbilities = false,
                displayPowTou = false,
                displayPlusOne = false,
                displayOwnership = true,
                displayDFC = false,


                ownerColor = "Grey",
                controllerColor = "Grey"
            }
        }
        enc.call("APIregisterValue",value)

        RefreshModuleChipButtons()
    else
        broadcastToAll("[888888][EASY MODULES][-]\nNo encoder found. You need [FFCC00]Encoder v4.20+ by Tipsy Hobbit (steam_id: 13465982)[-] to use the module")
        broadcastToAll("[888888][EASY MODULES][-]\nGet the Encoder from the Steam Workshop or type [FFCC00]'force encoder temporary'[-] to spawn a placeholder")
    end
end

function RefreshEncoderVersion(encoder)
    encVersion = tonumber(encoder.getVar("version"):match("%d+%.%d+"))
end

function ModuleActivation(obj,ply)
    enc.call("APItoggleProperty",{obj=obj,propID=pID})
end

function onChat(message, player)
    local message = string.lower(message)

    if string.find(message,'^force encoder') ~= nil then
        if string.find (message,'update') ~= nil then
            WebRequest.get("https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Encoder%20Core.lua", self, "ForceEncoderUpdate")
        elseif string.find (message,'temporary') ~= nil then
            WebRequest.get("https://raw.githubusercontent.com/Jophire/Tabletop-Simulator-Workshop-Items/master/Encoder/Encoder%20Core.lua", self, "ForcePlaceholderEncoder")
        elseif string.find (message, 'reload') ~= nil then
            enc = Global.getVar("Encoder")
            if enc ~= nil then 
                BroadcastToAll("Reloading Encoder object")
                enc.reload()
            end
        end
    end
    
    if string.find(message, '^force importer') ~= nil then
        if string.find (message, 'update') ~= nil then
            WebRequest.get("https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Magic/Importer.lua", self, "ForceImporterUpdate")
        elseif string.find (message, 'temporary') ~= nil then
            WebRequest.get("https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Magic/Importer.lua", self, "ForcePlaceholderImporter")
        elseif string.find (message, 'reload') ~= nil then
            local amuzetCardImporter = GetAmuzetsCardImporter()
            amuzetCardImporter.reload()
        end
    end

    if string.find(message, 'auto') ~= nil then
        --multi-setting supported ex 'auto powtou counter plusone off' should set all 3
        local targetState = message:find('%son') and true or (message:find('%soff') == nil and nil or false)
        if targetState == nil then return end

        local changedAnything = false
        if message:find('powtou') then
            autoActivatePowTou = targetState
            changedAnything = true
        end

        if message:find('plusone') then
            autoActivatePlusOne = targetState
            changedAnything = true
        end

        if message:find('counter') then
            autoActivateCounter = targetState
            changedAnything = true
        end

        if message:find('encode') then
            autoActivateModule = targetState
            changedAnything = true
        end

        if message:find('dfc') or message:find('double%-faced') then
            autoActivateDFC = targetState
            changedAnything = true
        end

        if message:find('owner') or message:find('control') then
            autoActivateOwnership = targetState
            changedAnything = true
        end

        if message:find('player') then
            autoActivatePlayerSettings[player.steam_id] = targetState and targetState or false
            local targetString = targetState and "[00FF00]ENABLED [-]" or "[FF0000]DISABLED [-]"
            local hexColor = Color.fromString(player.color):toHex(false)
            broadcastToAll("[BBBBBB]Auto-encoding "..targetString.."for ["..hexColor.."]"..player.steam_name.."[-]")
        end

        if changedAnything then BroadcastToAll("[888888][EASY MODULES][-] Settings Changed - Type 'module settings' to review") end
    end

    if string.find(message, '^module') ~= nil then
        if message:find('help') then BroadcastCommands() end
        if message:find('setting') then BroadcastSettings() end
        if message:find('update') then SelfUpdateCheck() end
    end
end

function BroadcastSettings()
    broadcastToAll("\n[888888][EASY MODULES][-] v"..moduleVersion.." - Auto-encode "..(autoActivateModule and "[00FF00]ON[-]" or "[FF0000]OFF[-]").." - Auto settings:")

    autoCounterText = autoActivateCounter and "[FFCC00]ON[-]" or "[BBBBBB]OFF[-]"
    autoPowTouText = autoActivatePowTou and "[FFCC00]ON[-]" or "[BBBBBB]OFF[-]"
    autoPlusOneText = autoActivatePlusOne and "[FFCC00]ON[-]" or "[BBBBBB]OFF[-]"
    autoDFCtext = autoActivateDFC and "[FFCC00]ON[-]" or "[BBBBBB]OFF[-]"
    autoOwnershipText = autoActivateOwnership and "[FFCC00]ON[-]" or "[BBBBBB]OFF[-]"

    broadcastToAll("Auto PowTou "..autoPowTouText.."     ".."Auto PlusOne "..autoPlusOneText.."     ".."Auto Counter "..autoCounterText)
    broadcastToAll("Auto Double-faced "..autoDFCtext.."     ".."Auto Ownership "..autoOwnershipText.."\n")

    broadcastToAll("Type [FFCC00]'module help'[-] to list commands")

    if autoActivateModule == false then broadcastToAll("\n[FF0000]Auto-encoding is [FFFFFF]OFF[-] - Nothing will activate automatically.\nType [FFFFFF]'auto encode on'[-] to turn it back on\n") 
    else 
        for key, player in pairs(Player.getPlayers()) do
            if autoActivatePlayerSettings[player.steam_id] ~= nil then
            --honestly we don't really car to show this unless the player disabled it, I'll keep the string ready for it but let's avoid spamming too much
                if autoActivatePlayerSettings[player.steam_id] then else
                    local stateString = autoActivatePlayerSettings[player.steam_id] and "[00FF00]ENABLED [-]" or "[FF0000]DISABLED [-]"
                    local hexColor = Color.fromString(player.color):toHex(false)
                    broadcastToAll("[BBBBBB]Auto-encoding is "..stateString.."for ["..hexColor.."]"..player.steam_name.."[-]")
                end
            end
        end
        broadcastToAll("[BBBBBB]Each player can set their preference by typing [FFCC00]'auto [FFFFFF]player[-] on/off")
    end
end

function BroadcastCommands()
    broadcastToAll("[888888][EASY MODULES][-] Command List")
    broadcastToAll("force     [BBBBBB]encoder / importer[-]     reload[888888] - Reloads the object, use if they stop working")
    broadcastToAll("force     [BBBBBB]encoder / importer[-]     update[888888] - Replaces object script with most recent release")
    broadcastToAll("force     [BBBBBB]encoder / importer[-]     temporary[888888] - Creates a placeholder with that script")
    broadcastToAll("\nauto     [BBBBBB]player[-]     on / off[888888] - Changes auto-encoding settings for who sent the message")
    broadcastToAll("\nauto     [BBBBBB]encode / dfc / owner[-]     on / off[888888] - Changes auto-activation settings")
    broadcastToAll("auto     [BBBBBB]powtou / plusone / counter[-]     on / off[888888] - Changes auto-activation settings")
    broadcastToAll("\nmodule     settings[888888] - Shows the current auto-activation settings")
    broadcastToAll("module     help[888888] - Spams chat with 10 lines of text")
    broadcastToAll("[888888]You can [BBBBBB]stack commands[-] with the same starting word: [BBBBBB]'auto powtou plusone off'[-]")
end

function ToggleAutoActivate()
    autoActivateModule = not autoActivateModule
    RefreshModuleChipButtons()
end

--external call compatibility casing
function createButtons(t)
    enc = Global.getVar('Encoder')

    if enc ~= nil then
        local encData = enc.call("APIobjGetPropData",{obj=t.obj,propID=pID})
        local data = encData["tyrantUnified"]
        if not data.hasParsed then InitializeCardData(t.obj, enc) return end

        local flip = enc.call("APIgetFlip",{obj=t.obj})
        local scaler = {x=1,y=1,z=1}--t.obj.getScale()
        local activeFace = data.activeFace

        local amuzetCardImporter = GetAmuzetsCardImporter()

        local colorLightGrey = {177/255,177/255,177/255}
        local colorDarkGrey = {40/255,40/255,40/255}
        local colorCardBorderBlack = {19/255,16/255,12/255}

        local hexTooltipLowlight = "[BBBBBB]"
        local hexTooltipMidlight = "[DDDDDD]"
        local hexTooltipHighlight = "[FFCC00]"
        local hexTooltipBluelight = "[7799FF]"
        local hexTooltipRedlight = "[FF2222]"

        local counterHeight = 0.33
        local loyaltyOffset = (data.displayCounters and data.cardFaces[activeFace].isPlaneswalker) and -counterHeight or 0
        local rimSize = 30
        local statHorizontalOffset = 0.75
        local statVerticalOffset = 1.3315
        local loyaltyHorizontalOffset = 0.81
        local counterHorizontalOffset = -0.87

        local cardOwner = data.ownerColor == nil and "Grey" or data.ownerColor
        local ownershipColor = Color.fromString(cardOwner)
        local ownerColorHex = ownershipColor:toHex(false)
        
        local cardController = data.controllerColor == nil and "Grey" or data.controllerColor
        local controlColor = Color.fromString(cardController)
        local controlColorHex = controlColor:toHex(false)
        --tooltips
        local multiSelectTooltip = hexTooltipHighlight.."AFFECTS ALL SELECTED CARDS[-]\n\n"
        local singleSelectTooltip = hexTooltipBluelight.."AFFECTS CLICKED CARD ONLY[-]\n\n"

        local buttonTooltipOwnershipGem =
            multiSelectTooltip..
            "CONTROLLER: ["..controlColorHex.."]"..cardController.."[-]\n"..
            "OWNER: ["..ownerColorHex.."]"..cardOwner.."[-]\n\n"..
            hexTooltipMidlight.."Click to become CONTROLLER[-]\n"..
            hexTooltipLowlight.."R-Click: Become OWNER[-]\n\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Toggle Ownership Gem"
        
        local buttonTooltipCounterSingleClick = 
            multiSelectTooltip..
            "Adds 1"..hexTooltipMidlight.." to the counter[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts 1 instead[-]\n\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract 10[-]"
         
        local buttonTooltipCounterTenClick = 
            multiSelectTooltip..
            "Adds 10"..hexTooltipMidlight.." to the counter[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts 10 instead[-]"

        local buttonTooltipPowerSingleClick = 
            multiSelectTooltip..
            "Adds 1"..hexTooltipMidlight.." to Power[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts 1 instead[-]\n\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract BOTH[-]"

        local buttonTooltipToughnessSingleClick = 
            multiSelectTooltip..
            "Adds 1"..hexTooltipMidlight.." to Toughness[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts 1 instead[-]\n\n"..
            hexTooltipHighlight.."Button Below:[-]"..hexTooltipMidlight.." Add/Subtract BOTH[-]"

        local buttonTooltipPowTouSingleClick = 
            multiSelectTooltip..
            "Adds 1/1"..hexTooltipMidlight.." to Power/Toughness[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts 1/1 instead[-]"

        local buttonTooltipPlusOneSingleClick = 
            multiSelectTooltip..
            "Adds a +1/+1"..hexTooltipMidlight.." to counters[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts instead[-]\n\n"..
            hexTooltipHighlight.."Button Above:[-]"..hexTooltipMidlight.." Add/Subtract 10[-]"
         
        local buttonTooltipPlusOneTenClick = 
            multiSelectTooltip..
            "Adds +10/+10"..hexTooltipMidlight.." to counters[-]\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Subtracts instead[-]"

        local buttonTooltipToggleDisplayCounters =
            multiSelectTooltip..
            hexTooltipHighlight..(data.displayCounters == true and "HIDE" or "SHOW").."[-]"..hexTooltipMidlight.." LOYALTY/NUMBER COUNTER\n"..
            hexTooltipLowlight.."Toggles a number counter on the card"
        local buttonTooltipToggleDisplayCountersPlaneswalkerAbilities =
            "\n\n"..hexTooltipHighlight.."R-Click: [-]"..(data.displayPlaneswalkerAbilities and hexTooltipRedlight.."HIDE[-]" or "SHOW")..hexTooltipHighlight.." PLANESWALKER BUTTONS[-]"

        local buttonTooltipToggleDisplayPlusOne =
            multiSelectTooltip..
            hexTooltipHighlight..(data.displayPlusOne == true and "HIDE" or "SHOW").."[-]"..hexTooltipMidlight.." +1/+1 COUNTER\n"..
            hexTooltipLowlight.."Toggles +1/+1 counters on the card"

        local buttonTooltipToggleDisplayPowTou =
            multiSelectTooltip..
            hexTooltipHighlight..(data.displayPowTou == true and "HIDE" or "SHOW").."[-]"..hexTooltipMidlight.." POWER/TOUGHNESS\n"..
            hexTooltipLowlight.."Toggles Power/Toughness on the card"
        local buttonTooltipToggleDisplayOwnership =
            multiSelectTooltip..
            hexTooltipHighlight..(data.displayOwnership == true and "HIDE" or "SHOW").."[-]"..hexTooltipMidlight.." OWNERSHIP GEM\n"..
            hexTooltipLowlight.."Toggles Ownership Gem on the card"
        local buttonTooltipExactCopy =
            singleSelectTooltip..
            hexTooltipHighlight.."EXACT COPY[-]"..hexTooltipLowlight.." (SPAM-CLICKABLE)[-]\n"..
            hexTooltipMidlight.."Spawns an exact copy of this card including its encoder data[-]\n\n"..
            hexTooltipMidlight.."R-Click: "..hexTooltipLowlight.."Spawn a regular copy instead"
        local buttonPlaneswalkerAbilityRightClick =
            hexTooltipMidlight.."\n\nR-Click: "..hexTooltipLowlight.."Reverse Loyalty cost"

        local buttonTooltipReImport =
            singleSelectTooltip..
            hexTooltipHighlight.."RE-IMPORT[-]\n"..
            hexTooltipMidlight.."Re-imports this card through Scryfall\nand spawns it[-]\n\n"..
            hexTooltipHighlight.."IMPORTS DOUBLE-FACED CARDS[-]\n"..
            hexTooltipLowlight.."Uses Amuzet's Card Importer[-]"

        local buttonTooltipReImportMissingImporter =
            hexTooltipHighlight.."RE-IMPORT[-]\n"..
            hexTooltipMidlight.."Re-imports this card through Scryfall\nand spawns it[-]\n\n"..
            hexTooltipRedlight.."REQUIRES AMUZET'S CARD IMPORTER[-]"

        local buttonTooltipEmblemsTokens =
            singleSelectTooltip..
            hexTooltipHighlight.."EMBLEMS & TOKENS[-]\n"..
            hexTooltipMidlight.."Imports this card's emblems & tokens through Scryfall[-]\n\n"..
            hexTooltipLowlight.."Uses Amuzet's Card Importer"

        local buttonTooltipEmblemsTokensMissingImporter =
            hexTooltipHighlight.."EMBLEMS & TOKENS[-]\n"..
            hexTooltipMidlight.."Imports this card's emblems & tokens through Scryfall[-]\n\n"..
            hexTooltipRedlight.."REQUIRES AMUZET'S CARD IMPORTER[-]"

        local buttonTooltipFlipDFC =
            singleSelectTooltip..
            "[FFFFFF]FLIP TO [-]"..hexTooltipHighlight..(activeFace == 1 and "BACK" or "FRONT").."[-] FACE\n"..
            hexTooltipLowlight.."Flip the card and change the active face\n\n"..
            hexTooltipMidlight.."R-CLICK:\n[-]"..
            hexTooltipLowlight.."Changes active face without flipping[-]"
        
        local buttonTooltipFlipDFCbackless =
            hexTooltipRedlight.."NO BACK FACE IMAGE FOUND[-]\n"..
            "Click to reimport card \n\n"..
            hexTooltipMidlight.."R-CLICK:\n[-]"..
            hexTooltipLowlight.."Change active face without flipping[-]"
        
        local buttonTooltipFlipDFColdImport =
            hexTooltipRedlight.."BAD DATA - REIMPORT REQUIRED[-]\n"..
            "Click to reimport card \n\n"..
            hexTooltipMidlight.."R-CLICK:\n[-]"..
            hexTooltipLowlight.."Change active face without flipping[-]"
        
        if true then --side buttons, toggles on the left and utils on the right
                local buttonBackgroundColorOff = {0,0,0,  0.7}
                local buttonBackgroundColorOn = {0,0,0,   0.9}
                local buttonBackgroundColorError = {0.6,0,0,   0.5}
    
                local buttonTextColorOff = {0.8,0.8,0.8, 0.8}
                local buttonTextColorOn = {1,0.8,0.4, 0.7}
                local buttonTextColorOnExtra = {0.6, 1, 0.7, 0.7}
                local buttonTextSize = 55
    
                local buttonHoverColor = {0,0,0,1}
    
                local buttonDimensions = 90
                local verticalSpacing = 0.2
    
                local horizontalOffset = 1.035
                local verticalOffset = -0.36
    
                --toggle counters & planeswalker abilities
                t.obj.createButton({
                    click_function = 'ToggleDisplayCounter',
                    function_owner = self,
    
                    label = "①",
                    font_size = buttonTextSize + 8,
                    font_color = data.displayCounters and ((data.cardFaces[activeFace].isPlaneswalker and data.displayPlaneswalkerAbilities) and buttonTextColorOnExtra or buttonTextColorOn) or buttonTextColorOff,
                    tooltip = buttonTooltipToggleDisplayCounters..((data.displayCounters and data.cardFaces[activeFace].isPlaneswalker) and buttonTooltipToggleDisplayCountersPlaneswalkerAbilities or ""),
    
                    height = buttonDimensions,
                    width = buttonDimensions,
    
                    color = data.displayCounters and buttonBackgroundColorOn or buttonBackgroundColorOff,
                    hover_color = buttonHoverColor,
    
                    rotation = {0, 0, 90 - 90 * flip},
                    position =
                    {
                       - horizontalOffset * flip * scaler.x,
                        0.35*flip*scaler.z,
                        verticalOffset + 2 * verticalSpacing * scaler.y
                    }
                })
    
                --toggle powtou
                t.obj.createButton({
                    click_function = 'ToggleDisplayPowTou',
                    function_owner = self,
    
                    label = "1/",
                    font_size = buttonTextSize,
                    font_color = data.displayPowTou and buttonTextColorOn or buttonTextColorOff,
                    tooltip = buttonTooltipToggleDisplayPowTou,
    
                    height = buttonDimensions,
                    width = buttonDimensions,
    
                    color = data.displayPowTou and buttonBackgroundColorOn or buttonBackgroundColorOff,
                    hover_color = buttonHoverColor,
    
                    rotation = {0, 0, 90 - 90 * flip},
                    position =
                    {
                        -horizontalOffset * flip * scaler.x,
                        0.35*flip*scaler.z,
                        verticalOffset + 1 * verticalSpacing * scaler.y
                    }
                })
    
                --toggle plusone
                t.obj.createButton({
                    click_function = 'ToggleDisplayPlusOne',
                    function_owner = self,
    
                    label = "+1 ",
                    font_size = buttonTextSize,
                    font_color = data.displayPlusOne and buttonTextColorOn or buttonTextColorOff,
                    tooltip = buttonTooltipToggleDisplayPlusOne,
    
                    height = buttonDimensions,
                    width = buttonDimensions,
    
                    color = data.displayPlusOne and buttonBackgroundColorOn or buttonBackgroundColorOff,
                    hover_color = buttonHoverColor,
    
                    rotation = {0, 0, 90 - 90 * flip},
                    position =
                    {
                        -horizontalOffset * flip * scaler.x,
                        0.35*flip*scaler.z,
                        verticalOffset + 0 * verticalSpacing * scaler.y
                    }
                })
    
                --exact copy
                t.obj.createButton({
                    click_function = "MakeExactCopy",
                    function_owner = self,
    
                    label = "❐",
                    font_size = buttonTextSize + 6,
                    font_color = buttonTextColorOff,
                    tooltip = buttonTooltipExactCopy,
    
                    height = buttonDimensions,
                    width = buttonDimensions,
    
                    color = buttonBackgroundColorOff,
                    hover_color = buttonHoverColor,
    
                    rotation = {0, 0, 90 - 90 * flip},
                    position =
                    {
                        horizontalOffset * flip * scaler.x,
                        0.35*flip*scaler.z,
                        verticalOffset + 0 * verticalSpacing * scaler.y
                    }
                })
    
                --reimport
                if amuzetCardImporter ~= nil then --re-import button
                    t.obj.createButton({
                        click_function = "ReImport",
                        function_owner = self,
    
                        label = "↺",
                        font_size = buttonTextSize + 16,
                        font_color = buttonTextColorOff,
                        tooltip = buttonTooltipReImport,
    
                        height = buttonDimensions,
                        width = buttonDimensions,
    
                        color = buttonBackgroundColorOff,
                        hover_color = buttonHoverColor,
    
                        rotation = {0, 0, 90 - 90 * flip},
                        position =
                        {
                            horizontalOffset * flip * scaler.x,
                            0.35*flip*scaler.z,
                            verticalOffset + 1 * verticalSpacing * scaler.y
                        }
                    })
                else
                    t.obj.createButton({
                        click_function = 'ReImport',
                        function_owner = self,
    
                        label = "↺",
                        font_size = buttonTextSize + 16,
                        font_color = buttonTextColorOff,
                        tooltip = buttonTooltipReImportMissingImporter,
    
                        height = buttonDimensions,
                        width = buttonDimensions,
    
                        color = buttonBackgroundColorError,
                        hover_color = buttonBackgroundColorError,
    
                        rotation = {0, 0, 90 - 90 * flip},
                        position =
                        {
                            horizontalOffset * flip * scaler.x,
                            0.35*flip*scaler.z,
                            verticalOffset + 1 * verticalSpacing * scaler.y
                        }
                    })
                end
    
                --emblems and tokens
                if amuzetCardImporter ~= nil then --emblem button
                    t.obj.createButton({
                        click_function = "EmblemsAndTokens",
                        function_owner = self,
        
                        label = "☗",
                        font_size = buttonTextSize,
                        font_color = buttonTextColorOff,
                        tooltip = buttonTooltipEmblemsTokens,
        
                        height = buttonDimensions,
                        width = buttonDimensions,
        
                        color = buttonBackgroundColorOff,
                        hover_color = buttonHoverColor,
        
                        rotation = {0, 180, 90 - 90 * flip}, -- the label looks like an emblem when upside down
                        position =
                        {
                            horizontalOffset * flip * scaler.x,
                            0.35*flip*scaler.z,
                            verticalOffset + 2 * verticalSpacing * scaler.y
                        }
                    })
                else
                    t.obj.createButton({
                        click_function = 'EmblemsAndTokens',
                        function_owner = self,
        
                        label = "☗",
                        font_size = buttonTextSize,
                        font_color = buttonTextColorOff,
                        tooltip = buttonTooltipEmblemsTokensMissingImporter,
        
                        height = buttonDimensions,
                        width = buttonDimensions,
        
                        color = buttonBackgroundColorError,
                        hover_color = buttonBackgroundColorError,
        
                        rotation = {0, 180, 90 - 90 * flip}, -- the label looks like an emblem when upside down
                        position =
                        {
                            horizontalOffset * flip * scaler.x,
                            0.35*flip*scaler.z,
                            verticalOffset + 2 * verticalSpacing * scaler.y
                        }
                    })
                end
            end

            --simplecounter buttons & planeswalker abilities
        if data.displayCounters then
            local verticalSize = 130
            local horizontalSize = 145


            local horizontalOffset = data.cardFaces[activeFace].isPlaneswalker and loyaltyHorizontalOffset or counterHorizontalOffset
            --tile size is about 500 for 1 unit

            --bg
            t.obj.createButton({
                click_function = 'DoNothing',
                function_owner = self,

                height = verticalSize + rimSize,
                width = horizontalSize + rimSize,

                color = colorLightGrey,

                position=
                {
                    ((horizontalOffset)*flip*scaler.x),
                    0.28*flip*scaler.z,
                    (statVerticalOffset)*scaler.y
                },

                rotation={0,0,-90-90*flip}
            })

            --counter button
            t.obj.createButton({
                label=" "..data.namedCounters.." ",
                tooltip = buttonTooltipCounterSingleClick,

                click_function='ReceiveCounterClick',
                function_owner=self,

                position=
                {
                    ((horizontalOffset)*flip*scaler.x),
                    0.35*flip*scaler.z,
                    (statVerticalOffset)*scaler.y
                },

                height= verticalSize,
                width= horizontalSize,
                color = colorDarkGrey,

                font_size=fSize,
                font_color = {1,1,1},

                rotation={0,0,90-90*flip}
            })

            --delta 10 button
            t.obj.createButton({
                tooltip = buttonTooltipCounterTenClick,
                click_function='ReceiveTenCounterClick',
                function_owner=self,

                position=
                {
                    (horizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    0.23 + (statVerticalOffset)*scaler.y
                },

                height= 80,
                width= horizontalSize,
                color = {0.3,0.3,0.3, 0.3},

                scale = {1,1,0.7},

                rotation={0,0,90-90*flip}
            })

            --planeswalker abilities
            if data.cardFaces[activeFace].isPlaneswalker and data.displayPlaneswalkerAbilities then
                local pwAbilityHorizontalOffset = 1.055

                local pwTinyTextOffset = 0.006
    
                local pwAbilityFontSize = 180
                local pwNeutralAbilityFontSize = pwAbilityFontSize * 1.7
                --■☗
                --arrow up = minus, neutral = minus, arrow down = plus
                --data.cardFaces[index]["pwAbilities"]
                if data.cardFaces[activeFace]["pwAbilities"] ~= nil and data.cardFaces[activeFace]["pwCount"] > 0 then
                    for index, value in ipairs(data.cardFaces[activeFace]["pwAbilities"]) do
                        if data.cardFaces[activeFace]["pwAbilities"][index]["abilityDelta"] ~= nil then
                            local pwAbilityDelta = data.cardFaces[activeFace]["pwAbilities"][index]["abilityDelta"]
                            local pwAbilityCost = 
                                type(pwAbilityDelta) == "string" and "-X " or
                                (pwAbilityDelta > 0 and "+" or "")..pwAbilityDelta.." "--(pwAbilityDelta ~= 0 and " " or "")
                            local pwAbilityTooltip =
                                hexTooltipHighlight..pwAbilityCost.."Loyalty:[-]\n".. 
                                hexTooltipMidlight..data.cardFaces[activeFace]["pwAbilities"][index]["abilityText"]
    
                            local isNeutralAbility = pwAbilityDelta == 0
                            pwAbilityDelta = type(pwAbilityDelta) ~= "number" and -1 or pwAbilityDelta
    
                            local pwAbilityVerticalOffset = GetPlaneswalkerAbilityVerticalOffset (index, data.cardFaces[activeFace]["pwCount"])
    
                            t.obj.createButton({
                                label = isNeutralAbility and "■" or "☗",
                                tooltip = pwAbilityTooltip..buttonPlaneswalkerAbilityRightClick,
                
                                click_function='ReceivePlaneswalkerClickSlot'..index,
                                function_owner=self,
                
                                position =
                                {
                                    pwAbilityHorizontalOffset * ((-loyaltyHorizontalOffset)*flip*scaler.x),
                                    0.35*flip*scaler.z,
                                    pwAbilityVerticalOffset * scaler.y
                                },
                
                                height= 100,
                                width= 140,
                                color = colorDarkGrey,
                
                                font_size= isNeutralAbility and pwNeutralAbilityFontSize or pwAbilityFontSize,
                                font_color = colorLightGrey,
                
                                rotation={0,pwAbilityDelta < 0 and 180 or 0,90-90*flip},
                                scale = {0.8, 0.55, 0.55}
                            })
                
                            t.obj.createButton({
                                label = isNeutralAbility and "■" or "☗",
                                tooltip = buttonTooltipCounterSingleClick,
                
                                click_function='DoNothing',
                                function_owner=self,
                
                                position =
                                {
                                    pwAbilityHorizontalOffset * ((-loyaltyHorizontalOffset)*flip*scaler.x),
                                    0.35*flip*scaler.z,
                                    pwAbilityVerticalOffset * scaler.y
                                },
                
                                height= 0,
                                width= 0,
                                color = colorDarkGrey,
                
                                font_size= (isNeutralAbility and pwNeutralAbilityFontSize or pwAbilityFontSize) * 0.8,
                                font_color = colorDarkGrey,
                
                                rotation={180,pwAbilityDelta < 0 and 0 or 180,90-90*flip},
                                scale = {0.8, 0.55, 0.55}
                            })
                
                            t.obj.createButton({
                                label = pwAbilityCost,
                                tooltip = buttonTooltipCounterSingleClick,
                
                                click_function='DoNothing',
                                function_owner=self,
                
                                position =
                                {
                                    pwAbilityHorizontalOffset * ((-loyaltyHorizontalOffset)*flip*scaler.x),
                                    0.35*flip*scaler.z,
                                    (pwAbilityVerticalOffset + (pwAbilityDelta <= 0 and pwTinyTextOffset*2 or -pwTinyTextOffset)) * scaler.y
                                },
                
                                height= 0,
                                width= 0,
                
                                font_size= 55,
                                font_color = Color.White,
                
                                rotation={0,0,90-90*flip}
                            })
                        end
                    end
                end
            end
        end

        --powtou buttons
        if data.displayPowTou then
            local widthPerDigit = 25
            local baseWidth = 250
            --size for double digit 320
            --size for single digit 270?

            local horizontalSize = 320
            local verticalSize = 130

            local powerText = data.cardFaces[data.activeFace]["basePower"]
            powerText = tonumber(powerText) ~= nil and (powerText + data.power) or (data.power == 0 and powerText or data.power)

            local toughnessText = data.cardFaces[data.activeFace]["baseToughness"]
            toughnessText = tonumber(toughnessText) ~= nil and (toughnessText + data.toughness) or (data.toughness == 0 and toughnessText or data.toughness)
            --tile size is about 500 for 1 unit

            --powtou increase both button
            t.obj.createButton({
                tooltip = buttonTooltipPowTouSingleClick,
                click_function='ReceivePowTouClick',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    0.21 + (statVerticalOffset + loyaltyOffset)*scaler.y
                },

                height= 60,
                width= horizontalSize-40,
                color = {0.3,0.3,0.3, 0.3},

                scale = {1,1,0.5},

                rotation={0,0,90-90*flip}
            })

            --powtou slash
            t.obj.createButton({
                label = "/",
                font_color = {1,1,1},
                font_size= 80,

                click_function = 'DoNothing',
                function_owner = self,

                height = 0,
                width = 0,

                color = {133/255,133/255,133/255},
                hover_color = {133/255,133/255,133/255},

                position=
                {
                    (statHorizontalOffset)*flip*scaler.x,
                    0.28*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset)*scaler.y
                },

                rotation={0,0,90-90*flip}
            })

            --powtou BG right
            t.obj.createButton({
                click_function='DoNothing',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset + 20/500 - (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset)*scaler.y
                },

                height= verticalSize + 26,
                width= horizontalSize/2.1 + 26,
                color = colorLightGrey,

                rotation={0,0,-90-90*flip}
            })

            --powtou BG left
            t.obj.createButton({
                click_function='DoNothing',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset - 20/500 + (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset)*scaler.y
                },

                height= verticalSize + 26,
                width= horizontalSize/2.1 + 26,
                color = colorLightGrey,

                rotation={0,0,-90-90*flip}
            })

            --powtou pow
            t.obj.createButton({
                label = powerText.." ",
                tooltip = buttonTooltipPowerSingleClick,

                click_function='ReceivePowerClick',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset + 20/500 - (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset)*scaler.y
                },

                height= verticalSize,
                width= horizontalSize/2.1,
                color = colorDarkGrey,

                font_size= 80,
                font_color = {1,1,1},

                rotation={0,0,90-90*flip}
            })

            --powtou tou
            t.obj.createButton({
                label = " "..toughnessText,
                tooltip = buttonTooltipToughnessSingleClick,

                click_function='ReceiveToughnessClick',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset - 20/500 + (horizontalSize/4/500))*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset)*scaler.y
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

            plusOneLabelString = ""..((data.plusOneCounters >= 0) and "+" or "")..data.plusOneCounters..'/'..((data.plusOneCounters >= 0) and "+" or "")..data.plusOneCounters.." "

            -- delta 10 button
            t.obj.createButton({
                tooltip = buttonTooltipPlusOneTenClick,
                click_function='ReceiveTenPlusOneClick',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    -0.2 + (statVerticalOffset + loyaltyOffset - counterHeight)*scaler.y
                },

                height= 60,
                width= horizontalSize-40,
                color = {0.3,0.3,0.3, 0.4},
                hover_color = {1,1,1, 0.66},

                scale = {1,1,0.5},

                rotation={0,0,90-90*flip}
            })

            --bg button
            t.obj.createButton({
                click_function = 'DoNothing',
                function_owner = self,

                height = verticalSize + rimSize + 16,
                width = horizontalSize + rimSize,

                color = colorLightGrey,

                position=
                {
                    (statHorizontalOffset)*flip*scaler.x,
                    0.28*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset - counterHeight)*scaler.y
                },

                rotation={0,0,-90-90*flip}
            })

            --plus one button
            t.obj.createButton({
                label=plusOneLabelString,
                tooltip = buttonTooltipPlusOneSingleClick,

                click_function='ReceivePlusOneClick',
                function_owner=self,

                position=
                {
                    (statHorizontalOffset)*flip*scaler.x,
                    0.35*flip*scaler.z,
                    (statVerticalOffset + loyaltyOffset - counterHeight)*scaler.y
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

            if data.displayOwnership then
                --bg with ownership function
                t.obj.createButton({
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
                t.obj.createButton({
                    click_function='DoNothing',
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
                t.obj.createButton({
                    click_function= "DoNothing",
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
            
            --toggle visibility
            t.obj.createButton({
                tooltip = buttonTooltipToggleDisplayOwnership,
                click_function= "ToggleDisplayOwnership",
                function_owner=self,

                position=
                {
                    0,
                    0.35*flip*scaler.z,
                    0.13 + verticalOffset
                },

                height= 80,
                width= horizontalSize / 3,
                color = {0.3,0.3,0.3, 0.3},

                scale = {1,1,0.7},

                rotation={0,0,90-90*flip}
            })
        end

        --DFC section
        if data.displayDFC and data.doubleFaceType ~= "none" and data.doubleFaceType ~= "flip" and data.doubleFaceType ~= "split" then
            --offsets are all over the place rip, but these should fit the vast majority of most common prints
            local typeOffsets = {
                planeswalker = {-0.865, -1.330},
                modal = {-0.875, -1.300},
                discovery = {-0.87, -1.305},
                werecard = {-0.87, -1.305},
                weredrazi = {-0.87, -1.300},
                ascendant = {-0.87, -1.305},
                artifactWerecard = {-0.85, -1.280},
                oldImport = {-0.87, -1.315}
            }
            
            local horizontalOffset
            local verticalOffset

            if data.cardFaces[activeFace]["isPlaneswalker"] then
                horizontalOffset = typeOffsets["planeswalker"][1]
                verticalOffset = typeOffsets["planeswalker"][2]
            elseif data.doubleFaceType == "werecard" and t.obj.getDescription():find("rtifact") then
                horizontalOffset = typeOffsets["artifactWerecard"][1]
                verticalOffset = typeOffsets["artifactWerecard"][2]
            else
                horizontalOffset = typeOffsets[data.doubleFaceType][1]
                verticalOffset = typeOffsets[data.doubleFaceType][2]
            end
            
            local dfcSize = 150
            local bgFontSize = 420

            local dfcTooltip = data.doubleFaceType == "oldImport" and buttonTooltipFlipDFColdImport or
                buttonTooltipFlipDFC

            local dfcFunction = data.doubleFaceType == "oldImport" and "ReceiveReimportOrChangeActiveFace" or "ReceiveChangeActiveFace"
            
            dfcBGcolor = Color(0.17,0.17,0.12)
            dfcFrameColor = data.doubleFaceType == "oldImport" and Color(1, 0.3, 0) or Color(1, 0.8, 0) --hextooltip highlight color
            dfcTextColor = data.doubleFaceType == "oldImport" and Color(1, 0.8, 0) or Color(1,1,1)

            --bg 
            t.obj.createButton({
                click_function = dfcFunction,
                tooltip = dfcTooltip,

                label = "●",
                function_owner = self,

                height = dfcSize,
                width = dfcSize,

                color = Color.Yellow,

                position=
                {
                    ((horizontalOffset)*flip*scaler.x),
                    0.35*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                font_size = bgFontSize * 1.25,
                font_color = dfcBGcolor,

                rotation={0,0,90-90*flip},
                scale = {0.5,0.5,0.5}
            })

            --bg  frame
            t.obj.createButton({
                click_function = 'DoNothing',
                label = "○",
                function_owner = self,

                height = 0,
                width = 0,

                position=
                {
                    ((horizontalOffset)*flip*scaler.x),
                    0.40*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                font_size = bgFontSize,
                font_color = dfcFrameColor:lerp(Color(0,0,0), 0.35),

                rotation={0,0,-90-90*flip},
                scale = {0.5,0.5,0.5}
            })

            local dfcLabelSymbols = {
                --structure:
                --name = {{frontSymbol1, frontSymbol2}, {backSymbol1, backSymbol2}}
                modal = {{"▴",""},{"▴ "," ▾"}},
                werecard = {{"❂",""},{" ☾  ",""}},
                weredrazi = {{"⊙",""},{"☤","♣"}},
                discovery = {{"※",""},{"    ▴     ","     ▴    "}},
                ascendant = {{"✧",""},{"✦",""}},
                oldImport = {{"!","! !"},{"!","! !"}}
            }

            local dfcSymbolOffset = {
                modal = {0.013, 0.013},
                werecard = {0.012, 0.012},
                weredrazi = {0.005, 0.040},
                discovery = {-0.003, 0.018},
                ascendant = {0.010, 0.012},
                oldImport = {0.005, -0.01}
            }

            --label symbol 2
            t.obj.createButton({
                click_function = 'DoNothing',
                label = dfcLabelSymbols[data.doubleFaceType][activeFace][2],
                function_owner = self,

                height = 0,
                width = 0,

                position=
                {
                    ((horizontalOffset)*flip*scaler.x),
                    0.40*flip*scaler.z,
                    (verticalOffset)*scaler.y
                },

                font_size = bgFontSize * 0.42,
                font_color = dfcTextColor:lerp(Color(0,0,0),0.15),

                rotation={0,0,90-90*flip},
                scale = {0.5,0.5,0.5}
            })

            --label symbol 1
            t.obj.createButton({
                click_function = 'DoNothing',
                label = dfcLabelSymbols[data.doubleFaceType][activeFace][1],
                function_owner = self,

                height = 0,
                width = 0,

                position=
                {
                    ((horizontalOffset)*flip*scaler.x),
                    0.40*flip*scaler.z,
                    (verticalOffset + dfcSymbolOffset[data.doubleFaceType][activeFace])*scaler.y
                },

                font_size = bgFontSize * 0.42,
                font_color = dfcTextColor,

                rotation={0,0,90-90*flip},
                scale = {0.5,0.5,0.5}
            })
        end
    end
end

function GetPlaneswalkerAbilityVerticalOffset (abilityIndex, abilityCount)
    local fourSlotOffsets = {
        0.3,
        0.58,
        0.82,
        1.06
    }

    local threeSlotOffsets = {
        0.52,
        0.78,
        1.06
    }

    --when there are ONLY 2 slots being, BOTH with pw abilities, it uses this spacing instead
    --apparently only arlinn kord meets these conditions
    local twoSlotOffsets = {
        0.62,
        1.02
    }

    if abilityIndex >= 1 and abilityIndex <= 4 then
        if (abilityCount >= 4) then
            if (abilityIndex > 4) then broadcastToAll("[888888][EASY MODULES][-]\nInvalid planeswalker ability index received: "..abilityIndex) end
            
            return fourSlotOffsets[math.min(abilityIndex, 4)]
        elseif (abilityCount == 3) then
            return threeSlotOffsets[math.min(abilityIndex, 3)]
        elseif (abilityCount == 2) then
            --need to check special cases for this one
            return twoSlotOffsets[math.min(abilityIndex, 2)]
        else
            --no planeswalker has only 1 slot, but if they did it would probably use the centered one
            return fourSlotOffsets[math.min(abilityIndex + 2, 4)]
        end
    else
        broadcastToAll("[888888][EASY MODULES][-]\nInvalid planeswalker ability index received: "..abilityIndex)
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
                if enc.call("APIobjectExists",{obj=value}) == true then
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
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj = dataTable.target, propID = pID})
    local objectData = encData["tyrantUnified"]

    if objectData[dataTable.varName] ~= nil then
        if type(dataTable.varDelta) == "number" then
            if type(objectData[dataTable.varName]) ==  "number" then
                objectData[dataTable.varName] = objectData[dataTable.varName] + dataTable.varDelta
            else
                broadcastToAll("[888888][EASY MODULES][-]\nType mismatch in value update attempt, received "..tostring(dataTable.varDelta).." against "..tostring(objectData[dataTable.varName]))
                broadcastToAll(type(dataTable.varDelta).."  "..type(objectData[dataTable.varName]))
            end
        elseif type(dataTable.varDelta) == "boolean" then
            if type(objectData[dataTable.varName]) ==  "boolean" then
                objectData[dataTable.varName] = dataTable.varDelta
            else
                broadcastToAll("[888888][EASY MODULES][-]\nType mismatch in value update attempt, received "..tostring(dataTable.varDelta).." against "..tostring(objectData[dataTable.varName]))
            end
        elseif type(dataTable.varDelta) == "string" then
            if type(objectData[dataTable.varName]) ==  "string" then
                objectData[dataTable.varName] = dataTable.varDelta
            else
                broadcastToAll("[888888][EASY MODULES][-]\nType mismatch in value update attempt, received "..tostring(dataTable.varDelta).." against "..tostring(objectData[dataTable.varName]))
            end
        else
            broadcastToAll("[888888][EASY MODULES][-]\nError in value update attempt, received "..tostring(dataTable.varDelta))
        end
    else
        broadcastToAll("[888888][EASY MODULES][-]\nOverriding nil value for: "..dataTable.varName)
        objectData[dataTable.varName] = dataTable.varDelta
    end

    encData["tyrantUnified"] = objectData
    dataTable.encoder.call("APIobjSetPropData",{obj = dataTable.target, propID = pID, data = encData})
    enc.call("APIrebuildButtons",{obj = dataTable.target})
end

function ToggleDisplayCounter (tar, ply, alt)
    if alt then TogglePlaneswalkerAbilities(tar, ply, alt) return end

    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    dataTable.varDelta = not data.displayCounters
    dataTable.varName = "displayCounters"
    PropagateValueChange(dataTable)
end

function TogglePlaneswalkerAbilities (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    dataTable.varDelta = not data.displayPlaneswalkerAbilities
    dataTable.varName = "displayPlaneswalkerAbilities"
    PropagateValueChange(dataTable)
end

function ToggleDisplayPowTou (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    dataTable.varDelta = not data.displayPowTou
    dataTable.varName = "displayPowTou"
    PropagateValueChange(dataTable)
end

function ToggleDisplayPlusOne (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    dataTable.varDelta = not data.displayPlusOne
    dataTable.varName = "displayPlusOne"
    PropagateValueChange(dataTable)
end

function ToggleDisplayOwnership (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    dataTable.varDelta = not data.displayOwnership
    dataTable.varName = "displayOwnership"
    PropagateValueChange(dataTable)
end

function ReceiveChangeActiveFace (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    local cardData = CheckGetSetCardTable(tar, nil)

    if data["doubleFaceStates"] and alt == false then
        local dfcStates = tar.getStates()
        local newDFCobject = tar.setState(dfcStates[1]["id"])
        TryEncoding(newDFCobject)
        dataTable.encoder.call("APIrebuildButtons",{obj=newDFCobject})
        return
    end

    if data["ownerColor"] ~= nil and data["ownerColor"] ~= "Grey" then 
        broadcastToAll("[888888][EASY MODULES][-]\nLibrary double-faced card detected, reimporting.")
        ReImport(tar, ply, false)
        return
    end

    data.activeFace = data.activeFace == 1 and 2 or 1

    if data.cardFaces[data.activeFace]["isPlaneswalker"] then
        data.displayPlaneswalkerAbilities = true
        data.displayCounters = true
        data.displayPowTou = false
    else
        data.displayPlaneswalkerAbilities = false
        data.displayCounters = false

        facePower = tonumber(data.cardFaces[data.activeFace]["basePower"]) == nil and 0 or tonumber(data.cardFaces[data.activeFace]["basePower"])
        faceToughness = tonumber(data.cardFaces[data.activeFace]["baseToughness"]) == nil and 0 or tonumber(data.cardFaces[data.activeFace]["baseToughness"])
        data.displayPowTou = (facePower ~= 0) or (faceToughness ~= 0)
    end

    if alt == false then
        tar.flip()
        dataTable.encoder.call("APIFlip",{obj = tar})
    end

    encData["tyrantUnified"] = data
    dataTable.encoder.call("APIobjSetPropData",{obj = tar, propID = pID, data = encData})
    enc.call("APIrebuildButtons",{obj = tar})
end

function ReceiveReimportOrChangeActiveFace (tar, ply, alt)
    if alt then ReceiveChangeActiveFace(tar, ply, alt) return end

    ReImport(tar, ply, alt)
end

function ReceiveGemClick (tar, ply, alt)
    if alt == false then ReceiveControllerClick(tar, ply, alt)
    else ReceiveOwnershipClick(tar, ply, alt) end
end

function ReceiveOwnershipClick (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
    dataTable.varDelta = ply
    dataTable.varName = "ownerColor"
    PropagateValueChange(dataTable)
end

function ReceiveControllerClick (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj=tar,propID=pID})
    local data = encData["tyrantUnified"]
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
        local dataTable = {recursiveCall=false}
        TryAutoRegister(dataTable)
    end
end

function ReceiveCounterClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "namedCounters"
    PropagateValueChange(dataTable)
end

function ReceiveTenCounterClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -10 or 10
    dataTable.varName = "namedCounters"
    PropagateValueChange(dataTable)
end

function GetPlaneswalkerAbilityDelta (dataTable, index)
    local encData = dataTable.encoder.call("APIobjGetPropData",{obj = dataTable.target, propID = pID})
    local data = encData["tyrantUnified"]
    
    dataTable.varDelta = data.cardFaces[data.activeFace]["pwAbilities"][index]["abilityDelta"]
    dataTable.varDelta = (type(dataTable.varDelta) == "number" and dataTable.varDelta or -1) * (dataTable.alt_click and -1 or 1)

    return dataTable.varDelta
end

function ReceivePlaneswalkerClickSlot1 (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varName = "namedCounters"
    dataTable.varDelta = GetPlaneswalkerAbilityDelta(dataTable, 1)
    PropagateValueChange(dataTable)
end

function ReceivePlaneswalkerClickSlot2 (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varName = "namedCounters"
    dataTable.varDelta = GetPlaneswalkerAbilityDelta(dataTable, 2)
    PropagateValueChange(dataTable)
end

function ReceivePlaneswalkerClickSlot3 (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varName = "namedCounters"
    dataTable.varDelta = GetPlaneswalkerAbilityDelta(dataTable, 3)
    PropagateValueChange(dataTable)
end

function ReceivePlaneswalkerClickSlot4 (tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varName = "namedCounters"
    dataTable.varDelta = GetPlaneswalkerAbilityDelta(dataTable, 4)
    PropagateValueChange(dataTable)
end

function ReceivePowerClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "power"
    PropagateValueChange(dataTable)
end

function ReceiveToughnessClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "toughness"
    PropagateValueChange(dataTable)
end

function ReceiveToughnessZeroClick(tar, ply, alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "toughness"
    PropagateValueChange(dataTable)
end

function ReceivePowTouClick(tar,ply,alt)
    ReceivePowerClick(tar,ply,alt)
    ReceiveToughnessClick(tar,ply,alt)
    --inefficient but propagating doesn't support changing two values atm
end

function ReceivePlusOneClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -1 or 1
    dataTable.varName = "plusOneCounters"
    PropagateValueChange(dataTable)
end

function ReceiveTenPlusOneClick(tar,ply,alt)
    local dataTable = GetClickdataTable(tar, ply, alt)
    dataTable.varDelta = alt and -10 or 10
    dataTable.varName = "plusOneCounters"
    PropagateValueChange(dataTable)
end

--Toolbox Functions
copyCount = 0
function MakeExactCopy (tar, ply, alt)
    --based on Exact Copy by Tipsy Hobbit (steam_id: 13465982)
    
    enc = Global.getVar('Encoder')
    if enc ~= nil then
        local encData = enc.call("APIobjGetPropData",{obj = tar, propID = pID})
        local data = encData["tyrantUnified"]
        local flip = enc.call("APIgetFlip",{obj=tar})
        local params = {position = tar.getPosition()}
        
        local horizontalOffsetMultiplier = data.exactCopyOffset % 5 + 1
        local verticalOffsetMultiplier = math.floor(data.exactCopyOffset/5)

        data.exactCopyOffset = data.exactCopyOffset + 1
        encData["tyrantUnified"] = data
        enc.call("APIobjSetPropData", {obj = tar, propID = pID, data = encData})

        local cardRight = tar.getTransformRight()
        local cardForward = tar.getTransformForward()

        if data.controllerColor ~= nil and data.controllerColor ~= "Grey" then
            controllerHand = Player[data.controllerColor].getHandTransform(1)
            if controllerHand ~= nil then
                --for some reason  right is left and forward is back
                cardRight[1] = controllerHand.right[1] * -1
                cardRight[3] = controllerHand.right[3] * -1

                cardForward[1] = controllerHand.forward[1] * -1
                cardForward[3] = controllerHand.forward[3] * -1
            end
        end

        local xOffset = (-2.4 * cardRight[1] * horizontalOffsetMultiplier) + (3.6 * cardForward[1] * verticalOffsetMultiplier)
        local zOffset = (-2.4 * cardRight[3] * horizontalOffsetMultiplier) + (3.6 * cardForward[3] * verticalOffsetMultiplier)

        params.position[1] = params.position[1] + xOffset
        params.position[2] = params.position[2] + 0.05
        params.position[3] = params.position[3] + zOffset

        local copiedCard = tar.clone(params)
        copyCount = copyCount + 1

        --alt click for regular copy
        if alt == false then
            copiedCard.setLock(true)
            local moduleData = enc.call("APIobjGetProps", {obj = tar})
            local valueData = enc.call("APIobjGetAllData",{obj = tar})
        
            Timer.create({
                identifier = "exactCopyTimer"..tar.guid..copyCount,
                function_name = "SetExactCopyData",
                function_owner = self,
                parameters = {copiedCard = copiedCard, valueData = valueData, moduleData = moduleData, flipData = flip, enc = enc},
                delay = 0.2
            })
        end
        
        Timer.destroy("resetExactCopyOffset"..tar.guid)
        Timer.create({
            identifier = "resetExactCopyOffset"..tar.guid,
            function_name = "ResetExactCopyOffset",
            function_owner = self,
            parameters = {tar = tar, enc = enc},
            delay = 3
        })
    end
    --cardName = UrlifyNameField(tar)
    --CreateTokenObject(scryfallCardCache[cardName],tar)
end

function SetExactCopyData (dataTable)
    dataTable.enc.call("APIencodeObject",{obj=dataTable.copiedCard})
    dataTable.enc.call("APIobjSetAllData",{obj=dataTable.copiedCard, data = dataTable.valueData})
    dataTable.enc.call("APIobjSetProps",{obj=dataTable.copiedCard, data = dataTable.moduleData})
    if dataTable.flipData < 0 then enc.call("APIFlip", {obj = dataTable.copiedCard}) end
    dataTable.enc.call("APIrebuildButtons",{obj=dataTable.copiedCard})

    dataTable.copiedCard.setLock(false)
end

function ResetExactCopyOffset (dataTable)
    local encData = dataTable.enc.call("APIobjGetPropData",{obj = dataTable.tar, propID = pID})
    local data = encData["tyrantUnified"]
    data.exactCopyOffset = 0

    encData["tyrantUnified"] = data
    dataTable.enc.call("APIobjSetPropData",{obj = dataTable.tar, propID = pID, data = encData})
end

function GetAmuzetsCardImporter ()
    enc = Global.getVar("Encoder")
    if enc ~= nil then
        local amuzetCardImporter

        RefreshEncoderVersion(enc)
        if encVersion < 4.4 then
            local encoderModuleTable = enc.getTable("Tools")
            if encoderModuleTable["Card Importer"] == nil then return end
            amuzetCardImporter = encoderModuleTable["Card Importer"].funcOwner ~= nil and encoderModuleTable["Card Importer"].funcOwner or nil
        else
            moduleReference = enc.call("APIgetProp",{propID="Card Importer"})
            if moduleReference == nil then return end
            amuzetCardImporter = moduleReference.funcOwner ~= nil and moduleReference.funcOwner or nil
        end
        if amuzetCardImporter == nil then return end

        local importerVersion = tonumber(string.match(amuzetCardImporter.getVar("version"),"%d+%.%d*"))
        if importerVersion < 1.901 then
            broadcastToAll ("[888888][EASY MODULES][-]\nUnsupported Card Importer version found, version 1.9 or newer is required")
            broadcastToAll ("[888888][EASY MODULES][-]\nType [FFCC00]'force importer update'[-] to update your Card Importer or get the new one from the Steam Workshop")
            return
        end

        return amuzetCardImporter
    end
end

function CreateImporterRequestTable (tar, ply)
    local qTbl = {
        position = tar.getPosition(),
        color = ply,
        player=Player[ply].steam_id,
        name = tar.getName():gsub("\n.*",""),
        mode = "",
        full = ""
    }

    qTbl.position[1] = qTbl.position[1] + 2.4
    qTbl.position[2] = qTbl.position[2] + 0.25

    return qTbl
end

lockReImport = false
function ReImport (tar, ply, alt)
    if lockReImport == true then
        broadcastToAll("[888888][EASY MODULES][-]\nSPAM-CLICK DETECTED\nTry again in a few seconds")
        return
    end

    if tar.getName() == "" then
        broadcastToAll("[888888][EASY MODULES][-]\nERROR\nCard Object has no name")
        return
    end

    amuzetCardImporter = GetAmuzetsCardImporter()
    if amuzetCardImporter ~= nil then
        local importerRequestTable = CreateImporterRequestTable(tar, ply)
        importerRequestTable.full = "Reimporting Card"

        amuzetCardImporter.call('Importer', importerRequestTable)

        lockReImport = true
        --used to avoid spam-clicking
        Timer.destroy("reImportTimer"..tar.guid)
        Timer.create({
            identifier = "reImportTimer"..tar.guid,
            function_name = "ReEnableReImport",
            function_owner = self,
            delay = 2
        })
    else
        broadcastToAll("[888888][EASY MODULES][-]\nThis feature requires [FFCC00]Amuzet's Card Importer[-]")
        broadcastToAll("Get the Card Importer from the Steam Workshop or type [FFCC00]'force importer temporary'[-] to create a placeholder")
    end
end

function ReEnableReImport ()
    lockReImport = false
end

lockEmblemsAndTokens = false
function EmblemsAndTokens (tar, ply, alt)
    if lockEmblemsAndTokens == true then
        broadcastToAll("[888888][EASY MODULES][-]\nSPAM-CLICK DETECTED\nTry again in a few seconds")
        return
    end

    if tar.getName() == "" then
        broadcastToAll("[888888][EASY MODULES][-]\nERROR\nCard Object has no name")
        return
    end

    amuzetCardImporter = GetAmuzetsCardImporter()
    if amuzetCardImporter ~= nil then
        importerRequestTable = CreateImporterRequestTable(tar, ply)
        importerRequestTable.full = "Importing Tokens & Emblems"
        importerRequestTable.mode = "Token"

        amuzetCardImporter.call('Importer', importerRequestTable)

        lockEmblemsAndTokens = true
        --used to avoid spam-clicking
        Timer.destroy("emblemsAndTokensTimer"..tar.guid)
        Timer.create({
            identifier = "emblemsAndTokensTimer"..tar.guid,
            function_name = "ReEnableEmblemsAndTokens",
            function_owner = self,
            delay = 2
        })
    else
        broadcastToAll("[888888][EASY MODULES][-]\nThis feature requires [FFCC00]Amuzet's Card Importer[-]")
        broadcastToAll("Get the Card Importer from the Steam Workshop or type [FFCC00]'force importer temporary'[-] to create a placeholder")
    end
end

function ReEnableEmblemsAndTokens ()
    lockEmblemsAndTokens = false
end

function CreateTokenObject(cardData, originalObject)
    local objectName = originalObject.getName()
    local objectDescription = originalObject.getDescription()
    
    local originalObjectData = originalObject.getCustomObject()
    local imageAddress = originalObjectData["face"] ~= nil and originalObjectData["face"] or ""


    local createdToken = spawnObject({
        type = "Custom_Tile",
        position = {0, 5, 0},
        callback = "",
        callback_owner = self,
        scale = {1.45, 1, 1.45}
    })

    createdToken.setCustomObject({
        type = 3,
        image = imageAddress,
        thickness = 0.15,
    })

    createdToken.setName(objectName)
    createdToken.setDescription(objectDescription)

    TryEncoding(createdToken, true)
end

--Parse Functions
function ParseCardData(dataTable)
    local enc = dataTable.enc
    local object = dataTable.object
    local scryfallData = scryfallCardCache[dataTable.nameUrlified]

    local encData = enc.call("APIobjGetPropData",{obj=object,propID=pID})
    local data = encData["tyrantUnified"]

    if data == nil then
        local dataTable = {obj = object}
        data = AutoActivate(dataTable)
    end
    
    if data.hasParsed == false then
        data.hasParsed = true
        if scryfallData ~= nil then
            local isDFC = scryfallData["card_faces"] ~= nil
            local isToken = false
            local stateBasedDFC = object.getStates() ~=  nil -- new DFC cards with states
            local faceSources = {}
            if isDFC then
                faceSources[1] = scryfallData["card_faces"][1]
                faceSources[2] = scryfallData["card_faces"][2]

                if  stateBasedDFC then
                    data.doubleFaceStates = true
                    data.activeFace = object.getStateId()-- == 1 and 2 or 1
                    --could it be? the end of inverted faces???
                else
                    if CheckInvertedFaces(object) then
                        data.activeFace = 2
                    else
                        local backFaceNameUrlified = UrlifyCardName(faceSources[2]["name"])
                        --honestly just a weird check as none of the old DFCs had the back face name on namefield
                        --whatever, weird checks but ok
                        data.activeFace = dataTable.nameUrlified == backFaceNameUrlified and 2 or 1
                    end 
                end
            else
                faceSources[1] = scryfallData
            end

            local cardData = {}--new scryfall-based sectioning

            local urlifiedName = UrlifyCardName(faceSources[data.activeFace]["name"])
            if parsedScryfallCache[urlifiedName] ~= nil then
                local cachedData = parsedScryfallCache[urlifiedName]["data"]
                cardData = parsedScryfallCache[urlifiedName]["cardData"]
                cachedData.doubleFaceStates = stateBasedDFC
                cachedData.activeFace = data.activeFace

                data = cachedData
            else
                for index, value in ipairs (faceSources) do
                    local cardStruct = {nameLine = "", typeLine = "", textLines = {}, power = "", toughness = "", loyalty = ""}    
                    table.insert(cardData, cardStruct)
                    cardData[index]["nameLine"] = faceSources[index]["name"]
                    cardData[index]["typeLine"] = faceSources[index]["type_line"]:gsub("−","-")
                    cardData[index]["textLines"] = string.splitUsingFind(faceSources[index]["oracle_text"],"\n")
                    cardData[index]["power"] = faceSources[index]["power"] ~= nil and faceSources[index]["power"] or nil
                    cardData[index]["toughness"] = faceSources[index]["toughness"] ~= nil and faceSources[index]["toughness"] or nil
                    cardData[index]["loyalty"] = faceSources[index]["loyalty"] ~= nil and faceSources[index]["loyalty"] or nil
                end

                --dirty token fix?
                isToken = cardData[data.activeFace]["typeLine"]:lower():find("token") ~= nil
                if isToken then
                    local objectDescription = object.getDescription()
                    local startIndex, endIndex = objectDescription:find("%[b%].-%/.-%[%/b%]")
                    if startIndex ~= nil then
                        local tokenPowtou = objectDescription:sub(startIndex+3,endIndex-4)
                        cardData[data.activeFace]["power"] = tokenPowtou:match("^(.-)%/")
                        cardData[data.activeFace]["toughness"] = tokenPowtou:match("/(.-)$")
                    end
                end

                if cardData[data.activeFace]["loyalty"] ~= nil then data.namedCounters = tonumber(cardData[data.activeFace]["loyalty"]) end
                for index, value in ipairs (cardData) do --goes off once for each face
                    --planeswalker check
                    if value["typeLine"]:find("laneswalker") then -- who knows if that P's gonna be capitalized
                        data.cardFaces[index]["isPlaneswalker"] = true
                        local pwAbilityCount = 0 --used to count amount of PW abilities vs amount of slots

                        --setting PW abilities
                        for innerIndex, innerValue in ipairs (value["textLines"]) do
                            local tooltipIndex = innerValue:find("%w%:%s")
                            local abilityDelta = nil

                            if tooltipIndex ~= nil then
                                pwAbilityCount = pwAbilityCount + 1
                                abilityDelta = innerValue:sub(1, tooltipIndex):gsub("−","-")
                                abilityDelta = abilityDelta:find("[xX]+") ~= nil and "X" or tonumber(abilityDelta)
                            end

                            local abilityText = tooltipIndex ~= nil and innerValue:sub(tooltipIndex + 3) or innerValue
                            data.cardFaces[index]["pwAbilities"][innerIndex] = {abilityDelta = abilityDelta, abilityText = abilityText}
                            data.cardFaces[index]["pwCount"] = data.cardFaces[index]["pwCount"] + 1
                        end

                        --trying to deal with placement edge cases - which all happen when there are only two slots
                        if (data.cardFaces[index]["pwCount"] == 2) then
                            --there's only one card with only 2 slots and 2 abilities... and it uses unique placement for some reason
                            if pwAbilityCount ~= 2 then
                                data.cardFaces[index]["pwCount"] = data.cardFaces[index]["pwCount"] + 1
                                --the other cards with 2 slots format correctly if one of the slots is counted as 2 (making a virtual third slot)
                                if data.cardFaces[index]["pwAbilities"][1]["abilityText"]:len() > data.cardFaces[index]["pwAbilities"][2]["abilityText"]:len() then
                                    data.cardFaces[index]["pwAbilities"][3] = {abilityDelta = data.cardFaces[index]["pwAbilities"][2]["abilityDelta"], abilityText = data.cardFaces[index]["pwAbilities"][2]["abilityText"]}
                                    data.cardFaces[index]["pwAbilities"][2] = {abilityDelta = nil, abilityText = "filler created to correct formatting, this should not be appear anywhere"}
                                else
                                    data.cardFaces[index]["pwAbilities"][3] = {abilityDelta = nil, abilityText = "filler created to correct formatting, this should not be appear anywhere"}
                                end
                            end
                        end
                    else --power/toughness
                        data.cardFaces[index]["basePower"] = cardData[index]["power"] ~= nil and cardData[index]["power"] or nil
                        data.cardFaces[index]["baseToughness"] = cardData[index]["toughness"] ~= nil and cardData[index]["toughness"] or nil
                    end
                end

                if true then --plus one section, we only care about the active face
                    if autoActivatePlusOne and cardData[data.activeFace]["typeLine"]:find("reature") then
                        local selfReferralString = {"it", cardData[data.activeFace]["nameLine"]:match("^%w+")}

                        for index, nameString in ipairs (selfReferralString) do
                            for innerIndex, textLine in ipairs (cardData[data.activeFace]["textLines"]) do
                                if textLine:find("[%+%-]1/[%+%-]1 counters? on "..nameString) then
                                    data.displayPlusOne = autoActivatePlusOne
                                    break --only breaks out of one loop
                                end
                            end
                        end
                    end
                end

                if isDFC then
                    frontFaceSplitCheck = cardData[1]["typeLine"]:find("nstant") and true or (cardData[1]["typeLine"]:find("orcery") and true)
                    backFaceSplitCheck = cardData[2]["typeLine"]:find("nstant") and true or (cardData[2]["typeLine"]:find("orcery") and true)
                    
                    if frontFaceSplitCheck and backFaceSplitCheck then
                        data.doubleFaceType = "split"
                    else
                        flipCardCheck = faceSources[data.activeFace]["oracle_text"]:find("lip it") or faceSources[data.activeFace]["oracle_text"]:find("lip "..cardData[1]["nameLine"]:match("^%w+"))
                        if flipCardCheck ~= nil then
                            data.doubleFaceType = "flip"
                        elseif faceSources[1]["oracle_text"]:find("ransform") == nil then
                            --alternatively: one side is a non-legendary land
                            data.doubleFaceType = "modal"
                        elseif cardData[2]["typeLine"]:find("ldrazi") ~= nil then
                            data.doubleFaceType = "weredrazi"
                        elseif cardData[2]["typeLine"]:find("[lL]and") ~= nil then
                            data.doubleFaceType = "discovery"
                        elseif (cardData[1]["typeLine"]:find("reature")) and (cardData[2]["typeLine"]:find("laneswalker")) then
                            data.doubleFaceType = "ascendant"
                        else
                            data.doubleFaceType = "werecard"
                        end
                    end
                    
                    if data.doubleFaceType ~= "none" and data.doubleFaceType ~= "flip" and data.doubleFaceType ~= "split" then
                        data.displayDFC = autoActivateDFC
                    end
                end

                if not isToken then
                    parsedScryfallCache[urlifiedName] = {}
                    parsedScryfallCache[urlifiedName]["data"] = data
                    parsedScryfallCache[urlifiedName]["cardData"] = cardData
                end
            end

            data.displayPowTou = autoActivatePowTou and (cardData[data.activeFace]["typeLine"]:find("reature") ~= nil)
            data.hasNonLoyaltyCounter = HasKeywordOrNamedCounter(cardData[data.activeFace]["nameLine"], faceSources[data.activeFace]["oracle_text"]) --maybe refactor this to not use the whole field
            data.displayPlaneswalkerAbilities = data.cardFaces[data.activeFace]["pwCount"] > 0
            data.displayCounters = autoActivateCounter and (data.cardFaces[data.activeFace].isPlaneswalker or data.hasNonLoyaltyCounter)
        end
        
        encData["tyrantUnified"] = data
        enc.call("APIobjSetPropData",{obj = object, propID = pID, data = encData})
        enc.call("APIrebuildButtons",{obj=object})
    else return end
end

function string.splitUsingFind(text, separator)
    if text == nil or text == "" then return {""} end
    --by @BoneWhite#6514 (discord id)
    local splitTable = {}
    while true do
        local index = text:find(separator)
        if not index then
            table.insert(splitTable,text)
            break
        else
            table.insert(splitTable,text:sub(1,index-1))
            text = text:sub(index+1)
        end
    end
    return splitTable
end

function HasKeywordOrNamedCounter(nameLine, description)
    local keywordCounters = {"Cumulative upkeep", "Suspend", "Vanishing", "Fading", "after III"}

    for index, keywordString in ipairs(keywordCounters) do
        if string.find(description, keywordString) then
                return true
        end
    end
    local namedCounterCheckParse
    namedCounterCheckParse = string.match(description, "[pP]ut %a+ %a+ counters? on %a+")
    if namedCounterCheckParse == nil then namedCounterCheckParse = string.match(description, "with %a+ %a+ counters? on %a+") end

    local cardNameFirstWord = string.match(nameLine, "%a+")

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

--Auto Functions
function onObjectDropped (playerColor, object)
    if autoActivateModule == false or (autoActivatePlayerSettings[Player[playerColor].steam_id] ~= nil and autoActivatePlayerSettings[Player[playerColor].steam_id] == false) then return end
    TryEncoding(object)
end

function onObjectSpawn(obj)
    if obj.tag == "Card" then
        if CheckInvertedFaces(obj) then InvertCardFaces(card) end

        cardTable = CheckGetSetCardTable(obj)
    end

    if obj.tag == "Deck" then
        containerTable = CheckGetSetContainerTable(obj)
    end
end

--[[
function TryEncoding(object)
    TryEncoding(object, false)
end
function TryEncoding(object, overrideTypeCheck)
    if not overrideTypeCheck and object.tag ~= "Card" then return end--]]
function TryEncoding(object)
    if object.tag ~= "Card" then return end
    if object.getVar('noencode') ~= nil and object.getVar('noencode') == true then return end

    local enc = Global.getVar('Encoder')
    if enc == nil then return end

    if enc.call("APIobjectExists",{obj=object}) == false then
        enc.call("APIencodeObject",{obj=object})
    end

    if enc.call("APIpropertyExists",{propID = pID}) == false then return end
    if enc.call("APIobjIsPropEnabled", {obj=object, propID = pID}) == false then
        enc.call("APIobjEnableProp",{obj=object, propID = pID})

        InitializeCardData(object, enc)
        return
    end
end

function FetchScryfallData (var)
    local cardName = type(var) == "userdata" and UrlifyNameField(var) or UrlifyCardName(var)
    if scryfallCardCache[cardName] ~= nil or queryNameTable[cardName] ~= nil then return end

    table.insert(scryfallQueryTable, cardName)
    queryNameTable[cardName] = cardName
    --used to check for redundancy, cleaned up in Storescryfalldata

    Timer.destroy("ScryfallQueryTimer")
    Timer.create({
        identifier = "ScryfallQueryTimer",
        function_name = "TimedScryfallQuery",
        function_owner = self,
        delay = 0.125,
        repetitions = 0
    })
end

queryNameTable = {}
scryfallQueryTable = {}
function TimedScryfallQuery ()
    if scryfallQueryTable[1] == nil then
        Timer.destroy("ScryfallQueryTimer")
        return
    end

    local cardName = table.remove(scryfallQueryTable, 1)
    --broadcastToAll("querying "..cardName)
    if cardName ~= nil and cardName ~= "" and scryfallCardCache[cardName] == nil then
        WebRequest.get("https://api.scryfall.com/cards/named?fuzzy="..cardName, self, "ProcessScryfallData")
    end
end

function ProcessScryfallData (requestedData)
    if requestedData.text then
        StartLuaifyJSONcoroutine(requestedData.text)
    else return end
end

function StoreScryfallData (luaTable)
    local isDFC = false
    for key,value in pairs(luaTable) do
        if key == "card_faces" then
            isDFC = true
            scryfallCardCache[UrlifyCardName(value[1]["name"])] = luaTable
            scryfallCardCache[UrlifyCardName(value[2]["name"])] = luaTable

            queryNameTable[UrlifyCardName(value[1]["name"])] = nil
            queryNameTable[UrlifyCardName(value[2]["name"])] = nil
        end
    end

    if not isDFC then
        queryNameTable[UrlifyCardName(luaTable["name"])] = nil
        --if decodedData["type_line"]:lower():find("token") then return end -- do not store token data, it's not identifiable by name
        --gives bad data sometimes, but just keeps querying if we don't store it
        scryfallCardCache[UrlifyCardName(luaTable["name"])] = luaTable
    end
end

function LuaifyJSON(jsonString)
    jsonString = jsonString:sub(2, jsonString:find("}$")-1)
    jsonString = jsonString:gsub('\\"',"\\'")
    --this should remove the start and end {} & avoid ending strings early

    local luaTable = {}
    while jsonString ~= "" do
        luaTable, jsonString = AddParsedKey(jsonString, luaTable)
    end
    return luaTable
end

luaifyWaitID = nil
function StartLuaifyJSONcoroutine(jsonString)
    table.insert(JSONqueue, jsonString)

    if luaifyWaitID ~= nil then Wait.stop(luaifyWaitID) end
    if LuaifyJSONcoroutineInstance == nil or coroutine.status(LuaifyJSONcoroutineInstance) == "dead" then LuaifyJSONcoroutineInstance = coroutine.create(LuaifyJSONcoroutineFunction) end
    luaifyWaitID = Wait.time(function() coroutine.resume(LuaifyJSONcoroutineInstance) end, 0.01, -1)
end

JSONqueue = {}
parseYieldInterval = 3
LuaifyJSONcoroutineInstance = nil
function LuaifyJSONcoroutineFunction()
    while JSONqueue[1] ~= nil do 
        jsonString = table.remove(JSONqueue,1)
        --log("started ||"..jsonString:sub(1, 40).."||")

        jsonString = jsonString:sub(2, jsonString:find("}$")-1)
        jsonString = jsonString:gsub('\\"',"\\'")
        --this should remove the start and end {} & avoid ending strings early

        local luaTable = {}

        local currentYieldInterval = parseYieldInterval
        while jsonString ~= "" do
            luaTable, jsonString = AddParsedKey(jsonString, luaTable)

            currentYieldInterval = currentYieldInterval - 1
            if currentYieldInterval == 0 then
                currentYieldInterval = parseYieldInterval
                coroutine.yield()
            end
        end

        --log("finished ||"..luaTable["id"])

        StoreScryfallData(luaTable)
    end
    
    Wait.stop(luaifyWaitID)
    return ("Parsing queue clear")
end


function AddParsedKey (jsonString, luaTable)
    local valueKey
    valueKey, jsonString = KeyParse(jsonString)
    
    luaTable[valueKey], jsonString = ParseJSON(jsonString)
    return luaTable, jsonString
end

function ParseJSON(jsonString)
    --log("||"..jsonString:sub(1, 40).."||")
    if jsonString:find('^%[') then
        --log("index table start")
        parsedValue, jsonString = IndexTableParse(jsonString)
    elseif jsonString:find('^{') then
        --log("key table start")
        parsedValue, jsonString = KeyTableParse(jsonString)
    elseif jsonString:find('^"') then
        parsedValue, jsonString = StringParse(jsonString)
    else
        parsedValue, jsonString = ValueParse(jsonString)
    end

    local commaIndex = jsonString:find("^%,")
    if commaIndex then jsonString = jsonString:sub(commaIndex+1) end
    --shitty workaround?

    return parsedValue, jsonString
end

function KeyParse(jsonString)
    --log("|||"..jsonString:sub(1, 40).."||")
    local startIndex,endIndex = jsonString:find('^".-":')
    
    local valueKey = jsonString:sub(startIndex + 1, endIndex - 2)
    --log("keyParse "..valueKey)
    return valueKey, jsonString:sub(endIndex + 1)
end

function StringParse(jsonString)
    local parsedValue = ''
    jsonString = jsonString:sub(2) --this is hilarious
    local startIndex,endIndex = jsonString:find('"')
    parsedValue = parsedValue..jsonString:sub(1, endIndex-1):gsub("\\n","\n")
    --log("stringParse "..parsedValue)
    return parsedValue, jsonString:sub(endIndex + 1)
end

function ValueParse(jsonString)
    --log("||"..jsonString:sub(1, 40).."||")
    local startIndex,endIndex = jsonString:find('^.-[,%]}$]')
    
    if not startIndex then 
        startIndex, endIndex = jsonString:find(".$") 
        endIndex = endIndex + 1
    end

    local parsedValue  = jsonString:sub(1, endIndex-1)
    --log("valueParse "..parsedValue)
    return parsedValue, jsonString:sub(endIndex)
end

function IndexTableParse(jsonString)
    local luaTable = {}
    jsonString = jsonString:sub(2)

    while not jsonString:find("^%]") do
        
        innerValue, jsonString = ParseJSON(jsonString)
        table.insert(luaTable, innerValue)
    end

    jsonString = jsonString:sub(2)
    --log("index table end")
    return luaTable, jsonString
end

function KeyTableParse(jsonString)
    local luaTable = {}
    local trackingString = jsonString:sub(1,15)
    --log("starting keyTable at ||"..trackingString)
    jsonString = jsonString:sub(2)
    while not jsonString:find("^}") do
        luaTable, jsonString = AddParsedKey(jsonString, luaTable, "xxx")
    end

    jsonString = jsonString:sub(2)
    
    --log("ending keyTable at ||"..trackingString)
    return luaTable, jsonString
end

function UrlifyNameField (object)
    local nameField = string.splitUsingFind(object.getName(),"\n")

    local cardName = UrlifyCardName(nameField[1])
    return cardName
end

function UrlifyCardName (cardName)
    if cardName == nil or cardName == "" then return "" end
    local dfcNameIndex = cardName:find("%s?//")
    if dfcNameIndex ~= nil then cardName = cardName:sub(1, dfcNameIndex-1) end

    cardName = cardName:gsub("%[.-%]",""):lower()
    cardName = cardName:gsub("[,%']","")
    cardName = cardName:gsub("%s","-")
    return cardName
end

function AutoActivate(dataTable)
    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        if enc.call("APIpropertyExists",{propID = pID}) == false then
            return
        
        elseif enc.call("APIobjectExists", {obj=dataTable.obj}) ~= nil then
            local encData = enc.call("APIobjGetPropData",{obj=dataTable.obj,propID=pID})
            local data = encData["tyrantUnified"]

            if data ~= nil and data.hasStats ~= nil then return data end

            if enc.call("APIobjIsPropEnabled", {obj=dataTable.obj, propID = pID}) == false then
                enc.call("APIobjEnableProp",{obj=dataTable.obj, propID = pID})

                ParseCardData(dataTable.obj, enc)

                enc.call("APIrebuildButtons",{obj=dataTable.obj})
                return data
            end
        end
    end
end

function InitializeCardData(object, enc)
    FetchScryfallData(object)
    TryAssignOwnership(object, enc)

    local dataTable = {object = object, enc = enc, GUID = object.getGUID()}
    if object.getName() == "" then ParseCardData(dataTable) return end
    Timer.destroy(object.getGUID().."parseTimer")
    Timer.create({
        identifier = object.getGUID().."parseTimer",
        function_name = "TryTimedParse",
        function_owner = self,
        parameters = dataTable,
        delay = 0.5,
        repetitions = 60
    })
end

function TryAssignOwnership(object, enc)
    local cardTable = CheckGetSetCardTable(object)
    local ownerColor = cardTable.ownerColor ~= "" and cardTable.ownerColor or (cardTable.containerID ~= "" and deckPlayerPairs[cardTable.containerID] or nil)

    local encData = enc.call("APIobjGetPropData",{obj = object, propID = pID})
    local data = encData["tyrantUnified"]

    if ownerColor ~= nil and ownerColor  ~= "" then
        data.ownerColor = ownerColor
        data.controllerColor = ownerColor
    end
    
    data.displayOwnership = autoActivateOwnership

    encData["tyrantUnified"] = data
    enc.call("APIobjSetPropData",{obj = object, propID = pID, data = encData})
end

function TryTimedParse(dataTable)
    if dataTable.object == nil then --nil check for when objects are deleted or grouped while waiting for parsing
        Timer.destroy(dataTable.GUID.."parseTimer")
        return
    end
    
    urlifiedName = UrlifyNameField(dataTable.object)
    if scryfallCardCache[urlifiedName] ~= nil then
        Timer.destroy(dataTable.GUID.."parseTimer")
        dataTable["nameUrlified"] = urlifiedName

        ParseCardData(dataTable)
    end
end

--Deck Tracking Functions
deckCandidateTracker = {}
deckPlayerPairs = {}
function InitializeDeckTables()
    local colorList = Color.list

    for key, value in pairs(colorList) do
        deckCandidateTracker[value] = {}
    end
end

function onObjectLeaveContainer (container, object)
    if object.tag ~= "Card" then return end
    local containerTable = CheckGetSetContainerTable(container)
    CheckGetSetCardTable(object, containerTable)
end

function onObjectEnterContainer(container, object)
    if container.getTable("tyrantUnified") ~= nil or object.getTable("tyrantUnified") == nil then return end
    if object.tag ~= "Card" and object.tag ~= "Container" then return end

    local sourceTable = CheckGetSetCardTable(object, nil)
    local dataTable = {sourceTable = sourceTable, object = container}
    
    Timer.destroy(container.getGUID().."setDataTimer")
    Timer.create({
        identifier = container.getGUID().."setDataTimer",
        function_name = "ResetDeckTable",
        function_owner = self,
        parameters = dataTable,
        delay = 1
    })
end

function ResetDeckTable(dataTable)
    dataTable.object.setTable("tyrantUnified", dataTable.sourceTable)
end

function CheckGetSetContainerTable (container)
    local containerTable = container.getTable("tyrantUnified")
    if containerTable == nil then
        containerData = container.getCustomObject()
        containerTable = {cardBack = "", frontFace = "", backFace = "", containerID = container.guid, ownerColor = ""}
        containerTable["frontFace"] = containerData["front"] ~= nil and containerData["front"] or ""
        container.setTable("tyrantUnified", containerTable)
    end
    return containerTable
end

function CheckGetSetCardTable (card, containerTable)
    local cardTable = card.getTable("tyrantUnified")
    if cardTable == nil then
        cardData = card.getCustomObject()
        cardTable = {cardBack = "", frontFace = "", backFace = "", containerID = "", ownerColor = ""}
        cardTable["frontFace"] = cardData["front"] ~= nil and cardData["front"] or ""
        cardTable["backFace"] = cardData["back"] ~= nil and cardData["back"]or "" 
    end

    if containerTable ~= nil then
        cardTable.cardBack = containerTable.cardBack
        cardTable.containerID = containerTable.containerID
        cardTable.ownerColor = containerTable.ownerColor
    end

    card.setTable("tyrantUnified", cardTable)
    return cardTable
end

function CheckInvertedFaces (card)
    local cardData = card.getCustomObject()
    local faceAddress = cardData["face"] ~= nil and cardData["face"] or ""
    local backAddress = cardData["back"] ~= nil and cardData["back"] or ""
    if faceAddress:find("/back/") and backAddress:find("/front/") then
        return true
        --broadcastToAll("[888888][EASY MODULES][-]\nInverted card faces detected & switched for "..card.getName():match("(.-)\n"))
    end
    return false
end

function InvertCardFaces (card)
    cardData = card.getCustomObject()
    initialFrontFace = cardData.face
    initialBackFace = cardData.back

    cardData.face = initialBackFace
    cardData.back = initialFrontFace

    card.setCustomObject(cardData)
    card.reload()
end

function onObjectEnterScriptingZone(zone, object)
    if object == nil or object.tag ~= "Card" then return end

    local enc = Global.getVar('Encoder')
    if enc ~= nil then
        local encoderZones
        --9 encoder update workarounds
        --9 encoder update workarounds
        --one week out, waiting around
        --10 encoder update workarounds
        local apiCheck = enc.getVar("APIlistZones")
        if apiCheck ~= nil then
            encoderZones = enc.call("APIlistZones",{})
        else
            encoderZones = enc.getTable("Zones")
        end
        
        if encoderZones[zone.getGUID()] ~= nil then
            local cardTable = CheckGetSetCardTable(object)
            local containerGUID = cardTable.containerID
            
            if containerGUID == nil or containerGUID == "" then return end

            local playerColor = encoderZones[zone.getGUID()].color
            if (deckCandidateTracker[playerColor][containerGUID]) ~= nil then
                deckCandidateTracker[playerColor][containerGUID].count = deckCandidateTracker[playerColor][containerGUID].count + 1;
                --jesus christ why does lua not have increment operators
            else
                deckCandidateTracker[playerColor][containerGUID] = {count = 1}
            end
            if deckCandidateTracker[playerColor][containerGUID].count == 7 then
                deck = getObjectFromGUID(containerGUID)
                --broadcastToAll("Deck set for ".."["..Color.fromString(playerColor):toHex(false).."]"..playerColor.."[-]")

                if deck ~= nil then
                    AddPlayerDeck(playerColor, containerGUID)
                end
            end
        end
    end
end

function AddPlayerDeck(playerColor, containerGUID)
    if deckPlayerPairs[containerGUID] ~= nil then
        deckCandidateTracker[deckPlayerPairs[containerGUID]][containerGUID].count = 0
    end
    deckPlayerPairs[containerGUID] = playerColor

    containerObject = getObjectFromGUID(containerGUID)
    if containerObject ~= nil then
        containerTable = CheckGetSetContainerTable(containerObject)
        containerTable.ownerColor = playerColor
        containerObject.setTable("tyrantUnified", containerTable)
    end
end

function DoNothing()
end

function ToBool(boolString)
    --the cheapest solution in the west
    local boolString = string.lower(tostring(boolString))
    --**taps forehead
    --if you turn it into a string first, then it will never be the wrong type for the conversion
    if boolString == "true" then return true
    else return false
    end
end