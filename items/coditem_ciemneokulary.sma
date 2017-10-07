#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Ciemne Okulary"
#define VERSION "1.0.15"
#define AUTHOR "O'Zone"

#define NAME        "Ciemne Okulary"
#define DESCRIPTION "Nie dzialaja na ciebie flashe"

new itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);

	register_message(get_user_msgid("ScreenFade"), "message_screen_fade");
}

public cod_item_enabled(id, value)
	rem_bit(id, itemActive);

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public message_screen_fade(msgType, msgID, id)
{
	if(get_bit(id, itemActive) && get_msg_arg_int(4) == 255 && get_msg_arg_int(5) == 255 && get_msg_arg_int(6) == 255) return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}