--Keeping the old function in for backwards compatibility (ugh, all the calls that would need updating :()
function Notify(ply, msgtype, len, msg)
	GAMEMODE:Notify(ply, msgtype, len, msg)
end

--See notification.AddLegacy for message types
function GM:Notify(ply, msgtype, len, msg)
	if not IsValid(ply) then return end
	umsg.Start("_Notify", ply)
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function NotifyAll(msgtype, len, msg)
	GAMEMODE:NotifyAll(msgtype, len, msg)
end

function GM:NotifyAll(msgtype, len, msg)
	umsg.Start("_Notify")
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function PrintMessageAll(msgtype, msg)
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(msgtype, msg)
	end
end

function GM:FindPlayer(info)
	if not info or info == "" then return nil end
	local pls = player.GetAll()

	-- Find by Index Number (status in console)
	for k = 1, #pls do -- Proven to be faster than pairs loop.
		local v = pls[k]
		if tonumber(info) == v:UserID() then
			return v
		end

		if info == v:SteamID() then
			return v
		end
	
		if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then
			return v
		end
	
		if string.find(string.lower(v:Name()), string.lower(tostring(info)), 1, true) ~= nil then
			return v
		end
	end
	return nil
end


function GM:IsEmpty(vector, ignore)
	ignore = ignore or {}

	local point = util.PointContents(vector)
	local a = point ~= CONTENTS_SOLID
		and point ~= CONTENTS_MOVEABLE
		and point ~= CONTENTS_LADDER
		and point ~= CONTENTS_PLAYERCLIP
		and point ~= CONTENTS_MONSTERCLIP

	local b = true

	for k,v in pairs(ents.FindInSphere(vector, 35)) do
		if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics") and not table.HasValue(ignore, v) then
			b = false
			break
		end
	end

	return a and b
end

/*---------------------------------------------------------------------------
Find an empty position near the position given in the first parameter
pos - The position to use as a center for looking around
ignore - what entities to ignore when looking for the position (the position can be within the entity)
distance - how far to look
step - how big the steps are
area - the position relative to pos that should also be free

Performance: O(N^2) (The Lua part, that is, I don't know about the C++ counterpart)
Don't call this function too often or with big inputs.
---------------------------------------------------------------------------*/
function GM:FindEmptyPos(pos, ignore, distance, step, area)
	if GAMEMODE:IsEmpty(pos, ignore) and GAMEMODE:IsEmpty(pos + area, ignore) then
		return pos
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do -- alternate in direction
			local k = j * i

			-- Look North/South
			if GAMEMODE:IsEmpty(pos + Vector(k, 0, 0), ignore) and GAMEMODE:IsEmpty(pos + Vector(k, 0, 0) + area, ignore) then
				return pos + Vector(k, 0, 0)
			end

			-- Look East/West
			if GAMEMODE:IsEmpty(pos + Vector(0, k, 0), ignore) and GAMEMODE:IsEmpty(pos + Vector(0, k, 0) + area, ignore) then
				return pos + Vector(0, k, 0)
			end

			-- Look Up/Down
			if GAMEMODE:IsEmpty(pos + Vector(0, 0, k), ignore) and GAMEMODE:IsEmpty(pos + Vector(0, 0, k) + area, ignore) then
				return pos + Vector(0, 0, k)
			end
		end
	end

	return pos
end

--Writes the specified message to the console, with the level controlling things like if the message shows,
--and how it is displayed.
Severity = {
["Critical"] = 0, --Tells players what just hit the fan
["Error"] = 1,
["Info"] = 2,
["Debug"] = 3}

function GM:WriteOut(message, level)
	if level == 0 then
		MsgAll(self.Name, " is experiencing some technical difficulties!\n", message)
		error(message, 2)
	elseif level == 1 then
		error(message, 0)
	elseif level == 2 then
		MsgC(Color(100, 100, 255), "[", self.Name, "-Info] ")
		MsgN(message)
	elseif level == 3 then
		MsgC(Color(150, 150, 220), "[", self.Name, "-Dbg] ")
		MsgN(message)
	end
end