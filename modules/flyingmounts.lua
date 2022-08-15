local aName, aObj = ...
local _G = _G

-- mountTypeID from here: https://wowpedia.fandom.com/wiki/API_C_MountJournal.GetMountInfoExtraByID
-- local isFlyingMount = {
-- 	[247] = true,
-- 	[248] = true,
-- }

local nonFlyingAreas = {
	["Darkmoon Island"]		= true,
	["Firelands"]           = true,
	["Isle of Giants"]      = true,
	["Timeless Isle"]		= true,
	["Vision of Orgrimmar"] = true,
	["Oribos"]              = true, -- [1670][1671][1672][1673]
	["The Maw"]             = true, -- [1543][1648][1960]
}
-- UIMapIDs here: https://wow.tools/dbc/?dbc=uimap
local nonFlyingAreasByID = {
	[1662] = true, -- "Queen's Conservatory, Ardenweald"
	[1961] = true, -- "Korthia"
	[1970] = true, -- "Zereth Mortis"
	[2016] = true, -- "Tazavesh, the Veiled Market"
	[2029] = true, -- "Gravid Repose, Zereth Mortis"
}

local function getMountInfo(idx)
	-- aObj:printD("getMountInfo", idx)
	local name, _, _, _, _, _, isFavourite, _, _, _, _, mountID = _G.C_MountJournal.GetDisplayedMountInfo(idx)
	local _, _, _, _, mountTypeID, _, _, _, _ = _G.C_MountJournal.GetMountInfoExtraByID(idx)
	return name, isFavourite, mountID, mountTypeID
end

local flyingAchievements = {
	[890] = false, -- Into The Wild Blue Yonder, Learn the expert riding skill
	[13250] = false, -- Battle for Azeroth Pathfinder, Part Two, allows flying in Kul Tiras and Zandalar
	[15514] = false, -- Unlocking the Secrets, allows flying in Zereth Mortis
}
-- setup flyingMounts
-- use /misc gmi to get MountID
local flyingMounts = {
	[1013] = true, -- Honeyback Harvester
	[1320] = true, -- Shadowbarb Drone
	[1510] = true, -- Dusklight Razorwing
}

function aObj:checkFlyingAreas()

	-- check flying achievements
	local chkEvt = false
	local function checkAchievements()
		for aID, achieved in _G.pairs(flyingAchievements) do
			local wasEarnedByMe = _G.select(13, _G.GetAchievementInfo(aID))
			aObj:printD("checkAchievements", aID, achieved, wasEarnedByMe)
			if not achieved then
				if wasEarnedByMe then
					flyingAchievements[aID] = true
				end
			else
				chkEvt = true
			end
		end
		if flyingAchievements[15514] then
			nonFlyingAreasByID[1970] = false
		end
	end
	checkAchievements()
	if chkEvt then
		self.ae.RegisterEvent(aName .. "flyingmounts", "ACHIEVEMENT_EARNED", function(...)
			self:printD(...)
			checkAchievements()
			chkEvt("ACHIEVEMENT_EARNED")
		end)
	else
		self.ae.UnregisterEvent(aName .. "flyingmounts", "ACHIEVEMENT_EARNED")
	end

	-- check mounts loop through all mounts until required one is found
	local function checkMounts(mntID, isFav)
		aObj:printD("checkMounts#1", mntID, isFav, _G.C_MountJournal.GetNumDisplayedMounts())
		for idx = 1, _G.C_MountJournal.GetNumDisplayedMounts() do
			name, isFavourite, mountID, _ = getMountInfo(idx)
			-- aObj:printD("checkMounts#2", name, isFavourite, mountID)
			if mountID == mntID then
				_G.C_MountJournal.SetIsFavorite(idx, isFav)
				aObj:printD("checkMounts#3:", mntID, name, "Favourite: ", isFav)
				break
			end
		end
	end

	local function checkEvt(event)
		aObj:printD("regEvt#0", event)
		-- wait for Zone info to be updated
		_G.C_Timer.After(1, function()
			if _G.UnitOnTaxi("player")
			or _G.UnitInVehicle("player")
			then
				return
			end
			local cMAID, rZone, rSubZone = _G.C_Map.GetBestMapForUnit("player"), _G.GetRealZoneText(), _G.GetSubZoneText()
			aObj:printD("regEvt#1", cMAID, rZone, rSubZone)
			if not cMAID then return end
			local isFav = true
			local instInfo = {_G.GetInstanceInfo()}
			if instInfo[2] ~= "none" -- not in innstances/dungeons/scenarios etc
			and not instInfo[1]:find("Garrison Level") -- not in Garrison
			or not flyingAchievements[890] -- ignore this if character can't fly yet
			or nonFlyingAreasByID[cMAID]
			or nonFlyingAreas[rZone]
			then
				isFav = false
			end
			aObj:printD("regEvt#2", nonFlyingAreasByID[cMAID], nonFlyingAreas[rZone], isFav)
			for mID, _ in _G.pairs(flyingMounts) do
				aObj:printD("regEvt#3", mID, isFav)
				checkMounts(mID, isFav)
			end
		end)
	end

	local function regEvt(event)
		aObj.ae.RegisterEvent(aName .. "flyingmounts", event, function()
			aObj:printD("regEvt#0", event)
		end)

	end
	aObj.ae.RegisterEvent(aName .. "flyingmounts","PLAYER_ENTERING_WORLD", function(...) checkEvt(...) end)
	aObj.ae.RegisterEvent(aName .. "flyingmounts","ZONE_CHANGED_NEW_AREA", function(...) checkEvt(...) end)
	aObj.ae.RegisterEvent(aName .. "flyingmounts","ZONE_CHANGED", function(...) checkEvt(...) end)
	aObj.ae.RegisterEvent(aName .. "flyingmounts","PLAYER_CONTROL_GAINED", function(...) checkEvt(...) end)
	aObj.ae.RegisterEvent(aName .. "flyingmounts","UNIT_EXITED_VEHICLE", function(...) checkEvt(...) end)

end

function aObj:getMountInfo() -- luacheck: ignore self
	local name, isFavourite, mountID, mountTypeID, mountTypeID2
	for i = 1, _G.C_MountJournal.GetNumDisplayedMounts() do
		name, isFavourite, mountID, mountTypeID = getMountInfo(i)
		mountTypeID2 = _G.select(5, _G.C_MountJournal.GetMountInfoExtraByID(mountID))
		_G.print("Mount Info#1: ", i, name, isFavourite, mountID, mountTypeID, mountTypeID2)
		if isFavourite then
			_G.print("Mount Info#2: ", i, name, mountID, mountTypeID, mountTypeID2)
		end
	end
end
