local aName, aObj = ...
local _G = _G

-- Fishing Macros
local fishingPoles = {
	6256, -- Fishing Pole (sold by vendors)
	12225, -- Blump Family Family Pole
	180135, -- The Broken Angle'r [Shadowlands]
	-- [46337] = true,
	-- [84660] = true,
	-- [116825] = true,
	-- [116826] = true,
	-- [118381] = true, -- Ephemeral Fishing Pole (duration 1 day)
	-- [133755] = true, -- Underlight Angler
}
-- local fishingHats = {
-- 	19972, -- Lucky Fishing Hat (+5 Fishing)
-- 	33820, -- Weather-Beaten Fishing Hat (+5 Fishing) (Using this attaches a 10 min lure +75 Fishing)
-- 	88710, -- Nat's Hat (+5 Fishing) (Using this attaches a 10 min lure +150 Fishing)
-- 	93732, -- Darkmoon Fishing Cap (+5 Fishing)
-- 	118380, -- Highfish Cap (+100 Fishing) (7 days duration)
-- 	118393, -- Tentacled Hat (+100 Fishing) (5 days duration)
-- }
-- if aObj.isRtl then
-- 	-- get fishing profession index
-- 	local fishingIdx, _ = (_G.select(4, _G.GetProfessions())), 0
-- 	-- aObj:printD("Fishing Profession index", fishingIdx)
-- 	local function getSkillLvl()
-- 		if fishingIdx then
-- 			local name, _, skillLvl = _G.GetProfessionInfo(fishingIdx)
-- 			self:printD("Fishing: Name, Skill Level", name, skillLvl)
-- 		end
-- 	end
-- end

local mhSlotId, ohSlotId, hSlotId
local function getItemIds()
	mhSlotId = _G.GetInventorySlotInfo("MainHandSlot")
	ohSlotId = _G.GetInventorySlotInfo("SecondaryHandSlot")
	hSlotId  = _G.GetInventorySlotInfo("HeadSlot")
	_G.misc_sv_pc.mhWeapon = _G.GetInventoryItemID("player", mhSlotId)
	_G.misc_sv_pc.ohWeapon = _G.GetInventoryItemID("player", ohSlotId)
	_G.misc_sv_pc.helmet   = _G.GetInventoryItemID("player", hSlotId)
end
-- TODO: need to hook a function to track equipment changes

local fpEquipped = false
local function chkWeapons()
	local mhItem = _G.GetInventoryItemID("player", mhSlotId)
	local ohItem = _G.GetInventoryItemID("player", ohSlotId)

	-- check to see if fishing rod already equipped
	if not _G.tContains(fishingPoles, mhItem) then
		-- save current Weapon(s)
		_G.misc_sv_pc.mhWeapon, _G.misc_sv_pc.ohWeapon = mhItem, ohItem
		-- aObj:printD("current weapons:", _G.misc_sv_pc.mhWeapon, _G.misc_sv_pc.ohWeapon)
		fpEquipped = false
	else
		fpEquipped = true
	end
end
-- local fhEquipped = false
-- local function chkHelmet()
-- 	local hsItem = _G.GetInventoryItemID("player", hSlotId)

-- 	-- check to see if fishing hat already equipped
-- 	if not _G.tContains(fishingHats, hsItem) then
-- 		fhEquipped = false
-- 	else
-- 		fhEquipped = true
-- 	end
-- end

function aObj:startFishing()

	if _G.InCombatLockdown() then
		self.oocTab[#self.oocTab + 1] = {self.startFishing, {self}}
		return
	end

	if not self.isRtl then
		aObj.ae.RegisterEvent(aName .. "fishing", "PLAYER_EQUIPMENT_CHANGED", function(...)
			-- _G.print("startFishing PLAYER_EQUIPMENT_CHANGED", ...)
		end)
		chkWeapons()
		if not fpEquipped then
			-- Equip a fishing rod
			for _, fp in _G.ipairs_reverse(fishingPoles) do
				_G.EquipItemByName(fp)
				if fpEquipped then
					-- self:printD("startFishing, equipping Fishing Pole", fp)
					break
				end
			end
		end
		-- chkHelmet()
		-- if not fhEquipped then
		-- 	-- Equip a fishing hat
		-- 	for _, fh in _G.ipairs_reverse(fishingHats) do
		-- 		_G.EquipItemByName(fh)
		-- 		if fhEquipped then
		-- 			self:printD("startFishing, equipping Hat", fh)
		-- 			break
		-- 		end
		-- 	end
		-- end
	end

	if not _G.C_CVar.GetCVarBool("Sound_EnableAllSound") then
		-- enable Sound
		_G.C_CVar.SetCVar("Sound_EnableAllSound", 1)
		_G.C_CVar.SetCVar("Sound_MasterVolume", 1.0)
		_G.C_CVar.SetCVar("Sound_EnableSFX", 1)
		_G.C_CVar.SetCVar("Sound_SFXVolume", 1.0)
		_G.C_CVar.SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)
		_G.C_CVar.SetCVar("Sound_EnableMusic", 0)
		_G.C_CVar.SetCVar("Sound_EnableAmbience", 0)
		_G.C_CVar.SetCVar("Sound_EnableDialog", 0)

		if self.isRtl then
			_G.ActionStatus:DisplayMessage(_G.SOUND_EFFECTS_ENABLED)
		end
	end

end
function aObj:endFishing()

	if _G.InCombatLockdown() then
		self.oocTab[#self.oocTab + 1] = {self.endFishing, {self}}
		return
	end

	if not self.isRtl then
		-- check to see if fishing rod equipped
		if fpEquipped then
		-- if fishingPoles[_G.GetInventoryItemID("player", mhSlotId)] then
			-- equip last used weapon(s)
			_G.EquipItemByName(_G.misc_sv_pc.mhWeapon, mhSlotId)
			if _G.misc_sv_pc.ohWeapon then _G.EquipItemByName(_G.misc_sv_pc.ohWeapon, ohSlotId) end
			fpEquipped = false
			-- self:printD("endFishing, re-equipping weapons", _G.misc_sv_pc.mhWeapon, _G.misc_sv_pc.ohWeapon)
		end
		-- -- check to see if fishing hat equipped
		-- if fishingHats[_G.GetInventoryItemID("player", hSlotId)] then
		-- 	-- equip last used helmet
		-- 	_G.EquipItemByName(_G.helmet, hSlotId)
		-- 	fhEquipped = false
		-- 	self:printD("endFishing, re-equipping Helmet", _G.helmet)
		-- end
		aObj.ae.UnregisterEvent(aName .. "fishing", "PLAYER_EQUIPMENT_CHANGED")
	end

	if _G.C_CVar.GetCVarBool("Sound_EnableAllSound") then
		-- disable sound
		_G.C_CVar.SetCVar("Sound_EnableAllSound", 0)
		_G.C_CVar.SetCVar("Sound_EnableMusic", 1)
		_G.C_CVar.SetCVar("Sound_EnableAmbience", 1)
		_G.C_CVar.SetCVar("Sound_EnableDialog", 1)

		if self.isRtl then
			_G.ActionStatus:DisplayMessage(_G.SOUND_EFFECTS_DISABLED)
		end
	end

end

aObj.RegisterCallback(aName .. "fishing", "AddOn_Loaded", function(_, _)
	_G.misc_sv_pc.mhWeapon = _G.misc_sv_pc.mhWeapon or 0
	_G.misc_sv_pc.ohWeapon = _G.misc_sv_pc.ohWeapon or 0
	_G.misc_sv_pc.helmet   = _G.misc_sv_pc.helmet or 0
	getItemIds()
	aObj:printD("fishing AddOn_Loaded:", mhSlotId, ohSlotId, hSlotId)
	aObj.UnregisterCallback(aName .. "fishing", "AddOn_Loaded")
end)
aObj.SCL["sf"] = aObj.startFishing
aObj.SCL["ef"] = aObj.endFishing
