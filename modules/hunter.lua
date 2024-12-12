local aName, aObj = ...
local _G = _G

if not aObj.isRtl then return end

if aObj.uCls ~= "HUNTER" then return end

-- track PLAYER_LOGIN event
aObj.ae.RegisterEvent(aName .. "hunter", "PLAYER_LOGIN", function(_, _)
	-- if a Hunter and in a Garrison then stop tracking Stable Masters
	-- aObj:printD("PLAYER_LOGIN")
	local function chgTracking(type, state)
		-- printD("chgTracking:", type, state)
		for i = 1, _G.C_Minimap.GetNumTrackingTypes() do
			local name, _, active, _, _ = _G.C_Minimap.GetTrackingInfo(i)
			if type == name then
				-- printD("TrackingInfo:", i, name, texture, active, category, nested)
				if state ~= active then
					-- printD("Setting" .. name .. " tracking " .. (state and "on" or "off"))
					_G.C_Minimap.SetTracking(i, state)
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
	aObj.ae.RegisterEvent(aName .. "hunter", "ZONE_CHANGED_NEW_AREA", function()
		-- printD("ZONE_CHANGED_NEW_AREA")
		chkSM()
	end)
	-- handle Garrison Heathstone into Town Hall
	aObj.ae.RegisterEvent(aName .. "hunter", "ZONE_CHANGED", function()
		-- printD("ZONE_CHANGED")
		chkSM()
	end)
	chkSM()

	aObj.ae.UnregisterEvent(aName .. "hunter", "PLAYER_LOGIN")

end)

-- track Pet Training spells
function aObj:getHunterTraining()

	local spells1 = {
		['Blood Beasts']   = 54753,
		['Gargons']        = 61160,
		['Cloud Serpents'] = 62254,
		['Undead']         = 62255,
		-- ['Ottuks']          = 66444,
		['Ottuks']         = 71184,
		['Dragonkin']      = 72094,
	}
	local spells2 = {
		['Direhorns']      = 138430,
		['Mechanicals']    = 205154,
		['Feathermanes']   = 242155,
	}

	for name, id in _G.pairs(spells1) do
		_G.print(name .. ":", _G.C_QuestLog.IsQuestFlaggedCompleted(id) and "Yes" or "No")
	end
	for name, id in _G.pairs(spells2) do
		_G.print(name .. ":", _G.IsPlayerSpell(id) and "Yes" or "No")
	end

end

aObj.SCL["ght"] = aObj.getHunterTraining
