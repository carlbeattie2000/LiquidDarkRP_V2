DarkRP.PLAYER.DoTutorial = DarkRP.stub{
	name = "DoTutorial",
	description = "Start or end the tutorial sequence for this player.",
	parameters = {
		{
			name = "Type",
			description = "The command to be issued, either 'start' or 'done'.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}