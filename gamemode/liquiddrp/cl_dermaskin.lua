local surface = surface
local draw = draw
local Color = Color

LDRP_Theme = LDRP_Theme or {}
LDRP_Theme["Default"] = {}
LDRP_Theme["Default"].Icon = "icon16/world.png"
LDRP_Theme["Default"].Name = "Default \"It's Blue\" Blue"
LDRP_Theme["Default"].FrameClr = Color(48,150,240,255)
LDRP_Theme["Default"].BGColor = Color( 0, 130, 255, 150 )
LDRP_Theme["Default"].AltBG = Color( 0, 157, 255, 200 )
LDRP_Theme["Default"].FontFrame = "ChatFont"
LDRP_Theme["Default"].ControlClr = Color( 50, 50, 100, 160 )
LDRP_Theme["Default"].List = Color( 0, 208, 255, 160 )
LDRP_Theme["Default"].Txt = Color( 175, 175, 175, 255 )
LDRP_Theme["Default"].Tip = Color( 100, 200, 255, 200 )
LDRP_Theme["Default"].TransBack = Color( 255, 255, 255, 50 )
LDRP_Theme["Default"].colProp = Color( 0, 102, 255, 200 )
LDRP_Theme["Default"].colTab = Color( 0, 141, 215, 200 )
LDRP_Theme["Default"].colFont = "Trebuchet18"
LDRP_Theme["Default"].colMenuBG = Color( 250, 250, 250, 200 )
LDRP_Theme["Default"].TradeMenu = Color( 0, 45, 255, 255 )
LDRP_Theme["Default"].IconBG = Color(133,215,253,140)

if !LDRP_Theme.CurrentSkin then LDRP_Theme.CurrentSkin = "Dark Skin" end

timer.Simple(1,function()
	if file.Exists("ldrp_savetheme.txt", "DATA") and LDRP_Theme[file.Read("ldrp_savetheme.txt", "DATA")] then
		LDRP_Theme.CurrentSkin = file.Read("ldrp_savetheme.txt", "DATA")
		RefreshSkin()
	end
end)

local oCTB = GWEN.CreateTextureBorder
--[[---------------------------------------------------------------------------
	Function: GWEN.CreateTextureBorder
	Description: This overrides the built in GWEN function that reads in a
	material from the specified skin file. This function attempts to perform a
	color modification so that the read in skin's color is modified based on
	one of the colors provided in the selected skin.
-----------------------------------------------------------------------------]]
GWEN.CreateTextureBorder = function( _x, _y, _w, _h, l, t, r, b, colMod )
	local modifyFunc = function( x, y, w, h, col )
		local otherFunc = oCTB( _x, _y, _w, _h, l, t, r, b )
		--Modify the texture's color by subtracting the difference between it and
		--one of the colors from this skin.
		local skinCol = colMod or LDRP_Theme[LDRP_Theme.CurrentSkin].IconBG
		if not col then col = Color( 255, 255, 255, 255 ) end
		local newCol = Color(
			col.r - ( col.r - skinCol.r ),
			col.g - ( col.g - skinCol.g ),
			col.b - ( col.b - skinCol.b ),
			col.a - ( col.a - skinCol.a ) )

		return otherFunc( x, y, w, h, newCol )
	end
	
	return modifyFunc
end

function RefreshSkin()

	local SKIN = {}

	SKIN.PrintName 		= "Derma skin for LiquidDRP V2" -- edited for public release, now with skin editing :)
	SKIN.Author 		= "Alex"
	SKIN.DermaVersion	= 1
	local function MC(v) return math.Clamp(v,0,255) end

	local BG = LDRP_Theme[LDRP_Theme.CurrentSkin].BGColor
	SKIN.bg_color 					= BG
	SKIN.bg_color_sleep 			= Color( MC(BG.r-40), MC(BG.g-40), MC(BG.b-40), MC(BG.a-100) )
	SKIN.bg_color_dark				= Color( MC(BG.r), MC(BG.g), MC(BG.b), BG.a + 100 )
	SKIN.bg_color_bright			= Color( MC(BG.r+20), MC(BG.g+20), MC(BG.b+20), MC(BG.a+70) )
	SKIN.frame_border                = Color( MC(BG.r-170), MC(BG.g-170), MC(BG.b-170), MC(BG.a+20) )
	SKIN.frame_title                = Color( MC(BG.r+20), MC(BG.g+20), MC(BG.b+20), MC(BG.a-40) )

	SKIN.fontFrame					= LDRP_Theme[LDRP_Theme.CurrentSkin].FontFrame

	local CC = LDRP_Theme[LDRP_Theme.CurrentSkin].ControlClr
	SKIN.control_color 				= CC
	SKIN.control_color_highlight	= Color( MC(CC.r+40), MC(CC.g+40), MC(CC.b+40), MC(CC.a+20) )
	SKIN.control_color_active 		= Color( MC(CC.r+20), MC(CC.g+20), MC(CC.b+20), MC(CC.a+20) )
	SKIN.control_color_bright 		= Color( MC(CC.r+20), MC(CC.g+20), MC(CC.b+20), MC(CC.a+45) )
	SKIN.control_color_dark 		= Color( MC(CC.r-80), MC(CC.g-80), MC(CC.b-80), MC(CC.a-20) )

	local AltBG = LDRP_Theme[LDRP_Theme.CurrentSkin].AltBG
	SKIN.bg_alt1 					= LDRP_Theme[LDRP_Theme.CurrentSkin].AltBG
	SKIN.bg_alt2 					= Color( MC(AltBG.r-80), MC(AltBG.g-80), MC(AltBG.b-80), MC(AltBG.a-20) )
	local LV = LDRP_Theme[LDRP_Theme.CurrentSkin].List
	SKIN.listview_hover				= LV
	SKIN.listview_selected			= Color( MC(AltBG.r-40), MC(AltBG.g-40), MC(AltBG.b-40), MC(AltBG.a+20) )

	local TX = LDRP_Theme[LDRP_Theme.CurrentSkin].Txt
	SKIN.text_bright				= Color( MC(TX.r+50), MC(TX.g+50), MC(TX.b+50), MC(TX.a+20) )
	SKIN.text_normal				= TX
	SKIN.text_dark					= Color( MC(TX.r-80), MC(TX.g-80), MC(TX.b-80), MC(TX.a+30) )
	SKIN.text_highlight				= Color( MC(TX.r-30), MC(TX.g-30), MC(TX.b-30), MC(TX.a-20) )
	
	SKIN.text_outline				= LDRP_Theme[LDRP_Theme.CurrentSkin].TradeMenu

	SKIN.texGradientUp				= Material( "gui/gradient_up" )
	SKIN.texGradientDown			= Material( "gui/gradient_down" )

	SKIN.combobox_selected			= SKIN.listview_selected

	SKIN.panel_transback			= LDRP_Theme[LDRP_Theme.CurrentSkin].TransBack
	SKIN.tooltip					= LDRP_Theme[LDRP_Theme.CurrentSkin].Tip

	local TB = LDRP_Theme[LDRP_Theme.CurrentSkin].colTab
	SKIN.colPropertySheet 			= LDRP_Theme[LDRP_Theme.CurrentSkin].colProp
	SKIN.colTab			 			= TB
	SKIN.colTabInactive				= Color( MC(TB.r-40), MC(TB.g-40), MC(TB.b-40), MC(TB.a-40) )
	SKIN.colTabShadow				= Color( 0, 0, 0, TB.a-50 )
	SKIN.colTabText		 			= Color( 255, 255, 255, 255 )
	SKIN.colTabTextInactive			= Color( 190, 190, 190, 155 )
	SKIN.fontTab					= LDRP_Theme[LDRP_Theme.CurrentSkin].colFont

	SKIN.colCollapsibleCategory		= Color( MC(TB.r-140), MC(TB.g-140), MC(TB.b-140), MC(TB.a-30) )

	SKIN.colCategoryText			= Color( 255, 255, 255, 255 )
	SKIN.colCategoryTextInactive	= Color( 200, 200, 200, 255 )
	SKIN.fontCategoryHeader			= "CenterPrintText"

	SKIN.colNumberWangBG			= Color( 100, 200, 255, 200 )
	SKIN.colTextEntryBG				= Color( MC(TB.r+50), MC(TB.g+50), MC(TB.b+50), MC(TB.a-70) )
	SKIN.colTextEntryBorder			= Color( MC(TB.r-120), MC(TB.g-120), MC(TB.b-120), MC(TB.a+60) )
	SKIN.colTextEntryText			= Color( 255, 255, 255, 200 )
	SKIN.colTextEntryTextHighlight	= Color( 255, 255, 255, 200 )

	SKIN.colMenuBG					= LDRP_Theme[LDRP_Theme.CurrentSkin].colMenuBG
	SKIN.colMenuBorder				= Color( MC(LDRP_Theme[LDRP_Theme.CurrentSkin].colMenuBG.r-120), MC(LDRP_Theme[LDRP_Theme.CurrentSkin].colMenuBG.g-120), MC(LDRP_Theme[LDRP_Theme.CurrentSkin].colMenuBG.b-120), MC(LDRP_Theme[LDRP_Theme.CurrentSkin].colMenuBG.a+60) )

	SKIN.colButtonText				= Color( 255, 255, 255, 255 )
	SKIN.colButtonTextDisabled		= Color( 50, 50, 50, 200 )
	SKIN.colButtonBorder			= Color( 20, 20, 20, 255 )
	SKIN.colButtonBorderHighlight	= Color( 200, 200, 200, 50 )
	SKIN.colButtonBorderShadow		= Color( 0, 0, 0, 100 )
	SKIN.fontButton					= "HudHintTextLarge"

	--Some GWEN support for now.
	SKIN.tex = {}
	
	SKIN.tex.Button						= GWEN.CreateTextureBorder( 480, 0,	31,		31,		8,	8,		8,	8, SKIN.control_color )
	SKIN.tex.Button_Hovered				= GWEN.CreateTextureBorder( 480, 32,	31,		31,		8,	8,		8,	8, SKIN.control_color_highlight )
	SKIN.tex.Button_Dead				= GWEN.CreateTextureBorder( 480, 64,	31,		31,		8,	8,		8,	8, SKIN.control_color_dark )
	SKIN.tex.Button_Down				= GWEN.CreateTextureBorder( 480, 96,	31,		31,		8,	8,		8,	8, SKIN.control_color_active )

	SKIN.tex.Checkbox_Checked            = GWEN.CreateTextureNormal( 448, 32, 15, 15 )
	SKIN.tex.Checkbox                    = GWEN.CreateTextureNormal( 464, 32, 15, 15 )
	SKIN.tex.CheckboxD_Checked            = GWEN.CreateTextureNormal( 448, 48, 15, 15 )
	SKIN.tex.CheckboxD                    = GWEN.CreateTextureNormal( 464, 48, 15, 15 )

	SKIN.tex.CategoryList = {}
	SKIN.tex.CategoryList.Outer        = GWEN.CreateTextureBorder( 256,        384, 63, 63, 8, 8, 8, 8, SKIN.control_color );


	SKIN.tex.Input = {}

	SKIN.tex.Input.ComboBox = {}
	SKIN.tex.Input.ComboBox.Button = {}
	SKIN.tex.Input.ComboBox.Button.Normal	= GWEN.CreateTextureNormal( 496,    272,    15, 15 );
	SKIN.tex.Input.ComboBox.Button.Hover	= GWEN.CreateTextureNormal( 496,    272+16, 15, 15 );
	SKIN.tex.Input.ComboBox.Button.Down		= GWEN.CreateTextureNormal( 496,    272+32, 15, 15 );
	SKIN.tex.Input.ComboBox.Button.Disabled	= GWEN.CreateTextureNormal( 496,    272+48, 15, 15 );


	SKIN.tex.Input.ListBox				= {}
	SKIN.tex.Input.ListBox.Background	= GWEN.CreateTextureBorder( 256,    256, 63, 127, 8, 8, 8, 8 );

	SKIN.tex.Input.Slider				= {}
	SKIN.tex.Input.Slider.H				= {}
	SKIN.tex.Input.Slider.H.Normal		= GWEN.CreateTextureNormal( 416,    32,    15, 15 );
	SKIN.tex.Input.Slider.H.Hover		= GWEN.CreateTextureNormal( 416,    32+16, 15, 15 );
	SKIN.tex.Input.Slider.H.Down		= GWEN.CreateTextureNormal( 416,    32+32, 15, 15 );
	SKIN.tex.Input.Slider.H.Disabled	= GWEN.CreateTextureNormal( 416,    32+48, 15, 15 );

	SKIN.tex.Input.UpDown 				= {}
	SKIN.tex.Input.UpDown.Up 			= {}
	SKIN.tex.Input.UpDown.Up.Normal		= GWEN.CreateTextureCentered( 384,        112,    7, 7 );
	SKIN.tex.Input.UpDown.Up.Hover		= GWEN.CreateTextureCentered( 384+8,    112,    7, 7 );
	SKIN.tex.Input.UpDown.Up.Down		= GWEN.CreateTextureCentered( 384+16,    112,    7, 7 );
	SKIN.tex.Input.UpDown.Up.Disabled	= GWEN.CreateTextureCentered( 384+24,    112,    7, 7 );

	SKIN.tex.Input.UpDown.Down 			= {}
	SKIN.tex.Input.UpDown.Down.Normal	= GWEN.CreateTextureCentered( 384,        120,    7, 7 );
	SKIN.tex.Input.UpDown.Down.Hover	= GWEN.CreateTextureCentered( 384+8,    120,    7, 7 );
	SKIN.tex.Input.UpDown.Down.Down		= GWEN.CreateTextureCentered( 384+16,    120,    7, 7 );
	SKIN.tex.Input.UpDown.Down.Disabled	= GWEN.CreateTextureCentered( 384+24,    120,    7, 7 );

	SKIN.tex.Menu = {}
	SKIN.tex.Menu.RightArrow                = GWEN.CreateTextureNormal( 464, 112, 15, 15 );

	SKIN.tex.Menu_Strip					= GWEN.CreateTextureBorder( 0, 128, 127, 21,        8, 8, 8, 8)

	SKIN.tex.ProgressBar = {}
	SKIN.tex.ProgressBar.Back        		= GWEN.CreateTextureBorder( 384,    0, 31, 31, 8, 8, 8, 8 );
	SKIN.tex.ProgressBar.Front        		= GWEN.CreateTextureBorder( 384+32,    0, 31, 31, 8, 8, 8, 8 );

	SKIN.tex.Scroller = {}
	SKIN.tex.Scroller.LeftButton_Normal		= GWEN.CreateTextureBorder( 464,	208,	15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.LeftButton_Hover		= GWEN.CreateTextureBorder( 480,	208,	15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.LeftButton_Down		= GWEN.CreateTextureBorder( 464,	272,	15, 15, 2, 2, 2, 2 );

	SKIN.tex.Scroller.UpButton_Normal		= GWEN.CreateTextureBorder( 464,		208 + 16,    15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.UpButton_Hover		= GWEN.CreateTextureBorder( 480,		208 + 16,    15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.UpButton_Down			= GWEN.CreateTextureBorder( 464,		272 + 16,    15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.UpButton_Disabled		= GWEN.CreateTextureBorder( 480 + 48,	272 + 16,    15, 15, 2, 2, 2, 2 );

	SKIN.tex.Scroller.DownButton_Normal		= GWEN.CreateTextureBorder( 464,		208 + 48,    15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.DownButton_Hover		= GWEN.CreateTextureBorder( 480,		208 + 48,    15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.DownButton_Down		= GWEN.CreateTextureBorder( 464,		272 + 48,    15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.DownButton_Disabled	= GWEN.CreateTextureBorder( 480 + 48,	272 + 48,    15, 15, 2, 2, 2, 2 );

	SKIN.tex.Scroller.RightButton_Normal	= GWEN.CreateTextureBorder( 464, 208 + 32,	15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.RightButton_Hover		= GWEN.CreateTextureBorder( 480, 208 + 32,	15, 15, 2, 2, 2, 2 );
	SKIN.tex.Scroller.RightButton_Down		= GWEN.CreateTextureBorder( 464,	272 + 32,	15, 15, 2, 2, 2, 2 );

	SKIN.tex.Selection						= GWEN.CreateTextureBorder( 384, 32, 31, 31, 4, 4, 4, 4 );
	
	SKIN.tex.Shadow							= GWEN.CreateTextureBorder( 448, 0,	31,	31,	8, 8, 8, 8 )

	SKIN.tex.TreePlus						= GWEN.CreateTextureNormal( 448, 96, 15, 15 )
	SKIN.tex.TreeMinus						= GWEN.CreateTextureNormal( 464, 96, 15, 15 )

	SKIN.tex.Window = {}

	SKIN.tex.Window.Close		= GWEN.CreateTextureNormal( 32, 448, 31, 31 );
	SKIN.tex.Window.Close_Hover	= GWEN.CreateTextureNormal( 64, 448, 31, 31 );
	SKIN.tex.Window.Close_Down	= GWEN.CreateTextureNormal( 96, 448, 31, 31 );

	SKIN.tex.Window.Maxi		= GWEN.CreateTextureNormal( 32 + 96*2, 448, 31, 31 );
	SKIN.tex.Window.Maxi_Hover	= GWEN.CreateTextureNormal( 64 + 96*2, 448, 31, 31 );
	SKIN.tex.Window.Maxi_Down	= GWEN.CreateTextureNormal( 96 + 96*2, 448, 31, 31 );

	SKIN.tex.Window.Mini		= GWEN.CreateTextureNormal( 32 + 96, 448, 31, 31 );
	SKIN.tex.Window.Mini_Hover	= GWEN.CreateTextureNormal( 64 + 96, 448, 31, 31 );
	SKIN.tex.Window.Mini_Down	= GWEN.CreateTextureNormal( 96 + 96, 448, 31, 31 );
	
	--Colo(u)rs?? (For GWEN most likely)
	SKIN.Colours = {}
	
	SKIN.Colours.Button = {}
	SKIN.Colours.Button.Normal				= SKIN.text_normal
	SKIN.Colours.Button.Hover				= SKIN.text_bright
	SKIN.Colours.Button.Down				= SKIN.text_dark
	SKIN.Colours.Button.Disabled			= SKIN.text_highlight
	
	SKIN.Colours.Category = {}
	SKIN.Colours.Category.Header				= GWEN.TextureColor( 4 + 8 * 18, 500 );
	SKIN.Colours.Category.Header_Closed			= GWEN.TextureColor( 4 + 8 * 19, 500 );
	SKIN.Colours.Category.Line = {}
	SKIN.Colours.Category.Line.Text				= SKIN.text_normal
	SKIN.Colours.Category.Line.Text_Hover		= GWEN.TextureColor( 4 + 8 * 21, 508 );
	SKIN.Colours.Category.Line.Text_Selected	= GWEN.TextureColor( 4 + 8 * 20, 500 );
	SKIN.Colours.Category.Line.Button			= GWEN.TextureColor( 4 + 8 * 21, 500 );
	SKIN.Colours.Category.Line.Button_Hover		= GWEN.TextureColor( 4 + 8 * 22, 508 );
	SKIN.Colours.Category.Line.Button_Selected	= GWEN.TextureColor( 4 + 8 * 23, 508 );
	SKIN.Colours.Category.LineAlt = {}
	SKIN.Colours.Category.LineAlt.Text				= SKIN.text_dark
	SKIN.Colours.Category.LineAlt.Text_Hover		= GWEN.TextureColor( 4 + 8 * 23, 500 );
	SKIN.Colours.Category.LineAlt.Text_Selected		= GWEN.TextureColor( 4 + 8 * 24, 508 );
	SKIN.Colours.Category.LineAlt.Button			= GWEN.TextureColor( 4 + 8 * 25, 508 );
	SKIN.Colours.Category.LineAlt.Button_Hover		= GWEN.TextureColor( 4 + 8 * 24, 500 );
	SKIN.Colours.Category.LineAlt.Button_Selected	= GWEN.TextureColor( 4 + 8 * 25, 500 );
	
	SKIN.Colours.Window = {}
	SKIN.Colours.Window.TitleActive			= SKIN.colButtonText
	SKIN.Colours.Window.TitleInactive		= SKIN.colButtonTextDisabled

	SKIN.Colours.Tab = {}
	SKIN.Colours.Tab.Active = {}
	SKIN.Colours.Tab.Active.Normal			= GWEN.TextureColor( 4 + 8 * 4, 508 );
	SKIN.Colours.Tab.Active.Hover			= GWEN.TextureColor( 4 + 8 * 5, 508 );
	SKIN.Colours.Tab.Active.Down			= GWEN.TextureColor( 4 + 8 * 4, 500 );
	SKIN.Colours.Tab.Active.Disabled		= GWEN.TextureColor( 4 + 8 * 5, 500 );
                                              
	SKIN.Colours.Tab.Inactive = {}            
	SKIN.Colours.Tab.Inactive.Normal		= GWEN.TextureColor( 4 + 8 * 6, 508 );
	SKIN.Colours.Tab.Inactive.Hover			= GWEN.TextureColor( 4 + 8 * 7, 508 );
	SKIN.Colours.Tab.Inactive.Down			= GWEN.TextureColor( 4 + 8 * 6, 500 );
	SKIN.Colours.Tab.Inactive.Disabled		= GWEN.TextureColor( 4 + 8 * 7, 500 );
                                              
	SKIN.Colours.Label = {}                   
	SKIN.Colours.Label.Default				= SKIN.text_normal
	SKIN.Colours.Label.Bright				= SKIN.text_bright
	SKIN.Colours.Label.Dark					= SKIN.text_dark
	SKIN.Colours.Label.Highlight			= SKIN.text_highlight

	SKIN.Colours.Tree = {}
	SKIN.Colours.Tree.Lines					= LDRP_Theme[LDRP_Theme.CurrentSkin].ControlClr
	--Affects the text of the tree nodes.
	SKIN.Colours.Tree.Normal 				= SKIN.text_normal
	SKIN.Colours.Tree.Hover					= GWEN.TextureColor( 4 + 8 * 10, 500 );
	SKIN.Colours.Tree.Selected				= GWEN.TextureColor( 4 + 8 * 11, 500 );

	SKIN.Colours.Properties = {}
	SKIN.Colours.Properties.Line_Normal			= GWEN.TextureColor( 4 + 8 * 12, 508 );
	SKIN.Colours.Properties.Line_Selected		= GWEN.TextureColor( 4 + 8 * 13, 508 );
	SKIN.Colours.Properties.Line_Hover			= GWEN.TextureColor( 4 + 8 * 12, 500 );
	SKIN.Colours.Properties.Title				= GWEN.TextureColor( 4 + 8 * 13, 500 );
	SKIN.Colours.Properties.Column_Normal		= GWEN.TextureColor( 4 + 8 * 14, 508 );
	SKIN.Colours.Properties.Column_Selected		= GWEN.TextureColor( 4 + 8 * 15, 508 );
	SKIN.Colours.Properties.Column_Hover		= GWEN.TextureColor( 4 + 8 * 14, 500 );
	SKIN.Colours.Properties.Border				= GWEN.TextureColor( 4 + 8 * 15, 500 );
	SKIN.Colours.Properties.Label_Normal		= GWEN.TextureColor( 4 + 8 * 16, 508 );
	SKIN.Colours.Properties.Label_Selected		= GWEN.TextureColor( 4 + 8 * 17, 508 );
	SKIN.Colours.Properties.Label_Hover			= GWEN.TextureColor( 4 + 8 * 16, 500 );

	SKIN.Colours.TooltipText	= GWEN.TextureColor( 4 + 8 * 26, 500 );

	/*---------------------------------------------------------
	   DrawGenericBackground
	---------------------------------------------------------*/
	function SKIN:DrawGenericBackground( x, y, w, h, color )

		draw.RoundedBox( 4, x, y, w, h, color )

	end


	/*---------------------------------------------------------
		Frame
	---------------------------------------------------------*/
	local matBlurScreen = Material( "pp/blurscreen" )
	local blur
	function SKIN:PaintFrame( panel )
		local FC = LDRP_Theme[LDRP_Theme.CurrentSkin].FrameClr
		local WD,TL = panel:GetSize()
		
		draw.RoundedBox( 8, 0, 0, WD, TL, Color(FC.r,FC.g,FC.b,FC.a-50) )
		--draw.RoundedBox( 12, 6, 6, WD-12, TL-12, Color(255,255,255,50) )
		
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )
			
		--[[local x1, y1 = panel:LocalToScreen( 2, 2 )
		local x2, y2 = panel:LocalToScreen( WD - 2, TL - 2 )
		x1 = x1 + 5 y1 = y1 + 5
		x2 = x2 - 5 y2 = y2 - 5]]
			
		matBlurScreen:SetFloat( "$blur", 5 )
		render.UpdateScreenEffectTexture()
		--[[surface.DrawPoly( {
			{ x = 2, y = 2, u = x1/ScrW(), v = y1/ScrH() },
			{ x = WD - 4, y = 2, u = x2/ScrW(), v = y1/ScrH() },
			{ x = WD - 4, y = TL - 2, u = x2/ScrW(), v = y2/ScrH() },
			{ x = 2, y = TL - 2, u = x1/ScrW(), v = y2/ScrH() }
		} )]]
		
	   -- draw.RoundedBox( 4, 1, 1, panel:GetWide()-2, panel:GetTall()-2, self.frame_title )
	   draw.RoundedBoxEx( 4, 2, 21, WD-4, TL-23, self.bg_color, false, false, true, true )

	end

	function SKIN:LayoutFrame( panel )

		panel.lblTitle:SetFont( self.fontFrame )
		
		panel.btnClose:SetPos( panel:GetWide() - 22, 4 )
		panel.btnClose:SetSize( 18, 18 )
		
		panel.lblTitle:SetPos( 8, 2 )
		panel.lblTitle:SetSize( panel:GetWide() - 25, 20 )

	end
	
	/*---------------------------------------------------------
	   DrawDisabledButtonBorder
	---------------------------------------------------------*/
	function SKIN:DrawDisabledButtonBorder( x, y, w, h, depressed )

		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawOutlinedRect( x, y, w, h )
		
	end

	/*---------------------------------------------------------
		SysButton
	---------------------------------------------------------*/
	function SKIN:PaintPanel( panel )

		if ( panel.m_bPaintBackground ) then
		
			local w, h = panel:GetSize()
			self:DrawGenericBackground( 0, 0, w, h, panel.m_bgColor or self.panel_transback )
			
		end    

	end

	/*---------------------------------------------------------
		SysButton
	---------------------------------------------------------*/
	function SKIN:PaintSysButton( panel )

		self:PaintButton( panel )
		self:PaintOverButton( panel ) // Border

	end

	function SKIN:SchemeSysButton( panel )

		panel:SetFont( "Marlett" )
		DLabel.ApplySchemeSettings( panel )
		
	end


	/*---------------------------------------------------------
		ImageButton
	---------------------------------------------------------*/
	function SKIN:PaintImageButton( panel )

		self:PaintButton( panel )

	end

	/*---------------------------------------------------------
		ImageButton
	---------------------------------------------------------*/
	function SKIN:PaintOverImageButton( panel )

		self:PaintOverButton( panel )

	end
	function SKIN:LayoutImageButton( panel )

		if ( panel.m_bBorder ) then
			panel.m_Image:SetPos( 1, 1 )
			panel.m_Image:SetSize( panel:GetWide()-2, panel:GetTall()-2 )
		else
			panel.m_Image:SetPos( 0, 0 )
			panel.m_Image:SetSize( panel:GetWide(), panel:GetTall() )
		end

	end

	/*---------------------------------------------------------
		PaneList
	---------------------------------------------------------*/
	function SKIN:PaintPanelList( panel )

		if ( panel.m_bBackground ) then
			draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall(), self.bg_color_dark )
		end

	end

	--[[---------------------------------------------------------
		Button
	-----------------------------------------------------------]]
	function SKIN:PaintWindowCloseButton( panel, w, h )

		if ( !panel.m_bBackground ) then return end
		
		if ( panel:GetDisabled() ) then
			return self.tex.Window.Close( 0, 0, w, h, Color( 255, 255, 255, 50 ) );    
		end    
		
		if ( panel.Depressed || panel:IsSelected() ) then
			return self.tex.Window.Close_Down( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Window.Close_Hover( 0, 0, w, h );    
		end
				
		self.tex.Window.Close( 0, 0, w, h );

	end


	function SKIN:PaintWindowMinimizeButton( panel, w, h )

		if ( !panel.m_bBackground ) then return end
		
		if ( panel:GetDisabled() ) then
			return self.tex.Window.Mini( 0, 0, w, h, Color( 255, 255, 255, 50 ) );    
		end    
		
		if ( panel.Depressed || panel:IsSelected() ) then
			return self.tex.Window.Mini_Down( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Window.Mini_Hover( 0, 0, w, h );    
		end
				
		self.tex.Window.Mini( 0, 0, w, h );

	end

	function SKIN:PaintWindowMaximizeButton( panel, w, h )

		if ( !panel.m_bBackground ) then return end
		
		if ( panel:GetDisabled() ) then
			return self.tex.Window.Maxi( 0, 0, w, h, Color( 255, 255, 255, 50 ) );    
		end    
		
		if ( panel.Depressed || panel:IsSelected() ) then
			return self.tex.Window.Maxi_Down( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Window.Maxi_Hover( 0, 0, w, h );    
		end
				
		self.tex.Window.Maxi( 0, 0, w, h );

	end

	/*---------------------------------------------------------
		ScrollBar
	---------------------------------------------------------*/
	function SKIN:PaintVScrollBar( panel, w, h )

		surface.SetDrawColor( self.bg_color_sleep )
		surface.DrawRect( 0, 0, w, h )

	end

	function SKIN:LayoutVScrollBar( panel )

		local Wide = panel:GetWide()
		local Scroll = panel:GetScroll() / panel.CanvasSize
		local BarSize = math.max( panel:BarScale() * (panel:GetTall() - (Wide * 2)), 10 )
		local Track = panel:GetTall() - (Wide * 2) - BarSize
		Track = Track + 1
		
		Scroll = Scroll * Track
		
		panel.btnGrip:SetPos( 0, Wide + Scroll )
		panel.btnGrip:SetSize( Wide, BarSize )
		
		panel.btnUp:SetPos( 0, 0, Wide, Wide )
		panel.btnUp:SetSize( Wide, Wide )
		
		panel.btnDown:SetPos( 0, panel:GetTall() - Wide, Wide, Wide )
		panel.btnDown:SetSize( Wide, Wide )

	end

	/*---------------------------------------------------------
		ScrollBarGrip
	---------------------------------------------------------*/
	function SKIN:PaintScrollBarGrip( panel, w, h )
		
		local col = self.control_color
		
		if ( panel.Depressed ) then
			col = self.control_color_active
		elseif ( panel.Hovered ) then
			col = self.control_color_highlight
		end
			
		draw.RoundedBox( 2, 0, 0, w, h, Color( 0, 0, 0, 230 ) )
		draw.RoundedBox( 2, 1, 1, w-2, h-2, Color( col.r + 30, col.g + 30, col.b + 30 ) )
		draw.RoundedBox( 2, 2, 2, w-4, h-4, col )
			
		draw.RoundedBox( 0, 3, h*0.5, w-6, h-h*0.5-2, Color( 0, 0, 0, 25 ) )

	end

	--[[---------------------------------------------------------
		ButtonDown
	-----------------------------------------------------------]]
	function SKIN:PaintButtonDown( panel, w, h )

		if ( !panel.m_bBackground ) then return end
		
		if ( panel.Depressed || panel:IsSelected() ) then
			self.tex.Scroller.DownButton_Down( 0, 0, w, h );    
		end    
		
		if ( panel:GetDisabled() ) then
			self.tex.Scroller.DownButton_Dead( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			self.tex.Scroller.DownButton_Hover( 0, 0, w, h );    
		end
				
		self.tex.Scroller.DownButton_Normal( 0, 0, w, h );
	end


	function SKIN:PaintMenu( panel )

		surface.SetDrawColor( self.colMenuBG )
		panel:DrawFilledRect( 0, 0, w, h )

	end
	function SKIN:PaintOverMenu( panel )

		surface.SetDrawColor( self.colMenuBorder )
		panel:DrawOutlinedRect( 0, 0, w, h )

	end
	function SKIN:LayoutMenu( panel )

		local w = panel:GetMinimumWidth()
		
		// Find the widest one
		if panel.Panels then
			for k, pnl in pairs( panel.Panels ) do
			
				pnl:PerformLayout()
				w = math.max( w, pnl:GetWide() )
			
			end
		else
			w = panel:GetWide() or 40
		end
		
		panel:SetWide( w )
		
		local y = 0
		
		if panel.Panels then
			for k, pnl in pairs( panel.Panels ) do
			
				pnl:SetWide( w )
				pnl:SetPos( 0, y )
				pnl:InvalidateLayout( true )
				
				y = y + pnl:GetTall()
			
			end
		else
			y = panel:GetTall() or 100
		end
		
		panel:SetTall( y )

	end

	/*---------------------------------------------------------
		ScrollBar
	---------------------------------------------------------*/
	function SKIN:PaintMenuOption( panel )

		if ( panel.m_bBackground && panel.Hovered ) then
		
			local col = nil
			
			if ( panel.Depressed ) then
				col = self.control_color_bright
			else
				col = self.control_color_active
			end
			
			surface.SetDrawColor( col.r, col.g, col.b, col.a )
			surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() )
		
		end
		
	end
	function SKIN:LayoutMenuOption( panel )

		// This is totally messy. :/

		panel:SizeToContents()

		panel:SetWide( panel:GetWide() + 30 )
		
		local w = math.max( panel:GetParent():GetWide(), panel:GetWide() )

		panel:SetSize( w, 18 )
		
		if ( panel.SubMenuArrow ) then
		
			panel.SubMenuArrow:SetSize( panel:GetTall(), panel:GetTall() )
			panel.SubMenuArrow:CenterVertical()
			panel.SubMenuArrow:AlignRight()
			
		end
		
	end
	function SKIN:SchemeMenuOption( panel )

		panel:SetFGColor( 40, 40, 40, 255 )
		
	end

	--[[---------------------------------------------------------
		MenuRightArrow
	-----------------------------------------------------------]]
	function SKIN:PaintMenuRightArrow( panel, w, h )
		
		self.tex.Menu.RightArrow( 0, 0, w, h );

	end

	/*---------------------------------------------------------
		TextEntry
	---------------------------------------------------------*/
	function SKIN:PaintTextEntry( panel )

		if ( panel.m_bBackground ) then
		
			surface.SetDrawColor( self.colTextEntryBG )
			surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() )
		
		end
		
		panel:DrawTextEntryText( panel.m_colText, panel.m_colHighlight, panel.m_colCursor )
		
		if ( panel.m_bBorder ) then
		
			surface.SetDrawColor( self.colTextEntryBorder )
			surface.DrawOutlinedRect( 0, 0, panel:GetWide(), panel:GetTall() )
		
		end

		
	end
	function SKIN:SchemeTextEntry( panel )

		panel:SetTextColor( self.colTextEntryText )
		panel:SetHighlightColor( self.colTextEntryTextHighlight )
		panel:SetCursorColor( Color( 0, 0, 100, 255 ) )

	end

	/*---------------------------------------------------------
		Label
	---------------------------------------------------------*/
	--[[function SKIN:PaintLabel( panel )
		return false
	end

	function SKIN:SchemeLabel( panel )

		local col = nil

		if ( panel.Hovered && panel:GetTextColorHovered() ) then
			col = panel:GetTextColorHovered()
		else
			col = panel:GetTextColor()
		end
		
		if ( col ) then
			panel:SetFGColor( col.r, col.g, col.b, col.a )
		else
			panel:SetFGColor( 200, 200, 200, 255 )
		end

	end

	function SKIN:LayoutLabel( panel )

		panel:ApplySchemeSettings()
		
		if ( panel.m_bAutoStretchVertical ) then
			panel:SizeToContentsY()
		end
		
	end]]

	/*---------------------------------------------------------
		CategoryHeader
	---------------------------------------------------------*/
	function SKIN:PaintCategoryHeader( panel )
			
	end

	function SKIN:SchemeCategoryHeader( panel )
		
		panel:SetTextInset( 5 )
		panel:SetFont( self.fontCategoryHeader )
		
		if ( panel:GetParent():GetExpanded() ) then
			panel:SetTextColor( self.colCategoryText )
		else
			panel:SetTextColor( self.colCategoryTextInactive )
		end
		
	end

	/*---------------------------------------------------------
		CategoryHeader
	---------------------------------------------------------*/
	function SKIN:PaintCollapsibleCategory( panel )
		
		draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall(), self.colCollapsibleCategory )
		
	end

	function SKIN:PaintCategoryList( panel, w, h )

		self.tex.CategoryList.Outer( 0, 0, w, h );

	end

	/*---------------------------------------------------------
		Tab
	---------------------------------------------------------*/
	function SKIN:PaintTab( panel )

		if ( panel:GetPropertySheet():GetActiveTab() == panel ) then
			draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow )
			draw.RoundedBox( 4, 1, 1, panel:GetWide()-2, panel:GetTall() + 8, self.colTab )
		else
			draw.RoundedBox( 4, 0, 1, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow )
			draw.RoundedBox( 4, 1, 2, panel:GetWide()-2, panel:GetTall() + 8, self.colTabInactive  )
		end
		
	end
	function SKIN:SchemeTab( panel )

		panel:SetFont( self.fontTab )

		local ExtraInset = 10

		if ( panel.Image ) then
			ExtraInset = ExtraInset + panel.Image:GetWide()
		end
		
		panel:SetTextInset( ExtraInset )
		panel:SizeToContents()
		panel:SetSize( panel:GetWide() + 10, panel:GetTall() + 8 )
		
		local Active = panel:GetPropertySheet():GetActiveTab() == panel
		
		if ( Active ) then
			panel:SetTextColor( self.colTabText )
		else
			panel:SetTextColor( self.colTabTextInactive )
		end
		
		panel.BaseClass.ApplySchemeSettings( panel )
			
	end

	function SKIN:LayoutTab( panel )

		panel:SetTall( 22 )

		if ( panel.Image ) then
		
			local Active = panel:GetPropertySheet():GetActiveTab() == panel
			
			local Diff = panel:GetTall() - panel.Image:GetTall()
			panel.Image:SetPos( 7, Diff * 0.6 )
			
			if ( !Active ) then
				panel.Image:SetImageColor( Color( 170, 170, 170, 155 ) )
			else
				panel.Image:SetImageColor( Color( 255, 255, 255, 255 ) )
			end
		
		end    
		
	end



	/*---------------------------------------------------------
		PropertySheet
	---------------------------------------------------------*/
	function SKIN:PaintPropertySheet( panel )

		local ActiveTab = panel:GetActiveTab()
		local Offset = 0
		if ( ActiveTab ) then Offset = ActiveTab:GetTall() end
		
		// This adds a little shadow to the right which helps define the tab shape..
		draw.RoundedBox( 4, 0, Offset, panel:GetWide(), panel:GetTall()-Offset, self.colPropertySheet )
		
	end

	/*---------------------------------------------------------
		ListView
	---------------------------------------------------------*/
	function SKIN:PaintListView( panel )

		if ( panel.m_bBackground ) then
			surface.SetDrawColor( 50, 50, 50, 255 )
			panel:DrawFilledRect()
		end
		
	end
		
	/*---------------------------------------------------------
		ListViewLine
	---------------------------------------------------------*/
	function SKIN:PaintListViewLine( panel )

		local Col = nil
		
		if ( panel:IsSelected() ) then
		
			Col = self.listview_selected
			
		elseif ( panel.Hovered ) then
		
			Col = self.listview_hover
			
		elseif ( panel.m_bAlt ) then
		
			Col = self.bg_alt2
			
		else
		
			return
					
		end
			
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() )
		
	end


	/*---------------------------------------------------------
		ListViewLabel
	---------------------------------------------------------*/
	function SKIN:SchemeListViewLabel( panel )

		panel:SetTextInset( 3 )
		panel:SetTextColor( Color( 255, 255, 255, 255 ) ) 
			
	end



	/*---------------------------------------------------------
		Form
	---------------------------------------------------------*/
	function SKIN:PaintForm( panel )

		local color = self.bg_color_sleep

		self:DrawGenericBackground( 0, 9, panel:GetWide(), panel:GetTall()-9, self.bg_color )

	end
	function SKIN:SchemeForm( panel )

		panel.Label:SetFont( "TabLarge" )
		panel.Label:SetTextColor( Color( 255, 255, 255, 255 ) )

	end
	function SKIN:LayoutForm( panel )

	end


	/*---------------------------------------------------------
		MultiChoice
	---------------------------------------------------------*/
	function SKIN:LayoutMultiChoice( panel )

		panel.TextEntry:SetSize( panel:GetWide(), panel:GetTall() )
		
		panel.DropButton:SetSize( panel:GetTall(), panel:GetTall() )
		panel.DropButton:SetPos( panel:GetWide() - panel:GetTall(), 0 )
		
		panel.DropButton:SetZPos( 1 )
		panel.DropButton:SetDrawBackground( false )
		panel.DropButton:SetDrawBorder( false )
		
		panel.DropButton:SetTextColor( Color( 30, 100, 200, 255 ) )
		panel.DropButton:SetTextColorHovered( Color( 50, 150, 255, 255 ) )
		
	end


	/*
	NumberWangIndicator
	*/

	function SKIN:DrawNumberWangIndicatorText( panel, wang, x, y, number, alpha )

		local alpha = math.Clamp( alpha ^ 0.5, 0, 1 ) * 255
		local col = self.text_dark
		
		// Highlight round numbers
		local dec = (wang:GetDecimals() + 1) * 10
		if ( number / dec == math.ceil( number / dec ) ) then
			col = self.text_highlight
		end

		draw.SimpleText( number, "Default", x, y, Color( col.r, col.g, col.b, alpha ) )
		
	end



	function SKIN:PaintNumberWangIndicator( panel )
		
		/*
		
			Please excuse the crudeness of this code.
		
		*/

		if ( panel.m_bTop ) then
			surface.SetMaterial( self.texGradientUp )
		else
			surface.SetMaterial( self.texGradientDown )
		end
		
		surface.SetDrawColor( self.colNumberWangBG )
		surface.DrawTexturedRect( 0, 0, panel:GetWide(), panel:GetTall() )
		
		local wang = panel:GetWang()
		local CurNum = math.floor( wang:GetFloatValue() )
		local Diff = CurNum - wang:GetFloatValue()
			
		local InsetX = 3
		local InsetY = 5
		local Increment = wang:GetTall()
		local Offset = Diff * Increment
		local EndPoint = panel:GetTall()
		local Num = CurNum
		local NumInc = 1
		
		if ( panel.m_bTop ) then
		
			local Min = wang:GetMin()
			local Start = panel:GetTall() + Offset
			local End = Increment * -1
			
			CurNum = CurNum + NumInc
			for y = Start, Increment * -1, End do
		
				CurNum = CurNum - NumInc
				if ( CurNum < Min ) then break end
						
				self:DrawNumberWangIndicatorText( panel, wang, InsetX, y + InsetY, CurNum, y / panel:GetTall() )
			
			end
		
		else
		
			local Max = wang:GetMax()
			
			for y = Offset - Increment, panel:GetTall(), Increment do
				
				self:DrawNumberWangIndicatorText( panel, wang, InsetX, y + InsetY, CurNum, 1 - ((y+Increment) / panel:GetTall()) )
				
				CurNum = CurNum + NumInc
				if ( CurNum > Max ) then break end
			
			end
		
		end
		

	end

	function SKIN:LayoutNumberWangIndicator( panel )

		panel.Height = 200

		local wang = panel:GetWang()
		local x, y = wang:LocalToScreen( 0, wang:GetTall() )
		
		if ( panel.m_bTop ) then
			y = y - panel.Height - wang:GetTall()
		end
		
		panel:SetPos( x, y )
		panel:SetSize( wang:GetWide() - wang.Wanger:GetWide(), panel.Height)

	end

	/*---------------------------------------------------------
		CheckBox
	---------------------------------------------------------*/
	function SKIN:PaintCheckBox( panel, w, h )

		if ( panel:GetChecked() ) then
		
			if ( panel:GetDisabled() ) then
				self.tex.CheckboxD_Checked( 0, 0, w, h )
			else
				self.tex.Checkbox_Checked( 0, 0, w, h )
			end
			
		else
		
			if ( panel:GetDisabled() ) then
				self.tex.CheckboxD( 0, 0, w, h )
			else
				self.tex.Checkbox( 0, 0, w, h )
			end
			
		end
	end

	/*---------------------------------------------------------
		Slider
	---------------------------------------------------------*/
	function SKIN:PaintSlider( panel )

	end


	/*---------------------------------------------------------
		NumSlider
	---------------------------------------------------------*/
	function SKIN:PaintNumSlider( panel )

		local w, h = panel:GetSize()
		
		self:DrawGenericBackground( 0, 0, w, h, Color( 255, 255, 255, 20 ) )
		
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( 3, h/2, w-6, 1 )
		
	end


	/*---------------------------------------------------------
		NumSlider
	---------------------------------------------------------*/
	function SKIN:PaintComboBoxItem( panel )

		if ( panel:GetSelected() ) then
			local col = self.combobox_selected
			surface.SetDrawColor( col.r, col.g, col.b, col.a )
			panel:DrawFilledRect()
		end

	end

	function SKIN:SchemeComboBoxItem( panel )
		panel:SetTextColor( Color( 0, 0, 0, 255 ) )
	end

	--[[---------------------------------------------------------
		ButtonUp
	-----------------------------------------------------------]]
	function SKIN:PaintButtonUp( panel, w, h )

		if ( !panel.m_bBackground ) then return end
		
		if ( panel.Depressed || panel:IsSelected() ) then
			return self.tex.Scroller.UpButton_Down( 0, 0, w, h );    
		end    
		
		if ( panel:GetDisabled() ) then
			return self.tex.Scroller.UpButton_Dead( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Scroller.UpButton_Hover( 0, 0, w, h );    
		end
				
		self.tex.Scroller.UpButton_Normal( 0, 0, w, h );

	end

	--[[---------------------------------------------------------
		ComboDownArrow
	-----------------------------------------------------------]]
	function SKIN:PaintComboDownArrow( panel, w, h )

		if ( panel.ComboBox:GetDisabled() ) then
			return self.tex.Input.ComboBox.Button.Disabled( 0, 0, w, h );    
		end    
		
		if ( panel.ComboBox.Depressed || panel.ComboBox:IsMenuOpen() ) then
			return self.tex.Input.ComboBox.Button.Down( 0, 0, w, h );    
		end    
		
		if ( panel.ComboBox.Hovered ) then
			return self.tex.Input.ComboBox.Button.Hover( 0, 0, w, h );    
		end
				
		self.tex.Input.ComboBox.Button.Normal( 0, 0, w, h );

	end

	/*---------------------------------------------------------
		ComboBox
	---------------------------------------------------------*/
	function SKIN:PaintComboBox( panel )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		panel:DrawFilledRect()
			
		surface.SetDrawColor( 0, 0, 0, 255 )
		panel:DrawOutlinedRect()
		
	end

	--[[---------------------------------------------------------
		ListBox
	-----------------------------------------------------------]]
	function SKIN:PaintListBox( panel, w, h )
		
		self.tex.Input.ListBox.Background( 0, 0, w, h );
		
	end

	--[[---------------------------------------------------------
		NumberUp
	-----------------------------------------------------------]]
	function SKIN:PaintNumberUp( panel, w, h )

		if ( panel:GetDisabled() ) then
			return self.Input.UpDown.Up.Disabled( 0, 0, w, h );    
		end    
		
		if ( panel.Depressed ) then
			return self.tex.Input.UpDown.Up.Down( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Input.UpDown.Up.Hover( 0, 0, w, h );    
		end
				
		self.tex.Input.UpDown.Up.Normal( 0, 0, w, h );
		
	end

	--[[---------------------------------------------------------
		NumberDown
	-----------------------------------------------------------]]
	function SKIN:PaintNumberDown( panel, w, h )

		if ( panel:GetDisabled() ) then
			return self.tex.Input.UpDown.Down.Disabled( 0, 0, w, h );    
		end    
		
		if ( panel.Depressed ) then
			return self.tex.Input.UpDown.Down.Down( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Input.UpDown.Down.Hover( 0, 0, w, h );    
		end
				
		self.tex.Input.UpDown.Down.Normal( 0, 0, w, h );
		
	end

	/*---------------------------------------------------------
		ScrollBar
	---------------------------------------------------------*/
	function SKIN:PaintBevel( panel )

		local w, h = panel:GetSize()

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, w-1, h-1)
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutlinedRect( 1, 1, w-1, h-1)

	end


	/*---------------------------------------------------------
		Tree
	---------------------------------------------------------*/
	function SKIN:PaintTree( panel )

		if ( panel.m_bBackground ) then
			surface.SetDrawColor( self.bg_color_bright.r, self.bg_color_bright.g, self.bg_color_bright.b, self.bg_color_bright.a )
			panel:DrawFilledRect()
		end

	end



	/*---------------------------------------------------------
		TinyButton
	---------------------------------------------------------*/
	function SKIN:PaintTinyButton( panel )

		if ( panel.m_bBackground ) then
		
			surface.SetDrawColor( 255, 255, 255, 255 )
			panel:DrawFilledRect()
		
		end
		
		if ( panel.m_bBorder ) then

			surface.SetDrawColor( 0, 0, 0, 255 )
			panel:DrawOutlinedRect()
		
		end

	end

	function SKIN:SchemeTinyButton( panel )

		panel:SetFont( "Default" )
		
		if ( panel:GetDisabled() ) then
			panel:SetTextColor( Color( 0, 0, 0, 50 ) )
		else
			panel:SetTextColor( Color( 0, 0, 0, 255 ) )
		end
		
		DLabel.ApplySchemeSettings( panel )
		
		panel:SetFont( "DefaultSmall" )

	end

	/*---------------------------------------------------------
		TinyButton
	---------------------------------------------------------*/
	function SKIN:PaintTreeNodeButton( panel )

		if ( panel.m_bSelected ) then

			surface.SetDrawColor( 50, 200, 255, 150 )
			panel:DrawFilledRect()
		
		elseif ( panel.Hovered ) then

			surface.SetDrawColor( 255, 255, 255, 100 )
			panel:DrawFilledRect()
		
		end
		
		

	end

	function SKIN:SchemeTreeNodeButton( panel )

		DLabel.ApplySchemeSettings( panel )

	end

	function SKIN:PaintSliderKnob( panel, w, h )

		if ( panel:GetDisabled() ) then    return self.tex.Input.Slider.H.Disabled( 0, 0, w, h ); end    
		
		if ( panel.Depressed ) then
			return self.tex.Input.Slider.H.Down( 0, 0, w, h );    
		end    
		
		if ( panel.Hovered ) then
			return self.tex.Input.Slider.H.Hover( 0, 0, w, h );    
		end
				
		self.tex.Input.Slider.H.Normal( 0, 0, w, h );

	end

	/*---------------------------------------------------------
		Tooltip
	---------------------------------------------------------*/
	function SKIN:PaintTooltip( panel, w, h )

		--local w, h = panel:GetSize()
		
		DisableClipping( true )
		
		// This isn't great, but it's not like we're drawing 1000's of tooltips all the time
		for i=1, 4 do
		
			local BorderSize = i*2
			local BGColor = Color( 0, 0, 0, (255 / i) * 0.3 )
			
			self:DrawGenericBackground( BorderSize, BorderSize, w, h, BGColor )
			--panel:DrawArrow( BorderSize, BorderSize )
			self:DrawGenericBackground( -BorderSize, BorderSize, w, h, BGColor )
			--panel:DrawArrow( -BorderSize, BorderSize )
			self:DrawGenericBackground( BorderSize, -BorderSize, w, h, BGColor )
			--panel:DrawArrow( BorderSize, -BorderSize )
			self:DrawGenericBackground( -BorderSize, -BorderSize, w, h, BGColor )
			--panel:DrawArrow( -BorderSize, -BorderSize )
			
		end


		self:DrawGenericBackground( 0, 0, w, h, self.tooltip )
		--panel:DrawArrow( 0, 0 )

		DisableClipping( false )
	end

	/*---------------------------------------------------------
		VoiceNotify
	---------------------------------------------------------*/

	function SKIN:PaintVoiceNotify( panel )

		local w, h = panel:GetSize()
		
		self:DrawGenericBackground( 0, 0, w, h, panel.Color )
		self:DrawGenericBackground( 1, 1, w-2, h-2, Color( 60, 60, 60, 240 ) )

	end

	function SKIN:SchemeVoiceNotify( panel )

		panel.LabelName:SetFont( "TabLarge" )
		panel.LabelName:SetContentAlignment( 4 )
		panel.LabelName:SetColor( color_white )
		
		panel:InvalidateLayout()
		
	end

	function SKIN:LayoutVoiceNotify( panel )

		panel:SetSize( 200, 40 )
		panel.Avatar:SetPos( 4, 4 )
		panel.Avatar:SetSize( 32, 32 )
		
		panel.LabelName:SetPos( 44, 0 )
		panel.LabelName:SizeToContents()
		panel.LabelName:CenterVertical()

	end

	function SKIN:PaintMenuBar( panel, w, h )

		self.tex.Menu_Strip( 0, 0, w, h )

	end

	derma.DefineSkin( "LiquidDRP2", "Made for LiquidDRP V2", SKIN )
	derma.RefreshSkins()
end

RefreshSkin()

function Set_Liquid_Skin(Skin)
	LDRP_Theme.CurrentSkin = Skin
	RefreshSkin()
end
