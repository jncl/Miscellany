-- luacheck: ignore 631 (line is too long)
local aName, aObj = ...
local _G = _G

local framesToMove = {
	["Boss1TargetFrame"]  = {move = true, yOfs = -236},
	["PlayerFrame"]       = {move = true, yOfs = -4},
	["TargetFrame"]       = {move = true, yOfs = -4},
	["FocusFrame"]        = {move = false, yOfs = 0},
	["MinimapCluster"]    = {move = true, yOfs = 0},
	["BuffFrame"]         = {move = true, yOfs = -13},
	["TicketStatusFrame"] = {move = true, yOfs = 0},
	["GMChatStatusFrame"] = {move = true, yOfs = -5},
	["UIWidgetTopCenterContainerFrame"] = {move = true, yOfs = -15}
}

function aObj:moveThem(offset)

	if _G.InCombatLockdown() then
		aObj.oocTab[#aObj.oocTab + 1] = {self.moveThem, {offset}}
		return
	end

	offset = offset or 22

	local topOffset, buffsAreaTopOffset = 0, 0
	if _G.TicketStatusFrame and _G.TicketStatusFrame:IsShown() then
		buffsAreaTopOffset = buffsAreaTopOffset + _G.TicketStatusFrame:GetHeight()
	end
	if _G.GMChatStatusFrame and _G.GMChatStatusFrame:IsShown() then
		buffsAreaTopOffset = buffsAreaTopOffset + _G.GMChatStatusFrame:GetHeight() + 5
	end
	if buffsAreaTopOffset == 0 then
		buffsAreaTopOffset = 13
	end
	if _G.OrderHallCommandBar and _G.OrderHallCommandBar:IsShown() then
		topOffset = 12
		-- don't adjust buffArea here as OrderHallCommandBar overlays ChocolateBar
		-- buffsAreaTopOffset = buffsAreaTopOffset + _G.OrderHallCommandBar:GetHeight()
	end
	framesToMove["BuffFrame"].yOfs = _G.Round(buffsAreaTopOffset) * -1
	-- aObj:printD("moveThem: [offsets]", offset, topOffset, _G.Round(buffsAreaTopOffset))

	local fObj
	for frame in _G.pairs(framesToMove) do
		if framesToMove[frame]
		and framesToMove[frame].move
		then
			fObj = _G[frame]
			if fObj
			and fObj:GetNumPoints() > 0 then
				if fObj:GetNumPoints() > 1 then
					-- aObj:printD("moveThem, GetNumPoints: ", frame, fObj:GetNumPoints())
					return
				end

				local point, relTo, relPoint, xOfs, yOfs = fObj:GetPoint()
				-- aObj:printD("moveThem:", frame, point, relTo, relPoint, xOfs, _G.Round(yOfs), framesToMove[frame].yOfs, framesToMove[frame].yOfs - topOffset, offset)

				if _G.Round(yOfs) == framesToMove[frame].yOfs
				or _G.Round(yOfs) == framesToMove[frame].yOfs - topOffset
				then
					-- move frame
					-- aObj:printD("moving", frame)
					fObj:SetPoint(point, relTo, relPoint, xOfs, yOfs - offset)
				end
			end
		end
	end

end

if not aObj.isClsc then
	aObj.ah:SecureHook("UIParent_UpdateTopFramePositions", function()
		-- aObj:printD("UIParent_UpdateTopFramePositions")
		aObj:moveThem()
	end)

	-- Hook Vehicle Event as Player Frame moves
	aObj.ae.RegisterEvent(aName, "UNIT_ENTERED_VEHICLE", function(_, ...)
		if _G.select(1, ...) == "player" then
			_G.C_Timer.After(1.5, function()
				aObj:moveThem()
			end)
		end
	end)
	aObj.ae.RegisterEvent(aName, "UNIT_EXITED_VEHICLE", function(_, ...)
		if _G.select(1, ...) == "player" then
			_G.C_Timer.After(1.5, function()
				aObj:moveThem()
			end)
		end
	end)
end

function aObj:cbJostle(offset)

	if _G.IsAddOnLoaded("ChocolateBar") then
		self:moveThem(offset)
	end

end
