AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
function ENT:Initialize()
  self.Item = LDRP_SH.AllItems[self.ItemType];
  if not self.Item then
    GM:WriteOut("Prematurely removing item entity: make sure it exists" .. "in the AllItems table!", Severity.Error);
    self:Remove();
    return;
  end

  if self.Item.fakemdl then
    local Fake = ents.Create("prop_physics");
    Fake:SetModel(self.Item.mdl);
    Fake:SetParent(self);
    Fake:SetPos(self:GetPos());
    Fake:SetAngles(self:GetAngles());
    Fake:SetMaterial(self.Item.mat);
    Fake:SetColor(self.Item.clr);
    self.Fake = Fake;
    self:SetColor(0, 0, 0, 0);
    self:SetModel(self.Item.fakemdl);
  else
    self:SetColor(self.Item.clr);
    self:SetMaterial(self.Item.mat);
    self:SetModel(self.Item.mdl);
  end

  self:PhysicsInit(SOLID_VPHYSICS);
  self:SetMoveType(MOVETYPE_VPHYSICS);
  self:SetSolid(SOLID_VPHYSICS);
  self:SetAngles(Angle(0, math.random(1, 360), 0));
  local phys = self:GetPhysicsObject();
  if phys and phys:IsValid() then phys:Wake(); end
  self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS);
end

function ENT:Use(ply, caller)
  if ply:CanCarry(self.ItemType, 1) then
    self:Remove();
    ply:AddItem(self.ItemType, 1);
    ply:LiquidChat(GM.Config.ChatPrefix, GM.Config.ChatPrefixColor, "Picked up a " .. self.ItemType .. ".");
  else
    ply:LiquidChat(GM.Config.ChatPrefix, GM.Config.ChatPrefixColor, "You need to free up inventory space before picking this up.");
  end
end

function ENT:OnRemove()
  if self.Fake then self.Fake:Remove(); end
end
