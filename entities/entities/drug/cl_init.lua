include("shared.lua")

function ENT:Initialize()
end

function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local owner = self:Getowning_ent()
	owner = (IsValid(owner) and owner:Nick()) or "Unknown"

	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Drugs!")
	local TextWidth2 = surface.GetTextSize("Price: $"..self:Getprice())

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	local TextAng = Ang

	TextAng:RotateAroundAxis(TextAng:Right(), CurTime() * -180)

	cam.Start3D2D(Pos + Ang:Right() * -15, TextAng, 0.1)
		draw.WordBox(2, -TextWidth*0.5 + 5, -30, "Drugs!", "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5 + 5, 18, "Price: $"..self:Getprice(), "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
end

function ENT:Think()
end