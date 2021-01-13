local M = {}
M.COBALT_VERSION = "1.5.3A"

--called whenever the extension is loaded
function onInit()
	
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
	clear =			{orginModule = "extCommands",	level = 1,	arguments = 0,	sourceLimited = 0,	description = "Deletes all of your vehicles"},
	c =				{orginModule = "extCommands",	level = 1,	arguments = 0,	sourceLimited = 0,	description = "Deletes all of your vehicles"},
	nuke =			{orginModule = "extCommands",	level = 10,	arguments = 0,	sourceLimited = 0,	description = "Deletes all vehicles on the server"},
	n =				{orginModule = "extCommands",	level = 10,	arguments = 0,	sourceLimited = 0,	description = "Deletes all vehicles on the server"},
	pop =			{orginModule = "extCommands",	level = 10,	arguments = {"target","vehID"},	sourceLimited = 0,	description = "Deletes a specific targeted vehicle of a player"},
	p =				{orginModule = "extCommands",	level = 10,	arguments = {"target","vehID"},	sourceLimited = 0,	description = "Deletes a specific targeted vehicle of a player"},
	popall =		{orginModule = "extCommands",	level = 10,	arguments = {"target"},	sourceLimited = 0,	description = "Deletes all of a target player's vehicles"},
	pa =			{orginModule = "extCommands",	level = 10,	arguments = {"target"},	sourceLimited = 0,	description = "Deletes all of a target player's vehicles"},

}

--apply them
applyCommands(commands, extCommands)

--removes the command-user's vehicles
local function clear(player, ...)
	if player.playerID ~= nil then
		vehCount = -1
		for k,v in pairs(player.vehicles) do
			vehCount = vehCount + 1
		end
		for vehID = 0, vehCount do
			RemoveVehicle(player.playerID,vehID)
		end
		CElog(player.name .. " cleared their vehicles")
		return "You have cleared your vehicles"
	else
		return "Nothing to clear, are you RCON?"
	end
end

--removes a specific vehicle of the target
local function pop(player, target, vehID, ...)

	if target ~= nil then
		if vehID ~= nil then
			RemoveVehicle(target,vehID)
			SendChatMessage(target, "Your vehicle has been removed")
			return "player's vehicle has been popped"
		else
			return "Vehicle not found, check vehID"
		end
	else
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
		for vehID = -0, vehCount do
			RemoveVehicle(target,vehID)
			SendChatMessage(target, "Your vehicle has been removed")
		end
		return "You popped 'em all"
	else
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
	--handle RCON nuke
	if player.name then
		CElog(player.name .. " nuked the server")
	else
		CElog(player.ID .. " nuked the server")
	end
	return "Server has been nuked"
end

M.onInit = onInit

M.clear = clear
M.nuke = nuke
M.popall = popall
M.pop = pop

M.c = clear
M.n = nuke
M.pa = popall
M.p = pop

M.onInit()

return M
