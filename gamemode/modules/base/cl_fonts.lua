--[[-------------------------------------------------
	Fonts that need to be used throughout the game.
---------------------------------------------------]]

surface.CreateFont("AckBarWriting", {
	font = "akbar",
	size = 20,
	weight = 500,
	antialias = true,
	additive = false
})
surface.CreateFont( "GModToolSubtitle", {
	font		= "Tahoma",
	size		= 24,
	weight		= 1000
})
surface.CreateFont("HUDNumber", {
	font = "Trebuchet MS",
    size = 40,
    weight = 900
})
surface.CreateFont("HUDNumber3", {
	font = "Trebuchet MS",
	size = 43,
	weight = 900
})
surface.CreateFont("HUDNumber5", {
	font = "Trebuchet MS",
	size = 45,
	weight = 900
})
surface.CreateFont("ScoreboardHeader", {
	size = 32,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardSubtitle", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerName", {
	size = 19,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerNameBig", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardText", {
	size = 16,
	weight = 1000,
	antialias = true,
	shadow = false,
	font = "Tahoma"})
surface.CreateFont("Trebuchet20", {
	size = 20,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet22", {
    font = "Trebuchet MS",
    size = 22,
    weight = 900
})
surface.CreateFont("Trebuchet24", {
    font = "Trebuchet MS",
    size = 24,
    weight = 900
})
surface.CreateFont("TabLarge", {
	size = 17,
	weight = 700,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("UiBold", {
	size = 16,
	weight = 800,
	antialias = true,
	shadow = false,
	font = "Default"})
surface.CreateFont ("DarkRPHUD2", {
	size = 23,
	weight = 400,
	antialias = true,
	shadow = false,
	font = "coolvetica"})

-- This is the font that's used to draw the death icons
surface.CreateFont("CSKillIcons", {
	size = ScreenScale(30),
	weight = 500,
	font = "csd"})
surface.CreateFont("CSSelectIcons", {
	size = ScreenScale(60),
	weight = 500,
	font = "csd"})
surface.CreateFont("Firemode", {
	font = "HalfLife2",
	size = ScrW() / 60, 
	additive = true})
