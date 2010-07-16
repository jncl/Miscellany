local aName, Miscellany = ...

-- DB defaults
local defaultVars = {
	debug = false, -- toggle for debugging
}
MiscellanyDB = MiscellanyDB or defaultVars
Miscellany.db = MiscellanyDB

local debug = true -- toggle for debugging

-- check to see if required libraries are loaded
assert(LibStub, aName.." requires LibStub")
for _, lib in pairs{"AceEvent-3.0", "AceHook-3.0"} do
	assert(LibStub:GetLibrary(lib, true), aName.." requires "..lib)
end
local ae, ah = LibStub("AceEvent-3.0"), LibStub("AceHook-3.0")

-- Misc functions here
local function resizeTradeSkillFrame()

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
	
end

-- Watch frame font size change
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

-- Change Equipment when stealthed, based upon EventEquip function
if select(2, UnitClass("player")) == "ROGUE"
and GetNumEquipmentSets() > 0
then
	local curSet, shifted = "Normal", false
	hooksecurefunc("UseEquipmentSet", function(setName)
		if not shifted then curSet = setName end
	end)
	ae:RegisterEvent("UPDATE_SHAPESHIFT_FORM", function ()
		local name, active
		for i = 1, GetNumShapeshiftForms() do
			_, name, active = GetShapeshiftFormInfo(i)
			if active and GetEquipmentSetInfoByName(name) then
				shifted = true
				EquipmentManager_EquipSet(name) -- equip shapeshift set if it exists
				return
			end
		end
		shifted = false
		EquipmentManager_EquipSet(curSet) -- re-equip previous set
	end)
end

-- track ADDON_LOADED event
ae.RegisterEvent(aName, "ADDON_LOADED", function(event, addon)
	if addon == aName then -- wait for addon to load before getting SV's
		MiscellanyDB = MiscellanyDB or defaultVars Miscellany.db = MiscellanyDB
	elseif addon == "Blizzard_TradeSkillUI" then
		resizeTradeSkillFrame()
		ae.UnregisterEvent(aName, "ADDON_LOADED")
	end
end)

-- define slash command
SLASH_BUYIT1 = "/misc"
function SlashCmdList.MISCELLANY(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "dbg" then
		Miscellany.db.debug = not Miscellany.db.debug
		print(aName, "debugging mode:", Miscellany.db.debug)
	elseif command == "show" then
		print("debug:", Miscellany.db.debug)
	end
end

