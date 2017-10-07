/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <ColorChat>

new const nazwa[] = "Kuszownik";
new const opis[] = "Dostaje kusze i 10 beltow, posiada 1 rakiete";
new const bronie = 1<<CSW_AK47;
new const zdrowie = 20;
new const kondycja = 15;
new const inteligencja = 0;
new const wytrzymalosc = 10;
new const niewidzialnosc = 0;
new const bonus_niewidzialnosci = 0;

new bool:ma_kusze[33];
new ilosc_beltow[33];
new poprzedni_belt[33];
new bool:ma_klase[33];
new sprite_blast;
new ilosc_rakiet_gracza[33];
new poprzednia_rakieta_gracza[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "O'Zone");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, niewidzialnosc, bonus_niewidzialnosci);
	
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_touch("Belt", "*" , "DotykBeltu");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	register_touch("rocket", "*" , "DotykRakiety");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	
}
public cod_class_enabled(id)
{
	new dostepna = 25;
	if (cod_get_class_level(id)<dostepna)
	{
		ColorChat(id, GREEN, "[COD:MW]^x01 Aby uzywac tej klasy musisz zdobyc^x04 %i^x01 poziom na dowolnej klasie!", dostepna);
		return COD_STOP;
	}
	ma_klase[id] = true;
	ilosc_beltow[id] = 10;
	ilosc_rakiet_gracza[id] = 1;
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id] = false;
	ilosc_beltow[id] = 0;
	ilosc_rakiet_gracza[id] = 0;
}

public Spawn(id)
{
	if (is_user_alive(id) && ma_klase[id]){
		ilosc_beltow[id] = 10;
		ilosc_rakiet_gracza[id] = 1;
	}
}
public plugin_precache()
{
	precache_model("models/QTM_CodMod/v_crossbow.mdl");
	precache_model("models/QTM_CodMod/belt.mdl");
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");
}
public client_disconnect(id)
{
	new Rakiety = find_ent_by_class(0, "rocket");
	while(Rakiety > 0)
	{
		if (entity_get_edict(Rakiety, EV_ENT_owner) == id)
			remove_entity(Rakiety);
		Rakiety = find_ent_by_class(Rakiety, "rocket");
	}
}
public NowaRunda()
{
	new Rakiety = find_ent_by_class(-1, "rocket");
	while(Rakiety > 0) 
	{
		remove_entity(Rakiety);
		Rakiety = find_ent_by_class(Rakiety, "rocket");	
	}
}
public CurWeapon(id)
{
	new weapon = read_data(2)
	
	if (weapon == CSW_KNIFE && ma_klase[id])
	{
		entity_set_string(id, EV_SZ_viewmodel, "models/QTM_CodMod/v_crossbow.mdl")
		ma_kusze[id] = true;
	}
	else
		ma_kusze[id] = false;
}
public client_PreThink(id)
{
	if ((pev(id,pev_button) & IN_ATTACK) && (ma_kusze[id]))
		StworzBelt(id);
		
	return PLUGIN_CONTINUE;
}
public StworzBelt(id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	if (!ilosc_beltow[id]){
		client_print(id, print_center, "Wykorzystales wszystkie belty!");
		return PLUGIN_CONTINUE;
	}
	
	if (get_gametime() < poprzedni_belt[id]+1.0){
		client_print(id, print_center, "Mozesz strzelac kusza co 1s!");
		return PLUGIN_CONTINUE;
	}
	
	poprzedni_belt[id] = floatround(get_gametime());
	ilosc_beltow[id]--;
	new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];		
	entity_get_vector(id, EV_VEC_v_angle, vAngle);
	entity_get_vector(id, EV_VEC_origin , Origin);
	
	new Ent = create_entity("info_target");
	
	entity_set_string(Ent, EV_SZ_classname, "Belt");
	entity_set_model(Ent, "models/QTM_CodMod/belt.mdl");
	
	vAngle[0] *= -1.0;
	
	entity_set_origin(Ent, Origin);
	entity_set_vector(Ent, EV_VEC_angles, vAngle);
	
	entity_set_int(Ent, EV_INT_effects, 2);
	entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(Ent, EV_ENT_owner, id);
	
	VelocityByAim(id, 1000 , Velocity);
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
	
	return PLUGIN_CONTINUE;
}


public DotykBeltu(ent)
{
	if ( !is_valid_ent(ent))
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 15.0, entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
			continue;
		
		new hp = get_user_health(pid)+1;
		cod_inflict_damage(attacker, pid, float(hp), 0.0, ent, (1<<24));
	}
	remove_entity(ent);
}

public cod_class_skill_used(id)
{
	if (!ilosc_rakiet_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
	}
	else
	{
		if (poprzednia_rakieta_gracza[id] + 2.0 > get_gametime())
		{
			client_print(id, print_center, "Rakiet mozesz uzywac co 2 sekundy!");
		}

		else
		{
			if (is_user_alive(id))
			{
				poprzednia_rakieta_gracza[id] = floatround(get_gametime());
				ilosc_rakiet_gracza[id]--;

				new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];

				entity_get_vector(id, EV_VEC_v_angle, vAngle);
				entity_get_vector(id, EV_VEC_origin , Origin);

				new Ent = create_entity("info_target");

				entity_set_string(Ent, EV_SZ_classname, "rocket");
				entity_set_model(Ent, "models/rpgrocket.mdl");

				vAngle[0] *= -1.0;

				entity_set_origin(Ent, Origin);
				entity_set_vector(Ent, EV_VEC_angles, vAngle);

				entity_set_int(Ent, EV_INT_effects, 2);
				entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
				entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
				entity_set_edict(Ent, EV_ENT_owner, id);

				VelocityByAim(id, 1000 , Velocity);
				entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
			}
		}
	}
}

public DotykRakiety(ent)
{
	if (!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);

	new Float:fOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fOrigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();

	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 190.0, entlist, 32);

	for (new i=0; i < numfound; i++)
	{
		new pid = entlist[i];

		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
			continue;
		cod_inflict_damage(attacker, pid, 55.0, 0.9, ent, (1<<24));
	}
	remove_entity(ent);
}
