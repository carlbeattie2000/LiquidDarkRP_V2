TOOL.Category = "Construction"
TOOL.Name = "Liquid DarkRP Manager"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Modes = { "Rock" }

TOOL.ClientConVar[ "mode" ] = TOOL.Modes[ 1 ]
TOOL.ClientConVar[ "model" ] = LDRP_SH.Rocks[ "Stone" ].mdl

if CLIENT then
	language.Add( "Tool.npcmanager.name", TOOL.Name )
	language.Add( "Tool.npcmanager.desc", "Assists administrators in setting up their LDRP server." )
	language.Add( "Tool.npcmanager.0", "Left click to spawn the selected entity, right click to remove one." )
end

function TOOL:LeftClick( trace )
	if ( CLIENT ) then return true end
	
	local mode = self:GetClientInfo( "mode" )
	local model = self:GetClientInfo( "model" )
end
 
function TOOL:RightClick( trace )
end