local GetConVar = GetConVar

local var = GetConVar("sv_allowcslua")
local var1 = GetConVar("mat_wireframe")
local var2 = GetConVar("sv_cheats")

timer.Simple(5, function()

  print(var:GetInt())
  print(var1:GetInt())
  print(var2:GetInt())

end)