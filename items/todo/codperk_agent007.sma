#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Agent 007"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define RANDOM_MIN 6
#define RANDOM_MAX 8
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MIN 3

new const name[] = "Agent 007";
new const description[] = "Masz 1/%s na natychmiastowe zabicie z p228 i +10 obrazen z niego.";

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value == RANDOM ? random_num(RANDOM_MIN, RANDOM_MAX): value;

	cod_give_weapon(id, CSW_P228);
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_P228);

public cod_item_upgrade(id)
{
	if(itemValue[id] <= VALUE_MIN && VALUE_MIN > 0) return COD_STOP;

	itemValue[id] = max(VALUE_MIN, itemValue[id] + random_num(UPGRADE_MIN, UPGRADE_MAX));
}

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_P228 && random_num(1, itemValue[attacker]) == 1)
	{
		if(random_num(1, itemValue[attacker]) == 1)
		{
			damage = COD_BLOCK;

			cod_kill_player(attacker, victim, damageBits);
		}
		else damage += 10.0;
	}
}

public cod_item_value(id)
	return itemValue[id];