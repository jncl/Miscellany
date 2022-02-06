local _, aObj = ...
local _G = _G

function aObj:AddDebugChatFrame() -- luacheck: ignore self

	local id = 10
	local cf = _G["ChatFrame" .. id]
	local cft = _G["ChatFrame" .. id .. "Tab"]

	_G.FCF_SetWindowName(cf, "Dbug")
	_G.FCF_SetWindowColor(cf, _G.DEFAULT_CHATFRAME_COLOR.r, _G.DEFAULT_CHATFRAME_COLOR.g, _G.DEFAULT_CHATFRAME_COLOR.b)
	_G.FCF_SetWindowAlpha(cf, 0)
	cf:Clear()
	_G.ChatFrame_RemoveAllMessageGroups(cf)
	_G.ChatFrame_RemoveAllChannels(cf)
	_G.ChatFrame_ReceiveAllPrivateMessages(cf)
	cf.editBox:ClearHistory()
	cf:SetMaxLines(10000)

	cf:Show()
	cft:Show()

	_G.FCF_DockFrame(cf, (#_G.FCFDock_GetChatFrames(_G.GENERAL_CHAT_DOCK) + 1), true)

	for i = 1, _G.NUM_CHAT_WINDOWS do
		_G.SetChatWindowLocked(i, false)
		local fObj = _G["ChatFrame" .. i]
		if fObj then
			_G.FCFTab_UpdateAlpha(fObj)
			_G.FCF_SetChatWindowFontSize(nil, fObj, 12)
			_G.FCF_SetWindowAlpha(fObj, 0)
		end
		if i == 1 then fObj:SetMaxLines(1000) end
	end

end
