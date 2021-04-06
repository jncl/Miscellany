local _, aObj = ...
local _G = _G

-- Alpaca It Up quest (BfA)
function aObj:alpacaItUp()

	local function checkTable(tab)

		for qName, info in _G.pairs(tab) do
			local text, _, finished = _G.GetQuestObjectiveInfo(info["questID"], 0, false)
			-- print("Alpaca It Up: ", text, objectiveType, finished)
			if not finished then
				_G.print("Alpaca It Up: ", text:sub(1, 3))
				for _, coords in _G.ipairs(info["coords"]) do
					_G.SlashCmdList.TOMTOM_WAY("Uldum:1527 " .. coords .. " " .. qName)
				end
				_G.SlashCmdList.TOMTOM_CLOSEST_WAYPOINT() -- point to nearest waypoint
			else
				_G.print("'Alpaca It Up' completed, 'Alpaca It In' available now")
			end
		end

	end

	-- Gersahl Shrub coords
	-- 68.14 73.81
	-- 65.43 74.36
	-- 65.13 73.70
	-- 64.71 72.52
	-- 68.09 75.36
	-- 67.47 73.41
	-- 66.18 71.65
	-- 67.60 72.49

	-- Friendly Alpaca quest info
	local faQuest = {
		["Friendly Alpaca"] = {
			["questID"] = 58881,
			["coords"] = {
				"15 61",
				"25 9", -- seen
				"28 49",
				"30 29",
				"39 9", -- seen
				"43 70", -- seen
				"46 48",
				"53 19", -- seen
				"55 69",
				"63 14",
				"63 53", -- seen
				"70 39", -- seen
				"76 68",
			},
		},
	}
	checkTable(faQuest)

end

-- Elusive Quickhoof mount in Vol'dun (BfA)
function aObj:elusiveQuickhoof()

	local function checkTable(tab)

		for qName, info in _G.pairs(tab) do
			if not _G.IsQuestFlaggedCompleted(info["questID"]) then
				for _, coords in _G.ipairs(info["coords"]) do
					_G.SlashCmdList.TOMTOM_WAY("Vol'dun " .. coords .. " " .. qName)
				end
				_G.SlashCmdList.TOMTOM_CLOSEST_WAYPOINT() -- point to nearest waypoint
			else
				_G.print(qName, "completed")
			end
		end

	end

	-- Elusive Quickhoof quest info
	local eqQuest = {
		["Elusive Quickhoof"] = {
			["questID"] = 7,
			["coords"] = {
				"26.4 52.5",
				"29.0 66.0",
				"31.1 67.3",
				"42.0 60.0",
				"43.0 69.0",
				"51.1 85.9",
				"52.6 89.3",
				"54.34 82.06",
				"54.6 53.2",
				"55.6 68.0", -- seen
				"55.13 72.6",
			},
		},
	}
	checkTable(eqQuest)

end
