# CE-extCommands

### Basic Cobalt Essentials extension-based commands for BeamMP

## Installation:

#### 1. Place extCommands.lua in
`.../Resources/Server/CobaltEssentials/extensions/`

#### 2. Add an entry to turn it on in:
`.../Resources/Server/CobaltEssentials/LoadExtensions.cfg`

```cfg
# Add your new extensions here as a key/value pair
# The first one is the name in the lua enviroment
# The second value is the file path to the main lua from CobaltEssentials/extensions

exampleExtension = "exampleExtension"
extCommands = "extCommands"
```

---
## Configuration:
- Now includes tracking kickCount and autobans respective of the configurable banThresh
```
local banThresh = 3
```


---
## Usage:

This extension's commands and aliases are:

`/clear` or `/c`

`/nuke` or `/n`

`/pop` or `/p`

`/popall` or `/pa`

`/k`

`/ks`

* Any player may use `/clear` or `/c`. This will remove all of the command-user's vehicles.

* Admins may use `/nuke` or `/n` to instantly remove all vehicles on the server.

* Admins may use `/pop` or `/p` to remove a specific vehicleID by playerID, `/pop 0 0`

* Admins may use `/popall` or `/pa` to remove all of a specific player's vehicles by playerID, `/popall 0`

* Admins may use `/k` to kick players and increment a kickCount, `/k <name> <optional reason>`
  * this does NOT replace `/kick`

* Any player may use `/ks` to check the number times a player has been kicked, `/ks <name>`

