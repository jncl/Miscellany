local aName, aObj = ...
local _G = _G

_G.misc_sv_pc = _G.misc_sv_pc or {}

aObj.debug = false

aObj.isClsc       = _G.C_CVar.GetCVar("agentUID") == "wow_classic" and true
aObj.isClscPTR    = _G.C_CVar.GetCVar("agentUID") == "wow_classic_ptr" and true
aObj.isClscERA    = _G.C_CVar.GetCVar("agentUID") == "wow_classic_era" and true
aObj.isClscERAPTR = _G.C_CVar.GetCVar("agentUID") == "wow_classic_era_ptr" and true
aObj.isClsc       = aObj.isClsc or aObj.isClscPTR
aObj.isClscERA    = aObj.isClscERA or aObj.isClscERAPTR
aObj.isRtl        = _G.C_CVar.GetCVar("agentUID") == "wow" and true
aObj.isRtlPTR     = _G.C_CVar.GetCVar("agentUID") == "wow_ptr" and true
aObj.isRtlPTRX    = _G.C_CVar.GetCVar("agentUID") == "wow_ptr_x" and true
aObj.isRtlBeta    = _G.C_CVar.GetCVar("agentUID") == "wow_beta" and true
aObj.isRtl        = aObj.isRtl or aObj.isRtlPTR or aObj.isRtlPTRX or aObj.isRtlBeta

-- _G.print(aName, "ver", aObj.isClsc, aObj.isClscERA, aObj.isRtl)

-- store player class as English Spelling
aObj.uCls = _G.select(2, _G.UnitClass("player"))

-- out of combat table
aObj.oocTab = {}

function aObj.printD(_, ...)

	if not aObj.debug then return end
	_G.print(("%s [%s.%03d]"):format(aName, _G.date("%H:%M:%S"), (_G.GetTime() % 1) * 1000), ...)

end

local LibStub = _G.LibStub
-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in _G.pairs{"AceEvent-3.0", "AceHook-3.0", "CallbackHandler-1.0"} do
	assert(LibStub:GetLibrary(lib, true), aName .. " requires " .. lib)
end
aObj.ae = LibStub("AceEvent-3.0")
aObj.ah = LibStub("AceHook-3.0")
aObj.callbacks = LibStub:GetLibrary("CallbackHandler-1.0", true):New(aObj)

-- Slash Command List entries
aObj.SCL = {}
aObj.SCL["cbl"] = function()
	aObj:cbJostle()
	_G.print("Jostled ChocolateBar")
end
aObj.SCL["clrs"] = function()
	_G.print("showing RAID_CLASS_COLORS")
	for k, v in _G.pairs(_G.RAID_CLASS_COLORS) do
		v["name"] = k
		_G.print("RCC", v)
	end
end
aObj.SCL["debug"] = function()
	aObj.debug = not aObj.debug
	_G.print("Debug ", aObj.debug and "enabled" or "disabled")
end
aObj.SCL["esi"] = function()
	local esNum = _G.C_EquipmentSet.GetNumEquipmentSets()
	_G.print("GetNumEquipmentSets()", esNum)
	for i = 0, esNum - 1 do
		_G.print(i, _G.C_EquipmentSet.GetEquipmentSetInfo(i))
	end
end
aObj.SCL["locate"] = function()
	_G.print("You Are Here: [", _G.GetRealZoneText(), "][", _G.GetSubZoneText(), "][", _G.C_Map.GetBestMapForUnit("player"), "]")
end
aObj.SCL["mapinfo"] = function()
	local uiMapID = _G.C_Map.GetBestMapForUnit("player")
	local mapinfo = _G.C_Map.GetMapInfo(uiMapID)
	local posn = _G.C_Map.GetPlayerMapPosition(uiMapID, "player")
	local areaName= _G.MapUtil.FindBestAreaNameAtMouse(uiMapID, posn["x"], posn["y"])
	_G.print("Map Info:", mapinfo["mapID"], mapinfo["name"], mapinfo["mapType"], mapinfo["parentMapID"], posn["x"], posn["y"], areaName)
end
aObj.SCL["pcf1"] = function()
	_G.ProfessionsCrafterOrders_LoadUI()
	_G.ShowUIPanel(_G.ProfessionsCrafterOrdersFrame)
end
aObj.SCL["pcf2"] = function()
	_G.ProfessionsCustomerOrders_LoadUI()
	_G.ShowUIPanel(_G.ProfessionsCustomerOrdersFrame)
end
aObj.SCL["ssv"] = function()
	_G.Spew("m_sv_pc", _G.misc_sv_pc)
end

_G.SLASH_MISCELLANY1 = '/misc'
function _G.SlashCmdList.MISCELLANY(msg, _)

	local cmd1, cmd2 = (" "):split(msg)

	aObj:printD("slash command:", msg, cmd1, cmd2, aObj.SCL[cmd1])

	if #cmd1 > 0 then -- check for empty string
		if aObj.SCL[cmd1] then
			aObj.SCL[cmd1](aObj, cmd2)
		end
	end

end

-- track PLAYER_LOGIN event
aObj.ae.RegisterEvent(aName, "PLAYER_LOGIN", function(_, _)

	-- Add another loot button and move them all up to fit if FramesResized isn't loaded
	if not aObj.isRtl then
		if not _G.IsAddOnLoaded("FramesResized") then
			local yOfs, btn = -27
			for i = 1, _G.LOOTFRAME_NUMBUTTONS do
				btn = _G["LootButton" .. i]
				btn:ClearAllPoints()
				btn:SetPoint("TOPLEFT", 9, yOfs)
				yOfs = yOfs - 41
			end
			_G.CreateFrame("Button", "LootButton5", _G.LootFrame, "LootButtonTemplate")
			_G.LootButton5:SetPoint("TOPLEFT", 9, yOfs)
			_G.LootButton5.id = 5
			_G.LOOTFRAME_NUMBUTTONS = 5
		end
	else
		local aqw, aqp = 0, 0
		-- if not running AAP-Core then automatically watch quests & their progress
		if not _G.C_AddOns.IsAddOnLoaded("AAP-Core") then
			-- aObj:printD("autoQuest", _G.C_CVar.GetCVar("autoQuestWatch"), _G.C_CVar.GetCVar("autoQuestProgress"))
			aqw, aqp = 1, 1
		end
		-- automatically add quests id required
		_G.C_CVar.SetCVar("autoQuestWatch", aqw)
		-- automatically add quests when they're updated if required
		_G.C_CVar.SetCVar("autoQuestProgress", aqp)

		aObj:checkRemix()

		aObj:checkFlyingAreas()

	end

	-- FIXME: this is to fix a bug in AzeriteUtil.lua line 7
	-- if aObj.isRtl then
	-- 	_G.EQUIPPED_LAST = _G.INVSLOT_LAST_EQUIPPED
	-- end

	aObj.ae.UnregisterEvent(aName, "PLAYER_LOGIN")

end)

-- this is used to handle LoD addons
local trackedAddonsSeen = {
	[aName] = false,
	["Blizzard_PetJournal"] = false,
	["Blizzard_FlightMap"] = false,
	["Blizzard_DebugTools"] = false,
}
aObj.ae.RegisterEvent(aName, "ADDON_LOADED", function(_, addon)
	-- aObj:printD(event, addon)

	trackedAddonsSeen[addon] = true

	if addon == aName then
		-- N.B. Saved variables have now been loaded

		aObj.callbacks:Fire("AddOn_Loaded", addon)

		-- increase Max Zoom Factor
		_G.C_CVar.SetCVar("cameraDistanceMaxZoomFactor", 2.9)
		_G.MoveViewOutStart(50000)

	end

	-- filter sources to remove Promotion & Trading Card Game sources
	if addon == "Blizzard_PetJournal" then
		_G.C_PetJournal.SetPetSourceFilter(8, false) -- Promotion
		_G.C_PetJournal.SetPetSourceFilter(9, false) -- Trading Card Game
		_G.UIDropDownMenu_Refresh(_G.PetJournalFilterDropDown, 2, 2)
	end

	if addon == "Blizzard_FlightMap" then
		_G.FlightMapFrame:SetScale(1.25)
	end

	if addon == "Blizzard_DebugTools" then
		aObj:widenTAD()
	end

	if not _G.tContains(trackedAddonsSeen, false) then
		aObj.ae.UnregisterEvent(aName, "ADDON_LOADED")
	end

end)

-- resize TaxiFrame
_G.TaxiFrame:SetScale(1.5)

-- Only show Available skills at trainer
aObj.ae.RegisterEvent(aName, "TRAINER_SHOW", function(_)
	_G.C_Timer.After(0.005, function()
		_G.SetTrainerServiceTypeFilter("unavailable", false)
	end)
end)

local eventChecks, event, eTab = {
	[_G.SPELL_FAILED_NOT_MOUNTED]       = {func=_G.Dismount},
	[_G.ERR_TAXIPLAYERALREADYMOUNTED]   = {func=_G.Dismount},
	[_G.ERR_ATTACK_MOUNTED]             = {func=_G.Dismount},
	[_G.ERR_GUILD_WITHDRAW_LIMIT]       = {func=_G.RepairAllItems},
	[_G.SPELL_FAILED_NOT_STANDING]      = {func=_G.DoEmote, arg="Stand"},
	[_G.ERR_CANT_INTERACT_SHAPESHIFTED] = {func=_G.CancelShapeshiftForm},
}
-- handle UI error messages when required
aObj.ae.RegisterEvent(aName, "UI_ERROR_MESSAGE", function(_, ...)
	-- aObj:printD("UI_ERROR_MESSAGE", select(1, ...), select(2, ...))

	event = _G.select(2, ...)

	eTab = eventChecks[event]
	if eTab then
		eTab.func(eTab.arg)
	end

end)

-- move frame down if chocolate bar is loaded
if _G.C_AddOns.IsAddOnLoaded("ChocolateBar") then
	_G.UIWidgetTopCenterContainerFrame:SetPoint("TOP", 0, -25)
end

-- Close Chat Info popup
aObj.ah:SecureHookScript(_G.StaticPopup1, "OnShow", function(this)
	if this.which == "REGIONAL_CHAT_DISABLED" then
		this.button2:Click()
	end
end)

-- show minimap tracking frame
if not aObj.isRtl then
	_G.C_Timer.After(1, function()
		local icon = _G._G.GetTrackingTexture()
		if icon then
			_G.MiniMapTrackingIcon:SetTexture(icon)
			_G.MiniMapTracking:Show()
		end
	end)
end
