include("shared.lua")

function ENT:Initialize()
end

function ENT:Draw()
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 600 then return end
	
	self.Entity:DrawModel()
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	local owner = self.dt.owning_ent
	owner = (IsValid(owner) and owner:Nick()) or "unknown"
	
	surface.SetFont("HUDNumber5")
	local printer = (self:GetNWString("Upgrade") .. " - $" .. self.dt.holding)
	local TextWidth = surface.GetTextSize(printer)
	local TextWidth2 = surface.GetTextSize(owner)
	
	Ang:RotateAroundAxis(Ang:Up(), 90)
	
	cam.Start3D2D(Pos + Ang:Up() * 11.5, Ang, 0.11)
		draw.WordBox(2, -TextWidth*0.5, -30, printer, "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5, 18, owner, "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
	cam.End3D2D()
	
end

function ENT:Think()
end
