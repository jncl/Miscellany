local aName, aObj = ...

local uCls = select(2, UnitClass("player"))

-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in pairs{"AceTimer-3.0", "AceEvent-3.0", "AceHook-3.0"} do
	assert(LibStub:GetLibrary(lib, true), aName.." requires "..lib)
end
local at, ae, ah = LibStub("AceTimer-3.0"), LibStub("AceEvent-3.0"), LibStub("AceHook-3.0")

-- track PLAYER_LOGIN event for EquipmentSet changes
ae.RegisterEvent(aName, "PLAYER_LOGIN", function(event, addon)
	-- change EquipmentSet when stealthed, based upon EventEquip function
	if uCls == "ROGUE"
	and GetNumEquipmentSets() > 0
	and GetEquipmentSetInfoByName("Stealth")
	then
		local function checkAndEquip(eSet)
			local sTime, eTime = select(5, UnitCastingInfo("player"))
			if eTime then -- casting in progress, equip after cast has finished, otherwise error and not equipped
				at:ScheduleTimer(function(eSet)
					EquipmentManager_EquipSet(eSet)
				end, (eTime - sTime) / 1000 + 0.1, eSet)
			else
				EquipmentManager_EquipSet(eSet)
			end
		end
		print(aName, "- Rogue's Stealth EquipmentSet detected")
		local curSet, shifted = "Normal", false
		ah:SecureHook("UseEquipmentSet", function(setName)
			if not shifted then curSet = setName end
		end)
		ae:RegisterEvent("UPDATE_SHAPESHIFT_FORM", function ()
			local name, active
			for i = 1, GetNumShapeshiftForms() do
				_, name, active = GetShapeshiftFormInfo(i)
				if active and GetEquipmentSetInfoByName(name) then
					shifted = true
					checkAndEquip(name) -- equip shapeshift set if it exists
					return
				end
			end
			shifted = false
			checkAndEquip(curSet) -- re-equip previous set
		end)
	end
	ae.UnregisterEvent(aName, "PLAYER_LOGIN")

end)

-- track ADDON_LOADED event for TradeSkillUI changes
ae.RegisterEvent(aName, "ADDON_LOADED", function(event, addon)
	if addon == "Blizzard_TradeSkillUI" then
		-- resize Tradeskill frame
		-- taken from FramesResized, credit to Elkano
		local frame
		for i = TRADE_SKILLS_DISPLAYED + 1, TRADE_SKILLS_DISPLAYED * 2 do
			frame = CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
			frame:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i - 1)], "BOTTOMLEFT")
		end
		local adj = TRADE_SKILLS_DISPLAYED * TRADE_SKILL_HEIGHT
		TRADE_SKILLS_DISPLAYED = TRADE_SKILLS_DISPLAYED * 2
		TradeSkillFrame:SetHeight(472 + adj)
		TradeSkillListScrollFrame:SetHeight(130 + adj)
		TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", 8, -(234 + adj))
		TradeSkillDetailScrollFrame:SetHeight(208)
		TradeSkillCancelButton:ClearAllPoints()
		TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -6, 6)
		ae.UnregisterEvent(aName, "ADDON_LOADED")
	end
end)

-- check for Blade Flurry buff, hide ShapeshiftBar
local check_for_bf, bfEvt
if uCls == "ROGUE" then
	function check_for_bf()
		b = UnitBuff("player", "Blade Flurry")
		if b then
			UIErrorsFrame:AddMessage("Disable Blade Flurry", 1.0, 0.0, 0.0, nil, 5)
			if not bfEvt then bfEvt = at:ScheduleRepeatingTimer(check_for_bf, 5) end
		else
			at:CancelTimer(bfEvt, true)
			bfEvt = nil
		end
	end
	-- hide ShapeshiftBar Frame
	ShapeshiftBarFrame.Show = function () end
	ShapeshiftBarFrame:Hide()
end

-- handle in Combat situations
local inCombat = InCombatLockdown()
ae.RegisterEvent(aName, "PLAYER_REGEN_DISABLED", function(...)
	inCombat = true
	UIErrorsFrame:AddMessage("YOU ARE UNDER ATTACK.", 1, 0, 0)
	SetCVar("nameplateShowEnemies", 1)
	-- equip "Normal" set if a fishing pole is equipped
	local mH = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
	if mH then
		local itemType = select(7, GetItemInfo(mH))
		if itemType == "Fishing Poles"
		and GetNumEquipmentSets() > 0
		then
			EquipmentManager_EquipSet("Normal")
		end
	end
	at:CancelTimer(bfEvt, true)
	bfEvt = nil
end)
ae.RegisterEvent(aName, "PLAYER_REGEN_ENABLED", function(...)
	inCombat = false
	UIErrorsFrame:AddMessage("Finished fighting.", 1, 1, 0)
	SetCVar("nameplateShowEnemies", 0)
	-- check for Blade Flurry if Rogue
	if uCls == "ROGUE" then check_for_bf() end
end)

-- Change Watch Frame font
WATCHFRAME_LINEHEIGHT = 12
WATCHFRAME_MULTIPLE_LINEHEIGHT = 21
WATCHFRAMELINES_FONTHEIGHT = 10;
WATCHFRAMELINES_FONTSPACING = (WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTHEIGHT) / 2
local function changeFont(line)
	local fontName, _, fontFlags = line.text:GetFont()
	line.text:SetFont(fontName, 10, fontFlags)
	line.dash:SetFont(fontName, 10, fontFlags)
end
for i = 1, #WatchFrame.lineCache.frames do
	changeFont(WatchFrame.lineCache.frames[i])
end
for i = 1, #WatchFrame.lineCache.usedFrames do
	changeFont(WatchFrame.lineCache.usedFrames[i])
end
ah:SecureHook(UIFrameCache, "GetFrame", function()
	for i = 1, #WatchFrame.lineCache.usedFrames do
		changeFont(WatchFrame.lineCache.usedFrames[i])
	end
end)

-- delete item from Bag if Alt+Right Clicked
ah:SecureHook("ContainerFrameItemButton_OnModifiedClick", function(self, button)
--    print("CFIB_OMC", self, button)
    if button == "RightButton"
    and IsAltKeyDown()
    then
        PickupContainerItem(self:GetParent():GetID(), self:GetID())
        DeleteCursorItem()
    end
end)

-- setup & populate groups for Auto-Bag
if IsAddOnLoaded("Auto-Bag") then
	print(aName, "- Auto-Bag detected, creating groups")

    AB_SEARCHGROUPS["AH_items"] = {}
    table.insert(AB_SEARCHGROUPS["AH_items"], "Pattern: *")
    table.insert(AB_SEARCHGROUPS["AH_items"], "Formula: *")
    table.insert(AB_SEARCHGROUPS["AH_items"], "Recipe: *")
    table.insert(AB_SEARCHGROUPS["AH_items"], "Schematic: *")
    table.insert(AB_SEARCHGROUPS["AH_items"], "Plans: *")
    table.insert(AB_SEARCHGROUPS["AH_items"], "Design: *")
    table.insert(AB_SEARCHGROUPS["AH_items"], "Technique: *")

    AB_SEARCHGROUPS["enchanter"] = {}
    table.insert(AB_SEARCHGROUPS["enchanter"], "* Dust")
    table.insert(AB_SEARCHGROUPS["enchanter"], "* Essence")
    table.insert(AB_SEARCHGROUPS["enchanter"], "* Shard")

    AB_SEARCHGROUPS["tailor"] = {}
    table.insert(AB_SEARCHGROUPS["tailor"], "* Cloth")
    table.insert(AB_SEARCHGROUPS["tailor"], "Runecloth")
    table.insert(AB_SEARCHGROUPS["tailor"], "Felcloth")
    table.insert(AB_SEARCHGROUPS["tailor"], "Bolt of *")

    AB_SEARCHGROUPS["miner"] = {}
    table.insert(AB_SEARCHGROUPS["miner"], "* Ore")
    table.insert(AB_SEARCHGROUPS["miner"], "* Stone")
    table.insert(AB_SEARCHGROUPS["miner"], "* Bar")

    AB_SEARCHGROUPS["skinner"] = {}
    table.insert(AB_SEARCHGROUPS["skinner"], "* Leather Scraps")
    table.insert(AB_SEARCHGROUPS["skinner"], "* Leather")
    table.insert(AB_SEARCHGROUPS["skinner"], "* Hide")
    table.insert(AB_SEARCHGROUPS["skinner"], "* Scale")

    AB_SEARCHGROUPS["digger"] = {}
    table.insert(AB_SEARCHGROUPS["digger"], "Dwarf Rune Stone")
    table.insert(AB_SEARCHGROUPS["digger"], "Highborne Scroll")
    table.insert(AB_SEARCHGROUPS["digger"], "Troll Tablet")
    table.insert(AB_SEARCHGROUPS["digger"], "Orc Blood Text") -- Skill >= 300
    table.insert(AB_SEARCHGROUPS["digger"], "Draenei Tome") -- Skill >=300
    table.insert(AB_SEARCHGROUPS["digger"], "Nerubian Obelisk") -- Skill >= 375
    table.insert(AB_SEARCHGROUPS["digger"], "Vrykul Rune Stick") -- Skill >= 375
    table.insert(AB_SEARCHGROUPS["digger"], "Tol'vir Hieroglyphic") -- Skill >= 450

    AB_SEARCHGROUPS["elementals"] = {}
    table.insert(AB_SEARCHGROUPS["elementals"], "Essence of *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Eternal *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Primal *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Mote of *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Crystallized *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Elemental *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Volatile *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Living Essence")
    table.insert(AB_SEARCHGROUPS["elementals"], "Breath of Wind")
    table.insert(AB_SEARCHGROUPS["elementals"], "Core of Earth")
    table.insert(AB_SEARCHGROUPS["elementals"], "Globe of Water")
    table.insert(AB_SEARCHGROUPS["elementals"], "Heart of Fire")
    table.insert(AB_SEARCHGROUPS["elementals"], "Heart of the Wild")
    table.insert(AB_SEARCHGROUPS["elementals"], "Ichor of Undeath")

    AB_SEARCHGROUPS["mage"] = {}
    table.insert(AB_SEARCHGROUPS["mage"], "Light feather")
    table.insert(AB_SEARCHGROUPS["mage"], "Conjured Mana *")
    table.insert(AB_SEARCHGROUPS["mage"], "Mana Gem")
    table.insert(AB_SEARCHGROUPS["mage"], "Rune of *")

    AB_SEARCHGROUPS["rogue"] = {}
    table.insert(AB_SEARCHGROUPS["rogue"], "* Poison")

    AB_SEARCHGROUPS["fish"] = {}
    table.insert(AB_SEARCHGROUPS["fish"], "Raw *")
    table.insert(AB_SEARCHGROUPS["fish"], "*Snapper")
    table.insert(AB_SEARCHGROUPS["fish"], "Oily *")
    table.insert(AB_SEARCHGROUPS["fish"], "*fish")
    table.insert(AB_SEARCHGROUPS["fish"], "Sharptooth")

    AB_SEARCHGROUPS["herbs"] = {}
    table.insert(AB_SEARCHGROUPS["herbs"], "Silverleaf")
    table.insert(AB_SEARCHGROUPS["herbs"], "Peacebloom")
    table.insert(AB_SEARCHGROUPS["herbs"], "Earthroot")
    table.insert(AB_SEARCHGROUPS["herbs"], "Mageroyal")
    table.insert(AB_SEARCHGROUPS["herbs"], "Briarthorn")
    table.insert(AB_SEARCHGROUPS["herbs"], "Swiftthistle")
    table.insert(AB_SEARCHGROUPS["herbs"], "Bruiseweed")
    table.insert(AB_SEARCHGROUPS["herbs"], "Stranglekelp")
    table.insert(AB_SEARCHGROUPS["herbs"], "Grave Moss")
    table.insert(AB_SEARCHGROUPS["herbs"], "Wild Steelbloom")
    table.insert(AB_SEARCHGROUPS["herbs"], "Kingsblood")
    table.insert(AB_SEARCHGROUPS["herbs"], "Liferoot")
    table.insert(AB_SEARCHGROUPS["herbs"], "Fadeleaf")
    table.insert(AB_SEARCHGROUPS["herbs"], "Goldthorn")
    table.insert(AB_SEARCHGROUPS["herbs"], "Khadgar's Whisker")
    table.insert(AB_SEARCHGROUPS["herbs"], "Dragon's Teeth")
    table.insert(AB_SEARCHGROUPS["herbs"], "Wildvine")
    table.insert(AB_SEARCHGROUPS["herbs"], "Firebloom")
    table.insert(AB_SEARCHGROUPS["herbs"], "Purple Lotus")
    table.insert(AB_SEARCHGROUPS["herbs"], "Arthas' Tears")
    table.insert(AB_SEARCHGROUPS["herbs"], "Sungrass")
    table.insert(AB_SEARCHGROUPS["herbs"], "Blindweed")
    table.insert(AB_SEARCHGROUPS["herbs"], "Ghost Mushroom")
    table.insert(AB_SEARCHGROUPS["herbs"], "Gromsblood")
    table.insert(AB_SEARCHGROUPS["herbs"], "Golden Sansam")
    table.insert(AB_SEARCHGROUPS["herbs"], "Dreamfoil")
    table.insert(AB_SEARCHGROUPS["herbs"], "Mountain Silversage")
    table.insert(AB_SEARCHGROUPS["herbs"], "Sorrowmoss")
    table.insert(AB_SEARCHGROUPS["herbs"], "Icecap")
    table.insert(AB_SEARCHGROUPS["herbs"], "Blood Scythe") -- used to collect Blood Vine from Zul'Gurub flora
    table.insert(AB_SEARCHGROUPS["herbs"], "Black Lotus")
    table.insert(AB_SEARCHGROUPS["herbs"], "Blood Vine")
    table.insert(AB_SEARCHGROUPS["herbs"], "Dreaming Glory") -- TBC onwards
    table.insert(AB_SEARCHGROUPS["herbs"], "Felweed")
    table.insert(AB_SEARCHGROUPS["herbs"], "Teracone")
    table.insert(AB_SEARCHGROUPS["herbs"], "Ragveil")
    table.insert(AB_SEARCHGROUPS["herbs"], "Flame Cap")
    table.insert(AB_SEARCHGROUPS["herbs"], "Ancient Lichen")
    table.insert(AB_SEARCHGROUPS["herbs"], "Fel Lotus")
    table.insert(AB_SEARCHGROUPS["herbs"], "Mana Thistle")
    table.insert(AB_SEARCHGROUPS["herbs"], "Nightmare Seed") -- WotLK onwards
    table.insert(AB_SEARCHGROUPS["herbs"], "Nightmare Vine")
    table.insert(AB_SEARCHGROUPS["herbs"], "Deadnettle")
    table.insert(AB_SEARCHGROUPS["herbs"], "Goldclover")
    table.insert(AB_SEARCHGROUPS["herbs"], "Talandra's Rose")
    table.insert(AB_SEARCHGROUPS["herbs"], "Tiger Lily")
    table.insert(AB_SEARCHGROUPS["herbs"], "Fire Leaf")
    table.insert(AB_SEARCHGROUPS["herbs"], "Adder's Tongue")
    table.insert(AB_SEARCHGROUPS["herbs"], "Frost Lotus")
    table.insert(AB_SEARCHGROUPS["herbs"], "Icethorn")
    table.insert(AB_SEARCHGROUPS["herbs"], "Lichbloom")
    table.insert(AB_SEARCHGROUPS["herbs"], "Cinderbloom") -- Cata onwards
    table.insert(AB_SEARCHGROUPS["herbs"], "Azshara's Veil")
    table.insert(AB_SEARCHGROUPS["herbs"], "Stormvine")
    table.insert(AB_SEARCHGROUPS["herbs"], "Heartblossom")
    table.insert(AB_SEARCHGROUPS["herbs"], "Whiptail")
    table.insert(AB_SEARCHGROUPS["herbs"], "Deathspore Pod")
    table.insert(AB_SEARCHGROUPS["herbs"], "Twilight Jasmine")


end

-- fix duplicate BugSack Minimap/Docking Station icons
if IsAddOnLoaded("BugSack") then
	if not BugSackLDBIconDB then BugSackLDBIconDB = {} end
	if IsAddOnLoaded("DockingStation") then
		BugSackLDBIconDB.hide = true -- turn off minimap icon
		LibStub("LibDBIcon-1.0", true):Hide("BugSack")
	else
		BugSackLDBIconDB.hide = false -- turn on minimap icon
		-- LibStub("LibDBIcon-1.0", true):Show("BugSack")
	end
end

-- resize TaxiFrame
TaxiFrame:SetScale(1.5)
-- resize MinimapCluster
MinimapCluster:SetScale(1.25)

-- Get Quest Info
SLASH_MISC1 = '/misc'

-- Cloth handin rep quests
clothQuests = {
	["Stormwind"] = {
		[7791] = "Wool",
		[7793] = "Silk",
		[7794] = "Mageweave",
		[7795] = "Runecloth",
		[7796] = "More Runecloth",
	},
	["Exodar"] = {
		[7792] = "Wool",
		[7798] = "Silk",
		[10356] = "Mageweave",
		[10357] = "Runecloth",
		[10358] = "More Runecloth",
	},
	["Ironforge"] = {
		[7802] = "Wool",
		[7803] = "Silk",
		[7804] = "Mageweave",
		[7805] = "Runecloth",
		[7806] = "More Runecloth",
	},
	["Gnomeregan"] = {
		[7807] = "Wool",
		[7808] = "Silk",
		[7809] = "Mageweave",
		[7811] = "Runecloth",
		[7812] = "More Runecloth",
	},
	["Darnassus"] = {
		[10352] = "Wool",
		[10354] = "Silk",
		[7799] = "Mageweave",
		[7800] = "Runecloth",
		[7810] = "More Runecloth",
	},
}
-- Chicken rescue quests
chickenQuests = {
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

local qTab, qType, loud, debug = {}
function SlashCmdList.MISC(msg, editbox)

	-- get Completed quest info
	if msg == "chicken"
	or msg == "cloth"
	then
		if debug then print("registering event") end
		ae.RegisterEvent(aName, "QUEST_QUERY_COMPLETE", function(...)
			if debug then print ("QUEST_QUERY_COMPLETE", ..., #...) end

			GetQuestsCompleted(qTab)
			if debug then print("No. Completed Quests", #qTab) end

			for k, v in ipairs(qType == "chicken" and chickenQuests or clothQuests) do
				print(k, qType, "quests:")
				for k2, v2 in ipairs(v) do
					if not qTab[k2] then
						print("==>", v2, "incomplete")
					else
						print("==>", v2, "completed")
					end
				end
			end

			ae.UnregisterEvent(aName, "QUEST_QUERY_COMPLETE")

		end)
		if debug then print("requesting completed quest info") end
		QueryQuestsCompleted()
		qType = msg
	elseif msg == "debug" then
		debug = not debug
	elseif msg == "loud" then
		loud = not loud
	end

	if debug then print(msg, editbox) end

end

-- ==> The following event actions are taken from Reactive Macros
local function __Msg(opts)

	if not loud and not opts.show then return end

	DEFAULT_CHAT_FRAME:AddMessage(aName..": "..opts.msg, opts.r, opts.g, opts.b)

end
function Msg(...)

	local opts = select(1, ...)

	-- handle missing message
	if not opts then return end

	if type(opts) == "string" then
		-- old style call
		opts = {}
		opts.msg = select(1, ...) and select(1, ...) or ""
		opts.r = select(2, ...) and select(2, ...) or nil
		opts.g = select(3, ...) and select(3, ...) or nil
		opts.b = select(4, ...) and select(4, ...) or nil
	end
	__Msg(opts)

end

-- AutoRepair by Ygrane, using GuildBank if available and in funds
ae.RegisterEvent(aName, "MERCHANT_SHOW", function(...)
	local gbMoney, repairAllCost, canRepair = GetGuildBankMoney(), GetRepairAllCost()
	if canRepair then RepairAllItems(repairAllCost <= gbMoney and CanGuildBankRepair() or nil) end
end)
-- Only show Available skills at trainer
ae.RegisterEvent(aName, "TRAINER_SHOW", function(...)
	SetTrainerServiceTypeFilter("unavailable", 0)
end)
-- Open/Close bags
ae.RegisterEvent(aName, "BANKFRAME_OPENED", function(...)
	OpenAllBags()
	-- ToggleAllBags()
end)
ae.RegisterEvent(aName, "BANKFRAME_CLOSED", function(...)
	CloseAllBags()
	-- ToggleAllBags()
end)
ae.RegisterEvent(aName, "GUILDBANKFRAME_OPENED", function(...)
	OpenAllBags()
	-- ToggleAllBags()
end)
-- AutoGossip by Ygrane -- Select only dialogue option unless shift key held down
ae.RegisterEvent(aName, "GOSSIP_SHOW", function(...)
	local o, p, q = GetGossipOptions()
	if o
	and not (q or IsShiftKeyDown() or GetGossipAvailableQuests() or GetGossipActiveQuests() or p == "binder")
	then
		Msg{msg="GS-Auto"..p.."["..(UnitName("target") or "?").."]: "..o, show=false}
		SelectGossipOption(1)
	end
	local o, p,_,_,_, q = GetGossipAvailableQuests()
	if o
	and not (q or IsShiftKeyDown() or GetGossipOptions() or GetGossipActiveQuests())
	then
		Msg{msg="GS-AutoNewQuest["..(UnitName("target") or "?").."]"..p..":"..o, show=false}
		SelectGossipAvailableQuest(1)
	end
	local o, p,_,_, q = GetGossipActiveQuests()
	if o
	and not (q or IsShiftKeyDown() or GetGossipOptions() or GetGossipAvailableQuests())
	then
		Msg{msg="GS-AutoCompleteQuest["..(UnitName("target") or "?").."]"..p..":"..o, show=false}
		SelectGossipActiveQuest(1)
	end
end)
-- Auto Accept Quest
ae.RegisterEvent(aName, "QUEST_DETAIL", function(...)
	if not IsShiftKeyDown()	then
		Msg{msg="AutoAcceptQuest["..(UnitName("target") or "?").."]: "..GetTitleText(), show=false}
		AcceptQuest()
	end
end)
-- Auto Progress Quest
ae.RegisterEvent(aName, "QUEST_PROGRESS", function(...)
	if IsQuestCompletable()
	and not IsShiftKeyDown()
	then
		Msg("AutoProgressQuest["..(UnitName("target") or "?").."]: "..GetTitleText())
		CompleteQuest()
	end
end)
-- Auto Complete Quest
ae.RegisterEvent(aName, "QUEST_COMPLETE", function(...)
	if GetNumQuestChoices() == 0
	and not IsShiftKeyDown()
	then
		Msg("AutoCompleteQuest["..(UnitName("target") or "?").."]: "..GetTitleText())
		QuestRewardCompleteButton_OnClick()
	end
end)
-- Toggle sound when equipping & unequipping 'Fishing' set
ae.RegisterEvent(aName, "EQUIPMENT_SWAP_FINISHED", function(...)
	local s = select(3, ...) == "Fishing" and 1 or 0
	SetCVar("Sound_EnableAllSound", s)
	if s == 0 then
		AudioOptionsFrame_AudioRestart()
		SetTracking(1, false) -- turn off fish tracking
	end
end)
ae.RegisterEvent(aName, "UI_ERROR_MESSAGE", function(...)
	if debug then print(select(1, ...), select(2, ...), IsFlying()) end
	-- dismount if required and not currently in flight
	if not IsFlying()
	and select(2, ...) == SPELL_FAILED_NOT_MOUNTED
	or select(2, ...) == ERR_TAXIPLAYERALREADYMOUNTED
	then
		Dismount()
	end
	-- handle no Guild Bank funds for repairs
	if select(2, ...) == ERR_GUILD_WITHDRAW_LIMIT then
		RepairAllItems()
	end
end)
