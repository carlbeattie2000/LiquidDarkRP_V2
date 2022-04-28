AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 
   
include('shared.lua') 
   
	
function ENT:Initialize() 

 	self:SetUseType( SIMPLE_USE )
 	self:SetHullType( HULL_HUMAN ); 
 	self:SetHullSizeNormal(); 

 	self:SetSolid( SOLID_BBOX )  
 	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NPC )
 	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	
 	self:SetMaxYawSpeed( 5000 )
	self:SetNotSolid( false )
end
