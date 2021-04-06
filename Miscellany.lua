local aName, aObj = ...
local _G = _G

local assert, print, select, stringf, pairs = _G.assert, _G.print, _G.select, _G.string.format, _G.pairs
local CreateFrame, LibStub = _G.CreateFrame, _G.LibStub

aObj.isClsc = _G.GetCVar("agentUID"):find("_classic") and true

aObj.debug = false

-- out of combat table
aObj.oocTab = {}

function aObj:printD(...)
	if not aObj.debug then return end
	print(("%s [%s.%03d]"):format(aName, _G.date("%H:%M:%S"), (_G.GetTime() % 1) * 1000), ...)
end
local printD = aObj.printD

-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in _G.pairs{"AceEvent-3.0", "AceHook-3.0"} do
	assert(LibStub:GetLibrary(lib, true), aName .. " requires " .. lib)
end
aObj.ah = LibStub("AceHook-3.0")
aObj.ae = LibStub("AceEvent-3.0")

local uCls = select(2, _G.UnitClass("player"))

_G.SLASH_MISC1 = '/misc'
aObj.loud = false
function SlashCmdList.MISC(msg, editbox)

	local cmds = { (" "):split(msg) }

	-- get Completed quest info
	if msg == "chicken" then aObj:chickenQuests()
	elseif msg == "debug" then
		aObj.debug = not aObj.debug
		_G.print("Debug ", aObj.debug and "enabled" or "disabled")
	elseif msg == "loud" then aObj.loud = not aObj.loud
	elseif msg == "sf" then aObj:startFishing()
	elseif msg == "ef" then aObj:endFishing()
	elseif msg == "bpet" then _G.battle_pets = not _G.battle_pets
	-- MoP specific
	elseif msg == "tic" then aObj:timelessIsleChests()
	elseif msg == "itc" then aObj:isleOfThunderChests()
	elseif msg == "pt" then aObj:pandariaTreasures()
	elseif msg == "pl" then aObj:loreObjects()
	-- legion specific
	elseif msg == "lth" then aObj:checkLTQHighmountain()
	elseif msg == "ltq" then aObj:checkLTQ(msg)
	-- BfA
	elseif msg == "ait" then aObj:alpacaItUp()
	elseif msg == "eq" then aObj:elusiveQuickhoof()
	elseif msg == "lib" then aObj:lessonsInBrigandry()
	elseif msg == "plp" then aObj:plunderThePlunderers()
	elseif msg == "tftd" then aObj:TerrorsFromTheDeep()
	elseif msg == "tskc" then aObj:TheSunKingsChosen()
	-- Jostle
	elseif msg == "cbj" then aObj:cbJostle(cmds[2])
		-- EquipmentSet info
	elseif msg == "esi" then
		local esNum = _G.C_EquipmentSet.GetNumEquipmentSets()
		_G.print("GetNumEquipmentSets()", esNum)
		for i = 0, esNum - 1 do
			_G.print(i, _G.C_EquipmentSet.GetEquipmentSetInfo(i))
		end
	-- enable Automatic Quest Tracking
	elseif cmds[1] == "clrs" then
		_G.print("showing RAID_CLASS_COLORS")
		for k, v in pairs(_G.RAID_CLASS_COLORS) do
			v["name"] = k
			_G.print("RCC", v)
		end
	elseif cmds[1] == "aq" then
		-- _G.print("Miscellany: autoQuest settings", _G.GetCVar("autoQuestWatch"), _G.GetCVar("autoQuestProgress"))
		_G.autoquests = not _G.autoquests
		_G.print("Miscellany autoquests setting:", _G.autoquests)
		aObj:autoQuests()
	elseif msg:lower() == "locate" then
		print("You Are Here: [", _G.GetRealZoneText(), "][", _G.GetSubZoneText(), "][", _G.C_Map.GetBestMapForUnit("player"), "]")
	elseif msg:lower() == "mapinfo" then
		local uiMapID = _G.C_Map.GetBestMapForUnit("player")
		local mapinfo = _G.C_Map.GetMapInfo(uiMapID)
		local posn = _G.C_Map.GetPlayerMapPosition(uiMapID, "player")
		local areaName= _G.MapUtil.FindBestAreaNameAtMouse(uiMapID, posn["x"], posn["y"])
		print("Map Info:", mapinfo["mapID"], mapinfo["name"], mapinfo["mapType"], mapinfo["parentMapID"], posn["x"], posn["y"], areaName)

	elseif msg == "dcf" then aObj:AddDebugChatFrame()
	end
	-- printD("slash command:", msg, editbox)

end

-- track PLAYER_LOGIN event
aObj.ae.RegisterEvent(aName, "PLAYER_LOGIN", function(event, addon)

	-- Add another loot button and move them all up to fit if FramesResized isn't loaded
	if not _G.IsAddOnLoaded("FramesResized") then
		local yOfs, btn = -27
		for i = 1, _G.LOOTFRAME_NUMBUTTONS do
			btn = _G["LootButton" .. i]
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", 9, yOfs)
			yOfs = yOfs - 41
		end
		if not aObj.isClsc then
			_G.CreateFrame("ItemButton", "LootButton5", _G.LootFrame, "LootButtonTemplate")
		else
			_G.CreateFrame("Button", "LootButton5", _G.LootFrame, "LootButtonTemplate")
		end
		_G.LootButton5:SetPoint("TOPLEFT", 9, yOfs)
		_G.LootButton5.id = 5
		_G.LOOTFRAME_NUMBUTTONS = 5
		yOfs = nil
	end

	if not aObj.isClsc then
		-- if not running AAP-Core then automatically watch quests & their progress
		if not _G.IsAddOnLoaded("AAP-Core") then
			-- printD("autoQuest", _G.GetCVar("autoQuestWatch"), _G.GetCVar("autoQuestProgress"))
			-- automatically add quests to watch frame
			_G.SetCVar("autoQuestWatch", 1)
			-- automatically add quests to watch frame when they're updated
			_G.SetCVar("autoQuestProgress", 1)
			-- printD("autoQuest#2", _G.GetCVar("autoQuestWatch"), _G.GetCVar("autoQuestProgress"))
		else
			-- don't automatically add quests to watch frame
			_G.SetCVar("autoQuestWatch", 0)
			-- don't automatically add quests to watch frame when they're updated
			_G.SetCVar("autoQuestProgress", 0)
		end
	end

	aObj.ae.UnregisterEvent(aName, "PLAYER_LOGIN")

end)

-- this is used to handle LoD addons
local trackedAddonsSeen = {
	[aName] = false,
	["Blizzard_PetJournal"] = false,
	["Blizzard_FlightMap"] = false,
}
local allSeen = false
aObj.ae.RegisterEvent(aName, "ADDON_LOADED", function(event, addon)
	-- aObj:printD(event, addon)

	-- -- Pet Battle functions
	-- if addon == aName then
	-- 	trackedAddonsSeen[addon] = true
	-- 	if battle_pets then
	-- 		-- PetBattle health check
	-- 		aObj:checkPetHealth(nil, _G.GetTime())
	-- 	end
	-- end
	--

	if addon == aName then
		trackedAddonsSeen[addon] = true

		-- battle_pets, mhWeapon, ohWeapon, helmet, autoquests
		-- aObj:printD("AL#1", _G.battle_pets, _G.mhWeapon, _G.ohWeapon, _G.helmet, _G.autoquests)

		if _G.autoquests == nil then
			_G.autoquests = false
		end
		-- aObj:printD("AutoQuest setting", _G.autoquests)
		-- enable Auto Quests functions
		if _G.autoquests then aObj:autoQuests() end

		-- increase Max Zoom Factor
		_G.SetCVar("cameraDistanceMaxZoomFactor", 2.9)
		_G.MoveViewOutStart(50000)
	end

	-- -- show BugSack minimap icon if required
	-- if addon == aName then
	-- 	local li = LibStub:GetLibrary("LibDBIcon-1.0", true)
	-- 	if li then
	-- 		if _G.IsAddOnLoaded("ChocolateBar") then
	-- 			li:Hide("BugSack")
	-- 			_G.BugSackLDBIconDB.hide = true
	-- 		else
	-- 			li:Show("BugSack")
	-- 			_G.BugSackLDBIconDB.hide = false
	-- 		end
	-- 	end
	-- 	li  = nil
	-- end

	-- filter sources to remove Promotion & Trading Card Game sources
	if addon == "Blizzard_PetJournal" then
		trackedAddonsSeen[addon] = true
		_G.C_PetJournal.SetPetSourceFilter(8, false) -- Promotion
		_G.C_PetJournal.SetPetSourceFilter(9, false) -- Trading Card Game
		_G.UIDropDownMenu_Refresh(_G.PetJournalFilterDropDown, 2, 2)
	end

	if addon == "Blizzard_FlightMap" then
		trackedAddonsSeen[addon] = true
		_G.FlightMapFrame:SetScale(1.25)
	end

	for _, seen in pairs(trackedAddonsSeen) do
		if not seen then allSeen = false end
	end
	if allSeen then
		aObj.ae.UnregisterEvent(aName, "ADDON_LOADED")
	end


end)

-- delete item from Bag if Alt+Right Clicked
aObj.ah:SecureHook("ContainerFrameItemButton_OnModifiedClick", function(self, button)

    if button == "RightButton"
    and _G.IsAltKeyDown()
    then
        _G.PickupContainerItem(self:GetParent():GetID(), self:GetID())
        _G.DeleteCursorItem()
    end

end)

-- resize TaxiFrame
_G.TaxiFrame:SetScale(1.5)

-- Only show Available skills at trainer
aObj.ae.RegisterEvent(aName, "TRAINER_SHOW", function(...)

	_G.SetTrainerServiceTypeFilter("unavailable", 0)

end)

-- handle UI error messages when required
aObj.ae.RegisterEvent(aName, "UI_ERROR_MESSAGE", function(event, ...)

	aObj:printD(select(1, ...), select(2, ...))

	-- dismount if required
	if select(2, ...) == _G.SPELL_FAILED_NOT_MOUNTED
	or select(2, ...) == _G.ERR_TAXIPLAYERALREADYMOUNTED
	or select(2, ...) == _G.ERR_ATTACK_MOUNTED
	-- or select(2, ...) == "Can't attack while mounted."
	-- unmount when attacking
	then
		_G.Dismount()
	-- handle no Guild Bank funds for repairs
	elseif select(2, ...) == _G.ERR_GUILD_WITHDRAW_LIMIT then
		_G.RepairAllItems()
	-- handle not standing when summoning pet etc.
	elseif select(2, ...) == _G.SPELL_FAILED_NOT_STANDING then
		_G.DoEmote("Stand")
	-- handle shapeshift form, Druid
	-- elseif select(2, ...) == _G.ERR_CANT_INTERACT_SHAPESHIFTED
	-- or select(2, ...) == _G.ERR_CANT_INTERACT_SHAPESHIFTED
	-- then
	-- 	-- CancelShapeshiftForm()
	end
	-- handle mounted when attacking

end)
