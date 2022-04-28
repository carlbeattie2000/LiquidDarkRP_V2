local LDRP = {}
LDRP.SavedPoses = {} --NPC poses, that is. Key = NPC type, then v.pos, and v.ang.

LDRP_SH.ShopPoses = {}

function LDRP_SH.CreateNPC(name,pos,ang)
	if LDRP_SH.ShopPoses[name] or !LDRP_SH.AllNPCs[name] then return end
	if !LDRP_SH.UsePaycheckLady and name == "Paycheck Lady" then
		GAMEMODE:WriteOut("Not spawning Paycheck Lady: UsePaycheckLady is false.", Severity.Info)
		return
	end
	
	local NewNPC = ents.Create("shop_base")
	NewNPC:SetPos(pos)
	NewNPC.ShopType = name
	NewNPC:SetModel(LDRP_SH.AllNPCs[name].mdl)
	LDRP_SH.ShopPoses[name] = NewNPC:GetPos()

	if ang then
		NewNPC:SetAngles(ang)
	end
	NewNPC:Spawn()
end

DB:DeclareTable("npc_poses", {
	{
		name = "id",
		data_type = "INTEGER",
		is_pk = true
	},
	{
		name = "mapname",
		data_type = "CHAR(128)"
	},
	{
		name = "name",
		data_type = "CHAR(128)"
	},
	{
		name = "position",
		data_type = "CHAR(128)"
	},
	{
		name = "angle",
		data_type = "CHAR(128)"
	}
})
--[[---------------------------------------------------------
	LoadNPCs - Loads NPC information from a predetermined
	storage location (in this case, the database) and spawns
	them, calling CreateNPC().
-----------------------------------------------------------]]
function LoadNPCs()
	DB:RetrieveData("npc_poses", "*", "mapname = '"..game.GetMap().."'", function(data)
		if type(data) == "table" then
			for k, v in ipairs(data) do
				local splitpos = string.Explode(",", v.position)
				local splitang = string.Explode(",", v.angle)

				LDRP.SavedPoses[v.name] = {}
				LDRP.SavedPoses[v.name].pos = Vector(splitpos[1], splitpos[2], splitpos[3])
				LDRP.SavedPoses[v.name].ang = Angle(tonumber(splitang[1]), tonumber(splitang[2]), tonumber(splitang[3]))
			end
			GAMEMODE:WriteOut("Finished loading "..table.Count(LDRP.SavedPoses).." NPC locations from the database.", Severity.Info)
		elseif data ~= nil then
			GAMEMODE:WriteOut("An error occured while trying to load the NPCs: "..tostring(data), Severity.Error)
		end
	end)
end

hook.Add("DarkRPDBInitialized", "Load NPC poses from DB", LoadNPCs)

function LDRP.UseNPC(ply,ent)
	if ent and ent:IsValid() and ent:GetClass() == "shop_base" and ent.ShopType and !ply.CanUse then
		local b = LDRP_SH.AllNPCs[ent.ShopType]
		if b then
			ply.CanUse = true
			timer.Simple(2, function()
				ply.CanUse = nil
			end)
			umsg.Start(b.uname,ply)
				if b.NeedTeam and !table.HasValue(b.NeedTeam, ply:Team()) then umsg.Float(b.NeedTeam[1]) end
			umsg.End()
		end
	end
end
hook.Add("PlayerUse","LDRP.UseNPC",LDRP.UseNPC)

function LDRP.AutoSpawnNPCs()
	timer.Simple(3, function()
		for k,v in pairs(LDRP.SavedPoses) do
			LDRP_SH.CreateNPC(k,v.pos,v.ang)
		end
		--Consider moving below code elsewhere - doesn't belong here.
		local Sun = ents.FindByClass("env_sun")[1]
		if Sun and Sun:IsValid() then Sun:Remove() end
	end)
end
hook.Add("InitPostEntity","Spawns saved NPCs",LDRP.AutoSpawnNPCs)

function LDRP.SetNPCPos(ply,cmd,args)
	if !ply:IsAdmin() then
		ply:ChatPrint("You must be an admin to use this function!")
		return
	end
	if !args or !args[1] then
		ply:PrintMessage(2, "You must specify an NPC type (Incorrect number of args given).")
		ply:PrintMessage(2, "Valid NPC types:")
		for k, v in pairs(LDRP_SH.AllNPCs) do
			ply:PrintMessage(2, k)
		end
		return
	end
	local Type = args[1]
	if !LDRP_SH.AllNPCs[Type] then ply:PrintMessage(2, "Type does not exist.") return end
	
	if LDRP.SavedPoses[Type] then
		for k,v in pairs(ents.FindByClass("shop_base")) do
			if v.ShopType == Type then
				v:Remove()
				break
			end
		end
	end
	
	LDRP.SavedPoses[Type] = nil
	DB:DeleteEntry("npc_poses", "mapname = '"..game.GetMap().."' AND name = '"..Type.."'")
	
	local pos = ply:GetEyeTrace().HitPos
	local ang = ply:GetAngles()+Angle(0,180,0)
	
	LDRP_SH.ShopPoses[Type] = nil
	LDRP_SH.CreateNPC(Type,pos,ang)
	LDRP.SavedPoses[Type] = {["pos"] = pos,["ang"] = ang}
	
	ply:ChatPrint(Type.." was created.")
	local serializedpos = pos.X..","..pos.Y..","..pos.Z
	local serializedang = ang.Pitch..","..ang.Yaw..","..ang.Roll
	DB:StoreEntry("npc_poses", {
		id = "NULL",
		mapname = "'"..game.GetMap().."'",
		name = "'"..Type.."'",
		position = "'"..serializedpos.."'",
		angle = "'"..serializedang.."'"
	})
end
concommand.Add("ldrp_npcpos",LDRP.SetNPCPos)

-- First real addition to the release of Liquid DarkRP
LDRP.SavedTablePos = (file.Exists("ldrp_craftingtable.txt", "DATA") and von.deserialize(file.Read("ldrp_craftingtable.txt", "DATA"))) or {}
concommand.Add("ldrp_craftingtable",function(ply,cmd,args)
	if !ply:IsAdmin() then return end
	local pos = ply:GetEyeTrace().HitPos
	local ang = ply:GetAngles()+Angle(0,180,0)
	LDRP.SavedTablePos.pos = pos
	LDRP.SavedTablePos.ang = ang
	file.Write("ldrp_craftingtable.txt", von.serialize(LDRP.SavedTablePos))
	if pos and ang then
		for k,v in pairs(ents.FindByClass("crafting_table")) do v:Remove() end
		
		local Table=ents.Create("crafting_table")
		Table:SetPos(pos+Vector(0,0,15))
		Table:SetAngles(ang)
		Table:Spawn()
	end
end)

hook.Add("Initialize","Spawn crafting table save",function()
	timer.Simple(4,function()
		local Check = LDRP.SavedTablePos
		if Check and Check.pos and Check.ang then
			local Table=ents.Create("crafting_table")
			Table:SetPos(Check.pos+Vector(0,0,15))
			Table:SetAngles(Check.ang)
			Table:Spawn()
		end
	end)
end)

LDRP.SellingWeed = (math.random(1,2) == 1)
LDRP.SellingShrooms = (math.random(1,2) == 1)
LDRP.BuyingWeed = (math.random(1,2) == 1)
LDRP.BuyingShrooms = (math.random(1,2) == 1)

timer.Create("DrugDealerChange_", 1000, 0, function()
	LDRP.SellingWeed = (math.random(1,2) == 1)
	LDRP.SellingShrooms = (math.random(1,2) == 1)
	LDRP.BuyingWeed = (math.random(1,2) == 1)
	LDRP.BuyingShrooms = (math.random(1,2) == 1)
end)

function LDRP.DrugDealerCMD(ply,cmd,args)
	if !args or !args[1] or !args[2] or ply:Team() != TEAM_DRUGDEALER then return end
	if !LDRP_SH.ShopPoses["Drug Dealer"] or ply:GetPos():Distance(LDRP_SH.ShopPoses["Drug Dealer"]) > 300 then return end
	
	local Do = args[1]
	local What = args[2]
	if Do == "buy" then
		if What == "weed" then
		
			if LDRP.SellingWeed then
				local Amount = tonumber(args[3]) or 1
				if Amount <= 0 then return end
				local Cost = Amount*LDRP_SH.SeedWorth
				if !ply:CanCarry("weed seed",Amount) then
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "You need to free up inventory space.")
					return
				end
				if ply:CanAfford(Cost) then
					ply:AddItem("weed seed",Amount)
					ply:AddMoney(-Cost)
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "Bought " .. Amount .. " seed(s) for $" .. Cost)
				else
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "You can't afford " .. Amount .. " seeds (costs $" .. Cost .. ")")
				end
			else
				ply:LiquidChat("DRUG DEALER", Color(0,180,0), "I don't have any weed seeds available right now.")
			end
		
		elseif What == "shrooms" then
		
			if LDRP.SellingShrooms then
				local Amount = tonumber(args[3]) or 1
				if Amount <= 0 then return end
				local Cost = Amount*LDRP_SH.SporeWorth
				if !ply:CanCarry("mushroom spore",Amount) then
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "You need to free up inventory space.")
					return
				end
				if ply:CanAfford(Cost) then
					ply:AddItem("mushroom spore",Amount)
					ply:AddMoney(-Cost)
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "Bought " .. Amount .. " mushroom spores for $" .. Cost)
				else
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "You can't afford " .. Amount .. " mushroom spores (costs $" .. Cost .. ")")
				end
			else
				ply:LiquidChat("DRUG DEALER", Color(0,180,0), "I don't have any mushroom spores available right now.")
			end

			
		end
	elseif Do == "sell" then
		if What == "weed" then
		
			if LDRP.BuyingWeed then
				local Bags = ply:HasItem("weed bag")
				if Bags then
					local Worth = Bags*LDRP_SH.WeedBagWorth
					ply:AddMoney(Worth)
					ply:AddItem("weed bag",-Bags)
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "Sold " .. Bags .. " bags of bud for $" .. Worth)
				else
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "You have no weed to sell.")
				end
			else
				ply:LiquidChat("DRUG DEALER", Color(0,180,0), "I don't have enough cash to buy weed right now.")
			end
			
		elseif What == "shrooms" then
		
			if LDRP.BuyingShrooms then
				local Bags = ply:HasItem("mushroom")
				if Bags then
					local Worth = Bags*LDRP_SH.ShroomWorth
					ply:AddMoney(Worth)
					ply:AddItem("mushroom",-Bags)
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "Sold " .. Bags .. " shrooms for $" .. Worth)
				else
					ply:LiquidChat("DRUG DEALER", Color(0,180,0), "You have no shrooms to sell.")
				end
			else
				ply:LiquidChat("DRUG DEALER", Color(0,180,0), "I don't have enough cash to buy shrooms right now.")
			end
			
		
		end
		
	end
end
concommand.Add("_dd",LDRP.DrugDealerCMD)

function LDRP.BailNPC(ply,cmd,args)
	if !LDRP_SH.ShopPoses["Bail NPC"] or ply:GetPos():Distance(LDRP_SH.ShopPoses["Bail NPC"]) > 300 then return end
	if ply:CanAfford(500) then
		if !RPArrestedPlayers[ply:SteamID()] then
			ply:LiquidChat("BAIL NPC", Color(0,0,200), "You're not even arrested!")
			return
		end
		ply:LiquidChat("BAIL NPC", Color(0,0,200), "Bailed you out for $500")
		ply:AddMoney(-500)
		ply:Unarrest()
		for k,v in pairs(team.GetPlayers(TEAM_POLICE)) do
			v:AddMoney(50)
			v:LiquidChat("BAIL NPC", Color(0,0,200), "Earned $50 for a bail. You should lock the jail doors.")
		end
		for k,v in pairs(team.GetPlayers(TEAM_CHIEF)) do
			v:AddMoney(50)
			v:LiquidChat("BAIL NPC", Color(0,0,200), "Earned $50 for a bail. You should lock the jail doors.")
		end
		if !ply:Alive() then ply:Spawn() end
	else
		ply:LiquidChat("BAIL NPC", Color(0,0,200), "Sorry, bail costs $500. You don't have enough.")
	end
end
concommand.Add("_bmo",LDRP.BailNPC)

function LDRP.GeneralStore(ply,cmd,args)
	if !args or !args[1] then return end
	
	if args[1] == "buy" then
		local Am = tonumber(args[2]) or 1
		if Am <= 0 then return end
		local Cost = Am*LDRP_SH.CarrotSeedPrice
		if ply:CanAfford(Cost) then
			ply:AddMoney(-Cost)
			ply:AddItem("carrot seed",Am)
			ply:LiquidChat("GENERAL STORE", Color(0,100,200), "Bought " .. Am .. " carrot seeds for $" .. Cost)
		else
			ply:LiquidChat("GENERAL STORE", Color(0,100,200), "You don't have enough for MY carrot seeds!! (costs $" .. Cost .. ")")
		end
	elseif args[1] == "sell" then
		local Carrot = ply:HasItem("carrot")
		if Carrot then
			ply:AddItem("carrot",-Carrot)
			local Earn = Carrot*LDRP_SH.CarrotBuyPrice
			ply:AddMoney(Earn)
			ply:LiquidChat("GENERAL STORE", Color(0,100,200), "Sold " .. Carrot .. " carrots for $" .. Earn)
		else
			ply:LiquidChat("GENERAL STORE", Color(0,100,200), "Come back when you actually HAVE some carrots.")
		end
	end
end
concommand.Add("__str",LDRP.GeneralStore)


function LDRP.StoreCMD(ply,cmd,args)
	local Type = args[1]
	local Item = args[2]
	local ItemTbl = (Type == "sell" and LDRP_SH.AllStores.Buys[Item]) or (Type == "buy" and LDRP_SH.AllStores.Sells[Item])
	
	if !Type or !ItemTbl then return end
	
	if Type == "buy" then
		if ply:GetPos():Distance(LDRP_SH.ShopPoses[ItemTbl.NPC]) < 500 then
			if ply:CanAfford(ItemTbl.Cost) then
				if ply:CanCarry(Item) then
					ply:LiquidChat("GAME", Color(0,200,200), "Purchased a " .. Item .. " for $" .. ItemTbl.Cost)
					ply:AddItem(Item,1)
					ply:AddMoney(-ItemTbl.Cost)
				else
					ply:LiquidChat("GAME", Color(0,200,200), "Free up some inventory space before buying this.")
				end
			else
				ply:LiquidChat("GAME", Color(0,200,200), "You can't afford this item.")
			end
		end
	elseif Type == "sell" then
		if ply:GetPos():Distance(LDRP_SH.ShopPoses[ItemTbl.NPC]) < 500 then
			local Am = ply:HasItem(Item)
			if Am and Am >= 1 then
				local Worth = Am*ItemTbl.Cost
				ply:LiquidChat("GAME", Color(0,200,200), "Sold " .. Am .. " " .. Item .. " for $" .. Worth)
				ply:AddItem(Item,-Am)
				ply:AddMoney(Worth)
			else
				ply:LiquidChat("GAME", Color(0,200,200), "You don't have any of this item to sell.")
			end
		end
	end
end
concommand.Add("__shp",LDRP.StoreCMD)

function LDRP.KillMayor(ply,inf,killer)
	if ply:Team() != TEAM_MAYOR then return end
	
	if !ply.Killed then
		ply:LiquidChat("GAME", Color(0,200,200), "If you die once more you will become a citizen.")
		ply.Killed = true
	else
		for k,v in pairs(player.GetAll()) do
			v:LiquidChat("GAME", Color(0,200,200), "The mayor has been assasinated completely!")
		end
		ply.Killed = nil
		ply:ChangeTeam(TEAM_CITIZEN, true)
	end
end
hook.Add("PlayerDeath","Demotes a killed mayor",LDRP.KillMayor)

local MR = math.Round
function LDRP.DoGetPos(ply,cmd,args)
	local EP = ply:GetEyeTrace().HitPos
	ply:ChatPrint("Here is the position you are looking at:")
	ply:ChatPrint("Vector(" .. MR(EP.x,2) .. "," .. MR(EP.y,2) .. "," .. MR(ep.z,2) .. ")")
end
concommand.Add("ldrp_getpos",LDRP.DoGetPos)
