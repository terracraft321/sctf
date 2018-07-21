void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 16.0f;

	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 8.0f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.Tag("exploding");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if(this.getDamageOwnerPlayer() is null || this.getTeamNum() != attached.getTeamNum())
	{
		CPlayer@ player = attached.getPlayer();
		if(player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}