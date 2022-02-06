local aName, aObj = ...
local _G = _G

local ToggleAllBags, CloseAllBags, OpenAllBags = _G.ToggleAllBags, _G.CloseAllBags, _G.OpenAllBags
-- Open/Close bags
aObj.ae.RegisterEvent(aName, "BANKFRAME_OPENED", function(_)
	ToggleAllBags() -- N.B. DOESN'T work here (PTR)
	OpenAllBags()
end)
aObj.ae.RegisterEvent(aName, "BANKFRAME_CLOSED", function(_)
	CloseAllBags()
end)
if not aObj.isClsc then
	aObj.ae.RegisterEvent(aName, "GUILDBANKFRAME_OPENED", function(_)
		ToggleAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "GUILDBANKFRAME_CLOSED", function(_)
		CloseAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "OBLITERUM_FORGE_SHOW", function(_)
		ToggleAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "OBLITERUM_FORGE_CLOSE", function(_)
		CloseAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "SCRAPPING_MACHINE_SHOW", function(_)
		ToggleAllBags() -- N.B. DOESN'T work here (PTR)
		OpenAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "SCRAPPING_MACHINE_CLOSE", function(_)
		CloseAllBags()
	end)
end

