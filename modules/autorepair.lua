local aName, aObj = ...
local _G = _G

function aObj.autoRepair(_)

	aObj:printD("autoRepair loaded", _G.misc_sv_pc.autorepair)

	-- if autoqrepair isn't set then Unregister Events and return
	if not _G.misc_sv_pc.autorepair then
		aObj.ae.UnregisterEvent(aName .. "autorepair", "MERCHANT_SHOW")
		return
	end

	aObj.ae.RegisterEvent(aName .. "autorepair", "MERCHANT_SHOW", function(...)
		aObj:printD(..., _G.select(2, _G.GetRepairAllCost()), _G.C_MerchantFrame.GetNumJunkItems(), _G.C_MerchantFrame.IsSellAllJunkEnabled())

		if _G.select(2, _G.GetRepairAllCost()) then -- check to see if merchant can repair
			_G.RepairAllItems(true) -- use GuildFunds if available
		end

		if _G.IsShiftKeyDown() then return end

		if _G.C_MerchantFrame.GetNumJunkItems()
		and _G.C_MerchantFrame.IsSellAllJunkEnabled()
		then
			_G.C_MerchantFrame.SellAllJunkItems()
		end

	end)

end

aObj.RegisterCallback(aName .. "autorepair", "AddOn_Loaded", function(_, _)
	_G.misc_sv_pc.autorepair = _G.misc_sv_pc.autorepair or false
	aObj.autoRepair()
	aObj.UnregisterCallback(aName .. "autorepair", "AddOn_Loaded")
end)
aObj.SCL["ar"] = function()
	_G.misc_sv_pc.autorepair = not _G.misc_sv_pc.autorepair
	aObj.autoRepair()
end
