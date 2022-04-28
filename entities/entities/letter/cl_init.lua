include("shared.lua")

local SignButton

function ENT:Draw()
	self.Entity:DrawModel()
end
local HasOpen
local function KillLetter(msg)
	hook.Remove("HUDPaint", "ShowLetter")
	HasOpen = false
end
usermessage.Hook("KillLetter", KillLetter)

local function ShowLetter(msg)
	if HasOpen then return end
	local LetterMsg = ""
	local Letter = msg:ReadEntity()
	local LetterType = msg:ReadShort()
	local LetterPos = msg:ReadVector()
	local sectionCount = msg:ReadShort()
	local LetterY = ScrH() / 2 - 300
	local LetterAlpha = 255

	for k=1, sectionCount do
		LetterMsg = LetterMsg .. msg:ReadString()
	end
	HasOpen = true
	SignButton = vgui.Create("DButton")
	SignButton:SetText("Sign letter")
	SignButton:SetPos(ScrW()*.5-256, ScrH()-74)
	SignButton:SetSize(512,64)
	SignButton:SetSkin("LiquidDRP2")
	gui.EnableScreenClicker(true)

	function SignButton:DoClick()
		RunConsoleCommand("_DarkRP_SignLetter", Letter:EntIndex())
		SignButton:Remove()
	end
	SignButton:SetDisabled(IsValid(Letter.dt.signed))

	local LeftLetter
	local Opened = CurTime()
	hook.Add("HUDPaint", "ShowLetter", function()
		if LetterAlpha < 255 then
			LetterAlpha = math.Clamp(LetterAlpha + 400 * FrameTime(), 0, 255)
		end

		local font = (LetterType == 1 and "AckBarWriting") or "Default"
		
		draw.RoundedBox(2, ScrW() * .2-4, LetterY-4, ScrW() * .8 - (ScrW() * .2)+8, ScrH()+8, Color(255, 255, 255, math.Clamp(LetterAlpha, 0, 150)))
		draw.RoundedBox(2, ScrW() * .2-4, LetterY-4, ScrW() * .8 - (ScrW() * .2)+8, ScrH()+8, Color(220, 220, 220, math.Clamp(LetterAlpha, 0, 100)))
		draw.DrawText(LetterMsg.."\n\n\nSigned by "..(IsValid(Letter.dt.signed) and Letter.dt.signed:Nick() or "no one"), font, ScrW() * .25 + 20, LetterY + 80, Color(0, 0, 0, LetterAlpha), 0)
		if ((LocalPlayer():KeyDown(IN_USE) or LocalPlayer():GetPos():Distance(LetterPos) > 70) and CurTime()-Opened >= 3) and !LeftLetter then
			LeftLetter = true
			SignButton:Remove()
			gui.EnableScreenClicker(false)
		end
		
		if LeftLetter then
			LetterY = Lerp(0.1, LetterY, ScrH())
			LetterAlpha = Lerp(0.1, LetterAlpha, 0)
			if LetterY >= ScrH()*.99 then
				KillLetter()
			end
		end
	end)
end
usermessage.Hook("ShowLetter", ShowLetter)
