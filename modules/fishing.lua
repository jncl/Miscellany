local aName, aObj = ...
local _G = _G

local pairs, ipairs, select = _G.pairs, _G.ipairs, _G.select
local GetInventorySlotInfo, GetInventoryItemID, EquipItemByName, GetItemInfo = _G.GetInventorySlotInfo, _G.GetInventoryItemID, _G.EquipItemByName, _G.GetItemInfo
local GetCVarBool, SetCVar = _G.GetCVarBool, _G.SetCVar
-- SV's
local mhWeapon, ohWeapon, helmet = _G.mhWeapon, _G.ohWeapon, _G.helmet

local debug = false
local function printD(...)
	if not debug then return end
	_G.print(("%s [%s.%03d]"):format(aName, _G.date("%H:%M:%S"), (_G.GetTime() % 1) * 1000), ...)
end

-- Fishing Macros
local fishingPoles = {
	-- [6256]  = true,
	-- [12225] = true, -- Blump Family Family Pole
	-- [46337] = true,
	-- [84660] = true,
	-- [116825] = true,
	-- [116826] = true,
	-- [118381] = true, -- Ephemeral Fishing Pole (duration 1 day)
	[133755] = true, -- Underlight Angler
}
-- local exclFishingPoles = {
-- 	[6365]  = 10, -- Strong Fishing	Pole
-- 	[6366]  = 50, -- Darkword Fishing Pole
-- 	[6367]  = 100, -- Big Iron Fishing Pole
-- 	[19022] = 100, -- Nat Pagle's Extreme Angler FC-5000
-- 	[25978] = 200, -- Seth's Graphite Fishing Pole
-- 	[45858] = 225, -- Nat's Lucky Fishing Pole
-- 	[19970] = 300, -- Arcanite Fishing Pole
-- 	[44050] = 300, -- Mastercraft Kala'ak Fishing Pole
-- 	[45991] = 300, -- Bone Fishing Pole
-- 	[45992] = 300, -- Jeweled Fishing Pole
-- 	[84661] = 525, -- Dragon Fishing Pole
-- }
local fishingHats = {
	[19972] = true, -- Lucky Fishing Hat (+5 Fishing)
	[33820] = true, -- Weather-Beaten Fishing Hat (+5 Fishing) (Using this attaches a 10 min lure +75 Fishing)
	[88710] = true, -- Nat's Hat (+5 Fishing) (Using this attaches a 10 min lure +150 Fishing)
	[93732] = true, -- Darkmoon Fishing Cap (+5 Fishing)
	[118380] = true, -- Highfish Cap (+100 Fishing) (7 days duration)
	[118393] = true, -- Tentacled Hat (+100 Fishing) (5 days duration)
}
-- get fishing profession index
local fishingIdx, skillLevel = (select(4, _G.GetProfessions())), 0
printD("Fishing Profession index", fishingIdx)

local mhSlotId, ohSlotId, hSlotId = (GetInventorySlotInfo("MainHandSlot")), (GetInventorySlotInfo("SecondaryHandSlot")), (GetInventorySlotInfo("HeadSlot"))
printD("MainHand, OffHand, Head slot ids", mhSlotId, ohSlotId, hSlotId)

local function getSkillLvl()
	if fishingIdx then
		name, _, skillLevel = _G.GetProfessionInfo(fishingIdx)
		printD("Fishing: Name, Skill Level", name, skillLevel)
	end
end
-- local function chkExclFP()
-- 	printD("chkExclFP")
-- 	-- see if excluded fishing pole(s) can now be equipped
-- 	for fp, reqLvl in pairs(exclFishingPoles) do
-- 		local fpName = (select(1, GetItemInfo(fp)))
-- 		printD("exclFishingPoles", fp, reqLvl, skillLevel, fpName)
-- 		if fpName
-- 		and reqLvl <= skillLevel
-- 		then
-- 			printD("adding excluded Fishing Pole", fpName)
-- 			fishingPoles[fp] = true
-- 			_G.table.remove(exclFishingPoles, fp)
-- 		end
-- 	end
-- end
local fpEquipped = false
local function chkWeapons(mhItem)
	if not mhItem then mhItem = GetInventoryItemID("player", mhSlotId) end

	-- check to see if fishing rod already equipped
	if not fishingPoles[mhItem] then
		-- get current Weapon(s)
		mhWeapon, ohWeapon = mhItem
		if not aObj.isBeta then
			ohWeapon = _G.OffhandHasWeapon() and GetInventoryItemID("player", ohSlotId) or nil
		end
		printD("current weapons:", mhWeapon, ohWeapon)
		fpEquipped = false
	else
		fpEquipped = true
	end
end
local fhEquipped = false
local function chkHelmet(hsItem)
	if not hsItem then hsItem = GetInventoryItemID("player", hSlotId) end

	-- check to see if fishing hat already equipped
	if not fishingHats[hsItem] then
		if helmet ~= hsItem then
			helmet = hsItem
			printD("current helmet:", helmet)
		end
		fhEquipped = false
	else
		fhEquipped = true
	end
end

aObj.ae.RegisterEvent(aName .. "-fishing", "PLAYER_LOGIN", function(event, addon)

	printD("PLAYER_LOGIN")
	-- -- get current skill level
	-- getSkillLvl()
	-- -- see if any excluded Fishing Poles can be used
	-- chkExclFP()
	--
	-- -- handle skillups
	-- aObj.ae.RegisterEvent(aName, "SKILL_LINES_CHANGED", function(...)
	-- 	printD("SKILL_LINES_CHANGED")
	-- 	getSkillLvl()
	-- 	if skillLevel == 50
	-- 	or skillLevel == 100
	-- 	or skillLevel == 200
	-- 	or skillLevel == 225
	-- 	or skillLevel == 300
	-- 	or skillLevel == 525
	-- 	then
	-- 		chkExclFP()
	-- 	end
	-- end)

	-- track equipment changes
	aObj.ae.RegisterEvent(aName, "PLAYER_EQUIPMENT_CHANGED", function(event, invSlot, hasItem)
		printD("PLAYER_EQUIPMENT_CHANGED", event, invSlot, hasItem)

		local invItem = GetInventoryItemID("player", invSlot)

		if invSlot == hSlotId then chkHelmet(invItem) end
		if invSlot == mhSlotId
		or invSlot == ohSlotId
		then
			chkWeapons(invItem)
		end
	end)

	aObj.ae.UnregisterEvent(aName .. "-fishing", "PLAYER_LOGIN")

end)

function aObj:startFishing()

	if _G.InCombatLockdown() then
		aObj.oocTab[#aObj.oocTab + 1] = {self.startFishing, {nil}}
		return
	end

	chkWeapons()
	chkHelmet()

	-- Equip a fishing hat
	for fh, _ in pairs(fishingHats) do
		EquipItemByName(fh)
		if fhEquipped then break end
	end

	-- Equip a fishing rod
	for fp, _ in pairs(fishingPoles) do
		EquipItemByName(fp)
		if fpEquipped then break end
	end

	if not GetCVarBool("Sound_EnableAllSound") then
		-- enable Sound
		SetCVar("Sound_EnableAllSound", 1)
		SetCVar("Sound_EnableSFX", 1)
	end


end
function aObj:endFishing()

	if _G.InCombatLockdown() then
		aObj.oocTab[#aObj.oocTab + 1] = {self.endFishing, {nil}}
		return
	end

	-- check to see if fishing hat equipped
	if fishingHats[GetInventoryItemID("player", hSlotId)] then
		printD("endFishing, re-equipping Helmet", helmet)
		-- equip last used helmet
		EquipItemByName(helmet, hSlotId)
	end
	-- check to see if fishing rod equipped
	if fishingPoles[GetInventoryItemID("player", mhSlotId)] then
		printD("endFishing, re-equipping weapons", mhWeapon, ohWeapon)
		-- equip last used weapon(s)
		EquipItemByName(mhWeapon, mhSlotId)
		if _G.ohWeapon then EquipItemByName(ohWeapon, ohSlotId) end
	end

	-- disable sound
	SetCVar("Sound_EnableAllSound", 0)
	_G.AudioOptionsFrame_AudioRestart()

end
