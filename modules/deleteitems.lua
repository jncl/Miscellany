local _, aObj = ...
local _G = _G

local delItems = {
	34498, -- Paper Zepplin Kit
}
local function deleteItem(item, button)
    if button == "RightButton"
    and _G.IsAltKeyDown()
    then
		local bagID, slotID, info, hasNoValue, isLocked, pickupItemFunc
		-- print("RB & Alt keys pressed")
		if not aObj.isRtl then
			bagID, slotID = item:GetParent():GetID(), item:GetID()
		else
			bagID, slotID = item:GetBagID(), item:GetID()
		end
		-- _G.Spew("item", item, bagID, slotID)
		info = _G.C_Container.GetContainerItemInfo(bagID, slotID)
		isLocked = info.isLocked
		hasNoValue = info.hasNoValue
		pickupItemFunc = _G.C_Container.PickupContainerItem
		-- _G.Spew("info", info)
		-- print("Item values", item.hasItem, hasNoValue, not isLocked)
		if item.hasItem
		and not isLocked
		and hasNoValue
		or _G.tContains(delItems, info.itemID)
		then
			-- print("PickupContainerItem", item)
			pickupItemFunc(bagID, slotID)
			if _G.CursorHasItem() then
				-- print("CursorHasItem", item)
				_G.DeleteCursorItem()
			end
		end
	end
end

-- delete item from Bag if Alt+Right Clicked
if not aObj.isRtl then
	aObj.ah:SecureHook("ContainerFrameItemButton_OnModifiedClick", function(item, button)
		deleteItem(item, button)
	end)
else
	-- print("deleteitems module loaded", _G.ContainerFrameItemButtonMixin.OnModifiedClick)
	-- _G.hooksecurefunc(_G.ContainerFrameItemButtonMixin, "OnModifiedClick", function(item, button)
	-- 	print("hsf CFIBM OnModifiedClick", item, button)
	-- end)
	aObj.ah:SecureHook(_G.ContainerFrameItemButtonMixin, "OnModifiedClick", function(item, button)
		-- print("CFIBM OnModifiedClick", item, button)
		deleteItem(item, button)
	end)
end

