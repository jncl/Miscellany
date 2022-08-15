local aName, aObj = ...
local _G = _G

local select = _G.select

-- AutoRepair by Ygrane
-- Sell Junk by Tekkub
aObj.ae.RegisterEvent(aName, "MERCHANT_SHOW", function(_)
	if select(2, _G.GetRepairAllCost()) then _G.RepairAllItems() end

	if _G.IsShiftKeyDown() then return end

	-- N.B. CAN'T sell junk at Worn Anvil(s) in Torghast, Tower of the Damned
	if _G.GetRealZoneText():find("Torghast")
	and _G.UnitName("NPC") == "Worn Anvil"
	then
		return
	end

	-- _G.print("Misc - autorepair", _G.UnitName("NPC"))

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
						 _G.PickupMerchantItem(0)
					 else
						 _G.DeleteCursorItem()
					 end
				 end
			 end
		 end
	 end

end)
