local aName, aObj = ...
local _G = _G
-- luacheck: ignore 631 (line is too long)

if not aObj.isRtl then
	return
end

-- mountTypeID from here: https://wowpedia.fandom.com/wiki/API_C_MountJournal.GetMountInfoExtraByID
-- local isFlyingMount = {
-- 	[247] = true,
-- 	[248] = true,
-- }
-- local isDragonRidingMount = {
-- 	[402] = true
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
local dragonRidingAreasByID = {
	[2021] = true, -- "The Forbidden Reach, Dragon Isles"
	[2022] = true, -- "The Waking Shores, Dragon Isles"
	[2023] = true, -- "Ohn'ahran Plains, Dragon Isles"
	[2024] = true, -- "The Azure Span, Dragon Isles"
	[2025] = true, -- "Thaldraszus, Dragon Isles"
	[2112] = true, -- "Valdrakken, Dragon Isles"
	[2085] = true, -- "The Primalist Future, Temporal Conflux, Dragon Isles"
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
	[19307] = false, -- Dragon Isles Pathfinder, allows flying in the Dragon Isles
}
-- setup flyingMounts
-- use /misc gmi to get MountID
local flyingMounts = {
	-- [1013] = true, -- Honeyback Harvester
	-- [1320] = true, -- Shadowbarb Drone
	-- [1510] = true, -- Dusklight Razorwing
	[1495] = true, -- Maldraxxian Corpsefly
	[1674] = true, -- Temperamental Skyclaw
}
local dragonRidingMounts = {
	[1590] = true, -- Windborne Velocidrake
	[1591] = true, -- Cliffside Wylderdrake
}

function aObj:checkFlyingAreas()

	-- check mounts loop through all mounts until required one is found
	local function checkMounts(mntID, isFav)
		-- aObj:printD("checkMounts#1", mntID, isFav, _G.C_MountJournal.GetNumDisplayedMounts())
		for idx = 1, _G.C_MountJournal.GetNumDisplayedMounts() do
			local _, _, mountID, _ = getMountInfo(idx)
			-- aObj:printD("checkMounts#2", name, isFavourite, mountID)
			if mountID == mntID then
				_G.C_MountJournal.SetIsFavorite(idx, isFav)
				-- aObj:printD("checkMounts#3:", mntID, name, "Favourite: ", isFav)
				break
			end
		end
	end

	local function checkEvt(event) -- luacheck: ignore 212
		-- aObj:printD("regEvt#0", event)
		-- wait for Zone info to be updated
		_G.C_Timer.After(1, function()
			if _G.UnitOnTaxi("player")
			or _G.UnitInVehicle("player")
			then
				return
			end
			local cMAID, rZone, rSubZone = _G.C_Map.GetBestMapForUnit("player"), _G.GetRealZoneText(), _G.GetSubZoneText() -- luacheck: ignore 211
			-- aObj:printD("regEvt#1", cMAID, rZone, rSubZone)
			if not cMAID then return end
			local isFav = true
			if _G.IsFlyableArea() then
				isFav = true
			else
				local instInfo = {_G.GetInstanceInfo()}
				-- aObj:printD("regEvt#1.5", instInfo[1], instInfo[2])
				if instInfo[2] ~= "none" -- not in instances/dungeons/scenarios etc
				and not instInfo[1]:find("Garrison Level") -- not in Garrison
				or not flyingAchievements[890] -- ignore this if character can't fly yet
				or nonFlyingAreasByID[cMAID]
				or nonFlyingAreas[rZone]
				or (dragonRidingAreasByID[cMAID] and not flyingAchievements[19307]) -- can't fly in Dragon Isles
				then
					isFav = false
				end
			end
			aObj:printD("regEvt#2", _G.IsFlyableArea(), nonFlyingAreasByID[cMAID], nonFlyingAreas[rZone], isFav)
			for mID, _ in _G.pairs(flyingMounts) do
				-- aObj:printD("regEvt#3", mID, isFav)
				checkMounts(mID, isFav)
			end
			-- enable DragonRiding mounts if no other way to fly in Dragon Isles
			-- N.B. can only ride dragons in The Primalist Future
			-- aObj:printD("regEvt#3.5", dragonRidingAreasByID[cMAID], flyingAchievements[19307], cMAID == 2085)
			isFav = ((dragonRidingAreasByID[cMAID] and not flyingAchievements[19307])
				 or (dragonRidingAreasByID[cMAID] and cMAID == 2085))
				 or (dragonRidingAreasByID[cMAID] and rSubZone:find("Suffusion Camp"))
				 and true or false
			-- aObj:printD("regEvt#4", dragonRidingAreasByID[cMAID], isFav)
			for mID, _ in _G.pairs(dragonRidingMounts) do
				-- aObj:printD("regEvt#5", mID, true)
				checkMounts(mID, isFav)
			end
		end)
	end

	-- check flying achievements
	local chkEvt = false
	local function checkAchievements()
		for aID, achieved in _G.pairs(flyingAchievements) do
			local wasEarnedByMe = _G.select(13, _G.GetAchievementInfo(aID))
			-- aObj:printD("checkAchievements", aID, achieved, wasEarnedByMe)
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
			checkEvt("ACHIEVEMENT_EARNED")
		end)
	else
		self.ae.UnregisterEvent(aName .. "flyingmounts", "ACHIEVEMENT_EARNED")
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
		-- _G.print("Mount Info#1: ", i, name, isFavourite, mountID, mountTypeID, mountTypeID2)
		if isFavourite then
			_G.print("Mount Info#2: ", i, name, mountID, mountTypeID, mountTypeID2)
		end
	end
end
