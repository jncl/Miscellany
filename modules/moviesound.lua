local aName, aObj = ...
local _G = _G

local allSound, soundMasterVolume
local function getOriginalSettings()
	allSound            = _G.C_CVar.GetCVar("Sound_EnableAllSound")
	soundMasterVolume   = _G.C_CVar.GetCVar("Sound_MasterVolume")
	-- aObj:printD("getOriginalSettings", allSound, soundMasterVolume)
end

local function setOriginalSettings()
	_G.C_CVar.SetCVar("Sound_EnableAllSound", allSound)
	_G.C_CVar.SetCVar("Sound_MasterVolume", soundMasterVolume)
	-- aObj:printD("setOriginalSettings", allSound, soundMasterVolume)
end

-- turn on sound when CinematicFrame or MovieFrame shows
local function enableSound()

	getOriginalSettings()

	_G.C_CVar.SetCVar("Sound_MasterVolume", 1.0)
	_G.C_CVar.SetCVar("Sound_EnableAllSound", 1)
	_G.C_CVar.SetCVar("Sound_EnableSFX", 0)
	_G.Sound_ToggleSound()

end
local function disableSound()

	_G.C_CVar.SetCVar("Sound_EnableSFX", 1)
	_G.Sound_ToggleSound()

	setOriginalSettings()

end

local cbs, cbp
local function enableChatBubbles()

	-- print("Misc enableChatBubbles#1:", _G.C_CVar.GetCVar("chatBubbles"), _G.C_CVar.GetCVar("chatBubblesParty"))

	cbs = _G.C_CVar.GetCVar("chatBubbles")
	cbp = _G.C_CVar.GetCVar("chatBubblesParty")

	_G.C_CVar.SetCVar("chatBubbles", 1)
	_G.C_CVar.SetCVar("chatBubblesParty", 1)

	-- print("Misc enableChatBubbles#2:", _G.C_CVar.GetCVar("chatBubbles"), _G.C_CVar.GetCVar("chatBubblesParty"))

end
local function disableChatBubbles()

	-- print("Misc disableChatBubbles#1:", _G.C_CVar.GetCVar("chatBubbles"), _G.C_CVar.GetCVar("chatBubblesParty"))

	_G.C_CVar.SetCVar("chatBubbles", cbs)
	_G.C_CVar.SetCVar("chatBubblesParty", cbp)

	-- print("Misc disableChatBubbles#2:", _G.C_CVar.GetCVar("chatBubbles"), _G.C_CVar.GetCVar("chatBubblesParty"))

end
aObj.ae.RegisterEvent(aName, "CINEMATIC_START", function(_, _)

	enableChatBubbles()
	enableSound()

end)
aObj.ae.RegisterEvent(aName, "CINEMATIC_STOP", function(_, _)

	disableChatBubbles()
	disableSound()

end)

local mst = _G.C_CVar.GetCVar("movieSubtitle") or 0
aObj.ae.RegisterEvent(aName, "PLAY_MOVIE", function(_, _)

	enableChatBubbles()
	enableSound()

	_G.MovieFrame:EnableSubtitles(true)

end)
aObj.ae.RegisterEvent(aName, "STOP_MOVIE", function(_, _)

	disableChatBubbles()
	disableSound()

	if _G.C_CVar.GetCVar("movieSubtitle") ~= mst then
		_G.C_CVar.SetCVar("movieSubtitle", mst)
		_G.MovieFrame:EnableSubtitles(_G.C_CVar.GetCVarBool("movieSubtitle"))
	end

end)
