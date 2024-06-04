local _, aObj = ...
local _G = _G

local print = _G.print

-- Chicken rescue quests
local chickenQuests = {
	-- oox-17-tn
	["Tanaris"] = {
		[351] = "Find",
		[648] = "Rescue",
	},
	-- oox-09-hl
	["Hinterlands"] = {
		[485] = "Find",
		[836] = "Rescue",
	},
	-- oox-22-fe
	["Feralas"] = {
		[2766] = "Find",
		[2767] = "Rescue",
		-- [25475] = "Find",
		-- [25476] = "Rescue",
	},
}

local qTab = {}
function aObj:chickenQuests() -- luacheck: ignore self

	_G.GetQuestsCompleted(qTab)
	aObj:printD("#Completed Quests: ", #qTab)

	for k, v in _G.pairs(chickenQuests) do
		print(k, "chicken quests:")
		for k2, v2 in _G.pairs(v) do
			if  qTab[k2] then
				print("==>", v2, "completed")
			else
				print("==>", v2, "incomplete")
			end
		end
	end

end

function aObj:doChicken() -- luacheck: ignore self

	_G.C_Timer.NewTicker(2.5, function() _G.DoEmote("CHICKEN") end, 50)

end
