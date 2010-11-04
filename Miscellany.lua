local aName, Miscellany = ...

-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in pairs{"AceTimer-3.0", "AceEvent-3.0", "AceHook-3.0"} do
	assert(LibStub:GetLibrary(lib, true), aName.." requires "..lib)
end
local at, ae, ah = LibStub("AceTimer-3.0"), LibStub("AceEvent-3.0"), LibStub("AceHook-3.0")

-- track PLAYER_LOGIN event for EquipmentSet changes
ae.RegisterEvent(aName, "PLAYER_LOGIN", function(event, addon)
	-- change EquipmentSet when stealthed, based upon EventEquip function
	if select(2, UnitClass("player")) == "ROGUE"
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
		TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", 20, -(234 + adj))
		TradeSkillDetailScrollFrame:SetHeight(208)
		TradeSkillCancelButton:ClearAllPoints()
		TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -6, 6)
		ae.UnregisterEvent(aName, "ADDON_LOADED")
	end
end)

--	TODO this causes taint in PTR/Beta
-- change font size of Watch frame text
-- hook this to change font size on WatchFrame lines
ah:RawHook("WatchFrame_SetLine", function(line, anchor, verticalOffset, ...)
	local vOfs = math.ceil(verticalOffset)
--		print("WF_SL:", line:GetHeight(), line.text:GetHeight())
	local fontName, _, fontFlags = line.text:GetFont()
	line.text:SetFont(fontName, 10, fontFlags)
	line.dash:SetFont(fontName, 10, fontFlags)
	if vOfs == 2 then verticalOffset = 1 end
	line:SetHeight(12)
	-- run the function
	ah.hooks["WatchFrame_SetLine"](line, anchor, verticalOffset, ...)
--		print("WF_SL#2:", line:GetHeight(), line.text:GetHeight())
end, true)

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

    AB_SEARCHGROUPS["miner"] = {}
    table.insert(AB_SEARCHGROUPS["miner"], "* Ore")
    table.insert(AB_SEARCHGROUPS["miner"], "* Stone")
    table.insert(AB_SEARCHGROUPS["miner"], "* Bar")

    AB_SEARCHGROUPS["skinner"] = {}
    table.insert(AB_SEARCHGROUPS["skinner"], "* Leather Scraps")
    table.insert(AB_SEARCHGROUPS["skinner"], "* Leather")
    table.insert(AB_SEARCHGROUPS["skinner"], "* Hide")
    table.insert(AB_SEARCHGROUPS["skinner"], "* Scale")

    AB_SEARCHGROUPS["elementals"] = {}
    table.insert(AB_SEARCHGROUPS["elementals"], "Essence of *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Eternal *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Primal *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Mote of *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Crystallized *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Elemental *")
    table.insert(AB_SEARCHGROUPS["elementals"], "Living Essence")
    table.insert(AB_SEARCHGROUPS["elementals"], "Breath of Wind")
    table.insert(AB_SEARCHGROUPS["elementals"], "Core of Earth")
    table.insert(AB_SEARCHGROUPS["elementals"], "Globe of Water")
    table.insert(AB_SEARCHGROUPS["elementals"], "Heart of Fire")
    table.insert(AB_SEARCHGROUPS["elementals"], "Heart of the Wild")
    table.insert(AB_SEARCHGROUPS["elementals"], "Ichor of Undeath")

end

-- fix duplicate BugSack Minimap/Docking Station icons
if IsAddOnLoaded("BugSack") then
	if not BugSackLDBIconDB then BugSackLDBIconDB = {} end
	if IsAddOnLoaded("DockingStation") then
		BugSackLDBIconDB.hide = true -- turn off minimap icon
		LibStub("LibDBIcon-1.0", true):Hide("BugSack")
	else
		BugSackLDBIconDB.hide = false -- turn on minimap icon
		LibStub("LibDBIcon-1.0", true):Show("BugSack")
	end
end
