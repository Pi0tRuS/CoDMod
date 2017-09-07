#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Adrenalina"
#define VERSION "1.0.4"
#define AUTHOR "O'Zone"

#define NAME "Adrenalina"
#define DESC "Za kazdego fraga dostajesz +%s HP"
#define RANDOM_MIN 40
#define RANDOM_MAX 55
#define UPGRADE_MIN -3
#define UPGRADE_MAX 6

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESC, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_value(id)
	return itemValue[id];

public cod_item_kill(killer, victim)
	cod_add_user_health(killer, itemValue[killer]);