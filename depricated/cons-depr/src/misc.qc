 
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};
//============================================================================

float START_OFF = 1;

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};


/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

void() FireAmbient =
{
	precache_sound ("ambience/fire.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/torchx/torch2.mdl");
	setmodel (self, "progs/torchx/torch2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_tiki_torch (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_tiki_torch =
{
	precache_model ("progs/torchx/torch1.mdl");
	setmodel (self, "progs/torchx/torch1.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_torch_tiki_torch(0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_torch_tiki_torch =
{
	precache_model ("progs/torchx/torch1.mdl");
	setmodel (self, "progs/torchx/torch1.mdl");
	FireAmbient ();
	makestatic (self);
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void(vector org, vector vec) LaunchLaser{};

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "misc/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		
	}
	else
		precache_sound ("misc/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};



/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};


/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic ();
};

.float chann;
.float vol;
.float atten;
.string noise2;
.float cuse;

void() misc_sound_use= 
{

	if(self.noise2)
	{
		if ((self.cuse < 1 ))
		{
			sound (self, self.chann, self.noise, self.vol, self.atten);
			self.cuse = 1;
		}
		else
		{
			sound (self, self.chann, self.noise2, self.vol, self.atten);
			self.cuse = 0;
		}
	}
	else
		sound (self, self.chann, self.noise, self.vol, self.atten);
};

void() misc_sound =
{
if (!self.chann)
self.chann  = 0;
if (!self.vol)
self.vol  = 1;
if (!self.atten)
self.atten  = 1;
if (!self.noise)
self.noise  = "tut/tut1.wav";

precache_sound (self.noise);
self.use = misc_sound_use;
};


void() console_use =
{
if (!self.message )
remove(self);
localcmd(self.message);
};


void() trigger_console =
{
self.use = console_use;
};


.string classmonster;

void()monster_slime_spawn;

void()monster_pirate_spawn;


void() monster_spawn_use =
{

self.cnt -= 1;
local entity monster;
monster = spawn();
setorigin (monster, self.origin + '0 0 64');
monster.classname = self.classmonster;

monster.target = self.target;

if (monster.classname == "monster_slime")
{
monster.skin = self.skin;
monster.think = monster_slime_spawn;
}
if (monster.classmonster == "monster_pirate")
monster.think = monster_pirate_spawn;

monster.nextthink = time + 0.1;

if (self.cnt > 0) 
self.think = monster_spawn_use;
else
self.think = SUB_Remove;

self.nextthink = time + self.wait;
self.use = SUB_Null;
}


void() monster_spawner =
{
if (!self.cnt)
self.cnt = 1;

if (!self.wait)
self.wait = 3;

if (!self.classmonster);
self.classmonster  = "monster_slime";

if (self.classmonster == "monster_slime")
{
	precache_model ("progs/slime.mdl");
	precache_sound ("slime/gib.wav");
	precache_sound ("slime/hit.wav");
	precache_sound ("slime/hitback.wav");
	precache_sound ("slime/movement.wav");
	precache_sound ("slime/die.wav");
}

if (self.classmonster == "monster_pirate")
{
	precache_model ("progs/pirate.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_sound ("pirate/death1.wav");
	precache_sound ("pirate/idle.wav");
	precache_sound ("pirate/pain1.wav");
	precache_sound ("pirate/pain2.wav");
	precache_sound ("pirate/sattck1.wav");
	precache_sound ("pirate/sight1.wav");

	precache_sound ("player/udeath.wav");		// gib death
}	

self.use = monster_spawn_use;

};

void() cdsprite_touch =
{

if (other.classname != "player")
return;
other.ammo_shells += 1;

SUB_UseTargets();
sound (self, CHAN_ITEM,"items/pickup.wav", 1, 1);
	local entity	stemp;
	stemp = self;
	self = other;
	W_SetCurrentAmmo();
	self = stemp;
if(other.ammo_shells >= totalboxes )
centerprint(other, "You Collected All the CD's!\n\n\n Bonus Stage Unlocked!");

remove (self);
};

void()cdsprite_think = 
{
totalboxes = totalboxes + 1;
}

void() cdsprite =
{
precache_model ("progs/cd_col.spr");
precache_sound ("items/pickup.wav");


setmodel (self,"progs/cd_col.spr");
self.solid = SOLID_TRIGGER;
setsize (self, '-8 -8 -8', ' 8 8 8'); 
self.touch = cdsprite_touch;
self.think = cdsprite_think;
self.nextthink = time + random() * 1;
};

void()cditem_touchable =
{
self.touch = cdsprite_touch;
self.think = SUB_Remove;
self.nextthink = time + 30;
};

void(entity ebox) cd_spawn =
{
local entity cditem;


local	float cdc;

cdc = 3;

while (cdc > 0)
{		
	cditem = spawn();
	cditem.target =  ebox.target;
	cditem.origin = ebox.origin + '0 0 24';
	cditem.owner = self;
	setmodel (cditem,"progs/cd_col.spr");
	cditem.solid = SOLID_TRIGGER;
	cditem.movetype = MOVETYPE_TOSS;
	cditem.velocity_x =crandom() * 120; 
	cditem.velocity_y =crandom() * 120; 
	cditem.velocity_z = 75 + crandom() * 150;
	cditem.think= cditem_touchable;
	cditem.nextthink =  time + 1;
	cdc = cdc - 1;
}
};

void(entity ebox, string dmodel) debris_spawn =
{
local entity debris;
	debris = spawn();
	debris.origin = ebox.origin + '0 0 24';
	setmodel (debris,dmodel);
	debris.solid = SOLID_TRIGGER;
	debris.movetype = MOVETYPE_TOSS;
	debris.velocity_x =crandom() * 150; 
	debris.velocity_y =crandom() * 150; 
	debris.velocity_z = 75 + crandom() * 250;
	debris.think= SUB_Remove;
	debris.nextthink =  time + 30;
};

void() box_die =
{
cd_spawn (self);
debris_spawn (self,"progs/cdbox_p1.mdl");
debris_spawn (self,"progs/cdbox_p2.mdl");
debris_spawn (self,"progs/cdbox_p3.mdl");
sound (self, CHAN_ITEM, "misc/box.wav", 1, ATTN_NORM);
remove (self);

};

void() cdbox_counter = 
{
totalboxes = totalboxes + 3;

};

void() cdbox =
{
precache_model ("progs/cd_col.spr");
precache_model ("progs/cdbox.mdl");
precache_sound ("items/pickup.wav");
precache_sound ("misc/box.wav");
//self.noise = "misc/box.wav";

setmodel (self,"progs/cdbox.mdl");
self.solid = SOLID_BBOX;
self.health = 1;
self.takedamage = DAMAGE_YES;
setsize (self, '-12 -12 0', ' 12 12 24'); 
self.th_die = box_die;
self.think = cdbox_counter;
self.nextthink = time + random() * 1;
};

void() static_model =
{
precache_file (self.model);
setmodel (self, self.model);
};

void() cutscene_c1a1 =
{
	precache_model ("progs/c1a1.mdl");
	setmodel (self, "progs/c1a1.mdl");
	makestatic (self);
};