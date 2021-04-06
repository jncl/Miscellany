local aName, aObj = ...
local _G = _G

if aObj.isClsc then return end

if not select(2, _G.UnitClass("player")) == "HUNTER" then return end

-- track PLAYER_LOGIN event
aObj.ae.RegisterEvent(aName .. "hunter", "PLAYER_LOGIN", function(event, addon)
	-- if a Hunter and in a Garrison then stop tracking Stable Masters
 	-- aObj:printD("PLAYER_LOGIN")
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

	aObj.ae.UnregisterEvent(aName, "PLAYER_LOGIN")

end)
