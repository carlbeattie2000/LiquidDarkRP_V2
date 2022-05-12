ENT.Type  ="anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Diamond Printer"
ENT.Author = "RebellionRP"

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "money" )
	
end