local aName, aObj = ...
local _G = _G

local ToggleAllBags, CloseAllBags, OpenAllBags = _G.ToggleAllBags, _G.CloseAllBags, _G.OpenAllBags
-- Open/Close bags
aObj.ae.RegisterEvent(aName, "BANKFRAME_OPENED", function(...)
	ToggleAllBags() -- N.B. DOESN'T work here (PTR)
	OpenAllBags()
end)
aObj.ae.RegisterEvent(aName, "BANKFRAME_CLOSED", function(...)
	CloseAllBags()
end)
if not aObj.isClsc then
	aObj.ae.RegisterEvent(aName, "GUILDBANKFRAME_OPENED", function(...)
		ToggleAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "GUILDBANKFRAME_CLOSED", function(...)
		CloseAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "OBLITERUM_FORGE_SHOW", function(...)
		ToggleAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "OBLITERUM_FORGE_CLOSE", function(...)
		CloseAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "SCRAPPING_MACHINE_SHOW", function(...)
		ToggleAllBags() -- N.B. DOESN'T work here (PTR)
		OpenAllBags()
	end)
	aObj.ae.RegisterEvent(aName, "SCRAPPING_MACHINE_CLOSE", function(...)
		CloseAllBags()
	end)
end

