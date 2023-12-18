local aName, aObj = ...
local _G = _G

local qIcon = {
	["CampaignIncompleteQuestIcon"] = true,
	["Interface/GossipFrame/IncompleteQuestIcon"] = true,
}

function aObj:autoQuests()

	if not _G.autoquests then
		self.ae.UnregisterEvent(aName .. "autoquests", "GOSSIP_SHOW")
		self.ae.UnregisterEvent(aName .. "autoquests", "QUEST_DETAIL")
		self.ae.UnregisterEvent(aName .. "autoquests", "QUEST_GREETING")
		self.ae.UnregisterEvent(aName .. "autoquests", "QUEST_PROGRESS")
		self.ae.UnregisterEvent(aName .. "autoquests", "QUEST_COMPLETE")
		if self.isRtl then
			self.ae.UnregisterEvent(aName .. "autoquests", "QUEST_WATCH_LIST_CHANGED")
		end
		return
	end

	local IsShiftKeyDown = _G.IsShiftKeyDown
	-- AutoGossip by Ygrane
	-- N.B. GossipFrame used for FlightMap
	if not self.isRtl
	and not self.isClscERAPTR
	then
		self.ae.RegisterEvent(aName .. "autoquests", "GOSSIP_SHOW", function(_)
			self:printD("GOSSIP_SHOW")
			local btnCnt = _G.GossipFrame.buttons and #_G.GossipFrame.buttons or _G.GossipFrame.buttonIndex
			self:printD("GOSSIP_SHOW", btnCnt)

			if btnCnt > 0 then
				local btn, bTex, bAtl, qIncomplete
				for i = 1, btnCnt do
					btn = _G.GossipFrame.buttons and _G.GossipFrame.buttons[i] or _G["GossipTitleButton" .. i]
					if btn.Icon then
						bTex = btn.Icon:GetTexture()
						bAtl = btn.Icon:GetAtlas()
						self:printD("bTex", bTex, bAtl)
						qIncomplete = qIcon[bTex] or qIcon[bAtl] or false
					else
						qIncomplete = false
					end
					local btnID = btn:GetID()
					self:printD(btn, btn.type, btnID, qIncomplete)
					if not IsShiftKeyDown() then
						if btn.type == "Available" then
							if _G.C_GossipInfo
							and _G.C_GossipInfo.SelectAvailableQuest
							then
								_G.C_GossipInfo.SelectAvailableQuest(btnID)
							else
								_G.SelectGossipAvailableQuest(btnID)
							end
							break
						elseif btn.type == "Active"
						and not qIncomplete -- ignore Incomplete quests
						then
							if _G.C_GossipInfo
							and	_G.C_GossipInfo.SelectActiveQuest
							then
								_G.C_GossipInfo.SelectActiveQuest(btnID)
							else
								_G.SelectGossipActiveQuest(btnID)
							end
							break
						elseif btn.type == "Gossip" then
							if _G.C_GossipInfo
							and _G.C_GossipInfo.GetNumOptions
							then
								if _G.C_GossipInfo.GetNumOptions() == 1 then
									_G.C_GossipInfo.SelectOption(btnID)
								end
							elseif _G.GetNumGossipOptions() == 1 then
								_G.SelectGossipOption(btnID)
								self:printD(btn:GetText())
								-- Rogue OrderHall access check
								if btn:GetText() == "<Lay your insignia on the table.>" then
									_G.SelectGossipOption(btnID)
								end
							end
							break
						end
					end
				end
			end

		end)
	else
		local function doQuest(eData)
			-- self:printD("doQuest", eData.info.isComplete, eData.info.questID)
			if eData.info.isComplete then
				_G.C_GossipInfo.SelectActiveQuest(eData.info.questID)
			else
				_G.C_GossipInfo.SelectAvailableQuest(eData.info.questID)
			end
		end
		self.ae.RegisterEvent(aName .. "autoquests", "GOSSIP_SHOW", function(_)
			local cnt, savedElement = 0
			local function skinElement(...)
				local _, elementData, new
				if _G.select("#", ...) == 2 then
					_, elementData = ...
				elseif _G.select("#", ...) == 3 then
					_, elementData, new = ...
				else
					_, _, elementData, new = ...
				end
				if new ~= false then
					-- self:printD("skinElement", elementData.buttonType)
					-- luacheck: ignore 542 ((W542) empty if branch))
					if not IsShiftKeyDown() then
						if elementData.buttonType == 4 -- Quest
						or elementData.buttonType == 5 -- Campaign Quest
						then
							doQuest(elementData)
						elseif elementData.buttonType == 3 then -- Gossip
							cnt = cnt + 1
							if elementData.info.name:find("Quest") then
								_G.C_GossipInfo.SelectOption(elementData.info.gossipOptionID)
							elseif cnt == 1 then
								savedElement = elementData
							end
						end
						if savedElement then
							-- self:printD("skinElement#2", cnt, savedElement)
							_G.C_GossipInfo.SelectOption(savedElement.info.gossipOptionID)
						end
					end
				end
			end
			_G.ScrollUtil.AddAcquiredFrameCallback(_G.GossipFrame.GreetingPanel.ScrollBox, skinElement, aObj, true)
		end)
	end
	-- Auto Accept Quest
	self.ae.RegisterEvent(aName .. "autoquests", "QUEST_DETAIL", function(_)
		self:printD("QUEST_DETAIL")
		if not IsShiftKeyDown()	then
			_G.AcceptQuest()
		end
	end)
	-- Auto Accept/Complete Multiple Quests
	self.ae.RegisterEvent(aName .. "autoquests", "QUEST_GREETING", function(_)
		self:printD("QUEST_GREETING", _G.GetNumActiveQuests(), _G.GetNumAvailableQuests())
		if self.isRtl then
			for questTitleButton in _G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive() do
				-- self:printD("QG", questTitleButton, questTitleButton.isActive)
				if not IsShiftKeyDown() then
					if questTitleButton then
						if questTitleButton.isActive == 1 then
							_G.SelectActiveQuest(questTitleButton:GetID())
						else
							_G.SelectAvailableQuest(questTitleButton:GetID())
						end
					end
				end
			end
		else
			local numActiveQuests, numAvailableQuests = _G.GetNumActiveQuests(), _G.GetNumAvailableQuests()
			-- self:printD("QUEST_GREETING#2", numActiveQuests, numAvailableQuests)
			for i = 1, numActiveQuests do
				if not IsShiftKeyDown() then
					-- self:printD("QUEST_GREETING#3", _G.select(2, _G.GetActiveTitle(i)))
					if _G.select(2, _G.GetActiveTitle(i)) then
						_G.SelectActiveQuest(_G["QuestTitleButton" .. i]:GetID())
					end
				end
			end
			for i = numActiveQuests + 1, numActiveQuests + numAvailableQuests do
				-- self:printD("QUEST_GREETING#4", i)
				if not IsShiftKeyDown() then
					_G.SelectAvailableQuest(_G["QuestTitleButton" .. i]:GetID())
				end
			end
		end
	end)
	-- Auto Progress Quest
	self.ae.RegisterEvent(aName .. "autoquests", "QUEST_PROGRESS", function(_)
		self:printD("QUEST_PROGRESS")
		if _G.IsQuestCompletable()
		and not IsShiftKeyDown()
		then
			_G.CompleteQuest()
		end
	end)
	-- Auto Complete Quest
	self.ae.RegisterEvent(aName .. "autoquests", "QUEST_COMPLETE", function(_)
		self:printD("QUEST_COMPLETE", _G.GetNumQuestChoices(), IsShiftKeyDown())
		if _G.GetNumQuestChoices() < 2
		and not IsShiftKeyDown()
		then
			_G.QuestRewardCompleteButton_OnClick()
		end
	end)

	if self.isRtl then
		local function acceptQuest(questID)
			-- local questTitle = _G.C_QuestLog.GetTitleForQuestID(questID)
			-- if ( questTitle and questTitle ~= "" ) then
			-- 	local block = _G.QUEST_TRACKER_MODULE:GetBlock(questID, "ScrollFrame", "AutoQuestPopUpBlockTemplate")
			-- 	--@debug@
			-- 	_G.C_Timer.After(1, function()
			-- 		_G.Spew("acceptQuest", block)
			-- 		_G.Spew("acceptQuest", block.module)
			-- 	end)
			-- 	--@end-debug@
			-- 	_G.AutoQuestPopUpTracker_OnMouseUp(block, "LeftButton", true)
			-- end
			_G.AutoQuestPopupTracker_RemovePopUp(questID)
		end
		aObj.ah:SecureHook("AutoQuestPopupTracker_AddPopUp", function(questID, _, _)
			self:printD("AutoQuestPopupTracker_AddPopUp", questID)
			acceptQuest(questID)
		end)
		self:printD("GetNumAutoQuestPopUps", _G.GetNumAutoQuestPopUps())
		for i = 1, _G.GetNumAutoQuestPopUps() do
			local questID, _ = _G.GetAutoQuestPopUp(i)
			self:printD("GetAutoQuestPopUp", questID, popUpType)
			acceptQuest(questID)
		end
	end

end

function aObj:checkQuest(id)
	_G.print(_G.C_QuestLog.IsQuestFlaggedCompleted(id))
end
