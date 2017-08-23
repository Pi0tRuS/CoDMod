/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <codmod>

#define AUTHOR "J River"

new const perk_name[] = "Bron Z Przemytu";
new const perk_desc[] = "Zadajesz 50% wiecej obrazen z ak\m4";

new ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", AUTHOR);
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
}
public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_AK47);
	cod_give_weapon(id, CSW_M4A1);
	client_print(id, print_chat, "Perk stworzony przez J River")
	ma_perk[id] = true;
}
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AK47);
	cod_take_weapon(id, CSW_M4A1);
	ma_perk[id] = false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(!(damagebits & (1<<1)))
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) != CSW_AK47)
		return HAM_IGNORED;
	
	cod_inflict_damage(idattacker, this, damage*0.5, 0.0, idinflictor, damagebits);
	
	if(get_user_weapon(idattacker) != CSW_M4A1)
		return HAM_IGNORED;
	
	cod_inflict_damage(idattacker, this, damage*0.5, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}