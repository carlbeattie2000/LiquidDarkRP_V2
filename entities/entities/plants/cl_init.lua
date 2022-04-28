include('shared.lua')

local SHeight = 5;
local SWidth = 2.5
local MaxHeight = 25;
local MaxWidth = 14;
local PlTbl = LDRP_SH.AllGrowableItems
local PlNum = LDRP_SH.PlantIDs
local DoneWidth = surface.GetTextSize("DONE")

function ENT:Draw()
	if self.StartGrow then
		local GrowPercent = (CurTime()-self.StartGrow)/(PlTbl[PlNum[self.Entity.dt.plantnum]].time*60)
		if GrowPercent <= 1 then
			local W = SWidth + (GrowPercent * MaxWidth)
			--self:SetModelScale(.05 * Vector(W, W, SHeight + (GrowPercent*MaxHeight)))
			--Temporary fix until garry adds the old SetModelScale back in
			local mat = Matrix()
			mat:Scale(.05 * Vector(W, W, SHeight + (GrowPercent*MaxHeight)))
			self:EnableMatrix("RenderMultiply", mat)
			
			self:DrawModel()
		else
			local W = SWidth + MaxWidth
			--self:SetModelScale(.05 * Vector(W, W, SHeight + MaxHeight))
			local mat = Matrix()
			mat:Scale(.05 * Vector(W, W, SHeight + MaxHeight))
			self:EnableMatrix("RenderMultiply", mat)
			
			local Pos = self:GetPos()+Vector(0,0,8)
			local Ang = self:GetAngles()
			
			Ang:RotateAroundAxis(Ang:Forward(), 90)
			local Txt = "DONE"
			if GrowPercent >= 1.35 then
				Txt = "DEAD"
			end
			self:DrawModel()
			cam.Start3D2D(Pos, Ang, 0.12)
				draw.WordBox(2, -DoneWidth*.5-(DoneWidth*.5), -300, Txt, "HUDNumber5", Color(0, 247, 243, 130), Color(255,255,255,255))
			cam.End3D2D()
		end
	end
end

function ENT:Think()
	if !self.StartGrow and self.Entity.dt.plantnum and self.Entity.dt.plantnum != 0 then
		self.StartGrow = CurTime()
	elseif self.StartGrow and self.Entity.dt.plantnum == 0 then
		self.StartGrow = nil
	end
end

function ENT:Initialize()	
end
