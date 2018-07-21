// Standard menu player controls

#include "EmotesCommon.as"
#include "StandardControlsCommon.as"

int zoomLevel = 1; // we can declare a global because this script is just used by myPlayer

void onInit(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
	CBlob@[] blobs;
	this.set("pickup blobs", blobs);
	this.set_u16("hover netid", 0);
	this.set_bool("release click", false);
	this.set_bool("can button tap", true);
	this.addCommandID("pickup");
	this.addCommandID("putin");
	this.addCommandID("getout");
	this.addCommandID("detach");
	this.addCommandID("cycle");

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	//add to the sprite
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.AddScript("StandardControls.as");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (!getNet().isServer())                                // server only!
	{
		return;
	}

	if (cmd == this.getCommandID("putin"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());
		CBlob@ pick = getBlobByNetworkID(params.read_netid());

		if (owner !is null && pick !is null)
		{
			if (!owner.server_PutInInventory(pick))
				owner.server_Pickup(pick);
		}
	}
	else if (cmd == this.getCommandID("pickup"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());
		CBlob@ pick = getBlobByNetworkID(params.read_netid());

		if (owner !is null && pick !is null)
		{
			owner.server_Pickup(pick);
		}
	}
	else if (cmd == this.getCommandID("detach"))
	{
		CBlob@ obj = getBlobByNetworkID(params.read_netid());

		if (obj !is null)
		{
			this.server_DetachFrom(obj);
		}
	}
	else if (cmd == this.getCommandID("getout"))
	{
		if (this.getInventoryBlob() !is null)
		{
			this.getInventoryBlob().server_PutOutInventory(this);
		}
	}
}

bool ClickGridMenu(CBlob@ this, int button)
{
	CGridMenu @gmenu;
	CGridButton @gbutton;
	CBlob @pickBlob = this.getCarriedBlob();

	if (this.ClickGridMenu(button, gmenu, gbutton))   // button gets pressed here - thing get picked up
	{
		if (gmenu !is null)
		{
			// if (gmenu.getName() == this.getInventory().getMenuName() && gmenu.getOwner() !is null)
			{
				if (pickBlob !is null && gbutton is null)    // carrying something, put it in
				{
					server_PutIn(this, gmenu.getOwner(), pickBlob);
				}
				else // take something
				{
					// handled by button cmd   // hardcoded still :/
				}
			}
			return true;
		}
	}

	return false;
}


void ButtonOrMenuClick(CBlob@ this, Vec2f pos, bool clear, bool doClosestClick)
{
	if (!ClickGridMenu(this, 0))
		if (this.ClickInteractButton())
		{
			clear = false;
		}
		else if (doClosestClick)
		{
			if (this.ClickClosestInteractButton(pos, this.getRadius() * 1.0f))
			{
				this.ClearButtons();
				clear = false;
			}
		}

	if (clear)
	{
		this.ClearButtons();
		this.ClearMenus();
	}
}

void onTick(CBlob@ this)
{
	if (getCamera() is null)
	{
		return;
	}
	ManageCamera(this);
  
  if(this.isMyPlayer() && !this.hasTag("dead") ){
		CControls@ controls = getControls();
		if(controls !is null){
			if (controls.isKeyJustPressed(KEY_KEY_B)   )OpenWebsite("https://discord.gg/2YUXWCR");
		}
	}

	// use menu

	if (this.isKeyJustPressed(key_use))
	{
		Tap(this);
		this.set_bool("can button tap", !getHUD().hasMenus());
		this.ClearMenus();
		this.ShowInteractButtons();
		this.set_bool("release click", true);
	}
	else if (this.isKeyJustReleased(key_use))
	{
		if (this.get_bool("release click"))
		{
			ButtonOrMenuClick(this, this.getPosition(), true, isTap(this) && this.get_bool("can button tap"));
		}

		this.ClearButtons();
	}

	CBlob @carryBlob = this.getCarriedBlob();

	// inventory menu

	if (this.getInventory() !is null && this.getTickSinceCreated() > 10)
	{
		if (this.isKeyJustPressed(key_inventory))
		{
			Tap(this);
			this.set_bool("release click", true);
			// this.ClearMenus();

			//  Vec2f center =  getDriver().getScreenCenterPos(); // center of screen
			Vec2f center = getControls().getMouseScreenPos();
			if (this.exists("inventory offset"))
			{
				this.CreateInventoryMenu(center + this.get_Vec2f("inventory offset"));
			}
			else
			{
				this.CreateInventoryMenu(center);
			}

			//getControls().setMousePosition( center );
		}
		else if (this.isKeyJustReleased(key_inventory))
		{
			if (isTap(this, 7))     // tap - put thing in inventory
			{
				if (carryBlob !is null && !carryBlob.hasTag("temp blob"))
				{
					server_PutIn(this, this, carryBlob);
				}
				else
				{
					// send cycle command
					CBitStream params;
					this.SendCommand(this.getCommandID("cycle"), params);
				}

				this.ClearMenus();
				return;
			}
			else // click inventory
			{
				if (this.get_bool("release click"))
				{
					ClickGridMenu(this, 0);
				}

				if (!this.hasTag("dont clear menus"))
				{
					this.ClearMenus();
				}
				else
				{
					this.Untag("dont clear menus");
				}
			}
		}
	}

	// in crate

	if (this.isInInventory())
	{
		if (this.isKeyJustPressed(key_pickup))
		{
			this.SendCommand(this.getCommandID("getout"));
		}

		return;
	}

	// no more stuff possible while in crate...

	// bubble menu

	if (this.isKeyJustPressed(key_bubbles))
	{
		this.CreateBubbleMenu();
		Tap(this);
	}

	/*else dont use this cause menu won't be release/clickable
	if (this.isKeyJustReleased(key_bubbles))
	{
	    this.ClearBubbleMenu();
	} */

	// release action1 to click buttons

	if (getHUD().hasButtons())
	{
		if ((this.isKeyJustPressed(key_action1) /*|| getControls().isKeyJustPressed(KEY_LBUTTON)*/) && !this.isKeyPressed(key_pickup))
		{
			ButtonOrMenuClick(this, this.getAimPos(), false, true);
			this.set_bool("release click", false);
		}
	}

	// clear grid menus on move

	if (!this.isKeyPressed(key_inventory) &&
	        (this.isKeyJustPressed(key_left) || this.isKeyJustPressed(key_right) || this.isKeyJustPressed(key_up) ||
	         this.isKeyJustPressed(key_down) || this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action3))
	   )
	{
		this.ClearMenus();
	}

	//if (this.isKeyPressed(key_action1))
	//{
	//  //server_DropCoins( this.getAimPos(), 100 );
	//  CBlob@ mat = server_CreateBlob( "cata_rock", 0, this.getAimPos());
	//}
}

// show dots on chat

void onDie(CBlob@ this)
{
	set_emote(this, Emotes::off);
}

// CAMERA

void onInit(CSprite@ this)
{
	//backwards compat - tag the blob if we're assigned to the sprite too
	//so if it's not there, the blob can adjust the camera at 30fps at least
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	blob.Tag("60fps_camera");
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || !blob.isMyPlayer()) return;
	//do 60fps camera
	AdjustCamera(blob, true);
}

void AdjustCamera(CBlob@ this, bool is_in_render)
{
	CCamera@ camera = getCamera();
	f32 zoom = camera.targetDistance;

	f32 zoomSpeed = 0.1f;
	if (is_in_render)
	{
		zoomSpeed *= getRenderApproximateCorrectionFactor();
	}

	f32 minZoom = 0.5f; // TODO: make vars
	f32 maxZoom = 2.0f;

	if (zoomLevel == 1 && (this.wasKeyPressed(key_use) || this.wasKeyPressed(key_pickup)))
	{
		zoom = 1.0f;
	}
	f32 zoom_target = 1.0f;
	switch (zoomLevel) {
		case 0: zoom_target = 0.5f; break;
		case 1: zoom_target = 1.0f; break;
		case 2: zoom_target = 2.0f; break;
	}

	if (zoom > zoom_target)
	{
		zoom = Maths::Max(zoom_target, zoom - zoomSpeed);
	}
	else if (zoom < zoom_target)
	{
		zoom = Maths::Min(zoom_target, zoom + zoomSpeed);
	}

	camera.targetDistance = zoom;
}

void ManageCamera(CBlob@ this)
{
	CCamera@ camera = getCamera();
	CControls@ controls = this.getControls();

	// mouse look & zoom
	if ((getGameTime() - this.get_s32("tap_time") > 5) && controls !is null)
	{
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT)))
		{
			if (zoomLevel == 2)
			{
				zoomLevel = 1;
			}
			else if (zoomLevel == 1)
			{
				zoomLevel = 0;
			}
			else if (zoomLevel == 3)
			{
				zoomLevel = 0;
			}

			Tap(this);
		}
		else  if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN)))
		{
			if (zoomLevel == 0)
			{
				zoomLevel = 3;
			}
			else if (zoomLevel == 3)
			{
				zoomLevel = 2;
			}
			else if (zoomLevel == 1)
			{
				zoomLevel = 2;
			}

			Tap(this);
		}
	}

	if (!this.hasTag("60fps_camera"))
	{
		AdjustCamera(this, false);
	}

	f32 zoom = camera.targetDistance;
	bool fixedCursor = true;
	if (zoom < 1.0f)  // zoomed out
	{
		camera.mousecamstyle = 1; // fixed
	}
	else
	{
		// gunner
		if (this.isAttachedToPoint("GUNNER"))
		{
			camera.mousecamstyle = 2;
		}
		else if (g_fixedcamera) // option
		{
			camera.mousecamstyle = 1; // fixed
		}
		else
		{
			camera.mousecamstyle = 2; // soldatstyle
		}
	}

	// camera
	camera.mouseFactor = 0.5f; // doesn't affect soldat cam
}


