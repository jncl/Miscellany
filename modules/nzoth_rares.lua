local _, aObj = ...
local _G = _G

local function checkTable(area, tab)

	for name, coords in _G.pairs(tab) do
		_G.SlashCmdList.TOMTOM_WAY(area .. " " .. coords .. " " .. name)
	end
	_G.SlashCmdList.TOMTOM_CLOSEST_WAYPOINT() -- point to nearest waypoint

end
-- Terrors from the Deep quest (BfA) [Uldum]
function aObj:TerrorsFromTheDeep() -- luacheck: ignore self

	-- Terrors from the Deep quest info [Uldum]
	local tab = {
		["Skikx'traz"]                = "21.23 61.05",
		["R'krox the Runt"]           = "28.90 17.65",
		["Corpse Eater"]              = "30.85 49.71",
		["Magus Rehleth"]             = "31.24 65.46",
		["Anq'uri the Titanic (122)"] = "32.45 64.96",
		["Warcaster Xeshro"]          = "33.50 26.18",
		["Obsidian Annihilator (122)"] = "35.11 17.30",
		["Lord Aj'qirai (cave)"]      = "36.87 20.90",
		["Qho"]                       = "37.82 60.28",
		["Aqir Flayer"]               = "40.83 38.22",
		["Zuythiz"]                   = "40.86 42.26",
		["Aqir Titanus"]              = "41.92 44.40",
		["High Priest Ytaessis"]      = "42.40 58.03",
		["Armagedillo"]               = "44.81 42.67",
		["Captain Dunewalker (cave)"] = "45.21 58.73",
		["High Guard Reshef"]         = "47.48 77.15",
		["Executor of N'Zoth"]        = "59.0 46.5",
	}
	checkTable("Uldum:1527", tab)

end

-- The Sun King's Chosen quest (BfA) [Uldum]
function aObj:TheSunKingsChosen() -- luacheck: ignore self

	--The Sun King's Chosen quest info [Uldum]
	local tab = {
		["Nebet the Ascended"]              = "61,98 25,67",
		["Acolyte Taspu (inside the tomb)"] = "64,57 26,23",
		["Muminah the Incandescent"]        = "67,30 19,47",
		["Rotfeaster"]                      = "68,23 31,97",
		["Tat the Bonechewer"]              = "65,98 34,99",
		["Atekhramun"]                      = "65,05 51,31",
		["Scoutmaster Moswen"]              = "69,92 42,14",
		["Anaua"]                           = "69,20 50,59",
		["Champion Sen-mat"]                = "75,49 52,19",
		["Hik-ten the Taskmaster"]          = "80,86 47,55",
		["Watcher Rehu"]                    = "80,18 52,04",
		["Sun Priestess Nubitt"]            = "84,59 57,08",
		["Zealot Tekem"]                    = "79,80 57,71",
		["Sun King Nahkotep"]               = "79,02 63,86",
		["Senbu the Pridefather"]           = "74,13 64,36",
		["Fangtaker Orsa"]                  = "75,07 68,12",
		["Sun Prophet Epaphos"]             = "73,32 74,63",
	}
	checkTable("Uldum:1527", tab)

end
