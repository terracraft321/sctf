// Vehicle Workshop
// Added Mounted Bow, Light Ballista And Bomb Ball.

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	AddIconToken( "$bombball$", "BombBall.png", Vec2f(16,16), 0 );
	AddIconToken( "$lightballista$", "LightBallista.png", Vec2f(24,16), 6 );
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + Descriptions::catapult, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::catapult);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + Descriptions::ballista, false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::ballista);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + Descriptions::ballista_ammo, false, false);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::ballista_ammo);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", Descriptions::ballista_ammo_upgrade_gold, false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::ballista_ammo_upgrade_gold);
		AddRequirement(s.requirements, "not tech", "bomb ammo", "Bomb Bolt", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Mounted Bow", "$mounted_bow$", "mounted_bow", "$mounted_bow$\n\n\n" + Descriptions::mounted_bow, false, true);
		s.crate_icon = 6;
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Ball", "$bombball$", "bombball", "Explode when drop or launch by catapult.\nDon't hurt allies, but be careful.", false, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 95);
	}
	{
		ShopItem@ s = addShopItem(this, "Light Ballista", "$lightballista$", "lightballista", "$lightballista$\n\n\nCan't shoot bomb ammo, but cheap. Useful to attack enemy and make arrow ladders.", false, true);
		s.crate_icon = 24;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			if (name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
		}
	}
}
