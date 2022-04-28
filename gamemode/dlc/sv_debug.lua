local function DumpPISHooks()
	local hooks = hook.GetTable()
	local theHook = hooks[ "PlayerInitialSpawn" ]
	
	if theHook then
		print("Hooks for PlayerInitialSpawn:")
		for k, _ in pairs( theHook ) do
			print("\t"..k)
		end
	end
end
concommand.Add( "ldrp_dbgpishook", DumpPISHooks )