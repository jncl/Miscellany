local aName, Miscellany = ...

-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in pairs{"AceTimer-3.0", "AceEvent-3.0", "AceHook-3.0"} do
	assert(LibStub:GetLibrary(lib, true), aName.." requires "..lib)
end
local at, ae, ah = LibStub("AceTimer-3.0"), LibStub("AceEvent-3.0"), LibStub("AceHook-3.0")

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
-- track PLAYER_LOGIN event for EquipmentSet changes
ae.RegisterEvent(aName, "PLAYER_LOGIN", function(event, addon)
	-- change EquipmentSet when stealthed, based upon EventEquip function
	if select(2, UnitClass("player")) == "ROGUE"
	and GetNumEquipmentSets() > 0
	and GetEquipmentSetInfoByName("Stealth")
	then
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
		TradeSkillFrame:SetHeight(512 + adj)
		TradeSkillListScrollFrame:SetHeight(130 + adj)
		TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", 20, -(234 + adj))
		TradeSkillCreateButton:SetPoint("CENTER", TradeSkillCreateButton:GetParent(), "TOPLEFT", 224, -(422 + adj))
		TradeSkillCancelButton:SetPoint("CENTER", TradeSkillCancelButton:GetParent(), "TOPLEFT", 305, -(422 + adj))
		ae.UnregisterEvent(aName, "ADDON_LOADED")
	end
end)

-- change font size of Watch frame text
WATCHFRAME_LINEHEIGHT = 12
WATCHFRAMELINES_FONTHEIGHT = 10
WATCHFRAMELINES_FONTSPACING = (WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTHEIGHT) / 2
-- hook this to change font size on WatchFrame lines
ah:RawHook("WatchFrame_SetLine", function(line, ...)
	local fontName, _, fontFlags = line.text:GetFont()
	line.text:SetFont(fontName, 10, fontFlags)
	line.dash:SetFont(fontName, 10, fontFlags)
	return ah.hooks["WatchFrame_SetLine"](line, ...)
end, true)
