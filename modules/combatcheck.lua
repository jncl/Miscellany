local aName, aObj = ...
local _G = _G

-- handle in Combat situations
aObj.ae.RegisterEvent(aName, "PLAYER_REGEN_DISABLED", function(_)
	-- printD("PLAYER_REGEN_DISABLED")
	-- _G.print("Miscellany - PLAYER_REGEN_DISABLED")
	_G.UIErrorsFrame:AddMessage("YOU ARE UNDER ATTACK.", 1, 0, 0)
	_G.C_CVar.SetCVar("nameplateShowEnemies", 1)
	-- equip "Normal" set if a fishing pole is equipped
	local mH = 	_G.GetInventoryItemLink("player", _G.GetInventorySlotInfo("MainHandSlot"))
	if mH then
		local itemType = _G.select(7, _G.C_Item.GetItemInfo(mH))
		if itemType == "Fishing Poles"
		and _G.C_EquipmentSet.GetNumEquipmentSets() > 0
		then
			_G.EquipmentManager_EquipSet(1) -- Normal set
		end
	end
end)

aObj.ae.RegisterEvent(aName, "PLAYER_REGEN_ENABLED", function(_)
	-- printD("PLAYER_REGEN_ENABLED")
	_G.UIErrorsFrame:AddMessage("Finished fighting.", 1, 1, 0)
	_G.C_CVar.SetCVar("nameplateShowEnemies", 0)
	for _, v in _G.pairs(aObj.oocTab) do
		v[1](_G.unpack(v[2]))
	end
	_G.wipe(aObj.oocTab)
end)
