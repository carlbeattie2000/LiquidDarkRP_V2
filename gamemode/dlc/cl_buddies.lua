local LDRP = {}

LDRP.CurBuddies = {}
function LDRP.GetBuddy(um)
	LDRP.CurBuddies[um:ReadString()] = um:ReadString()
end
usermessage.Hook("SendPPBuddy",LDRP.GetBuddy)

function LDRP.BuddiesList()
	local B = {}
	
	B.BG = vgui.Create("DFrame")
	B.BG:SetSize(600,380)
	B.BG:SetTitle("Protector - buddies list")
	B.BG:Center()
	B.BG:MakePopup()
	
	B.Players = vgui.Create("DPanelList",B.BG)
	B.Players:SetPos(4,25)
	B.Players:SetSize(292,350)
	B.Players:SetPadding(4)
	B.Players:SetSpacing(4)
	B.Players:EnableVerticalScrollbar(true)
	
	B.Friends = vgui.Create("DPanelList",B.BG)
	B.Friends:SetPos(304,25)
	B.Friends:SetSize(292,350)
	B.Friends:SetPadding(4)
	B.Friends:SetSpacing(4)
	B.Friends:EnableVerticalScrollbar(true)
	
	local Lists = {}
	Lists.F = {}
	Lists.P = {}
	function B.AddPlayer(Section,Playa)
		local Name,SID
		if type(Playa) == "table" then
			Name,SID = Playa[2],Playa[1]
		else
			Name,SID = Playa:Name(),Playa:UniqueID()
		end
		
		if Lists.P[SID] then
			B.Players:RemoveItem(Lists.P[SID])
			Lists.P[SID] = nil
		end
		if Lists.F[SID] then
			B.Friends:RemoveItem(Lists.F[SID])
			Lists.F[SID] = nil
		end
		
		local Ply = vgui.Create("DPanel")
		Ply:SetHeight(30)
		Ply.Paint = function(s)
			local W,H = s:GetSize()
			draw.RoundedBox(6,0,0,W,H,Color(0,0,0,180))
			draw.SimpleTextOutlined(Name,"Trebuchet18",6,15,Color(255,255,255,210),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 2, Color(0,0,0,150) )
		end
		
		timer.Simple(.01,function()
			local Add = vgui.Create("DButton",Ply)
			Add:SetPos(Ply:GetWide()-74,4)
			Add:SetSize(70,22)
			Add:SetText((Section == "players" and "Add") or "Remove")
			local function ButtonFunc()
				for k,v in pairs(player.GetAll()) do
					if v:UniqueID() == SID then
						B.AddPlayer((Section == "players" and "friends") or "players",Playa)
					end
				end
				if Section != "players" then LDRP.CurBuddies[SID] = nil end
				RunConsoleCommand("_protector","friend",SID)
			end
			Add.DoClick = function()
				if Section != "players" then
					local YouSure = vgui.Create("DFrame")
					YouSure:SetSize(400,75)
					YouSure:Center()
					YouSure:SetBackgroundBlur(true)
					YouSure:MakePopup()
					YouSure:SetTitle("Are you sure?")
					
					local Txt = vgui.Create("DPanel",YouSure)
					Txt:SetText("")
					Txt:SetPos(0,25)
					Txt:SetSize(400,20)
					Txt.Paint = function()
						draw.SimpleTextOutlined("Are you sure you want to remove " .. Name .. "?",(string.len(Name) > 10 and "Trebuchet18") or "Trebuchet22",200,10,Color(255,255,255,210),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,150) )
					end
					
					local Yes,CLr = vgui.Create("DButton",YouSure),Color(140,140,140,255)
					Yes:SetPos(175,50)
					Yes:SetSize(50,20)
					Yes:SetText("Yes")
					Yes.DoClick = function() ButtonFunc() YouSure:Close() end
					Yes.OnCursorEntered = function() CLr = Color(255,0,0,80) end
					Yes.OnCursorExited = function() CLr = Color(140,140,140,255) end
					Yes.Paint = function()
						draw.RoundedBox(6,0,0,50,20,Color(0,0,0,255))
						draw.RoundedBox(6,2,2,46,16,CLr)
					end
				else
					ButtonFunc()
				end
			end
		end)
		if Section == "players" then
			B.Players:AddItem(Ply)
			Lists.P[SID] = Ply
		else
			B.Friends:AddItem(Ply)
			Lists.F[SID] = Ply
		end
	end
	
	for k,v in pairs(player.GetAll()) do
		if v == LocalPlayer() or LDRP.CurBuddies[v:UniqueID()] then continue end
		B.AddPlayer("players",v)
	end
	
	for k,v in pairs(LDRP.CurBuddies) do
		B.AddPlayer("friends",{[1] = k,[2] = v})
	end
end
usermessage.Hook("SendBuddyMenu",LDRP.BuddiesList)

hook.Add("PhysgunPickup","Removes dumb lasor",function(ply,ent) return false end)