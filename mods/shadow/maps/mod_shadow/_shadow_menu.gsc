/* SHADOW GARDEN GSC - BO1 Zombies v1.0.2 */

#include common_scripts\utility;
#include maps\_utility;

shadow_player_init()
{
    self endon("disconnect");

    if (isDefined(self.shadow_running) && self.shadow_running)
        return;

    self.shadow_running = true;
    self.shadow_open = false;
    self.shadow_closing = false;
    self.shadow_was_ignored = false;
    self.shadow_menu_invuln_applied = false;
    self.shadow_page = 0;
    self.shadow_cursor = 0;
    self.shadow_window = 0;
    self.shadow_visible_rows = 8;
    self.shadow_rows = [];
    self.shadow_items = [];
    self.shadow_item_values = [];

    self.shadow_god = false;
    self.shadow_user_notarget = false;
    self.shadow_spawn_origin = undefined;
    self.shadow_room_slots = [];
    self.shadow_map_spots = [];
    self.shadow_shoot_tp = false;
    self.shadow_last_shoot_tp = -10000;
    self.shadow_fx_enabled = false;
    self.shadow_fx_style = 0;
    self.shadow_last_fx = -10000;
    self.shadow_nuke_rounds = false;
    self.shadow_last_nuke_shot = -10000;
    self.shadow_speed = false;
    self.shadow_auto_refill = false;
    self.shadow_infinite_clip = false;
    self.shadow_ammo_mode = 0;
    self.shadow_one_hit = false;
    self.shadow_zombie_counter = false;
    self.shadow_count_hud = undefined;
    self.shadow_saved_origin = undefined;
    self.shadow_classic_aimbot = false;
    self.shadow_unfair_aimbot = false;
    self.shadow_aim_always = false;
    self.shadow_aim_bone = "j_head";
    self.shadow_key_mode = 0;
    self.shadow_noclip_bind = 1;
    self.shadow_noclip_active = false;
    self.shadow_key_repeat = 215;
    self.shadow_invert_scroll = false;
    self.shadow_swap_horizontal = false;
    self.shadow_color_r = 0.87;
    self.shadow_color_g = 0.19;
    self.shadow_color_b = 0.36;
    self.shadow_last_powerup_drop = -5000;
    self.shadow_palette = 0;
    self.shadow_low_effects = false;
    self.shadow_selection_visible = true;
    self.shadow_scrollbar_visible = true;
    self.shadow_busy_defcon = false;
    self.shadow_busy_doors = false;
    self.shadow_busy_clear = false;
    self.shadow_defcon_last = -10000;
    self.shadow_menu_auto_protect = true;
    self.shadow_achievement_survivor = false;
    self.shadow_achievement_veteran = false;
    self.shadow_achievement_rich = false;
    self.shadow_achievement_century = false;
    self.shadow_achievement_banker = false;

    self thread shadow_input_loop();
    self thread shadow_refill_loop();
    self thread shadow_aimbot_loop();
    self thread shadow_counter_loop();
    self thread shadow_ammo_effect_loop();
    self thread shadow_achievement_loop();
    self thread shadow_one_hit_loop();
    self thread shadow_safety_watchdog();
}

// Native crashes cannot be recovered from GSC.
shadow_safety_watchdog()
{
    self endon("disconnect");
    for (;;)
    {
        if (self.shadow_open && !self.shadow_closing &&
            (!isDefined(self.shadow_bg) || !isDefined(self.shadow_title) ||
            !isDefined(self.shadow_section) ||
            !isDefined(self.shadow_selection) ||
            self.shadow_rows.size != self.shadow_visible_rows))
        {
            self shadow_close();
            self iPrintLn("^1SHADOW ^7HUD recovered from an incomplete state");
        }
        wait 1;
    }
}

shadow_input_loop()
{
    self endon("disconnect");

    old_ads = false;
    old_melee = false;
    old_attack = false;
    old_use = false;
    old_right = false;
    old_left = false;
    next_nav = 0;

    for (;;)
    {
        ads = self adsButtonPressed();
        melee = self meleeButtonPressed();
        attack = self attackButtonPressed();
        use = self useButtonPressed();

        if (!self.shadow_open)
        {
            if (ads && melee && (!old_ads || !old_melee))
                self shadow_show();
        }
        else
        {

            movement = self getNormalizedMovement();
            w = movement[0] > 0.50;
            s = movement[0] < -0.50;
            d = movement[1] > 0.50;
            a = movement[1] < -0.50;
            select_key = d && !old_right;
            back_key = a && !old_left;
            up_key = w;
            down_key = s;
            if (self.shadow_swap_horizontal)
            {
                select_key = a && !old_left;
                back_key = d && !old_right;
            }
            if (self.shadow_invert_scroll)
            {
                up_key = s;
                down_key = w;
            }

            if (melee && !old_melee)
                self shadow_close();
            else if ((self.shadow_key_mode == 0 && select_key) ||
                (use && !old_use))
                self shadow_activate();
            else if (self.shadow_key_mode == 0 && back_key)
                self shadow_back();
            else if (getTime() >= next_nav)
            {
                if ((self.shadow_key_mode == 0 && down_key) || (attack && !old_attack))
                {
                    self shadow_move(1);
                    next_nav = getTime() + self.shadow_key_repeat;
                }
                else if ((self.shadow_key_mode == 0 && up_key) || (ads && !old_ads))
                {
                    self shadow_move(-1);
                    next_nav = getTime() + self.shadow_key_repeat;
                }
            }
            old_right = d;
            old_left = a;
        }

        old_ads = ads;
        old_melee = melee;
        old_attack = attack;
        old_use = use;
        wait 0.05;
    }
}

shadow_show()
{
    if (self.shadow_open || self.shadow_closing)
        return;

    self.shadow_open = true;
    self.shadow_page = 0;
    self.shadow_cursor = 0;
    self.shadow_window = 0;
    if (!isDefined(self.shadow_spawn_origin))
        self.shadow_spawn_origin = self.origin;
    self setVelocity((0, 0, 0));
    self freezeControls(true);
    self.shadow_was_ignored = isDefined(self.ignoreme) && self.ignoreme;
    self.shadow_menu_invuln_applied = false;
    if (self.shadow_menu_auto_protect)
    {
        self.ignoreme = true;
        self enableInvulnerability();
        self.shadow_menu_invuln_applied = true;
    }
    self disableWeapons();
    self shadow_define_page();

    self.shadow_bg = self shadow_center_bar(0, 38, 372, 362,
        (0.018, 0.020, 0.031), 0.94, 3);
    self.shadow_top = self shadow_center_bar(0, 38, 366, 69,
        (0.105, 0.027, 0.060), 0.98, 4);
    self.shadow_edge = self shadow_center_bar(-183, 38, 5, 362,
        self shadow_accent(), 1, 5);
    self.shadow_rule = self shadow_center_bar(0, 106, 346, 2,
        self shadow_accent(), 0.90, 5);
    self.shadow_selection = self shadow_center_bar(0, 143, 338, 24,
        (0.33, 0.035, 0.095), 0.94, 5);
    self.shadow_scroll_thumb = self shadow_center_bar(174, 146, 3, 19,
        self shadow_accent(), 0.95, 6);

    self.shadow_title = self shadow_center_text("SHADOW GARDEN", -166, 52, 1.68,
        (1, 1, 1), 7);
    self.shadow_subtitle = self shadow_center_text("GSC MENU / BLACK OPS ZOMBIES", -165, 82,
        1.05, self shadow_accent(), 7);
    self.shadow_section = self shadow_center_text("MAIN MENU", -165, 117,
        1.08, self shadow_accent(), 7);
    self.shadow_page_count = self shadow_center_text("1 / 1", 127, 117,
        1.05, (0.85, 0.85, 0.85), 7);

    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        self.shadow_rows[i] = self shadow_center_text(" ", -158, 146 + (i * 24),
            1.08, (1, 1, 1), 7);
    }

    self.shadow_footer = self shadow_center_text("W/S MOVE   D SELECT   A BACK", -164, 346,
        1.05, (0.85, 0.85, 0.85), 7);
    self.shadow_exit = self shadow_center_text("MELEE CLOSES MENU", -164, 370,
        1.05, (0.85, 0.85, 0.85), 7);

    self shadow_paint_page();
}

shadow_close()
{
    if (!self.shadow_open)
        return;

    self.shadow_open = false;
    self.shadow_closing = true;
    self notify("shadow_menu_closed");
    self freezeControls(false);
    self setVelocity((0, 0, 0));
    self enableWeapons();
    if (self.shadow_speed)
        self setMoveSpeedScale(1.5);
    else
        self setMoveSpeedScale(1);
    self.ignoreme = self.shadow_user_notarget || self.shadow_was_ignored;
    if (!self.shadow_god && self.shadow_menu_invuln_applied)
        self disableInvulnerability();
    self.shadow_menu_invuln_applied = false;

    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        if (isDefined(self.shadow_rows[i]))
            self.shadow_rows[i] destroy();
    }

    if (isDefined(self.shadow_exit))
        self.shadow_exit destroy();
    if (isDefined(self.shadow_footer))
        self.shadow_footer destroy();
    if (isDefined(self.shadow_scroll_thumb))
        self.shadow_scroll_thumb destroy();
    if (isDefined(self.shadow_selection))
        self.shadow_selection destroy();
    if (isDefined(self.shadow_section))
        self.shadow_section destroy();
    if (isDefined(self.shadow_page_count))
        self.shadow_page_count destroy();
    if (isDefined(self.shadow_subtitle))
        self.shadow_subtitle destroy();
    if (isDefined(self.shadow_title))
        self.shadow_title destroy();
    if (isDefined(self.shadow_rule))
        self.shadow_rule destroy();
    if (isDefined(self.shadow_edge))
        self.shadow_edge destroy();
    if (isDefined(self.shadow_top))
        self.shadow_top destroy();
    if (isDefined(self.shadow_bg))
        self.shadow_bg destroy();

    self.shadow_rows = [];
    self.shadow_items = [];
    self.shadow_item_values = [];
    self.shadow_cursor = 0;
    self.shadow_window = 0;
    self.shadow_closing = false;
    self.shadow_footer = undefined;
    self.shadow_exit = undefined;
    self.shadow_scroll_thumb = undefined;
    self.shadow_selection = undefined;
    self.shadow_section = undefined;
    self.shadow_page_count = undefined;
    self.shadow_subtitle = undefined;
    self.shadow_title = undefined;
    self.shadow_rule = undefined;
    self.shadow_edge = undefined;
    self.shadow_top = undefined;
    self.shadow_bg = undefined;
}

shadow_move(direction)
{
    count = self.shadow_items.size;
    if (count == 0)
        return;

    self.shadow_cursor += direction;
    if (self.shadow_cursor < 0)
        self.shadow_cursor = count - 1;
    if (self.shadow_cursor >= count)
        self.shadow_cursor = 0;

    old_window = self.shadow_window;
    if (self.shadow_cursor < self.shadow_window)
        self.shadow_window = self.shadow_cursor;
    if (self.shadow_cursor >= self.shadow_window + self.shadow_visible_rows)
        self.shadow_window = self.shadow_cursor - (self.shadow_visible_rows - 1);
    if (old_window != self.shadow_window)
        self shadow_paint_page();
    else
        self shadow_paint_cursor();
}

shadow_change_page(page)
{
    if (page == 18)
        self.shadow_five_parent = self.shadow_page;
    self.shadow_page = page;
    self.shadow_cursor = 0;
    self.shadow_window = 0;
    self shadow_define_page();
    self shadow_paint_page();
}

shadow_back()
{
    if (self.shadow_page == 0)
        self shadow_close();
    else
        self shadow_change_page(self shadow_parent_page(self.shadow_page));
}

shadow_parent_page(page)
{
    if (page == 18 && isDefined(self.shadow_five_parent))
        return self.shadow_five_parent;
    if (page == 2 || page == 3 || page == 9 || page == 22)
        return 13;
    if (page == 4 || page == 5 || page == 27)
        return 14;
    if (page == 24)
        return 4;
    if (page == 6 || page == 10 || page == 25)
        return 15;
    if (page == 17 || page == 23)
        return 6;
    if (page == 8 || page == 12)
        return 16;
    if (page == 26)
        return 19;
    if (page == 11 || page == 19 || page == 21)
        return 20;
    return 0;
}

shadow_define_page()
{
    self.shadow_items = [];
    self.shadow_item_values = [];

    if (self.shadow_page == 0)
    {
        self shadow_add_option("Player / Movement", 1);
        self shadow_add_option("Arsenal / Upgrades", 13);
        self shadow_add_option("Zombies / Points", 14);
        self shadow_add_option("Teleport / World", 15);
        self shadow_add_option("Combat / Aimbot", 7);
        self shadow_add_option("Controls / HUD", 20);
        self shadow_add_option("Stats / Achievements", 16);
        self shadow_add_option("Close Shadow", -1);
    }
    else if (self.shadow_page == 1)
    {
        if (self.shadow_god)
            self.shadow_items[0] = "God Mode: ON";
        else
            self.shadow_items[0] = "God Mode: OFF";

        if (self.shadow_user_notarget)
            self.shadow_items[1] = "No Target: ON";
        else
            self.shadow_items[1] = "No Target: OFF";

        self.shadow_items[2] = "NoClip: " + self shadow_on_off(self.shadow_noclip_active);
        self.shadow_items[3] = "NoClip Bind: " + self shadow_noclip_bind_name();
        if (self.shadow_speed)
            self.shadow_items[4] = "Speed Boost: ON";
        else
            self.shadow_items[4] = "Speed Boost: OFF";
        self.shadow_items[5] = "Restore Health";
        self.shadow_items[6] = "Save Spawn / Return in TP Menu";
        self.shadow_items[7] = "Reset Player Options";
        self.shadow_items[8] = "< Back";
    }
    else if (self.shadow_page == 2)
    {
        self shadow_add_option("Death Machine", "minigun_zm");
        self shadow_add_weapon("ray_gun_zm", "Ray Gun");
        self shadow_add_weapon("ak74u_zm", "AK74u");
        self shadow_add_weapon("mp40_zm", "MP40");
        self shadow_add_weapon("galil_zm", "Galil");
        self shadow_add_weapon("hk21_zm", "HK21");
        self shadow_add_weapon("rpk_zm", "RPK");
        self shadow_add_weapon("m1911_zm", "M1911");
        self shadow_add_weapon("thundergun_zm", "Thundergun");
        self shadow_add_weapon("tesla_gun_zm", "Wunderwaffe DG-2");
        self shadow_add_weapon("freezegun_zm", "Winter's Howl");
        self shadow_add_weapon("scavenger_zm", "Scavenger");
        self shadow_add_weapon("microwavegun_zm", "Wave Gun");
        self shadow_add_weapon("31-79_jgb215_zm", "31-79 JGb215");
        if (self.shadow_items.size == 0)
            self shadow_add_option("No registered weapons", "unavailable");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 3)
    {
        self.shadow_items[0] = "Refill Current Weapon";
        if (self.shadow_auto_refill)
            self.shadow_items[1] = "Infinite Reserve: ON";
        else
            self.shadow_items[1] = "Infinite Reserve: OFF";
        if (self.shadow_infinite_clip)
            self.shadow_items[2] = "Infinite Clip: ON";
        else
            self.shadow_items[2] = "Infinite Clip: OFF";
        self.shadow_items[3] = "Rounds: " + self shadow_ammo_mode_name();
        self.shadow_items[4] = "Drop Current Weapon";
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 4)
    {
        self.shadow_items[0] = "Clear Spawned Zombies";
        if (self.shadow_zombie_counter)
            self.shadow_items[1] = "Zombie Counter: ON";
        else
            self.shadow_items[1] = "Zombie Counter: OFF";
        if (self.shadow_one_hit)
            self.shadow_items[2] = "One-Hit Zombies: ON";
        else
            self.shadow_items[2] = "One-Hit Zombies: OFF";
        self.shadow_items[3] = "Count Alive Now";
        self.shadow_items[4] = "Current Round";
        self.shadow_items[5] = "Zombie Spawner";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 5)
    {
        self.shadow_items[0] = "Add 1,000";
        self.shadow_items[1] = "Add 5,000";
        self.shadow_items[2] = "Add 10,000";
        self.shadow_items[3] = "Add 50,000";
        self.shadow_items[4] = "Add 100,000";
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 6)
    {
        self.shadow_items[0] = "Room Bookmarks (A / B / C)";
        self.shadow_items[1] = "Map Location Teleports";
        self.shadow_items[2] = "Shoot to TP: " + self shadow_on_off(self.shadow_shoot_tp);
        self.shadow_items[3] = "Save Current Location";
        self.shadow_items[4] = "Return to Saved";
        self.shadow_items[5] = "Teleport to Crosshair";
        self.shadow_items[6] = "Clear Saved Location";
        self.shadow_items[7] = "< Back";
    }
    else if (self.shadow_page == 7)
    {
        if (self.shadow_classic_aimbot)
            self.shadow_items[0] = "Classic Aimbot: ON";
        else
            self.shadow_items[0] = "Classic Aimbot: OFF";

        if (self.shadow_unfair_aimbot)
            self.shadow_items[1] = "Unfair Aimbot: ON";
        else
            self.shadow_items[1] = "Unfair Aimbot: OFF";

        if (self.shadow_aim_always)
            self.shadow_items[2] = "Classic Aim: Always";
        else
            self.shadow_items[2] = "Classic Aim: ADS";

        if (self.shadow_aim_bone == "j_head")
            self.shadow_items[3] = "Target: Head";
        else
            self.shadow_items[3] = "Target: Torso";

        self.shadow_items[4] = "< Back";
    }
    else if (self.shadow_page == 8)
    {
        self.shadow_items[0] = "Current Map";
        self.shadow_items[1] = "Current Weapon";
        self.shadow_items[2] = "Player Position";
        self.shadow_items[3] = "Current Round";
        self.shadow_items[4] = "< Back";
    }
    else if (self.shadow_page == 9)
    {
        self shadow_add_perk("specialty_armorvest", "Juggernog");
        self shadow_add_perk("specialty_fastreload", "Speed Cola");
        self shadow_add_perk("specialty_rof", "Double Tap");
        self shadow_add_perk("specialty_quickrevive", "Quick Revive");
        self shadow_add_perk("specialty_longersprint", "Stamin-Up");
        self shadow_add_perk("specialty_detectexplosive", "PhD Flopper");
        self shadow_add_perk("specialty_deadshot", "Deadshot Daiquiri");
        self shadow_add_perk("specialty_additionalprimaryweapon", "Mule Kick");
        self shadow_add_option("Give All Available Perks", "all_perks");
        self shadow_add_option("Remove All Perks", "clear_perks");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 10)
    {
        if (self shadow_door_count() > 0)
            self shadow_add_option("Unlock All Doors", "doors");
        if (self shadow_power_available())
            self shadow_add_option("Turn Power On", "power");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 11)
    {
        if (self.shadow_key_mode == 0)
            self.shadow_items[0] = "Navigation: WASD";
        else
            self.shadow_items[0] = "Navigation: Classic";
        self.shadow_items[1] = "Scroll Repeat: " + self.shadow_key_repeat + "ms";
        if (self.shadow_invert_scroll)
            self.shadow_items[2] = "Scroll Direction: Inverted";
        else
            self.shadow_items[2] = "Scroll Direction: Normal";
        if (self.shadow_swap_horizontal)
            self.shadow_items[3] = "Horizontal: A Select / D Back";
        else
            self.shadow_items[3] = "Horizontal: D Select / A Back";
        self.shadow_items[4] = "NoClip Bind: " + self shadow_noclip_bind_name();
        self.shadow_items[5] = "Reset Controls";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 12)
    {
        self.shadow_items[0] = "SHADOW Session Challenges";
        if (self.shadow_achievement_survivor)
            self.shadow_items[1] = "Survivor V  [UNLOCKED]";
        else
            self.shadow_items[1] = "Survivor V  [LOCKED]";
        if (self.shadow_achievement_veteran)
            self.shadow_items[2] = "Veteran X  [UNLOCKED]";
        else
            self.shadow_items[2] = "Veteran X  [LOCKED]";
        if (self.shadow_achievement_rich)
            self.shadow_items[3] = "Wealth 10K  [UNLOCKED]";
        else
            self.shadow_items[3] = "Wealth 10K  [LOCKED]";
        if (self.shadow_achievement_century)
            self.shadow_items[4] = "Hunter 100  [UNLOCKED]";
        else
            self.shadow_items[4] = "Hunter 100  [LOCKED]";
        if (self.shadow_achievement_banker)
            self.shadow_items[5] = "Banker 100K  [UNLOCKED]";
        else
            self.shadow_items[5] = "Banker 100K  [LOCKED]";
        self.shadow_items[6] = "Unlock All Local Badges";
        self.shadow_items[7] = "Reset Local Badges";
        self.shadow_items[8] = "< Back";
    }
    else if (self.shadow_page == 13)
    {
        self shadow_add_option("Give Weapons", 2);
        self shadow_add_option("Ammo / Impact Rounds", 3);
        self shadow_add_option("Custom Weapon FX", 22);
        if (self shadow_perks_available())
            self shadow_add_option("Give / Remove Perks", 9);
        if (getDvar("mapname") == "zombie_pentagon")
            self shadow_add_option("Five: Pack-a-Punch Access", 18);
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 14)
    {
        self shadow_add_option("Zombie Controls", 4);
        self shadow_add_option("Add Points", 5);
        self shadow_add_option("Spawn Power-Ups", 27);
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 15)
    {
        self shadow_add_option("Saved / Room Teleports", 6);
        if (self shadow_world_available())
            self shadow_add_option("Doors / Power", 10);
        if (getDvar("mapname") == "zombie_pentagon")
            self shadow_add_option("Five: Rooms / DEFCON", 18);
        self shadow_add_option("Change Map (Shift+M)", 25);
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 16)
    {
        self shadow_add_option("Session Challenges", 12);
        self shadow_add_option("Map / Player Information", 8);
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 17)
    {
        self.shadow_items[0] = "Save Room A Here";
        self.shadow_items[1] = "Teleport to Room A";
        self.shadow_items[2] = "Save Room B Here";
        self.shadow_items[3] = "Teleport to Room B";
        self.shadow_items[4] = "Save Room C Here";
        self.shadow_items[5] = "Teleport to Room C";
        self.shadow_items[6] = "Return to Spawn";
        self.shadow_items[7] = "< Back";
    }
    else if (self.shadow_page == 18)
    {
        self.shadow_items[0] = "Activate DEFCON 5 (Power First)";
        self.shadow_items[1] = "Teleport: Top Floor";
        self.shadow_items[2] = "Teleport: War Room";
        self.shadow_items[3] = "Teleport: Labs";
        self.shadow_items[4] = "Teleport: Pack-a-Punch Room";
        self.shadow_items[5] = "DEFCON / Power Status";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 19)
    {
        self.shadow_items[0] = "Selection Highlight: " + self shadow_on_off(self.shadow_selection_visible);
        self.shadow_items[1] = "Side Scrollbar: " + self shadow_on_off(self.shadow_scrollbar_visible);
        self.shadow_items[2] = "Custom Accent Colors";
        self.shadow_items[3] = "< Back";
    }
    else if (self.shadow_page == 20)
    {
        self shadow_add_option("Menu Binds / NoClip Key", 11);
        self shadow_add_option("Theme / HUD Effects", 19);
        self shadow_add_option("Safety / Performance", 21);
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 21)
    {
        self.shadow_items[0] = "Auto Protection: " + self shadow_on_off(self.shadow_menu_auto_protect);
        self.shadow_items[1] = "Low Effects: " + self shadow_on_off(self.shadow_low_effects);
        self.shadow_items[2] = "Emergency: Close Menu";
        self.shadow_items[3] = "< Back";
    }
    else if (self.shadow_page == 22)
    {
        self.shadow_items[0] = "Impact FX: " + self shadow_on_off(self.shadow_fx_enabled);
        self.shadow_items[1] = "Effect: " + self shadow_fx_name();
        self.shadow_items[2] = "Ammo Damage Mode: " + self shadow_ammo_mode_name();
        self.shadow_items[3] = "Nuke Rounds: " + self shadow_on_off(self.shadow_nuke_rounds);
        self.shadow_items[4] = "< Back";
    }
    else if (self.shadow_page == 23)
    {
        self shadow_build_map_spots();
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 24)
    {
        self.shadow_items[0] = "Queue 1 Map Zombie";
        self.shadow_items[1] = "Queue 5 Map Zombies";
        self.shadow_items[2] = "Queue 10 Map Zombies";
        self.shadow_items[3] = "Queued This Round: " + self shadow_spawn_pending_text();
        self.shadow_items[4] = "Clear All Spawned Zombies";
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 25)
    {
        self.shadow_items[0] = "Open launcher: SHIFT + M";
        self.shadow_items[1] = "Pick the new map in the panel";
        self.shadow_items[2] = "Press Change Map";
        self.shadow_items[3] = "Reload the loader on new page";
        self.shadow_items[4] = "< Back";
    }
    else if (self.shadow_page == 26)
    {
        self.shadow_items[0] = "Red: " + self.shadow_color_r;
        self.shadow_items[1] = "Green: " + self.shadow_color_g;
        self.shadow_items[2] = "Blue: " + self.shadow_color_b;
        self.shadow_items[3] = "Cycle Color Presets";
        self.shadow_items[4] = "Restore Shadow Red";
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 27)
    {
        self.shadow_items[0] = "Spawn Active Nuke";
        self.shadow_items[1] = "Spawn Max Ammo";
        self.shadow_items[2] = "Spawn Insta-Kill";
        self.shadow_items[3] = "Spawn Double Points";
        self.shadow_items[4] = "Spawn Carpenter";
        self.shadow_items[5] = "Spawn Fire Sale";
        self.shadow_items[6] = "< Back";
    }
}

shadow_on_off(value)
{
    if (value) return "ON";
    return "OFF";
}

shadow_noclip_bind_name()
{
    if (self.shadow_noclip_bind == 1) return "MOUSE4";
    if (self.shadow_noclip_bind == 2) return "MOUSE5";
    if (self.shadow_noclip_bind == 3) return "F6";
    return "OFF";
}

shadow_noclip_bind_key(value)
{
    if (value == 1) return "MOUSE4";
    if (value == 2) return "MOUSE5";
    if (value == 3) return "F6";
    return "";
}

shadow_cycle_noclip_bind()
{
    old_key = self shadow_noclip_bind_key(self.shadow_noclip_bind);
    self.shadow_noclip_bind++;
    if (self.shadow_noclip_bind > 3)
        self.shadow_noclip_bind = 0;
    new_key = self shadow_noclip_bind_key(self.shadow_noclip_bind);
    if (self.shadow_noclip_active)
    {
        command = "";
        if (old_key != "")
            command = "unbind " + old_key;
        if (new_key != "")
        {
            if (command != "")
                command += ";";
            command += "bind " + new_key + " noclip";
        }
        if (command != "")
            self setClientDvar("activeAction", command);
    }
}

shadow_request_noclip()
{
    self.shadow_noclip_active = !self.shadow_noclip_active;
    key = self shadow_noclip_bind_key(self.shadow_noclip_bind);
    if (self.shadow_noclip_active)
    {
        if (key != "")
            self setClientDvar("activeAction", "bind " + key + " noclip;noclip");
        else
            self setClientDvar("activeAction", "noclip");
    }
    else if (key != "")
        self setClientDvar("activeAction", "unbind " + key + ";noclip");
    else
        self setClientDvar("activeAction", "noclip");
}

shadow_fx_name()
{
    if (self.shadow_fx_style == 0) return "Explosion";
    if (self.shadow_fx_style == 1) return "Tesla";
    if (self.shadow_fx_style == 2) return "Flame";
    if (self.shadow_fx_style == 3) return "Blood";
    return "Dust";
}

shadow_page_name()
{
    if (self.shadow_page == 1) return "PLAYER";
    if (self.shadow_page == 2) return "WEAPONS";
    if (self.shadow_page == 3) return "AMMO";
    if (self.shadow_page == 4) return "ZOMBIES";
    if (self.shadow_page == 5) return "POINTS";
    if (self.shadow_page == 6) return "TELEPORT";
    if (self.shadow_page == 7) return "AIMBOT";
    if (self.shadow_page == 8) return "INFORMATION";
    if (self.shadow_page == 9) return "PERKS";
    if (self.shadow_page == 10) return "WORLD / MAP";
    if (self.shadow_page == 11) return "BINDS / THEME";
    if (self.shadow_page == 12) return "ACHIEVEMENTS";
    if (self.shadow_page == 13) return "ARSENAL / UPGRADES";
    if (self.shadow_page == 14) return "ZOMBIES / POINTS";
    if (self.shadow_page == 15) return "TELEPORT / WORLD";
    if (self.shadow_page == 16) return "STATS / ACHIEVEMENTS";
    if (self.shadow_page == 17) return "ROOM BOOKMARKS";
    if (self.shadow_page == 18) return "FIVE / DEFCON";
    if (self.shadow_page == 19) return "THEME / HUD";
    if (self.shadow_page == 20) return "CONTROLS / HUD";
    if (self.shadow_page == 21) return "SAFETY / PERFORMANCE";
    if (self.shadow_page == 22) return "CUSTOM WEAPON FX";
    if (self.shadow_page == 23) return "MAP LOCATIONS";
    if (self.shadow_page == 24) return "ZOMBIE SPAWNER";
    if (self.shadow_page == 25) return "CHANGE MAP";
    if (self.shadow_page == 26) return "CUSTOM COLORS";
    if (self.shadow_page == 27) return "POWER-UPS / NUKES";
    return "MAIN MENU";
}

shadow_add_option(label, value)
{
    index = self.shadow_items.size;
    self.shadow_items[index] = label;
    self.shadow_item_values[index] = value;
}

shadow_add_weapon(weapon, label)
{
    if (isDefined(level.zombie_weapons) &&
        isDefined(level.zombie_weapons[weapon]))
        self shadow_add_option(label, weapon);
}

shadow_perks_available()
{
    triggers = getEntArray("zombie_vending", "targetname");
    return triggers.size > 0;
}

shadow_add_perk(perk, label)
{
    triggers = getEntArray("zombie_vending", "targetname");
    for (i = 0; i < triggers.size; i++)
    {
        if (isDefined(triggers[i].script_noteworthy) &&
            triggers[i].script_noteworthy == perk)
        {
            self shadow_add_option(label, perk);
            return;
        }
    }
}

shadow_door_count()
{
    doors = getEntArray("zombie_door", "targetname");
    debris = getEntArray("zombie_debris", "targetname");
    return doors.size + debris.size;
}

shadow_power_available()
{
    map = getDvar("mapname");
    if (map == "zombie_theater" || map == "zombie_pentagon" ||
        map == "zombie_cod5_factory" || map == "nazi_zombie_factory" ||
        map == "zombie_cod5_asylum" || map == "nazi_zombie_asylum" ||
        map == "zombie_cosmodrome" || map == "zombie_coast" ||
        map == "zombie_temple" || map == "zombie_moon")
        return true;
    return false;
}

shadow_world_available()
{
    return self shadow_door_count() > 0 || self shadow_power_available();
}

shadow_ammo_mode_name()
{
    if (self.shadow_ammo_mode == 1) return "Explosive";
    if (self.shadow_ammo_mode == 2) return "Heavy";
    if (self.shadow_ammo_mode == 3) return "One-Hit";
    if (self.shadow_ammo_mode == 4) return "Burn DOT";
    return "Normal";
}

shadow_paint_page()
{
    if (!self.shadow_open || !isDefined(self.shadow_section) ||
        !isDefined(self.shadow_footer))
        return;

    self.shadow_section setText(self shadow_page_name());
    if (self.shadow_key_mode == 0 && self.shadow_swap_horizontal)
        self.shadow_footer setText("W/S MOVE   A SELECT   D BACK");
    else if (self.shadow_key_mode == 0)
        self.shadow_footer setText("W/S MOVE   D SELECT   A BACK");
    else
        self.shadow_footer setText("FIRE DOWN  ADS UP  USE SELECT");

    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        item = i + self.shadow_window;
        if (item < self.shadow_items.size)
        {
            self.shadow_rows[i].alpha = 1;
        }
        else
        {
            self.shadow_rows[i] setText(" ");
            self.shadow_rows[i].alpha = 0;
        }
    }

    self shadow_paint_cursor();
}

shadow_paint_cursor()
{
    if (!self.shadow_open || !isDefined(self.shadow_page_count))
        return;

    position = self.shadow_cursor - self.shadow_window;
    if (isDefined(self.shadow_selection))
    {
        self.shadow_selection.y = 143 + (position * 24);
        if (self.shadow_selection_visible)
            self.shadow_selection.alpha = 0.94;
        else
            self.shadow_selection.alpha = 0;
    }
    if (isDefined(self.shadow_scroll_thumb))
    {
        scroll_position = 0;
        if (self.shadow_items.size > 1)
            scroll_position = (self.shadow_cursor * (self.shadow_visible_rows - 1)) /
                (self.shadow_items.size - 1);
        self.shadow_scroll_thumb.y = 146 + (scroll_position * 24);
        if (self.shadow_scrollbar_visible)
            self.shadow_scroll_thumb.alpha = 0.95;
        else
            self.shadow_scroll_thumb.alpha = 0;
    }
    self.shadow_page_count setText((self.shadow_cursor + 1) + " / " + self.shadow_items.size);
    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        item = i + self.shadow_window;
        if (item < self.shadow_items.size)
        {
            self.shadow_rows[i] setText("  " + self.shadow_items[item]);
            self.shadow_rows[i].color = (1, 1, 1);
        }
    }
}

shadow_activate()
{
    page = self.shadow_page;
    index = self.shadow_cursor;

    if (page == 0)
    {
        choice = self.shadow_item_values[index];
        if (choice == -1)
            self shadow_close();
        else
            self shadow_change_page(choice);
        return;
    }

    if (index == self.shadow_items.size - 1)
    {
        self shadow_back();
        return;
    }

    if (page == 13 || page == 14 || page == 15 || page == 16 || page == 20)
    {
        self shadow_change_page(self.shadow_item_values[index]);
        return;
    }

    if (page == 1)
    {
        if (index == 0)
        {
            self.shadow_god = !self.shadow_god;
            if (self.shadow_god || self.shadow_menu_invuln_applied)
                self enableInvulnerability();
            else if (!self.shadow_god)
                self disableInvulnerability();
        }
        else if (index == 1)
        {
            self.shadow_user_notarget = !self.shadow_user_notarget;
            self.ignoreme = self.shadow_user_notarget ||
                self.shadow_was_ignored ||
                (self.shadow_menu_auto_protect && self.shadow_open);
        }
        else if (index == 2)
            self shadow_request_noclip();
        else if (index == 3)
            self shadow_cycle_noclip_bind();
        else if (index == 4)
        {
            self.shadow_speed = !self.shadow_speed;
            if (!self.shadow_open)
            {
                if (self.shadow_speed)
                    self setMoveSpeedScale(1.5);
                else
                    self setMoveSpeedScale(1);
            }
        }
        else if (index == 5)
        {
            if (isDefined(self.maxhealth))
                self.health = self.maxhealth;
            else
                self.health = 100;
            self iPrintLn("^1SHADOW ^7Health restored");
        }
        else if (index == 6)
            self iPrintLn("^1SHADOW ^7Save and return with Teleport / World");
        else if (index == 7)
        {
            self.shadow_god = false;
            self.shadow_user_notarget = false;
            self.shadow_speed = false;
            if (self.shadow_noclip_active)
                self shadow_request_noclip();
            self.ignoreme = self.shadow_was_ignored ||
                (self.shadow_menu_auto_protect && self.shadow_open);
            if (!self.shadow_menu_invuln_applied)
                self disableInvulnerability();
            self iPrintLn("^1SHADOW ^7Player options reset");
        }
    }
    else if (page == 2)
    {
        choice = self.shadow_item_values[index];
        if (choice != "unavailable")
            self shadow_give_weapon(choice, self.shadow_items[index]);
    }
    else if (page == 3)
    {
        if (index == 0)
        {
            current = self getCurrentWeapon();
            if (isDefined(current) && current != "none")
                self giveMaxAmmo(current);
            self iPrintLn("^1SHADOW ^7Ammo refilled");
        }
        else if (index == 1)
        {
            self.shadow_auto_refill = !self.shadow_auto_refill;
        }
        else if (index == 2)
            self.shadow_infinite_clip = !self.shadow_infinite_clip;
        else if (index == 3)
        {
            self.shadow_ammo_mode++;
            if (self.shadow_ammo_mode > 4)
                self.shadow_ammo_mode = 0;
        }
        else if (index == 4)
        {
            current = self getCurrentWeapon();
            if (isDefined(current) && current != "none")
                self takeWeapon(current);
        }
    }
    else if (page == 4)
    {
        if (index == 0)
        {
            self thread shadow_clear_zombies();
        }
        else if (index == 1)
        {
            self.shadow_zombie_counter = !self.shadow_zombie_counter;
            if (!self.shadow_zombie_counter && isDefined(self.shadow_count_hud))
            {
                self.shadow_count_hud destroy();
                self.shadow_count_hud = undefined;
            }
        }
        else if (index == 2)
            self.shadow_one_hit = !self.shadow_one_hit;
        else if (index == 3)
        {
            zombies = getAiArray("axis");
            self iPrintLn("^1SHADOW ^7Zombies alive: " + zombies.size);
        }
        else if (index == 4)
            self shadow_print_round();
        else if (index == 5)
            self shadow_change_page(24);
    }
    else if (page == 5)
    {
        amount = 1000;
        if (index == 1) amount = 5000;
        if (index == 2) amount = 10000;
        if (index == 3) amount = 50000;
        if (index == 4) amount = 100000;
        self maps\_zombiemode_score::add_to_player_score(amount);
        self iPrintLn("^1SHADOW ^7Points added: " + amount);
    }
    else if (page == 6)
    {
        if (index == 0)
            self shadow_change_page(17);
        else if (index == 1)
            self shadow_change_page(23);
        else if (index == 2)
            self.shadow_shoot_tp = !self.shadow_shoot_tp;
        else if (index == 3)
        {
            self.shadow_saved_origin = self.origin;
            self iPrintLn("^1SHADOW ^7Location saved");
        }
        else if (index == 4)
        {
            if (isDefined(self.shadow_saved_origin))
                self shadow_warp(self.shadow_saved_origin, "saved position");
            else
                self iPrintLn("^1SHADOW ^7Save a location first");
        }
        else if (index == 5)
            self shadow_teleport_to_crosshair();
        else if (index == 6)
        {
            self.shadow_saved_origin = undefined;
            self iPrintLn("^1SHADOW ^7Saved location cleared");
        }
    }
    else if (page == 7)
    {
        if (index == 0)
            self.shadow_classic_aimbot = !self.shadow_classic_aimbot;
        else if (index == 1)
            self.shadow_unfair_aimbot = !self.shadow_unfair_aimbot;
        else if (index == 2)
            self.shadow_aim_always = !self.shadow_aim_always;
        else if (index == 3)
        {
            if (self.shadow_aim_bone == "j_head")
                self.shadow_aim_bone = "j_spine4";
            else
                self.shadow_aim_bone = "j_head";
        }
    }
    else if (page == 8)
    {
        if (index == 0)
            self iPrintLn("^1SHADOW ^7Map: " + getDvar("mapname"));
        else if (index == 1)
            self iPrintLn("^1SHADOW ^7Weapon: " + self getCurrentWeapon());
        else if (index == 2)
        {
            pos = self.origin;
            self iPrintLn("^1SHADOW ^7X " + pos[0] + " Y " + pos[1] + " Z " + pos[2]);
        }
        else
            self shadow_print_round();
    }
    else if (page == 9)
    {
        choice = self.shadow_item_values[index];
        if (choice == "all_perks")
        {
            for (i = 0; i < self.shadow_item_values.size - 3; i++)
                self shadow_grant_perk(self.shadow_item_values[i]);
            self iPrintLn("^1SHADOW ^7Available perks granted");
        }
        else if (choice == "clear_perks")
        {
            self clearPerks();
            self iPrintLn("^1SHADOW ^7Perks cleared");
        }
        else
        {
            self shadow_grant_perk(choice);
            self iPrintLn("^1SHADOW ^7Perk granted: " + self.shadow_items[index]);
        }
    }
    else if (page == 10)
    {
        choice = self.shadow_item_values[index];
        if (choice == "doors")
            self thread shadow_unlock_all_doors();
        else if (choice == "power")
        {
            flag_set("power_on");
            self iPrintLn("^1SHADOW ^7Power activated");
        }
    }
    else if (page == 11)
    {
        if (index == 0)
            self.shadow_key_mode = !self.shadow_key_mode;
        else if (index == 1)
        {
            self.shadow_key_repeat -= 35;
            if (self.shadow_key_repeat < 60)
                self.shadow_key_repeat = 200;
        }
        else if (index == 2)
            self.shadow_invert_scroll = !self.shadow_invert_scroll;
        else if (index == 3)
            self.shadow_swap_horizontal = !self.shadow_swap_horizontal;
        else if (index == 4)
            self shadow_cycle_noclip_bind();
        else if (index == 5)
        {
            self.shadow_key_mode = 0;
            self.shadow_key_repeat = 215;
            self.shadow_invert_scroll = false;
            self.shadow_swap_horizontal = false;
            self.shadow_noclip_bind = 1;
            if (self.shadow_noclip_active)
                self setClientDvar("activeAction", "unbind MOUSE5;unbind F6;bind MOUSE4 noclip");
        }
    }
    else if (page == 17)
    {
        if (index == 6)
        {
            if (isDefined(self.shadow_spawn_origin))
                self shadow_warp(self.shadow_spawn_origin, "spawn");
            else
                self iPrintLn("^1SHADOW ^7Spawn point unavailable");
        }
        else
        {
            slot = 0;
            if (index == 2 || index == 3)
                slot = 1;
            else if (index == 4 || index == 5)
                slot = 2;
            if (index == 0 || index == 2 || index == 4)
            {
                self.shadow_room_slots[slot] = self.origin;
                self iPrintLn("^1SHADOW ^7Room bookmark saved");
            }
            else if (isDefined(self.shadow_room_slots[slot]))
                self shadow_warp(self.shadow_room_slots[slot], "room bookmark");
            else
                self iPrintLn("^1SHADOW ^7Save this room slot first");
        }
    }
    else if (page == 18)
    {
        if (index == 0)
            self thread shadow_five_auto_defcon();
        else if (index == 1)
            self shadow_five_warp(0);
        else if (index == 2)
            self shadow_five_warp(1);
        else if (index == 3)
            self shadow_five_warp(2);
        else if (index == 4)
            self shadow_five_warp(3);
        else if (index == 5)
            self shadow_five_status();
    }
    else if (page == 19)
    {
        if (index == 0)
            self.shadow_selection_visible = !self.shadow_selection_visible;
        else if (index == 1)
            self.shadow_scrollbar_visible = !self.shadow_scrollbar_visible;
        else if (index == 2)
        {
            self shadow_change_page(26);
            return;
        }
    }
    else if (page == 21)
    {
        if (index == 0)
        {
            self.shadow_menu_auto_protect = !self.shadow_menu_auto_protect;
            self.ignoreme = self.shadow_user_notarget || self.shadow_was_ignored ||
                (self.shadow_menu_auto_protect && self.shadow_open);
            self.shadow_menu_invuln_applied = self.shadow_menu_auto_protect;
            if (self.shadow_god || self.shadow_menu_invuln_applied)
                self enableInvulnerability();
            else
                self disableInvulnerability();
        }
        else if (index == 1)
            self.shadow_low_effects = !self.shadow_low_effects;
        else if (index == 2)
        {
            self shadow_close();
            return;
        }
    }
    else if (page == 22)
    {
        if (index == 0)
            self.shadow_fx_enabled = !self.shadow_fx_enabled;
        else if (index == 1)
        {
            self.shadow_fx_style++;
            if (self.shadow_fx_style > 4)
                self.shadow_fx_style = 0;
        }
        else if (index == 2)
        {
            self.shadow_ammo_mode++;
            if (self.shadow_ammo_mode > 4)
                self.shadow_ammo_mode = 0;
        }
        else if (index == 3)
            self.shadow_nuke_rounds = !self.shadow_nuke_rounds;
    }
    else if (page == 23)
    {
        if (index < self.shadow_map_spots.size &&
            isDefined(self.shadow_map_spots[index]))
            self shadow_warp(self.shadow_map_spots[index], "map location");
    }
    else if (page == 24)
    {
        if (index == 0)
            self shadow_queue_zombies(1);
        else if (index == 1)
            self shadow_queue_zombies(5);
        else if (index == 2)
            self shadow_queue_zombies(10);
        else if (index == 4)
            self thread shadow_clear_zombies();
    }
    else if (page == 25)
        self iPrintLn("^1SHADOW ^7Press Shift+M to open the map launcher");
    else if (page == 26)
    {
        if (index == 0)
            self.shadow_color_r = self shadow_step_color(self.shadow_color_r);
        else if (index == 1)
            self.shadow_color_g = self shadow_step_color(self.shadow_color_g);
        else if (index == 2)
            self.shadow_color_b = self shadow_step_color(self.shadow_color_b);
        else if (index == 3)
            self shadow_next_palette();
        else if (index == 4)
        {
            self.shadow_palette = 0;
            self.shadow_color_r = 0.87;
            self.shadow_color_g = 0.19;
            self.shadow_color_b = 0.36;
        }
        self shadow_apply_theme();
    }
    else if (page == 27)
    {
        if (index == 0)
            self shadow_spawn_powerup("nuke", true);
        else if (index == 1)
            self shadow_spawn_powerup("full_ammo", false);
        else if (index == 2)
            self shadow_spawn_powerup("insta_kill", false);
        else if (index == 3)
            self shadow_spawn_powerup("double_points", false);
        else if (index == 4)
            self shadow_spawn_powerup("carpenter", false);
        else if (index == 5)
            self shadow_spawn_powerup("fire_sale", false);
    }
    else if (page == 12)
    {
        if (index == 6)
        {
            self.shadow_achievement_survivor = true;
            self.shadow_achievement_veteran = true;
            self.shadow_achievement_rich = true;
            self.shadow_achievement_century = true;
            self.shadow_achievement_banker = true;
            self iPrintLn("^1SHADOW ^7All local badges unlocked (not platform awards)");
        }
        else if (index == 7)
        {
            self.shadow_achievement_survivor = false;
            self.shadow_achievement_veteran = false;
            self.shadow_achievement_rich = false;
            self.shadow_achievement_century = false;
            self.shadow_achievement_banker = false;
            self iPrintLn("^1SHADOW ^7Local badges reset");
        }
        else
            self iPrintLn("^1SHADOW ^7Local session badges, not platform achievements");
    }

    self shadow_define_page();
    if (self.shadow_cursor >= self.shadow_items.size)
        self.shadow_cursor = self.shadow_items.size - 1;
    if (self.shadow_cursor < self.shadow_window)
        self.shadow_window = self.shadow_cursor;
    self shadow_paint_page();
}

shadow_print_round()
{
    if (isDefined(level.round_number))
        self iPrintLn("^1SHADOW ^7Round: " + level.round_number);
    else
        self iPrintLn("^1SHADOW ^7Round information unavailable");
}

shadow_spawn_pending_text()
{
    if (isDefined(level.zombie_total))
        return level.zombie_total;
    return "Unavailable";
}

shadow_queue_zombies(amount)
{
    // The round manager handles spawns. Keep the queue capped.
    if (!isDefined(level.zombie_total) || !isDefined(level.enemy_spawns) ||
        level.enemy_spawns.size == 0)
    {
        self iPrintLn("^1SHADOW ^7Map spawner not ready");
        return;
    }
    if (level.zombie_total + amount > 50)
    {
        self iPrintLn("^1SHADOW ^7Spawn queue capped at 50");
        return;
    }
    level.zombie_total += amount;
    self iPrintLn("^1SHADOW ^7Queued " + amount + " zombies through round spawner");
}

shadow_warp(position, label)
{
    if (!isDefined(position))
    {
        self iPrintLn("^1SHADOW ^7Teleport destination unavailable");
        return;
    }

    // Move the lock anchor before teleporting.
    if (self.shadow_open)
        self.shadow_lock_origin = position;
    self setVelocity((0, 0, 0));
    self setOrigin(position);
    self iPrintLn("^1SHADOW ^7Teleported: " + label);
}

shadow_add_map_spot(label, position)
{
    if (!isDefined(position) || self.shadow_items.size >= 7)
        return;
    index = self.shadow_items.size;
    self.shadow_map_spots[index] = position;
    self shadow_add_option(label, index);
}

shadow_perk_spot_name(perk)
{
    if (perk == "specialty_armorvest") return "Juggernog Room";
    if (perk == "specialty_fastreload") return "Speed Cola Room";
    if (perk == "specialty_rof") return "Double Tap Room";
    if (perk == "specialty_quickrevive") return "Quick Revive Room";
    if (perk == "specialty_longersprint") return "Stamin-Up Room";
    if (perk == "specialty_detectexplosive") return "PhD Flopper Room";
    if (perk == "specialty_deadshot") return "Deadshot Room";
    if (perk == "specialty_additionalprimaryweapon") return "Mule Kick Room";
    return "Perk Machine Room";
}

shadow_build_map_spots()
{
    self.shadow_map_spots = [];
    if (isDefined(self.shadow_spawn_origin))
        self shadow_add_map_spot("Starting Room", self.shadow_spawn_origin);

    // Build destinations from the current map's entities.
    power = getEntArray("use_elec_switch", "targetname");
    if (power.size > 0 && isDefined(power[0].origin))
        self shadow_add_map_spot("Power Switch", power[0].origin + (0, 0, 36));
    upgrade = getEntArray("zombie_vending_upgrade", "targetname");
    if (upgrade.size > 0 && isDefined(upgrade[0].origin) &&
        getDvar("mapname") != "zombie_pentagon")
        self shadow_add_map_spot("Pack-a-Punch Machine", upgrade[0].origin + (0, 0, 36));

    perks = getEntArray("zombie_vending", "targetname");
    for (i = 0; i < perks.size && i < 10 && self.shadow_items.size < 7; i++)
    {
        if (isDefined(perks[i]) && isDefined(perks[i].origin) &&
            isDefined(perks[i].script_noteworthy))
            self shadow_add_map_spot(self shadow_perk_spot_name(perks[i].script_noteworthy),
                perks[i].origin + (0, 0, 36));
    }
    if (self.shadow_items.size == 0)
        self shadow_add_option("No known map locations yet", "unavailable");
}

shadow_five_status()
{
    if (getDvar("mapname") != "zombie_pentagon")
    {
        self iPrintLn("^1SHADOW ^7Five features unavailable on this map");
        return;
    }
    if (flag("power_on"))
        self iPrintLn("^1SHADOW ^7Power: ON");
    else
        self iPrintLn("^1SHADOW ^7Power: OFF");
    if (isDefined(level.defcon_level))
        self iPrintLn("^1SHADOW ^7DEFCON: " + level.defcon_level);
}

shadow_five_auto_defcon()
{
    self endon("disconnect");
    if (self.shadow_busy_defcon || getTime() - self.shadow_defcon_last < 1800)
        return;
    if (getDvar("mapname") != "zombie_pentagon")
        return;
    if (!flag("power_on"))
    {
        self iPrintLn("^1SHADOW ^7Five: activate power first");
        return;
    }
    if (flag("defcon_active"))
    {
        self iPrintLn("^1SHADOW ^7DEFCON already active - use a teleporter");
        return;
    }
    switches = getEntArray("punch_switch", "targetname");
    if (switches.size < 4)
    {
        self iPrintLn("^1SHADOW ^7DEFCON switches not initialized");
        return;
    }
    self.shadow_busy_defcon = true;
    self.shadow_defcon_last = getTime();
    for (i = 0; i < switches.size && i < 4; i++)
    {
        if (isDefined(switches[i]) && !flag("defcon_active"))
            switches[i] notify("trigger", self);
        wait 0.26;
    }
    if (flag("defcon_active"))
        self iPrintLn("^1SHADOW ^7DEFCON 5: Pack-a-Punch route active");
    else
        self iPrintLn("^1SHADOW ^7DEFCON not ready; try the War Room switches");
    self.shadow_busy_defcon = false;
}

shadow_five_warp(spot)
{
    if (getDvar("mapname") != "zombie_pentagon")
        return;
    if (spot == 0 && isDefined(level.portal_top))
        self shadow_warp(level.portal_top.origin + (0, 0, 38), "top floor");
    else if (spot == 1 && isDefined(level.portal_mid))
        self shadow_warp(level.portal_mid.origin + (0, 0, 38), "war room");
    else if (spot == 2 && isDefined(level.portal_bottom) &&
        level.portal_bottom.size > 0)
        self shadow_warp(level.portal_bottom[0].origin + (0, 0, 38), "labs");
    else if (spot == 3)
    {
        if (!flag("defcon_active"))
        {
            self iPrintLn("^1SHADOW ^7Open DEFCON 5 before entering Pack room");
            return;
        }
        if (isDefined(level.portal_pack))
            self shadow_warp(level.portal_pack.origin + (0, 0, 38), "Panic Room");
        else
            self iPrintLn("^1SHADOW ^7Panic Room portal not ready");
    }
    else
        self iPrintLn("^1SHADOW ^7Five portal not ready (power may be off)");
}

shadow_give_weapon(name, label)
{
    if (name != "minigun_zm" &&
        (!isDefined(level.zombie_weapons) ||
        !isDefined(level.zombie_weapons[name])))
    {
        self iPrintLn("^1SHADOW ^7Weapon unavailable on this map");
        return;
    }
    self giveWeapon(name);
    self giveMaxAmmo(name);
    self switchToWeapon(name);
    self iPrintLn("^1SHADOW ^7" + label + " (if available on this map)");
}

shadow_grant_perk(perk)
{
    if (!self hasPerk(perk))
        self maps\_zombiemode_perks::give_perk(perk, false);
}

shadow_refill_loop()
{
    self endon("disconnect");

    while (self.shadow_running)
    {
        if (self.shadow_auto_refill || self.shadow_infinite_clip)
        {
            current = self getCurrentWeapon();
            if (isDefined(current) && current != "none")
            {
                if (self.shadow_auto_refill)
                    self giveMaxAmmo(current);
                if (self.shadow_infinite_clip)
                {
                    maximum = weaponClipSize(current);
                    if (maximum > 0)
                        self setWeaponAmmoClip(current, maximum);
                }
            }
        }
        if (self.shadow_auto_refill || self.shadow_infinite_clip)
            wait 0.18;
        else
            wait 0.60;
    }
}

shadow_ammo_effect_loop()
{
    self endon("disconnect");

    last_attack = false;
    while (self.shadow_running)
    {
        if (self.shadow_ammo_mode == 0 && !self.shadow_fx_enabled &&
            !self.shadow_nuke_rounds &&
            !self.shadow_shoot_tp)
        {
            last_attack = false;
            wait 0.18;
            continue;
        }
        attack = self attackButtonPressed();
        if ((self.shadow_ammo_mode > 0 || self.shadow_fx_enabled ||
            self.shadow_nuke_rounds ||
            self.shadow_shoot_tp) && !self.shadow_open &&
            attack && !last_attack)
        {
            start = self getEye();
            finish = start + (anglesToForward(self getPlayerAngles()) * 3500);
            trace = bulletTrace(start, finish, false, self);
            if (isDefined(trace) && isDefined(trace["position"]))
            {
                hit = trace["position"];
                if (self.shadow_nuke_rounds)
                    self shadow_trigger_shot_nuke();
                if (self.shadow_fx_enabled &&
                    getTime() - self.shadow_last_fx >= 220)
                {
                    self.shadow_last_fx = getTime();
                    self shadow_impact_fx(hit);
                }

                if (self.shadow_ammo_mode == 1)
                {
                    radiusDamage(hit, 135, 300, 30, self);
                }

                else if (isDefined(trace["entity"]))
                {
                    victim = trace["entity"];
                    if (isDefined(victim.health) && victim.health > 0)
                    {
                        if (self.shadow_ammo_mode == 2)
                            victim doDamage(1250, hit, self);
                        else if (self.shadow_ammo_mode == 3)
                            victim doDamage(victim.health + 1000, hit, self);
                        else if (self.shadow_ammo_mode == 4)
                            self thread shadow_burn_target(victim);
                    }
                }

                if (self.shadow_shoot_tp &&
                    getTime() - self.shadow_last_shoot_tp >= 650 &&
                    isDefined(trace["fraction"]) && trace["fraction"] < 0.98 &&
                    distance(start, hit) >= 80)
                {
                    landing = hit + (0, 0, 42);
                    if (isDefined(trace["normal"]))
                        landing += trace["normal"] * 24;
                    self.shadow_last_shoot_tp = getTime();
                    self shadow_warp(landing, "shoot-to-TP impact");
                }
            }
        }

        last_attack = attack;
        wait 0.05;
    }
}

shadow_impact_fx(hit)
{
    // Skip effects that the map has not loaded.
    if (!isDefined(level._effect))
        return;
    if (self.shadow_fx_style == 0 && isDefined(level._effect["def_explosion"]))
        playFX(level._effect["def_explosion"], hit);
    else if (self.shadow_fx_style == 1 && isDefined(level._effect["tesla_head_light"]))
        playFX(level._effect["tesla_head_light"], hit);
    else if (self.shadow_fx_style == 2 && isDefined(level._effect["character_fire_pain_sm"]))
        playFX(level._effect["character_fire_pain_sm"], hit);
    else if (self.shadow_fx_style == 3 && isDefined(level._effect["bloodspurt"]))
        playFX(level._effect["bloodspurt"], hit);
    else if (self.shadow_fx_style == 4 && isDefined(level._effect["rise_burst"]))
        playFX(level._effect["rise_burst"], hit);
}

shadow_burn_target(victim)
{
    self endon("disconnect");

    if (!isDefined(victim) || !isAlive(victim) ||
        (isDefined(victim.shadow_burn_active) && victim.shadow_burn_active))
        return;
    victim.shadow_burn_active = true;

    for (tick = 0; tick < 5; tick++)
    {
        if (!isDefined(victim) || !isAlive(victim))
            return;
        victim doDamage(75, victim.origin, self);
        wait 0.35;
    }
    if (isDefined(victim))
        victim.shadow_burn_active = false;
}

shadow_one_hit_loop()
{
    self endon("disconnect");

    while (self.shadow_running)
    {
        if (self.shadow_one_hit)
        {
            zombies = getAiArray("axis");
            for (i = 0; i < zombies.size; i++)
            {
                if (isDefined(zombies[i]) && isAlive(zombies[i]) && zombies[i].health > 1)
                    zombies[i].health = 1;
            }
        }
        if (self.shadow_one_hit)
            wait 0.5;
        else
            wait 1.0;
    }
}

shadow_achievement_loop()
{
    self endon("disconnect");

    while (self.shadow_running)
    {
        if (isDefined(level.round_number) && level.round_number >= 5 &&
            !self.shadow_achievement_survivor)
        {
            self.shadow_achievement_survivor = true;
            self iPrintLn("^1SHADOW GARDEN ^7Challenge: Survivor V");
        }
        if (isDefined(level.round_number) && level.round_number >= 10 &&
            !self.shadow_achievement_veteran)
        {
            self.shadow_achievement_veteran = true;
            self iPrintLn("^1SHADOW GARDEN ^7Challenge: Veteran X");
        }
        if (isDefined(self.score) && self.score >= 10000 &&
            !self.shadow_achievement_rich)
        {
            self.shadow_achievement_rich = true;
            self iPrintLn("^1SHADOW GARDEN ^7Challenge: Wealth 10K");
        }
        if (isDefined(self.kills) && self.kills >= 100 &&
            !self.shadow_achievement_century)
        {
            self.shadow_achievement_century = true;
            self iPrintLn("^1SHADOW GARDEN ^7Challenge: Hunter 100");
        }
        if (isDefined(self.score) && self.score >= 100000 &&
            !self.shadow_achievement_banker)
        {
            self.shadow_achievement_banker = true;
            self iPrintLn("^1SHADOW GARDEN ^7Challenge: Banker 100K");
        }
        wait 2;
    }
}

shadow_counter_loop()
{
    self endon("disconnect");

    last_count = -1;
    while (self.shadow_running)
    {
        if (self.shadow_zombie_counter && !self.shadow_open)
        {
            if (!isDefined(self.shadow_count_hud))
            {
                self.shadow_count_hud = self shadow_text("ZOMBIES  0", 18, 121,
                    0.70, self shadow_accent(), 8);
                last_count = -1;
            }

            zombies = getAiArray("axis");
            if (last_count != zombies.size)
            {
                self.shadow_count_hud setText("ZOMBIES  " + zombies.size);
                last_count = zombies.size;
            }
        }
        else
        {
            if (isDefined(self.shadow_count_hud))
            {
                self.shadow_count_hud destroy();
                self.shadow_count_hud = undefined;
            }
            last_count = -1;
        }

        wait 0.5;
    }
}

shadow_aimbot_loop()
{
    self endon("disconnect");

    old_attack = false;
    for (;;)
    {
        if ((!self.shadow_classic_aimbot && !self.shadow_unfair_aimbot) ||
            self.shadow_open)
        {
            old_attack = false;
            wait 0.18;
            continue;
        }
        attack = self attackButtonPressed();

        aim_active = self.shadow_classic_aimbot &&
            (self adsButtonPressed() || self.shadow_aim_always);
        shoot_active = self.shadow_unfair_aimbot && attack && !old_attack;

        if (aim_active || shoot_active)
        {
            target = self shadow_nearest_zombie();
            if (isDefined(target))
            {
                hit = target getTagOrigin(self.shadow_aim_bone);
                if (aim_active)
                {
                    eye = self getEye();
                    self setPlayerAngles(vectorToAngles(hit - eye));
                }

                if (shoot_active)
                {
                    weapon = self getCurrentWeapon();
                    if (isDefined(weapon) && weapon != "none")
                        MagicBullet(weapon, hit + (0, 0, 5), hit, self);
                }
            }
        }

        old_attack = attack;
        wait 0.05;
    }
}

shadow_nearest_zombie()
{
    zombies = getAiArray("axis");
    best = undefined;
    best_distance = 100000000;

    for (i = 0; i < zombies.size; i++)
    {
        zombie = zombies[i];
        if (!isDefined(zombie) || !isAlive(zombie))
            continue;

        d = distance(self.origin, zombie.origin);
        if (d < best_distance)
        {
            best_distance = d;
            best = zombie;
        }
    }

    return best;
}

shadow_clear_zombies()
{
    self endon("disconnect");

    if (self.shadow_busy_clear)
        return;
    self.shadow_busy_clear = true;

    zombies = getAiArray("axis");
    for (i = 0; i < zombies.size && i < 128; i++)
    {
        if (isDefined(zombies[i]) && isAlive(zombies[i]))
            zombies[i] doDamage(zombies[i].health + 1000, zombies[i].origin, self);

        wait 0.05;
    }
    self iPrintLn("^1SHADOW ^7Spawned zombies cleared");
    self.shadow_busy_clear = false;
}

shadow_accent()
{
    return (self.shadow_color_r, self.shadow_color_g, self.shadow_color_b);
}

shadow_step_color(value)
{
    value += 0.16;
    if (value > 1)
        value = 0;
    return value;
}

shadow_next_palette()
{
    self.shadow_palette++;
    if (self.shadow_palette > 4)
        self.shadow_palette = 0;
    if (self.shadow_palette == 0)
    {
        self.shadow_color_r = 0.87;
        self.shadow_color_g = 0.19;
        self.shadow_color_b = 0.36;
    }
    else if (self.shadow_palette == 1)
    {
        self.shadow_color_r = 0.30;
        self.shadow_color_g = 0.68;
        self.shadow_color_b = 1;
    }
    else if (self.shadow_palette == 2)
    {
        self.shadow_color_r = 0.50;
        self.shadow_color_g = 0.96;
        self.shadow_color_b = 0.28;
    }
    else if (self.shadow_palette == 3)
    {
        self.shadow_color_r = 0.88;
        self.shadow_color_g = 0.38;
        self.shadow_color_b = 1;
    }
    else
    {
        self.shadow_color_r = 1;
        self.shadow_color_g = 0.68;
        self.shadow_color_b = 0.20;
    }
}

shadow_apply_theme()
{
    if (!self.shadow_open)
        return;
    if (isDefined(self.shadow_section))
        self.shadow_section.color = self shadow_accent();
    if (isDefined(self.shadow_subtitle))
        self.shadow_subtitle.color = self shadow_accent();
    if (isDefined(self.shadow_edge))
        self.shadow_edge.color = self shadow_accent();
    if (isDefined(self.shadow_rule))
        self.shadow_rule.color = self shadow_accent();
    if (isDefined(self.shadow_scroll_thumb))
        self.shadow_scroll_thumb.color = self shadow_accent();
    self shadow_paint_cursor();
}

shadow_spawn_powerup(type, activate)
{
    if (!isDefined(level.zombie_powerups) ||
        !isDefined(level.zombie_powerups[type]))
    {
        self iPrintLn("^1SHADOW ^7Power-up unavailable on this map");
        return false;
    }
    if (getTime() - self.shadow_last_powerup_drop < 1200)
    {
        self iPrintLn("^1SHADOW ^7Wait before spawning another power-up");
        return false;
    }
    self.shadow_last_powerup_drop = getTime();
    if (activate)
        point = self.origin;
    else
        point = self.origin + (anglesToForward(self getPlayerAngles()) * 96);
    level thread maps\_zombiemode_powerups::specific_powerup_drop(type, point);
    self iPrintLn("^1SHADOW ^7Power-up spawned: " + type);
    return true;
}

shadow_trigger_shot_nuke()
{
    if (!self.shadow_nuke_rounds || !isDefined(level.zombie_powerups) ||
        !isDefined(level.zombie_powerups["nuke"]) ||
        getTime() - self.shadow_last_nuke_shot < 1500)
        return;

    self.shadow_last_nuke_shot = getTime();
    level thread maps\_zombiemode_powerups::specific_powerup_drop("nuke", self.origin);
}

shadow_teleport_to_crosshair()
{
    start = self getEye();
    finish = start + (anglesToForward(self getPlayerAngles()) * 8000);
    trace = bulletTrace(start, finish, false, self);

    if (!isDefined(trace) || !isDefined(trace["position"]) ||
        (isDefined(trace["fraction"]) && trace["fraction"] >= 1))
    {
        self iPrintLn("^1SHADOW ^7No safe crosshair surface found");
        return;
    }

    landing = trace["position"] + (0, 0, 42);
    if (isDefined(trace["normal"]))
        landing += trace["normal"] * 24;
    self shadow_warp(landing, "crosshair impact");
}

shadow_unlock_all_doors()
{
    self endon("disconnect");

    if (self.shadow_busy_doors)
        return;
    self.shadow_busy_doors = true;

    total = 0;
    doors = getEntArray("zombie_door", "targetname");
    for (i = 0; i < doors.size && i < 96; i++)
    {
        if (isDefined(doors[i]))
        {
            doors[i] notify("trigger", self);
            total++;
        }
        wait 0.05;
    }

    debris = getEntArray("zombie_debris", "targetname");
    for (i = 0; i < debris.size && i < 96; i++)
    {
        if (isDefined(debris[i]))
        {
            debris[i] notify("trigger", self);
            total++;
        }
        wait 0.05;
    }

    self iPrintLn("^1SHADOW ^7Triggered " + total + " door/debris objects");
    self.shadow_busy_doors = false;
}

shadow_center_text(value, x, y, scale, rgb, sort)
{
    elem = newClientHudElem(self);
    elem.horzAlign = "center";
    elem.vertAlign = "top";
    elem.alignX = "left";
    elem.alignY = "top";
    elem.x = x;
    elem.y = y;
    elem.font = "default";
    if (scale < 1.0)
        scale = 1.05;
    elem.fontScale = scale;
    elem setText(value);
    elem.color = rgb;
    elem.alpha = 1;
    elem.sort = sort;
    elem.hideWhenInMenu = false;
    return elem;
}

shadow_center_bar(x, y, width, height, rgb, alpha, sort)
{
    elem = newClientHudElem(self);
    elem.horzAlign = "center";
    elem.vertAlign = "top";
    elem.alignX = "center";
    elem.alignY = "top";
    elem.x = x;
    elem.y = y;
    elem.sort = sort;
    elem.color = rgb;
    elem.alpha = alpha;
    elem setShader("white", width, height);
    elem.hideWhenInMenu = false;
    return elem;
}

shadow_text(value, x, y, scale, rgb, sort)
{
    elem = newClientHudElem(self);
    elem.horzAlign = "left";
    elem.vertAlign = "top";
    elem.alignX = "left";
    elem.alignY = "top";
    elem.x = x;
    elem.y = y;
    elem.font = "default";
    if (scale < 1.0)
        scale = 1.05;
    elem.fontScale = scale;
    elem setText(value);
    elem.color = rgb;
    elem.alpha = 1;
    elem.sort = sort;
    elem.hideWhenInMenu = false;
    return elem;
}

