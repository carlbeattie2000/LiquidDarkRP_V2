local ChatCommands = {}


function AddChatCommand(cmd, callback, delay)

	local detour = function(ply, arg, ...)
		if ply.DarkRPUnInitialized then
			GAMEMODE:Notify(ply, 1, 4, "Your data has not been loaded yet. Please wait.")
			GAMEMODE:Notify(ply, 1, 4, "If this persists, try rejoining or contacting an admin.")
			return ""
		end
		return callback(ply, arg, ...)
	end

	ChatCommands[string.lower(cmd)] = {
		cmd = cmd,
		callback = detour,
		delay = delay
	}
end

function removeChatCommand(cmd)
	ChatCommands[string.lower(cmd)] = nil
end

function getChatCommand(cmd)
	return ChatCommands[string.lower(cmd)]
end

local function RP_PlayerChat(ply, text)
	DB.Log(ply:SteamName().." ("..ply:SteamID().."): "..text )
	local callback = "" 
	local DoSayFunc
	for k, v in pairs(ChatCommands) do
		if string.lower(v.cmd) == string.Explode(" ", string.lower(text))[1] then
			callback, DoSayFunc = v.callback(ply, string.sub(text, string.len(v.cmd) + 2, string.len(text)))
			if callback == "" then 
				return "", "" , DoSayFunc
			end
			text = string.sub(text, string.len(v.cmd) + 2, string.len(text)).. " "
		end
	end
	if callback ~= "" then callback = (callback or "").." " end
	return text, callback, DoSayFunc
end

local function RP_ActualDoSay(ply, text, callback)
	callback = callback or ""
	if text == "" then return "" end
	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if not ply:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end
	
	if GAMEMODE.Config.alltalk then
		for k,v in pairs(player.GetAll()) do
			GAMEMODE:TalkToPerson(v, col, callback..ply:Name(), col2, text, ply)
		end
	else
		TalkToRange(ply, callback..ply:Name(), text, 250)
	end
	return "" 
end

local otherhooks = {}

--Where the chat magic begins (server side, at least).
function GM:PlayerSay(ply, text, isTeamChat) -- We will make the old hooks run AFTER DarkRP's playersay has been run.
	local text2 = (not isTeamChat and "" or "/g ") .. text
	local callback
	text2, callback, DoSayFunc = RP_PlayerChat(ply, text2)
	if tostring(text2) == " " then text2, callback = callback, text2 end
	for k,v in SortedPairs(otherhooks, false) do
		if type(v) == "function" then
			text2 = v(ply, text2) or text2
		end
	end
	if game.IsDedicated() then
		ServerLog("\""..ply:Nick().."<"..ply:UserID()..">" .."<"..ply:SteamID()..">".."<"..team.GetName( ply:Team() )..">\" say \""..text.. "\"\n")
	end
	
	if DoSayFunc then DoSayFunc(text2) return "" end
	text2 = RP_ActualDoSay(ply, text2, callback) 
	return false
end

--Remove all PlayerSay hooks, they all interfere with DarkRP's PlayerSay
hook.Add("InitPostEntity", "DarkRP_ChatCommands", function()
	if not hook.GetTable().PlayerSay then return end
	for k,v in pairs(hook.GetTable().PlayerSay) do
		otherhooks[k] = v
		hook.Remove("PlayerSay", k)
	end
	for a,b in pairs(otherhooks) do
		if type(b) ~= "function" then
			otherhooks[a] = nil
		end
	end
end)

function TalkToRange(ply, PlayerName, Message, size)
	local ents = ents.FindInSphere(ply:EyePos(), size)
	local col = team.GetColor(ply:Team())
	local filter = RecipientFilter() 
	filter:RemoveAllPlayers()
	for k, v in pairs(ents) do
		if v:IsPlayer() then
			filter:AddPlayer(v)
		end
	end
	
	umsg.Start("DarkRP_Chat", filter)
		umsg.Short(col.r)
		umsg.Short(col.g)
		umsg.Short(col.b)
		umsg.String(PlayerName)
		umsg.Entity(ply)
		umsg.Short(255)
		umsg.Short(255)
		umsg.Short(255)
		umsg.String(Message)
	umsg.End()
end

function GM:TalkToPerson(receiver, col1, text1, col2, text2, sender)
	umsg.Start("DarkRP_Chat", receiver)
		umsg.Short(col1.r)
		umsg.Short(col1.g)
		umsg.Short(col1.b)
		umsg.String(text1)
		if sender then
			umsg.Entity(sender)
		end
		if col2 and text2 then
			umsg.Short(col2.r)
			umsg.Short(col2.g)
			umsg.Short(col2.b)
			umsg.String(text2)
		end
	umsg.End()
end

function ConCommand(ply, _, args)
	if not args[1] then for k,v in pairs(ChatCommands) do print(k) end return end

	local cmd = string.lower(args[1])
	local arg = table.concat(args, ' ', 2)
	local tbl = ChatCommands[cmd]
	local time = CurTime()
	
	if not tbl then return end

	ply.DrpCommandDelays = ply.DrpCommandDelays or {}

	if tbl.delay and ply.DrpCommandDelays[cmd] and ply.DrpCommandDelays[cmd] > time - tbl.delay then
		return
	end

	ply.DrpCommandDelays[cmd] = time

	tbl.callback(ply, arg)
end
concommand.Add("darkrp", ConCommand)