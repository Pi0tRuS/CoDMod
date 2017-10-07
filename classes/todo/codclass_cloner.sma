/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <colorchat>
#include <engine>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <dhudmessage>

#define OFFSET_PRIMARYWEAPON 116

new const nazwa[] = "Cloner";
new const opis[] = "Tworzy klona majac mniej niz 50HP przy czym staje sie niewidzialny na 20s i zostaje bez broni,^nwtedy moze sie ukryc i po 20s dostaje bronie+50HP !";
new const bronie = 1<<CSW_MP5NAVY | 1<<CSW_HEGRENADE;
new const zdrowie = 20;
new const kondycja = 40;
new const inteligencja = 10;
new const wytrzymalosc = 10;

new bool:ma_klase[33], bool:klon[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1)
	
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Klasa %s zostala stworzona przez CBeebies", nazwa);
	ma_klase[id] = true;
	klon[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	klon[id] = false;
	
	cod_take_weapon(id, CSW_MP5NAVY)
	cod_take_weapon(id, CSW_HEGRENADE)
	
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
	set_user_footsteps(id, 0);
}
	
public client_PreThink(id)
{
	if (!is_user_alive(id) && !is_user_connected(id))
		return PLUGIN_CONTINUE
		
	if (ma_klase[id])
	{
		if (get_user_health(id) <= 50)
		{
			if (klon[id])
			{
				new Float:OriginGracza[3], Float:OriginKlona[3], Float:VBA[3];
				entity_get_vector(id, EV_VEC_origin, OriginGracza);
				VelocityByAim(id, 50, VBA);
		
				VBA[2] = 0.0;
		
				for(new i=0; i < 3; i++)
					OriginKlona[i] = OriginGracza[i]+VBA[i];
		
				new model[55], Float:AngleKlona[3],
		
				SekwencjaKlona = entity_get_int(id, EV_INT_gaitsequence);
				SekwencjaKlona = SekwencjaKlona == 3 || SekwencjaKlona == 4? 1: SekwencjaKlona;
				
				entity_get_string(id, EV_SZ_model, model, 54);
				entity_get_vector(id, EV_VEC_angles, AngleKlona);
		
				AngleKlona[0] = 0.0;
		
				new ent = create_entity("info_target");
		
				entity_set_string(ent, EV_SZ_classname, "Klon");
				entity_set_model(ent, model);
				entity_set_vector(ent, EV_VEC_origin, OriginKlona);
				entity_set_vector(ent, EV_VEC_angles, AngleKlona);
				entity_set_vector(ent, EV_VEC_v_angle, AngleKlona);
				entity_set_int(ent, EV_INT_sequence, SekwencjaKlona);
				entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
				entity_set_size(ent, Float:{-16.0,-16.0, -36.0}, Float:{16.0,16.0, 40.0});
				entity_set_int(ent, EV_INT_iuser1, id);
					
				drop_to_floor(ent);
					
				set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				set_user_footsteps(id, 1);
				
				strip_user_weapons(id);
				set_pdata_int(id, OFFSET_PRIMARYWEAPON, 0);
					
				set_dhudmessage(0, 255, 0, -1.0, 0.65, 2, 6.0, 3.0, 0.1, 1.5, false);
				show_dhudmessage(id, "* Utworzyles klona *^nMasz 20s na ucieczke !");
					
				set_task(20.0, "usun_klona", id);
			}
			klon[id] = false;
		}
	}
	return PLUGIN_HANDLED
}

public usun_klona(id)
{
	remove_entity_name("Klon")
	
	if (ma_klase[id])
	{
		if (!klon[id])
		{
			set_user_health(id, get_user_health(id)+50);
			set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
			set_user_footsteps(id, 0);
			
			cod_give_weapon(id, CSW_MP5NAVY)
			cod_give_weapon(id, CSW_HEGRENADE)
			give_item(id,"ammo_9mm")
			give_item(id,"ammo_9mm")
			give_item(id,"ammo_9mm")
			
			if (get_user_team(id) == 1)
			{
				cod_give_weapon(id, CSW_GLOCK18)
				give_item(id,"ammo_9mm")
				give_item(id,"ammo_9mm")
				give_item(id,"ammo_9mm")
			}
			else
			{
				cod_give_weapon(id, CSW_USP)
				give_item(id,"ammo_45acp")
				give_item(id,"ammo_45acp")
				give_item(id,"ammo_45acp")
			}
				
			set_dhudmessage(205, 255, 0, -1.0, 0.65, 2, 6.0, 3.0, 0.1, 1.5, false)
			show_dhudmessage(id, "* Jestes gotow *^nDostales +50HP oraz bronie !")
		}
	}
}

public Odrodzenie(id)
{
	if (ma_klase[id])
	{
		klon[id] = true;
		set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
		set_user_footsteps(id, 0);
	}	
}

public NowaRunda()
	remove_entity_name("Klon")
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
