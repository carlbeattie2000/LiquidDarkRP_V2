
local LDRP = {}
LDRP.AutoSaveMins = 1

function LDRP.AutoSaveAll()
	for k,v in pairs(player.GetAll()) do
		v:SavePlayer()
	end
end
timer.Create("AutoSaveAllPlayers", LDRP.AutoSaveMins*60, 0, LDRP.AutoSaveAll)

local function SavePlayersBeforeShutDown()
	GAMEMODE:WriteOut( "Saving player information before server shuts down...", Severity.Info )
	
	local plys = player.GetHumans()
	
	table.foreachi( plys, function( _, v )
		--Put the player's weapons in their inventory so it will save them
		for __, w in ipairs( v:GetWeapons() ) do
			local wepType = w:GetClass()
			if v:CanCarry( wepType ) then
				v:AddItem( wepType, 1 )
			end
		end
		
		v:SavePlayer()
	end )
end
hook.Add( "ShutDown", "SavePlayersBeforeShutDown", SavePlayersBeforeShutDown )

local Check = LDRP_SH.AllItems
function LDRP.InitializeSelf(ply,cmd,args)
	if ply.Inited then return end
	ply:LiquidChat("GAME", Color(0,200,200), "Your client has been fully established.")
	ply.Inited = true
	ply.Growing = {}
	
	local InvWeight = 0 
	-- Inventory:
	if ply:LiquidFile("Inventory") then
		local Tbl = von.deserialize(ply:LiquidFile("Inventory",true))
		ply.Inventory = Tbl
		for k,v in pairs(Tbl) do -- Remove unexisting items and recalculate weight
			if !Check[k] then ply.Inventory[k] = nil continue end
			
			if v >= 1 then
				InvWeight = InvWeight+(Check[k].weight*v)
			end
		end
	else
		ply.Inventory = {}
	end
	
	timer.Simple(3,function()
		if !ply:IsValid() then return end
		for k,v in pairs(ply.Inventory) do
			ply:SendItem(k,v)
		end
		timer.Simple(1,function()
			if !ply:IsValid() then return end
			for k,v in pairs(ply.Character.Bank) do
				ply:SendBItem(k,v)
			end

      ply:SendInterestInfo(ply.Character.InterestRate)
		end)
	end)

	-- Skills:
	if ply:LiquidFile("Character") then
		ply.Character = von.deserialize(ply:LiquidFile("Character",true))
		ply.Character.InvWeight["cur"] = InvWeight
	else
		ply.Character = {}
		ply.Character.Skills = {}
		ply.Character.InvWeight = {["cur"] = 0,["allowed"] = 10}
	end

	if !ply.Character.BankWeight then
		ply.Character.Bank = {["curcash"] = 0}
		ply.Character.BankWeight = {["cur"] = 0,["allowed"] = 30}
    ply.Character.InterestRate = {["cur"] = 0}
	end

  if !ply.Character.InterestRate["lastcollected"] then

    ply.Character.InterestRate["lastcollected"] = os.time()
    
  end
	
	timer.Simple(3,function()
		if !ply:IsValid() then return end
		umsg.Start("SendWeight",ply)
			umsg.Float(ply.Character.InvWeight.allowed)
		umsg.End()
		umsg.Start("SendBWeight",ply)
			umsg.Float(ply.Character.BankWeight.allowed)
		umsg.End()
	end)
	timer.Simple(2,function()
		if !ply:IsValid() then return end
		if !file.Exists("liquiddrp/didtutorial_" .. ply:UniqueID() .. ".txt", "DATA") then
			ply:DoTutorial("start")
			
			file.Write("liquiddrp/didtutorial_" .. ply:UniqueID() .. ".txt","1")
		end
	end)
	
	for k,v in pairs(LDRP_SH.AllSkills) do
		if !ply.Character.Skills[k] then
			ply.Character.Skills[k] = {}
			ply.Character.Skills[k].lvl = 1
			ply.Character.Skills[k].exp = 0
		end
	end
	
	timer.Simple(.7,function()
		if !ply:IsValid() then return end
		for k,v in pairs(ply.Character.Skills) do
			umsg.Start("SendSkill",ply)
				umsg.String(k)
				umsg.Float(v.exp)
				umsg.Float(v.lvl)
			umsg.End()
		end
	end)
	ply:SavePlayer()
end
concommand.Add("_initme",LDRP.InitializeSelf)

function LDRP.ItemCMD(ply,cmd,args)
	if RPArrestedPlayers[ply:SteamID()] then ply:ChatPrint("You are in jail!") return end
	if !args or !args[1] or !args[2] or args[3] then return end
	if !ply:Alive() then ply:ChatPrint("You must be alive to do this!") return end
	
	local it = string.lower(tostring(args[2]))
	local b = LDRP_SH.ItemTable(it)
	
	if b and ply:HasItem(it) then
		if args[1] == "drop" then
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply
			
			local tr = util.TraceLine(trace)
			
			local DroppedItem
			
			ply:AddItem(it,-1)
			
			if b.realent and !b.iswep then
				DroppedItem = ents.Create(b.realent)
			elseif b.iswep then
				DroppedItem = ents.Create("spawned_weapon")
				DroppedItem.weaponclass = b.nicename
				DroppedItem:SetModel(b.mdl)
			else
				DroppedItem = ents.Create("item_base")
				DroppedItem.ItemType = it
				DroppedItem:SetModel(b.mdl)
				DroppedItem.Owner = ply
			end
			DroppedItem.dt = {}
			DroppedItem.dt.owning_ent = ply
			DroppedItem.ShareGravgun = true
			DroppedItem:SetPos(tr.HitPos+Vector(0,0,5))
			if CPPI then DroppedItem:CPPISetOwner( ply ) end --Support for FPP
			DroppedItem:Spawn()
			
			it = LDRP_SH.NicerWepNames[it] or it
			ply:LiquidChat("INVENTORY", Color(0,150,200), "You have dropped " .. it)
		elseif args[1] == "use" then
			if b.cuse then
				ply:AddItem(it,-1)
				b.use(ply)
			end
		elseif args[1] == "delete" then
			ply:LiquidChat("INVENTORY", Color(0,150,200), "Removed 1 " .. it .. " from your inventory.")
			ply:AddItem(it,-1)
		end
	elseif b then 
		ply:LiquidChat("INVENTORY", Color(0,150,200), "You don't have any of that item!")
	end
	
end
concommand.Add("_inven",LDRP.ItemCMD)

function LDRP.HolsterWep(ply,cmd,args)
	if !ply:Alive() then return "" end
	if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF then
		ply:LiquidChat("INVENTORY", Color(0,150,200), "Can't holster weapons as cop (because of free gun!)")
		return ""
	end
	
	local Type = ply:GetActiveWeapon():GetClass()
	if Type == ("weapon_real_cs_grenade" or "weapon_real_cs_smoke" or "weapon_real_cs_flash") then
		ply:LiquidChat("INVENTORY", Color(0,150,200), "Can't holster grenades (duplication glitch)")
		return ""
	end
	
	if LDRP_SH.AllItems[Type] then
		if !ply:CanCarry(Type) then
			ply:LiquidChat("INVENTORY", Color(0,150,200), "Free up inventory space before holstering this.")
			return ""
		end
		ply:StripWeapon(Type)
		ply:AddItem(Type,1)
		ply:LiquidChat("INVENTORY", Color(0,150,200), "You have holstered your weapon into your inventory.")
		
		local ammotype = ply:GetActiveWeapon():GetPrimaryAmmoType()
		local ammo = ply:GetAmmoCount(ammotype)
		ply:RemoveAmmo(ammo, ammotype)
	else
		ply:LiquidChat("INVENTORY", Color(0,150,200), "Can't holster this gun.")
	end
	
	return ""
end
AddChatCommand("/holster",LDRP.HolsterWep)
