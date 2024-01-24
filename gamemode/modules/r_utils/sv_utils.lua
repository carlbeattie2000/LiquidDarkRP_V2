sUtils = sUtils or {}

function sUtils.playerIsValid(ply)
  return IsValid(ply) and ply:IsPlayer();
end
