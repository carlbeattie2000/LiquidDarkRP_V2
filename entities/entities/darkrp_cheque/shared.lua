ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Cheque"
ENT.Author = "Eusion"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "owning_ent")
	self:DTVar("Entity", 1, "recipient")
	self:DTVar("Int", 0, "amount")
end