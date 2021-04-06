local aName, aObj = ...
local _G = _G

local select = _G.select

-- AutoRepair by Ygrane
-- Sell Junk by Tekkub
aObj.ae.RegisterEvent(aName, "MERCHANT_SHOW", function(...)
	if not aObj.isClsc then
		-- repair gear using Guild funds if available
		local gbMoney, repairAllCost, canRepair = _G.GetGuildBankMoney(), _G.GetRepairAllCost()
		-- printD("Guild Repair", canRepair, repairAllCost <= gbMoney, _G.CanGuildBankRepair())
		if canRepair then _G.RepairAllItems(_G.CanGuildBankRepair()) end
		gbMoney, repairAllCost, canRepair = nil, nil, nil
	else
		if select(2, _G.GetRepairAllCost()) then _G.RepairAllItems() end
	end

	if _G.IsShiftKeyDown() then return end

	-- Sell Junk, blatantly copied from SellJunk
	local grey, currPrice
	for bag = 0, 4 do
		for slot = 1, _G.GetContainerNumSlots(bag) do
			local link = _G.GetContainerItemLink(bag, slot)
			if link then
				grey = select(3, _G.GetItemInfo(link)) == 0 and true or false
				if grey then
					 currPrice = select(11, _G.GetItemInfo(link))
					 _G.PickupContainerItem(bag, slot)
					 -- ignore unsellable grey items
					 if currPrice > 0 then
						 _G.PickupMerchantItem()
					 else
						 _G.DeleteCursorItem()
					 end
				 end
				 grey = nil
			 end
		 end
	 end
	 grey, currPrice = nil, nil

end)
