if UseFPP then return end
LDRP_Protector = {}
local LDRP = {}

LDRP.Options = {}

function LDRP.AddOpt(Name,Cmd,Type,Function)
	LDRP.Options[Name] = {}
	LDRP.Options[Name].cmd = Cmd
	LDRP.Options[Name].typ = Type
	LDRP.Options[Name].func = Function
	LDRP.Options[Name].choices = {}
end
LDRP.AddOpt("Use protection","useprotect","tick")
LDRP.AddOpt("No physgun","nophys","list")
LDRP.AddOpt("All physgun","allphys","list")
LDRP.AddOpt("Restrict models","model","list")
LDRP.AddOpt("Restrict tools","tool","list")

LDRP.OptVals = {}
function LDRP.GetOptVal(um)
	local cmd = um:ReadString()
	if cmd == "useprotect" then
		LDRP.OptVals[cmd] = um:ReadFloat()
	else
		LDRP.OptVals[cmd] = {}
		for i=1,um:ReadFloat() do
			local Val1,Val2 = um:ReadString(),um:ReadString()
			Val1 = (tonumber(Val1) or Val1)
			LDRP.OptVals[cmd][Val1] = Val2
		end
	end
end
usermessage.Hook("SendOptionValue",LDRP.GetOptVal)

function LDRP.AdminOpts()
	local B = {}
	B.OptCount = table.Count(LDRP.Options)
	
	B.BG = vgui.Create("DFrame")
	B.BG:SetSize(500,300)
	B.BG:Center()
	B.BG:MakePopup()
	B.BG:SetTitle("Protector - admin options")
	
	B.List = vgui.Create("DPanelList",B.BG)
	B.List:SetPos(4,24)
	B.List:SetSize(492,272)
	B.List:SetPadding(4)
	B.List:SetSpacing(4)
	B.List:EnableVerticalScrollbar(true)
	B.List.Paint = function() draw.RoundedBox(6,0,0,492,272,Color(0,0,0,180)) end
	
	for k,v in pairs(LDRP.Options) do
		local S = vgui.Create("DPanel")
		S:SetHeight(30)
		S.Paint = function(sa)
			draw.RoundedBox(6,0,0,sa:GetWide(),sa:GetTall(),Color(50,50,50,180))
			draw.SimpleTextOutlined(k,"Trebuchet24",6,15,Color(255,255,255,210),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 2, Color(0,0,0,150) )
		end
		RunConsoleCommand("_protector","getvar",v.cmd)
		
		timer.Simple(.1,function()
			
			if v.typ == "tick" then
				local Tick = vgui.Create("DCheckBox",S)
				Tick:SetSize(14,14)
				Tick:SetPos(S:GetWide()-20,15-(7))
				Tick.DoClick = function()
					RunConsoleCommand("_protector",v.cmd)
					Tick:SetValue((Tick:GetChecked() and 0) or 1)
					LDRP.OptVals[v.cmd] = nil
				end
				
				Tick:SetValue((LDRP.OptVals[v.cmd]) or 0)
			elseif v.typ == "list" then
				local Choice,ListSpacer = vgui.Create("DMultiChoice",S),(string.len(k)*13)
				Choice:SetPos(4+ListSpacer,4)
				Choice:SetSize(300-ListSpacer,22)
				
				local Since = {}
				local x,y = Choice:GetPos()
				local Add = vgui.Create("DButton",S)
				Add:SetPos(S:GetWide()-Add:GetWide()-4,S:GetTall()-Add:GetTall()-4)
				Add:SetWide(50)
				Add:SetText("Add")
				Add.DoClick = function()
					local Val = Choice:GetValue()
					if Val == "" then ply:ChatPrint("You need to enter an entity name!") return end
					Choice:SetText("")
					
					Choice:AddChoice(Val)
					table.insert(Since,Val)
					RunConsoleCommand("_protector",v.cmd,Val)
				end
				LDRP.OptVals[v.cmd] = LDRP.OptVals[v.cmd] or {}
				for cc,cb in pairs(LDRP.OptVals[v.cmd]) do
					Choice:AddChoice(cb)
				end
				
				local Rem = vgui.Create("DButton",S)
				Rem:SetWide(75)
				Rem:SetTall(Add:GetTall())
				Rem:SetPos(S:GetWide()-Add:GetWide()-23-Rem:GetWide(),S:GetTall()-Add:GetTall()-4)
				Rem:SetText("Remove")
				Rem.DoClick = function()
					local Val = Choice:GetValue()
					if Val == "" then ply:ChatPrint("You need to choose an entity!") return end
					Choice:SetText("")
					Choice:Clear()
					for ck,cv in pairs(LDRP.OptVals[v.cmd]) do
						if string.lower(cv) != string.lower(Val) then
							Choice:AddChoice(cv)
						else
							RunConsoleCommand("_protector",v.cmd,Val)
							table.remove(LDRP.OptVals[v.cmd],table.KeyFromValue(LDRP.OptVals[v.cmd],cv))
						end
					end
					for ck,cv in pairs(Since) do
						MsgN(cv)
						if string.lower(cv) != string.lower(Val) then
							Choice:AddChoice(cv)
						else
							RunConsoleCommand("_protector",v.cmd,Val)
							table.remove(Since,table.KeyFromValue(Since,cv))
						end
					end
				end
			end
		end)
		
		B.List:AddItem(S)
	end
end
concommand.Add("protector_admin",LDRP.AdminOpts)

concommand.Add("protector_tools",function(ply,cmd,args)
	for k,v in pairs(spawnmenu.GetTools()) do
		MsgN("Section: " .. v.Name)
		for c,b in pairs(v.Items) do
			for a,g in pairs(b) do
				if type(g) == "table" and g.Command and g.Command != "" then
					local Name = string.Replace(g.Text,"#","")
					local Spaces = " "
					for i=1,(35-string.len(Name)) do
						Spaces = Spaces .. " "
					end
					MsgN("          ",Name,Spaces,string.Replace(g.Command,"gmod_tool ",""))
				end
			end
		end
	end
end)