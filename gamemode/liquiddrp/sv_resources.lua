local function AddDir(dir) --recursively adds everything in a directory to be downloaded by client
	local files, folders = file.Find(dir.."/*", "GAME")

	for _, fdir in pairs(folders) do
		if fdir != ".svn" then // don't spam people with useless .svn folders
			AddDir(dir.."/"..fdir)
		end
	end

	for k,v in pairs(files) do
		resource.AddFile(dir.."/"..v)
	end
end

resource.AddFile( "materials/FAG/weedplantuvmap.vmt" )

resource.AddSingleFile( "materials/skybox/sky33bk.vmt" )
resource.AddSingleFile( "materials/skybox/sky33bk.vtf" )
resource.AddSingleFile( "materials/skybox/sky33dn.vmt" )
resource.AddSingleFile( "materials/skybox/sky33dn.vtf" )
resource.AddSingleFile( "materials/skybox/sky33ft.vmt" )
resource.AddSingleFile( "materials/skybox/sky33ft.vtf" )
resource.AddSingleFile( "materials/skybox/sky33lf.vmt" )
resource.AddSingleFile( "materials/skybox/sky33lf.vtf" )
resource.AddSingleFile( "materials/skybox/sky33rt.vmt" )
resource.AddSingleFile( "materials/skybox/sky33rt.vtf" )
resource.AddSingleFile( "materials/skybox/sky33up.vmt" )
resource.AddSingleFile( "materials/skybox/sky33up.vtf" )
resource.AddSingleFile( "models/FAG/delicious_penis.dx80.vtx" )
resource.AddSingleFile( "models/FAG/delicious_penis.dx90.vtx" )
resource.AddSingleFile( "models/FAG/delicious_penis.mdl" )
resource.AddSingleFile( "models/FAG/delicious_penis.sw.vtx" )
resource.AddSingleFile( "models/FAG/delicious_penis.vvd" )
resource.AddSingleFile( "models/nater/weedplant_pot_dirt.dx80.vtx" )
resource.AddSingleFile( "models/nater/weedplant_pot_dirt.dx90.vtx" )
resource.AddSingleFile( "models/nater/weedplant_pot_dirt.mdl" )
resource.AddSingleFile( "models/nater/weedplant_pot_dirt.phy" )
resource.AddSingleFile( "models/nater/weedplant_pot_dirt.sw.vtx" )
resource.AddSingleFile( "models/nater/weedplant_pot_dirt.vvd" )
resource.AddSingleFile( "materials/gui/silkicons/money.vmt" )
resource.AddSingleFile( "materials/gui/silkicons/money.vtf" )
resource.AddSingleFile( "materials/gui/silkicons/ruby.vmt" )
resource.AddSingleFile( "materials/gui/silkicons/ruby.vtf" )

resource.AddFile( "materials/katharsmodels/contraband/contraband_normal.vtf" )
resource.AddFile( "materials/katharsmodels/contraband/contraband_one.vmt" )
resource.AddFile( "materials/katharsmodels/contraband/contraband_see.vmt" )
resource.AddFile( "materials/katharsmodels/contraband/contraband_two.vmt" )
resource.AddFile( "models/katharsmodels/contraband/zak_wiet/zak_seed.mdl" )

resource.AddSingleFile( "models/katharsmodels/contraband/zak_wiet/zak_wiet.dx80.vtx" )
resource.AddSingleFile( "models/katharsmodels/contraband/zak_wiet/zak_wiet.dx90.vtx" )
resource.AddSingleFile( "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl" )
resource.AddSingleFile( "models/katharsmodels/contraband/zak_wiet/zak_wiet.phy" )
resource.AddSingleFile( "models/katharsmodels/contraband/zak_wiet/zak_wiet.sw.vtx" )
resource.AddSingleFile( "models/katharsmodels/contraband/zak_wiet/zak_wiet.vvd" )

resource.AddFile( "materials/models/nater/weedplant_dirt.vmt" )
resource.AddFile( "materials/models/nater/weedplant_dirt_bump.vmt" )
resource.AddFile( "materials/models/nater/weedplant_texture.vmt" )
resource.AddFile( "materials/models/nater/weedplant_texture_bump.vmt" )

resource.AddFile( "models/nukeftw/faggotbox.mdl" )
resource.AddFile( "materials/models/nukeftw/fagbox.vmt" )

resource.AddFile( "models/nukeftw/faggotplant.mdl" )
resource.AddFile( "materials/models/nukeftw/fagplant.vmt" )

resource.AddFile( "models/props/carrot.mdl" )
resource.AddFile( "materials/models/props/carrot.vmt" )

resource.AddFile( "materials/models/weapons/pickaxe/stone/pickaxe01.vmt" )
resource.AddFile( "materials/models/weapons/pickaxe/stone/stone.vtf" )
resource.AddFile( "materials/models/weapons/pickaxe/stone/stone_n.vtf" )
resource.AddFile( "models/weapons/w_stone_pickaxe.mdl" )
resource.AddFile( "models/weapons/v_stone_pickaxe.mdl" )


resource.AddSingleFile( "materials/models/weapons/pickaxe/sledge.vtf" )
resource.AddSingleFile( "materials/models/weapons/pickaxe/sledge.vmf" )
resource.AddFile( "models/weapons/v_sledgehammer/v_sledgehammer.mdl" )
resource.AddFile( "models/weapons/w_sledgehammer.mdl" )

resource.AddSingleFile( "sound/LiquidDRP/eating.wav" )

resource.AddFile( "models/props_swamp/shroom_ref_01.mdl" )
resource.AddFile( "models/props_swamp/shroom_ref_01_cluster.mdl")
resource.AddFile( "materials/props_swamp/shroom_diffuse.vtf")

--Missing CSS Real textures
resource.AddFile( "materials/scope/scope_normal.vmt" )

--FAdmin resources
AddDir("materials/fadmin")