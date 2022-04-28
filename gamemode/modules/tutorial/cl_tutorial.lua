local LDRP = {}

LDRP.TutorialParts = {}
LDRP.CurrentPart = 1

--[[---------------------------------------------------------------------------
	Function: LoadTutParts
	Description: Copies the given table into the tutorial parts table, where it
	is assumed that the given table is structured similarly to the tutorial
	parts structure.
-----------------------------------------------------------------------------]]
net.Receive( "LoadTutParts", function( len, pl )
	LDRP.TutorialParts = net.ReadTable()
	notification.AddLegacy( "Tutorial points updated!", 0, 3 )
end )

--[[---------------------------------------------------------------------------
	Function: CreateTutorialPoint
	Description: Replaces the previous tutorial creation system. This is now
derma-based, prompting the user for a title and description of the requested
tutorial point, while capturing their view's position and angle.
-----------------------------------------------------------------------------]]
local C_MAXTITLECHAR = 32
local C_MAXDESCCHAR = 224
local function CreateTutorialPoint( ply, cmd, args )
	local camPos = ply:EyePos()
	local camAng = ply:EyeAngles()

	local promptWindow = vgui.Create( "DFrame" )
	promptWindow:SetSkin( "LiquidDRP2" )
	promptWindow:SetTitle( "Create New Tutorial Point" )
	promptWindow:SetBackgroundBlur( true )
	promptWindow:SetSize( 295, 255 )
	
	local titleLabel = vgui.Create( "DLabel", promptWindow )
	titleLabel:SetText( "Title" )
	titleLabel:SetPos( 5, 20 )
	
	local titleChars = vgui.Create( "DLabel", promptWindow )
	titleChars:SetText( "0/"..C_MAXTITLECHAR )
	titleChars:SetPos( 35, 20 )
	
	local titleValue = vgui.Create( "DTextEntry", promptWindow )
	titleValue:SetPos( 5, 40 )
	titleValue:SetSize( 285, 20 )
	
	function titleValue:OnTextChanged( )
		local txt = self:GetText()
		if #txt > C_MAXTITLECHAR then
			titleChars:SetTextColor( Color( 255, 0, 0, 255 ) )
			timer.Simple( 2, function()
				titleChars:SetTextColor( self:GetSkin().text_normal )
			end )
			local newTxt = string.sub( txt, 1, #txt - 1 )
			self:SetText( newTxt )
			self:SetValue( newTxt )
			self:SetCaretPos( #newTxt )
		end
		
		titleChars:SetText( #self:GetText().."/"..C_MAXTITLECHAR )
	end
	
	local descLabel = vgui.Create( "DLabel", promptWindow )
	descLabel:SetText( "Description" )
	descLabel:SetPos( 5, 65 )
	
	local descChars = vgui.Create( "DLabel", promptWindow )
	descChars:SetText( "0/"..C_MAXDESCCHAR )
	descChars:SetPos( 60, 65 )
	
	local descValue = vgui.Create( "DTextEntry", promptWindow )
	descValue:SetMultiline( true )
	descValue:SetPos( 5, 85 )
	descValue:SetSize( 285, 40 )
	
	function descValue:OnTextChanged( )
		local txt = self:GetText()
		if #txt > C_MAXDESCCHAR then
			descChars:SetTextColor( Color( 255, 0, 0, 255 ) )
			timer.Simple( 2, function()
				descChars:SetTextColor( self:GetSkin().text_normal )
			end )
			local newTxt = string.sub( txt, 1, #txt - 1 )
			self:SetText( newTxt )
			self:SetValue( newTxt )
			self:SetCaretPos( #newTxt )
		end
		
		descChars:SetText( #self:GetText().."/"..C_MAXDESCCHAR )
	end
	
	local promptText = vgui.Create( "DLabel", promptWindow )
	promptText:SetText( "You are about to create a new tutorial point with"..
		" the current settings:\nPosition: "..tostring( camPos ).."\nAngle: "..
		tostring( camAng ).."\nMap: "..game.GetMap()..
		"\n\nDo you want to create a new point?" )
	promptText:SetPos( 5, 130 )
	promptText:SetAutoStretchVertical( true )
	promptText:SetWide( 285 )
	promptText:SetWrap( true )
	
	local cancelBtn = vgui.Create( "DButton", promptWindow )
	cancelBtn:SetText( "Cancel" )
	cancelBtn:SetWide( 80 )
	cancelBtn:SetPos( 30, 230 )
	
	function cancelBtn:OnMousePressed()
		promptWindow:Close()
	end
	
	local yesBtn = vgui.Create( "DButton", promptWindow )
	yesBtn:SetText( "Yes" )
	yesBtn:SetWide( 80 )
	yesBtn:SetPos( promptWindow:GetWide() - 110, 230 )
	function yesBtn:OnMousePressed()
		local titleTxt = titleValue:GetValue()
		local descTxt = descValue:GetValue()
		
		if #titleTxt == 0 then
			Derma_Message( "You must enter a title!", "Cannot Submit Form", "Ok" )
			return
		elseif #descTxt == 0 then
			Derma_Message( "You must enter a description!", "Cannot Submit Form", "Ok" )
			return
		end
		--Send request
		net.Start( "SaveTutorialPoint" )
			net.WriteString( titleTxt )
			net.WriteString( descTxt )
			net.WriteInt( camPos.x, 32 )
			net.WriteInt( camPos.y, 32 )
			net.WriteInt( camPos.z, 32 )
			net.WriteInt( camAng.p, 9 )
			net.WriteInt( camAng.y, 9 )
			net.WriteInt( camAng.r, 9 )
		net.SendToServer()
		
		Derma_Message( "Request has been sent to the server!" )
		promptWindow:Close()
	end
	
	promptWindow:Center()
	promptWindow:MakePopup()
end
concommand.Add( "ldrp_createtutpoint", CreateTutorialPoint )

--[[---------------------------------------------------------------------------
	Function: DeleteTutPoint
	Description: While viewing a particular tutorial point, a user can delete
it by issuing the below concommand.
-----------------------------------------------------------------------------]]
local function DeleteTutPoint()
	if not LocalPlayer().InTut then
		LocalPlayer():ChatPrint(
			"You must be viewing a tutorial point in order to delete it!" )
		return false
	end
	--Good to go, send the request to the server.
	net.Start( "DeleteTutPoint" )
	--I can't imagine someone having > 255 tutorial points.
	net.WriteString( LDRP.TutorialParts[LDRP.CurrentPart]["name"] )
	net.SendToServer()
end
concommand.Add( "ldrp_deletetutpoint", DeleteTutPoint )

--[[---------------------------------------------------------------------------
	Function: LDRP.DoTutorial
	Description: All of the client-side processing during the actual tutorial
happens here.
-----------------------------------------------------------------------------]]
function LDRP.DoTutorial()
	LDRP.CurrentPart = 1
	if LocalPlayer().InTut then return end
	LocalPlayer().InTut = true
	gui.EnableScreenClicker(true)
	timer.Simple(3,function()
		if !LocalPlayer().InTut then return end
		gui.EnableScreenClicker(true)
	end)
	local NextButton = vgui.Create("DButton")
	NextButton:SetPos(ScrW()-ScrH()*.07-10,ScrH()*.82)
	NextButton:SetSize(ScrH()*.07,ScrH()*.07)
	NextButton:SetText("")
	local CurColor = Color(50,50,50,150)
	NextButton.OnCursorEntered = function()
		CurColor = Color(150,150,150,150)
	end
	NextButton.OnCursorExited = function()
		CurColor = Color(50,50,50,150)
	end
	local w,h = NextButton:GetWide(),NextButton:GetTall()
	NextButton.Paint = function()
		draw.RoundedBox(8,0,0,w,h,CurColor)
		draw.SimpleTextOutlined( ">","Trebuchet24", w*.5, h*.5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
	end
	
	local BackButton = vgui.Create("DButton")
	BackButton:SetPos(10,ScrH()*.82)
	BackButton:SetSize(ScrH()*.07,ScrH()*.07)
	BackButton:SetText("")
	local CurColor = Color(50,50,50,150)
	BackButton.OnCursorEntered = function()
		CurColor = Color(150,150,150,150)
	end
	BackButton.OnCursorExited = function()
		CurColor = Color(50,50,50,150)
	end
	w,h = BackButton:GetWide(),BackButton:GetTall()
	BackButton.Paint = function()
		draw.RoundedBox(8,0,0,w,h,CurColor)
		draw.SimpleTextOutlined( "<","Trebuchet24", w*.5, h*.5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
	end
	BackButton.DoClick = function()
		if LDRP.CurrentPart == 1 then LocalPlayer():ChatPrint("You are already at the start of the tutorial!") return end
		LDRP.CurrentPart = LDRP.CurrentPart-1
		Change = CurTime()
	end
	
	local HasP
	local Change = CurTime()
	NextButton.DoClick = function()
		if !HasP then HasP = true end
		LDRP.CurrentPart = LDRP.CurrentPart+1
		Change = CurTime()
	end

	function LDRP.TutorialHUD()
		if LDRP.CurrentPart <= #LDRP.TutorialParts then
			draw.RoundedBox(0,0,0,ScrW(),ScrH()*.1,Color(0,0,0,180))
			draw.SimpleTextOutlined( LDRP.TutorialParts[LDRP.CurrentPart].name,"HUDNumber", ScrW()*.5, ScrH()*.05, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			
			draw.RoundedBox(0,0,ScrH()*.9,ScrW(),ScrH()*.1,Color(0,0,0,180))
			
			if !HasP then
				draw.SimpleTextOutlined( "Use the arrow buttons on the left and right to go through the tutorial","Trebuchet24", ScrW()*.5, ScrH()*.85, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			end
			
			local D = LDRP.TutorialParts[LDRP.CurrentPart].descrpt
			if string.len(D) < 100 then
				draw.SimpleTextOutlined( D,"Trebuchet24", ScrW()*.5, ScrH()*.95, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			else
				draw.SimpleTextOutlined( string.sub(D,0,100) .. "-","Trebuchet24", ScrW()*.5, ScrH()*.935, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
				draw.SimpleTextOutlined( string.sub(D,101,string.len(D)),"Trebuchet24", ScrW()*.5, ScrH()*.97, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			end
		else
			gui.EnableScreenClicker(false)
			NextButton:Remove()
			BackButton:Remove()
			LocalPlayer().InTut = nil
			RunConsoleCommand("_fintut")
			hook.Remove("CalcView","Sets the view for current tutorial")
			hook.Remove("HUDPaint","The tutorial VGUI")
		end
	end
	hook.Add("HUDPaint","The tutorial VGUI",LDRP.TutorialHUD)

	function LDRP.TutorialView(ply,pos,angles,fov)
		if LDRP.CurrentPart > #LDRP.TutorialParts then return end
		
		local view = {}
		view.origin = LDRP.TutorialParts[LDRP.CurrentPart].pos
		view.angles = LDRP.TutorialParts[LDRP.CurrentPart].angs
		view.fov = fov-math.Clamp(2*(CurTime()-Change),0,20)

		return view
	end
	hook.Add("CalcView","Sets the view for current tutorial",LDRP.TutorialView)
end
net.Receive( "StartTutorial", LDRP.DoTutorial )