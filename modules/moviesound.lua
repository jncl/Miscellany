local aName, aObj = ...
local _G = _G

-- turn on sound when CinematicFrame or MovieFrame shows
local seas
local function enableSound()

	seas = _G.GetCVar("Sound_EnableAllSound")

	_G.SetCVar("Sound_EnableAllSound", 1)
	_G.SetCVar("Sound_EnableSFX", 0)
	_G.Sound_ToggleSound()

end
local function disableSound()

	_G.SetCVar("Sound_EnableAllSound", seas)
	_G.Sound_ToggleSound()

end
local cbs, cbp
local function enableChatBubbles()

	-- print("Misc enableChatBubbles#1:", _G.GetCVar("chatBubbles"), _G.GetCVar("chatBubblesParty"))

	cbs = _G.GetCVar("chatBubbles")
	cbp = _G.GetCVar("chatBubblesParty")

	_G.SetCVar("chatBubbles", 1)
	_G.SetCVar("chatBubblesParty", 1)

	-- print("Misc enableChatBubbles#2:", _G.GetCVar("chatBubbles"), _G.GetCVar("chatBubblesParty"))

end
local function disableChatBubbles()

	-- print("Misc disableChatBubbles#1:", _G.GetCVar("chatBubbles"), _G.GetCVar("chatBubblesParty"))

	_G.SetCVar("chatBubbles", cbs)
	_G.SetCVar("chatBubblesParty", cbp)

	-- print("Misc disableChatBubbles#2:", _G.GetCVar("chatBubbles"), _G.GetCVar("chatBubblesParty"))

end
aObj.ae.RegisterEvent(aName, "CINEMATIC_START", function(event, ...)

	enableChatBubbles()
	enableSound()

end)
aObj.ae.RegisterEvent(aName, "CINEMATIC_STOP", function(event, ...)

	disableChatBubbles()
	disableSound()

end)
local mst = GetCVarBool("movieSubtitle") or 0
aObj.ae.RegisterEvent(aName, "PLAY_MOVIE", function(event, ...)

	enableChatBubbles()
	enableSound()

	if not _G.GetCVarBool("movieSubtitle") then
		_G.SetCVar("movieSubtitle", 1)
		_G.MovieFrame:EnableSubtitles(_G.GetCVarBool("movieSubtitle"))
		mst = 1
	end

end)
aObj.ah:SecureHook("GameMovieFinished", function()

	disableChatBubbles()
	disableSound()

	if _G.GetCVarBool("movieSubtitle")
	and _G.GetCVarBool("movieSubtitle") ~= mst
	then
		_G.SetCVar("movieSubtitle", 0)
		_G.MovieFrame:EnableSubtitles(_G.GetCVarBool("movieSubtitle"))
		mst = 0
	end

end)
