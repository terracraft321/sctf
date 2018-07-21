// Outpost
// added heavy weight
#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";

void onInit( CBlob@ this )
{
	this.SetLight( true );
    this.SetLightRadius( 16.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );

	this.Tag("respawn");

	InitRespawnCommand( this );
	InitClasses( this );
	this.Tag("change class store inventory");
	this.Tag("heavy weight");

	this.getShape().SetRotationsAllowed( false );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ button = caller.CreateGenericButton( "$change_class$", Vec2f(14,-4), this, SpawnCmd::buildMenu, "Change class", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == SpawnCmd::buildMenu || cmd == SpawnCmd::changeClass)
	{
		onRespawnCommand( this, cmd, params );
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (byBlob.getTeamNum() == this.getTeamNum());
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return ( forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this) );
}