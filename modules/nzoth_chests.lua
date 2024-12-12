local _, aObj = ...
local _G = _G

-- Lessons in Brigandry quest (BfA) [Uldum]
local function checkTable(area, tab)

	for qName, info in _G.pairs(tab) do
		for _, coords in _G.ipairs(info["coords"]) do
			_G.SlashCmdList.TOMTOM_WAY(area .. " " .. coords .. " " .. qName)
		end
	_G.SlashCmdList.TOMTOM_CLOSEST_WAYPOINT() -- point to nearest waypoint
	end

end
function aObj:lessonsInBrigandry()

	-- Lessons in Brigandry quest info [Uldum]
	local tab = {
		["Lessons in Brigandry"] = {
			["coords"] = {
				"38.80 40.12", -- seen ??
				"45.68 79.61",
				"48.99 76.84",
				"50.80 31.46",
				"51.66 71.22",
				"52.20 77.55", --seen
				"55.65 83.43",
				"58.38 15.36", -- seen
				"59.39 62.25", -- seen
				"60.22 65.28",
				"62.80 75.66", -- seen
				"62.98 64.36", -- seen
				"62.97 76.11", -- seen
				"63.43 68.12",
				"64.44 65.02",
				"64.57 75.07", -- seen
				"65.35 71.20", -- seen
				"71 73",
			},
		},
	}
	checkTable("Uldum:1527", tab)

end

-- Plunder the Plunderers quest (BfA) [Vale of Eternal Blossoms]
function aObj:plunderThePlunderers()

	-- Plunder the Plunderers quest info
	local tab = {
		["Plunder the Plunderers"] = {
			["coords"] = {
				"10.75 28.15",
				"20.0 63.3",
				"20.08 63.12",
				"24.35 2.82",
				"30.9 30.6",
				"32.2 71.2",
				"32.8 18.6",
				"43.1 42.2",
				"47.91 70.90", -- seen
				"50.22 21.43",
				"50.~67 34.43", --seen
				"62.59 57.28", -- seen
				"70.21 53.72", -- seen
			},
		},
	}
	checkTable("Vale of Eternal Blossoms:1530", tab)

end

aObj.SCL["lib"] = aObj.lessonsInBrigandry
aObj.SCL["plp"] = aObj.plunderThePlunderers
