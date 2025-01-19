local aName, aObj = ...
local _G = _G

if _G.C_VideoOptions.GetGxAdapterInfo()[1].name ~= "Apple M4 Pro"
or _G.C_CVar.GetCVar("gxMonitor") ~= 1
then
	return
end

function aObj.adjustBars()

	aObj:printD("chocolatebar loaded")

	local yAdj = aObj.isRtl and 32 or 24
	local cBar = _G.LibStub:GetLibrary("AceAddon-3.0"):GetAddon("ChocolateBar", true)
	local point, relTo, relPoint, xOfs, yOfs
	for _, bar in _G.pairs(cBar:GetBars()) do
		point, relTo, relPoint, xOfs, yOfs = bar:GetPoint()
		bar:SetPoint(point, relTo, relPoint, xOfs, yOfs + yAdj)
	end

	-- use a resolution of 2560x1440 for Retail
	local scale = 0.65
	-- local scale = aObj.isRtl and 0.5333 or 0.65
	_G.C_Timer.After(0.25, function()
		_G.UIParent:SetScale(scale)
	end)

-- -- move frame down if chocolate bar is loaded
-- if _G.C_AddOns.IsAddOnLoaded("ChocolateBar") then
-- 	_G.UIWidgetTopCenterContainerFrame:SetPoint("TOP", 0, -25)
-- end

end

aObj.RegisterCallback(aName .. "chocolatebar", "AddOn_Loaded", function(_, _)
	if _G.C_AddOns.IsAddOnLoaded("ChocolateBar") then
		aObj.adjustBars()
	end
	aObj.UnregisterCallback(aName .. "chocolatebar", "AddOn_Loaded")
end)
aObj.SCL["cb"] = function()
	aObj.adjustBars()
end
