-- luacheck: ignore 631 (line is too long)
local aName, aObj = ...
local _G = _G

local allSound, ambiance, dialog, emoteSounds, errorSpeech, music, petBattleMusic, petSounds, pingSounds, reverb, sfx, soundWhenGameIsInBG, soundMasterVolume
local function getOriginalSettings()
	allSound            = _G.C_CVar.GetCVar("Sound_EnableAllSound")
	ambiance            = _G.C_CVar.GetCVar("Sound_EnableAmbience")
	dialog              = _G.C_CVar.GetCVar("Sound_EnableDialog")
	emoteSounds         = _G.C_CVar.GetCVar("Sound_EnableEmoteSounds")
	errorSpeech         = _G.C_CVar.GetCVar("Sound_EnableErrorSpeech")
	music               = _G.C_CVar.GetCVar("Sound_EnableMusic")
	petBattleMusic      = _G.C_CVar.GetCVar("Sound_EnablePetBattleMusic")
	petSounds           = _G.C_CVar.GetCVar("Sound_EnablePetSounds")
	pingSounds          = _G.C_CVar.GetCVar("Sound_EnablePingSounds")
	reverb              = _G.C_CVar.GetCVar("Sound_EnableReverb")
	sfx                 = _G.C_CVar.GetCVar("Sound_EnableSFX")
	soundWhenGameIsInBG = _G.C_CVar.GetCVar("Sound_EnableSoundWhenGameIsInBG")
	soundMasterVolume   = _G.C_CVar.GetCVar("Sound_MasterVolume")
	aObj:printD("getOriginalSettings", allSound, ambiance, dialog, emoteSounds, errorSpeech, music, petBattleMusic, petSounds, pingSounds, reverb, sfx, soundWhenGameIsInBG, soundMasterVolume)
end

local function setOriginalSettings()
	_G.C_CVar.SetCVar("Sound_EnableAllSound", allSound)
	_G.C_CVar.SetCVar("Sound_EnableAmbience", ambiance)
	_G.C_CVar.SetCVar("Sound_EnableDialog", dialog)
	_G.C_CVar.SetCVar("Sound_EnableEmoteSounds", emoteSounds)
	_G.C_CVar.SetCVar("Sound_EnableErrorSpeech", errorSpeech)
	_G.C_CVar.SetCVar("Sound_EnableMusic", music)
	_G.C_CVar.SetCVar("Sound_EnablePetBattleMusic", petBattleMusic)
	_G.C_CVar.SetCVar("Sound_EnablePetSounds", petSounds)
	_G.C_CVar.SetCVar("Sound_EnablePingSounds", pingSounds)
	_G.C_CVar.SetCVar("Sound_EnableReverb", reverb)
	_G.C_CVar.SetCVar("Sound_EnableSFX", sfx)
	_G.C_CVar.SetCVar("Sound_EnableSoundWhenGameIsInBG", soundWhenGameIsInBG)
	_G.C_CVar.SetCVar("Sound_MasterVolume", soundMasterVolume)
	aObj:printD("setOriginalSettings", allSound, ambiance, dialog, emoteSounds, errorSpeech, music, petBattleMusic, petSounds, pingSounds, reverb, sfx, soundWhenGameIsInBG, soundMasterVolume)
end

-- turn on sound when CinematicFrame or MovieFrame shows
local function enableSound()

	getOriginalSettings()

	_G.C_CVar.SetCVar("Sound_EnableAllSound", 1)
	_G.C_CVar.SetCVar("Sound_EnableSFX", 1)
	_G.C_CVar.SetCVar("Sound_MasterVolume", 1.0)
	_G.Sound_ToggleSound()

end
local function disableSound()

	setOriginalSettings()
	_G.Sound_ToggleSound()

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
