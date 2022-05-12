include("shared.lua")

local camStart3D2D = cam.Start3D2D
local camEnd3D2D = cam.End3D2D
local drawWordBox = draw.WordBox
local IsValid = IsValid


function format_int(number)

  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

surface.CreateFont( "moneyFont", {
	font = "Trebuchet24", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 50,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

function ENT:Draw()

	self:DrawModel()
	self:SetMaterial("models/shiny")

  local distance = self:GetPos():Distance( LocalPlayer():GetPos() )

  local Pos = self:GetPos()
  local Ang = self:GetAngles()

  
  if (distance > 300) then
    return
  end

  -- self:Getmoney()
  -- draw.RoundedBox(borderRadius, 0, 0, w, h, Color(255, 255, 255, 255))
  -- draw.SimpleText(test, "DermaDefault", x, y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

  Ang:RotateAroundAxis(Ang:Up(), 90)

  camStart3D2D(Pos + Ang:Up() * 6, Ang, 0.08)

    draw.RoundedBox( 5, -100, -150, 200, 100, Color (213, 100, 100, 100))

    draw.SimpleText("$"..format_int(self:Getmoney()), "moneyFont",0, -100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   
  camEnd3D2D()
  
end

local changeColorTimer = CurTime()

local colors = {
  Color(255, 0, 0, 255),
  Color(0, 255, 0, 255),
  Color(0, 0, 255, 255)
}

function ENT:Think()

  if CurTime() > changeColorTimer + .5 then

    self:SetColor(colors[math.random(#colors)])

    changeColorTimer = CurTime()
  
  end


end