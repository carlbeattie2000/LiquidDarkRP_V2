--include("includes/modules/timer.lua")

--[[---------------------------------------------------------------------------
	Function: StamSkillFromMovement
	Description: This function replaces the old method of giving a player
stamina experience (through a timer seeing if they had changed positions in a
set amount of time) with a new method that will give the player experience
_when_ they move based on how fast they are moving.
-----------------------------------------------------------------------------]]
local oldPosition
local cumDistance = 0
local moveKeys = bit.bor( IN_BACK, IN_MOVELEFT, IN_MOVERIGHT, IN_FORWARD )
local function StamSkillFromMovement( ply, moveData )
	local v_curPos = moveData:GetOrigin()
	if not oldPosition then oldPosition = v_curPos end
	if oldPosition == v_curPos or not ply:KeyDown( moveKeys ) then return end
	local distance = oldPosition:Distance( v_curPos )
	if distance >= 10 then
		oldPosition = v_curPos
		return
	end

	--Walking player seems to move 2.3 units, 3.5 sprinting every time this
	--hook is called.
	cumDistance = cumDistance + distance
	oldPosition = v_curPos
end
hook.Add( "Move", "Increase stamina skill on move", StamSkillFromMovement )

--[[---------------------------------------------------------------------------
	Timer: CalcExpFromWalkSprint
	Description: Calculate the stamina experience that should be gained by the
player based on how much distance (cumDistance) they've covered, then reset
cumDistance.
-----------------------------------------------------------------------------]]
local expCollected = 0
local expScale = 400 --How much the distance value will be scaled back
timer.Create( "CalcExpFromWalkSprint", 1, 0, function() 
	if cumDistance == 0 then return end
	expCollected = expCollected + (cumDistance / expScale)
	cumDistance = 0
	
	if expCollected >= 1 then
		local expToSend = math.Round( expCollected )
		expCollected = expCollected - expToSend
		
		net.Start( "AddStaminaExp" )
			net.WriteInt( expToSend, 8 )
		net.SendToServer()
	end
end )