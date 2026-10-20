/* SHADOW GARDEN GSC - BO1 Zombies v1.3.13 */

#include common_scripts\utility;
#include maps\_utility;

shadow_player_init()
{
    self endon("disconnect");

    if (isDefined(self.shadow_running) && self.shadow_running)
        return;

    self.shadow_running = true;
    self.shadow_input_last_tick = getTime();
    self.shadow_menu_opened_at = -10000;
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
    self.shadow_navigation_pages = [];
    self.shadow_navigation_cursors = [];
    self.shadow_navigation_depth = 0;

    self.shadow_god = false;
    self.shadow_user_notarget = false;
    self.shadow_spawn_origin = undefined;
    self.shadow_lock_origin = undefined;
    self.shadow_lock_angles = undefined;
    self.shadow_controls_frozen_by_menu = false;
    self.shadow_room_slots = [];
    self.shadow_map_spots = [];
    self.shadow_shoot_tp = false;
    self.shadow_last_shoot_tp = -10000;
    self.shadow_fx_enabled = false;
    self.shadow_fx_style = 0;
    self.shadow_last_fx = -10000;
    self.shadow_nuke_rounds = false;
    self.shadow_last_nuke_shot = -10000;
    self.shadow_speed_level = 0;
    if (!isDefined(level.shadow_jump_default))
    {
        level.shadow_jump_default = getDvarInt("jump_height");
        if (level.shadow_jump_default <= 0)
            level.shadow_jump_default = 39;
    }
    if (!isDefined(level.shadow_gravity_default))
    {
        level.shadow_gravity_default = getDvarInt("g_gravity");
        if (level.shadow_gravity_default <= 0)
            level.shadow_gravity_default = 800;
    }
    if (!isDefined(level.shadow_super_jump))
        level.shadow_super_jump = false;
    if (!isDefined(level.shadow_low_gravity))
        level.shadow_low_gravity = false;
    self.shadow_auto_refill = false;
    self.shadow_infinite_clip = false;
    self.shadow_ammo_mode = 0;
    self.shadow_one_hit = false;
    self.shadow_zombie_counter = false;
    self.shadow_count_hud = undefined;
    self.shadow_notice_bg = undefined;
    self.shadow_notice_text = undefined;
    self.shadow_notice_expires = 0;
    self.shadow_saved_origin = undefined;
    self.shadow_last_hand_weapon = undefined;
    self.shadow_classic_aimbot = false;
    self.shadow_unfair_aimbot = false;
    self.shadow_aim_target = undefined;
    self.shadow_aim_next_scan = 0;
    self.shadow_unfair_last_shot = -10000;
    self.shadow_aim_always = false;
    self.shadow_aim_bone = "j_head";
    self.shadow_key_mode = 0;
    self.shadow_noclip_bind = 1;
    self.shadow_noclip_active = false;
    self.shadow_noclip_bound_key = "";
    self.shadow_noclip_dirty = false;
    self.shadow_noclip_toggle_pending = false;
    self.shadow_key_repeat = 215;
    self.shadow_invert_scroll = false;
    self.shadow_swap_horizontal = false;
    self.shadow_color_r = 0.90;
    self.shadow_color_g = 0.035;
    self.shadow_color_b = 0.022;
    self.shadow_last_powerup_drop = -5000;
    self.shadow_palette = 0;
    self.shadow_low_effects = false;
    self.shadow_selection_visible = true;
    self.shadow_scrollbar_visible = false;
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

shadow_safety_watchdog()
{
    self endon("disconnect");
    for (;;)
    {
        if (self.shadow_open && !self.shadow_closing &&
            getTime() - self.shadow_menu_opened_at > 350 &&
            (!isDefined(self.shadow_bg) || !isDefined(self.shadow_title) ||
            !isDefined(self.shadow_section) ||
            !isDefined(self.shadow_selection) ||
            self.shadow_rows.size != self.shadow_visible_rows ||
            getTime() - self.shadow_input_last_tick > 2000))
        {
            self shadow_close();
            self shadow_notice("^1SHADOW ^7Menu reset after an error");
        }
        if (isDefined(self.shadow_notice_bg) &&
            isDefined(self.shadow_notice_text) &&
            self.shadow_notice_expires != 0)
        {
            remaining = self.shadow_notice_expires - getTime();
            if (remaining <= 0)
            {
                self.shadow_notice_bg.alpha = 0;
                self.shadow_notice_text.alpha = 0;
                self.shadow_notice_expires = 0;
            }
            else if (remaining < 800)
            {
                self.shadow_notice_bg.alpha = remaining / 800.0;
                self.shadow_notice_text.alpha = remaining / 800.0;
            }
        }
        wait 0.25;
    }
}

shadow_input_loop()
{
    self endon("disconnect");

    old_ads = false;
    old_melee = false;
    old_attack = false;
    old_use = false;
    old_jump = false;
    old_right = false;
    old_left = false;
    next_nav = 0;

    for (;;)
    {
        self.shadow_input_last_tick = getTime();
        ads = self adsButtonPressed();
        melee = self meleeButtonPressed();
        attack = self attackButtonPressed();
        use = self useButtonPressed();
        jump = self jumpButtonPressed();

        if (!self.shadow_open)
        {
            if (ads && melee && (!old_ads || !old_melee))
            {
                self shadow_show();
                next_nav = getTime() + 180;
            }
            old_right = false;
            old_left = false;
        }
        else
        {
            if (isDefined(self.shadow_lock_origin))
            {
                self setVelocity((0, 0, 0));
                if (distance(self.origin, self.shadow_lock_origin) > 2)
                    self setOrigin(self.shadow_lock_origin);
            }
            if (isDefined(self.shadow_lock_angles))
                self setPlayerAngles(self.shadow_lock_angles);

            movement = self getNormalizedMovement();
            if (!isDefined(movement))
                movement = (0, 0, 0);
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

            if (ads && melee && (!old_ads || !old_melee))
            {
                self shadow_close();
                next_nav = getTime() + 200;
            }
            else if (melee && !old_melee)
            {
                if (self.shadow_page == 0)
                    self shadow_close();
                else
                    self shadow_back();
                next_nav = getTime() + 140;
            }
            else if ((self.shadow_key_mode == 0 && select_key) ||
                (use && !old_use) || (jump && !old_jump))
            {
                self shadow_activate();
                next_nav = getTime() + 130;
            }
            else if (self.shadow_key_mode == 0 && back_key)
            {
                self shadow_back();
                next_nav = getTime() + 130;
            }
            else if (getTime() >= next_nav)
            {
                if ((self.shadow_key_mode == 0 && down_key) ||
                    (attack && !old_attack))
                {
                    self shadow_move(1);
                    next_nav = getTime() + self.shadow_key_repeat;
                }
                else if ((self.shadow_key_mode == 0 && up_key) ||
                    (ads && !old_ads))
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
        old_jump = jump;
        if (self.shadow_open)
            wait 0.04;
        else
            wait 0.07;
    }
}

shadow_show()
{
    if (self.shadow_open || self.shadow_closing)
        return;

    self.shadow_open = true;
    self.shadow_menu_opened_at = getTime();
    if (!isDefined(self.shadow_spawn_origin))
        self.shadow_spawn_origin = self.origin;
    self.shadow_lock_origin = self.origin;
    self.shadow_lock_angles = self getPlayerAngles();
    self.shadow_controls_frozen_by_menu = true;
    self freezeControls(true);
    self thread shadow_hold_view();
    self.shadow_last_hand_weapon = self getCurrentWeapon();
    self setVelocity((0, 0, 0));
    self setMoveSpeedScale(0);
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
    if (self.shadow_cursor >= self.shadow_items.size)
        self.shadow_cursor = self.shadow_items.size - 1;
    if (self.shadow_cursor < 0)
        self.shadow_cursor = 0;
    if (self.shadow_window > self.shadow_cursor)
        self.shadow_window = self.shadow_cursor;
    if (self.shadow_window < 0)
        self.shadow_window = 0;
    if (self.shadow_cursor >= self.shadow_window + self.shadow_visible_rows)
        self.shadow_window = self.shadow_cursor - self.shadow_visible_rows + 1;

    self.shadow_bg = self shadow_center_bar(0, 49, 220, 240,
        (0.018, 0.020, 0.031), 0.94, 3);
    self.shadow_top = self shadow_center_bar(0, 49, 216, 42,
        (0.051, 0.018, 0.016), 0.98, 4);
    self.shadow_rule = self shadow_center_bar(0, 91, 198, 2,
        self shadow_accent(), 0.90, 5);
    self.shadow_selection = self shadow_center_bar(0, 111, 194, 18,
        (0.32, 0.025, 0.020), 0.94, 5);

    self.shadow_title = self shadow_center_text("SHADOWGARDEN GSC MENU", -5, 52, 1.20,
        (1, 1, 1), 7);
    self.shadow_title.alignX = "center";
    self.shadow_title.glowColor = (1, 0.02, 0.015);
    self.shadow_title.glowAlpha = 0.55;
    self.shadow_subtitle = self shadow_center_text("BY ^1JOSHUA ^7| DISCORD.GG/^1SHADOWGARDEN", -15, 71,
        1.05, (0.88, 0.82, 0.82), 7);
    self.shadow_subtitle.alignX = "center";
    self.shadow_subtitle.glowColor = (1, 0.025, 0.018);
    self.shadow_subtitle.glowAlpha = 0.20;
    self.shadow_section = self shadow_center_text("MAIN MENU", -96, 98,
        1.05, self shadow_accent(), 7);
    self.shadow_page_count = self shadow_center_text("1 / 1", 72, 98,
        1.05, (0.85, 0.85, 0.85), 7);

    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        self.shadow_rows[i] = self shadow_center_text(" ", -86, 113 + (i * 18),
            1.03, (1, 1, 1), 7);
    }

    self.shadow_footer_rule = self shadow_center_bar(0, 244, 220, 2,
        self shadow_accent(), 0.85, 5);
    self.shadow_footer_strip = self shadow_center_bar(0, 247, 220, 41,
        (0.11, 0.018, 0.016), 0.90, 4);
    self.shadow_footer = self shadow_center_text("^7             ^1[W/S] ^7NAV ^1[D/USE] ^7SELECT ^1[A] ^7BACK\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT", -24, 253,
        1.05, (1, 0.92, 0.90), 7);
    self.shadow_footer.alignX = "center";
    self.shadow_footer.fontScale = 0.98;
    self shadow_paint_page();
    self.shadow_footer.alpha = 0.92;
    self thread shadow_title_cycle();
}

shadow_hold_view()
{
    self endon("disconnect");
    self endon("shadow_menu_closed");
    for (;;)
    {
        if (!self.shadow_open || !isDefined(self.shadow_lock_angles))
            return;
        if (distance(self getPlayerAngles(), self.shadow_lock_angles) > 0.01)
            self setPlayerAngles(self.shadow_lock_angles);
        wait 0.02;
    }
}

shadow_title_cycle()
{
    self endon("disconnect");
    self endon("shadow_menu_closed");
    for (;;)
    {
        if (!self.shadow_open || !isDefined(self.shadow_title))
            return;
        self.shadow_title.color = (1, 0.02, 0.015);
        self.shadow_title.glowAlpha = 0.82;
        wait 2.3;
        self.shadow_title.color = (1, 1, 1);
        self.shadow_title.glowAlpha = 0.55;
        wait 2.3;
    }
}

shadow_close()
{
    if (!self.shadow_open)
        return;

    self.shadow_open = false;
    self.shadow_closing = true;
    self notify("shadow_menu_closed");
    self.shadow_lock_origin = undefined;
    self.shadow_lock_angles = undefined;
    self setVelocity((0, 0, 0));
    if (self.shadow_controls_frozen_by_menu)
        self freezeControls(false);
    self.shadow_controls_frozen_by_menu = false;
    self enableWeapons();
    self setMoveSpeedScale(self shadow_speed_scale());
    self.ignoreme = self.shadow_user_notarget || self.shadow_was_ignored;
    if (!self.shadow_god && self.shadow_menu_invuln_applied)
        self disableInvulnerability();
    self.shadow_menu_invuln_applied = false;
    if (self.shadow_noclip_dirty || self.shadow_noclip_toggle_pending)
        self thread shadow_apply_noclip();

    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        if (isDefined(self.shadow_rows[i]))
            self.shadow_rows[i] destroy();
    }

    if (isDefined(self.shadow_footer))
        self.shadow_footer destroy();
    if (isDefined(self.shadow_footer_rule))
        self.shadow_footer_rule destroy();
    if (isDefined(self.shadow_footer_strip))
        self.shadow_footer_strip destroy();
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
    self.shadow_bg_height = undefined;

    self.shadow_rows = [];
    self.shadow_items = [];
    self.shadow_item_values = [];
    self.shadow_closing = false;
    self.shadow_footer = undefined;
    self.shadow_footer_rule = undefined;
    self.shadow_footer_strip = undefined;
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
    if (!isDefined(page) || page < 0 || page > 28)
        return;
    if (self.shadow_navigation_depth < 10)
    {
        self.shadow_navigation_pages[self.shadow_navigation_depth] = self.shadow_page;
        self.shadow_navigation_cursors[self.shadow_navigation_depth] = self.shadow_cursor;
        self.shadow_navigation_depth++;
    }
    self.shadow_page = page;
    self.shadow_cursor = 0;
    self.shadow_window = 0;
    self shadow_define_page();
    self shadow_paint_page();
}

shadow_back()
{
    if (self.shadow_navigation_depth <= 0)
    {
        self shadow_close();
        return;
    }
    self.shadow_navigation_depth--;
    self.shadow_page = self.shadow_navigation_pages[self.shadow_navigation_depth];
    selected = self.shadow_navigation_cursors[self.shadow_navigation_depth];
    self shadow_define_page();
    if (selected >= self.shadow_items.size)
        selected = self.shadow_items.size - 1;
    if (selected < 0)
        selected = 0;
    self.shadow_cursor = selected;
    self.shadow_window = 0;
    if (selected >= self.shadow_visible_rows)
        self.shadow_window = selected - self.shadow_visible_rows + 1;
    self shadow_paint_page();
}

shadow_define_page()
{
    self.shadow_items = [];
    self.shadow_item_values = [];

    if (self.shadow_page == 0)
    {
        self shadow_add_option("Player Mods", "page_1");
        self shadow_add_option("Weapons", "page_13");
        self shadow_add_option("Lobby Mods", "page_15");
        self shadow_add_option("Aimbot & Combat", "page_7");
        self shadow_add_option("Settings", "page_20");
        self shadow_add_option("Extras", "page_16");
    }
    else if (self.shadow_page == 1)
    {
        self.shadow_items[0] = "God Mode: " + self shadow_on_off(self.shadow_god);
        self.shadow_items[1] = "No Target: " + self shadow_on_off(self.shadow_user_notarget);
        self.shadow_items[2] = "NoClip: " + self shadow_on_off(self.shadow_noclip_active);
        self.shadow_items[3] = "Player Speed: " + self shadow_speed_name();
        self.shadow_items[4] = "Heal Player";
        self.shadow_items[5] = "Reset Player Mods";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 2)
    {
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
        self shadow_add_weapon("python_zm", "Python");
        self shadow_add_weapon("cz75_zm", "CZ75");
        self shadow_add_weapon("cz75dw_zm", "CZ75 Dual Wield");
        self shadow_add_weapon("mp5k_zm", "MP5K");
        self shadow_add_weapon("mpl_zm", "MPL");
        self shadow_add_weapon("pm63_zm", "PM63");
        self shadow_add_weapon("spectre_zm", "Spectre");
        self shadow_add_weapon("ithaca_zm", "Stakeout");
        self shadow_add_weapon("spas_zm", "SPAS-12");
        self shadow_add_weapon("rottweil72_zm", "Olympia");
        self shadow_add_weapon("hs10_zm", "HS10");
        self shadow_add_weapon("m14_zm", "M14");
        self shadow_add_weapon("m16_zm", "M16");
        self shadow_add_weapon("g11_lps_zm", "G11");
        self shadow_add_weapon("famas_zm", "FAMAS");
        self shadow_add_weapon("aug_acog_zm", "AUG");
        self shadow_add_weapon("commando_zm", "Commando");
        self shadow_add_weapon("fnfal_zm", "FN FAL");
        self shadow_add_weapon("dragunov_zm", "Dragunov");
        self shadow_add_weapon("l96a1_zm", "L96A1");
        self shadow_add_weapon("m72_law_zm", "M72 LAW");
        self shadow_add_weapon("china_lake_zm", "China Lake");
        self shadow_add_weapon("crossbow_explosive_zm", "Explosive Crossbow");
        self shadow_add_weapon("knife_ballistic_zm", "Ballistic Knife");
        self shadow_add_weapon("knife_ballistic_bowie_zm", "Ballistic Knife (Bowie)");
        self shadow_add_weapon("knife_ballistic_sickle_zm", "Ballistic Knife (Sickle)");
        if (self.shadow_items.size == 0)
            self shadow_add_option("No registered weapons", "unavailable");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 3)
    {
        self.shadow_items[0] = "Pack-a-Punch Weapon";
        self.shadow_items[1] = "Refill Current Ammo";
        self.shadow_items[2] = "Refill All Ammo";
        self.shadow_items[3] = "Unlimited Ammo: " + self shadow_on_off(self.shadow_auto_refill);
        self.shadow_items[4] = "Infinite Clip: " + self shadow_on_off(self.shadow_infinite_clip);
        self.shadow_items[5] = "Drop Weapon";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 4)
    {
        self.shadow_items[0] = "Clear Zombies";
        self.shadow_items[1] = "Zombie Counter: " + self shadow_on_off(self.shadow_zombie_counter);
        self.shadow_items[2] = "Show Alive Zombies";
        self.shadow_items[3] = "Skip Round";
        self.shadow_items[4] = "Zombie Spawner";
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 5)
    {
        self.shadow_items[0] = "Add 1,337 Points";
        self.shadow_items[1] = "Add 1,000 Points";
        self.shadow_items[2] = "Add 5,000 Points";
        self.shadow_items[3] = "Add 10,000 Points";
        self.shadow_items[4] = "Add 50,000 Points";
        self.shadow_items[5] = "Add 100,000 Points";
        self.shadow_items[6] = "Reset Points";
        self.shadow_items[7] = "< Back";
    }
    else if (self.shadow_page == 6)
    {
        self.shadow_items[0] = "Saved Positions";
        self.shadow_items[1] = "Map Teleports";
        self.shadow_items[2] = "Shoot to Teleport: " + self shadow_on_off(self.shadow_shoot_tp);
        self.shadow_items[3] = "Save Position";
        self.shadow_items[4] = "Teleport to Saved";
        self.shadow_items[5] = "Teleport to Crosshair";
        self.shadow_items[6] = "Set Spawn Return Point";
        self.shadow_items[7] = "< Back";
    }
    else if (self.shadow_page == 7)
    {
        self.shadow_items[0] = "Classic Aimbot: " + self shadow_on_off(self.shadow_classic_aimbot);
        self.shadow_items[1] = "Unfair Aimbot: " + self shadow_on_off(self.shadow_unfair_aimbot);
        if (self.shadow_aim_always)
            self.shadow_items[2] = "Aim Activation: Always";
        else
            self.shadow_items[2] = "Aim Activation: ADS";
        if (self.shadow_aim_bone == "j_head")
            self.shadow_items[3] = "Aim Target: Head";
        else
            self.shadow_items[3] = "Aim Target: Body";
        self.shadow_items[4] = "One-Hit Kill: " + self shadow_on_off(self.shadow_one_hit);
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 8)
    {
        self.shadow_items[0] = "View Map Name";
        self.shadow_items[1] = "View Current Weapon";
        self.shadow_items[2] = "View Coordinates";
        self.shadow_items[3] = "View Round";
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
        self shadow_add_option("Turn On Power", "power");
        self shadow_add_option("Open All Doors & Debris", "doors");
        self shadow_add_option("Open All Doors", "doors_only");
        self shadow_add_option("Clear All Debris", "debris_only");
        self shadow_add_option("Super Jump: " + self shadow_on_off(level.shadow_super_jump), "jump");
        self shadow_add_option("Low Gravity: " + self shadow_on_off(level.shadow_low_gravity), "gravity");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 11)
    {
        if (self.shadow_key_mode == 0)
            self.shadow_items[0] = "Control Layout: WASD";
        else
            self.shadow_items[0] = "Control Layout: Classic";
        self.shadow_items[1] = "Scroll Speed: " + self shadow_scroll_speed_name();
        if (self.shadow_invert_scroll)
            self.shadow_items[2] = "Scroll Direction: Inverted";
        else
            self.shadow_items[2] = "Scroll Direction: Normal";
        if (self.shadow_swap_horizontal)
            self.shadow_items[3] = "Select: A / Back: D";
        else
            self.shadow_items[3] = "Select: D / Back: A";
        self.shadow_items[4] = "NoClip Bind: " + self shadow_noclip_bind_name();
        self.shadow_items[5] = "Reset Controls";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 12)
    {
        self.shadow_items[0] = "Challenge Progress";
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
        self shadow_add_option("Give Weapons", "page_2");
        self shadow_add_option("Equipment", "page_28");
        self shadow_add_option("Ammo & Upgrades", "page_3");
        self shadow_add_option("Bullet FX & Rounds", "page_22");
        if (self shadow_perks_available())
            self shadow_add_option("Perks", "page_9");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 14)
    {
        self shadow_add_option("Zombie Options", "page_4");
        self shadow_add_option("Points", "page_5");
        self shadow_add_option("Power-Ups", "page_27");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 15)
    {
        self shadow_add_option("Zombies & Points", "page_14");
        self shadow_add_option("World Mods", "page_10");
        self shadow_add_option("Teleport", "page_6");
        if (getDvar("mapname") == "zombie_pentagon")
            self shadow_add_option("Five Controls", "page_18");
        self shadow_add_option("Change Map [Shift+M]", "map_shortcut");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 16)
    {
        self shadow_add_option("Local Challenges", "page_12");
        self shadow_add_option("Game Info", "page_8");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 17)
    {
        self.shadow_items[0] = "Save Position A";
        self.shadow_items[1] = "Teleport to Position A";
        self.shadow_items[2] = "Save Position B";
        self.shadow_items[3] = "Teleport to Position B";
        self.shadow_items[4] = "Save Position C";
        self.shadow_items[5] = "Teleport to Position C";
        self.shadow_items[6] = "Return to Spawn";
        self.shadow_items[7] = "< Back";
    }
    else if (self.shadow_page == 18)
    {
        self.shadow_items[0] = "Activate DEFCON 5 (Power First)";
        self.shadow_items[1] = "Teleport to Top Floor";
        self.shadow_items[2] = "Teleport to War Room";
        self.shadow_items[3] = "Teleport to Labs";
        self.shadow_items[4] = "Teleport to Pack-a-Punch";
        self.shadow_items[5] = "Show DEFCON / Power Status";
        self.shadow_items[6] = "< Back";
    }
    else if (self.shadow_page == 19)
    {
        self.shadow_items[0] = "Selection Highlight: " + self shadow_on_off(self.shadow_selection_visible);
        self.shadow_items[1] = "Menu Colors";
        self.shadow_items[2] = "< Back";
    }
    else if (self.shadow_page == 20)
    {
        self shadow_add_option("Controls & Keybinds", "page_11");
        self shadow_add_option("Appearance", "page_19");
        self shadow_add_option("Performance & Safety", "page_21");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 21)
    {
        self.shadow_items[0] = "Menu Protection: " + self shadow_on_off(self.shadow_menu_auto_protect);
        self.shadow_items[1] = "Reduced Effects: " + self shadow_on_off(self.shadow_low_effects);
        self.shadow_items[2] = "Force Close Menu";
        self.shadow_items[3] = "< Back";
    }
    else if (self.shadow_page == 22)
    {
        self.shadow_items[0] = "Bullet Impact FX: " + self shadow_on_off(self.shadow_fx_enabled);
        self.shadow_items[1] = "Impact Effect: " + self shadow_fx_name();
        self.shadow_items[2] = "Bullet Damage: " + self shadow_ammo_mode_name();
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
        self.shadow_items[0] = "Add 1 Zombie to Round";
        self.shadow_items[1] = "Add 5 Zombies to Round";
        self.shadow_items[2] = "Add 10 Zombies to Round";
        self.shadow_items[3] = "Zombies Queued: " + self shadow_spawn_pending_text();
        self.shadow_items[4] = "< Back";
    }
    else if (self.shadow_page == 26)
    {
        self.shadow_items[0] = "Red: " + self.shadow_color_r;
        self.shadow_items[1] = "Green: " + self.shadow_color_g;
        self.shadow_items[2] = "Blue: " + self.shadow_color_b;
        self.shadow_items[3] = "Next Color Preset";
        self.shadow_items[4] = "Restore Default Red";
        self.shadow_items[5] = "< Back";
    }
    else if (self.shadow_page == 28)
    {
        self shadow_add_weapon("zombie_cymbal_monkey", "Monkey Bombs");
        self shadow_add_weapon("zombie_black_hole_bomb", "Gersh Device");
        self shadow_add_weapon("zombie_nesting_dolls", "Matryoshka Dolls");
        self shadow_add_weapon("frag_grenade_zm", "Frag Grenades");
        self shadow_add_weapon("sticky_grenade_zm", "Semtex Grenades");
        self shadow_add_weapon("claymore_zm", "Claymores");
        if (self.shadow_items.size == 0)
            self shadow_add_option("No special equipment on this map", "unavailable");
        self shadow_add_option("< Back", "back");
    }
    else if (self.shadow_page == 27)
    {
        self.shadow_items[0] = "Activate Nuke";
        self.shadow_items[1] = "Spawn Max Ammo";
        self.shadow_items[2] = "Spawn Insta-Kill";
        self.shadow_items[3] = "Spawn Double Points";
        self.shadow_items[4] = "Spawn Carpenter";
        self.shadow_items[5] = "Spawn Fire Sale";
        self.shadow_items[6] = "Spawn Bonfire Sale";
        self.shadow_items[7] = "Spawn Free Perk";
        self.shadow_items[8] = "Spawn Death Machine";
        self.shadow_items[9] = "< Back";
    }
}

shadow_on_off(value)
{
    if (value) return "^2ON";
    return "^1OFF";
}

shadow_scroll_speed_name()
{
    if (self.shadow_key_repeat >= 180) return "Slow";
    if (self.shadow_key_repeat >= 110) return "Normal";
    return "Fast";
}

shadow_speed_name()
{
    if (self.shadow_speed_level == 1) return "1.5x";
    if (self.shadow_speed_level == 2) return "2.0x";
    if (self.shadow_speed_level == 3) return "3.0x";
    return "Normal";
}

shadow_speed_scale()
{
    if (self.shadow_speed_level == 1) return 1.5;
    if (self.shadow_speed_level == 2) return 2.0;
    if (self.shadow_speed_level == 3) return 3.0;
    return 1.0;
}

shadow_apply_movement_dvars()
{
    if (level.shadow_super_jump)
        setDvar("jump_height", 175);
    else
        setDvar("jump_height", level.shadow_jump_default);

    if (level.shadow_low_gravity)
        setDvar("g_gravity", 400);
    else
        setDvar("g_gravity", level.shadow_gravity_default);
}

shadow_noclip_bind_name()
{
    if (self.shadow_noclip_bind == 1) return "MOUSE4";
    if (self.shadow_noclip_bind == 2) return "MOUSE5";
    if (self.shadow_noclip_bind == 3) return "F6";
    return "^1OFF";
}


shadow_cycle_noclip_bind()
{
    self.shadow_noclip_bind++;
    if (self.shadow_noclip_bind > 3)
        self.shadow_noclip_bind = 0;
    if (self.shadow_noclip_active)
        self.shadow_noclip_dirty = true;
}

shadow_request_noclip()
{
    self.shadow_noclip_active = !self.shadow_noclip_active;
    self.shadow_noclip_toggle_pending = true;
    self.shadow_noclip_dirty = true;
    if (self.shadow_open)
        self shadow_close();
    else
        self thread shadow_apply_noclip();
}

shadow_apply_noclip()
{
    self endon("disconnect");
    wait 0.15;
    if (!self.shadow_noclip_dirty && !self.shadow_noclip_toggle_pending)
        return;

    key = "";
    if (self.shadow_noclip_active)
        key = self shadow_noclip_bind_key(self.shadow_noclip_bind);
    command = "";
    if (self.shadow_noclip_bound_key != "" &&
        self.shadow_noclip_bound_key != key)
        command = "unbind " + self.shadow_noclip_bound_key;
    if (key != "")
    {
        if (command != "")
            command += ";";
        command += "bind " + key + " noclip";
    }
    if (self.shadow_noclip_toggle_pending)
    {
        if (command != "")
            command += ";";
        command += "noclip";
    }
    if (command != "")
        self setClientDvar("activeAction", command);
    self.shadow_noclip_bound_key = key;
    self.shadow_noclip_dirty = false;
    self.shadow_noclip_toggle_pending = false;
}

shadow_noclip_bind_key(value)
{
    if (value == 1) return "MOUSE4";
    if (value == 2) return "MOUSE5";
    if (value == 3) return "F6";
    return "";
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
    if (self.shadow_page == 1) return "PLAYER MODS";
    if (self.shadow_page == 2) return "GIVE WEAPON";
    if (self.shadow_page == 3) return "AMMO & UPGRADES";
    if (self.shadow_page == 4) return "ZOMBIE OPTIONS";
    if (self.shadow_page == 5) return "POINTS";
    if (self.shadow_page == 6) return "TELEPORT MENU";
    if (self.shadow_page == 7) return "AIMBOT & COMBAT";
    if (self.shadow_page == 8) return "GAME INFO";
    if (self.shadow_page == 9) return "PERKS";
    if (self.shadow_page == 10) return "WORLD MODS";
    if (self.shadow_page == 11) return "MENU CONTROLS";
    if (self.shadow_page == 12) return "LOCAL CHALLENGES";
    if (self.shadow_page == 13) return "WEAPONS";
    if (self.shadow_page == 14) return "ZOMBIES & POINTS";
    if (self.shadow_page == 15) return "LOBBY MODS";
    if (self.shadow_page == 16) return "EXTRAS";
    if (self.shadow_page == 17) return "SAVED POSITIONS";
    if (self.shadow_page == 18) return "FIVE CONTROLS";
    if (self.shadow_page == 19) return "APPEARANCE";
    if (self.shadow_page == 20) return "SETTINGS";
    if (self.shadow_page == 21) return "PERFORMANCE";
    if (self.shadow_page == 22) return "BULLET FX & ROUNDS";
    if (self.shadow_page == 23) return "MAP TELEPORTS";
    if (self.shadow_page == 24) return "ZOMBIE SPAWNER";
    if (self.shadow_page == 26) return "MENU COLORS";
    if (self.shadow_page == 27) return "POWER-UPS";
    if (self.shadow_page == 28) return "EQUIPMENT";
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
    supported = map == "zombie_theater" || map == "zombie_pentagon" ||
        map == "zombie_cod5_factory" || map == "nazi_zombie_factory" ||
        map == "zombie_cod5_asylum" || map == "nazi_zombie_asylum" ||
        map == "zombie_cosmodrome" || map == "zombie_coast" ||
        map == "zombie_temple" || map == "zombie_moon";
    if (!supported || flag("power_on"))
        return false;
    triggers = getEntArray("use_power_switch", "targetname");
    return triggers.size > 0;
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
    if (self.shadow_ammo_mode == 4) return "Burn Damage";
    return "Normal";
}

shadow_paint_page()
{
    if (!self.shadow_open || !isDefined(self.shadow_section) ||
        !isDefined(self.shadow_footer))
        return;

    shown = self.shadow_items.size;
    if (shown < 1)
        shown = 1;
    if (shown > self.shadow_visible_rows)
        shown = self.shadow_visible_rows;
    rule_y = 113 + (shown * 18) + 5;
    self.shadow_footer_rule.y = rule_y;
    self.shadow_footer_strip.y = rule_y + 3;
    self.shadow_footer.y = rule_y + 9;
    bg_height = rule_y - 49 + 45;
    if (!isDefined(self.shadow_bg_height) || self.shadow_bg_height != bg_height)
    {
        self.shadow_bg setShader("white", 220, bg_height);
        self.shadow_bg_height = bg_height;
    }

    self.shadow_section setText(self shadow_page_name());
    if (self.shadow_key_mode == 0 && self.shadow_swap_horizontal)
        self.shadow_footer setText("^7             ^1[W/S] ^7NAV ^1[A/USE] ^7SELECT ^1[D] ^7BACK\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT");
    else if (self.shadow_key_mode == 0)
        self.shadow_footer setText("^7             ^1[W/S] ^7NAV ^1[D/USE] ^7SELECT ^1[A] ^7BACK\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT");
    else
        self.shadow_footer setText("^7                  ^1[FIRE/ADS] ^7NAV ^1[USE] ^7SELECT\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT");

    for (i = 0; i < self.shadow_visible_rows; i++)
    {
        item = i + self.shadow_window;
        if (item < self.shadow_items.size)
        {
            self.shadow_rows[i] setText(self.shadow_items[item]);
            self.shadow_rows[i].color = (1, 1, 1);
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
        self.shadow_selection.y = 111 + (position * 18);
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
        self.shadow_scroll_thumb.y = 115 + (scroll_position * 18);
        if (self.shadow_scrollbar_visible &&
            self.shadow_items.size > self.shadow_visible_rows)
            self.shadow_scroll_thumb.alpha = 0.95;
        else
            self.shadow_scroll_thumb.alpha = 0;
    }
    self.shadow_page_count setText((self.shadow_cursor + 1) + " / " + self.shadow_items.size);
}

shadow_submenu_page(choice)
{
    if (!isDefined(choice))
        return -1;
    if (choice == "page_1") return 1;
    if (choice == "page_2") return 2;
    if (choice == "page_3") return 3;
    if (choice == "page_4") return 4;
    if (choice == "page_5") return 5;
    if (choice == "page_6") return 6;
    if (choice == "page_7") return 7;
    if (choice == "page_8") return 8;
    if (choice == "page_9") return 9;
    if (choice == "page_10") return 10;
    if (choice == "page_11") return 11;
    if (choice == "page_12") return 12;
    if (choice == "page_13") return 13;
    if (choice == "page_14") return 14;
    if (choice == "page_15") return 15;
    if (choice == "page_16") return 16;
    if (choice == "page_18") return 18;
    if (choice == "page_19") return 19;
    if (choice == "page_20") return 20;
    if (choice == "page_21") return 21;
    if (choice == "page_22") return 22;
    if (choice == "page_27") return 27;
    if (choice == "page_28") return 28;
    return -1;
}

shadow_activate()
{
    page = self.shadow_page;
    index = self.shadow_cursor;
    if (index < 0 || index >= self.shadow_items.size)
        return;

    choice = undefined;
    if (index < self.shadow_item_values.size)
        choice = self.shadow_item_values[index];

    if ((page == 0 || page == 13 || page == 14 ||
        page == 15 || page == 16 || page == 20) &&
        isDefined(choice))
    {
        target_page = self shadow_submenu_page(choice);
        if (target_page >= 0)
        {
            self shadow_change_page(target_page);
            return;
        }
    }

    if (index == self.shadow_items.size - 1 &&
        self.shadow_items[index] == "< Back")
    {
        self shadow_back();
        return;
    }

    if (page == 0)
        return;

    if (page == 13 || page == 14 || page == 15 || page == 16 || page == 20)
    {
        if (!isDefined(choice))
            return;
        if (choice == "map_shortcut")
            self shadow_notice("^1SHADOW ^7Shift+M opens the map launcher");
        return;
    }

    if (page == 1)
    {
        if (index == 0)
        {
            self.shadow_god = !self.shadow_god;
            if (self.shadow_god || self.shadow_menu_invuln_applied)
                self enableInvulnerability();
            else
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
        {
            self.shadow_speed_level++;
            if (self.shadow_speed_level > 3)
                self.shadow_speed_level = 0;
        }
        else if (index == 4)
        {
            if (isDefined(self.maxhealth))
                self.health = self.maxhealth;
            else
                self.health = 100;
            self shadow_notice("^1SHADOW ^7Health restored");
        }
        else if (index == 5)
        {
            self.shadow_god = false;
            self.shadow_user_notarget = false;
            self.shadow_speed_level = 0;
            if (self.shadow_noclip_active)
                self shadow_request_noclip();
            self.ignoreme = self.shadow_was_ignored ||
                (self.shadow_menu_auto_protect && self.shadow_open);
            if (!self.shadow_menu_invuln_applied)
                self disableInvulnerability();
            self shadow_notice("^1SHADOW ^7Player settings reset");
        }
    }
    else if (page == 2 || page == 28)
    {
        if (index >= self.shadow_item_values.size)
            return;
        choice = self.shadow_item_values[index];
        if (choice != "unavailable")
            self shadow_give_weapon(choice, self.shadow_items[index]);
    }
    else if (page == 3)
    {
        if (index == 0)
            self shadow_upgrade_current_weapon();
        else if (index == 1)
        {
            current = self shadow_equipped_weapon();
            if (isDefined(current) && current != "none")
                self giveMaxAmmo(current);
            self shadow_notice("^1SHADOW ^7Ammo refilled");
        }
        else if (index == 2)
        {
            weapons = self getWeaponsListPrimaries();
            for (i = 0; i < weapons.size && i < 4; i++)
                self giveMaxAmmo(weapons[i]);
            self shadow_notice("^1SHADOW ^7All carried weapons refilled");
        }
        else if (index == 3)
            self.shadow_auto_refill = !self.shadow_auto_refill;
        else if (index == 4)
            self.shadow_infinite_clip = !self.shadow_infinite_clip;
        else if (index == 5)
        {
            current = self shadow_equipped_weapon();
            if (isDefined(current) && current != "none")
            {
                self takeWeapon(current);
                self.shadow_last_hand_weapon = undefined;
            }
        }
    }
    else if (page == 4)
    {
        if (index == 0)
            self thread shadow_clear_zombies();
        else if (index == 1)
            self.shadow_zombie_counter = !self.shadow_zombie_counter;
        else if (index == 2)
        {
            zombies = getAiArray("axis");
            self shadow_notice("^1SHADOW ^7Zombies alive: " + zombies.size);
        }
        else if (index == 3)
            self thread shadow_skip_round();
        else if (index == 4)
            self shadow_change_page(24);
    }
    else if (page == 5)
    {
        amount = 1337;
        if (index == 1) amount = 1000;
        if (index == 2) amount = 5000;
        if (index == 3) amount = 10000;
        if (index == 4) amount = 50000;
        if (index == 5) amount = 100000;
        if (index == 6) amount = 0 - self.score;
        self maps\_zombiemode_score::add_to_player_score(amount);
        if (index == 6)
            self shadow_notice("^1SHADOW ^7Points reset to 0");
        else
            self shadow_notice("^1SHADOW ^7Points added: " + amount);
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
            self shadow_notice("^1SHADOW ^7Quick location saved");
        }
        else if (index == 4)
        {
            if (isDefined(self.shadow_saved_origin))
                self shadow_warp(self.shadow_saved_origin, "saved position");
            else
                self shadow_notice("^1SHADOW ^7Save a location first");
        }
        else if (index == 5)
            self shadow_teleport_to_crosshair();
        else if (index == 6)
        {
            self.shadow_spawn_origin = self.origin;
            self shadow_notice("^1SHADOW ^7Return point set");
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
        else if (index == 4)
            self.shadow_one_hit = !self.shadow_one_hit;
    }
    else if (page == 8)
    {
        if (index == 0)
            self shadow_notice("^1SHADOW ^7Map: " + getDvar("mapname"));
        else if (index == 1)
            self shadow_notice("^1SHADOW ^7Weapon: " + self getCurrentWeapon());
        else if (index == 2)
        {
            pos = self.origin;
            self shadow_notice("^1SHADOW ^7X " + pos[0] + " Y " + pos[1] + " Z " + pos[2]);
        }
        else
            self shadow_print_round();
    }
    else if (page == 9)
    {
        choice = self.shadow_item_values[index];
        if (choice == "all_perks")
        {
            for (i = 0; i < self.shadow_item_values.size; i++)
            {
                perk = self.shadow_item_values[i];
                if (perk != "all_perks" && perk != "clear_perks" && perk != "back")
                    self shadow_grant_perk(perk);
            }
            self shadow_notice("^1SHADOW ^7Available perks granted");
        }
        else if (choice == "clear_perks")
        {
            self clearPerks();
            self shadow_notice("^1SHADOW ^7Perks cleared");
        }
        else
        {
            self shadow_grant_perk(choice);
            self shadow_notice("^1SHADOW ^7Perk granted: " + self.shadow_items[index]);
        }
    }
    else if (page == 10)
    {
        choice = self.shadow_item_values[index];
        if (choice == "doors")
            self thread shadow_unlock_all_doors(0);
        else if (choice == "doors_only")
            self thread shadow_unlock_all_doors(1);
        else if (choice == "debris_only")
            self thread shadow_unlock_all_doors(2);
        else if (choice == "power")
            self thread shadow_turn_power_on();
        else if (choice == "jump")
        {
            level.shadow_super_jump = !level.shadow_super_jump;
            self shadow_apply_movement_dvars();
        }
        else if (choice == "gravity")
        {
            level.shadow_low_gravity = !level.shadow_low_gravity;
            self shadow_apply_movement_dvars();
        }
    }
    else if (page == 11)
    {
        if (index == 0)
            self.shadow_key_mode = !self.shadow_key_mode;
        else if (index == 1)
        {
            if (self.shadow_key_repeat >= 180)
                self.shadow_key_repeat = 145;
            else if (self.shadow_key_repeat >= 110)
                self.shadow_key_repeat = 75;
            else
                self.shadow_key_repeat = 215;
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
                self.shadow_noclip_dirty = true;
        }
    }
    else if (page == 17)
    {
        if (index == 6)
        {
            if (isDefined(self.shadow_spawn_origin))
                self shadow_warp(self.shadow_spawn_origin, "spawn");
            else
                self shadow_notice("^1SHADOW ^7Spawn point unavailable");
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
                self shadow_notice("^1SHADOW ^7Room bookmark saved");
            }
            else if (isDefined(self.shadow_room_slots[slot]))
                self shadow_warp(self.shadow_room_slots[slot], "room bookmark");
            else
                self shadow_notice("^1SHADOW ^7Save this room slot first");
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
    }
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
            self.shadow_color_r = 0.90;
            self.shadow_color_g = 0.035;
            self.shadow_color_b = 0.022;
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
        else if (index == 6)
            self shadow_spawn_powerup("bonfire_sale", false);
        else if (index == 7)
            self shadow_spawn_powerup("free_perk", false);
        else if (index == 8)
            self shadow_spawn_powerup("minigun", false);
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
            self shadow_notice("^1SHADOW ^7All local badges unlocked (not platform awards)");
        }
        else if (index == 7)
        {
            self.shadow_achievement_survivor = false;
            self.shadow_achievement_veteran = false;
            self.shadow_achievement_rich = false;
            self.shadow_achievement_century = false;
            self.shadow_achievement_banker = false;
            self shadow_notice("^1SHADOW ^7Local badges reset");
        }
        else
            self shadow_notice("^1SHADOW ^7Local session badges, not platform achievements");
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
        self shadow_notice("^1SHADOW ^7Round: " + level.round_number);
    else
        self shadow_notice("^1SHADOW ^7Round information unavailable");
}

shadow_spawn_pending_text()
{
    if (isDefined(level.zombie_total))
        return level.zombie_total;
    return "Unavailable";
}

shadow_queue_zombies(amount)
{
    if (!isDefined(level.zombie_total) || !isDefined(level.enemy_spawns) ||
        level.enemy_spawns.size == 0)
    {
        self shadow_notice("^1SHADOW ^7Map spawner not ready");
        return;
    }
    if (level.zombie_total + amount > 50)
    {
        self shadow_notice("^1SHADOW ^7Spawn queue capped at 50");
        return;
    }
    level.zombie_total += amount;
    self shadow_notice("^1SHADOW ^7Queued " + amount + " zombies through round spawner");
}

shadow_warp(position, label)
{
    if (!isDefined(position))
    {
        self shadow_notice("^1SHADOW ^7Teleport destination unavailable");
        return;
    }

    if (self.shadow_open)
        self.shadow_lock_origin = position;
    self setVelocity((0, 0, 0));
    self setOrigin(position);
    self shadow_notice("^1SHADOW ^7Teleported: " + label);
}

shadow_add_map_spot(label, position)
{
    if (!isDefined(position) || self.shadow_items.size >= 7)
        return;
    index = self.shadow_items.size;
    self.shadow_map_spots[index] = position;
    self shadow_add_option(label, "spot");
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
        self shadow_add_map_spot("Return Point", self.shadow_spawn_origin);

    power = getEntArray("use_power_switch", "targetname");
    if (power.size == 0)
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
        self shadow_notice("^1SHADOW ^7Five features unavailable on this map");
        return;
    }
    power_status = "OFF";
    if (flag("power_on"))
        power_status = "ON";
    if (isDefined(level.defcon_level))
        self shadow_notice("^1SHADOW ^7Power " + power_status + " / DEFCON " + level.defcon_level);
    else
        self shadow_notice("^1SHADOW ^7Power " + power_status);
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
        self shadow_notice("^1SHADOW ^7Five: activate power first");
        return;
    }
    if (flag("defcon_active"))
    {
        self shadow_notice("^1SHADOW ^7DEFCON already active - use a teleporter");
        return;
    }
    switches = getEntArray("punch_switch", "targetname");
    if (switches.size < 4)
    {
        self shadow_notice("^1SHADOW ^7DEFCON switches not initialized");
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
        self shadow_notice("^1SHADOW ^7DEFCON 5: Pack-a-Punch route active");
    else
        self shadow_notice("^1SHADOW ^7DEFCON not ready; try the War Room switches");
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
            self shadow_notice("^1SHADOW ^7Open DEFCON 5 before entering Pack room");
            return;
        }
        if (isDefined(level.portal_pack))
            self shadow_warp(level.portal_pack.origin + (0, 0, 38), "Panic Room");
        else
            self shadow_notice("^1SHADOW ^7Panic Room portal not ready");
    }
    else
        self shadow_notice("^1SHADOW ^7Five portal not ready (power may be off)");
}

shadow_give_weapon(name, label)
{
    if (!isDefined(level.zombie_weapons) ||
        !isDefined(level.zombie_weapons[name]) ||
        !isDefined(level.zombie_include_weapons) ||
        !isDefined(level.zombie_include_weapons[name]))
    {
        self shadow_notice("^1SHADOW ^7Weapon not registered on this map");
        return;
    }

    if (self hasWeapon(name))
    {
        self giveMaxAmmo(name);
        self shadow_notice("^1SHADOW ^7Ammo refilled: " + label);
        return;
    }

    self maps\_zombiemode_weapons::weapon_give(name);
    if (self hasWeapon(name))
        self shadow_notice("^1SHADOW ^7Equipped: " + label);
    else
        self shadow_notice("^1SHADOW ^7Game rejected this item");
}

shadow_equipped_weapon()
{
    current = self getCurrentWeapon();
    if (!isDefined(current) || current == "none" || !self hasWeapon(current))
        current = self.shadow_last_hand_weapon;
    if (isDefined(current) && current != "none" && self hasWeapon(current))
        return current;
    return "none";
}

shadow_upgrade_current_weapon()
{
    current = self getCurrentWeapon();
    if (!isDefined(current) || current == "none" || !self hasWeapon(current))
        current = self.shadow_last_hand_weapon;
    if (!isDefined(current) || current == "none" || !self hasWeapon(current))
    {
        self shadow_notice("^1SHADOW ^7No equipped weapon found");
        return;
    }

    if (current == "microwavegun_zm" && self hasWeapon("microwavegundw_zm"))
        current = "microwavegundw_zm";

    if (!isDefined(level.zombie_weapons) ||
        !isDefined(level.zombie_weapons[current]) ||
        !isDefined(level.zombie_weapons[current].upgrade_name) ||
        self maps\_zombiemode_weapons::is_weapon_upgraded(current))
    {
        self shadow_notice("^1SHADOW ^7Already upgraded or not Pack-a-Punchable");
        return;
    }
    upgraded = level.zombie_weapons[current].upgrade_name;
    if (!isDefined(upgraded) || upgraded == "" || upgraded == current)
    {
        self shadow_notice("^1SHADOW ^7No Pack-a-Punch version on this map");
        return;
    }

    old_clip = self getWeaponAmmoClip(current);
    old_stock = self getWeaponAmmoStock(current);
    self takeWeapon(current);
    self giveWeapon(upgraded, 0,
        self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options(upgraded));
    if (!self hasWeapon(upgraded))
    {
        self giveWeapon(current);
        if (self hasWeapon(current))
        {
            self setWeaponAmmoClip(current, old_clip);
            self setWeaponAmmoStock(current, old_stock);
            self switchToWeapon(current);
        }
        self shadow_notice("^1SHADOW ^7Upgrade failed; original weapon restored");
        return;
    }

    self giveStartAmmo(upgraded);
    self switchToWeapon(upgraded);
    self.shadow_last_hand_weapon = upgraded;
    self shadow_notice("^1SHADOW ^7Pack-a-Punched equipped weapon");
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
            wait 0.25;
        else
            wait 1.0;
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
            wait 0.55;
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
                    getTime() - self.shadow_last_fx >=
                    self shadow_fx_cooldown())
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
                        else if (self.shadow_ammo_mode == 4 &&
                            (!isDefined(victim.shadow_burn_active) || !victim.shadow_burn_active))
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
        {
            if (isDefined(victim))
                victim.shadow_burn_active = false;
            return;
        }
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
            for (i = 0; i < zombies.size && i < 128; i++)
            {
                if (isDefined(zombies[i]) && isAlive(zombies[i]) && zombies[i].health > 1)
                    zombies[i].health = 1;
            }
        }
        if (self.shadow_one_hit)
            wait 0.75;
        else
            wait 1.5;
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
            self shadow_notice("^1SHADOW GARDEN ^7Challenge: Survivor V");
        }
        if (isDefined(level.round_number) && level.round_number >= 10 &&
            !self.shadow_achievement_veteran)
        {
            self.shadow_achievement_veteran = true;
            self shadow_notice("^1SHADOW GARDEN ^7Challenge: Veteran X");
        }
        if (isDefined(self.score) && self.score >= 10000 &&
            !self.shadow_achievement_rich)
        {
            self.shadow_achievement_rich = true;
            self shadow_notice("^1SHADOW GARDEN ^7Challenge: Wealth 10K");
        }
        if (isDefined(self.kills) && self.kills >= 100 &&
            !self.shadow_achievement_century)
        {
            self.shadow_achievement_century = true;
            self shadow_notice("^1SHADOW GARDEN ^7Challenge: Hunter 100");
        }
        if (isDefined(self.score) && self.score >= 100000 &&
            !self.shadow_achievement_banker)
        {
            self.shadow_achievement_banker = true;
            self shadow_notice("^1SHADOW GARDEN ^7Challenge: Banker 100K");
        }
        wait 4;
    }
}

shadow_create_counter_hud()
{
    self.shadow_count_hud = newClientHudElem(self);
    self.shadow_count_hud.horzAlign = "left";
    self.shadow_count_hud.vertAlign = "top";
    self.shadow_count_hud.alignX = "left";
    self.shadow_count_hud.alignY = "top";
    self.shadow_count_hud.x = 18;
    self.shadow_count_hud.y = 121;
    self.shadow_count_hud.font = "default";
    self.shadow_count_hud.fontScale = 1.05;
    self.shadow_count_hud.color = self shadow_accent();
    self.shadow_count_hud.alpha = 1;
    self.shadow_count_hud.sort = 8;
    self.shadow_count_hud.hideWhenInMenu = false;
    self.shadow_count_hud setText("ZOMBIES  0");
}

shadow_remove_counter_hud()
{
    if (isDefined(self.shadow_count_hud))
        self.shadow_count_hud destroy();
    self.shadow_count_hud = undefined;
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
                self shadow_create_counter_hud();
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
                self shadow_remove_counter_hud();
            last_count = -1;
        }
        wait 0.5;
    }
}

shadow_aimbot_loop()
{
    self endon("disconnect");
    old_attack = false;

    while (self.shadow_running)
    {
        if (self.shadow_open ||
            (!self.shadow_classic_aimbot && !self.shadow_unfair_aimbot))
        {
            self.shadow_aim_target = undefined;
            old_attack = false;
            wait 0.55;
            continue;
        }

        attack = self attackButtonPressed();
        aim_active = self.shadow_classic_aimbot &&
            (self adsButtonPressed() || self.shadow_aim_always);
        shoot_active = self.shadow_unfair_aimbot && attack && !old_attack &&
            getTime() - self.shadow_unfair_last_shot >= 280;

        if (aim_active || shoot_active)
        {
            if (getTime() >= self.shadow_aim_next_scan ||
                !isDefined(self.shadow_aim_target) ||
                !isAlive(self.shadow_aim_target))
            {
                self.shadow_aim_target = self shadow_nearest_zombie();
                self.shadow_aim_next_scan = getTime() + 250;
            }

            target = self.shadow_aim_target;
            if (isDefined(target) && isAlive(target) &&
                distance(self.origin, target.origin) < 4200)
            {
                hit = target.origin + (0, 0, 37);
                if (self.shadow_aim_bone == "j_head")
                    hit = target.origin + (0, 0, 55);

                if (aim_active)
                    self setPlayerAngles(vectorToAngles(hit - self getEye()));

                if (shoot_active)
                {
                    weapon = self getCurrentWeapon();
                    if (isDefined(weapon) && weapon != "none" && target.health > 0)
                    {
                        self.shadow_unfair_last_shot = getTime();
                        target doDamage(target.health + 100, hit, self);
                    }
                }
            }
        }

        old_attack = attack;
        wait 0.075;
    }
}

shadow_nearest_zombie()
{
    zombies = getAiArray("axis");
    best = undefined;
    best_distance = 4200;
    for (i = 0; i < zombies.size && i < 112; i++)
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
    self shadow_notice("^1SHADOW ^7Spawned zombies cleared");
    self.shadow_busy_clear = false;
}

shadow_skip_round()
{
    self endon("disconnect");

    if (!isDefined(level.round_number) || !flag("begin_spawning") ||
        is_true(level.intermission) || is_true(level.dog_intermission))
    {
        self shadow_notice("^1SHADOW ^7Wait for an active round");
        return;
    }
    if ((isDefined(level.shadow_skip_round_busy) && level.shadow_skip_round_busy) ||
        (isDefined(level.shadow_last_round_skip) &&
        getTime() - level.shadow_last_round_skip < 3000))
        return;

    level.shadow_skip_round_busy = true;
    level.shadow_last_round_skip = getTime();
    old_round = level.round_number;

    level.zombie_total = 0;
    for (pass = 0; pass < 4; pass++)
    {
        zombies = getAiArray("axis");
        for (i = 0; i < zombies.size && i < 128; i++)
        {
            if (isDefined(zombies[i]) && isAlive(zombies[i]))
                zombies[i] doDamage(zombies[i].health + 1000, zombies[i].origin, self);
        }
        wait 0.10;
    }
    if (level.round_number == old_round)
        level.zombie_total = 0;
    level.shadow_skip_round_busy = false;
    self shadow_notice("^1SHADOW ^7Round " + old_round + " cleared; advancing");
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
        self.shadow_color_r = 0.90;
        self.shadow_color_g = 0.035;
        self.shadow_color_b = 0.022;
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
    if (isDefined(self.shadow_footer_rule))
        self.shadow_footer_rule.color = self shadow_accent();
    if (isDefined(self.shadow_scroll_thumb))
        self.shadow_scroll_thumb.color = self shadow_accent();
    self shadow_paint_cursor();
}

shadow_spawn_powerup(type, activate)
{
    if (!isDefined(level.zombie_powerups) ||
        !isDefined(level.zombie_powerups[type]))
    {
        self shadow_notice("^1SHADOW ^7Power-up unavailable on this map");
        return false;
    }
    if (getTime() - self.shadow_last_powerup_drop < 1200)
    {
        self shadow_notice("^1SHADOW ^7Wait before spawning another power-up");
        return false;
    }
    self.shadow_last_powerup_drop = getTime();
    if (activate)
        point = self.origin;
    else
        point = self.origin + (anglesToForward(self getPlayerAngles()) * 96);
    level thread maps\_zombiemode_powerups::specific_powerup_drop(type, point);
    self shadow_notice("^1SHADOW ^7Power-up spawned: " + type);
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
        self shadow_notice("^1SHADOW ^7No safe crosshair surface found");
        return;
    }

    landing = trace["position"] + (0, 0, 42);
    if (isDefined(trace["normal"]))
        landing += trace["normal"] * 24;
    self shadow_warp(landing, "crosshair impact");
}

shadow_unlock_all_doors(mode)
{
    self endon("disconnect");
    if (self.shadow_busy_doors)
        return;
    self.shadow_busy_doors = true;
    if (!flag("begin_spawning"))
    {
        self shadow_notice("^1SHADOW ^7Wait for map blockers to initialize");
        self.shadow_busy_doors = false;
        return;
    }

    previous_unlock = getDvarInt("zombie_unlock_all");
    if (!isDefined(level.shadow_unlock_serial))
        level.shadow_unlock_serial = 0;
    level.shadow_unlock_serial++;
    level thread shadow_restore_unlock_failsafe(previous_unlock,
        level.shadow_unlock_serial);
    setDvar("zombie_unlock_all", 1);
    count = 0;
    if (mode != 2)
    {
        count += self shadow_open_blockers("zombie_door");
        count += self shadow_open_blockers("zombie_doors");
    }
    if (mode != 1)
    {
        count += self shadow_open_blockers("zombie_debris");
        count += self shadow_open_blockers("zombie_airlock_buy");
        count += self shadow_open_blockers("buyable_stairs");
    }
    wait 0.15;
    setDvar("zombie_unlock_all", previous_unlock);
    self.shadow_busy_doors = false;
    if (count == 0)
        self shadow_notice("^1SHADOW ^7No compatible unopened blockers found");
    else
        self shadow_notice("^1SHADOW ^7Sent " + count + " forced opening requests");
}

shadow_open_blockers(name)
{
    blockers = getEntArray(name, "targetname");
    count = 0;
    for (i = 0; i < blockers.size && i < 96; i++)
    {
        blocker = blockers[i];
        if (!isDefined(blocker))
            continue;
        if (isDefined(blocker._door_open) && blocker._door_open)
            continue;
        blocker notify("trigger", self, true);
        count++;
        wait 0.025;
    }
    return count;
}

shadow_restore_unlock_failsafe(previous, serial)
{
    wait 18;
    if (level.shadow_unlock_serial == serial &&
        getDvarInt("zombie_unlock_all") == 1 && previous != 1)
        setDvar("zombie_unlock_all", previous);
}

shadow_turn_power_on()
{
    self endon("disconnect");
    if (flag("power_on"))
    {
        self shadow_notice("^1SHADOW ^7Power is already on");
        return;
    }
    if (!flag("begin_spawning"))
    {
        self shadow_notice("^1SHADOW ^7Wait for map power to initialize");
        return;
    }
    switches = getEntArray("use_power_switch", "targetname");
    if (switches.size == 0)
        switches = getEntArray("use_elec_switch", "targetname");
    if (switches.size == 0)
    {
        self shadow_notice("^1SHADOW ^7No scripted power switch on this map");
        return;
    }

    switches[0] notify("trigger", self);
    wait 0.90;
    if (flag("power_on"))
        self shadow_notice("^1SHADOW ^7Map power is now ON");
    else
        self shadow_notice("^1SHADOW ^7Map rejected power request");
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

shadow_fx_cooldown()
{
    if (self.shadow_low_effects)
        return 900;
    return 300;
}

shadow_notice(value)
{
    if (!isDefined(self.shadow_notice_bg))
    {
        self.shadow_notice_bg = newClientHudElem(self);
        self.shadow_notice_bg.horzAlign = "left";
        self.shadow_notice_bg.vertAlign = "bottom";
        self.shadow_notice_bg.alignX = "left";
        self.shadow_notice_bg.alignY = "bottom";
        self.shadow_notice_bg.x = 20;
        self.shadow_notice_bg.y = -128;
        self.shadow_notice_bg.color = self shadow_accent();
        self.shadow_notice_bg.sort = 25;
        self.shadow_notice_bg setShader("white", 120, 2);
        self.shadow_notice_bg.hideWhenInMenu = false;

        self.shadow_notice_text = newClientHudElem(self);
        self.shadow_notice_text.horzAlign = "left";
        self.shadow_notice_text.vertAlign = "bottom";
        self.shadow_notice_text.alignX = "left";
        self.shadow_notice_text.alignY = "bottom";
        self.shadow_notice_text.x = 20;
        self.shadow_notice_text.y = -144;
        self.shadow_notice_text.font = "default";
        self.shadow_notice_text.fontScale = 0.96;
        self.shadow_notice_text.color = (1, 1, 1);
        self.shadow_notice_text.sort = 26;
        self.shadow_notice_text.hideWhenInMenu = false;
    }

    self.shadow_notice_bg.alpha = 1;
    self.shadow_notice_text.alpha = 1;
    self.shadow_notice_bg.color = self shadow_accent();
    self.shadow_notice_text setText(value);
    self.shadow_notice_expires = getTime() + 5500;
}
