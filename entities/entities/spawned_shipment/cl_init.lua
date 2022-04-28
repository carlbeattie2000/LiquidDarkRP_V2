include("shared.lua")

function ENT:Draw()
	self.Entity:DrawModel()
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	local content = self.dt.contents or ""
	local contents = CustomShipments[content]
	if not contents then return end
	contents = contents.name
	
	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Contents:")
	local TextWidth2 = surface.GetTextSize(contents)
	
	cam.Start3D2D(Pos + Ang:Up() * 25, Ang, 0.2)
		draw.WordBox(2, -TextWidth*0.5 + 5, -30, "Contents:", "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5 + 5, 18, contents, "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
	cam.End3D2D()
	
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	
	TextWidth = surface.GetTextSize("Amount left:")
	TextWidth2 = surface.GetTextSize(self.dt.count)
	
	cam.Start3D2D(Pos + Ang:Up() * 17, Ang, 0.14)
		draw.WordBox(2, -TextWidth*0.5 + 5, -150, "Amount left:", "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5 + 0, -102, self.dt.count, "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
	cam.End3D2D()
end