/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <engine>
#include <fakemeta> 
#include <fun>
#include <cstrike>
#include <amxmisc>
#include <codmod>

#define AUTHOR "J River"

#define MAX 32			 //Max number of valid player entities

new const perk_name[] = "Nicolas Eye";
new const perk_desc[] = "Mozesz podlozyc kamere";

new player_b_eye[33] = 0		//Ability to place camera
new sprite_line = 0

public plugin_init() 
{
	register_plugin(perk_name, "1.0", AUTHOR);
	
	cod_register_perk(perk_name, perk_desc);
	
	register_think("PlayerCamera","Think_PlayerCamera");
	
}
public cod_perk_enabled(id)
{
	client_print(id, print_chat, "Perk stworzony przez J River")
	player_b_eye[id] = -1		//Ability to place camera
}
public cod_perk_disabled(id)
{
	player_b_eye[id] = 0		//Ability to place camera
}
public plugin_precache()
{ 
	precache_model("models/rpgrocket.mdl")
	sprite_line = precache_model("sprites/dot.spr")

}
public client_PreThink ( id ) 
{
	//USE Button actives USEMAGIC
	if (pev(id,pev_button) & IN_USE )
		Use_Spell(id)
	
	return PLUGIN_CONTINUE	
}
public Use_Spell(id)
{
	if (player_b_eye[id] != 0) item_eye(id)
	return PLUGIN_HANDLED
}
public item_eye(id)
{
	if (player_b_eye[id] == -1)
	{
		//place camera
		new Float:playerOrigin[3]
		entity_get_vector(id,EV_VEC_origin,playerOrigin)
		new ent = create_entity("info_target") 
		entity_set_string(ent, EV_SZ_classname, "PlayerCamera") 
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_NOCLIP) 
		entity_set_int(ent, EV_INT_solid, SOLID_NOT) 
		entity_set_edict(ent, EV_ENT_owner, id)
		entity_set_model(ent, "models/rpgrocket.mdl")  				//Just something
		entity_set_origin(ent,playerOrigin)
		entity_set_int(ent,EV_INT_iuser1,0)		//Viewing through this camera						
		set_rendering (ent,kRenderFxNone, 0,0,0, kRenderTransTexture,0)
		entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01) 
		player_b_eye[id] = ent
	}
	else
	{
		//view through camera or stop viewing
		new ent = player_b_eye[id]
		if (!is_valid_ent(ent))
		{
			attach_view(id,id)
			return PLUGIN_HANDLED
		}
		new viewing = entity_get_int(ent,EV_INT_iuser1)
		
		if (viewing) 
		{	
			entity_set_int(ent,EV_INT_iuser1,0)
			attach_view(id,id)
		}	
		else 
		{
			entity_set_int(ent,EV_INT_iuser1,1)
			attach_view(id,ent)
		}
	}
	
	return PLUGIN_HANDLED
}

/* ==================================================================================================== */

//Called when PlayerCamera thinks
public Think_PlayerCamera(ent)
{
	new id = entity_get_edict(ent,EV_ENT_owner)
	
	//Check if player is still having the item and is still online
	if (!is_valid_ent(id) || player_b_eye[id] == 0 || !is_user_connected(id))
	{
		//remove entity
		if (is_valid_ent(id) && is_user_connected(id)) attach_view(id,id)
		remove_entity(ent)
	}
	else
	{
		//Dont use cpu when not alive anyway or not viewing
		if (!is_user_alive(id))
		{
			entity_set_float(ent,EV_FL_nextthink,halflife_time() + 3.0) 
			return PLUGIN_HANDLED
		}
		
		if (!entity_get_int(ent,EV_INT_iuser1))
		{
			entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.5) 
			return PLUGIN_HANDLED
		}
		
		entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01) 
		
		//Find nearest player to camera
		new Float:pOrigin[3],Float:plOrigin[3],Float:ret[3]
		entity_get_vector(ent,EV_VEC_origin,plOrigin)
		new Float:distrec = 2000.0, winent = -1
		
		for (new i=0; i<MAX; i++) 
		{
			if (is_user_connected(i) && is_user_alive(i))
			{
				entity_get_vector(i,EV_VEC_origin,pOrigin)
				pOrigin[2]+=10.0
				if (trace_line ( 0, plOrigin, pOrigin, ret ) == i && vector_distance(pOrigin,plOrigin) < distrec)
				{
					winent = i
					distrec = vector_distance(pOrigin,plOrigin)
				}
			}	
		}
		
		//Traceline and updown is still revresed
		if (winent > -1)
		{
			new Float:toplayer[3], Float:ideal[3],Float:pOrigin[3]
			entity_get_vector(winent,EV_VEC_origin,pOrigin)
			pOrigin[2]+=10.0
			toplayer[0] = pOrigin[0]-plOrigin[0]
			toplayer[1] = pOrigin[1]-plOrigin[1]
			toplayer[2] = pOrigin[2]-plOrigin[2]
			vector_to_angle ( toplayer, ideal ) 
			ideal[0] = ideal[0]*-1
			entity_set_vector(ent,EV_VEC_angles,ideal)
		}
	}
	
	return PLUGIN_CONTINUE
}

public Create_Line(id,origin1[3],origin2[3],bool:draw)
{
	if (draw)
	{
		message_begin(MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
		write_byte(0)
		write_coord(origin1[0])	// starting pos
		write_coord(origin1[1])
		write_coord(origin1[2])
		write_coord(origin2[0])	// ending pos
		write_coord(origin2[1])
		write_coord(origin2[2])
		write_short(sprite_line)	// sprite index
		write_byte(1)		// starting frame
		write_byte(5)		// frame rate
		write_byte(2)		// life
		write_byte(3)		// line width
		write_byte(0)		// noise
		write_byte(255)	// RED
		write_byte(50)	// GREEN
		write_byte(50)	// BLUE					
		write_byte(155)		// brightness
		write_byte(5)		// scroll speed
		message_end()
	}
	
	new Float:ret[3],Float:fOrigin1[3],Float:fOrigin2[3]
	//So we dont hit ourself
	origin1[2]+=50
	IVecFVec(origin1,fOrigin1)
	IVecFVec(origin2,fOrigin2)
	new hit = trace_line ( 0, fOrigin1, fOrigin2, ret )
	return hit
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/