local aName, aObj = ...
local _G = _G

-- mountTypeID from here: https://wowpedia.fandom.com/wiki/API_C_MountJournal.GetMountInfoExtraByID
local isFlyingMount = {
	[247] = true,
	[248] = true,
}

local nonFlyingAreas = {
	["Oribos"]   = true, -- [1670][1671][1672][1673]
	["The Maw"]  = true, -- [1543][1648][1960]
}
-- UIMapIDs here: https://wow.tools/dbc/?dbc=uimap
local nonFlyingAreasByID = {
	[1662] = true, -- "Queen's Conservatory, Ardenweald"
	[1961] = true, -- "Korthia"
	[1970] = true, -- "Zereth Mortis"
	[2016] = true, -- "Tazavesh, the Veiled Market"
}

local function getMountInfo(idx)
	local name, _, _, _, _, _, isFavourite, _, _, _, _, mountID = _G.C_MountJournal.GetDisplayedMountInfo(idx)
	local _, _, _, _, mountTypeID, _, _, _, _ = _G.C_MountJournal.GetMountInfoExtraByID(mountID)
	return name, isFavourite, mountID, mountTypeID
end
function aObj:checkFlyingAreas()

	_G.flyingMounts = _G.flyingMounts or {
		[1013] = true, -- Honeyback Harvester
		[1320] = true, -- Shadowbard Drone
	}
	-- add/remove flying mounts from favourites table
	local name, isFavourite, mountID, mountTypeID
	local function setupMounts(event)
		self:printD("setupMounts", event)
		for i = _G.C_MountJournal.GetNumDisplayedMounts(), 1, -1 do
			name, isFavourite, mountID, mountTypeID = getMountInfo(i)
			if _G.flyingMounts[mountID] then
				if not isFavourite then
					_G.flyingMounts[mountID] = false
					self:printD("removing flying mount:", name)
				end
			else
				if isFavourite
				and isFlyingMount[mountID]
				then
					_G.flyingMounts[mountID] = true
					self:printD("adding flying mount:", name)
				end
			end
		end
	end

	-- hook this to handle favourite mount changes
	self.ah:SecureHook("CollectionsJournal_LoadUI", function()
		self.ah:SecureHookScript(_G.MountJournal, "OnHide", function(_)
			setupMounts("OnHide")
		end)
		self.ah:Unhook("CollectionsJournal_LoadUI")
	end)

	local function checkMounts(event)
		self:printD("checkMounts#1", event)
		_G.C_Timer.After(0.5, function() -- add delay before checks
			if _G.UnitOnTaxi("player")
			or _G.UnitInVehicle("player")
			then
				return
			end
			local cMAID, rZone, rSubZone = _G.C_Map.GetBestMapForUnit("player"), _G.GetRealZoneText(), _G.GetSubZoneText()
			self:printD("checkMounts#1", event, cMAID, rZone, rSubZone)
			-- loop in reverse order to process ALL mounts
			for i = _G.C_MountJournal.GetNumDisplayedMounts(), 1, -1 do
				name, isFavourite, mountID, mountTypeID = getMountInfo(i)
				-- self:printD("checkMounts", i, name, isFavourite, mountID, mountTypeID, _G.flyingMounts[mountID])
				-- add/remove favourite flying mounts
				if _G.flyingMounts[mountID] then
					if nonFlyingAreasByID[cMAID]
					or nonFlyingAreas[rZone]
					then
						_G.C_MountJournal.SetIsFavorite(i, false)
						self:printD("checkMounts#2", name, "Unset Favourite")
					elseif not isFavourite then
						_G.C_MountJournal.SetIsFavorite(i, true)
						self:printD("checkMounts#3", name, "Set Favourite")
					end
				end
			end
		end)
	end
	self.ae.RegisterEvent(aName .. "flyingmounts", "PLAYER_ENTERING_WORLD", function(...)
		checkMounts(...)
	end)
	self.ae.RegisterEvent(aName .. "flyingmounts", "ZONE_CHANGED_NEW_AREA", function(...)
		checkMounts(...)
	end)
	self.ae.RegisterEvent(aName .. "flyingmounts", "PLAYER_CONTROL_GAINED", function(...)
		checkMounts(...)
	end)
	self.ae.RegisterEvent(aName .. "flyingmounts", "UNIT_EXITED_VEHICLE", function(...)
		checkMounts(...)
	end)

end

function aObj:getMountInfo() -- luacheck: ignore self
	local name, isFavourite, mountID, mountTypeID, mountTypeID2
	for i = _G.C_MountJournal.GetNumDisplayedMounts(), 1, -1 do
		name, isFavourite, mountID, mountTypeID = getMountInfo(i)
		mountTypeID2 = _G.select(5, _G.C_MountJournal.GetMountInfoExtraByID(mountID))
		-- _G.print("Mount Info#1: ", i, name, isFavourite, mountID, mountTypeID, mountTypeID2)
		if isFavourite then
			_G.print("Mount Info#2: ", i, name, mountID, mountTypeID, mountTypeID2)
		end
	end
end
