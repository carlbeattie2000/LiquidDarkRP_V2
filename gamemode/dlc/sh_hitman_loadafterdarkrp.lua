LDRP_SH_Hitman = {}

LDRP_SH_Hitman.HitPrice = 5000 -- Price of hits
LDRP_SH_Hitman.Max = 3 -- Max hitmen
LDRP_SH_Hitman.Salary = 50 -- Hitman's salary
LDRP_SH_Hitman.MultiHits = false -- Allow multiple hits to be placed on one player?

TEAM_HITMAN = AddExtraTeam("Hitman", {
	color = Color(227,141,141),
	model = "models/player/arctic.mdl",
	description = [[The hitman carries out hits requested by players for
		large sums of cash.
		The system is automatic and you will gain your cash immediatly.
		Type /hit as a hitman to see currently placed hits.
		Players in the server can type "/hit player" to place a hit.]],
	weapons = {},
	command = "hitman",
	max = LDRP_SH_Hitman.Max,
	salary = LDRP_SH_Hitman.Salary,
	admin = 0,
	vote = false,
	hasLicense = false
})
