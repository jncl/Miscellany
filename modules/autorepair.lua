local aName, aObj = ...
local _G = _G

local GetContainerNumSlots = _G.C_Container and _G.C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemLink = _G.C_Container and _G.C_Container.GetContainerItemLink or _G.GetContainerItemLink
local PickupContainerItem = _G.C_Container and _G.C_Container.PickupContainerItem or _G.PickupContainerItem
local GetItemInfo = _G.C_Container and _G.C_Container.GetItemInfo or _G.GetItemInfo

-- AutoRepair by Ygrane
-- Sell Junk by Tekkub
aObj.ae.RegisterEvent(aName, "MERCHANT_SHOW", function(_)
	-- _G.print("Misc - autorepair", _G.GetRealZoneText(), _G.UnitName("NPC"))
	if _G.select(2, _G.GetRepairAllCost()) then _G.RepairAllItems() end

	-- N.B. CAN'T sell junk at Worn Anvil(s) in Torghast, Tower of the Damned
	if _G.GetRealZoneText():find("Torghast")
	and _G.UnitName("NPC") == "Worn Anvil"
	then
		return
	end

	if _G.IsShiftKeyDown() then return end

	-- Sell Junk, blatantly copied from SellJunk
	local junk, currPrice
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				junk = _G.select(3, GetItemInfo(link)) == 0 and true or false
				if junk then
					 currPrice = _G.select(11, GetItemInfo(link))
					 PickupContainerItem(bag, slot)
					 -- ignore unsellable junk items
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
