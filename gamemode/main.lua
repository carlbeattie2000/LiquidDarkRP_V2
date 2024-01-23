--[[---------------------------------------------------------
 Variables
 ---------------------------------------------------------]]
local timeLeft = 10;
local timeLeft2 = 10;
local stormOn = false;
local zombieOn = false;
local maxZombie = 10;
-- Global function to send message to all players in table.
function SendMessageToAllPlayers(players, msg)
  if not players or not msg then return; end
  for k, v in pairs(players) do
    v:ChatPrint(msg);
  end
end

--[[---------------------------------------------------------
 Zombie
 ---------------------------------------------------------]]
local ZombieStart, ZombieEnd;
local function ControlZombie()
  timeLeft2 = timeLeft2 - 1;
  if timeLeft2 < 1 then
    if zombieOn then
      timeLeft2 = math.random(300, 500);
      zombieOn = false;
      timer.Stop("start2");
      ZombieEnd();
    else
      timeLeft2 = math.random(150, 300);
      zombieOn = true;
      timer.Start("start2");
      DB.RetrieveZombies(function() ZombieStart(); end);
    end
  end
end

ZombieStart = function()
  for k, v in pairs(player.GetAll()) do
    if v:Alive() then
      v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.zombie_approaching);
      v:PrintMessage(HUD_PRINTTALK, LANGUAGE.zombie_approaching);
    end
  end
end;

ZombieEnd = function()
  for k, v in pairs(player.GetAll()) do
    if v:Alive() then
      v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.zombie_leaving);
      v:PrintMessage(HUD_PRINTTALK, LANGUAGE.zombie_leaving);
    end
  end
end;

local function LoadTable(ply)
  ply:SetDarkRPVar("numPoints", table.getn(zombieSpawns));
  for k, v in pairs(zombieSpawns) do
    ply:SetDarkRPVar("zPoints" .. k, tostring(v));
  end
end

local function ReMoveZombie(ply, index)
  if ply:HasPriv("rp_commands") then
    if not index or zombieSpawns[tonumber(index)] == nil then
      Notify(ply, 1, 4, string.format(LANGUAGE.zombie_spawn_not_exist, tostring(index)));
    else
      DB.RetrieveZombies(function()
        Notify(ply, 0, 4, LANGUAGE.zombie_spawn_removed);
        table.remove(zombieSpawns, index);
        DB.StoreZombies();
        if ply.DarkRPVars.zombieToggle then LoadTable(ply); end
      end);
    end
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/removezombie"));
  end
  return "";
end

AddChatCommand("/removezombie", ReMoveZombie);
local function AddZombie(ply)
  if ply:HasPriv("rp_commands") then
    DB.RetrieveZombies(function()
      table.insert(zombieSpawns, tostring(ply:GetPos()));
      DB.StoreZombies();
      if ply.DarkRPVars.zombieToggle then LoadTable(ply); end
      Notify(ply, 0, 4, LANGUAGE.zombie_spawn_added);
    end);
  else
    Notify(ply, 1, 6, string.format(LANGUAGE.need_admin, "/addzombie"));
  end
  return "";
end

AddChatCommand("/addzombie", AddZombie);
local function ToggleZombie(ply)
  if ply:HasPriv("rp_commands") then
    if not ply.DarkRPVars.zombieToggle then
      DB.RetrieveZombies(function()
        ply:SetDarkRPVar("zombieToggle", true);
        LoadTable(ply);
      end);
    else
      ply:SetDarkRPVar("zombieToggle", false);
    end
  else
    Notify(ply, 1, 6, LANGUAGE.string.format(LANGUAGE.need_admin, "/showzombie"));
  end
  return "";
end

AddChatCommand("/showzombie", ToggleZombie);
local function GetAliveZombie()
  local zombieCount = 0;
  local ZombieTypes = {"npc_zombie", "npc_fastzombie", "npc_antlion", "npc_headcrab_fast"};
  for _, Type in pairs(ZombieTypes) do
    for _, zombie in pairs(ents.FindByClass(Type)) do
      zombieCount = zombieCount + 1;
    end
  end
  return zombieCount;
end

local function SpawnZombie()
  timer.Start("move");
  if GetAliveZombie() < maxZombie then
    if table.getn(zombieSpawns) > 0 then
      local zombieType = math.random(1, 4);
      local ZombieTypes = {"npc_zombie", "npc_fastzombie", "npc_antlion", "npc_headcrab_fast"};
      local Zombie = ents.Create(ZombieTypes[zombieType]);
      Zombie.nodupe = true;
      Zombie:Spawn();
      Zombie:Activate();
      Zombie:SetPos(DB.RetrieveRandomZombieSpawnPos());
    end
  end
end

local function ZombieMax(ply, args)
  if ply:HasPriv("rp_commands") then
    if not tonumber(args) then
      Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""));
      return "";
    end

    maxZombie = tonumber(args);
    Notify(ply, 0, 4, string.format(LANGUAGE.zombie_maxset, args));
  end
  return "";
end

AddChatCommand("/zombiemax", ZombieMax);
AddChatCommand("/maxzombie", ZombieMax);
AddChatCommand("/maxzombies", ZombieMax);
local function StartZombie(ply)
  if ply:HasPriv("rp_commands") then
    timer.Start("zombieControl");
    Notify(ply, 0, 4, LANGUAGE.zombie_enabled);
  end
  return "";
end

AddChatCommand("/enablezombie", StartZombie);
local function StopZombie(ply)
  if ply:HasPriv("rp_commands") then
    timer.Stop("zombieControl");
    zombieOn = false;
    timer.Stop("start2");
    ZombieEnd();
    Notify(ply, 0, 4, LANGUAGE.zombie_disabled);
    return "";
  end
end

AddChatCommand("/disablezombie", StopZombie);
timer.Create("start2", 1, 0, SpawnZombie);
timer.Create("zombieControl", 1, 0, ControlZombie);
timer.Stop("start2");
timer.Stop("zombieControl");
--[[---------------------------------------------------------
 Meteor storm
 ---------------------------------------------------------]]
local function StormStart()
  for k, v in pairs(player.GetAll()) do
    if v:Alive() then v:PrintMessage(HUD_PRINTTALK, LANGUAGE.meteor_approaching); end
  end
end

local function StormEnd()
  for k, v in pairs(player.GetAll()) do
    if v:Alive() then v:PrintMessage(HUD_PRINTTALK, LANGUAGE.meteor_passing); end
  end
end

local function ControlStorm()
  timeLeft = timeLeft - 1;
  if timeLeft < 1 then
    if stormOn then
      timeLeft = math.random(300, 500);
      stormOn = false;
      timer.Stop("start");
      StormEnd();
    else
      timeLeft = math.random(60, 90);
      stormOn = true;
      timer.Start("start");
      StormStart();
    end
  end
end

local function AttackEnt(ent)
  meteor = ents.Create("meteor");
  meteor.nodupe = true;
  meteor:Spawn();
  meteor:SetMeteorTarget(ent);
end

local function StartShower()
  timer.Adjust("start", math.random(.1, 1), 0, StartShower);
  for k, v in pairs(player.GetAll()) do
    if math.random(0, 2) == 0 and v:Alive() then AttackEnt(v); end
  end
end

local function StartStorm(ply)
  if ply:HasPriv("rp_commands") then
    timer.Start("stormControl");
    Notify(ply, 0, 4, LANGUAGE.meteor_enabled);
  end
  return "";
end

AddChatCommand("/enablestorm", StartStorm);
local function StopStorm(ply)
  if ply:HasPriv("rp_commands") then
    timer.Stop("stormControl");
    stormOn = false;
    timer.Stop("start");
    StormEnd();
    Notify(ply, 0, 4, LANGUAGE.meteor_disabled);
    return "";
  end
end

AddChatCommand("/disablestorm", StopStorm);
timer.Create("start", 1, 0, StartShower);
timer.Create("stormControl", 1, 0, ControlStorm);
timer.Stop("start");
timer.Stop("stormControl");
--[[---------------------------------------------------------
 Flammable
 ---------------------------------------------------------]]
local FlammableProps = {"drug", "drug_lab", "gunlab", "letter", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "spawned_money", "prop_physics"};
local function IsFlammable(ent)
  local class = ent:GetClass();
  for k, v in pairs(FlammableProps) do
    if class == v then return true; end
  end
  return false;
end

-- FireSpread from SeriousRP
local function FireSpread(e)
  if e:IsOnFire() then
    if e:IsMoneyBag() then e:Remove(); end
    local en = ents.FindInSphere(e:GetPos(), math.random(20, 90));
    local rand = math.random(0, 300);
    if rand <= 1 then
      for k, v in pairs(en) do
        if IsFlammable(v) then
          if not v.burned then
            v:Ignite(math.random(5, 180), 0);
            v.burned = true;
          else
            local color = v:GetColor();
            if (color.r - 51) >= 0 then color.r = color.r - 51; end
            if (color.g - 51) >= 0 then color.g = color.g - 51; end
            if (color.b - 51) >= 0 then color.b = color.b - 51; end
            v:SetColor(color);
            if (color.r + color.g + color.b) < 103 and math.random(1, 100) < 35 then
              v:Fire("enablemotion", "", 0);
              constraint.RemoveAll(v);
            end
          end

          break; -- Don't ignite all entities in sphere at once, just one at a time
        end
      end
    end
  end
end

local function FlammablePropThink()
  for k, v in ipairs(FlammableProps) do
    local ens = ents.FindByClass(v);
    for a, b in pairs(ens) do
      FireSpread(b);
    end
  end
end

timer.Create("FlammableProps", 0.1, 0, FlammablePropThink);
--[[---------------------------------------------------------
 Shipments
 ---------------------------------------------------------]]
local NoDrop = {}; -- Drop blacklist
local AlwaysAllow = {
  "pickaxe", -- Always allow these
  "pickaxe1",
  "pickaxevip",
  "hammer"
};

local function DropWeapon(ply)
  local ent = ply:GetActiveWeapon();
  if not IsValid(ent) then return ""; end
  local canDrop = hook.Call("CanDropWeapon", GAMEMODE, ply, ent);
  if not canDrop then
    Notify(ply, 1, 4, LANGUAGE.cannot_drop_weapon);
    return "";
  end

  local RP = RecipientFilter();
  RP:AddAllPlayers();
  umsg.Start("anim_dropitem", RP);
  umsg.Entity(ply);
  umsg.End();
  ply.anim_DroppingItem = true;
  timer.Simple(1, function() if IsValid(ply) and IsValid(ent) and ent:GetModel() then ply:DropDRPWeapon(ent); end end);
  return "";
end

AddChatCommand("/drop", DropWeapon);
AddChatCommand("/dropweapon", DropWeapon);
AddChatCommand("/weapondrop", DropWeapon);
--[[---------------------------------------------------------
Spawning 
 ---------------------------------------------------------]]
local function SetSpawnPos(ply, args)
  if not ply:HasPriv("rp_commands") then return ""; end
  local pos = string.Explode(" ", tostring(ply:GetPos()));
  local selection = "citizen";
  local t;
  for k, v in pairs(RPExtraTeams) do
    if args == v.command then
      t = k;
      Notify(ply, 0, 4, string.format(LANGUAGE.created_spawnpos, v.name));
    end
  end

  if t then
    DB.StoreTeamSpawnPos(t, pos);
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: " .. tostring(args)));
  end
  return "";
end

AddChatCommand("/setspawn", SetSpawnPos);
local function AddSpawnPos(ply, args)
  if not ply:HasPriv("rp_commands") then return ""; end
  local pos = string.Explode(" ", tostring(ply:GetPos()));
  local selection = "citizen";
  local t;
  for k, v in pairs(RPExtraTeams) do
    if args == v.command then
      t = k;
      Notify(ply, 0, 4, string.format(LANGUAGE.updated_spawnpos, v.name));
    end
  end

  if t then
    DB.AddTeamSpawnPos(t, pos);
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: " .. tostring(args)));
  end
  return "";
end

AddChatCommand("/addspawn", AddSpawnPos);
local function RemoveSpawnPos(ply, args)
  if not ply:HasPriv("rp_commands") then return ""; end
  local pos = string.Explode(" ", tostring(ply:GetPos()));
  local selection = "citizen";
  local t;
  for k, v in pairs(RPExtraTeams) do
    if args == v.command then
      t = k;
      Notify(ply, 0, 4, string.format(LANGUAGE.updated_spawnpos, v.name));
    end
  end

  if t then
    DB.RemoveTeamSpawnPos(t);
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: " .. tostring(args)));
  end
  return "";
end

AddChatCommand("/removespawn", RemoveSpawnPos);
function ShowSpare1(ply)
  ply:ConCommand("gm_showspare1\n");
end

concommand.Add("gm_spare1", ShowSpare1);
function ShowSpare2(ply)
  ply:ConCommand("gm_showspare2\n");
end

concommand.Add("gm_spare2", ShowSpare2);
function GM:ShowTeam(ply)
  umsg.Start("KeysMenu", ply);
  umsg.Bool(ply:GetEyeTrace().Entity:IsVehicle());
  umsg.End();
end

function GM:ShowHelp(ply)
  ply:SendLua([[RunConsoleCommand("__trd","start")]]);
end

local function LookPersonUp(ply, cmd, args)
  if not args[1] then
    ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", ""));
    return;
  end

  local P = GAMEMODE:FindPlayer(args[1]);
  if not IsValid(P) then
    ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: " .. tostring(args[1])));
    return;
  end

  ply:PrintMessage(2, "Nick: " .. P:Nick());
  ply:PrintMessage(2, "Steam name: " .. P:SteamName());
  ply:PrintMessage(2, "Steam ID: " .. P:SteamID());
end

concommand.Add("rp_lookup", LookPersonUp);
--[[---------------------------------------------------------
 Items
 ---------------------------------------------------------]]
local function MakeLetter(ply, args, type)
  if not GAMEMODE.Config.letters then
    Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/write / /type", ""));
    return "";
  end

  if ply.maxletters and ply.maxletters >= GAMEMODE.Config.maxletters then
    Notify(ply, 1, 4, string.format(LANGUAGE.limit, "letter"));
    return "";
  end

  if CurTime() - ply:GetTable().LastLetterMade < 3 then
    Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)), "/write / /type"));
    return "";
  end

  ply:GetTable().LastLetterMade = CurTime();
  -- Instruct the player's letter window to open
  local ftext = string.gsub(args, "//", "\n");
  ftext = string.gsub(ftext, "\\n", "\n") .. "\n\nYours,\n" .. ply:Nick();
  local length = string.len(ftext);
  local numParts = math.floor(length / 39) + 1;
  local tr = {};
  tr.start = ply:EyePos();
  tr.endpos = ply:EyePos() + 95 * ply:GetAimVector();
  tr.filter = ply;
  local trace = util.TraceLine(tr);
  local letter = ents.Create("letter");
  letter:SetModel("models/props_c17/paper01.mdl");
  letter.dt.owning_ent = ply;
  letter.ShareGravgun = true;
  letter:SetPos(trace.HitPos);
  letter.nodupe = true;
  letter:Spawn();
  letter:GetTable().Letter = true;
  letter.type = type;
  letter.numPts = numParts;
  local startpos = 1;
  local endpos = 39;
  letter.Parts = {};
  for k = 1, numParts do
    table.insert(letter.Parts, string.sub(ftext, startpos, endpos));
    startpos = startpos + 39;
    endpos = endpos + 39;
  end

  letter.SID = ply.SID;
  PrintMessageAll(2, string.format(LANGUAGE.created_x, ply:Nick(), "mail"));
  if not ply.maxletters then ply.maxletters = 0; end
  ply.maxletters = ply.maxletters + 1;
  timer.Simple(600, function() if IsValid(letter) then letter:Remove(); end end);
end

local function WriteLetter(ply, args)
  if args == "" then return ""; end
  MakeLetter(ply, args, 1);
  return "";
end

AddChatCommand("/write", WriteLetter);
local function TypeLetter(ply, args)
  if args == "" then return ""; end
  MakeLetter(ply, args, 2);
  return "";
end

AddChatCommand("/type", TypeLetter);
local function RemoveLetters(ply)
  for k, v in pairs(ents.FindByClass("letter")) do
    if v.SID == ply.SID then v:Remove(); end
  end

  Notify(ply, 4, 4, string.format(LANGUAGE.cleaned_up, "mails"));
  return "";
end

AddChatCommand("/removeletters", RemoveLetters);
local function SetPrice(ply, args)
  if args == "" then return ""; end
  local a = tonumber(args);
  if not a then return ""; end
  local b = math.Clamp(math.floor(a), GAMEMODE.Config.pricemin, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 500);
  local trace = {};
  trace.start = ply:EyePos();
  trace.endpos = trace.start + ply:GetAimVector() * 85;
  trace.filter = ply;
  local tr = util.TraceLine(trace);
  if not IsValid(tr.Entity) then
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave"));
    return "";
  end

  local class = tr.Entity:GetClass();
  if IsValid(tr.Entity) and (class == "gunlab" or class == "microwave" or class == "drug_lab") and tr.Entity.SID == ply.SID then
    tr.Entity.dt.price = b;
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave"));
  end
  return "";
end

AddChatCommand("/price", SetPrice);
AddChatCommand("/setprice", SetPrice);
for k, v in pairs(DarkRPEntities) do
  local function buythis(ply, args)
    if RPArrestedPlayers[ply:SteamID()] then return ""; end
    if type(v.allowed) == "table" and not table.HasValue(v.allowed, ply:Team()) then
      Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, v.cmd));
      return "";
    end

    local cmdname = string.gsub(v.ent, " ", "_");
    local disabled = tobool(GetConVarNumber("disable" .. cmdname));
    if disabled then
      Notify(ply, 1, 4, string.format(LANGUAGE.disabled, v.cmd, ""));
      return "";
    end

    if cmdname == "money_printer" and (ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF) then
      Notify(ply, 2, 4, "Money printers aren't allowed as cops!");
      return "";
    end

    local max = GetConVarNumber("max" .. cmdname);
    if not max or max == 0 then max = tonumber(v.max); end
    if ply:IsVIP() and cmdname == "money_printer" then max = max + 1; end
    if ply["max" .. cmdname] and tonumber(ply["max" .. cmdname]) >= tonumber(max) then
      Notify(ply, 1, 4, string.format(LANGUAGE.limit, v.cmd));
      return "";
    end

    local price = GetConVarNumber(cmdname .. "_price");
    if price == 0 then price = v.price; end
    if not ply:CanAfford(price) then
      Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, v.name));
      return "";
    end

    if GM.Config.DisabledModules["r_government"] then
      ply:AddMoney(-price);
    else
      hook.Call("r_government_item_sale", GAMEMODE, ply, v.name, price);
    end

    local trace = {};
    trace.start = ply:EyePos();
    trace.endpos = trace.start + ply:GetAimVector() * 85;
    trace.filter = ply;
    local tr = util.TraceLine(trace);
    local item = ents.Create(v.ent);
    item.dt = item.dt or {};
    item.dt.owning_ent = ply;
    item:SetPos(tr.HitPos);
    item.SID = ply.SID;
    item.onlyremover = true;
    if CPPI then item:CPPISetOwner(ply); end
    item:Spawn();
    Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, v.name, CUR .. price));
    if not ply["max" .. cmdname] then ply["max" .. cmdname] = 0; end
    ply["max" .. cmdname] = ply["max" .. cmdname] + 1;
    return "";
  end

  AddChatCommand(v.cmd, buythis);
end

local function BuyShipment(ply, args)
  if args == "" then return ""; end
  local trace = {};
  trace.start = ply:EyePos();
  trace.endpos = trace.start + ply:GetAimVector() * 85;
  trace.filter = ply;
  local tr = util.TraceLine(trace);
  if RPArrestedPlayers[ply:SteamID()] then return ""; end
  local found = false;
  local foundKey;
  for k, v in pairs(CustomShipments) do
    if string.lower(args) == string.lower(v.name) and not v.noship then
      found = v;
      foundKey = k;
      local canbecome = false;
      for a, b in pairs(v.allowed) do
        if ply:Team() == b then canbecome = true; end
      end

      if not canbecome then
        Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyshipment"));
        return "";
      end
    end
  end

  if not found then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyshipment", args));
    return "";
  end

  local cost = found.price;
  if not ply:CanAfford(cost) then
    Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "shipment"));
    return "";
  end

  ply:AddMoney(-cost);
  Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, args, CUR .. tostring(cost)));
  local crate = ents.Create("spawned_shipment");
  crate.SID = ply.SID;
  crate.dt.owning_ent = ply;
  crate:SetContents(foundKey, found.amount, found.weight);
  crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z));
  crate.nodupe = true;
  crate:Spawn();
  if found.shipmodel then
    crate:SetModel(found.shipmodel);
    crate:PhysicsInit(SOLID_VPHYSICS);
    crate:SetMoveType(MOVETYPE_VPHYSICS);
    crate:SetSolid(SOLID_VPHYSICS);
  end

  local phys = crate:GetPhysicsObject();
  if phys and phys:IsValid() then phys:Wake(); end
  return "";
end

AddChatCommand("/buyshipment", BuyShipment);
--[[---------------------------------------------------------
 Jobs
 ---------------------------------------------------------]]
local function CreateAgenda(ply, args)
  if DarkRPAgendas[ply:Team()] then
    ply:SetDarkRPVar("agenda", args);
    Notify(ply, 2, 4, LANGUAGE.agenda_updated);
    for k, v in pairs(DarkRPAgendas[ply:Team()].Listeners) do
      for a, b in pairs(team.GetPlayers(v)) do
        Notify(b, 2, 4, LANGUAGE.agenda_updated);
      end
    end
  else
    Notify(ply, 1, 6, string.format(LANGUAGE.unable, "agenda", "Incorrect team"));
  end
  return "";
end

AddChatCommand("/agenda", CreateAgenda);
local function GetHelp(ply, args)
  umsg.Start("ToggleHelp", ply);
  umsg.End();
  return "";
end

AddChatCommand("/help", GetHelp);
local function ChangeJob(ply, args)
  local netent, netstr = net.ReadEntity(), net.ReadString();
  if netent then ply = netent; end
  if netstr then args = netstr; end
  if args == "" then return ""; end
  if RPArrestedPlayers[ply:SteamID()] then
    Notify(ply, 1, 5, string.format(LANGUAGE.unable, "/job", ">2"));
    return "";
  end

  if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
    Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(10 - (CurTime() - ply.LastJob)), "/job"));
    return "";
  end

  ply.LastJob = CurTime();
  if not ply:Alive() then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ""));
    return "";
  end

  if not GAMEMODE.Config.customjobs then
    Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/job", ""));
    return "";
  end

  local len = string.len(args);
  if len < 3 then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ">2"));
    return "";
  end

  if len > 25 then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", "<26"));
    return "";
  end

  local jl = string.lower(args);
  local t = ply:Team();
  for k, v in pairs(RPExtraTeams) do
    if jl == v.name then ply:ChangeTeam(k); end
  end

  NotifyAll(2, 4, string.format(LANGUAGE.job_has_become, ply:Nick(), args));
  ply:UpdateJob(args);
  return "";
end

AddChatCommand("/job", ChangeJob);
util.AddNetworkString("ChangeJob");
net.Receive("ChangeJob", ChangeJob);
local function FinishDemote(vote, choice)
  local target = vote.target;
  target.IsBeingDemoted = nil;
  if choice == 1 then
    target:TeamBan();
    if target:Alive() then
      target:ChangeTeam(TEAM_CITIZEN, true);
      if target:isArrested() then target:arrest(); end
    else
      target.demotedWhileDead = true;
    end

    GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.demoted, target:Nick()));
  else
    GAMEMODE:NotifyAll(1, 4, string.format(LANGUAGE.demoted_not, target:Nick()));
  end
end

local function Demote(ply, args)
  local tableargs = string.Explode(" ", args);
  if #tableargs == 1 then
    GAMEMODE:Notify(ply, 1, 4, LANGUAGE.vote_specify_reason);
    return "";
  end

  local reason = "";
  for i = 2, #tableargs do
    reason = reason .. " " .. tableargs[i];
  end

  reason = string.sub(reason, 2);
  if string.len(reason) > 99 then
    GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", "<100"));
    return "";
  end

  local p = GAMEMODE:FindPlayer(tableargs[1]);
  if p == ply then
    GAMEMODE:Notify(ply, 1, 4, "Can't demote yourself.");
    return "";
  end

  local canDemote, message = hook.Call("CanDemote", GAMEMODE, ply, p, reason);
  if canDemote == false then
    GAMEMODE:Notify(ply, 1, 4, message or string.format(LANGUAGE.unable, "demote", ""));
    return "";
  end

  if p then
    if CurTime() - ply.LastVoteCop < 80 then
      GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"));
      return "";
    end

    if not RPExtraTeams[p:Team()] or RPExtraTeams[p:Team()].candemote == false then
      GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", ""));
    else
      GAMEMODE:TalkToPerson(p, team.GetColor(ply:Team()), "(DEMOTE) " .. ply:Nick(), Color(255, 0, 0, 255), "I want to demote you. Reason: " .. reason, p);
      GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.demote_vote_started, ply:Nick(), p:Nick()));
      DB.Log(string.format(LANGUAGE.demote_vote_started, ply:Nick(), p:Nick()) .. " (" .. reason .. ")", false, Color(255, 128, 255, 255));
      p.IsBeingDemoted = true;
      GAMEMODE.vote:create(p:Nick() .. ":\n" .. string.format(LANGUAGE.demote_vote_text, reason), "demote", p, 20, FinishDemote, {
        [p] = true,
        [ply] = true
      }, function(vote)
        if not IsValid(vote.target) then return; end
        vote.target.IsBeingDemoted = nil;
      end);

      ply:GetTable().LastVoteCop = CurTime();
    end
    return "";
  else
    GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: " .. tostring(args)));
    return "";
  end
end

AddChatCommand("/demote", Demote);
local function ExecSwitchJob(answer, ent, ply, target)
  if answer ~= 1 then return; end
  local Pteam = ply:Team();
  local Tteam = target:Team();
  ply:ChangeTeam(Tteam, true);
  target:ChangeTeam(Pteam, true);
  Notify(ply, 2, 4, LANGUAGE.team_switch);
  Notify(target, 2, 4, LANGUAGE.team_switch);
end

local function SwitchJob(ply) --Idea by Godness.
  if not GAMEMODE.Config.allowjobswitch then return ""; end
  local eyetrace = ply:GetEyeTrace();
  if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return ""; end
  ques:Create("Switch job with " .. ply:Nick() .. "?", "switchjob" .. tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity);
  return "";
end

AddChatCommand("/switchjob", SwitchJob);
AddChatCommand("/switchjobs", SwitchJob);
AddChatCommand("/jobswitch", SwitchJob);
local function DoTeamBan(ply, args, cmdargs)
  if not args or cmdargs == "" then return ""; end
  local ent = args;
  local Team = args;
  if cmdargs then
    if not cmdargs[1] then
      ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamban [player name/ID] [team name/id] Use this to ban a player from a certain team");
      return "";
    end

    ent = cmdargs[1];
    Team = cmdargs[2];
  else
    local a, b = string.find(args, " ");
    ent = string.sub(args, 1, a - 1);
    Team = string.sub(args, a + 1);
  end

  local target = GAMEMODE:FindPlayer(ent);
  if not target or not IsValid(target) then
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"));
    return "";
  end

  if (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", target)) or not ply:IsAdmin() then
    Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamban"));
    return "";
  end

  local found = false;
  for k, v in pairs(team.GetAllTeams()) do
    if string.lower(v.Name) == string.lower(Team) then
      Team = k;
      found = true;
      break;
    end

    if k == Team then
      found = true;
      break;
    end
  end

  if not found then
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"));
    return "";
  end

  if not target.bannedfrom then target.bannedfrom = {}; end
  target.bannedfrom[Team] = 1;
  NotifyAll(0, 5, ply:Nick() .. " has banned " .. target:Nick() .. " from being a " .. team.GetName(Team));
  return "";
end

AddChatCommand("/teamban", DoTeamBan);
concommand.Add("rp_teamban", DoTeamBan);
local function DoTeamUnBan(ply, args, cmdargs)
  if not ply:IsAdmin() then
    Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamunban"));
    return "";
  end

  local ent = args;
  local Team = args;
  if cmdargs then
    if not cmdargs[1] then
      ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamunban [player name/ID] [team name/id] Use this to unban a player from a certain team");
      return "";
    end

    ent = cmdargs[1];
    Team = cmdargs[2];
  else
    local a, b = string.find(args, " ");
    ent = string.sub(args, 1, a - 1);
    Team = string.sub(args, a + 1);
  end

  local target = GAMEMODE:FindPlayer(ent);
  if not target or not IsValid(target) then
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"));
    return "";
  end

  local found = false;
  for k, v in pairs(team.GetAllTeams()) do
    if string.lower(v.Name) == string.lower(Team) then
      Team = k;
      found = true;
      break;
    end

    if k == Team then
      found = true;
      break;
    end
  end

  if not found then
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"));
    return "";
  end

  if not target.bannedfrom then target.bannedfrom = {}; end
  target.bannedfrom[Team] = 0;
  NotifyAll(1, 5, ply:Nick() .. " has unbanned " .. target:Nick() .. " from being a " .. team.GetName(Team));
  return "";
end

AddChatCommand("/teamunban", DoTeamUnBan);
concommand.Add("rp_teamunban", DoTeamUnBan);
--[[---------------------------------------------------------
Talking 
 ---------------------------------------------------------]]
local function PM(ply, args)
  local namepos = string.find(args, " ");
  if not namepos then return ""; end
  local name = string.sub(args, 1, namepos - 1);
  local msg = string.sub(args, namepos + 1);
  if msg == "" then return ""; end
  target = GAMEMODE:FindPlayer(name);
  if target then
    local col = team.GetColor(ply:Team());
    GAMEMODE:TalkToPerson(target, col, "(PM) " .. ply:Nick(), Color(255, 255, 255, 255), msg, ply);
    GAMEMODE:TalkToPerson(ply, col, "(PM) " .. ply:Nick(), Color(255, 255, 255, 255), msg, ply);
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: " .. tostring(name)));
  end
  return "";
end

AddChatCommand("/pm", PM);
local function Whisper(ply, args)
  local DoSay = function(text)
    if text == "" then return ""; end
    TalkToRange(ply, "(" .. LANGUAGE.whisper .. ") " .. ply:Nick(), text, 90);
  end;
  return args, DoSay;
end

AddChatCommand("/w", Whisper);
local function Yell(ply, args)
  local DoSay = function(text)
    if text == "" then return ""; end
    TalkToRange(ply, "(" .. LANGUAGE.yell .. ") " .. ply:Nick(), text, 550);
  end;
  return args, DoSay;
end

AddChatCommand("/y", Yell);
local function Me(ply, args)
  if args == "" then return ""; end
  local DoSay = function(text)
    if text == "" then return ""; end
    if GAMEMODE.Config.alltalk then
      for _, target in pairs(player.GetAll()) do
        GAMEMODE:TalkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. text);
      end
    else
      TalkToRange(ply, ply:Nick() .. " " .. text, "", 250);
    end
  end;
  return args, DoSay;
end

AddChatCommand("/me", Me);
local function OOC(ply, args)
  if not GAMEMODE.Config.ooc then
    Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "OOC", ""));
    return "";
  end

  local DoSay = function(text)
    if text == "" then return ""; end
    local col = team.GetColor(ply:Team());
    local col2 = Color(255, 255, 255, 255);
    if not ply:Alive() then
      col2 = Color(255, 200, 200, 255);
      col = col2;
    end

    for k, v in pairs(player.GetAll()) do
      GAMEMODE:TalkToPerson(v, col, "(OOC) " .. ply:Name(), col2, text, ply);
    end
  end;
  return args, DoSay;
end

AddChatCommand("//", OOC, true);
AddChatCommand("/a", OOC, true);
AddChatCommand("/ooc", OOC, true);
local function PlayerAdvertise(ply, args)
  if args == "" then return ""; end
  local DoSay = function(text)
    if text == "" then return; end
    for k, v in pairs(player.GetAll()) do
      local col = team.GetColor(ply:Team());
      GAMEMODE:TalkToPerson(v, col, LANGUAGE.advert .. " " .. ply:Nick(), Color(255, 255, 0, 255), text, ply);
    end
  end;
  return args, DoSay;
end

AddChatCommand("/advert", PlayerAdvertise);
local function MayorBroadcast(ply, args)
  if args == "" then return ""; end
  if ply:Team() ~= TEAM_MAYOR then
    Notify(ply, 1, 4, "You have to be mayor");
    return "";
  end

  local DoSay = function(text)
    if text == "" then return; end
    for k, v in pairs(player.GetAll()) do
      local col = team.GetColor(ply:Team());
      GAMEMODE:TalkToPerson(v, col, "[Broadcast!] " .. ply:Nick(), Color(170, 0, 0, 255), text, ply);
    end
  end;
  return args, DoSay;
end

AddChatCommand("/broadcast", MayorBroadcast);
local function SetRadioChannel(ply, args)
  if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 99 then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/channel", "0<channel<100"));
    return "";
  end

  Notify(ply, 2, 4, "Channel set to " .. args .. "!");
  ply.RadioChannel = tonumber(args);
  return "";
end

AddChatCommand("/channel", SetRadioChannel);
local function SayThroughRadio(ply, args)
  if not ply.RadioChannel then ply.RadioChannel = 1; end
  if not args or args == "" then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/radio", ""));
    return "";
  end

  local DoSay = function(text)
    if text == "" then return; end
    for k, v in pairs(player.GetAll()) do
      if v.RadioChannel == ply.RadioChannel then GAMEMODE:TalkToPerson(v, Color(180, 180, 180, 255), "Radio " .. tostring(ply.RadioChannel), Color(180, 180, 180, 255), text, ply); end
    end
  end;
  return args, DoSay;
end

AddChatCommand("/radio", SayThroughRadio);
local function CombineRequest(ply, args)
  if args == "" then return ""; end
  local t = ply:Team();
  local DoSay = function(text)
    if text == "" then return; end
    for k, v in pairs(player.GetAll()) do
      if v:Team() == TEAM_POLICE or v:Team() == TEAM_CHIEF or v == ply then GAMEMODE:TalkToPerson(v, team.GetColor(ply:Team()), LANGUAGE.request .. ply:Nick(), Color(255, 0, 0, 255), text, ply); end
    end
  end;
  return args, DoSay;
end

AddChatCommand("/cr", CombineRequest);
local function GroupMsg(ply, args)
  if args == "" then return ""; end
  local DoSay = function(text)
    if text == "" then return; end
    local t = ply:Team();
    local col = team.GetColor(ply:Team());
    local hasReceived = {};
    for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
      -- not the group of the player
      if not func(ply) then continue; end
      for _, target in pairs(player.GetAll()) do
        if func(target) and not hasReceived[target] then
          hasReceived[target] = true;
          GAMEMODE:TalkToPerson(target, col, LANGUAGE.group .. " " .. ply:Nick(), Color(255, 255, 255, 255), text, ply);
        end
      end
    end
  end;
  return args, DoSay;
end

AddChatCommand("/g", GroupMsg, 1.5);
--[[---------------------------------------------------------
 Money
 ---------------------------------------------------------]]
local function GiveMoney(ply, args)
  if args == "" then return ""; end
  if not tonumber(args) then return ""; end
  local trace = ply:GetEyeTrace();
  if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
    local amount = math.floor(tonumber(args));
    if amount < 1 then
      Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""));
      return;
    end

    if not ply:CanAfford(amount) then
      Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""));
      return "";
    end

    local RP = RecipientFilter();
    RP:AddAllPlayers();
    umsg.Start("anim_giveitem", RP);
    umsg.Entity(ply);
    umsg.End();
    ply.anim_GivingItem = true;
    timer.Simple(1.2, function(ply)
      if IsValid(ply) then
        local trace2 = ply:GetEyeTrace();
        if IsValid(trace2.Entity) and trace2.Entity:IsPlayer() and trace2.Entity:GetPos():Distance(ply:GetPos()) < 150 then
          if not ply:CanAfford(amount) then
            Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""));
            return "";
          end

          DB.PayPlayer(ply, trace2.Entity, amount);
          Notify(trace2.Entity, 0, 4, string.format(LANGUAGE.has_given, ply:Nick(), CUR .. tostring(amount)));
          Notify(ply, 0, 4, string.format(LANGUAGE.you_gave, trace2.Entity:Nick(), CUR .. tostring(amount)));
          DB.Log(ply:Nick() .. " (" .. ply:SteamID() .. ") has given " .. CUR .. tostring(amount) .. " to " .. trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")");
        end
      end
    end, ply);
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "player"));
  end
  return "";
end

AddChatCommand("/give", GiveMoney);
local function DropMoney(ply, args)
  if args == "" then return ""; end
  if not tonumber(args) then return ""; end
  local amount = math.floor(tonumber(args));
  GAMEMODE:Notify(ply, 3, 5, "If you are giving money to someone, consider using the trade (F1) function instead!");
  if amount <= 1 then
    GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""));
    return "";
  end

  if not ply:CanAfford(amount) then
    GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""));
    return "";
  end

  ply:AddMoney(-amount);
  local RP = RecipientFilter();
  RP:AddAllPlayers();
  umsg.Start("anim_dropitem", RP);
  umsg.Entity(ply);
  umsg.End();
  ply.anim_DroppingItem = true;
  timer.Simple(1, function()
    if IsValid(ply) then
      local trace = {};
      trace.start = ply:EyePos();
      trace.endpos = trace.start + ply:GetAimVector() * 85;
      trace.filter = ply;
      local tr = util.TraceLine(trace);
      DarkRPCreateMoneyBag(tr.HitPos, amount);
      DB.Log(ply:Nick() .. " (" .. ply:SteamID() .. ") has dropped " .. GAMEMODE.Config.currency .. tostring(amount));
    end
  end);
  return "";
end

AddChatCommand("/dropmoney", DropMoney, 0.3);
AddChatCommand("/moneydrop", DropMoney, 0.3);
local function CreateCheque(ply, args)
  local argt = string.Explode(" ", args);
  local recipient = GAMEMODE:FindPlayer(argt[1]);
  local amount = tonumber(argt[2]);
  if not recipient then
    Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "recipient (1)"));
    return "";
  end

  if amount <= 1 then
    Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "amount (2)"));
    return "";
  end

  if not ply:CanAfford(amount) then
    Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""));
    return "";
  end

  if IsValid(ply) and IsValid(recipient) then ply:AddMoney(-amount); end
  umsg.Start("anim_dropitem", RecipientFilter():AddAllPlayers());
  umsg.Entity(ply);
  umsg.End();
  ply.anim_DroppingItem = true;
  timer.Simple(1, function(ply)
    if IsValid(ply) and IsValid(recipient) then
      local trace = {};
      trace.start = ply:EyePos();
      trace.endpos = trace.start + ply:GetAimVector() * 85;
      trace.filter = ply;
      local tr = util.TraceLine(trace);
      local Cheque = ents.Create("darkrp_cheque");
      Cheque:SetPos(tr.HitPos);
      Cheque.dt.owning_ent = ply;
      Cheque.dt.recipient = recipient;
      Cheque.dt.amount = amount;
      Cheque:Spawn();
    end
  end, ply);
  return "";
end

AddChatCommand("/cheque", CreateCheque);
AddChatCommand("/check", CreateCheque); -- for those of you who can't spell
local function MakeZombieSoundsAsHobo(ply)
  if not ply.nospamtime then ply.nospamtime = CurTime() - 2; end
  if not TEAM_HOBO or ply:Team() ~= TEAM_HOBO or CurTime() < (ply.nospamtime + 1.3) or (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then return; end
  ply.nospamtime = CurTime();
  local ran = math.random(1, 3);
  if ran == 1 then
    ply:EmitSound("npc/zombie/zombie_voice_idle" .. tostring(math.random(1, 14)) .. ".wav", 100, 100);
  elseif ran == 2 then
    ply:EmitSound("npc/zombie/zombie_pain" .. tostring(math.random(1, 6)) .. ".wav", 100, 100);
  elseif ran == 3 then
    ply:EmitSound("npc/zombie/zombie_alert" .. tostring(math.random(1, 3)) .. ".wav", 100, 100);
  end
end

concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo);
--[[---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------]]
local LotteryPeople = {};
local LotteryON = false;
local LotteryAmount = 0;
local CanLottery = CurTime();
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
  if tobool(answer) and not table.HasValue(LotteryPeople, target) then
    if not target:CanAfford(LotteryAmount) then
      GAMEMODE:Notify(target, 1, 4, string.format(LANGUAGE.cant_afford, "lottery"));
      return;
    end

    table.insert(LotteryPeople, target);
    target:AddMoney(-LotteryAmount);
    GAMEMODE:Notify(target, 0, 4, string.format(LANGUAGE.lottery_entered, GAMEMODE.Config.currency .. tostring(LotteryAmount)));
  elseif answer ~= nil and not table.HasValue(LotteryPeople, target) then
    GAMEMODE:Notify(target, 1, 4, string.format(LANGUAGE.lottery_not_entered, "You"));
  end

  if TimeIsUp then
    LotteryON = false;
    CanLottery = CurTime() + 60;
    if table.Count(LotteryPeople) == 0 then
      GAMEMODE:NotifyAll(1, 4, LANGUAGE.lottery_noone_entered);
      return;
    end

    local chosen = LotteryPeople[math.random(1, #LotteryPeople)];
    chosen:AddMoney(#LotteryPeople * LotteryAmount);
    GAMEMODE:NotifyAll(0, 10, string.format(LANGUAGE.lottery_won, chosen:Nick(), GAMEMODE.Config.currency .. tostring(#LotteryPeople * LotteryAmount)));
  end
end

local function DoLottery(ply)
  if ply:Team() ~= TEAM_MAYOR then
    Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/lottery"));
    return "";
  end

  if not GAMEMODE.Config.lottery then
    Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/lottery", ""));
    return "";
  end

  if #player.GetAll() <= 2 or LotteryON then
    Notify(ply, 1, 6, string.format(LANGUAGE.unable, "/lottery, there must be > 2 players", ""));
    return "";
  end

  if CanLottery > CurTime() then
    Notify(ply, 1, 5, string.format(LANGUAGE.have_to_wait, tostring(CanLottery - CurTime()), "/lottery"));
    return "";
  end

  NotifyAll(0, 4, "A lottery has started!");
  LotteryON = true;
  LotteryPeople = {};
  for k, v in pairs(player.GetAll()) do
    if v ~= ply then ques:Create("There is a lottery! Participate for " .. CUR .. tostring(GetConVarNumber("lotterycommitcost")) .. "?", "lottery" .. tostring(k), v, 30, EnterLottery, ply, v); end
  end

  timer.Create("Lottery", 30, 1, EnterLottery, nil, nil, nil, nil, true);
  return "";
end

AddChatCommand("/lottery", DoLottery);
local lstat = false;
local wait_lockdown = false;
local function WaitLock()
  wait_lockdown = false;
  lstat = false;
  timer.Destroy("spamlock");
end

-- Liquid DarkRP has a different lockdown system (some below code by Jackool)
local function LockdownCMD(ply, cmd, args)
  args = args or {
    [1] = ""
  };

  if args[2] then
    for k, v in pairs(args) do
      args[1] = args[1] .. " " .. v;
    end
  end

  if not lstat and ply:Team() == TEAM_MAYOR then
    ply:LiquidChat("GAME", Color(0, 200, 200), "Started a lockdown. Type /unlockdown to end it.");
    for k, v in pairs(player.GetAll()) do
      v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n");
    end

    lstat = true;
    PrintMessageAll(HUD_PRINTTALK, LANGUAGE.lockdown_started);
    NotifyAll(0, 3, LANGUAGE.lockdown_started);
    LockDownReasoning = args[1];
    umsg.Start("SendLockdown");
    umsg.String(args[1]);
    umsg.End();
  end
end

concommand.Add("_lckdwn", LockdownCMD);
local function Lockdown(ply)
  if ply:Team() ~= TEAM_MAYOR then return ""; end
  if not lstat then
    ply:ConCommand("lockreason");
  elseif LockDownReasoning then
    ply:LiquidChat("GAME", Color(0, 200, 200), "There is already a lockdown in progress. Type /unlockdown to end it.");
  elseif lstat then
    ply:LiquidChat("GAME", Color(0, 200, 200), "Please wait before starting another lockdown.");
  end
  return "";
end

concommand.Add("rp_lockdown", Lockdown);
AddChatCommand("/lockdown", Lockdown);
function UnLockdown(ply) -- Must be global
  if lstat and not wait_lockdown and ply:Team() == TEAM_MAYOR then
    PrintMessageAll(HUD_PRINTTALK, LANGUAGE.lockdown_ended);
    NotifyAll(1, 3, LANGUAGE.lockdown_ended);
    wait_lockdown = true;
    RunConsoleCommand("DarkRP_LockDown", 0);
    LockDownReasoning = nil;
    umsg.Start("SendLockdown");
    umsg.String("__StoP");
    umsg.End();
    timer.Create("spamlock", 20, 1, WaitLock, "");
  end
  return "";
end

concommand.Add("rp_unlockdown", UnLockdown);
AddChatCommand("/unlockdown", UnLockdown);
local function MayorSetSalary(ply, cmd, args)
  if ply:EntIndex() == 0 then
    print("Console should use rp_setsalary instead.");
    return;
  end

  if GAMEMODE.Config.enablemayorsetsalary then
    ply:PrintMessage(2, string.format(LANGUAGE.disabled, "rp_setsalary", ""));
    Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "rp_setsalary", ""));
    return;
  end

  if ply:Team() ~= TEAM_MAYOR then
    ply:PrintMessage(2, string.format(LANGUAGE.incorrect_job, "rp_setsalary"));
    return;
  end

  local amount = math.floor(tonumber(args[2]));
  if not amount or amount < 0 then
    ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "salary", args[2]));
    return;
  end

  if amount > GAMEMODE.Config.maxmayorsetsalary then
    ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "salary", "< " .. GAMEMODE.Config.maxmayorsetsalary));
    return;
  end

  local plynick = ply:Nick();
  local target = GAMEMODE:FindPlayer(args[1]);
  if target then
    local targetteam = target:Team();
    local targetnick = target:Nick();
    if targetteam == TEAM_MAYOR then
      Notify(ply, 1, 4, string.format(LANGUAGE.unable, "rp_setsalary", ""));
      return;
    elseif targetteam == TEAM_POLICE or targetteam == TEAM_CHIEF then
      if amount > GAMEMODE.Config.maxcopsalary then
        Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "salary", "< " .. GAMEMODE.Config.maxcopsalary));
        return;
      else
        DB.StoreSalary(target, amount);
        ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount);
        target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount);
      end
    elseif targetteam == TEAM_CITIZEN or targetteam == TEAM_GUN or targetteam == TEAM_MEDIC or targetteam == TEAM_COOK then
      if amount > GAMEMODE.Config.maxnormalsalary then
        Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "salary", "< " .. GAMEMODE.Config.maxnormalsalary));
        return;
      else
        DB.StoreSalary(target, amount);
        ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount);
        target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount);
      end
    elseif targetteam == TEAM_GANG or targetteam == TEAM_MOB then
      Notify(ply, 1, 4, string.format(LANGUAGE.unable, "rp_setsalary", ""));
      return;
    end
  else
    ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: " .. tostring(args[1])));
  end
  return;
end

concommand.Add("rp_mayor_setsalary", MayorSetSalary);
--[[---------------------------------------------------------
 License
 ---------------------------------------------------------]]
local function GrantLicense(answer, Ent, Initiator, Target)
  if answer == 1 then
    Notify(Initiator, 0, 4, string.format(LANGUAGE.gunlicense_granted, Target:Nick(), Initiator:Nick()));
    Notify(Target, 0, 4, string.format(LANGUAGE.gunlicense_granted, Target:Nick(), Initiator:Nick()));
    Initiator:SetDarkRPVar("HasGunlicense", true);
  else
    Notify(Initiator, 1, 4, string.format(LANGUAGE.gunlicense_denied, Target:Nick(), Initiator:Nick()));
  end
end

local function RequestLicense(ply)
  if ply.DarkRPVars.HasGunlicense then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/requestlicense", ""));
    return "";
  end

  local LookingAt = ply:GetEyeTrace().Entity;
  local ismayor; --first look if there's a mayor
  local ischief; -- then if there's a chief
  local iscop; -- and then if there's a cop to ask
  for k, v in pairs(player.GetAll()) do
    if v:Team() == TEAM_MAYOR then
      ismayor = true;
      break;
    end
  end

  if not ismayor then
    for k, v in pairs(player.GetAll()) do
      if v:Team() == TEAM_CHIEF then
        ischief = true;
        break;
      end
    end
  end

  if not ischief and not ismayor then
    for k, v in pairs(player.GetAll()) do
      if v:Team() == TEAM_POLICE then
        iscop = true;
        break;
      end
    end
  end

  if not ismayor and not ischief and not iscop then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/requestlicense", ""));
    return "";
  end

  if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "mayor/chief/cop"));
    return "";
  end

  if ismayor and LookingAt:Team() ~= TEAM_MAYOR then
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "mayor"));
    return "";
  elseif ischief and LookingAt:Team() ~= TEAM_CHIEF then
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "chief"));
    return "";
  elseif iscop and LookingAt:Team() ~= TEAM_POLICE then
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "cop"));
    return "";
  end

  Notify(ply, 3, 4, string.format(LANGUAGE.gunlicense_requested, ply:Nick(), LookingAt:Nick()));
  ques:Create(string.format(LANGUAGE.gunlicense_question_text, ply:Nick()), "Gunlicense" .. ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt);
  return "";
end

AddChatCommand("/requestlicense", RequestLicense);
local function GiveLicense(ply)
  local ismayor; --first look if there's a mayor
  local ischief; -- then if there's a chief
  local iscop; -- and then if there's a cop to ask
  for k, v in pairs(player.GetAll()) do
    if v:Team() == TEAM_MAYOR then
      ismayor = true;
      break;
    end
  end

  if not ismayor then
    for k, v in pairs(player.GetAll()) do
      if v:Team() == TEAM_CHIEF then
        ischief = true;
        break;
      end
    end
  end

  if not ischief and not ismayor then
    for k, v in pairs(player.GetAll()) do
      if v:Team() == TEAM_POLICE then
        iscop = true;
        break;
      end
    end
  end

  if ismayor and ply:Team() ~= TEAM_MAYOR then
    Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"));
    return "";
  elseif ischief and ply:Team() ~= TEAM_CHIEF then
    Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"));
    return "";
  elseif iscop and ply:Team() ~= TEAM_POLICE then
    Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"));
    return "";
  end

  local LookingAt = ply:GetEyeTrace().Entity;
  if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
    Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "player"));
    return "";
  end

  Notify(LookingAt, 0, 4, string.format(LANGUAGE.gunlicense_granted, ply:Nick(), LookingAt:Nick()));
  Notify(ply, 0, 4, string.format(LANGUAGE.gunlicense_granted, ply:Nick(), LookingAt:Nick()));
  LookingAt:SetDarkRPVar("HasGunlicense", true);
  return "";
end

AddChatCommand("/givelicense", GiveLicense);
local function rp_GiveLicense(ply, cmd, args)
  if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
    ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_givelicense"));
    return;
  end

  local target = GAMEMODE:FindPlayer(args[1]);
  if target then
    target:SetDarkRPVar("HasGunlicense", true);
    if ply:EntIndex() ~= 0 then
      nick = ply:Nick();
    else
      nick = "Console";
    end

    Notify(target, 1, 4, string.format(LANGUAGE.gunlicense_granted, nick, target:Nick()));
    Notify(ply, 2, 4, string.format(LANGUAGE.gunlicense_granted, nick, target:Nick()));
    DB.Log(ply:SteamName() .. " (" .. ply:SteamID() .. ") force-gave " .. target:Nick() .. " a gun license");
    if ply:EntIndex() == 0 then
      DB.Log("Console force-gave " .. target:Nick() .. " a gun license");
    else
      DB.Log(ply:SteamName() .. " (" .. ply:SteamID() .. ") force-gave " .. target:Nick() .. " a gun license");
    end
  else
    if ply:EntIndex() == 0 then
      print(string.format(LANGUAGE.could_not_find, "player: " .. tostring(args[1])));
    else
      ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: " .. tostring(args[1])));
    end
    return;
  end
end

concommand.Add("rp_givelicense", rp_GiveLicense);
local function rp_RevokeLicense(ply, cmd, args)
  if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
    ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_revokelicense"));
    return;
  end

  local target = GAMEMODE:FindPlayer(args[1]);
  if target then
    target:SetDarkRPVar("HasGunlicense", false);
    if ply:EntIndex() ~= 0 then
      nick = ply:Nick();
    else
      nick = "Console";
    end

    Notify(target, 1, 4, string.format(LANGUAGE.gunlicense_denied, nick, target:Nick()));
    Notify(ply, 1, 4, string.format(LANGUAGE.gunlicense_denied, nick, target:Nick()));
    DB.Log(ply:SteamName() .. " (" .. ply:SteamID() .. ") force-removed " .. target:Nick() .. "'s gun license");
    if ply:EntIndex() == 0 then
      DB.Log("Console force-removed " .. target:Nick() .. "'s gun license");
    else
      DB.Log(ply:SteamName() .. " (" .. ply:SteamID() .. ") force-removed " .. target:Nick() .. "'s gun license");
    end
  else
    if ply:EntIndex() == 0 then
      print(string.format(LANGUAGE.could_not_find, "player: " .. tostring(args[1])));
    else
      ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: " .. tostring(args[1])));
    end
    return;
  end
end

concommand.Add("rp_revokelicense", rp_RevokeLicense);
local function FinishRevokeLicense(choice, v)
  if choice == 1 then
    v:SetDarkRPVar("HasGunlicense", false);
    v:StripWeapons();
    GAMEMODE:PlayerLoadout(v);
    NotifyAll(0, 4, string.format(LANGUAGE.gunlicense_removed, v:Nick()));
  else
    NotifyAll(0, 4, string.format(LANGUAGE.gunlicense_not_removed, v:Nick()));
  end
end

local function VoteRemoveLicense(ply, args)
  local tableargs = string.Explode(" ", args);
  if #tableargs == 1 then
    Notify(ply, 1, 4, LANGUAGE.vote_specify_reason);
    return "";
  end

  local reason = "";
  for i = 2, #tableargs do
    reason = reason .. " " .. tableargs[i];
  end

  reason = string.sub(reason, 2);
  if string.len(reason) > 22 then
    Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demotelicense", "<23"));
    return "";
  end

  local p = GAMEMODE:FindPlayer(tableargs[1]);
  if p then
    if CurTime() - ply:GetTable().LastVoteCop < 80 then
      Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"));
      return "";
    end

    if ply.DarkRPVars.HasGunlicense then
      Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demotelicense", ""));
    else
      NotifyAll(0, 4, string.format(LANGUAGE.gunlicense_remove_vote_text, ply:Nick(), p:Nick()));
      GAMEMODE.vote:create(p:Nick() .. ":\n" .. string.format(LANGUAGE.gunlicense_remove_vote_text2, reason), p:EntIndex() .. "votecop" .. ply:EntIndex(), p, 20, FinishRevokeLicense, true);
      ply:GetTable().LastVoteCop = CurTime();
      Notify(ply, 0, 4, LANGUAGE.vote_started);
    end
    return "";
  else
    Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: " .. tostring(args)));
    return "";
  end
end

AddChatCommand("/demotelicense", VoteRemoveLicense);
function RaidCommand(ply, cmd, args)
  if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF then ply:ChatPrint("Police are not allowed to raid!"); end
  local ENT = ply:GetEyeTrace()["Entity"];
  local ENT_Owner = ENT:GetDoorOwner();
  if not ENT:IsDoor() then
    ply:ChatPrint("Must be looking at a door!");
    return "";
  end

  if not IsValid(ENT_Owner) then
    ply:ChatPrint("Door must be owned!");
    return "";
  end

  if ENT_Owner == ply then
    ply:ChatPrint("You can't raid yourself!");
    return "";
  end

  local GlobalNotifaction = "%s is raiding!";
  NotifyAll(1, 6, string.format(GlobalNotifaction, ply:Nick()));
  -- Notify the player being raided
  Notify(ply, 0, 6, "You are being raided!");
  return "";
end

AddChatCommand("/raid", RaidCommand);
local preventRollSpam = false;
function RollDice(ply, cmd, args)
  if preventRollSpam then return ""; end
  preventRollSpam = true;
  local ENT = ply:GetEyeTrace()["Entity"];
  if not ENT:IsPlayer() then ply:ChatPrint("Must be looking at player!"); end
  local numberRolled = math.random(1, 30);
  ply:ChatPrint(string.format("Rolled: %s", numberRolled));
  ENT:ChatPrint(string.format("Rolled: %s", numberRolled));
  timer.Simple(10, function() preventRollSpam = false; end);
  return "";
end

AddChatCommand("/roll", RollDice);
function CoinFlip(ply, args)
  if not args or args == "" then
    ply:ChatPrint("/flip |target| <amount>");
    return "";
  end

  local betAmount = tonumber(args);
  local ENT = ply:GetEyeTrace()["Entity"];
  if not ENT:IsPlayer() then
    ply:ChatPrint("Must be looking at player!");
    return "";
  end

  local players = {ply, ENT};
  for k, v in pairs(players) do
    local playerCash = v:getDarkRPVar("money");
    if playerCash < betAmount then
      SendMessageToAllPlayers(players, "Not enough money to do this flip!");
      return "";
    end
  end

  SendMessageToAllPlayers(players, "Coin flip started!");
  local winner = table.Random(players);
  timer.Simple(3, function()
    SendMessageToAllPlayers(players, string.format("%s won $%s", winner:Nick(), betAmount * 2));
    for k, v in pairs(players) do
      if v == winner then
        v:AddMoney(betAmount);
      else
        v:AddMoney(-betAmount);
      end
    end
  end);
  return "";
end

AddChatCommand("/flip", CoinFlip);
