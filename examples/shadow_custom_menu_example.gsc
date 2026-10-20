// Example custom menu for Shadow Garden
// Load this file with "Load Custom Script" before starting a new solo game.
// Importing it enables Custom GSC and disables Built-in Menu by default.
// The launcher can turn either script on or off independently.
// ADS + USE opens it; FIRE moves; USE selects; MELEE closes.
#include common_scripts\utility;
#include maps\_utility;

main()
{
    self endon("disconnect");
    if (isDefined(self.custom_running) && self.custom_running)
        return;

    self.custom_running = true;
    self.custom_open = false;
    self.custom_cursor = 0;
    self.custom_rows = [];
    self thread custom_input();
}

custom_input()
{
    self endon("disconnect");
    old_ads = false;
    old_use = false;
    old_attack = false;
    old_melee = false;

    for (;;)
    {
        ads = self adsButtonPressed();
        use = self useButtonPressed();
        attack = self attackButtonPressed();
        melee = self meleeButtonPressed();

        if (!self.custom_open)
        {
            if (ads && use && (!old_ads || !old_use))
                self custom_show();
        }
        else
        {
            if (melee && !old_melee)
                self custom_close();
            else if (use && !old_use)
                self custom_select();
            else if (attack && !old_attack)
            {
                self.custom_cursor++;
                if (self.custom_cursor >= self.custom_rows.size)
                    self.custom_cursor = 0;
                self custom_draw_cursor();
            }
        }
        old_ads = ads;
        old_use = use;
        old_attack = attack;
        old_melee = melee;
        wait 0.05;
    }
}

custom_show()
{
    if (self.custom_open)
        return;

    self.custom_open = true;
    self.custom_cursor = 0;
    self.custom_bg = newClientHudElem(self);
    self.custom_bg.horzAlign = "center";
    self.custom_bg.vertAlign = "top";
    self.custom_bg.alignX = "center";
    self.custom_bg.alignY = "top";
    self.custom_bg.x = 0;
    self.custom_bg.y = 105;
    self.custom_bg.color = (0.035, 0.035, 0.045);
    self.custom_bg.alpha = 0.9;
    self.custom_bg.sort = 3;
    self.custom_bg setShader("white", 250, 204);

    self.custom_title = self custom_text("CUSTOM GSC MENU", -108, 120, 1.3);
    self.custom_rows[0] = self custom_text("Heal Player", -108, 159, 1.08);
    self.custom_rows[1] = self custom_text("Add 1,000 Points", -108, 188, 1.08);
    self.custom_rows[2] = self custom_text("Close", -108, 217, 1.08);
    self.custom_footer = self custom_text("FIRE NEXT  |  USE SELECT\nMELEE CLOSE", -108, 255, 1.0);
    self custom_draw_cursor();
}

custom_text(value, x, y, scale)
{
    hud = newClientHudElem(self);
    hud.horzAlign = "center";
    hud.vertAlign = "top";
    hud.alignX = "left";
    hud.alignY = "top";
    hud.x = x;
    hud.y = y;
    hud.font = "default";
    hud.fontScale = scale;
    hud.color = (0.95, 0.95, 0.95);
    hud.alpha = 1;
    hud.sort = 5;
    hud.hideWhenInMenu = false;
    hud setText(value);
    return hud;
}

custom_draw_cursor()
{
    if (!self.custom_open)
        return;
    for (i = 0; i < self.custom_rows.size; i++)
    {
        if (i == self.custom_cursor)
            self.custom_rows[i].color = (1, 0.18, 0.29);
        else
            self.custom_rows[i].color = (0.95, 0.95, 0.95);
    }
}

custom_select()
{
    if (self.custom_cursor == 0)
    {
        if (isDefined(self.maxhealth))
            self.health = self.maxhealth;
        else
            self.health = 100;
        self iPrintLn("^1CUSTOM ^7Health restored");
    }
    else if (self.custom_cursor == 1)
    {
        self maps\_zombiemode_score::add_to_player_score(1000);
        self iPrintLn("^1CUSTOM ^7+1,000 points");
    }
    else
        self custom_close();
}

custom_close()
{
    if (!self.custom_open)
        return;
    self.custom_open = false;

    for (i = 0; i < self.custom_rows.size; i++)
    {
        if (isDefined(self.custom_rows[i]))
            self.custom_rows[i] destroy();
    }
    if (isDefined(self.custom_footer))
        self.custom_footer destroy();
    if (isDefined(self.custom_title))
        self.custom_title destroy();
    if (isDefined(self.custom_bg))
        self.custom_bg destroy();

    self.custom_rows = [];
    self.custom_footer = undefined;
    self.custom_title = undefined;
    self.custom_bg = undefined;
}
