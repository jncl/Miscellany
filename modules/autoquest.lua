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
		if not self.isClsc then
			self.ah:Unhook("AutoQuestPopupTracker_Update")
		end
		return
	end

	local IsShiftKeyDown = _G.IsShiftKeyDown
	-- AutoGossip by Ygrane
	-- N.B. GossipFrame used for FlightMap
	self.ae.RegisterEvent(aName .. "autoquests", "GOSSIP_SHOW", function(_)
		local btnCnt = _G.GossipFrame.buttons and #_G.GossipFrame.buttons or _G.GossipFrame.buttonIndex
		self:printD("GOSSIP_SHOW", btnCnt)

		if btnCnt then
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
				self:printD(btn, btn.type, btn:GetID(), qIncomplete)
				if not IsShiftKeyDown() then
					if btn.type == "Available" then
						if _G.C_GossipInfo
						and _G.C_GossipInfo.SelectAvailableQuest
						then
							_G.C_GossipInfo.SelectAvailableQuest(btn:GetID())
						else
							_G.SelectGossipAvailableQuest(btn:GetID())
						end
						break
					elseif btn.type == "Active"
					and not qIncomplete -- ignore Incomplete quests
					then
						if _G.C_GossipInfo
						and	_G.C_GossipInfo.SelectActiveQuest
						then
							_G.C_GossipInfo.SelectActiveQuest(btn:GetID())
						else
							_G.SelectGossipActiveQuest(btn:GetID())
						end
						break
					elseif btn.type == "Gossip" then
						if _G.C_GossipInfo
						and _G.C_GossipInfo.GetNumOptions
						then
							if _G.C_GossipInfo.GetNumOptions() == 1 then
								_G.C_GossipInfo.SelectOption(btn:GetID())
							end
						elseif _G.GetNumGossipOptions() == 1 then
							_G.SelectGossipOption(btn:GetID())
							self:printD(btn:GetText())
							-- Rogue OrderHall access check
							if btn:GetText() == "<Lay your insignia on the table.>" then
								_G.SelectGossipOption(btn:GetID())
							end
						end
						break
					end
				end
			end
		end

		-- -- Bodyguard dialog check
		-- if o
		-- and not IsShiftKeyDown()
		-- and (o:find("head back to the barracks.") or q and q:find("head back to the barracks."))
		-- then
		-- 	return
		-- end

	end)
	-- Auto Accept Quest
	self.ae.RegisterEvent(aName .. "autoquests", "QUEST_DETAIL", function(_)
		aObj:printD("QUEST_DETAIL")
		if not IsShiftKeyDown()	then
			_G.AcceptQuest()
		end
	end)
	-- Auto Accept/Complete Multiple Quests
	self.ae.RegisterEvent(aName .. "autoquests", "QUEST_GREETING", function(_)
		self:printD("QUEST_GREETING", _G.GetNumActiveQuests(), _G.GetNumAvailableQuests())
		if not aObj.isClsc then
			for questTitleButton in _G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive() do
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
			self:printD("QUEST_GREETING#2", numActiveQuests, numAvailableQuests)
			for i = 1, numActiveQuests do
				if not IsShiftKeyDown() then
					-- aObj:printD("QUEST_GREETING#3", _G.select(2, _G.GetActiveTitle(i)))
					if _G.select(2, _G.GetActiveTitle(i)) then
						_G.SelectActiveQuest(_G["QuestTitleButton" .. i]:GetID())
					end
				end
			end
			for i = numActiveQuests + 1, numActiveQuests + numAvailableQuests do
				self:printD("QUEST_GREETING#4", i)
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
			return
		end
	end)

	if not self.isClsc then
		-- Auto Accept AutoQuest popup
		-- self.ae.RegisterEvent(aName, "QUEST_WATCH_LIST_CHANGED", function(...)
		-- 	self:printD("QUEST_WATCH_LIST_CHANGED")
		-- 	local function acceptQuest(block)
		-- 		_G.C_Timer.After(0.15, function()
		-- 			_G.AutoQuestPopUpTracker_OnMouseDown(block)
		-- 		end)
		-- 	end
		-- 	local _, questID, added = ...
		-- 	if added then
		-- 		-- if not aObj.isBeta then
		-- 		-- 	acceptQuest(_G.AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(questID))
		-- 		-- end
		-- 	else
		-- 		for i = 1, _G.GetNumAutoQuestPopUps() do
		-- 			questID, _ = _G.GetAutoQuestPopUp(i)
		-- 			-- aObj:printD(questID)
		-- 			if not _G.C_QuestLog.IsQuestBounty(questID) then
		-- 				-- TODO: replace with new version
		-- 				-- 	acceptQuest(_G.AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(questID))
		-- 			end
		-- 		end
		-- 	end
		-- end)
		self.ah:SecureHook("AutoQuestPopupTracker_Update", function(owningModule)
			-- self:printD("AutoQuestPopupTracker_Update", owningModule)
		end)
	end

end