local LDRP_Hitman,CurHits,MC = {},0,math.Clamp

LDRP_Hitman.Hits = {}
function LDRP_Hitman.ReceiveHit(um)
	CurHits = CurHits+1
	LDRP_Hitman.Hits[CurHits] = um:ReadEntity()
	MsgN("Added")
end
usermessage.Hook("SendHitt",LDRP_Hitman.ReceiveHit)

function LDRP_Hitman.RemoveHit(um)
	local playa = um:ReadString()
	for k,v in pairs(LDRP_Hitman.Hits) do
		if string.lower(v:UniqueID()) == playa then
			LDRP_Hitman.Hits[k] = nil
		end
	end
end
usermessage.Hook("RemoveHitt",LDRP_Hitman.RemoveHit)

usermessage.Hook("ResetHits",function(um) LDRP_Hitman.Hits = {} end)

function LDRP_Hitman.HitMenu()
	local B = {}
	B.Opened = CurTime()
	B.OpenMath = 0
	
	B.BG = vgui.Create("DFrame")
	B.BG:SetSize(500,400)
	local w,h = B.BG:GetSize()
	B.BG:MakePopup()
	B.BG:Center()
	B.BG.Paint = function(s)
		B.OpenMath = (MC((CurTime()-B.Opened),0,.5)/.5)
		if B.Closin then B.OpenMath = 1-B.OpenMath end
		draw.RoundedBox(8,0,0,w,h,Color(0,0,0,210*B.OpenMath))
		draw.SimpleTextOutlined("Players with hits on them","Trebuchet22",w*.5,12,Color(255,255,255,240*B.OpenMath),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2, Color(0,0,0,150*B.OpenMath) )
	end
	B.BG:ShowCloseButton(false)
	B.BG:SetTitle("")
	
	B.Close = vgui.Create("DButton",B.BG)
	B.Close:SetPos(w-24,4)
	B.Close:SetSize(20,20)
	B.Close.DoClick = function() if !B.Closin then B.Opened = CurTime() B.Closin = true timer.Simple(.5,function() B.BG:Close() end) end end
	local cl = Color(110,110,110,210)
	B.Close.Paint = function(s) local x,y = s:GetSize() draw.RoundedBox(8,0,0,x,y,Color(cl.r,cl.g,cl.b,cl.a*B.OpenMath)) draw.SimpleTextOutlined("X","Trebuchet24",x*.5,y*.5,Color(255,255,255,200*B.OpenMath),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200*B.OpenMath) ) end
	B.Close.OnCursorEntered = function() cl = Color(160,160,160,210) end
	B.Close.OnCursorExited = function() cl = Color(110,110,110,210) end
	B.Close:SetText("")
	
	B.List = vgui.Create("DPanelList",B.BG)
	B.List:SetPos(4,28)
	B.List:SetSize(w-8,h-34)
	B.List.Paint = function(s) local x,y=s:GetSize() draw.RoundedBox(10,0,0,x,y,Color(40,40,40,200*B.OpenMath)) end
	B.List:SetPadding(4)
	B.List:SetSpacing(4)
	B.List:EnableVerticalScrollbar(true)
	
	local HitUIs = {}
	local function AddHit(ply,num)
		local thename = ply:GetName()
		
		local Hit = vgui.Create("DPanel")
		Hit:SetHeight(30)
		Hit.Paint = function(s)
			local tw,th = s:GetSize()
			draw.RoundedBox(6,0,0,tw,th,Color(80,80,80,210))
			draw.SimpleTextOutlined(thename,"Trebuchet24",tw*.5,th*.5,Color(255,255,255,140),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2, Color(0,0,0,150) )
		end
		B.List:AddItem(Hit)
		HitUIs[num] = Hit
	end
	
	local Inlist = {}
	for k,v in pairs(LDRP_Hitman.Hits) do
		if !v:IsValid() then return end
		Inlist[k] = v
		AddHit(v,k)
	end
	
	B.List.Think = function()
		for k,v in pairs(LDRP_Hitman.Hits) do
			if !Inlist[k] or Inlist[k] != v then
				if Inlist[k] then HitUIs[k]:Remove() end
				Inlist[k] = v
				AddHit(v,k)
			end
		end
		for k,v in pairs(Inlist) do
			if !LDRP_Hitman.Hits[k] then
				if HitUIs[k] and HitUIs[k]:IsValid() then
					HitUIs[k]:Remove()
					Inlist[k] = nil
				end
			end
		end
	end
end
usermessage.Hook("SendHitMenu",LDRP_Hitman.HitMenu)