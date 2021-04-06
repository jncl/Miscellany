local aName, aObj = ...
local _G = _G

function aObj:checkLTQ(questID)
	if _G.IsQuestFlaggedCompleted(questID) then
		-- print("LegionTreasure quest complete:", questID)
	else
		_G.print("LegionTreasure quest incomplete:", questID)
	end
end

function aObj:checkLTQHighmountain()

	for _, q in _G.pairs {39466,39494,39503,39531,39606,39766,39824,40471,40472,40473,40474,40475,40476,40477,40478,40479,40480,40481,40482,40483,40484,40487,40488,40489,40491,40493,40494,40496,40497,40498,40499,40500,40505,40506,40507,40508,40509,40510,42453,44279,44352,39507,44280} do
	-- for _, q in pairs{39507,44280} do
		aObj:checkLTQ(q)
	end
end
