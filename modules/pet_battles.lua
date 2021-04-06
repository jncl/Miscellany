local aName, aObj = ...
local _G = _G

-- PetBattle functions
if battle_pets then
	-- Check to see if any Pets need to be healed, if so and the cooldown is up then display a message
	local rbp, rbpEvt = {}
	local function healthCheck(petID, name)
		aObj:printD("healthCheck", petID, name)
		local health, maxHealth = _G.C_PetJournal.GetPetStats(petID)
		aObj:printD("hC pet info", petID, name, health, maxHealth)
		if health + 1 < maxHealth then -- allow for rounding issue
			aObj:printD("hC pet health", petID, name, health, maxHealth)
			if rbp[1] > 0 and rbp[2] > 0 then
				if not rbpEvt then
					_G.DEFAULT_CHAT_FRAME:AddMessage("Revive Battle Pets on cooldown, try a bandage", 0.9, 0.0, 0.0)
					aObj:printD("Starting Timer for end of cooldown")
					rbpEvt = aObj.at.ScheduleTimer(function() _G.DEFAULT_CHAT_FRAME:AddMessage("Timer - Heal Battle Pets", 0.9, 0.0, 0.0) _G.UIErrorsFrame:AddMessage("Timer - Heal Battle Pets", 0.9, 0.0, 0.0, 10) rbpEvt = nil end, rbp[1] + rbp[2] - _G.GetTime())
				end
			else
			-- display a message if not on cooldown
				_G.DEFAULT_CHAT_FRAME:AddMessage("Heal Battle Pets", 0.9, 0.0, 0.0)
				_G.UIErrorsFrame:AddMessage("Heal Battle Pets", 0.9, 0.0, 0.0, 1.0)
			end
		end

	end
	local lTime = 0
	function aObj:checkPetHealth(battleEnded, time)
		aObj:printD("Checking BattlePets health", battleEnded, time, lTime)
		-- handle 2 consecutive PET_BATTLE_CLOSE events, action the second one
		if battleEnded
		and time > lTime + 5
		then
			lTime = time
			return
		end

		-- get spell cooldown info (Spell ID: 125439)
		rbp = {_G.GetSpellCooldown(125439)}
		aObj:printD("cPH - Spell", rbp[1], rbp[2], rbp[3])
		-- Pet Battle ended
		if battleEnded then
			-- check active pets health
			for i = 1, 3 do
				local petID = _G.C_PetJournal.GetPetLoadOutInfo(i)
				if not petID == nil then
					local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = _G.C_PetJournal.GetPetInfoByPetID(petID)
					healthCheck(petID, customName or name)
				end
			end
		-- first time through
		else
			-- check all pet's health
			local numPets, numOwned = _G.C_PetJournal.GetNumPets()
			aObj:printD("cPH numPets", numPets, numOwned)
			for i = 1, numPets do
				local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle = _G.C_PetJournal.GetPetInfoByIndex(i)
				aObj:printD(petID, isOwned, customName, name)
				if petID ~= nil and isOwned then
					healthCheck(petID, customName or name)
				end
			end
		end
	end
	-- -- hook PetBattle finished
	-- aObj.ae.RegisterEvent(aName, "PET_BATTLE_CLOSE", function() aObj.at.ScheduleTimer(function() aObj:checkPetHealth(true, _G.GetTime()) end, .2) end) -- wait before checking pet's health to give PetJournal time to catch up
	-- aObj:checkPetHealth()

	-- Auto Forfeit PetBattles
	aObj.ah:SecureHookScript(_G.PetBattleFrame.BottomFrame.ForfeitButton, "OnClick", function(this)
		_G.C_PetBattles.ForfeitGame()
		_G.StaticPopup_Hide("PET_BATTLE_FORFEIT")
	end)
end
