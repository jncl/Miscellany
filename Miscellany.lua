local aName, aObj = ...
local _G = _G

local assert, print, select, stringf, pairs = _G.assert, _G.print, _G.select, _G.string.format, _G.pairs
local CreateFrame, LibStub = _G.CreateFrame, _G.LibStub
local GetCVar, SetCVar, GetCVarBool = _G.GetCVar, _G.SetCVar, _G.GetCVarBool
-- SV's
local battle_pets = _G.battle_pets

aObj.debug = true

local function printD(...)
	if not aObj.debug then return end
	print(("%s [%s.%03d]"):format(aName, _G.date("%H:%M:%S"), (_G.GetTime() % 1) * 1000), ...)
end

-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in _G.pairs{"AceTimer-3.0", "AceEvent-3.0", "AceHook-3.0"} do
	assert(LibStub:GetLibrary(lib, true), aName .. " requires " .. lib)
end
aObj.ah = LibStub("AceHook-3.0")
aObj.at = LibStub("AceTimer-3.0")
aObj.ae = LibStub("AceEvent-3.0")

local buildInfo = {_G.GetBuildInfo()}
local portal = _G.GetCVar("portal") or nil

local uCls = select(2, _G.UnitClass("player"))

-- Chicken rescue quests
local chickenQuests = {
	["Tanaris"] = {
		[351] = "Find",
		[648] = "Rescue",
	},
	["Hinterlands"] = {
		[485] = "Find",
		[836] = "Rescue",
	},
	["Feralas"] = {
		[25475] = "Find",
		[25476] = "Rescue",
	},
}

_G.SLASH_MISC1 = '/misc'
local qTab, qType, loud = {}, nil, false
function SlashCmdList.MISC(msg, editbox)

	-- get Completed quest info
	if msg == "chicken"
	then
		-- printD("registering event")
		aObj.ae.RegisterEvent(aName, "QUEST_QUERY_COMPLETE", function(...)
			-- printD("QUEST_QUERY_COMPLETE", ..., #...)

			_G.GetQuestsCompleted(qTab)
			-- printD("No. Completed Quests", #qTab)

			for k, v in _G.ipairs(qType == "chicken" and chickenQuests) do
				print(k, qType, "quests:")
				for k2, v2 in _G.ipairs(v) do
					if not qTab[k2] then
						print("==>", v2, "incomplete")
					else
						print("==>", v2, "completed")
					end
				end
			end

			aObj.ae.UnregisterEvent(aName, "QUEST_QUERY_COMPLETE")

		end)
		-- printD("requesting completed quest info")
		_G.QueryQuestsCompleted()
		qType = msg
	elseif msg == "debug" then
		aObj.debug = not aObj.debug
		_G.print("Debug ", aObj.debug and "enabled" or "disabled")
	elseif msg == "loud" then loud = not loud
	elseif msg == "sf" then aObj:startFishing()
	elseif msg == "ef" then aObj:endFishing()
	elseif msg == "bpet" then battle_pets = not battle_pets
	-- MoP specific
	elseif msg == "tic" then aObj:timelessIsleChests()
	elseif msg == "itc" then aObj:isleOfThunderChests()
	elseif msg == "pt" then aObj:pandariaTreasures()
	elseif msg == "pl" then aObj:loreObjects()
	-- legion specific
	elseif msg == "lth" then aObj:checkLTQHighmountain()
	elseif msg == "ltq" then aObj:checkLTQ(msg)
	-- Jostle
	elseif msg == "cbj" then aObj:cbJostle()
		-- EquipmentSet info
	elseif msg == "esi" then
		local esNum = _G.C_EquipmentSet.GetNumEquipmentSets()
		_G.print("GetNumEquipmentSets()", esNum)
		for i = 0, esNum - 1 do
			_G.print(i, _G.C_EquipmentSet.GetEquipmentSetInfo(i))
		end
	-- enable Automatic Quest Tracking
	elseif msg == "atq_on" then
		_G.SetCVar("autoQuestWatch", 1)
		_G.ReloadUI()
	elseif msg == "atq_off" then
		_G.SetCVar("autoQuestWatch", 0)
		_G.ReloadUI()
	end
	-- printD("slash command:", msg, editbox)

end

-- ==> The following event actions are taken from Reactive Macros
local function __Msg(opts)

	if not aObj.debug
	or not loud and not opts.show
	then
		return
	end

	_G.DEFAULT_CHAT_FRAME:AddMessage(aName..": "..opts.msg, opts.r, opts.g, opts.b)

end
local function Msg(...)

	local opts = select(1, ...)

	-- handle missing message
	if not opts then return end

	if _G.type(opts) == "string" then
		-- old style call
		opts = {}
		opts.msg = select(1, ...) and select(1, ...) or ""
		opts.r = select(2, ...) and select(2, ...) or nil
		opts.g = select(3, ...) and select(3, ...) or nil
		opts.b = select(4, ...) and select(4, ...) or nil
	end
	__Msg(opts)

end

-- track PLAYER_LOGIN event for EquipmentSet changes
aObj.ae.RegisterEvent(aName, "PLAYER_LOGIN", function(event, addon)
	-- if a Hunter and in a Garrison then stop tracking Stable Masters
	if uCls == "HUNTER" then
		local function chgTracking(type, state)
			-- printD("chgTracking:", type, state)
			for i = 1, _G.GetNumTrackingTypes() do
				local name, texture, active, category, nested = _G.GetTrackingInfo(i)
				if type == name then
					-- printD("TrackingInfo:", i, name, texture, active, category, nested)
					if state ~= active then
						-- printD("Setting" .. name .. " tracking " .. (state and "on" or "off"))
						_G.SetTracking(i, state)
						break
					end
				end
			end
		end
		local function chkSM()
			local rZone = _G.GetRealZoneText()
			-- printD("chkSM:", rZone)
			if rZone == "Lunarfall" -- Alliance Garrison
			or rZone == "Frostwall" -- Horde Garrison
			then
				chgTracking("Stable Master", false)
			else
				chgTracking("Stable Master", true)
			end
		end
		aObj.ae.RegisterEvent(aName, "ZONE_CHANGED_NEW_AREA", function()
			-- printD("ZONE_CHANGED_NEW_AREA")
			chkSM()
		end)
		-- handle Garrison Heathstone into Town Hall
		aObj.ae.RegisterEvent(aName, "ZONE_CHANGED", function()
			-- printD("ZONE_CHANGED")
			chkSM()
		end)
		chkSM()
	end

	-- Add another loot button and move them all up to fit if FramesResized isn't loaded
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
		yOfs = nil
	end

	aObj.ae.UnregisterEvent(aName, "PLAYER_LOGIN")

end)

-- track PLAYER_LOGOFF to turn off sound
aObj.ae.RegisterEvent(aName, "PLAYER_LOGOFF", function(event, addon)
	-- disable sound
	SetCVar("Sound_EnableAllSound", 0)
	_G.AudioOptionsFrame_AudioRestart()
end)

-- this is used to handle LoD addons
local trackedAddonsSeen = {
	["Blizzard_TradeSkillUI"] = false,
	[aName] = false,
	["Blizzard_PetJournal"] = false,
	["Blizzard_FlightMap"] = false,
}
local allSeen = false
aObj.ae.RegisterEvent(aName, "ADDON_LOADED", function(event, addon)
	-- printD(event, addon)

	-- -- Pet Battle functions
	-- if addon == aName then
	-- 	trackedAddonsSeen[addon] = true
	-- 	if battle_pets then
	-- 		-- PetBattle health check
	-- 		aObj:checkPetHealth(nil, _G.GetTime())
	-- 	end
	-- end
	--
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

	if addon == "BugSack" then
		-- enable BugSack Minimap icon
		if _G.BugSack.healthCheck then
			_G.BugSackLDBIconDB.hide = false
			LibStub("LibDBIcon-1.0"):Show("BugSack")
		end
	end

	if addon == "ChocolateBar" then
		-- disable BugSack Minimap icon
		if _G.BugSack.healthCheck then
			_G.BugSackLDBIconDB.hide = true
			LibStub("LibDBIcon-1.0"):Hide("BugSack")
		end
	end

end)

-- handle in Combat situations
local inCombat = _G.InCombatLockdown()
aObj.ae.RegisterEvent(aName, "PLAYER_REGEN_DISABLED", function(...)
	-- printD("PLAYER_REGEN_DISABLED")
	-- _G.print("Miscellany - PLAYER_REGEN_DISABLED")
	inCombat = true
	_G.UIErrorsFrame:AddMessage("YOU ARE UNDER ATTACK.", 1, 0, 0)
	SetCVar("nameplateShowEnemies", 1)
	-- equip "Normal" set if a fishing pole is equipped
	local mH = 	_G.GetInventoryItemLink("player", _G.GetInventorySlotInfo("MainHandSlot"))
	if mH then
		local itemType = select(7, _G.GetItemInfo(mH))
		if itemType == "Fishing Poles"
		and _G.GetNumEquipmentSets() > 0
		then
			_G.EquipmentManager_EquipSet(1) -- Normal set
		end
	end
end)
aObj.oocTab = {}
aObj.ae.RegisterEvent(aName, "PLAYER_REGEN_ENABLED", function(...)
	-- printD("PLAYER_REGEN_ENABLED")
	inCombat = false
	_G.UIErrorsFrame:AddMessage("Finished fighting.", 1, 1, 0)
	SetCVar("nameplateShowEnemies", 0)
	for _, v in pairs(aObj.oocTab) do
		v[1](_G.unpack(v[2]))
	end
	_G.wipe(aObj.oocTab)
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

-- AutoRepair by Ygrane
-- Sell Junk by Tekkub
aObj.ae.RegisterEvent(aName, "MERCHANT_SHOW", function(...)
	-- repair gear using Guild funds if available
	local gbMoney, repairAllCost, canRepair = _G.GetGuildBankMoney(), _G.GetRepairAllCost()
	if canRepair then _G.RepairAllItems(repairAllCost <= gbMoney and _G.CanGuildBankRepair() or nil) end

	-- Sell Junk, blatantly copied from tekJunkSeller
	for bag = 0, 4 do
		for slot = 0, _G.GetContainerNumSlots(bag) do
			local link = _G.GetContainerItemLink(bag, slot)
			if link
			and select(3, _G.GetItemInfo(link)) == 0
			then
				-- wait a while to prevent 'that object is busy' message
				_G.C_Timer.After(0.3, function() _G.UseContainerItem(bag, slot) end)
			end
		end
	end
end)

-- Only show Available skills at trainer
aObj.ae.RegisterEvent(aName, "TRAINER_SHOW", function(...)
	_G.SetTrainerServiceTypeFilter("unavailable", 0)
end)

local ToggleAllBags, CloseAllBags = _G.ToggleAllBags, _G.CloseAllBags
-- Open/Close bags
aObj.ae.RegisterEvent(aName, "BANKFRAME_OPENED", function(...)
	-- printD("BANKFRAME_OPENED")
	ToggleAllBags()
end)
aObj.ae.RegisterEvent(aName, "BANKFRAME_CLOSED", function(...)
	-- printD("BANKFRAME_CLOSED")
	CloseAllBags()
end)
aObj.ae.RegisterEvent(aName, "GUILDBANKFRAME_OPENED", function(...)
	-- printD("GUILDBANKFRAME_OPENED")
	ToggleAllBags()
end)
aObj.ae.RegisterEvent(aName, "GUILDBANKFRAME_CLOSED", function(...)
	-- printD("GUILDBANKFRAME_CLOSED")
	CloseAllBags()
end)

local IsShiftKeyDown, UnitName, GetTitleText = _G.IsShiftKeyDown, _G.UnitName, _G.GetTitleText
local AcceptQuest, IsQuestCompletable, CompleteQuest, GetNumQuestChoices = _G.AcceptQuest, _G.IsQuestCompletable, _G.CompleteQuest, _G.GetNumQuestChoices
local GetGossipOptions, GetGossipAvailableQuests, GetGossipActiveQuests = _G.GetGossipOptions, _G.GetGossipAvailableQuests, _G.GetGossipActiveQuests
local SelectGossipOption, SelectGossipAvailableQuest, SelectGossipActiveQuest = _G.SelectGossipOption, _G.SelectGossipAvailableQuest, _G.SelectGossipActiveQuest
-- AutoGossip by Ygrane -- Select only dialogue option unless shift key held down
aObj.ae.RegisterEvent(aName, "GOSSIP_SHOW", function(...)
	-- printD("GOSSIP_SHOW")

	local o, p, q = GetGossipOptions()
	-- printD("GetGossipOptions", o, p, q)
	if o
	and not (q or IsShiftKeyDown() or GetGossipAvailableQuests() or GetGossipActiveQuests() or p == "binder")
	then
		Msg{msg="GS-Auto"..p.."[" .. (UnitName("target") or "?") .. "]: " .. o, show=false}
		SelectGossipOption(1)
	end
	-- Bodyguard dialog check
	if o
	and not IsShiftKeyDown()
	and (o:find("head back to the barracks.") or q and q:find("head back to the barracks."))
	then
		_G.CloseGossip()
	end
	-- Rogue OrderHall access check
	if o
	and not IsShiftKeyDown()
	and o:find("<Lay your insignia on the table.>")
	then
		SelectGossipOption(1)
	end

	local o, p,_,_,_, q = GetGossipAvailableQuests()
	-- printD("GetGossipAvailableQuests", o, p, q)
	if o
	and not (q or IsShiftKeyDown() or GetGossipOptions() or GetGossipActiveQuests())
	then
		Msg{msg="GS-AutoNewQuest[" .. (UnitName("target") or "?") .. "]" .. p .. ":" .. o, show=false}
		SelectGossipAvailableQuest(1)
	end

	local o, p,_,_, q = GetGossipActiveQuests()
	-- printD("GetGossipActiveQuests", o, p, q)
	if o
	and not (q or IsShiftKeyDown() or GetGossipOptions() or GetGossipAvailableQuests())
	then
		Msg{msg="GS-AutoCompleteQuest[" .. (UnitName("target") or "?") .. "]" .. p .. ":" .. o, show=false}
		SelectGossipActiveQuest(1)
	end
	-- -- Bodyguard additions
	-- if not IsControlKeyDown() then
	-- 	CheckForBodyGuard()
	-- end
end)
-- Auto Accept Quest
aObj.ae.RegisterEvent(aName, "QUEST_DETAIL", function(...)
	-- printD("QUEST_DETAIL")
	if not IsShiftKeyDown()	then
		Msg{msg="AutoAcceptQuest[" .. (UnitName("target") or "?") .. "]: " ..	GetTitleText(), show=false}
		AcceptQuest()
	end
end)
-- Auto Accept/Complete Multiple Quests
aObj.ae.RegisterEvent(aName, "QUEST_GREETING", function(...)
	-- printD("QUEST_GREETING", _G.GetNumAvailableQuests(), _G.GetNumActiveQuests())
	local numActiveQuests = _G.GetNumActiveQuests()
	local numAvailableQuests = _G.GetNumAvailableQuests()
	-- Complete Quests
	for i = 1, numActiveQuests do
		local _, isComplete = _G.GetActiveTitle(i)
		if isComplete
		and not IsShiftKeyDown()
		then
			_G.QuestTitleButton_OnClick(_G["QuestTitleButton" .. i], button, down)
		end
	end
	-- Accept Quests
	for i = numActiveQuests + 1, numActiveQuests + numAvailableQuests do
		if not IsShiftKeyDown()
		then
			_G.QuestTitleButton_OnClick(_G["QuestTitleButton" .. i], button, down)
		end
	end
end)
-- Auto Progress Quest
aObj.ae.RegisterEvent(aName, "QUEST_PROGRESS", function(...)
	-- printD("QUEST_PROGRESS")
	if IsQuestCompletable()
	and not IsShiftKeyDown()
	then
		Msg("AutoProgressQuest[" .. (UnitName("target") or "?") .. "]: " .. GetTitleText())
		CompleteQuest()
	end
end)
-- Auto Complete Quest
aObj.ae.RegisterEvent(aName, "QUEST_COMPLETE", function(...)
	-- printD("QUEST_COMPLETE", GetNumQuestChoices(), IsShiftKeyDown())
	if GetNumQuestChoices() < 2
	and not IsShiftKeyDown()
	then
		Msg("AutoCompleteQuest[" .. (UnitName("target") or "?") .. "]: " .. GetTitleText())
		_G.QuestRewardCompleteButton_OnClick()
		return
	end
end)

-- handle UI error messages when required
aObj.ae.RegisterEvent(aName, "UI_ERROR_MESSAGE", function(event, ...)
	-- printD(select(1, ...), select(2, ...))
	-- dismount if required
	if select(2, ...) == _G.SPELL_FAILED_NOT_MOUNTED
	or select(2, ...) == _G.ERR_TAXIPLAYERALREADYMOUNTED
	then
		_G.Dismount()
	end
	-- handle no Guild Bank funds for repairs
	if select(2, ...) == _G.ERR_GUILD_WITHDRAW_LIMIT then
		_G.RepairAllItems()
	end
	-- handle not standing when summoning pet etc.
	if select(2, ...) == _G.SPELL_FAILED_NOT_STANDING then
		_G.DoEmote("Stand")
	end
end)

-- Auto Accept Party Invites from known players
aObj.ae.RegisterEvent(aName, "PARTY_INVITE_REQUEST", function(event, name)
	-- printD("PARTY_INVITE_REQUEST", event, name)

	if not name == "Stabbly" then return end

	_G.AcceptGroup()
	for i = 1, _G.STATICPOPUP_NUMDIALOGS do
		local dlg = _G["StaticPopup"..i]
		if dlg.which == "PARTY_INVITE" then
			dlg.inviteAccepted = 1
			break
		end
	end
	_G.StaticPopup_Hide("PARTY_INVITE")

end)

-- set MaxLines for Debug chatframe
_G.ChatFrame10:SetMaxLines(10000)

-- turn on sound when CinematicFrame or MovieFrame shows
local seas
local function enableSound()

	seas = GetCVar("Sound_EnableAllSound")

	SetCVar("Sound_EnableAllSound", 1)
	SetCVar("Sound_EnableSFX", 0)
	_G.Sound_ToggleSound()

end
local function disableSound()

	SetCVar("Sound_EnableAllSound", seas)
	_G.Sound_ToggleSound()

end
local cbs, cbp
local function enableChatBubbles()

	-- print("Misc enableChatBubbles#1:", GetCVar("chatBubbles"), GetCVar("chatBubblesParty"))

	cbs = GetCVar("chatBubbles")
	cbp = GetCVar("chatBubblesParty")

	SetCVar("chatBubbles", 1)
	SetCVar("chatBubblesParty", 1)

	-- print("Misc enableChatBubbles#2:", GetCVar("chatBubbles"), GetCVar("chatBubblesParty"))

end
local function disableChatBubbles()

	-- print("Misc disableChatBubbles#1:", GetCVar("chatBubbles"), GetCVar("chatBubblesParty"))

	SetCVar("chatBubbles", cbs)
	SetCVar("chatBubblesParty", cbp)

	-- print("Misc disableChatBubbles#2:", GetCVar("chatBubbles"), GetCVar("chatBubblesParty"))

end
aObj.ae.RegisterEvent(aName, "CINEMATIC_START", function(event, ...)

	enableChatBubbles()
	enableSound()

end)
aObj.ae.RegisterEvent(aName, "CINEMATIC_STOP", function(event, ...)

	disableChatBubbles()
	disableSound()

end)
local mst = GetCVarBool("movieSubtitle")
aObj.ae.RegisterEvent(aName, "PLAY_MOVIE", function(event, ...)

	enableChatBubbles()
	enableSound()

	if not GetCVarBool("movieSubtitle") then
		SetCVar("movieSubtitle", 1)
		_G.MovieFrame:EnableSubtitles(GetCVarBool("movieSubtitle"))
	end

end)
aObj.ah:SecureHook("GameMovieFinished", function()

	disableChatBubbles()
	disableSound()

	if GetCVarBool("movieSubtitle")
	and GetCVarBool("movieSubtitle") ~= mst
	then
		SetCVar("movieSubtitle", mst)
		_G.MovieFrame:EnableSubtitles(mst)
	end

end)

function aObj:checkLTQ(questID)
	if _G.IsQuestFlaggedCompleted(questID) then
		-- print("LegionTreasure quest complete:", questID)
	else
		print("LegionTreasure quest incomplete:", questID)
	end
end

function aObj:checkLTQHighmountain()

	for _, q in pairs{39466,39494,39503,39531,39606,39766,39824,40471,40472,40473,40474,40475,40476,40477,40478,40479,40480,40481,40482,40483,40484,40487,40488,40489,40491,40493,40494,40496,40497,40498,40499,40500,40505,40506,40507,40508,40509,40510,42453,44279,44352,39507,44280} do
	-- for _, q in pairs{39507,44280} do
		aObj:checkLTQ(q)
	end
end

local ChocolateBar
function aObj:cbJostle()

	if _G.IsAddOnLoaded("ChocolateBar") then
		ChocolateBar = LibStub("AceAddon-3.0"):GetAddon("ChocolateBar", true)
		if ChocolateBar then
			ChocolateBar:UpdateJostle()
			ChocolateBar = nil
		end
	end

end
