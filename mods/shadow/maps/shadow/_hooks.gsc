// Shadow Garden hooks

#include common_scripts\utility;
#include maps\_utility;

register()
{
    maps\_modstack::add( "_zombiemode_ffotd::main_end", ::main_end );
    maps\_modstack::add( "zombie_pentagon_ffotd::main_end", ::main_end );
}

main_end()
{
    if (isDefined(level.shadow_hook_started))
        return;
    level.shadow_hook_started = true;
    level thread shadow_new_connections();
    level thread shadow_existing_players();
}

shadow_new_connections()
{
    for (;;)
    {
        level waittill( "connecting", player );
        player thread shadow_attach();
    }
}

shadow_existing_players()
{
    for (check = 0; check < 24; check++)
    {
        players = get_players();
        for (i = 0; i < players.size; i++)
        {
            if (!isDefined(players[i].shadow_attached))
                players[i] thread shadow_attach();
        }
        wait 0.25;
    }
}

shadow_attach()
{
    self endon( "disconnect" );
    if (IsDefined(self.shadow_attached) && self.shadow_attached)
        return;

    self.shadow_attached = true;
    self thread maps\mod_shadow\_shadow_menu::shadow_player_init();
    self thread maps\shadow\_user::main();
}
