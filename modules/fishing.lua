local _, aObj = ...
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
local fishingHats = {
	19972, -- Lucky Fishing Hat (+5 Fishing)
	33820, -- Weather-Beaten Fishing Hat (+5 Fishing) (Using this attaches a 10 min lure +75 Fishing)
	88710, -- Nat's Hat (+5 Fishing) (Using this attaches a 10 min lure +150 Fishing)
	93732, -- Darkmoon Fishing Cap (+5 Fishing)
	118380, -- Highfish Cap (+100 Fishing) (7 days duration)
	118393, -- Tentacled Hat (+100 Fishing) (5 days duration)
}
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

local mhSlotId = _G.GetInventorySlotInfo("MainHandSlot")
local ohSlotId = _G.GetInventorySlotInfo("SecondaryHandSlot")
local hSlotId  = _G.GetInventorySlotInfo("HeadSlot")
-- aObj:printD("Global MainHand, OffHand, Head slot ids", _G.mhWeapon, _G.ohWeapon, _G.helmet)
-- aObj:printD("MainHand, OffHand, Head slot ids", mhSlotId, ohSlotId, hSlotId)

local fpEquipped = false
local function chkWeapons()
	local mhItem = _G.GetInventoryItemID("player", mhSlotId)
	local ohItem = _G.GetInventoryItemID("player", ohSlotId)

	-- check to see if fishing rod already equipped
	if not _G.tContains(fishingPoles, mhItem) then
		-- get current Weapon(s)
		_G.mhWeapon, _G.ohWeapon = mhItem, ohItem
		aObj:printD("current weapons:", _G.mhWeapon, _G.ohWeapon)
		fpEquipped = false
	else
		fpEquipped = true
	end
end
local fhEquipped = false
local function chkHelmet()
	local hsItem = _G.GetInventoryItemID("player", hSlotId)

	-- check to see if fishing hat already equipped
	if not _G.tContains(fishingHats, hsItem) then
		_G.helmet = hsItem
		aObj:printD("current helmet:", _G.helmet)
		fhEquipped = false
	else
		fhEquipped = true
	end
end

function aObj:startFishing()

	if _G.InCombatLockdown() then
		self.oocTab[#self.oocTab + 1] = {self.startFishing, {nil}}
		return
	end

	if not self.isRtl then
		chkWeapons()
		chkHelmet()
		-- Equip a fishing hat
		for _, fh in _G.ipairs_reverse(fishingHats) do
			_G.EquipItemByName(fh)
			if fhEquipped then
				self:printD("startFishing, equipping Hat", _G.helmet)
				break
			end
		end
		-- Equip a fishing rod
		for _, fp in _G.ipairs_reverse(fishingPoles) do
			_G.EquipItemByName(fp)
			if fpEquipped then
				self:printD("startFishing, equipping Fishing Pole", _G.helmet)
				break
			end
		end
	end

	if not _G.GetCVarBool("Sound_EnableAllSound") then
		-- enable Sound
		_G.SetCVar("Sound_EnableAllSound", 1)
		_G.SetCVar("Sound_MasterVolume", 1.0)
		_G.SetCVar("Sound_EnableSFX", 1)
		_G.SetCVar("Sound_SFXVolume", 1.0)
		_G.SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)
		_G.SetCVar("Sound_EnableMusic", 0)
		_G.SetCVar("Sound_EnableAmbience", 0)
		_G.SetCVar("Sound_EnableDialog", 0)

		if self.isRtl then
			_G.ActionStatus:DisplayMessage(_G.SOUND_EFFECTS_ENABLED)
		else
			_G.AudioOptionsFrame_AudioRestart()
		end
	end


end
function aObj:endFishing()

	if _G.InCombatLockdown() then
		self.oocTab[#self.oocTab + 1] = {self.endFishing, {nil}}
		return
	end

	if not self.isRtl then
		-- check to see if fishing hat equipped
		if fishingHats[_G.GetInventoryItemID("player", hSlotId)] then
			-- equip last used helmet
			_G.EquipItemByName(_G.helmet, hSlotId)
			self:printD("endFishing, re-equipping Helmet", _G.helmet)
		end
		-- check to see if fishing rod equipped
		if fishingPoles[_G.GetInventoryItemID("player", mhSlotId)] then
			-- equip last used weapon(s)
			_G.EquipItemByName(_G.mhWeapon, mhSlotId)
			if _G.ohWeapon then _G.EquipItemByName(_G.ohWeapon, ohSlotId) end
			self:printD("endFishing, re-equipping weapons", _G.mhWeapon, _G.ohWeapon)
		end
	end

	if _G.GetCVarBool("Sound_EnableAllSound") then
		-- disable sound
		_G.SetCVar("Sound_EnableAllSound", 0)
		_G.SetCVar("Sound_EnableMusic", 1)
		_G.SetCVar("Sound_EnableAmbience", 1)
		_G.SetCVar("Sound_EnableDialog", 1)

		if self.isRtl then
			_G.ActionStatus:DisplayMessage(_G.SOUND_EFFECTS_DISABLED)
		else
			_G.AudioOptionsFrame_AudioRestart()
		end
	end

end
