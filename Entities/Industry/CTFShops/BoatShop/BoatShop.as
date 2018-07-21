// BoatShop.as
// Added Bomber.

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	AddIconToken( "$bomber$", "Balloon.png", Vec2f(48,16), 1 );
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// TODO: Better information + icons like the vehicle shop, also make boats not suck
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + Descriptions::dinghy);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::dinghy);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::dinghy_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + Descriptions::longboat, false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::longboat);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::longboat_wood);
		s.crate_icon = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + Descriptions::warboat, false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::warboat);
		s.crate_icon = 2;
	{
		ShopItem@ s = addShopItem(this, "Bomber", "$bomber$", "bomber", "$bomber$\n\n\n" + "Hot Balloon that can carry a siege.\nLeft click to up\nRight click to down", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 300);
	}
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
	}
}