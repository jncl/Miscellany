local _, aObj = ...
local _G = _G

if not aObj.isClsc then return end

aObj.ah:SecureHook("QuestLog_Update", function(_)

	local numEntries, _ = _G.GetNumQuestLogEntries()

	local questIndex, qlt
	for i = 1, _G.QUESTS_DISPLAYED do
		questIndex = i + _G.FauxScrollFrame_GetOffset(_G.QuestLogListScrollFrame)
		if questIndex <= numEntries then
			qlt = {_G.GetQuestLogTitle(questIndex)}
			-- aObj:printD("QLU", qlt)
			-- _G.Spew("", qlt)

			if not qlt[4] then -- check for Header
				-- _G["QuestLogTitle" .. i]:SetText("[" .. qlt[2] .. "] " .. qlt[1])
			end

		end
	end

end)
