local _, aObj = ...
local _G = _G

-- Maximum sellPrice
local maxSP = 250

local delItems = {
	34498, -- Paper Zepplin Kit
}
local function deleteItem(item, button)
    if button == "RightButton"
    and _G.IsAltKeyDown()
    then
		local bagID, slotID, info, itemInfo
		-- print("RB & Alt keys pressed")
		if not aObj.isRtl then
			bagID, slotID = item:GetParent():GetID(), item:GetID()
		else
			bagID, slotID = item:GetBagID(), item:GetID()
		end
		-- _G.Spew("item", item, bagID, slotID)
		info = _G.C_Container.GetContainerItemInfo(bagID, slotID)
		itemInfo = {_G.C_Item.GetItemInfo(info.itemID)}
		if item.hasItem
		and not info.isLocked
		and (info.hasNoValue or itemInfo[11] <= maxSP)
		or _G.tContains(delItems, info.itemID)
		then
			_G.C_Container.PickupContainerItem(bagID, slotID)
			if _G.CursorHasItem() then
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
	aObj.ah:SecureHook(_G.ContainerFrameItemButtonMixin, "OnModifiedClick", function(item, button)
		deleteItem(item, button)
	end)
end

