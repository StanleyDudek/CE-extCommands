local M = {}
M.COBALT_VERSION = "1.6.0"

utils.setLogType("extCommands",34)

local banThresh = 3

--called whenever the extension is loaded
function onInit()
	
end


--called whenever the player is authenticated by the server.
local function onPlayerAuth(player)
	kickCount = CobaltDB.query("playersDB/" .. player.name, "kickCount", "count")
	if kickCount == nil then
		kickCount = 0
		CobaltDB.set("playersDB/" .. player.name, "kickCount", "count", kickCount)
	elseif kickCount >= banThresh then
		SendChatMessage(-1, "Banned player " .. player.name .. " tried to join")
	end
end


--function to apply commands
local function applyCommands(targetDatabase, tables)
	local appliedTables = {}
	for tableName, table in pairs(tables) do
		--check to see if the database already recognizes this table.
		if targetDatabase[tableName]:exists() == false then
			--write the key/value table into the database
			for key, value in pairs(table) do
				targetDatabase[tableName][key] = value
			end
			appliedTables[tableName] = tableName
		end
	end
	return appliedTables
end

--info re: new commands for applyCommands to apply
local extCommands = 
{
	--orginModule[commandName] is where the command is executed from
	-- Source-Limit-Map [0:no limit | 1:Chat Only | 2:RCON Only]
	clear =			{orginModule = "extCommands",	level = 1,	arguments = 0,					sourceLimited = 0,	description = "Deletes all of your vehicles"},
	c =				{orginModule = "extCommands",	level = 1,	arguments = 0,					sourceLimited = 0,	description = "Deletes all of your vehicles"},
	nuke =			{orginModule = "extCommands",	level = 10,	arguments = 0,					sourceLimited = 0,	description = "Deletes all vehicles on the server"},
	n =				{orginModule = "extCommands",	level = 10,	arguments = 0,					sourceLimited = 0,	description = "Deletes all vehicles on the server"},
	pop =			{orginModule = "extCommands",	level = 10,	arguments = {"target","vehID"},	sourceLimited = 0,	description = "Deletes a specific targeted vehicle of a player"},
	p =				{orginModule = "extCommands",	level = 10,	arguments = {"target","vehID"},	sourceLimited = 0,	description = "Deletes a specific targeted vehicle of a player"},
	popall =		{orginModule = "extCommands",	level = 10,	arguments = {"target"},			sourceLimited = 0,	description = "Deletes all of a target player's vehicles"},
	pa =			{orginModule = "extCommands",	level = 10,	arguments = {"target"},			sourceLimited = 0,	description = "Deletes all of a target player's vehicles"},
	k =				{orginModule = "extCommands",	level = 10,	arguments = {"name", "*reason"},			sourceLimited = 0,	description = "Kick a player and increment kickCount"},
	ks =			{orginModule = "extCommands",	level = 1,	arguments = {"name"},			sourceLimited = 0,	description = "return player's kickCount"},

}

--apply them
applyCommands(commands, extCommands)

local function newKick(sender, name, reason, ...)
	reason = reason or "You've been kicked from the server!"
	local player = players.getPlayerByName(name)
	CobaltDB.openDatabase("playersDB/" .. name)
	kickCount = CobaltDB.query("playersDB/" .. name, "kickCount", "count")
	if kickCount == nil or kickCount == 0 then
		kickCount = 1
		CobaltDB.set("playersDB/" .. name, "kickCount", "count", kickCount)
	else
		kickCount = kickCount + 1
		print(kickCount)
		if kickCount == banThresh then
			reason = kickCount .. " strikes, you're out!"
			CobaltDB.openDatabase("playerPermissions")
			CobaltDB.set("playerPermissions", name, "banned", 1)
			CobaltDB.set("playerPermissions", name, "banReason", kickCount .. " strikes, you're out!")
			CobaltDB.set("playersDB/" .. name, "kickCount", "count", kickCount)
			if player then		
				player:kick(reason)
				return "Kicked " .. name .. " for: " .. reason .. ", kickCount: " .. kickCount
			end
			return "Banned " .. name .. " for: " .. reason .. ", kickCount: " .. kickCount
		else
			if kickCount > banThresh then
				return "Player has already been kicked " .. kickCount .. " times and banned"
			else
				CobaltDB.set("playersDB/" .. name, "kickCount", "count", kickCount)
			end
		end
	
	end	
	if player then		
		player:kick(reason)
		return "Kicked " .. name .. " for: " .. reason .. ", kickCount: " .. kickCount
	end
end

local function kicks(sender, name, ...)
	CobaltDB.openDatabase("playersDB/" .. name)
	kickCount = CobaltDB.query("playersDB/" .. name, "kickCount", "count")
	if kickCount == nil then
		kickCount = 0
	end
	return name .. "'s kickCount is: " .. kickCount
end

--removes the command-user's vehicles
local function clear(player, ...)
	if player.playerID ~= nil then
		if player.vehicles ~= nil then
			vehCount = -1
			for k,v in pairs(player.vehicles) do
				vehCount = vehCount + 1
			end
			if vehCount == -1 then
				CElog("Nothing to clear!", "extCommands")
				return "Nothing to clear!"
			else 
				for vehID = 0, vehCount do
					RemoveVehicle(player.playerID,vehID)
				end
				CElog(player.name .. " cleared their vehicles", "extCommands")
				return "You have cleared your vehicles"
			end
		else

		end
	else
		CElog("Nothing to clear!", "extCommands")
		return "Nothing to clear, are you RCON?"
	end
end

--removes a specific vehicle of the target
local function pop(player, target, vehID, ...)

	if target ~= nil then
		vehCount = -1
		for k,v in pairs(players[tonumber(target)].vehicles) do
			vehCount = vehCount + 1
		end
		if vehCount == -1 then
			CElog("Target has no vehicles", "extCommands")
			return "Target has no vehicles"
		else
			RemoveVehicle(target,vehID)
			SendChatMessage(target, "Your vehicle has been removed")
			return "player's vehicle has been popped"
		end
	else
		CElog("invalid ID", "extCommands")
		return "Player not present, check playerID"	
	end
	
end

--removes all the vehicles of the target
local function popall(player, target, ...)
	if target ~= nil then
		vehCount = -1
		for k,v in pairs(players[tonumber(target)].vehicles) do
			vehCount = vehCount + 1
		end
		if vehCount == -1 then
			CElog("Target has no vehicles", "extCommands")
			return "Target has no vehicles"
		else
			for vehID = -0, vehCount do
				RemoveVehicle(target,vehID)
				SendChatMessage(target, "Your vehicle has been removed")
			end
			return "You popped 'em all"
		end
	else
		CElog("invalid ID", "extCommands")
		return "Player not present, check playerID"
	end
end

--removes all vehicles on server
local function nuke(player, ...)
	vehCount = -1
	playerCount = -1
	for playerID, player in ipairs(players), players, -1 do
		playerCount = playerCount + 1
		for k,v in pairs(player.vehicles) do
			vehCount = vehCount + 1
		end
		for vehID = 0, vehCount do
			RemoveVehicle(playerCount,vehID)
		end
	end
	SendChatMessage(-1, "Everyone's vehicles have been removed")
	CElog("Server has been nuked", "extCommands")
	return "Server has been nuked"
end

M.onInit = onInit

M.onPlayerAuth = onPlayerAuth

M.clear = clear
M.nuke = nuke
M.popall = popall
M.pop = pop

M.c = clear
M.n = nuke
M.pa = popall
M.p = pop

M.k = newKick
M.ks = kicks

M.onInit()

return M
