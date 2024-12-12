local aName, aObj = ...
local _G = _G

function aObj:autoQuests()

	self:printD("autoQuests loaded", _G.misc_sv_pc.autoquest)

	-- if autoquest isn't set then Unregister Events and return
	if not _G.misc_sv_pc.autoquest then
		self.ae.UnregisterEvent(aName .. "autoquest", "GOSSIP_SHOW")
		self.ae.UnregisterEvent(aName .. "autoquest", "QUEST_DETAIL")
		self.ae.UnregisterEvent(aName .. "autoquest", "QUEST_GREETING")
		self.ae.UnregisterEvent(aName .. "autoquest", "QUEST_PROGRESS")
		self.ae.UnregisterEvent(aName .. "autoquest", "QUEST_COMPLETE")
		if self.isRtl then
			self.ae.UnregisterEvent(aName .. "autoquest", "QUEST_WATCH_LIST_CHANGED")
		end
		return
	end

	local delay, gotQuest = 30, false
	local function closePanels()
		_G.C_Timer.After(delay, function()
			_G.C_GossipInfo.CloseGossip()
			_G.HideUIPanel(_G.QuestFrame)
		end)
		gotQuest = false
	end
	local ignStrings = {
		["review my basic training"] = true,
		["Dagger in the Dark"]       = true, -- Rogue access to OrderHall in Dalaran
	}

	local IsShiftKeyDown = _G.IsShiftKeyDown
	-- AutoGossip by Ygrane
	-- N.B. GossipFrame used for FlightMap
	local eData
	local function doQuest(elementData)
		-- self:printD("doQuest", elementData.info.questID, elementData.info.isComplete, elementData.info.repeatable)
		-- if aObj.debug then
		-- 	_G.Spew("dq elementData.info", elementData.info)
		-- end
		if elementData.info.isComplete then
			_G.C_GossipInfo.SelectActiveQuest(elementData.info.questID)
			closePanels()
		elseif not elementData.info.repeatable then
			_G.C_GossipInfo.SelectAvailableQuest(elementData.info.questID)
			closePanels()
		end
	end
	-- GOSSIP_BUTTON_TYPE_TITLE = 1
	-- GOSSIP_BUTTON_TYPE_DIVIDER = 2
	-- GOSSIP_BUTTON_TYPE_OPTION = 3
	-- GOSSIP_BUTTON_TYPE_ACTIVE_QUEST = 4
	-- GOSSIP_BUTTON_TYPE_AVAILABLE_QUEST = 5
	self.ae.RegisterEvent(aName .. "autoquest", "GOSSIP_SHOW", function(_)
		-- self:printD("GOSSIP_SHOW")
		local cnt, savedElement, ignore = 0
		local function skinGossip(...)
			local element, elementData, new, _
			if _G.select("#", ...) == 2 then
				element, elementData = ...
			elseif _G.select("#", ...) == 3 then
				element, elementData, new = ...
			else
				_, element, elementData, new = ...
			end
			if gotQuest then return end
			if new ~= false then
				-- self:printD("skinElement#1", elementData.buttonType)
				-- if aObj.debug then
					-- _G.Spew("gs elementData", elementData)
					-- _G.Spew("gs elementData.info", elementData.info)
				-- end
				if not IsShiftKeyDown() then
					if elementData.buttonType == _G.GOSSIP_BUTTON_TYPE_ACTIVE_QUEST
					or elementData.buttonType == _G.GOSSIP_BUTTON_TYPE_AVAILABLE_QUEST
					then
						doQuest(elementData)
						gotQuest = true
					elseif elementData.buttonType == _G.GOSSIP_BUTTON_TYPE_OPTION then
						cnt = cnt + 1
						if elementData.info.flags == _G.Enum.GossipOptionRecFlags.QuestLabelPrepend then
							-- self:printD("selecting (Quest) option", cnt, element:GetID())
							savedElement = element
						elseif aObj.uCls == "HUNTER"
						and elementData.info.gossipOptionID == 36816 -- Pet Stable
						then
							savedElement = element
						elseif cnt == 1 then
							savedElement = element
						end
					end
				end
			end
		end
		_G.ScrollUtil.AddInitializedFrameCallback(_G.GossipFrame.GreetingPanel.ScrollBox, skinGossip, aObj, true)
		if savedElement then
			-- self:printD("skinElement#2", cnt, savedElement:GetID())
			eData = savedElement:GetElementData()
			-- if aObj.debug then
				-- _G.Spew("savedElement", savedElement)
				-- _G.Spew("eData", eData)
			-- end
			-- ignore gossip option if required
			ignore = false
			for str, _ in _G.pairs(ignStrings) do
				if eData.info.name:find(str) then
					ignore = true
					break
				end
			end
			if not ignore then
				_G.C_GossipInfo.SelectOptionByIndex(savedElement:GetID())
			end
		end
		closePanels()
	end)

	-- Auto Accept Quest
	self.ae.RegisterEvent(aName .. "autoquest", "QUEST_DETAIL", function(_)
		-- self:printD("QUEST_DETAIL")
		if not IsShiftKeyDown()	then
			_G.AcceptQuest()
		end
	end)

	-- Auto Accept/Complete Multiple Quests
	self.ae.RegisterEvent(aName .. "autoquest", "QUEST_GREETING", function(_)
		if self.isRtl then
			for questTitleButton in _G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive() do
				-- self:printD("QG", questTitleButton, questTitleButton.isActive)
				-- if aObj.debug then
				-- 	_G.Spew("qg questTitleButton", questTitleButton)
				-- end
				if not IsShiftKeyDown() then
					if questTitleButton then
						if questTitleButton.isActive == 1 then
							_G.C_GossipInfo.SelectActiveQuest(questTitleButton:GetID())
						else
							_G.C_GossipInfo.SelectAvailableQuest(questTitleButton:GetID())
						end
					end
				end
			end
		else
			local numActiveQuests, numAvailableQuests = _G.GetNumActiveQuests(), _G.GetNumAvailableQuests()
			-- self:printD("QUEST_GREETING#1", numActiveQuests, numAvailableQuests)
			for i = 1, numActiveQuests do
				if not IsShiftKeyDown() then
					-- self:printD("QUEST_GREETING#2", _G.select(2, _G.GetActiveTitle(i)))
					if _G.select(2, _G.GetActiveTitle(i)) then
						_G.SelectActiveQuest(_G["QuestTitleButton" .. i]:GetID())
					end
				end
			end
			for i = numActiveQuests + 1, numActiveQuests + numAvailableQuests do
				-- self:printD("QUEST_GREETING#3", i)
				if not IsShiftKeyDown() then
					_G.SelectAvailableQuest(_G["QuestTitleButton" .. i]:GetID())
				end
			end
		end
	end)

	-- Auto Progress Quest
	self.ae.RegisterEvent(aName .. "autoquest", "QUEST_PROGRESS", function(_)
		-- self:printD("QUEST_PROGRESS", _G.GetTitleText())
		-- DON'T autocomplete MoP Remix rep handins
		if _G.GetTitleText():find('Aid the') then return end
		if _G.IsQuestCompletable()
		and not IsShiftKeyDown()
		then
			_G.CompleteQuest()
		end
	end)

	-- Auto Complete Quest
	self.ae.RegisterEvent(aName .. "autoquest", "QUEST_COMPLETE", function(_)
		-- self:printD("QUEST_COMPLETE", _G.GetNumQuestChoices(), IsShiftKeyDown())
		if _G.GetNumQuestChoices() < 2
		and not IsShiftKeyDown()
		then
			_G.QuestRewardCompleteButton_OnClick()
		end
	end)

	if self.isRtl then
		local questTitle, block
		local function acceptAPQuest(questID, popUpType)
			questTitle = _G.C_QuestLog.GetTitleForQuestID(questID)
			self:printD("acceptAPQuest", questTitle, popUpType)
			if questTitle
			and questTitle ~= ""
			then
				block = _G.QuestObjectiveTracker:GetBlock(questID, "AutoQuestPopUpBlockTemplate")
				--@debug@
				-- _G.C_Timer.After(0.25, function() -- wait for Spew to be loaded
					-- _G.Spew("acceptAPQuest", block)
					-- _G.Spew("acceptAPQuest Contents", block.Contents)
				-- end)
				--@end-debug@
				if popUpType == "OFFER" then
					_G.ShowQuestOffer(questID)
				else
					_G.ShowQuestComplete(questID)
				end
				block.parentModule:RemoveAutoQuestPopUp(questID)
			end
		end
		aObj.ah:SecureHook(_G.AutoQuestPopupTrackerMixin, "AddAutoQuestPopUp", function(this, questID, popUpType, itemID)
			-- self:printD("AutoQuestPopupTracker AddAutoQuestPopUp", questID, popUpType, itemID)
			acceptAPQuest(questID, popUpType)
		end)
		_G.C_Timer.After(2, function() -- wait for everything to be loaded
			for i = 1, _G.GetNumAutoQuestPopUps() do
				local questID, popUpType = _G.GetAutoQuestPopUp(i)
				self:printD("GetAutoQuestPopUp", questID, popUpType)
				acceptAPQuest(questID, popUpType)
			end
		end)
	end

end

function aObj.checkQuest(_, id)
	_G.print(_G.C_QuestLog.IsQuestFlaggedCompleted(id))
end

aObj.RegisterCallback(aName .. "autoquest", "AddOn_Loaded", function(_, _)
	_G.misc_sv_pc.autoquest = _G.misc_sv_pc.autoquest or false
	aObj:autoQuests()
	aObj.UnregisterCallback(aName .. "autoquest", "AddOn_Loaded")
end)
aObj.SCL["aq"] = function()
	_G.misc_sv_pc.autoquest = not _G.misc_sv_pc.autoquest
	aObj:autoQuests()
end
aObj.SCL["cq"] = aObj.checkQuest
