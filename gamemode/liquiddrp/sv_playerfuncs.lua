local meta = FindMetaTable("Player")
local file = file
local LDRP = {}
util.AddNetworkString( "SendEXP" )

--[[ Files: Loading and saving ]]--

function meta:UIDToFile(fil)
	if self and self:IsValid() and fil then
		return "LiquidDRP/" .. fil .. "_" .. self:UniqueID()
	end
end

function meta:LiquidFile(fil,load)
	if self and self:IsValid() and fil then
		local UID = self:UniqueID()
		if !UID then return false end
		if load then
			return file.Read("LiquidDRP/" .. fil .. "_" .. UID .. ".txt", "DATA")
		else
			return file.Exists("LiquidDRP/" .. fil .. "_" .. UID .. ".txt", "DATA")
		end
	end
end

local SaveTables = {"Inventory","Character"}
function meta:SavePlayer(savewhat)
	if self and self:IsValid() and self.Inited then
		if !file.IsDir( "LiquidDRP", "DATA" ) then file.CreateDir( "LiquidDRP" ) end
		if savewhat and self.savewat != nil then
			if self[savewhat] then
				file.Write("LiquidDRP/" .. savewhat .. "_" .. self:UniqueID() .. ".txt", von.serialize(self[savewhat]))
			end
		else
			for k,v in pairs(SaveTables) do
				if self[v] then
					file.Write("LiquidDRP/" .. v .. "_" .. self:UniqueID() .. ".txt", von.serialize(self[v]))
				end
			end
		end
	end
end

--[[ Inventory ]]--

function meta:SendItem(item,am)
	umsg.Start("SendItem",self)
		umsg.String(tostring(item))
		umsg.Float(am)
	umsg.End()
end

function meta:AddItem(name,amount)
	local am = amount or 1
	local Tbl = LDRP_SH.ItemTable(name)
	if Tbl then
		if self.Inventory[name] != nil then
			self.Inventory[name] = self.Inventory[name]+am
		else
			self.Inventory[name] = am
		end
		self.Character.InvWeight.cur = self.Character.InvWeight.cur+(Tbl.weight*am)
		
		self:SendItem(name,self.Inventory[name])
	end
end

function meta:HasItem(name,am)
	local Check = self.Inventory[name] or 0
	return (Check >= (am or 1) and Check)
end

function meta:CanCarry(item,amount)
	local am = amount or 1
	local Tbl = LDRP_SH.ItemTable(item)
	if not Tbl then return nil end
	return ((self.Character.InvWeight.cur+(Tbl.weight*am)) <= self.Character.InvWeight.allowed) and self.Character.InvWeight.cur+(Tbl.weight*am)
end

function meta:SendBItem(item,am)
	umsg.Start("SendBItem",self)
		umsg.String(tostring(item))
		umsg.Float(am)
	umsg.End()
end

function meta:AddBMoney(amount)
	local Add = (self.Character.Bank["curcash"] or 0)+amount
	self.Character.Bank["curcash"] = Add
	self:SendBItem("curcash",Add)
end

function meta:GetBMoney()
	return self.Character.Bank["curcash"] or 0
end

function meta:AddBItem(name,amount)
	local am = amount or 1
	local Tbl = LDRP_SH.ItemTable(name)
	if Tbl then
		if self.Character.Bank[name] != nil then
			self.Character.Bank[name] = self.Character.Bank[name]+am
		else
			self.Character.Bank[name] = am
		end
		self.Character.BankWeight.cur = self.Character.BankWeight.cur+(Tbl.weight*am)
		
		self:SendBItem(name,self.Character.Bank[name])
	end
end

function meta:HasBItem(name,am)
	local Check = self.Character.Bank[name] or 0
	return (Check >= (am or 1) and Check)
end

function meta:CanBCarry(item,amount)
	local am = amount or 1
	local Tbl = LDRP_SH.ItemTable(item)
	return ((self.Character.BankWeight.cur+(Tbl.weight*am)) <= self.Character.BankWeight.allowed) and self.Character.BankWeight.cur+(Tbl.weight*am)
end

function meta:GetInterestRate()

	return self.Character.InterestRate["cur"]

end

function meta:GetInterestRateType()

	return self.Character.InterestRate["rateType"]

end

function meta:SetInterestRate(rateType, newRate)

  self.Character.InterestRate["rateType"] = rateType
	self.Character.InterestRate["cur"] = newRate

end

--[[ Skills ]]--

function meta:GiveEXP(skill,am,send)
	if self.Character and self.Character.Skills[skill] then
		local cur = self.Character.Skills[skill]
		local sk = LDRP_SH.AllSkills[skill]
		
		if cur.exp <= sk.exptbl[cur.lvl] then
			local new = math.Clamp(cur.exp+((self:IsVIP() and math.Round(am*1.3)) or math.Round(am)), 0, sk.exptbl[cur.lvl])
			self.Character.Skills[skill].exp = new
			if send then
				net.Start( "SendEXP" )
					net.WriteString( skill )
					net.WriteFloat( new )
				net.Send( self )
			end
		end
	end
end

function meta:GiveLevel(skill,am)
	if self:IsValid() and self.Character and self.Character.Skills[skill] then
		local cur = self.Character.Skills[skill]
		self.Character.Skills[skill].lvl = cur.lvl+am
		self.Character.Skills[skill].exp = 0
		umsg.Start("SendSkill",self)
			umsg.String(skill)
			umsg.Float(0)
			umsg.Float(cur.lvl)
		umsg.End()
		if LDRP_SH.AllSkills[skill].LvlFunction then
			LDRP_SH.AllSkills[skill].OnLevelUp(self)
		end
		self:SavePlayer("Character")
	end
end

--[[ Chat ]]--

function meta:LiquidChat(nam,col,msg)
	if !self:IsValid() then return end
	umsg.Start("LiquidChat", self)
		umsg.String(nam)
		umsg.Vector(Vector(col.r,col.g,col.b))
		umsg.String(msg)
	umsg.End()
end