local aName, aObj = ...
local _G = _G

if aObj.uCls ~= "ROGUE" then return end

-- hide StanceBar Frame
_G.StanceBarFrame:Hide()

if aObj.isClsc then
	-- get dagger from bag
	-- get current MH

	-- aObj.ae.RegisterEvent(aName .. "-rogue", "UPDATE_SHAPESHIFT_FORM", function ()
	-- 	local name, active
	-- 	for i = 1, _G.GetNumShapeshiftForms() do
	-- 		local _, name, active = _G.GetShapeshiftFormInfo(i)
	-- 		if active then
	-- 			shifted = true
	-- 			-- equip dagger
	-- 			return
	-- 		end
	-- 	end
	-- 	shifted = false
	-- 	 -- re-equip MH
	-- end)

else
	aObj.ae.RegisterEvent(aName .. "-rogue", "PLAYER_LOGIN", function(_, _)
		local equipmentSetID = _G.C_EquipmentSet.GetEquipmentSetID("Stealth")
		-- change EquipmentSet when stealthed, based upon EventEquip function
		if _G.C_EquipmentSet.GetNumEquipmentSets() > 0
		and equipmentSetID
		-- and _G.GetEquipmentSetInfoByName("Stealth")
		then
			local function checkAndEquip(eSet)
				local sTime, eTime = _G.select(5, _G.UnitCastingInfo("player"))
				if eTime then -- casting in progress, equip after cast has finished, otherwise error and not equipped
					aObj.at.ScheduleTimer(function(setID)
						_G.EquipmentManager_EquipSet(setID)
					end, (eTime - sTime) / 1000 + 0.1, eSet)
				else
					_G.EquipmentManager_EquipSet(eSet)
				end
			end
			-- aObj:printD(aName, "- Rogue's Stealth EquipmentSet detected")
			local curSet, shifted = "Normal", false
			aObj.ah.SecureHook(aName .. "-rogue", "UseEquipmentSet", function(setName)
				if not shifted then curSet = setName end
			end)
			aObj.ae.RegisterEvent(aName .. "-rogue", "UPDATE_SHAPESHIFT_FORM", function ()
				local _, name, active
				for i = 1, _G.GetNumShapeshiftForms() do
					_, name, active = _G.GetShapeshiftFormInfo(i)
					-- if active and _G.GetEquipmentSetInfoByName(name) then
					if active
					and _G.C_EquipmentSet.GetEquipmentSetID(name)
					then
						shifted = true
						checkAndEquip(name) -- equip shapeshift set if it exists
						return
					end
				end
				shifted = false
				checkAndEquip(curSet) -- re-equip previous set
			end)
		end
	end)

	-- -- check for Blade Flurry buff
	-- bfEvt = nil
	-- function check_for_bf()
	-- 	aObj.at.CancelTimer(aName .. "-rogue", bfEvt, true)
	-- 	bfEvt = nil
	-- 	for i = 1, 40 do
	-- 		aObj:printD("UnitBuff", i, _G.UnitBuff("player", i))
	-- 		if _G.UnitBuff("player", i) == "Blade Flurry" then
	-- 			_G.UIErrorsFrame:AddMessage("Disable Blade Flurry", 1.0, 0.0, 0.0, nil, 5)
	-- 			bfEvt = aObj.at.ScheduleRepeatingTimer(aName .. "-rogue", check_for_bf, 5)
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- check_for_bf()
	-- -- hook these to enable/disable the timer
	-- aObj.ae.RegisterEvent(aName .. "-rogue", "PLAYER_REGEN_DISABLED", function(...)
	-- 	check_for_bf()
	-- end)
	-- aObj.ae.RegisterEvent(aName .. "-rogue", "PLAYER_REGEN_ENABLED", function(...)
	-- 	check_for_bf()
	-- end)

	-- Pickpocketing bits for AutoBag
	-- local ppItems = {
	-- 	-- Rings
	-- 	[112995] = "Slimy Ring",
	-- 	[112996] = "Glistening Ring",
	-- 	[112997] = "Emerald Ring",
	-- 	[112998] = "Diamond Ring",
	-- 	[112998] = "Sapphire Ring",
	-- 	[127400] = "Wax Daubed Signet",
	-- 	[127406] = "Lovingly Polished Nose Ring",
	-- 	[127407] = "Lava Prism Ring",
	-- 	-- Amulets
	-- 	[113000] = "Oozing Amulet",
	-- 	[113001] = "Sparkling Amulet",
	-- 	[113002] = "Ruby Amulet",
	-- 	[113003] = "Opal Amulet",
	-- 	-- Necklaces
	-- 	[113004] = "Locket of Dreams",
	-- 	[113005] = "Chain of Hopes",
	-- 	[113006] = "Choker of Nightmares",
	-- 	[127398] = "Locket of Precious Memories",
	-- 	[127402] = "Limited Edition Choker (17 of 499)",
	-- 	[127404] = "Limited Edition Choker (237 of 499)",
	-- 	-- Assorted
	-- 	[113007] = "Magma-Infused Warbeads",
	-- 	[113008] = "Glowing Ancestral Idol",
	-- 	[127409] = "Sculpted Memorial Urn",
	-- }

	-- create a scanning tooltip
	local scantt = _G.CreateFrame("GameTooltip", aName .. "_Scan_TT", nil, "GameTooltipTemplate")
	scantt:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
	-- define default bags for pickpocketing items
	local ppBag1 = 3
	local ppBag2 = 1

	-- hook AutoBag check function to add checks for these items
	-- aObj.ah.SecureHook(aName .. "-rogue", "AB_ArrangeBags", function()

	-- trigger on BAG_UPDATE_DELAYED event
	aObj.ae.RegisterEvent(aName .. "-rogue", "BAG_UPDATE_DELAYED", function()
		-- for each bag
		for bn = 0, 4 do
		-- for each slot in this bag
			for sn = 1, _G.GetContainerNumSlots(bn) do
				scantt:SetBagItem(bn, sn)

				-- local nr = scantt:GetNumRegions()
				-- for i = 1, nr do
				-- 	local region = select(i, scantt:GetRegions())
				-- 	if region and region:GetObjectType() == "FontString" then
				-- 		local text = region:GetText()
				-- 		if text and bn == 3 then
				-- 			_G.print("Tooltip text:", i, text)
				-- 		end
				-- 	end
				-- end

				-- check for pickpocketing items and move them
				local ppt = _G.select(12, scantt:GetRegions())
				if ppt
				and ppt:GetObjectType() == "FontString"
				and ppt:GetText()
				and ppt:GetText():find("Pickpocketing")
				then
					if bn ~= ppBag1 and bn ~= ppBag2 then
						_G.PickupContainerItem(bn, sn)
						if (_G.GetContainerNumFreeSlots(ppBag1)) > 0 then
							_G.PutItemInBag(ppBag1 + 19)
						elseif (_G.GetContainerNumFreeSlots(ppBag2)) > 0 then
							_G.PutItemInBag(ppBag2 + 19)
						end
					end
				end

			end
		end
	end)

end
