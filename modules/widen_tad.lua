local _, aObj = ...
local _G = _G

function aObj.widenTAD(_)

	local wOfs, hOfs, w, h = 350, 200
	local function makeWider(obj, height)
		w, h = obj:GetSize()
		if not obj.wider then
			obj:SetSize(w+ wOfs, h + (height and hOfs or 0))
			obj.wider = true
		end
	end
	local kwOfs = 120
	local function makeKeyWider(obj)
		w, h = obj:GetSize()
		if not obj.wider then
			obj:SetSize(w + kwOfs, h)
			obj.wider = true
		end
	end

	aObj.ah:SecureHook(_G.TableAttributeDisplay, "UpdateLines", function(frame)
		for _, line in _G.pairs(frame.lines) do
			makeWider(line)
			if line.Key then
				makeKeyWider(line.Key)
				makeKeyWider(line.Key.Text)
			end
			if line.Text then
				makeWider(line.Text)
			end
			if line.Value
			and line.Value:IsObjectType("FontString")
			then
				makeWider(line.Value)
			end
			if line.ValueButton then
				makeWider(line.ValueButton)
				makeWider(line.ValueButton.Text)
			end
		end
	end)

	aObj.ah:SecureHookScript(_G.TableAttributeDisplay, "OnShow", function(frame)
		makeWider(frame, true)
		makeWider(frame.FilterBox)
		makeWider(frame.TitleButton)
		makeWider(frame.TitleButton.Text)
		makeWider(frame.LinesScrollFrame, true)
		makeWider(frame.LinesScrollFrame.LinesContainer)


	end)
	if _G.TableAttributeDisplay:IsShown() then
		_G.TableAttributeDisplay:Hide()
		_G.TableAttributeDisplay:Show()
	end

end
