local aName, aObj = ...
local _G = _G

-- Open/Close bags
aObj.ah:SecureHookScript(_G.BankFrame, "OnShow", function(_)
	_G.ToggleAllBags()
end)
aObj.ah:SecureHookScript(_G.BankFrame, "OnHide", function(_)
	_G.CloseAllBags()
end)
if not aObj.isClscERA then
	aObj.ae.RegisterEvent(aName .. "bagsopen", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", function(_, ...)
		local type = ...
		if type == 10 then
			aObj.ah:SecureHookScript(_G.GuildBankFrame, "OnShow", function(_)
				_G.ToggleAllBags()
			end)
			aObj.ah:SecureHookScript(_G.GuildBankFrame, "OnHide", function(_)
				_G.CloseAllBags()
			end)
			_G.ToggleAllBags()
		end
		aObj.ae.UnregisterEvent(aName .. "bagsopen", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end)
end

