#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Intelekt O'Zone"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define RANDOM_MIN 6
#define RANDOM_MAX 8
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MIN 3

new const name[] = "Intelekt O'Zone";
new const description[] = "Masz 1/%s szansy na zmiane trajektorii lotu kuli na glowe przy trafieniu";

new itemValue[MAX_PLAYERS + 1], hasItem;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);

	register_forward(FM_TraceLine, "trace_line");
	register_forward(FM_TraceHull, "trace_hull", 1);
}

public cod_item_enabled(id, value)
{
	set_bit(id, hasItem);

	itemValue[id] = value == RANDOM ? random_num(RANDOM_MIN, RANDOM_MAX): value;
}

public cod_item_disabled(id)
	rem_bit(id, hasItem);

public cod_item_upgrade(id)
{
	if(itemValue[id] <= VALUE_MIN) return COD_STOP;

	itemValue[id] = max(VALUE_MIN, itemValue[id] + random_num(UPGRADE_MIN, UPGRADE_MAX));
}

public cod_item_value(id)
	return itemValue[id];

public trace_line(Float:startVector[3], Float:endVector[3], conditions, id, trace)
	return process_trace(id, trace);

public trace_hull(Float:startVector[3], Float:endVector[3], conditions, hull, id, trace)
	return process_trace(id, trace);

public process_trace(id, trace)
{
	if(!is_user_alive(id) || !(get_bit(id, hasItem)) || random_num(1, itemValue[id]) != 1) return FMRES_IGNORED;
	
	static ent; ent = get_tr2(trace, TR_pHit);
	
	if(!is_user_alive(ent) || cod_get_user_item(id) == cod_get_item_id("Bezglowie")) return FMRES_IGNORED;
		
	new Float:origin[3], Float:angles[3];

	engfunc(EngFunc_GetBonePosition, ent, 8, origin, angles);

	set_tr2(trace, TR_vecEndPos, origin);
	set_tr2(trace, TR_iHitgroup, HIT_HEAD);
	
	return FMRES_IGNORED
}