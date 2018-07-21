// Bomb logic

#include "Hitters.as";
#include "ClusterBombCommon.as";
#include "ShieldCommon.as";

const s32 bomb_fuse = 120;

void onInit(CBlob@ this)
{
	this.set_f32("explosive_damage",0.5f);	
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
	SetupBomb(this, bomb_fuse, 48.0f, 3.0f, 24.0f, 0.4f, true);
	//
	this.Tag("activated"); // make it lit already and throwable
}

//start ugly bomb logic :)

void set_delay(CBlob@ this, string field, s32 delay)
{
	this.set_s32(field, getGameTime() + delay);
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f vel = blob.getVelocity();

	s32 timer = blob.get_s32("bomb_timer") - getGameTime();

	if (timer < 0)
	{
		return;
	}

	if (timer > 30)
	{
		this.SetAnimation("default");
		this.animation.frame = this.animation.getFramesCount() * (1.0f - ((timer - 30) / 220.0f));
	}
	else
	{
		this.SetAnimation("shes_gonna_blow");
		this.animation.frame = this.animation.getFramesCount() * (1.0f - (timer / 30.0f));

		if (timer < 15 && timer > 0)
		{
			f32 invTimerScale = (1.0f - (timer / 15.0f));
			Vec2f scaleVec = Vec2f(1, 1) * (1.0f + 0.07f * invTimerScale * invTimerScale);
			this.ScaleBy(scaleVec);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is hitterBlob)
	{
		this.set_s32("bomb_timer", 0);
	}

	if (isExplosionHitter(customData))
	{
		return damage; //chain explosion
	}

	return 0.0f;
}

void onDie(CBlob@ this)
{
this.getSprite().SetEmitSoundPaused(true);

		CBlob@ heart = server_CreateBlob( "cluster", this.getTeamNum(), this.getPosition() );

            if (heart !is null)
            {
                Vec2f vel( XORRandom(2) == 0 ? -1.0 : 1.0f, -6.0f );
                heart.setVelocity(vel);
            }
			
			CBlob@ heart1 = server_CreateBlob( "cluster", this.getTeamNum(), this.getPosition() );

            if (heart1 !is null)
            {
                Vec2f vel( XORRandom(2) == 0 ? -2.0 : 2.0f, -7.0f );
                heart1.setVelocity(vel);
            }
			
			CBlob@ heart2 = server_CreateBlob( "cluster", this.getTeamNum(), this.getPosition() );

            if (heart2 !is null)
            {
                Vec2f vel( XORRandom(2) == 0 ? -3.0 : 3.0f, -8.0f );
                heart2.setVelocity(vel);
            }
			
			CBlob@ heart3 = server_CreateBlob( "cluster", this.getTeamNum(), this.getPosition() );

            if (heart3 !is null)
            {
                Vec2f vel( XORRandom(2) == 0 ? -1.5 : 1.5f, -5.0f );
                heart3.setVelocity(vel);
            }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		const u8 hitter = this.get_u8("custom_hitter");

		//all water bombs collide with enemies
		if (hitter == Hitters::water)
			return blob.getTeamNum() != this.getTeamNum();

		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
	{
		return false;
	}

	return true;
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	const u8 hitter = this.get_u8("custom_hitter");
	if (vellen > 1.7f)
	{
		Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
		            "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
	}

	if (!isExplosionHitter(hitter) && !this.isAttached())
	{
		Boom(this);
		if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
		{
			this.Tag("_hit_water");
			Vec2f pos = this.getPosition();
			blob.Tag("force_knock");
		}
	}
}

