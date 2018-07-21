#include "Hitters.as";
#include "Explosion1.as";
void onInit( CSprite@ this )
{
    //burning sound	    
    this.SetEmitSound("MolotovBurning.ogg");
    this.SetEmitSoundVolume(5.0f);
    this.SetEmitSoundPaused(false);
}

void onInit( CBlob@ this )
{
//    this.Tag("bomberman_style");
//	this.set_f32("map_bomberman_width", 24.0f);
    this.set_f32("explosive_radius", 40.0f);
    this.set_f32("explosive_damage",0.5f);
    this.set_u8("custom_hitter", Hitters::bomb);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
    this.set_f32("map_damage_radius", 20.0f);
    this.set_f32("map_damage_ratio", 0.1f);
    this.set_bool("map_damage_raycast", true);
	this.set_bool("explosive_teamkill", false);
    this.server_SetTimeToDie(40.0f/30);
	this.Tag("exploding");	
}
// void onTick( CBlob@ this )
// {
    //explode on collision with map
    // if (this.isOnMap()) 
    // {
        // this.server_Die();
    // }
// }

//sprite update
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    this.RotateAllBy(5 * vel.x, Vec2f_zero);	 		  
}

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
    // if ((blob.hasTag("solid") || blob.hasTag("door") || blob.hasTag("vehicle") || ( blob.hasTag("player")) && blob.getTeamNum() != this.getTeamNum() ))
         	// this.server_Die();

    // return false;
// } 

void onDie(CBlob@ this)
{
	if (this.hasTag("exploding"))
	{
		if (this.exists("explosive_radius") && this.exists("explosive_damage"))
		{
			Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
		}
	}
}
