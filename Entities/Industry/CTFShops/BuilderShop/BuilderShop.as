// BuilderShop.as
// Added Outpost, Crate, Resources and Bucket filling.

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	AddIconToken( "$outpost$", "Outpost.png", Vec2f(40,48), 0 );
	InitCosts(); //read from cfg

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem( this, "Outpost", "$outpost$", "outpost", "An outpost, used for cheap spawning/storing/changing class anywhere.", false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 600);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::boulder_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::trampoline_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::drill_stone);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::drill);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::saw_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::crate_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::sponge);
	}
	{
		ShopItem@ s = addShopItem(this, "Wood", "$mat_wood$", "mat_wood", Descriptions::wood, true);//"It's used for building bridges, shops, and more."
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Stone", "$mat_stone$", "mat_stone", Descriptions::stone, true);//"It's used for building defence, trap, and more."
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Gold", "$mat_gold$", "mat_gold", "Buy gold with coins.", true);//"It's used for building advance shops."
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (blob.getName() == "bucket")
		{
			blob.set_u8("filled", 3);
			blob.set_u8("water_delay", 30);
			blob.getSprite().SetAnimation("full");
		}
		else
		{
		CBlob@ b = blob.getCarriedBlob();
			if (b !is null)
			{
				if (b.getName() == "bucket")
				{
				b.set_u8("filled", 3);
				b.set_u8("water_delay", 30);
				b.getSprite().SetAnimation("full");
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
	}
}
