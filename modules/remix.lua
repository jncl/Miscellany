-- luacheck: ignore 212 631 (unused argument|line is too long)
local _, aObj = ...
local _G = _G

function aObj:checkRemix()

	-- MoP: Remix
	aObj.timerunningSeasonID = not not _G.PlayerGetTimerunningSeasonID()
	aObj:printD("timerunning Character", aObj.timerunningSeasonID)

	local instInfo
	-- automatically open Cache of Infinite Treasure
	if aObj.timerunningSeasonID then
		local myTimer = _G.C_Timer.NewTicker(15, function()
			-- aObj:printD("Running Remix Ticker")
			instInfo = {_G.GetInstanceInfo()}
			if instInfo[2] == "scenario"
			or _G.C_Scenario.IsInScenario()
			then
				return
			end
			_G.C_Item.UseItemByName("Cache of Infinite Treasure")
			_G.C_Item.UseItemByName("Minor Bronze Cache")
			_G.C_Item.UseItemByName("Lesser Bronze Cache")
			_G.C_Item.UseItemByName("Bronze Cache")
			_G.C_Item.UseItemByName("Greater Bronze Cache")
			-- N.B. opening these causes an error, [AddOn 'Miscellany' tried to call the protected function 'UNKNOWN()']
			-- _G.C_Item.UseItemByName("Minor Spool of Eternal Thread")
			-- _G.C_Item.UseItemByName("Lesser Spool of Eternal Thread")
			-- _G.C_Item.UseItemByName("Spool of Eternal Thread")
			-- _G.C_Item.UseItemByName("Greater Spool of Eternal Thread")
		end)
	end

end
