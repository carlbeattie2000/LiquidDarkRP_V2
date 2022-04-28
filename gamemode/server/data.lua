include("static_data.lua")

/*---------------------------------------------------------------------------
Functions and variables
---------------------------------------------------------------------------*/
local teamSpawns = {}
local jailPos = {}
local createSpawnPos,
	setUpNonOwnableDoors,
	setUpTeamOwnableDoors,
	setUpGroupDoors,
	createJailPos
DB.Prefix = "ldrp"

local CustomTables = {}
--Sample value: string: "table_name", table: table_columns{"name", "data_type", bool allow_null (default = false), bool is_pk (default = false)}}

--[[---------------------------------------------------------
	DB.DeclareTable - Tells us that a custom table should be
	be made available in the database. This encompasses
	creating the table if it does not exist, as well as
	allowing for reading, adding, deleting, and editing data.
	table_columns follows the structure of the nested table
	in CustomTables as defined above.
	Ex: DB:DeclareTable("cvars, {{name = "var", data_type = "char(20)", allow_null = false, is_pk = true},
	{name = "value", data_type = "INTEGER", allow_null = false, is_pk = false}})
	* Creates the table ldrp_cvars. See below for the SQL code.
	
	CREATE TABLE IF NOT EXISTS ldrp_cvars(var char(20) NOT NULL, value INTEGER NOT NULL, PRIMARY KEY(var));")
-----------------------------------------------------------]]
function DB:DeclareTable(table_name, table_columns)
	table.insert(CustomTables, {["table_name"] = table_name, ["table_columns"] = table_columns})
	GM:WriteOut("Declaring custom table "..DB.Prefix.."_"..table_name, Severity.Debug)
end

--[[---------------------------------------------------------
	DB.RetrieveData - Gets rows from table_name matching filter,
	returning the columns specified in columns.
	Ex: DB:RetrieveData("npcs", "*", nil) --Gets all NPCs.
-----------------------------------------------------------]]
function DB:RetrieveData(table_name, columns, filter, callback)
	local query = "SELECT "..columns.." FROM "..DB.Prefix.."_"..table_name
	if not filter then
		query = query..";"
	else
		query = query.." WHERE "..filter..";"
	end

	MySQLite.query(query, callback)
end

--[[---------------------------------------------------------
	DB.StoreEntry - Inserts a table of column-value pairs (data) into a
	new row in table_name. Don't forget to sanitize the
	values!
	Ex of data: {var = "flashlight", value = "1"}
-----------------------------------------------------------]]
function DB:StoreEntry(table_name, data, callback)
	local queryvalues = ""
	local columns = ""
	if not istable( data ) then error( "StoreEntry was not passed a table datatype for var data." ) end
	
	table.foreach(data, function(k, v)
		columns = columns .. tostring( k ) .. ", "
		queryvalues = queryvalues .. tostring(v) .. ", "
	end)
	
	queryvalues = string.sub( queryvalues, 1, #queryvalues - 2 ) --Trim the trailing comma and space
	columns = string.sub( columns, 1, #columns - 2 )

	MySQLite.query( "INSERT INTO "..DB.Prefix.."_"..table_name.." ("..columns..") VALUES ("..queryvalues.. ");", callback )
end

--[[---------------------------------------------------------
	DB.DeleteEntry - Remove a row with values matching match
	(used in the WHERE statement) from table_name.
-----------------------------------------------------------]]
function DB:DeleteEntry(table_name, match, callback)
	MySQLite.query("DELETE FROM "..DB.Prefix.."_"..table_name.." WHERE "..match..";", callback)
end

/*---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------*/
function DarkRP.initDatabase()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.begin()
		-- Gotta love the difference between SQLite and MySQL
		local AUTOINCREMENT = MySQLite.CONNECTED_TO_MYSQL and "AUTO_INCREMENT" or "AUTOINCREMENT"

		-- Create the table for the convars used in DarkRP
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_cvar(
				var VARCHAR(25) NOT NULL PRIMARY KEY,
				value INTEGER NOT NULL
			);
		]])

		-- Table that holds all position data (jail, consoles, zombie spawns etc.)
		-- Queue these queries because other queries depend on the existence of the darkrp_position table
		-- Race conditions could occur if the queries are executed simultaneously
		MySQLite.queueQuery([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_position(
				id INTEGER NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
				map VARCHAR(45) NOT NULL,
				type CHAR(1) NOT NULL,
				x INTEGER NOT NULL,
				y INTEGER NOT NULL,
				z INTEGER NOT NULL
			);
		]])

		-- team spawns require extra data
		MySQLite.queueQuery([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_jobspawn(
				id INTEGER NOT NULL PRIMARY KEY,
				team INTEGER NOT NULL
			);
		]])

		if MySQLite.CONNECTED_TO_MYSQL then
			MySQLite.queueQuery([[
				ALTER TABLE ]]..DB.Prefix..[[_jobspawn ADD FOREIGN KEY(id) REFERENCES ]]..DB.Prefix..[[_position(id)
					ON UPDATE CASCADE
					ON DELETE CASCADE;
			]])
		end


		-- Consoles have to be spawned in an angle
		MySQLite.queueQuery([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_console(
				id INTEGER NOT NULL PRIMARY KEY,
				pitch INTEGER NOT NULL,
				yaw INTEGER NOT NULL,
				roll INTEGER NOT NULL,

				FOREIGN KEY(id) REFERENCES ]]..DB.Prefix..[[_position(id)
					ON UPDATE CASCADE
					ON DELETE CASCADE
			);
		]])
		
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS playerinformation(
				uid BIGINT NOT NULL,
				steamID VARCHAR(50) NOT NULL PRIMARY KEY
			)
		]])
		-- Player information
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_player(
				uid BIGINT NOT NULL PRIMARY KEY,
				rpname VARCHAR(45),
				salary INTEGER NOT NULL DEFAULT 45,
				wallet INTEGER NOT NULL,
				UNIQUE(rpname)
			);
		]])

		-- Door data
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_door(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				title VARCHAR(25),
				isLocked BOOLEAN,
				isDisabled BOOLEAN NOT NULL DEFAULT FALSE,
				PRIMARY KEY(idx, map)
			);
		]])

		-- Some doors are owned by certain teams
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_jobown(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				job INTEGER NOT NULL,

				PRIMARY KEY(idx, map, job)
			);
		]])

		-- Door groups
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS ]]..DB.Prefix..[[_doorgroups(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				doorgroup VARCHAR(100) NOT NULL,

				PRIMARY KEY(idx, map)
			)
		]])

		-- SQlite doesn't really handle foreign keys strictly, neither does MySQL by default
		-- So to keep the DB clean, here's a manual partial foreign key enforcement
		-- For now it's deletion only, since updating of the common attribute doesn't happen.

		-- MySQL trigger
		if MySQLite.CONNECTED_TO_MYSQL then
			MySQLite.query("show triggers", function(data)
				-- Check if the trigger exists first
				if data then
					for k,v in pairs(data) do
						if v.Trigger == "JobPositionFKDelete" then
							return
						end
					end
				end

				MySQLite.query("SHOW PRIVILEGES", function(data)
					if not data then return end

					local found;
					for k,v in pairs(data) do
						if v.Privilege == "Trigger" then
							found = true
							break;
						end
					end

					if not found then return end
					MySQLite.query([[
						CREATE TRIGGER JobPositionFKDelete
							AFTER DELETE ON ]]..DB.Prefix..[[_position
							FOR EACH ROW
								IF OLD.type = "T" THEN
									DELETE FROM ]]..DB.Prefix..[[_jobspawn WHERE ]]..DB.Prefix..[[_jobspawn.id = OLD.id;
								ELSEIF OLD.type = "C" THEN
									DELETE FROM ]]..DB.Prefix..[[_console WHERE ]]..DB.Prefix..[[_console.id = OLD.id;
								END IF
						;
					]])
				end)
			end)
		else -- SQLite triggers, quite a different syntax
			MySQLite.query([[
				CREATE TRIGGER IF NOT EXISTS JobPositionFKDelete
					AFTER DELETE ON ]]..DB.Prefix..[[_position
					FOR EACH ROW
					WHEN OLD.type = "T"
					BEGIN
						DELETE FROM ]]..DB.Prefix..[[_jobspawn WHERE ]]..DB.Prefix..[[_jobspawn.id = OLD.id;
					END;
			]])
		end
		
		--Also create custom tables
		for k, v in ipairs(CustomTables) do
			local query = "CREATE TABLE IF NOT EXISTS "..DB.Prefix.."_"..v["table_name"].."("
			for a, b in pairs(v["table_columns"]) do
				query = query..b["name"].." "..b["data_type"]
				if b["allow_null"] == nil or (b["allow_null"] ~= nil and b["allow_null"] == false) then
					query = query.." NOT NULL"
				end
				if (b["is_pk"] ~= nil and b["is_pk"] == true) then
					query = query.." PRIMARY KEY"
				end
				--If we're on the last column, finish the query, otherwise add a comma and space.
				if a == #v["table_columns"] then query = query..");"
					else query = query..", "
				end
			end
			MySQLite.query(query)
		end
		
	MySQLite.commit(function() -- Initialize the data after all the tables have been created

		-- Update older version of database to the current database
		-- Only run when one of the older tables exist
		local updateQuery = [[SELECT name FROM sqlite_master WHERE type="table" AND name="]]..DB.Prefix..[[_cvars";]]
		if MySQLite.CONNECTED_TO_MYSQL then
			updateQuery = [[show tables like "]]..DB.Prefix..[[_cvars";]]
		end

		MySQLite.queryValue(updateQuery, function(data)
			if data == DB.Prefix.."_cvars" then
				print("UPGRADING DATABASE!")
				updateDatabase()
			end
		end)

		setUpNonOwnableDoors()
		setUpTeamOwnableDoors()
		setUpGroupDoors()

		MySQLite.query("SELECT * FROM "..DB.Prefix.."_cvar;", function(settings)
			for k,v in pairs(settings or {}) do
				RunConsoleCommand(v.var, v.value)
			end
		end)

		jailPos = jailPos or {}
		MySQLite.query([[SELECT * FROM ]]..DB.Prefix..[[_position WHERE type = 'J' AND map = ]] .. map .. [[;]], function(data)
			for k,v in pairs(data or {}) do
				table.insert(jailPos, v)
			end

			if table.Count(jailPos) == 0 then
				createJailPos()
				return
			end

			jail_positions = nil
		end)

		MySQLite.query("SELECT * FROM "..DB.Prefix.."_position NATURAL JOIN "..DB.Prefix.."_jobspawn WHERE map = "..map..";", function(data)
			if not data or table.Count(data) == 0 then
				createSpawnPos()
				return
			end

			team_spawn_positions = nil

			teamSpawns = data
		end)

		if MySQLite.CONNECTED_TO_MYSQL then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined,
									--so he walks around with the settings from the SQLite database
			for k,v in pairs(player.GetAll()) do
				local UniqueID = sql.SQLStr(v:UniqueID())
				MySQLite.query([[SELECT * FROM ]]..DB.Prefix..[[_player WHERE uid = ]].. UniqueID ..[[;]], function(data)
					if not data or not data[1] then return end

					local Data = data[1]
					v:SetDarkRPVar("rpname", Data.rpname)
					v:SetSelfDarkRPVar("salary", Data.salary)
					v:SetDarkRPVar("money", Data.wallet)
				end)
			end
		end
	end)
	
	hook.Call("DarkRPDBInitialized")
end

/*---------------------------------------------------------------------------
Updating the older database to work with the current version
(copy as much as possible over)
---------------------------------------------------------------------------*/
local function updateDatabase()
	print("CONVERTING DATABASE")
	-- Start transaction.
	MySQLite.begin()

	-- CVars
	MySQLite.query([[DELETE FROM ]]..DB.Prefix..[[_cvar;]])
	MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_cvar SELECT v.var, v.value FROM ]]..DB.Prefix..[[_cvars v;]])
	MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_cvars;]])

	-- Positions
	MySQLite.query([[DELETE FROM ]]..DB.Prefix..[[_position;]])

	-- Team spawns
	MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_position SELECT NULL, p.map, "T", p.x, p.y, p.z FROM ]]..DB.Prefix..[[_tspawns p;]])
	MySQLite.query([[
		INSERT INTO ]]..DB.Prefix..[[_jobspawn
			SELECT new.id, old.team FROM ]]..DB.Prefix..[[_position new JOIN ]]..DB.Prefix..[[_tspawns old ON
				new.map = old.map AND new.x = old.x AND new.y = old.y AND new.z = old.Z
			WHERE new.type = "T";
	]])
	MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_tspawns;]])

	-- Jail positions
	MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_position SELECT NULL, p.map, "J", p.x, p.y, p.z FROM ]]..DB.Prefix..[[_jailpositions p;]])
	MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_jailpositions;]])

	-- Doors
	MySQLite.query([[DELETE FROM ]]..DB.Prefix..[[_door;]])
	MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_door SELECT old.idx - ]] .. game.MaxPlayers() .. [[, old.map, old.title, old.locked, old.disabled FROM ]]..DB.Prefix..[[_doors old;]])

	MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_doors;]])
	MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_teamdoors;]])
	MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_groupdoors;]])

	MySQLite.commit()


	local count = MySQLite.queryValue("SELECT COUNT(*) FROM "..DB.Prefix.."_wallets;") or 0
	for i = 0, count, 1000 do -- SQLite selecting limit
		MySQLite.query([[SELECT ]]..DB.Prefix..[[_wallets.steam, amount, salary, name FROM ]]..DB.Prefix..[[_wallets
			LEFT OUTER JOIN ]]..DB.Prefix..[[_salaries ON ]]..DB.Prefix..[[_salaries.steam = ]]..DB.Prefix..[[_wallets.steam
			LEFT OUTER JOIN ]]..DB.Prefix..[[_rpnames ON ]]..DB.Prefix..[[_rpnames.steam = ]]..DB.Prefix..[[_wallets.steam LIMIT 1000 OFFSET ]]..i..[[;]], function(data)

			-- Separate transaction for the player data
			MySQLite.begin()

			for k,v in pairs(data or {}) do
				local uniqueID = util.CRC("gm_" .. v.steam .. "_gm")

				MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_player VALUES(]]
					..uniqueID..[[,]]
					..((v.name == "NULL" or not v.name) and "NULL" or MySQLite.SQLStr(v.name))..[[,]]
					..((v.salary == "NULL" or not v.salary) and GAMEMODE.Config.normalsalary or v.salary)..[[,]]
					..v.amount..[[);]])
			end

			if count - i < 1000 then -- the last iteration
				MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_wallets;]])
				MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_salaries;]])
				MySQLite.query([[DROP TABLE ]]..DB.Prefix..[[_rpnames;]])
			end

			MySQLite.commit()
		end)
	end
end

/*---------------------------------------------------------
 positions
 ---------------------------------------------------------*/
function createSpawnPos()
	local map = string.lower(game.GetMap())
	if not team_spawn_positions then return end

	for k, v in pairs(team_spawn_positions) do
		if v[1] == map then
			table.insert(teamSpawns, {id = k, map = v[1], x = v[3], y = v[4], z = v[5], team = v[2]})
		end
	end
	team_spawn_positions = nil -- We're done with this now.
end

function createJailPos()
	if not jail_positions then return end
	local map = string.lower(game.GetMap())

	MySQLite.begin()
		MySQLite.query([[DELETE FROM ]]..DB.Prefix..[[_position WHERE type = "J" AND map = ]].. MySQLite.SQLStr(map)..[[;]])
		for k, v in pairs(jail_positions) do
			if map == string.lower(v[1]) then
				MySQLite.query("INSERT INTO "..DB.Prefix.."_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
				table.insert(jailPos, {map = map, x = v[2], y = v[3], z = v[4]})
			end
		end
	MySQLite.commit()
end

local JailIndex = 1 -- Used to circulate through the jailpos table
function DB.StoreJailPos(ply, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(ply:GetPos()))
	MySQLite.queryValue("SELECT COUNT(*) FROM "..DB.Prefix.."_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function(already)
		if not already or already == 0 then
			MySQLite.query("INSERT INTO "..DB.Prefix.."_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")
			GAMEMODE:Notify(ply, 0, 4,  LANGUAGE.created_first_jailpos)

			return
		end

		if addingPos then
			MySQLite.query("INSERT INTO "..DB.Prefix.."_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")

			table.insert(jailPos, {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"})
			GAMEMODE:Notify(ply, 0, 4,  LANGUAGE.added_jailpos)
		else
			MySQLite.query("DELETE FROM "..DB.Prefix.."_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function()
				MySQLite.query("INSERT INTO "..DB.Prefix.."_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")


				jailPos = {[1] = {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"}}
				GAMEMODE:Notify(ply, 0, 5,  LANGUAGE.reset_add_jailpos)
			end)
		end
	end)

	JailIndex = 1
end

function DB.RetrieveJailPos()
	local map = string.lower(game.GetMap())
	if not jailPos then return Vector(0,0,0) end

	-- Retrieve the least recently used jail position
	local oldestPos = jailPos[JailIndex]
	JailIndex = JailIndex % #jailPos + 1

	return oldestPos and Vector(oldestPos.x, oldestPos.y, oldestPos.z)
end

function DB.SaveSetting(setting, value)
	MySQLite.query("REPLACE INTO "..DB.Prefix.."_cvars VALUES("..MySQLite.SQLStr(setting)..", "..MySQLite.SQLStr(value)..");")
end

function DB.CountJailPos()
	return table.Count(jailPos or {})
end

function DB.StoreTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[DELETE FROM ]]..DB.Prefix..[[_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND id IN (SELECT id FROM ]]..DB.Prefix..[[_jobspawn WHERE team = ]] .. t .. [[)]])

	MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_position VALUES(NULL, ]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM ]]..DB.Prefix..[[_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if not id then return end
			MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)

	print(DarkRP.getPhrase("created_spawnpos", team.GetName(t)))
end

function DB.AddTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_position VALUES(NULL, ]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM ]]..DB.Prefix..[[_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if type(id) == "boolean" then return end
			MySQLite.query([[INSERT INTO ]]..DB.Prefix..[[_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)
end

function DB.RemoveTeamSpawnPos(t, callback)
	local map = string.lower(game.GetMap())
	MySQLite.query([[SELECT ]]..DB.Prefix..[[_position.id FROM ]]..DB.Prefix..[[_position
		NATURAL JOIN ]]..DB.Prefix..[[_jobspawn
		WHERE map = ]] .. MySQLite.SQLStr(map) .. [[
		AND team = ]].. t ..[[;]], function(data)

		MySQLite.begin()
		for k,v in pairs(data or {}) do
			-- The trigger will make sure the values get deleted from the jobspawn as well
			MySQLite.query([[DELETE FROM ]]..DB.Prefix..[[_position WHERE id = ]]..v.id..[[;]])
		end
		MySQLite.commit()
	end)

	for k,v in pairs(teamSpawns) do
		if tonumber(v.team) == t then
			teamSpawns[k] = nil
		end
	end

	if callback then callback() end
end

function DB.RetrieveTeamSpawnPos(ply)
	local map = string.lower(game.GetMap())
	local t = ply:Team()

	local returnal = {}

	if teamSpawns then
		for k,v in pairs(teamSpawns) do
			if v.map == map and tonumber(v.team) == t then
				table.insert(returnal, Vector(v.x, v.y, v.z))
			end
		end
		return (table.Count(returnal) > 0 and returnal) or nil
	end
end

/*---------------------------------------------------------
Players 
 ---------------------------------------------------------*/
function DB.StoreRPName(ply, name)
	if not name or string.len(name) < 2 then return end
	ply:SetDarkRPVar("rpname", name)

	MySQLite.query([[UPDATE ]]..DB.Prefix..[[_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. ply:UniqueID() .. ";")
end

function DB.RetrieveRPNames(ply, name, callback)
	MySQLite.query("SELECT COUNT(*) AS count FROM "..DB.Prefix.."_player WHERE rpname = "..MySQLite.SQLStr(name)..";", function(r)
		callback(tonumber(r[1].count) > 0)
	end)
end

function DB.RetrievePlayerData(ply, callback, failed, attempts)
	attempts = attempts or 0

	if attempts > 3 then return failed() end

	MySQLite.query("SELECT rpname, wallet, salary FROM "..DB.Prefix.."_player WHERE uid = " .. ply:UniqueID() .. ";", callback, function()
		DB.RetrievePlayerData(ply, callback, failed, attempts + 1)
	end)
end

function DB.CreatePlayerData(ply, name, wallet, salary)
	MySQLite.query(string.format([[REPLACE INTO playerinformation VALUES(%s, %s);]], MySQLite.SQLStr(ply:UniqueID()), MySQLite.SQLStr(ply:SteamID())))
	MySQLite.query([[REPLACE INTO ]]..DB.Prefix..[[_player VALUES(]] ..
			ply:UniqueID() .. [[, ]] ..
			MySQLite.SQLStr(name)  .. [[, ]] ..
			salary  .. [[, ]] ..
			wallet .. ");")
end

function DB.StoreMoney(ply, amount)
	if not IsValid(ply) then return end
	if amount < 0  then return end

	MySQLite.query([[UPDATE ]]..DB.Prefix..[[_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())
end

function DB.ResetAllMoney(ply,cmd,args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
	MySQLite.query("UPDATE "..DB.Prefix.."_player SET wallet = "..GAMEMODE.Config.startingmoney.." ;")
	for k,v in pairs(player.GetAll()) do
		v:SetDarkRPVar("money", GAMEMODE.Config.startingmoney)
	end
	if ply:IsPlayer() then
		GAMEMODE:NotifyAll(0,4, DarkRP.getPhrase("reset_money", ply:Nick()))
	else
		GAMEMODE:NotifyAll(0,4, DarkRP.getPhrase("reset_money", "Console"))
	end
end
concommand.Add("rp_resetallmoney", DB.ResetAllMoney)

function DB.PayPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:AddMoney(-amount)
	ply2:AddMoney(amount)
end

function DB.StoreSalary(ply, amount)
	ply:SetSelfDarkRPVar("salary", math.floor(amount))

	MySQLite.query([[UPDATE ]]..DB.Prefix..[[_player SET salary = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())

	return amount
end

function DB.RetrieveSalary(ply, callback)
	if not IsValid(ply) then return 0 end

	if ply:getDarkRPVar("salary") then return callback and callback(ply:getDarkRPVar("salary")) end -- First check the cache.

	MySQLite.queryValue("SELECT salary FROM "..DB.Prefix.."_player WHERE uid = " .. ply:UniqueID() .. ";", function(r)
		local normal = GAMEMODE.Config.normalsalary
		if not r then
			ply:SetSelfDarkRPVar("salary", normal)
			callback(normal)
		else
			callback(r)
		end
	end)
end

/*---------------------------------------------------------
 Doors
 ---------------------------------------------------------*/
function DB.StoreDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}
	local nonOwnable = ent.DoorData.NonOwnable

	MySQLite.query([[REPLACE INTO ]]..DB.Prefix..[[_door VALUES(]]..
		ent:DoorIndex() ..[[, ]] ..
		MySQLite.SQLStr(map) .. [[, ]] ..
		(ent.DoorData.title and MySQLite.SQLStr(ent.DoorData.title) or "NULL") .. [[, ]] ..
		"NULL" .. [[, ]] ..
		(ent.DoorData.NonOwnable and 1 or 0) .. [[);]])
end

function DB.StoreDoorTitle(ent, text)
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.title = text
	MySQLite.query("UPDATE "..DB.Prefix.."_door SET title = " .. MySQLite.SQLStr(text) .. " WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:DoorIndex() .. ";")
end

function setUpNonOwnableDoors()
	MySQLite.query("SELECT idx, title, isLocked, isDisabled FROM "..DB.Prefix.."_door WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))
			if IsValid(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.NonOwnable = tobool(row.isDisabled)
				if r.isLocked ~= nil then
					e:Fire((tobool(row.locked) and "" or "un").."lock", "", 0)
				end
				e.DoorData.title = row.title ~= "NULL" and row.title or nil
			end
		end
	end)
end

function DB.StoreTeamDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}

	MySQLite.query("DELETE FROM "..DB.Prefix.."_jobown WHERE idx = " .. ent:DoorIndex() .. " AND map = " .. MySQLite.SQLStr(map) .. ";")
	for k,v in pairs(string.Explode("\n", ent.DoorData.TeamOwn or "")) do
		if v == "" then continue end

		MySQLite.query("INSERT INTO "..DB.Prefix.."_jobown VALUES("..ent:DoorIndex() .. ", "..MySQLite.SQLStr(map) .. ", " .. v .. ");")
	end
end

function setUpTeamOwnableDoors()
	MySQLite.query("SELECT idx, job FROM "..DB.Prefix.."_jobown WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))
			if IsValid(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.TeamOwn = e.DoorData.TeamOwn or ""
				e.DoorData.TeamOwn = (e.DoorData.TeamOwn == "" and row.job) or (e.DoorData.TeamOwn .. "\n" .. row.job)
			end
		end
	end)
end

function DB.SetDoorGroup(ent, group)
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	local index = ent:DoorIndex()

	if group == "" then
		MySQLite.query("DELETE FROM "..DB.Prefix.."_doorgroups WHERE map = " .. map .. " AND idx = " .. index .. ";")
		return
	end

	MySQLite.query("REPLACE INTO "..DB.Prefix.."_doorgroups VALUES(" .. index .. ", " .. map .. ", " .. SQLStr(group) .. ");");
end

function setUpGroupDoors()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.query("SELECT idx, doorgroup FROM "..DB.Prefix.."_doorgroups WHERE map = " .. map, function(data)
		if not data then return end

		for _, row in pairs(data) do
			local ent = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))

			if not IsValid(ent) then
				continue
			end

			ent.DoorData = ent.DoorData or {}
			ent.DoorData.GroupOwn = row.doorgroup
		end
	end)
end

/*---------------------------------------------------------
 Logging
 ---------------------------------------------------------*/
function DB.Log(text, force)
	GAMEMODE:WriteOut(text, Severity.Info) --Might consider reducing to debug
	if (not GAMEMODE.Config.logging or not text) and not force then return end
	if not DB.File then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("DarkRP_logs", "DATA") then
			file.CreateDir("DarkRP_logs", "DATA")
		end
		DB.File = "DarkRP_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(DB.File, os.date().. "\t".. text)
		return
	end
	file.Write(DB.File, (file.Read(DB.File) or "").."\n"..os.date().. "\t"..(text or ""))
end