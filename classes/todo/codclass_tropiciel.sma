#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <fakemeta>
#define TASK_ID 128000
	  
new const nazwa[]   = "Tropiciel (Premium)";
new const opis[]	= "Posiada moc zatruwania po naladowaniu noza dla klasy";
new const bronie	= (1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FIVESEVEN)|(1<<CSW_MP5NAVY)|(1<<CSW_FLASHBANG);
new const zdrowie   = 20;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 20;
#define CZAS_LADOWANIA 10 // Jak dlugo ma sie ladowac moc w s
new bool:moc_zaladowana[33];
new bool:ma_klase[33];
new msg_bartime;
  
public plugin_init()
{
		register_plugin(nazwa, "1.0", "amxx.pl");
		register_event("CurWeapon", "CurWeapon", "be", "1=1");
		register_event("ResetHUD", "ResetHUD", "abe");
		register_event("Damage", "Damage", "be", "2!0", "3=0", "4!0");
		msg_bartime = get_user_msgid("BarTime");
  
		register_forward(FM_PlayerPreThink, "client_PreThink");
		cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}
public cod_class_enabled(id)
{
give_item(id, "weapon_hegrenade");
give_item(id, "weapon_flashbang");
give_item(id, "weapon_flashbang");
give_item(id, "weapon_smokegrenade");
}
public client_PreThink(id)
{
	if(!task_exists(id+TASK_ID))
			return;
		  
	if(pev(id, pev_button) & (IN_MOVELEFT+IN_MOVERIGHT+IN_FORWARD+IN_BACK+IN_JUMP+IN_DUCK))
	{
			change_task(id+TASK_ID, CZAS_LADOWANIA.0);
			set_bartime(id, CZAS_LADOWANIA);
	}
}
public CurWeapon(id)
{
	if(get_user_weapon(id) == CSW_KNIFE && !moc_zaladowana[id] && ma_klase[id])
	{
			set_task(CZAS_LADOWANIA.0, "MocZaladowana", id+TASK_ID);
			set_bartime(id, CZAS_LADOWANIA);
	}
	else
	{
			remove_task(id+TASK_ID);
			set_bartime(id, 0);
	}
}
stock set_bartime(id, czas)
{
	message_begin((id)?MSG_ONE:MSG_ALL, msg_bartime, _, id)
	write_short(czas);
	message_end();
}
public MocZaladowana(id)
{
	id -= TASK_ID;
  
	if(!ma_klase[id]) return;
  
	moc_zaladowana[id] = true;
	client_print(id, print_center, "Umiejetnosc zostala aktywowana!");
	CurWeapon(id);
}
  
  
public ResetHUD(id) moc_zaladowana[id] = false;
#define TASK_ZATRUCIE 64000
new zatruwajacy[33];
public Damage(id)
{
	new attacker = get_user_attacker(id);
	if(!is_user_alive(attacker)) return;
  
	if(!moc_zaladowana[attacker]) return;
  
	zatruwajacy[id] = attacker;
	if(!task_exists(id+TASK_ZATRUCIE)) set_task(1.0, "Zatruj", id+TASK_ZATRUCIE, _, _, "a", 5);
}
public Zatruj(id)
{
	id -= TASK_ZATRUCIE;
	client_print(id, print_center, "Zostales zatruty!!");
	cod_inflict_damage(zatruwajacy[id], id, 8.0, 0.3);
}