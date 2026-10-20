/* Shadow Garden 1.3 */
(() => {
  'use strict';
  const VERSION = '1.3';
  const SOURCES = JSON.parse([
    "{\"hooks\":\"// Shadow Garden hooks\\n\\n#include common_scripts\\\\utility;\\n#include maps\\\\_utility;\\n\\nregister()\\n{\\n    maps\\\\_modstack::add( \\\"_zombiemode_ffotd::main_end\\\", ::main_end );\\n    maps\\\\_modstack::add( \\\"zombie_pentagon_ffotd::main_end\\\", ::main_end );\\n}\\n\\nmain_end()\\n{\\n    if (isDefined(level.shadow_hook_started))\\n        return;\\n    level.shadow_hook_started = true;\\n    level thread shadow_new_connections();\\n    level thread shadow_existing_players();\\n}\\n\\nshadow_new_connections()\\n{\\n    for (;;)\\n    {\\n        level waittill( \\\"connecting\\\", player );\\n        player thread shadow_attach();\\n    }\\n}\\n\\nshadow_existing_players()\\n{\\n    for (check = 0; check < 24; check++)\\n    {\\n        players = get_players();\\n        for (i = 0; i < players.size; i++)\\n        {\\n            if (!isDefined(players[i].shadow_attached))\\n                players[i] thread shadow_attach();\\n        }\\n        wait 0.25;\\n    }\\n}\\n\\nshadow_attach()\\n{\\n    self endon( \\\"disconnect\\\" );\\n    if (IsDefined(self.shadow_attached) && self.shadow_attached)\\n        return;\\n\\n    ",
    "self.shadow_attached = true;\\n    self thread maps\\\\mod_shadow\\\\_shadow_menu::shadow_player_init();\\n}\\n\",\"menu\":\"/* SHADOW GARDEN GSC - BO1 Zombies v1.3.13 */\\n\\n#include common_scripts\\\\utility;\\n#include maps\\\\_utility;\\n\\nshadow_player_init()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    if (isDefined(self.shadow_running) && self.shadow_running)\\n        return;\\n\\n    self.shadow_running = true;\\n    self.shadow_input_last_tick = getTime();\\n    self.shadow_menu_opened_at = -10000;\\n    self.shadow_open = false;\\n    self.shadow_closing = false;\\n    self.shadow_was_ignored = false;\\n    self.shadow_menu_invuln_applied = false;\\n    self.shadow_page = 0;\\n    self.shadow_cursor = 0;\\n    self.shadow_window = 0;\\n    self.shadow_visible_rows = 8;\\n    self.shadow_rows = [];\\n    self.shadow_items = [];\\n    self.shadow_item_values = [];\\n    self.shadow_navigation_pages = [];\\n    self.shadow_navigation_cursors = [];\\n    self.shadow_navigation_depth = 0;\\n\\n    self.shadow_god = false;\\n    self.shadow_user_notarget = false;\\n    self.shadow_spawn_origin = undefined;\\n    self.shad",
    "ow_lock_origin = undefined;\\n    self.shadow_lock_angles = undefined;\\n    self.shadow_controls_frozen_by_menu = false;\\n    self.shadow_room_slots = [];\\n    self.shadow_map_spots = [];\\n    self.shadow_shoot_tp = false;\\n    self.shadow_last_shoot_tp = -10000;\\n    self.shadow_fx_enabled = false;\\n    self.shadow_fx_style = 0;\\n    self.shadow_last_fx = -10000;\\n    self.shadow_nuke_rounds = false;\\n    self.shadow_last_nuke_shot = -10000;\\n    self.shadow_speed_level = 0;\\n    if (!isDefined(level.shadow_jump_default))\\n    {\\n        level.shadow_jump_default = getDvarInt(\\\"jump_height\\\");\\n        if (level.shadow_jump_default <= 0)\\n            level.shadow_jump_default = 39;\\n    }\\n    if (!isDefined(level.shadow_gravity_default))\\n    {\\n        level.shadow_gravity_default = getDvarInt(\\\"g_gravity\\\");\\n        if (level.shadow_gravity_default <= 0)\\n            level.shadow_gravity_default = 800;\\n    }\\n    if (!isDefined(level.shadow_super_jump))\\n        level.shadow_super_jump = false;\\n    if (!isDefined(level.shadow_low_gravity))\\n        level.shadow_low_gravity = fa",
    "lse;\\n    self.shadow_auto_refill = false;\\n    self.shadow_infinite_clip = false;\\n    self.shadow_ammo_mode = 0;\\n    self.shadow_one_hit = false;\\n    self.shadow_zombie_counter = false;\\n    self.shadow_count_hud = undefined;\\n    self.shadow_notice_bg = undefined;\\n    self.shadow_notice_text = undefined;\\n    self.shadow_notice_expires = 0;\\n    self.shadow_saved_origin = undefined;\\n    self.shadow_last_hand_weapon = undefined;\\n    self.shadow_classic_aimbot = false;\\n    self.shadow_unfair_aimbot = false;\\n    self.shadow_aim_target = undefined;\\n    self.shadow_aim_next_scan = 0;\\n    self.shadow_unfair_last_shot = -10000;\\n    self.shadow_aim_always = false;\\n    self.shadow_aim_bone = \\\"j_head\\\";\\n    self.shadow_key_mode = 0;\\n    self.shadow_noclip_bind = 1;\\n    self.shadow_noclip_active = false;\\n    self.shadow_noclip_bound_key = \\\"\\\";\\n    self.shadow_noclip_dirty = false;\\n    self.shadow_noclip_toggle_pending = false;\\n    self.shadow_key_repeat = 215;\\n    self.shadow_invert_scroll = false;\\n    self.shadow_swap_horizontal = false;\\n    self.shadow_color_r = 0.90",
    ";\\n    self.shadow_color_g = 0.035;\\n    self.shadow_color_b = 0.022;\\n    self.shadow_last_powerup_drop = -5000;\\n    self.shadow_palette = 0;\\n    self.shadow_low_effects = false;\\n    self.shadow_selection_visible = true;\\n    self.shadow_scrollbar_visible = false;\\n    self.shadow_busy_defcon = false;\\n    self.shadow_busy_doors = false;\\n    self.shadow_busy_clear = false;\\n    self.shadow_defcon_last = -10000;\\n    self.shadow_menu_auto_protect = true;\\n    self.shadow_achievement_survivor = false;\\n    self.shadow_achievement_veteran = false;\\n    self.shadow_achievement_rich = false;\\n    self.shadow_achievement_century = false;\\n    self.shadow_achievement_banker = false;\\n\\n    self thread shadow_input_loop();\\n    self thread shadow_refill_loop();\\n    self thread shadow_aimbot_loop();\\n    self thread shadow_counter_loop();\\n    self thread shadow_ammo_effect_loop();\\n    self thread shadow_achievement_loop();\\n    self thread shadow_one_hit_loop();\\n    self thread shadow_safety_watchdog();\\n}\\n\\nshadow_safety_watchdog()\\n{\\n    self endon(\\\"disconnect\\\");\\n    for (;;)\\",
    "n    {\\n        if (self.shadow_open && !self.shadow_closing &&\\n            getTime() - self.shadow_menu_opened_at > 350 &&\\n            (!isDefined(self.shadow_bg) || !isDefined(self.shadow_title) ||\\n            !isDefined(self.shadow_section) ||\\n            !isDefined(self.shadow_selection) ||\\n            self.shadow_rows.size != self.shadow_visible_rows ||\\n            getTime() - self.shadow_input_last_tick > 2000))\\n        {\\n            self shadow_close();\\n            self shadow_notice(\\\"^1SHADOW ^7Menu reset after an error\\\");\\n        }\\n        if (isDefined(self.shadow_notice_bg) &&\\n            isDefined(self.shadow_notice_text) &&\\n            self.shadow_notice_expires != 0)\\n        {\\n            remaining = self.shadow_notice_expires - getTime();\\n            if (remaining <= 0)\\n            {\\n                self.shadow_notice_bg.alpha = 0;\\n                self.shadow_notice_text.alpha = 0;\\n                self.shadow_notice_expires = 0;\\n            }\\n            else if (remaining < 800)\\n            {\\n                self.shadow_notice_bg.alpha = rema",
    "ining / 800.0;\\n                self.shadow_notice_text.alpha = remaining / 800.0;\\n            }\\n        }\\n        wait 0.25;\\n    }\\n}\\n\\nshadow_input_loop()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    old_ads = false;\\n    old_melee = false;\\n    old_attack = false;\\n    old_use = false;\\n    old_jump = false;\\n    old_right = false;\\n    old_left = false;\\n    next_nav = 0;\\n\\n    for (;;)\\n    {\\n        self.shadow_input_last_tick = getTime();\\n        ads = self adsButtonPressed();\\n        melee = self meleeButtonPressed();\\n        attack = self attackButtonPressed();\\n        use = self useButtonPressed();\\n        jump = self jumpButtonPressed();\\n\\n        if (!self.shadow_open)\\n        {\\n            if (ads && melee && (!old_ads || !old_melee))\\n            {\\n                self shadow_show();\\n                next_nav = getTime() + 180;\\n            }\\n            old_right = false;\\n            old_left = false;\\n        }\\n        else\\n        {\\n            if (isDefined(self.shadow_lock_origin))\\n            {\\n                self setVelocity((0, 0, 0));\\n   ",
    "             if (distance(self.origin, self.shadow_lock_origin) > 2)\\n                    self setOrigin(self.shadow_lock_origin);\\n            }\\n            if (isDefined(self.shadow_lock_angles))\\n                self setPlayerAngles(self.shadow_lock_angles);\\n\\n            movement = self getNormalizedMovement();\\n            if (!isDefined(movement))\\n                movement = (0, 0, 0);\\n            w = movement[0] > 0.50;\\n            s = movement[0] < -0.50;\\n            d = movement[1] > 0.50;\\n            a = movement[1] < -0.50;\\n\\n            select_key = d && !old_right;\\n            back_key = a && !old_left;\\n            up_key = w;\\n            down_key = s;\\n            if (self.shadow_swap_horizontal)\\n            {\\n                select_key = a && !old_left;\\n                back_key = d && !old_right;\\n            }\\n            if (self.shadow_invert_scroll)\\n            {\\n                up_key = s;\\n                down_key = w;\\n            }\\n\\n            if (ads && melee && (!old_ads || !old_melee))\\n            {\\n                self shadow_close();\\n",
    "                next_nav = getTime() + 200;\\n            }\\n            else if (melee && !old_melee)\\n            {\\n                if (self.shadow_page == 0)\\n                    self shadow_close();\\n                else\\n                    self shadow_back();\\n                next_nav = getTime() + 140;\\n            }\\n            else if ((self.shadow_key_mode == 0 && select_key) ||\\n                (use && !old_use) || (jump && !old_jump))\\n            {\\n                self shadow_activate();\\n                next_nav = getTime() + 130;\\n            }\\n            else if (self.shadow_key_mode == 0 && back_key)\\n            {\\n                self shadow_back();\\n                next_nav = getTime() + 130;\\n            }\\n            else if (getTime() >= next_nav)\\n            {\\n                if ((self.shadow_key_mode == 0 && down_key) ||\\n                    (attack && !old_attack))\\n                {\\n                    self shadow_move(1);\\n                    next_nav = getTime() + self.shadow_key_repeat;\\n                }\\n                else if ((self.shadow_ke",
    "y_mode == 0 && up_key) ||\\n                    (ads && !old_ads))\\n                {\\n                    self shadow_move(-1);\\n                    next_nav = getTime() + self.shadow_key_repeat;\\n                }\\n            }\\n            old_right = d;\\n            old_left = a;\\n        }\\n\\n        old_ads = ads;\\n        old_melee = melee;\\n        old_attack = attack;\\n        old_use = use;\\n        old_jump = jump;\\n        if (self.shadow_open)\\n            wait 0.04;\\n        else\\n            wait 0.07;\\n    }\\n}\\n\\nshadow_show()\\n{\\n    if (self.shadow_open || self.shadow_closing)\\n        return;\\n\\n    self.shadow_open = true;\\n    self.shadow_menu_opened_at = getTime();\\n    if (!isDefined(self.shadow_spawn_origin))\\n        self.shadow_spawn_origin = self.origin;\\n    self.shadow_lock_origin = self.origin;\\n    self.shadow_lock_angles = self getPlayerAngles();\\n    self.shadow_controls_frozen_by_menu = true;\\n    self freezeControls(true);\\n    self thread shadow_hold_view();\\n    self.shadow_last_hand_weapon = self getCurrentWeapon();\\n    self setVelocity((0, 0, ",
    "0));\\n    self setMoveSpeedScale(0);\\n    self.shadow_was_ignored = isDefined(self.ignoreme) && self.ignoreme;\\n    self.shadow_menu_invuln_applied = false;\\n    if (self.shadow_menu_auto_protect)\\n    {\\n        self.ignoreme = true;\\n        self enableInvulnerability();\\n        self.shadow_menu_invuln_applied = true;\\n    }\\n    self disableWeapons();\\n    self shadow_define_page();\\n    if (self.shadow_cursor >= self.shadow_items.size)\\n        self.shadow_cursor = self.shadow_items.size - 1;\\n    if (self.shadow_cursor < 0)\\n        self.shadow_cursor = 0;\\n    if (self.shadow_window > self.shadow_cursor)\\n        self.shadow_window = self.shadow_cursor;\\n    if (self.shadow_window < 0)\\n        self.shadow_window = 0;\\n    if (self.shadow_cursor >= self.shadow_window + self.shadow_visible_rows)\\n        self.shadow_window = self.shadow_cursor - self.shadow_visible_rows + 1;\\n\\n    self.shadow_bg = self shadow_center_bar(0, 49, 220, 240,\\n        (0.018, 0.020, 0.031), 0.94, 3);\\n    self.shadow_top = self shadow_center_bar(0, 49, 216, 42,\\n        (0.051, 0.018, 0.016), 0.98, ",
    "4);\\n    self.shadow_rule = self shadow_center_bar(0, 91, 198, 2,\\n        self shadow_accent(), 0.90, 5);\\n    self.shadow_selection = self shadow_center_bar(0, 111, 194, 18,\\n        (0.32, 0.025, 0.020), 0.94, 5);\\n\\n    self.shadow_title = self shadow_center_text(\\\"SHADOWGARDEN GSC MENU\\\", -5, 52, 1.20,\\n        (1, 1, 1), 7);\\n    self.shadow_title.alignX = \\\"center\\\";\\n    self.shadow_title.glowColor = (1, 0.02, 0.015);\\n    self.shadow_title.glowAlpha = 0.55;\\n    self.shadow_subtitle = self shadow_center_text(\\\"BY ^1JOSHUA ^7| DISCORD.GG/^1SHADOWGARDEN\\\", -15, 71,\\n        1.05, (0.88, 0.82, 0.82), 7);\\n    self.shadow_subtitle.alignX = \\\"center\\\";\\n    self.shadow_subtitle.glowColor = (1, 0.025, 0.018);\\n    self.shadow_subtitle.glowAlpha = 0.20;\\n    self.shadow_section = self shadow_center_text(\\\"MAIN MENU\\\", -96, 98,\\n        1.05, self shadow_accent(), 7);\\n    self.shadow_page_count = self shadow_center_text(\\\"1 / 1\\\", 72, 98,\\n        1.05, (0.85, 0.85, 0.85), 7);\\n\\n    for (i = 0; i < self.shadow_visible_rows; i++)\\n    {\\n        self.shadow_rows[i] = self shadow_ce",
    "nter_text(\\\" \\\", -86, 113 + (i * 18),\\n            1.03, (1, 1, 1), 7);\\n    }\\n\\n    self.shadow_footer_rule = self shadow_center_bar(0, 244, 220, 2,\\n        self shadow_accent(), 0.85, 5);\\n    self.shadow_footer_strip = self shadow_center_bar(0, 247, 220, 41,\\n        (0.11, 0.018, 0.016), 0.90, 4);\\n    self.shadow_footer = self shadow_center_text(\\\"^7             ^1[W/S] ^7NAV ^1[D/USE] ^7SELECT ^1[A] ^7BACK\\\\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT\\\", -24, 253,\\n        1.05, (1, 0.92, 0.90), 7);\\n    self.shadow_footer.alignX = \\\"center\\\";\\n    self.shadow_footer.fontScale = 0.98;\\n    self shadow_paint_page();\\n    self.shadow_footer.alpha = 0.92;\\n    self thread shadow_title_cycle();\\n}\\n\\nshadow_hold_view()\\n{\\n    self endon(\\\"disconnect\\\");\\n    self endon(\\\"shadow_menu_closed\\\");\\n    for (;;)\\n    {\\n        if (!self.shadow_open || !isDefined(self.shadow_lock_angles))\\n            return;\\n        if (distance(self getPlayerAngles(), self.shadow_lock_angles) > 0.01)\\n            self setPlayerAngles(self.shadow_lock_angles);\\n        wait 0.02;\\n    ",
    "}\\n}\\n\\nshadow_title_cycle()\\n{\\n    self endon(\\\"disconnect\\\");\\n    self endon(\\\"shadow_menu_closed\\\");\\n    for (;;)\\n    {\\n        if (!self.shadow_open || !isDefined(self.shadow_title))\\n            return;\\n        self.shadow_title.color = (1, 0.02, 0.015);\\n        self.shadow_title.glowAlpha = 0.82;\\n        wait 2.3;\\n        self.shadow_title.color = (1, 1, 1);\\n        self.shadow_title.glowAlpha = 0.55;\\n        wait 2.3;\\n    }\\n}\\n\\nshadow_close()\\n{\\n    if (!self.shadow_open)\\n        return;\\n\\n    self.shadow_open = false;\\n    self.shadow_closing = true;\\n    self notify(\\\"shadow_menu_closed\\\");\\n    self.shadow_lock_origin = undefined;\\n    self.shadow_lock_angles = undefined;\\n    self setVelocity((0, 0, 0));\\n    if (self.shadow_controls_frozen_by_menu)\\n        self freezeControls(false);\\n    self.shadow_controls_frozen_by_menu = false;\\n    self enableWeapons();\\n    self setMoveSpeedScale(self shadow_speed_scale());\\n    self.ignoreme = self.shadow_user_notarget || self.shadow_was_ignored;\\n    if (!self.shadow_god && self.shadow_menu_invuln_applied)\\n    ",
    "    self disableInvulnerability();\\n    self.shadow_menu_invuln_applied = false;\\n    if (self.shadow_noclip_dirty || self.shadow_noclip_toggle_pending)\\n        self thread shadow_apply_noclip();\\n\\n    for (i = 0; i < self.shadow_visible_rows; i++)\\n    {\\n        if (isDefined(self.shadow_rows[i]))\\n            self.shadow_rows[i] destroy();\\n    }\\n\\n    if (isDefined(self.shadow_footer))\\n        self.shadow_footer destroy();\\n    if (isDefined(self.shadow_footer_rule))\\n        self.shadow_footer_rule destroy();\\n    if (isDefined(self.shadow_footer_strip))\\n        self.shadow_footer_strip destroy();\\n    if (isDefined(self.shadow_scroll_thumb))\\n        self.shadow_scroll_thumb destroy();\\n    if (isDefined(self.shadow_selection))\\n        self.shadow_selection destroy();\\n    if (isDefined(self.shadow_section))\\n        self.shadow_section destroy();\\n    if (isDefined(self.shadow_page_count))\\n        self.shadow_page_count destroy();\\n    if (isDefined(self.shadow_subtitle))\\n        self.shadow_subtitle destroy();\\n    if (isDefined(self.shadow_title))\\n        self.shado",
    "w_title destroy();\\n    if (isDefined(self.shadow_rule))\\n        self.shadow_rule destroy();\\n    if (isDefined(self.shadow_edge))\\n        self.shadow_edge destroy();\\n    if (isDefined(self.shadow_top))\\n        self.shadow_top destroy();\\n    if (isDefined(self.shadow_bg))\\n        self.shadow_bg destroy();\\n    self.shadow_bg_height = undefined;\\n\\n    self.shadow_rows = [];\\n    self.shadow_items = [];\\n    self.shadow_item_values = [];\\n    self.shadow_closing = false;\\n    self.shadow_footer = undefined;\\n    self.shadow_footer_rule = undefined;\\n    self.shadow_footer_strip = undefined;\\n    self.shadow_scroll_thumb = undefined;\\n    self.shadow_selection = undefined;\\n    self.shadow_section = undefined;\\n    self.shadow_page_count = undefined;\\n    self.shadow_subtitle = undefined;\\n    self.shadow_title = undefined;\\n    self.shadow_rule = undefined;\\n    self.shadow_edge = undefined;\\n    self.shadow_top = undefined;\\n    self.shadow_bg = undefined;\\n\\n}\\n\\nshadow_move(direction)\\n{\\n    count = self.shadow_items.size;\\n    if (count == 0)\\n        return;\\n\\n    self.sh",
    "adow_cursor += direction;\\n    if (self.shadow_cursor < 0)\\n        self.shadow_cursor = count - 1;\\n    if (self.shadow_cursor >= count)\\n        self.shadow_cursor = 0;\\n\\n    old_window = self.shadow_window;\\n    if (self.shadow_cursor < self.shadow_window)\\n        self.shadow_window = self.shadow_cursor;\\n    if (self.shadow_cursor >= self.shadow_window + self.shadow_visible_rows)\\n        self.shadow_window = self.shadow_cursor - (self.shadow_visible_rows - 1);\\n    if (old_window != self.shadow_window)\\n        self shadow_paint_page();\\n    else\\n        self shadow_paint_cursor();\\n}\\n\\nshadow_change_page(page)\\n{\\n    if (!isDefined(page) || page < 0 || page > 28)\\n        return;\\n    if (self.shadow_navigation_depth < 10)\\n    {\\n        self.shadow_navigation_pages[self.shadow_navigation_depth] = self.shadow_page;\\n        self.shadow_navigation_cursors[self.shadow_navigation_depth] = self.shadow_cursor;\\n        self.shadow_navigation_depth++;\\n    }\\n    self.shadow_page = page;\\n    self.shadow_cursor = 0;\\n    self.shadow_window = 0;\\n    self shadow_define_page();\\n",
    "    self shadow_paint_page();\\n}\\n\\nshadow_back()\\n{\\n    if (self.shadow_navigation_depth <= 0)\\n    {\\n        self shadow_close();\\n        return;\\n    }\\n    self.shadow_navigation_depth--;\\n    self.shadow_page = self.shadow_navigation_pages[self.shadow_navigation_depth];\\n    selected = self.shadow_navigation_cursors[self.shadow_navigation_depth];\\n    self shadow_define_page();\\n    if (selected >= self.shadow_items.size)\\n        selected = self.shadow_items.size - 1;\\n    if (selected < 0)\\n        selected = 0;\\n    self.shadow_cursor = selected;\\n    self.shadow_window = 0;\\n    if (selected >= self.shadow_visible_rows)\\n        self.shadow_window = selected - self.shadow_visible_rows + 1;\\n    self shadow_paint_page();\\n}\\n\\nshadow_define_page()\\n{\\n    self.shadow_items = [];\\n    self.shadow_item_values = [];\\n\\n    if (self.shadow_page == 0)\\n    {\\n        self shadow_add_option(\\\"Player Mods\\\", \\\"page_1\\\");\\n        self shadow_add_option(\\\"Weapons\\\", \\\"page_13\\\");\\n        self shadow_add_option(\\\"Lobby Mods\\\", \\\"page_15\\\");\\n        self shadow_add_option(\\\"Aimbot",
    " & Combat\\\", \\\"page_7\\\");\\n        self shadow_add_option(\\\"Settings\\\", \\\"page_20\\\");\\n        self shadow_add_option(\\\"Extras\\\", \\\"page_16\\\");\\n    }\\n    else if (self.shadow_page == 1)\\n    {\\n        self.shadow_items[0] = \\\"God Mode: \\\" + self shadow_on_off(self.shadow_god);\\n        self.shadow_items[1] = \\\"No Target: \\\" + self shadow_on_off(self.shadow_user_notarget);\\n        self.shadow_items[2] = \\\"NoClip: \\\" + self shadow_on_off(self.shadow_noclip_active);\\n        self.shadow_items[3] = \\\"Player Speed: \\\" + self shadow_speed_name();\\n        self.shadow_items[4] = \\\"Heal Player\\\";\\n        self.shadow_items[5] = \\\"Reset Player Mods\\\";\\n        self.shadow_items[6] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 2)\\n    {\\n        self shadow_add_weapon(\\\"ray_gun_zm\\\", \\\"Ray Gun\\\");\\n        self shadow_add_weapon(\\\"ak74u_zm\\\", \\\"AK74u\\\");\\n        self shadow_add_weapon(\\\"mp40_zm\\\", \\\"MP40\\\");\\n        self shadow_add_weapon(\\\"galil_zm\\\", \\\"Galil\\\");\\n        self shadow_add_weapon(\\\"hk21_zm\\\", \\\"HK21\\\");\\n        self shadow_add_weapon(\\\"rpk_zm\\\", \\\"RPK\\\");\\n     ",
    "   self shadow_add_weapon(\\\"m1911_zm\\\", \\\"M1911\\\");\\n        self shadow_add_weapon(\\\"thundergun_zm\\\", \\\"Thundergun\\\");\\n        self shadow_add_weapon(\\\"tesla_gun_zm\\\", \\\"Wunderwaffe DG-2\\\");\\n        self shadow_add_weapon(\\\"freezegun_zm\\\", \\\"Winter's Howl\\\");\\n        self shadow_add_weapon(\\\"scavenger_zm\\\", \\\"Scavenger\\\");\\n        self shadow_add_weapon(\\\"microwavegun_zm\\\", \\\"Wave Gun\\\");\\n        self shadow_add_weapon(\\\"31-79_jgb215_zm\\\", \\\"31-79 JGb215\\\");\\n        self shadow_add_weapon(\\\"python_zm\\\", \\\"Python\\\");\\n        self shadow_add_weapon(\\\"cz75_zm\\\", \\\"CZ75\\\");\\n        self shadow_add_weapon(\\\"cz75dw_zm\\\", \\\"CZ75 Dual Wield\\\");\\n        self shadow_add_weapon(\\\"mp5k_zm\\\", \\\"MP5K\\\");\\n        self shadow_add_weapon(\\\"mpl_zm\\\", \\\"MPL\\\");\\n        self shadow_add_weapon(\\\"pm63_zm\\\", \\\"PM63\\\");\\n        self shadow_add_weapon(\\\"spectre_zm\\\", \\\"Spectre\\\");\\n        self shadow_add_weapon(\\\"ithaca_zm\\\", \\\"Stakeout\\\");\\n        self shadow_add_weapon(\\\"spas_zm\\\", \\\"SPAS-12\\\");\\n        self shadow_add_weapon(\\\"rottweil72_zm\\\", \\\"Olympia\\\");\\n        self shadow_add_weapon(",
    "\\\"hs10_zm\\\", \\\"HS10\\\");\\n        self shadow_add_weapon(\\\"m14_zm\\\", \\\"M14\\\");\\n        self shadow_add_weapon(\\\"m16_zm\\\", \\\"M16\\\");\\n        self shadow_add_weapon(\\\"g11_lps_zm\\\", \\\"G11\\\");\\n        self shadow_add_weapon(\\\"famas_zm\\\", \\\"FAMAS\\\");\\n        self shadow_add_weapon(\\\"aug_acog_zm\\\", \\\"AUG\\\");\\n        self shadow_add_weapon(\\\"commando_zm\\\", \\\"Commando\\\");\\n        self shadow_add_weapon(\\\"fnfal_zm\\\", \\\"FN FAL\\\");\\n        self shadow_add_weapon(\\\"dragunov_zm\\\", \\\"Dragunov\\\");\\n        self shadow_add_weapon(\\\"l96a1_zm\\\", \\\"L96A1\\\");\\n        self shadow_add_weapon(\\\"m72_law_zm\\\", \\\"M72 LAW\\\");\\n        self shadow_add_weapon(\\\"china_lake_zm\\\", \\\"China Lake\\\");\\n        self shadow_add_weapon(\\\"crossbow_explosive_zm\\\", \\\"Explosive Crossbow\\\");\\n        self shadow_add_weapon(\\\"knife_ballistic_zm\\\", \\\"Ballistic Knife\\\");\\n        self shadow_add_weapon(\\\"knife_ballistic_bowie_zm\\\", \\\"Ballistic Knife (Bowie)\\\");\\n        self shadow_add_weapon(\\\"knife_ballistic_sickle_zm\\\", \\\"Ballistic Knife (Sickle)\\\");\\n        if (self.shadow_items.size == 0)\\n            self shadow_add",
    "_option(\\\"No registered weapons\\\", \\\"unavailable\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 3)\\n    {\\n        self.shadow_items[0] = \\\"Pack-a-Punch Weapon\\\";\\n        self.shadow_items[1] = \\\"Refill Current Ammo\\\";\\n        self.shadow_items[2] = \\\"Refill All Ammo\\\";\\n        self.shadow_items[3] = \\\"Unlimited Ammo: \\\" + self shadow_on_off(self.shadow_auto_refill);\\n        self.shadow_items[4] = \\\"Infinite Clip: \\\" + self shadow_on_off(self.shadow_infinite_clip);\\n        self.shadow_items[5] = \\\"Drop Weapon\\\";\\n        self.shadow_items[6] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 4)\\n    {\\n        self.shadow_items[0] = \\\"Clear Zombies\\\";\\n        self.shadow_items[1] = \\\"Zombie Counter: \\\" + self shadow_on_off(self.shadow_zombie_counter);\\n        self.shadow_items[2] = \\\"Show Alive Zombies\\\";\\n        self.shadow_items[3] = \\\"Skip Round\\\";\\n        self.shadow_items[4] = \\\"Zombie Spawner\\\";\\n        self.shadow_items[5] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 5)\\n    {\\n        self.shadow_ite",
    "ms[0] = \\\"Add 1,337 Points\\\";\\n        self.shadow_items[1] = \\\"Add 1,000 Points\\\";\\n        self.shadow_items[2] = \\\"Add 5,000 Points\\\";\\n        self.shadow_items[3] = \\\"Add 10,000 Points\\\";\\n        self.shadow_items[4] = \\\"Add 50,000 Points\\\";\\n        self.shadow_items[5] = \\\"Add 100,000 Points\\\";\\n        self.shadow_items[6] = \\\"Reset Points\\\";\\n        self.shadow_items[7] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 6)\\n    {\\n        self.shadow_items[0] = \\\"Saved Positions\\\";\\n        self.shadow_items[1] = \\\"Map Teleports\\\";\\n        self.shadow_items[2] = \\\"Shoot to Teleport: \\\" + self shadow_on_off(self.shadow_shoot_tp);\\n        self.shadow_items[3] = \\\"Save Position\\\";\\n        self.shadow_items[4] = \\\"Teleport to Saved\\\";\\n        self.shadow_items[5] = \\\"Teleport to Crosshair\\\";\\n        self.shadow_items[6] = \\\"Set Spawn Return Point\\\";\\n        self.shadow_items[7] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 7)\\n    {\\n        self.shadow_items[0] = \\\"Classic Aimbot: \\\" + self shadow_on_off(self.shadow_classic_aimbot);\\n        self.shadow_ite",
    "ms[1] = \\\"Unfair Aimbot: \\\" + self shadow_on_off(self.shadow_unfair_aimbot);\\n        if (self.shadow_aim_always)\\n            self.shadow_items[2] = \\\"Aim Activation: Always\\\";\\n        else\\n            self.shadow_items[2] = \\\"Aim Activation: ADS\\\";\\n        if (self.shadow_aim_bone == \\\"j_head\\\")\\n            self.shadow_items[3] = \\\"Aim Target: Head\\\";\\n        else\\n            self.shadow_items[3] = \\\"Aim Target: Body\\\";\\n        self.shadow_items[4] = \\\"One-Hit Kill: \\\" + self shadow_on_off(self.shadow_one_hit);\\n        self.shadow_items[5] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 8)\\n    {\\n        self.shadow_items[0] = \\\"View Map Name\\\";\\n        self.shadow_items[1] = \\\"View Current Weapon\\\";\\n        self.shadow_items[2] = \\\"View Coordinates\\\";\\n        self.shadow_items[3] = \\\"View Round\\\";\\n        self.shadow_items[4] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 9)\\n    {\\n        self shadow_add_perk(\\\"specialty_armorvest\\\", \\\"Juggernog\\\");\\n        self shadow_add_perk(\\\"specialty_fastreload\\\", \\\"Speed Cola\\\");\\n        self shadow_add_perk(",
    "\\\"specialty_rof\\\", \\\"Double Tap\\\");\\n        self shadow_add_perk(\\\"specialty_quickrevive\\\", \\\"Quick Revive\\\");\\n        self shadow_add_perk(\\\"specialty_longersprint\\\", \\\"Stamin-Up\\\");\\n        self shadow_add_perk(\\\"specialty_detectexplosive\\\", \\\"PhD Flopper\\\");\\n        self shadow_add_perk(\\\"specialty_deadshot\\\", \\\"Deadshot Daiquiri\\\");\\n        self shadow_add_perk(\\\"specialty_additionalprimaryweapon\\\", \\\"Mule Kick\\\");\\n        self shadow_add_option(\\\"Give All Available Perks\\\", \\\"all_perks\\\");\\n        self shadow_add_option(\\\"Remove All Perks\\\", \\\"clear_perks\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 10)\\n    {\\n        self shadow_add_option(\\\"Turn On Power\\\", \\\"power\\\");\\n        self shadow_add_option(\\\"Open All Doors & Debris\\\", \\\"doors\\\");\\n        self shadow_add_option(\\\"Open All Doors\\\", \\\"doors_only\\\");\\n        self shadow_add_option(\\\"Clear All Debris\\\", \\\"debris_only\\\");\\n        self shadow_add_option(\\\"Super Jump: \\\" + self shadow_on_off(level.shadow_super_jump), \\\"jump\\\");\\n        self shadow_add_option",
    "(\\\"Low Gravity: \\\" + self shadow_on_off(level.shadow_low_gravity), \\\"gravity\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 11)\\n    {\\n        if (self.shadow_key_mode == 0)\\n            self.shadow_items[0] = \\\"Control Layout: WASD\\\";\\n        else\\n            self.shadow_items[0] = \\\"Control Layout: Classic\\\";\\n        self.shadow_items[1] = \\\"Scroll Speed: \\\" + self shadow_scroll_speed_name();\\n        if (self.shadow_invert_scroll)\\n            self.shadow_items[2] = \\\"Scroll Direction: Inverted\\\";\\n        else\\n            self.shadow_items[2] = \\\"Scroll Direction: Normal\\\";\\n        if (self.shadow_swap_horizontal)\\n            self.shadow_items[3] = \\\"Select: A / Back: D\\\";\\n        else\\n            self.shadow_items[3] = \\\"Select: D / Back: A\\\";\\n        self.shadow_items[4] = \\\"NoClip Bind: \\\" + self shadow_noclip_bind_name();\\n        self.shadow_items[5] = \\\"Reset Controls\\\";\\n        self.shadow_items[6] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 12)\\n    {\\n        self.shadow_items[0] = \\\"Challenge Pro",
    "gress\\\";\\n        if (self.shadow_achievement_survivor)\\n            self.shadow_items[1] = \\\"Survivor V  [UNLOCKED]\\\";\\n        else\\n            self.shadow_items[1] = \\\"Survivor V  [LOCKED]\\\";\\n        if (self.shadow_achievement_veteran)\\n            self.shadow_items[2] = \\\"Veteran X  [UNLOCKED]\\\";\\n        else\\n            self.shadow_items[2] = \\\"Veteran X  [LOCKED]\\\";\\n        if (self.shadow_achievement_rich)\\n            self.shadow_items[3] = \\\"Wealth 10K  [UNLOCKED]\\\";\\n        else\\n            self.shadow_items[3] = \\\"Wealth 10K  [LOCKED]\\\";\\n        if (self.shadow_achievement_century)\\n            self.shadow_items[4] = \\\"Hunter 100  [UNLOCKED]\\\";\\n        else\\n            self.shadow_items[4] = \\\"Hunter 100  [LOCKED]\\\";\\n        if (self.shadow_achievement_banker)\\n            self.shadow_items[5] = \\\"Banker 100K  [UNLOCKED]\\\";\\n        else\\n            self.shadow_items[5] = \\\"Banker 100K  [LOCKED]\\\";\\n        self.shadow_items[6] = \\\"Unlock All Local Badges\\\";\\n        self.shadow_items[7] = \\\"Reset Local Badges\\\";\\n        self.shadow_items[8] = \\\"< Back\\\";\\n  ",
    "  }\\n    else if (self.shadow_page == 13)\\n    {\\n        self shadow_add_option(\\\"Give Weapons\\\", \\\"page_2\\\");\\n        self shadow_add_option(\\\"Equipment\\\", \\\"page_28\\\");\\n        self shadow_add_option(\\\"Ammo & Upgrades\\\", \\\"page_3\\\");\\n        self shadow_add_option(\\\"Bullet FX & Rounds\\\", \\\"page_22\\\");\\n        if (self shadow_perks_available())\\n            self shadow_add_option(\\\"Perks\\\", \\\"page_9\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 14)\\n    {\\n        self shadow_add_option(\\\"Zombie Options\\\", \\\"page_4\\\");\\n        self shadow_add_option(\\\"Points\\\", \\\"page_5\\\");\\n        self shadow_add_option(\\\"Power-Ups\\\", \\\"page_27\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 15)\\n    {\\n        self shadow_add_option(\\\"Zombies & Points\\\", \\\"page_14\\\");\\n        self shadow_add_option(\\\"World Mods\\\", \\\"page_10\\\");\\n        self shadow_add_option(\\\"Teleport\\\", \\\"page_6\\\");\\n        if (getDvar(\\\"mapname\\\") == \\\"zombie_pentagon\\\")\\n            self shadow_add_option(\\\"Five ",
    "Controls\\\", \\\"page_18\\\");\\n        self shadow_add_option(\\\"Change Map [Shift+M]\\\", \\\"map_shortcut\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 16)\\n    {\\n        self shadow_add_option(\\\"Local Challenges\\\", \\\"page_12\\\");\\n        self shadow_add_option(\\\"Game Info\\\", \\\"page_8\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 17)\\n    {\\n        self.shadow_items[0] = \\\"Save Position A\\\";\\n        self.shadow_items[1] = \\\"Teleport to Position A\\\";\\n        self.shadow_items[2] = \\\"Save Position B\\\";\\n        self.shadow_items[3] = \\\"Teleport to Position B\\\";\\n        self.shadow_items[4] = \\\"Save Position C\\\";\\n        self.shadow_items[5] = \\\"Teleport to Position C\\\";\\n        self.shadow_items[6] = \\\"Return to Spawn\\\";\\n        self.shadow_items[7] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 18)\\n    {\\n        self.shadow_items[0] = \\\"Activate DEFCON 5 (Power First)\\\";\\n        self.shadow_items[1] = \\\"Teleport to Top Floor\\\";\\n        self.shadow_items[2] = \\\"Telep",
    "ort to War Room\\\";\\n        self.shadow_items[3] = \\\"Teleport to Labs\\\";\\n        self.shadow_items[4] = \\\"Teleport to Pack-a-Punch\\\";\\n        self.shadow_items[5] = \\\"Show DEFCON / Power Status\\\";\\n        self.shadow_items[6] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 19)\\n    {\\n        self.shadow_items[0] = \\\"Selection Highlight: \\\" + self shadow_on_off(self.shadow_selection_visible);\\n        self.shadow_items[1] = \\\"Menu Colors\\\";\\n        self.shadow_items[2] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 20)\\n    {\\n        self shadow_add_option(\\\"Controls & Keybinds\\\", \\\"page_11\\\");\\n        self shadow_add_option(\\\"Appearance\\\", \\\"page_19\\\");\\n        self shadow_add_option(\\\"Performance & Safety\\\", \\\"page_21\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 21)\\n    {\\n        self.shadow_items[0] = \\\"Menu Protection: \\\" + self shadow_on_off(self.shadow_menu_auto_protect);\\n        self.shadow_items[1] = \\\"Reduced Effects: \\\" + self shadow_on_off(self.shadow_low_effects);\\n        self.shadow_items[2]",
    " = \\\"Force Close Menu\\\";\\n        self.shadow_items[3] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 22)\\n    {\\n        self.shadow_items[0] = \\\"Bullet Impact FX: \\\" + self shadow_on_off(self.shadow_fx_enabled);\\n        self.shadow_items[1] = \\\"Impact Effect: \\\" + self shadow_fx_name();\\n        self.shadow_items[2] = \\\"Bullet Damage: \\\" + self shadow_ammo_mode_name();\\n        self.shadow_items[3] = \\\"Nuke Rounds: \\\" + self shadow_on_off(self.shadow_nuke_rounds);\\n        self.shadow_items[4] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 23)\\n    {\\n        self shadow_build_map_spots();\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 24)\\n    {\\n        self.shadow_items[0] = \\\"Add 1 Zombie to Round\\\";\\n        self.shadow_items[1] = \\\"Add 5 Zombies to Round\\\";\\n        self.shadow_items[2] = \\\"Add 10 Zombies to Round\\\";\\n        self.shadow_items[3] = \\\"Zombies Queued: \\\" + self shadow_spawn_pending_text();\\n        self.shadow_items[4] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 26)\\n    {\\n        sel",
    "f.shadow_items[0] = \\\"Red: \\\" + self.shadow_color_r;\\n        self.shadow_items[1] = \\\"Green: \\\" + self.shadow_color_g;\\n        self.shadow_items[2] = \\\"Blue: \\\" + self.shadow_color_b;\\n        self.shadow_items[3] = \\\"Next Color Preset\\\";\\n        self.shadow_items[4] = \\\"Restore Default Red\\\";\\n        self.shadow_items[5] = \\\"< Back\\\";\\n    }\\n    else if (self.shadow_page == 28)\\n    {\\n        self shadow_add_weapon(\\\"zombie_cymbal_monkey\\\", \\\"Monkey Bombs\\\");\\n        self shadow_add_weapon(\\\"zombie_black_hole_bomb\\\", \\\"Gersh Device\\\");\\n        self shadow_add_weapon(\\\"zombie_nesting_dolls\\\", \\\"Matryoshka Dolls\\\");\\n        self shadow_add_weapon(\\\"frag_grenade_zm\\\", \\\"Frag Grenades\\\");\\n        self shadow_add_weapon(\\\"sticky_grenade_zm\\\", \\\"Semtex Grenades\\\");\\n        self shadow_add_weapon(\\\"claymore_zm\\\", \\\"Claymores\\\");\\n        if (self.shadow_items.size == 0)\\n            self shadow_add_option(\\\"No special equipment on this map\\\", \\\"unavailable\\\");\\n        self shadow_add_option(\\\"< Back\\\", \\\"back\\\");\\n    }\\n    else if (self.shadow_page == 27)\\n    {\\n        self",
    ".shadow_items[0] = \\\"Activate Nuke\\\";\\n        self.shadow_items[1] = \\\"Spawn Max Ammo\\\";\\n        self.shadow_items[2] = \\\"Spawn Insta-Kill\\\";\\n        self.shadow_items[3] = \\\"Spawn Double Points\\\";\\n        self.shadow_items[4] = \\\"Spawn Carpenter\\\";\\n        self.shadow_items[5] = \\\"Spawn Fire Sale\\\";\\n        self.shadow_items[6] = \\\"Spawn Bonfire Sale\\\";\\n        self.shadow_items[7] = \\\"Spawn Free Perk\\\";\\n        self.shadow_items[8] = \\\"Spawn Death Machine\\\";\\n        self.shadow_items[9] = \\\"< Back\\\";\\n    }\\n}\\n\\nshadow_on_off(value)\\n{\\n    if (value) return \\\"^2ON\\\";\\n    return \\\"^1OFF\\\";\\n}\\n\\nshadow_scroll_speed_name()\\n{\\n    if (self.shadow_key_repeat >= 180) return \\\"Slow\\\";\\n    if (self.shadow_key_repeat >= 110) return \\\"Normal\\\";\\n    return \\\"Fast\\\";\\n}\\n\\nshadow_speed_name()\\n{\\n    if (self.shadow_speed_level == 1) return \\\"1.5x\\\";\\n    if (self.shadow_speed_level == 2) return \\\"2.0x\\\";\\n    if (self.shadow_speed_level == 3) return \\\"3.0x\\\";\\n    return \\\"Normal\\\";\\n}\\n\\nshadow_speed_scale()\\n{\\n    if (self.shadow_speed_level == 1) return 1.5;\\n    if (self.",
    "shadow_speed_level == 2) return 2.0;\\n    if (self.shadow_speed_level == 3) return 3.0;\\n    return 1.0;\\n}\\n\\nshadow_apply_movement_dvars()\\n{\\n    if (level.shadow_super_jump)\\n        setDvar(\\\"jump_height\\\", 175);\\n    else\\n        setDvar(\\\"jump_height\\\", level.shadow_jump_default);\\n\\n    if (level.shadow_low_gravity)\\n        setDvar(\\\"g_gravity\\\", 400);\\n    else\\n        setDvar(\\\"g_gravity\\\", level.shadow_gravity_default);\\n}\\n\\nshadow_noclip_bind_name()\\n{\\n    if (self.shadow_noclip_bind == 1) return \\\"MOUSE4\\\";\\n    if (self.shadow_noclip_bind == 2) return \\\"MOUSE5\\\";\\n    if (self.shadow_noclip_bind == 3) return \\\"F6\\\";\\n    return \\\"^1OFF\\\";\\n}\\n\\n\\nshadow_cycle_noclip_bind()\\n{\\n    self.shadow_noclip_bind++;\\n    if (self.shadow_noclip_bind > 3)\\n        self.shadow_noclip_bind = 0;\\n    if (self.shadow_noclip_active)\\n        self.shadow_noclip_dirty = true;\\n}\\n\\nshadow_request_noclip()\\n{\\n    self.shadow_noclip_active = !self.shadow_noclip_active;\\n    self.shadow_noclip_toggle_pending = true;\\n    self.shadow_noclip_dirty = true;\\n    if (self.shadow_open)\\n   ",
    "     self shadow_close();\\n    else\\n        self thread shadow_apply_noclip();\\n}\\n\\nshadow_apply_noclip()\\n{\\n    self endon(\\\"disconnect\\\");\\n    wait 0.15;\\n    if (!self.shadow_noclip_dirty && !self.shadow_noclip_toggle_pending)\\n        return;\\n\\n    key = \\\"\\\";\\n    if (self.shadow_noclip_active)\\n        key = self shadow_noclip_bind_key(self.shadow_noclip_bind);\\n    command = \\\"\\\";\\n    if (self.shadow_noclip_bound_key != \\\"\\\" &&\\n        self.shadow_noclip_bound_key != key)\\n        command = \\\"unbind \\\" + self.shadow_noclip_bound_key;\\n    if (key != \\\"\\\")\\n    {\\n        if (command != \\\"\\\")\\n            command += \\\";\\\";\\n        command += \\\"bind \\\" + key + \\\" noclip\\\";\\n    }\\n    if (self.shadow_noclip_toggle_pending)\\n    {\\n        if (command != \\\"\\\")\\n            command += \\\";\\\";\\n        command += \\\"noclip\\\";\\n    }\\n    if (command != \\\"\\\")\\n        self setClientDvar(\\\"activeAction\\\", command);\\n    self.shadow_noclip_bound_key = key;\\n    self.shadow_noclip_dirty = false;\\n    self.shadow_noclip_toggle_pending = false;\\n}\\n\\nshadow_noclip_bind_key(value)\\n",
    "{\\n    if (value == 1) return \\\"MOUSE4\\\";\\n    if (value == 2) return \\\"MOUSE5\\\";\\n    if (value == 3) return \\\"F6\\\";\\n    return \\\"\\\";\\n}\\n\\nshadow_fx_name()\\n{\\n    if (self.shadow_fx_style == 0) return \\\"Explosion\\\";\\n    if (self.shadow_fx_style == 1) return \\\"Tesla\\\";\\n    if (self.shadow_fx_style == 2) return \\\"Flame\\\";\\n    if (self.shadow_fx_style == 3) return \\\"Blood\\\";\\n    return \\\"Dust\\\";\\n}\\n\\nshadow_page_name()\\n{\\n    if (self.shadow_page == 1) return \\\"PLAYER MODS\\\";\\n    if (self.shadow_page == 2) return \\\"GIVE WEAPON\\\";\\n    if (self.shadow_page == 3) return \\\"AMMO & UPGRADES\\\";\\n    if (self.shadow_page == 4) return \\\"ZOMBIE OPTIONS\\\";\\n    if (self.shadow_page == 5) return \\\"POINTS\\\";\\n    if (self.shadow_page == 6) return \\\"TELEPORT MENU\\\";\\n    if (self.shadow_page == 7) return \\\"AIMBOT & COMBAT\\\";\\n    if (self.shadow_page == 8) return \\\"GAME INFO\\\";\\n    if (self.shadow_page == 9) return \\\"PERKS\\\";\\n    if (self.shadow_page == 10) return \\\"WORLD MODS\\\";\\n    if (self.shadow_page == 11) return \\\"MENU CONTROLS\\\";\\n    if (self.shadow_page == 12) return \\\"LOCAL C",
    "HALLENGES\\\";\\n    if (self.shadow_page == 13) return \\\"WEAPONS\\\";\\n    if (self.shadow_page == 14) return \\\"ZOMBIES & POINTS\\\";\\n    if (self.shadow_page == 15) return \\\"LOBBY MODS\\\";\\n    if (self.shadow_page == 16) return \\\"EXTRAS\\\";\\n    if (self.shadow_page == 17) return \\\"SAVED POSITIONS\\\";\\n    if (self.shadow_page == 18) return \\\"FIVE CONTROLS\\\";\\n    if (self.shadow_page == 19) return \\\"APPEARANCE\\\";\\n    if (self.shadow_page == 20) return \\\"SETTINGS\\\";\\n    if (self.shadow_page == 21) return \\\"PERFORMANCE\\\";\\n    if (self.shadow_page == 22) return \\\"BULLET FX & ROUNDS\\\";\\n    if (self.shadow_page == 23) return \\\"MAP TELEPORTS\\\";\\n    if (self.shadow_page == 24) return \\\"ZOMBIE SPAWNER\\\";\\n    if (self.shadow_page == 26) return \\\"MENU COLORS\\\";\\n    if (self.shadow_page == 27) return \\\"POWER-UPS\\\";\\n    if (self.shadow_page == 28) return \\\"EQUIPMENT\\\";\\n    return \\\"MAIN MENU\\\";\\n}\\n\\nshadow_add_option(label, value)\\n{\\n    index = self.shadow_items.size;\\n    self.shadow_items[index] = label;\\n    self.shadow_item_values[index] = value;\\n}\\n\\nshadow_add_weapon(weapon, label)",
    "\\n{\\n    if (isDefined(level.zombie_weapons) &&\\n        isDefined(level.zombie_weapons[weapon]))\\n        self shadow_add_option(label, weapon);\\n}\\n\\nshadow_perks_available()\\n{\\n    triggers = getEntArray(\\\"zombie_vending\\\", \\\"targetname\\\");\\n    return triggers.size > 0;\\n}\\n\\nshadow_add_perk(perk, label)\\n{\\n    triggers = getEntArray(\\\"zombie_vending\\\", \\\"targetname\\\");\\n    for (i = 0; i < triggers.size; i++)\\n    {\\n        if (isDefined(triggers[i].script_noteworthy) &&\\n            triggers[i].script_noteworthy == perk)\\n        {\\n            self shadow_add_option(label, perk);\\n            return;\\n        }\\n    }\\n}\\n\\nshadow_door_count()\\n{\\n    doors = getEntArray(\\\"zombie_door\\\", \\\"targetname\\\");\\n    debris = getEntArray(\\\"zombie_debris\\\", \\\"targetname\\\");\\n    return doors.size + debris.size;\\n}\\n\\nshadow_power_available()\\n{\\n    map = getDvar(\\\"mapname\\\");\\n    supported = map == \\\"zombie_theater\\\" || map == \\\"zombie_pentagon\\\" ||\\n        map == \\\"zombie_cod5_factory\\\" || map == \\\"nazi_zombie_factory\\\" ||\\n        map == \\\"zombie_cod5_asylum\\\" || map == \\\"nazi_",
    "zombie_asylum\\\" ||\\n        map == \\\"zombie_cosmodrome\\\" || map == \\\"zombie_coast\\\" ||\\n        map == \\\"zombie_temple\\\" || map == \\\"zombie_moon\\\";\\n    if (!supported || flag(\\\"power_on\\\"))\\n        return false;\\n    triggers = getEntArray(\\\"use_power_switch\\\", \\\"targetname\\\");\\n    return triggers.size > 0;\\n}\\n\\nshadow_world_available()\\n{\\n    return self shadow_door_count() > 0 || self shadow_power_available();\\n}\\n\\nshadow_ammo_mode_name()\\n{\\n    if (self.shadow_ammo_mode == 1) return \\\"Explosive\\\";\\n    if (self.shadow_ammo_mode == 2) return \\\"Heavy\\\";\\n    if (self.shadow_ammo_mode == 3) return \\\"One-Hit\\\";\\n    if (self.shadow_ammo_mode == 4) return \\\"Burn Damage\\\";\\n    return \\\"Normal\\\";\\n}\\n\\nshadow_paint_page()\\n{\\n    if (!self.shadow_open || !isDefined(self.shadow_section) ||\\n        !isDefined(self.shadow_footer))\\n        return;\\n\\n    shown = self.shadow_items.size;\\n    if (shown < 1)\\n        shown = 1;\\n    if (shown > self.shadow_visible_rows)\\n        shown = self.shadow_visible_rows;\\n    rule_y = 113 + (shown * 18) + 5;\\n    self.shadow_footer_rule.y = ru",
    "le_y;\\n    self.shadow_footer_strip.y = rule_y + 3;\\n    self.shadow_footer.y = rule_y + 9;\\n    bg_height = rule_y - 49 + 45;\\n    if (!isDefined(self.shadow_bg_height) || self.shadow_bg_height != bg_height)\\n    {\\n        self.shadow_bg setShader(\\\"white\\\", 220, bg_height);\\n        self.shadow_bg_height = bg_height;\\n    }\\n\\n    self.shadow_section setText(self shadow_page_name());\\n    if (self.shadow_key_mode == 0 && self.shadow_swap_horizontal)\\n        self.shadow_footer setText(\\\"^7             ^1[W/S] ^7NAV ^1[A/USE] ^7SELECT ^1[D] ^7BACK\\\\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT\\\");\\n    else if (self.shadow_key_mode == 0)\\n        self.shadow_footer setText(\\\"^7             ^1[W/S] ^7NAV ^1[D/USE] ^7SELECT ^1[A] ^7BACK\\\\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT\\\");\\n    else\\n        self.shadow_footer setText(\\\"^7                  ^1[FIRE/ADS] ^7NAV ^1[USE] ^7SELECT\\\\n^7           ^1[MELEE] ^7BACK/CLOSE ^1[ADS+MELEE] ^7EXIT\\\");\\n\\n    for (i = 0; i < self.shadow_visible_rows; i++)\\n    {\\n        item = i + self.shadow_window;\\n        i",
    "f (item < self.shadow_items.size)\\n        {\\n            self.shadow_rows[i] setText(self.shadow_items[item]);\\n            self.shadow_rows[i].color = (1, 1, 1);\\n            self.shadow_rows[i].alpha = 1;\\n        }\\n        else\\n        {\\n            self.shadow_rows[i] setText(\\\" \\\");\\n            self.shadow_rows[i].alpha = 0;\\n        }\\n    }\\n\\n    self shadow_paint_cursor();\\n}\\n\\nshadow_paint_cursor()\\n{\\n    if (!self.shadow_open || !isDefined(self.shadow_page_count))\\n        return;\\n\\n    position = self.shadow_cursor - self.shadow_window;\\n    if (isDefined(self.shadow_selection))\\n    {\\n        self.shadow_selection.y = 111 + (position * 18);\\n        if (self.shadow_selection_visible)\\n            self.shadow_selection.alpha = 0.94;\\n        else\\n            self.shadow_selection.alpha = 0;\\n    }\\n    if (isDefined(self.shadow_scroll_thumb))\\n    {\\n        scroll_position = 0;\\n        if (self.shadow_items.size > 1)\\n            scroll_position = (self.shadow_cursor * (self.shadow_visible_rows - 1)) /\\n                (self.shadow_items.size - 1);\\n        se",
    "lf.shadow_scroll_thumb.y = 115 + (scroll_position * 18);\\n        if (self.shadow_scrollbar_visible &&\\n            self.shadow_items.size > self.shadow_visible_rows)\\n            self.shadow_scroll_thumb.alpha = 0.95;\\n        else\\n            self.shadow_scroll_thumb.alpha = 0;\\n    }\\n    self.shadow_page_count setText((self.shadow_cursor + 1) + \\\" / \\\" + self.shadow_items.size);\\n}\\n\\nshadow_submenu_page(choice)\\n{\\n    if (!isDefined(choice))\\n        return -1;\\n    if (choice == \\\"page_1\\\") return 1;\\n    if (choice == \\\"page_2\\\") return 2;\\n    if (choice == \\\"page_3\\\") return 3;\\n    if (choice == \\\"page_4\\\") return 4;\\n    if (choice == \\\"page_5\\\") return 5;\\n    if (choice == \\\"page_6\\\") return 6;\\n    if (choice == \\\"page_7\\\") return 7;\\n    if (choice == \\\"page_8\\\") return 8;\\n    if (choice == \\\"page_9\\\") return 9;\\n    if (choice == \\\"page_10\\\") return 10;\\n    if (choice == \\\"page_11\\\") return 11;\\n    if (choice == \\\"page_12\\\") return 12;\\n    if (choice == \\\"page_13\\\") return 13;\\n    if (choice == \\\"page_14\\\") return 14;\\n    if (choice == \\\"page_15\\\") return 15;\\",
    "n    if (choice == \\\"page_16\\\") return 16;\\n    if (choice == \\\"page_18\\\") return 18;\\n    if (choice == \\\"page_19\\\") return 19;\\n    if (choice == \\\"page_20\\\") return 20;\\n    if (choice == \\\"page_21\\\") return 21;\\n    if (choice == \\\"page_22\\\") return 22;\\n    if (choice == \\\"page_27\\\") return 27;\\n    if (choice == \\\"page_28\\\") return 28;\\n    return -1;\\n}\\n\\nshadow_activate()\\n{\\n    page = self.shadow_page;\\n    index = self.shadow_cursor;\\n    if (index < 0 || index >= self.shadow_items.size)\\n        return;\\n\\n    choice = undefined;\\n    if (index < self.shadow_item_values.size)\\n        choice = self.shadow_item_values[index];\\n\\n    if ((page == 0 || page == 13 || page == 14 ||\\n        page == 15 || page == 16 || page == 20) &&\\n        isDefined(choice))\\n    {\\n        target_page = self shadow_submenu_page(choice);\\n        if (target_page >= 0)\\n        {\\n            self shadow_change_page(target_page);\\n            return;\\n        }\\n    }\\n\\n    if (index == self.shadow_items.size - 1 &&\\n        self.shadow_items[index] == \\\"< Back\\\")\\n    {\\n        self shado",
    "w_back();\\n        return;\\n    }\\n\\n    if (page == 0)\\n        return;\\n\\n    if (page == 13 || page == 14 || page == 15 || page == 16 || page == 20)\\n    {\\n        if (!isDefined(choice))\\n            return;\\n        if (choice == \\\"map_shortcut\\\")\\n            self shadow_notice(\\\"^1SHADOW ^7Shift+M opens the map launcher\\\");\\n        return;\\n    }\\n\\n    if (page == 1)\\n    {\\n        if (index == 0)\\n        {\\n            self.shadow_god = !self.shadow_god;\\n            if (self.shadow_god || self.shadow_menu_invuln_applied)\\n                self enableInvulnerability();\\n            else\\n                self disableInvulnerability();\\n        }\\n        else if (index == 1)\\n        {\\n            self.shadow_user_notarget = !self.shadow_user_notarget;\\n            self.ignoreme = self.shadow_user_notarget ||\\n                self.shadow_was_ignored ||\\n                (self.shadow_menu_auto_protect && self.shadow_open);\\n        }\\n        else if (index == 2)\\n            self shadow_request_noclip();\\n        else if (index == 3)\\n        {\\n            self.shadow_spe",
    "ed_level++;\\n            if (self.shadow_speed_level > 3)\\n                self.shadow_speed_level = 0;\\n        }\\n        else if (index == 4)\\n        {\\n            if (isDefined(self.maxhealth))\\n                self.health = self.maxhealth;\\n            else\\n                self.health = 100;\\n            self shadow_notice(\\\"^1SHADOW ^7Health restored\\\");\\n        }\\n        else if (index == 5)\\n        {\\n            self.shadow_god = false;\\n            self.shadow_user_notarget = false;\\n            self.shadow_speed_level = 0;\\n            if (self.shadow_noclip_active)\\n                self shadow_request_noclip();\\n            self.ignoreme = self.shadow_was_ignored ||\\n                (self.shadow_menu_auto_protect && self.shadow_open);\\n            if (!self.shadow_menu_invuln_applied)\\n                self disableInvulnerability();\\n            self shadow_notice(\\\"^1SHADOW ^7Player settings reset\\\");\\n        }\\n    }\\n    else if (page == 2 || page == 28)\\n    {\\n        if (index >= self.shadow_item_values.size)\\n            return;\\n        choice = self.shadow_",
    "item_values[index];\\n        if (choice != \\\"unavailable\\\")\\n            self shadow_give_weapon(choice, self.shadow_items[index]);\\n    }\\n    else if (page == 3)\\n    {\\n        if (index == 0)\\n            self shadow_upgrade_current_weapon();\\n        else if (index == 1)\\n        {\\n            current = self shadow_equipped_weapon();\\n            if (isDefined(current) && current != \\\"none\\\")\\n                self giveMaxAmmo(current);\\n            self shadow_notice(\\\"^1SHADOW ^7Ammo refilled\\\");\\n        }\\n        else if (index == 2)\\n        {\\n            weapons = self getWeaponsListPrimaries();\\n            for (i = 0; i < weapons.size && i < 4; i++)\\n                self giveMaxAmmo(weapons[i]);\\n            self shadow_notice(\\\"^1SHADOW ^7All carried weapons refilled\\\");\\n        }\\n        else if (index == 3)\\n            self.shadow_auto_refill = !self.shadow_auto_refill;\\n        else if (index == 4)\\n            self.shadow_infinite_clip = !self.shadow_infinite_clip;\\n        else if (index == 5)\\n        {\\n            current = self shadow_equipped_weapon();\\n ",
    "           if (isDefined(current) && current != \\\"none\\\")\\n            {\\n                self takeWeapon(current);\\n                self.shadow_last_hand_weapon = undefined;\\n            }\\n        }\\n    }\\n    else if (page == 4)\\n    {\\n        if (index == 0)\\n            self thread shadow_clear_zombies();\\n        else if (index == 1)\\n            self.shadow_zombie_counter = !self.shadow_zombie_counter;\\n        else if (index == 2)\\n        {\\n            zombies = getAiArray(\\\"axis\\\");\\n            self shadow_notice(\\\"^1SHADOW ^7Zombies alive: \\\" + zombies.size);\\n        }\\n        else if (index == 3)\\n            self thread shadow_skip_round();\\n        else if (index == 4)\\n            self shadow_change_page(24);\\n    }\\n    else if (page == 5)\\n    {\\n        amount = 1337;\\n        if (index == 1) amount = 1000;\\n        if (index == 2) amount = 5000;\\n        if (index == 3) amount = 10000;\\n        if (index == 4) amount = 50000;\\n        if (index == 5) amount = 100000;\\n        if (index == 6) amount = 0 - self.score;\\n        self maps\\\\_zombiemode_score::add_",
    "to_player_score(amount);\\n        if (index == 6)\\n            self shadow_notice(\\\"^1SHADOW ^7Points reset to 0\\\");\\n        else\\n            self shadow_notice(\\\"^1SHADOW ^7Points added: \\\" + amount);\\n    }\\n    else if (page == 6)\\n    {\\n        if (index == 0)\\n            self shadow_change_page(17);\\n        else if (index == 1)\\n            self shadow_change_page(23);\\n        else if (index == 2)\\n            self.shadow_shoot_tp = !self.shadow_shoot_tp;\\n        else if (index == 3)\\n        {\\n            self.shadow_saved_origin = self.origin;\\n            self shadow_notice(\\\"^1SHADOW ^7Quick location saved\\\");\\n        }\\n        else if (index == 4)\\n        {\\n            if (isDefined(self.shadow_saved_origin))\\n                self shadow_warp(self.shadow_saved_origin, \\\"saved position\\\");\\n            else\\n                self shadow_notice(\\\"^1SHADOW ^7Save a location first\\\");\\n        }\\n        else if (index == 5)\\n            self shadow_teleport_to_crosshair();\\n        else if (index == 6)\\n        {\\n            self.shadow_spawn_origin = self.origin;\\",
    "n            self shadow_notice(\\\"^1SHADOW ^7Return point set\\\");\\n        }\\n    }\\n    else if (page == 7)\\n    {\\n        if (index == 0)\\n            self.shadow_classic_aimbot = !self.shadow_classic_aimbot;\\n        else if (index == 1)\\n            self.shadow_unfair_aimbot = !self.shadow_unfair_aimbot;\\n        else if (index == 2)\\n            self.shadow_aim_always = !self.shadow_aim_always;\\n        else if (index == 3)\\n        {\\n            if (self.shadow_aim_bone == \\\"j_head\\\")\\n                self.shadow_aim_bone = \\\"j_spine4\\\";\\n            else\\n                self.shadow_aim_bone = \\\"j_head\\\";\\n        }\\n        else if (index == 4)\\n            self.shadow_one_hit = !self.shadow_one_hit;\\n    }\\n    else if (page == 8)\\n    {\\n        if (index == 0)\\n            self shadow_notice(\\\"^1SHADOW ^7Map: \\\" + getDvar(\\\"mapname\\\"));\\n        else if (index == 1)\\n            self shadow_notice(\\\"^1SHADOW ^7Weapon: \\\" + self getCurrentWeapon());\\n        else if (index == 2)\\n        {\\n            pos = self.origin;\\n            self shadow_notice(\\\"^1SHADOW ^7X \\\" +",
    " pos[0] + \\\" Y \\\" + pos[1] + \\\" Z \\\" + pos[2]);\\n        }\\n        else\\n            self shadow_print_round();\\n    }\\n    else if (page == 9)\\n    {\\n        choice = self.shadow_item_values[index];\\n        if (choice == \\\"all_perks\\\")\\n        {\\n            for (i = 0; i < self.shadow_item_values.size; i++)\\n            {\\n                perk = self.shadow_item_values[i];\\n                if (perk != \\\"all_perks\\\" && perk != \\\"clear_perks\\\" && perk != \\\"back\\\")\\n                    self shadow_grant_perk(perk);\\n            }\\n            self shadow_notice(\\\"^1SHADOW ^7Available perks granted\\\");\\n        }\\n        else if (choice == \\\"clear_perks\\\")\\n        {\\n            self clearPerks();\\n            self shadow_notice(\\\"^1SHADOW ^7Perks cleared\\\");\\n        }\\n        else\\n        {\\n            self shadow_grant_perk(choice);\\n            self shadow_notice(\\\"^1SHADOW ^7Perk granted: \\\" + self.shadow_items[index]);\\n        }\\n    }\\n    else if (page == 10)\\n    {\\n        choice = self.shadow_item_values[index];\\n        if (choice == \\\"doors\\\")\\n            self t",
    "hread shadow_unlock_all_doors(0);\\n        else if (choice == \\\"doors_only\\\")\\n            self thread shadow_unlock_all_doors(1);\\n        else if (choice == \\\"debris_only\\\")\\n            self thread shadow_unlock_all_doors(2);\\n        else if (choice == \\\"power\\\")\\n            self thread shadow_turn_power_on();\\n        else if (choice == \\\"jump\\\")\\n        {\\n            level.shadow_super_jump = !level.shadow_super_jump;\\n            self shadow_apply_movement_dvars();\\n        }\\n        else if (choice == \\\"gravity\\\")\\n        {\\n            level.shadow_low_gravity = !level.shadow_low_gravity;\\n            self shadow_apply_movement_dvars();\\n        }\\n    }\\n    else if (page == 11)\\n    {\\n        if (index == 0)\\n            self.shadow_key_mode = !self.shadow_key_mode;\\n        else if (index == 1)\\n        {\\n            if (self.shadow_key_repeat >= 180)\\n                self.shadow_key_repeat = 145;\\n            else if (self.shadow_key_repeat >= 110)\\n                self.shadow_key_repeat = 75;\\n            else\\n                self.shadow_key_repeat = 215;\\n     ",
    "   }\\n        else if (index == 2)\\n            self.shadow_invert_scroll = !self.shadow_invert_scroll;\\n        else if (index == 3)\\n            self.shadow_swap_horizontal = !self.shadow_swap_horizontal;\\n        else if (index == 4)\\n            self shadow_cycle_noclip_bind();\\n        else if (index == 5)\\n        {\\n            self.shadow_key_mode = 0;\\n            self.shadow_key_repeat = 215;\\n            self.shadow_invert_scroll = false;\\n            self.shadow_swap_horizontal = false;\\n            self.shadow_noclip_bind = 1;\\n            if (self.shadow_noclip_active)\\n                self.shadow_noclip_dirty = true;\\n        }\\n    }\\n    else if (page == 17)\\n    {\\n        if (index == 6)\\n        {\\n            if (isDefined(self.shadow_spawn_origin))\\n                self shadow_warp(self.shadow_spawn_origin, \\\"spawn\\\");\\n            else\\n                self shadow_notice(\\\"^1SHADOW ^7Spawn point unavailable\\\");\\n        }\\n        else\\n        {\\n            slot = 0;\\n            if (index == 2 || index == 3)\\n                slot = 1;\\n            else if (i",
    "ndex == 4 || index == 5)\\n                slot = 2;\\n            if (index == 0 || index == 2 || index == 4)\\n            {\\n                self.shadow_room_slots[slot] = self.origin;\\n                self shadow_notice(\\\"^1SHADOW ^7Room bookmark saved\\\");\\n            }\\n            else if (isDefined(self.shadow_room_slots[slot]))\\n                self shadow_warp(self.shadow_room_slots[slot], \\\"room bookmark\\\");\\n            else\\n                self shadow_notice(\\\"^1SHADOW ^7Save this room slot first\\\");\\n        }\\n    }\\n    else if (page == 18)\\n    {\\n        if (index == 0)\\n            self thread shadow_five_auto_defcon();\\n        else if (index == 1)\\n            self shadow_five_warp(0);\\n        else if (index == 2)\\n            self shadow_five_warp(1);\\n        else if (index == 3)\\n            self shadow_five_warp(2);\\n        else if (index == 4)\\n            self shadow_five_warp(3);\\n        else if (index == 5)\\n            self shadow_five_status();\\n    }\\n    else if (page == 19)\\n    {\\n        if (index == 0)\\n            self.shadow_selection_visible =",
    " !self.shadow_selection_visible;\\n        else if (index == 1)\\n        {\\n            self shadow_change_page(26);\\n            return;\\n        }\\n    }\\n    else if (page == 21)\\n    {\\n        if (index == 0)\\n        {\\n            self.shadow_menu_auto_protect = !self.shadow_menu_auto_protect;\\n            self.ignoreme = self.shadow_user_notarget || self.shadow_was_ignored ||\\n                (self.shadow_menu_auto_protect && self.shadow_open);\\n            self.shadow_menu_invuln_applied = self.shadow_menu_auto_protect;\\n            if (self.shadow_god || self.shadow_menu_invuln_applied)\\n                self enableInvulnerability();\\n            else\\n                self disableInvulnerability();\\n        }\\n        else if (index == 1)\\n            self.shadow_low_effects = !self.shadow_low_effects;\\n        else if (index == 2)\\n        {\\n            self shadow_close();\\n            return;\\n        }\\n    }\\n    else if (page == 22)\\n    {\\n        if (index == 0)\\n            self.shadow_fx_enabled = !self.shadow_fx_enabled;\\n        else if (index == 1)\\n        {\\n ",
    "           self.shadow_fx_style++;\\n            if (self.shadow_fx_style > 4)\\n                self.shadow_fx_style = 0;\\n        }\\n        else if (index == 2)\\n        {\\n            self.shadow_ammo_mode++;\\n            if (self.shadow_ammo_mode > 4)\\n                self.shadow_ammo_mode = 0;\\n        }\\n        else if (index == 3)\\n            self.shadow_nuke_rounds = !self.shadow_nuke_rounds;\\n    }\\n    else if (page == 23)\\n    {\\n        if (index < self.shadow_map_spots.size &&\\n            isDefined(self.shadow_map_spots[index]))\\n            self shadow_warp(self.shadow_map_spots[index], \\\"map location\\\");\\n    }\\n    else if (page == 24)\\n    {\\n        if (index == 0)\\n            self shadow_queue_zombies(1);\\n        else if (index == 1)\\n            self shadow_queue_zombies(5);\\n        else if (index == 2)\\n            self shadow_queue_zombies(10);\\n    }\\n    else if (page == 26)\\n    {\\n        if (index == 0)\\n            self.shadow_color_r = self shadow_step_color(self.shadow_color_r);\\n        else if (index == 1)\\n            self.shadow_color_g = self s",
    "hadow_step_color(self.shadow_color_g);\\n        else if (index == 2)\\n            self.shadow_color_b = self shadow_step_color(self.shadow_color_b);\\n        else if (index == 3)\\n            self shadow_next_palette();\\n        else if (index == 4)\\n        {\\n            self.shadow_palette = 0;\\n            self.shadow_color_r = 0.90;\\n            self.shadow_color_g = 0.035;\\n            self.shadow_color_b = 0.022;\\n        }\\n        self shadow_apply_theme();\\n    }\\n    else if (page == 27)\\n    {\\n        if (index == 0)\\n            self shadow_spawn_powerup(\\\"nuke\\\", true);\\n        else if (index == 1)\\n            self shadow_spawn_powerup(\\\"full_ammo\\\", false);\\n        else if (index == 2)\\n            self shadow_spawn_powerup(\\\"insta_kill\\\", false);\\n        else if (index == 3)\\n            self shadow_spawn_powerup(\\\"double_points\\\", false);\\n        else if (index == 4)\\n            self shadow_spawn_powerup(\\\"carpenter\\\", false);\\n        else if (index == 5)\\n            self shadow_spawn_powerup(\\\"fire_sale\\\", false);\\n        else if (index == 6)\\n            ",
    "self shadow_spawn_powerup(\\\"bonfire_sale\\\", false);\\n        else if (index == 7)\\n            self shadow_spawn_powerup(\\\"free_perk\\\", false);\\n        else if (index == 8)\\n            self shadow_spawn_powerup(\\\"minigun\\\", false);\\n    }\\n    else if (page == 12)\\n    {\\n        if (index == 6)\\n        {\\n            self.shadow_achievement_survivor = true;\\n            self.shadow_achievement_veteran = true;\\n            self.shadow_achievement_rich = true;\\n            self.shadow_achievement_century = true;\\n            self.shadow_achievement_banker = true;\\n            self shadow_notice(\\\"^1SHADOW ^7All local badges unlocked (not platform awards)\\\");\\n        }\\n        else if (index == 7)\\n        {\\n            self.shadow_achievement_survivor = false;\\n            self.shadow_achievement_veteran = false;\\n            self.shadow_achievement_rich = false;\\n            self.shadow_achievement_century = false;\\n            self.shadow_achievement_banker = false;\\n            self shadow_notice(\\\"^1SHADOW ^7Local badges reset\\\");\\n        }\\n        else\\n            self s",
    "hadow_notice(\\\"^1SHADOW ^7Local session badges, not platform achievements\\\");\\n    }\\n\\n    self shadow_define_page();\\n    if (self.shadow_cursor >= self.shadow_items.size)\\n        self.shadow_cursor = self.shadow_items.size - 1;\\n    if (self.shadow_cursor < self.shadow_window)\\n        self.shadow_window = self.shadow_cursor;\\n    self shadow_paint_page();\\n}\\n\\nshadow_print_round()\\n{\\n    if (isDefined(level.round_number))\\n        self shadow_notice(\\\"^1SHADOW ^7Round: \\\" + level.round_number);\\n    else\\n        self shadow_notice(\\\"^1SHADOW ^7Round information unavailable\\\");\\n}\\n\\nshadow_spawn_pending_text()\\n{\\n    if (isDefined(level.zombie_total))\\n        return level.zombie_total;\\n    return \\\"Unavailable\\\";\\n}\\n\\nshadow_queue_zombies(amount)\\n{\\n    if (!isDefined(level.zombie_total) || !isDefined(level.enemy_spawns) ||\\n        level.enemy_spawns.size == 0)\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Map spawner not ready\\\");\\n        return;\\n    }\\n    if (level.zombie_total + amount > 50)\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Spawn queue capped at 5",
    "0\\\");\\n        return;\\n    }\\n    level.zombie_total += amount;\\n    self shadow_notice(\\\"^1SHADOW ^7Queued \\\" + amount + \\\" zombies through round spawner\\\");\\n}\\n\\nshadow_warp(position, label)\\n{\\n    if (!isDefined(position))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Teleport destination unavailable\\\");\\n        return;\\n    }\\n\\n    if (self.shadow_open)\\n        self.shadow_lock_origin = position;\\n    self setVelocity((0, 0, 0));\\n    self setOrigin(position);\\n    self shadow_notice(\\\"^1SHADOW ^7Teleported: \\\" + label);\\n}\\n\\nshadow_add_map_spot(label, position)\\n{\\n    if (!isDefined(position) || self.shadow_items.size >= 7)\\n        return;\\n    index = self.shadow_items.size;\\n    self.shadow_map_spots[index] = position;\\n    self shadow_add_option(label, \\\"spot\\\");\\n}\\n\\nshadow_perk_spot_name(perk)\\n{\\n    if (perk == \\\"specialty_armorvest\\\") return \\\"Juggernog Room\\\";\\n    if (perk == \\\"specialty_fastreload\\\") return \\\"Speed Cola Room\\\";\\n    if (perk == \\\"specialty_rof\\\") return \\\"Double Tap Room\\\";\\n    if (perk == \\\"specialty_quickrevive\\\") return \\\"Quick Revive ",
    "Room\\\";\\n    if (perk == \\\"specialty_longersprint\\\") return \\\"Stamin-Up Room\\\";\\n    if (perk == \\\"specialty_detectexplosive\\\") return \\\"PhD Flopper Room\\\";\\n    if (perk == \\\"specialty_deadshot\\\") return \\\"Deadshot Room\\\";\\n    if (perk == \\\"specialty_additionalprimaryweapon\\\") return \\\"Mule Kick Room\\\";\\n    return \\\"Perk Machine Room\\\";\\n}\\n\\nshadow_build_map_spots()\\n{\\n    self.shadow_map_spots = [];\\n    if (isDefined(self.shadow_spawn_origin))\\n        self shadow_add_map_spot(\\\"Return Point\\\", self.shadow_spawn_origin);\\n\\n    power = getEntArray(\\\"use_power_switch\\\", \\\"targetname\\\");\\n    if (power.size == 0)\\n        power = getEntArray(\\\"use_elec_switch\\\", \\\"targetname\\\");\\n    if (power.size > 0 && isDefined(power[0].origin))\\n        self shadow_add_map_spot(\\\"Power Switch\\\", power[0].origin + (0, 0, 36));\\n    upgrade = getEntArray(\\\"zombie_vending_upgrade\\\", \\\"targetname\\\");\\n    if (upgrade.size > 0 && isDefined(upgrade[0].origin) &&\\n        getDvar(\\\"mapname\\\") != \\\"zombie_pentagon\\\")\\n        self shadow_add_map_spot(\\\"Pack-a-Punch Machine\\\", upgrade[0].origin + (0",
    ", 0, 36));\\n\\n    perks = getEntArray(\\\"zombie_vending\\\", \\\"targetname\\\");\\n    for (i = 0; i < perks.size && i < 10 && self.shadow_items.size < 7; i++)\\n    {\\n        if (isDefined(perks[i]) && isDefined(perks[i].origin) &&\\n            isDefined(perks[i].script_noteworthy))\\n            self shadow_add_map_spot(self shadow_perk_spot_name(perks[i].script_noteworthy),\\n                perks[i].origin + (0, 0, 36));\\n    }\\n    if (self.shadow_items.size == 0)\\n        self shadow_add_option(\\\"No known map locations yet\\\", \\\"unavailable\\\");\\n}\\n\\nshadow_five_status()\\n{\\n    if (getDvar(\\\"mapname\\\") != \\\"zombie_pentagon\\\")\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Five features unavailable on this map\\\");\\n        return;\\n    }\\n    power_status = \\\"OFF\\\";\\n    if (flag(\\\"power_on\\\"))\\n        power_status = \\\"ON\\\";\\n    if (isDefined(level.defcon_level))\\n        self shadow_notice(\\\"^1SHADOW ^7Power \\\" + power_status + \\\" / DEFCON \\\" + level.defcon_level);\\n    else\\n        self shadow_notice(\\\"^1SHADOW ^7Power \\\" + power_status);\\n}\\n\\nshadow_five_auto_defcon()\\n{\\n    sel",
    "f endon(\\\"disconnect\\\");\\n    if (self.shadow_busy_defcon || getTime() - self.shadow_defcon_last < 1800)\\n        return;\\n    if (getDvar(\\\"mapname\\\") != \\\"zombie_pentagon\\\")\\n        return;\\n    if (!flag(\\\"power_on\\\"))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Five: activate power first\\\");\\n        return;\\n    }\\n    if (flag(\\\"defcon_active\\\"))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7DEFCON already active - use a teleporter\\\");\\n        return;\\n    }\\n    switches = getEntArray(\\\"punch_switch\\\", \\\"targetname\\\");\\n    if (switches.size < 4)\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7DEFCON switches not initialized\\\");\\n        return;\\n    }\\n    self.shadow_busy_defcon = true;\\n    self.shadow_defcon_last = getTime();\\n    for (i = 0; i < switches.size && i < 4; i++)\\n    {\\n        if (isDefined(switches[i]) && !flag(\\\"defcon_active\\\"))\\n            switches[i] notify(\\\"trigger\\\", self);\\n        wait 0.26;\\n    }\\n    if (flag(\\\"defcon_active\\\"))\\n        self shadow_notice(\\\"^1SHADOW ^7DEFCON 5: Pack-a-Punch route active\\\");\\n    else\\n        self shado",
    "w_notice(\\\"^1SHADOW ^7DEFCON not ready; try the War Room switches\\\");\\n    self.shadow_busy_defcon = false;\\n}\\n\\nshadow_five_warp(spot)\\n{\\n    if (getDvar(\\\"mapname\\\") != \\\"zombie_pentagon\\\")\\n        return;\\n    if (spot == 0 && isDefined(level.portal_top))\\n        self shadow_warp(level.portal_top.origin + (0, 0, 38), \\\"top floor\\\");\\n    else if (spot == 1 && isDefined(level.portal_mid))\\n        self shadow_warp(level.portal_mid.origin + (0, 0, 38), \\\"war room\\\");\\n    else if (spot == 2 && isDefined(level.portal_bottom) &&\\n        level.portal_bottom.size > 0)\\n        self shadow_warp(level.portal_bottom[0].origin + (0, 0, 38), \\\"labs\\\");\\n    else if (spot == 3)\\n    {\\n        if (!flag(\\\"defcon_active\\\"))\\n        {\\n            self shadow_notice(\\\"^1SHADOW ^7Open DEFCON 5 before entering Pack room\\\");\\n            return;\\n        }\\n        if (isDefined(level.portal_pack))\\n            self shadow_warp(level.portal_pack.origin + (0, 0, 38), \\\"Panic Room\\\");\\n        else\\n            self shadow_notice(\\\"^1SHADOW ^7Panic Room portal not ready\\\");\\n    }\\n    else\\n ",
    "       self shadow_notice(\\\"^1SHADOW ^7Five portal not ready (power may be off)\\\");\\n}\\n\\nshadow_give_weapon(name, label)\\n{\\n    if (!isDefined(level.zombie_weapons) ||\\n        !isDefined(level.zombie_weapons[name]) ||\\n        !isDefined(level.zombie_include_weapons) ||\\n        !isDefined(level.zombie_include_weapons[name]))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Weapon not registered on this map\\\");\\n        return;\\n    }\\n\\n    if (self hasWeapon(name))\\n    {\\n        self giveMaxAmmo(name);\\n        self shadow_notice(\\\"^1SHADOW ^7Ammo refilled: \\\" + label);\\n        return;\\n    }\\n\\n    self maps\\\\_zombiemode_weapons::weapon_give(name);\\n    if (self hasWeapon(name))\\n        self shadow_notice(\\\"^1SHADOW ^7Equipped: \\\" + label);\\n    else\\n        self shadow_notice(\\\"^1SHADOW ^7Game rejected this item\\\");\\n}\\n\\nshadow_equipped_weapon()\\n{\\n    current = self getCurrentWeapon();\\n    if (!isDefined(current) || current == \\\"none\\\" || !self hasWeapon(current))\\n        current = self.shadow_last_hand_weapon;\\n    if (isDefined(current) && current != \\\"none\\\" && sel",
    "f hasWeapon(current))\\n        return current;\\n    return \\\"none\\\";\\n}\\n\\nshadow_upgrade_current_weapon()\\n{\\n    current = self getCurrentWeapon();\\n    if (!isDefined(current) || current == \\\"none\\\" || !self hasWeapon(current))\\n        current = self.shadow_last_hand_weapon;\\n    if (!isDefined(current) || current == \\\"none\\\" || !self hasWeapon(current))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7No equipped weapon found\\\");\\n        return;\\n    }\\n\\n    if (current == \\\"microwavegun_zm\\\" && self hasWeapon(\\\"microwavegundw_zm\\\"))\\n        current = \\\"microwavegundw_zm\\\";\\n\\n    if (!isDefined(level.zombie_weapons) ||\\n        !isDefined(level.zombie_weapons[current]) ||\\n        !isDefined(level.zombie_weapons[current].upgrade_name) ||\\n        self maps\\\\_zombiemode_weapons::is_weapon_upgraded(current))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Already upgraded or not Pack-a-Punchable\\\");\\n        return;\\n    }\\n    upgraded = level.zombie_weapons[current].upgrade_name;\\n    if (!isDefined(upgraded) || upgraded == \\\"\\\" || upgraded == current)\\n    {\\n        self sh",
    "adow_notice(\\\"^1SHADOW ^7No Pack-a-Punch version on this map\\\");\\n        return;\\n    }\\n\\n    old_clip = self getWeaponAmmoClip(current);\\n    old_stock = self getWeaponAmmoStock(current);\\n    self takeWeapon(current);\\n    self giveWeapon(upgraded, 0,\\n        self maps\\\\_zombiemode_weapons::get_pack_a_punch_weapon_options(upgraded));\\n    if (!self hasWeapon(upgraded))\\n    {\\n        self giveWeapon(current);\\n        if (self hasWeapon(current))\\n        {\\n            self setWeaponAmmoClip(current, old_clip);\\n            self setWeaponAmmoStock(current, old_stock);\\n            self switchToWeapon(current);\\n        }\\n        self shadow_notice(\\\"^1SHADOW ^7Upgrade failed; original weapon restored\\\");\\n        return;\\n    }\\n\\n    self giveStartAmmo(upgraded);\\n    self switchToWeapon(upgraded);\\n    self.shadow_last_hand_weapon = upgraded;\\n    self shadow_notice(\\\"^1SHADOW ^7Pack-a-Punched equipped weapon\\\");\\n}\\n\\nshadow_grant_perk(perk)\\n{\\n    if (!self hasPerk(perk))\\n        self maps\\\\_zombiemode_perks::give_perk(perk, false);\\n}\\n\\nshadow_refill_loop()\\n{\\n    se",
    "lf endon(\\\"disconnect\\\");\\n\\n    while (self.shadow_running)\\n    {\\n        if (self.shadow_auto_refill || self.shadow_infinite_clip)\\n        {\\n            current = self getCurrentWeapon();\\n            if (isDefined(current) && current != \\\"none\\\")\\n            {\\n                if (self.shadow_auto_refill)\\n                    self giveMaxAmmo(current);\\n                if (self.shadow_infinite_clip)\\n                {\\n                    maximum = weaponClipSize(current);\\n                    if (maximum > 0)\\n                        self setWeaponAmmoClip(current, maximum);\\n                }\\n            }\\n        }\\n        if (self.shadow_auto_refill || self.shadow_infinite_clip)\\n            wait 0.25;\\n        else\\n            wait 1.0;\\n    }\\n}\\n\\nshadow_ammo_effect_loop()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    last_attack = false;\\n    while (self.shadow_running)\\n    {\\n        if (self.shadow_ammo_mode == 0 && !self.shadow_fx_enabled &&\\n            !self.shadow_nuke_rounds &&\\n            !self.shadow_shoot_tp)\\n        {\\n            last_attack = false;\\n",
    "            wait 0.55;\\n            continue;\\n        }\\n        attack = self attackButtonPressed();\\n        if ((self.shadow_ammo_mode > 0 || self.shadow_fx_enabled ||\\n            self.shadow_nuke_rounds ||\\n            self.shadow_shoot_tp) && !self.shadow_open &&\\n            attack && !last_attack)\\n        {\\n            start = self getEye();\\n            finish = start + (anglesToForward(self getPlayerAngles()) * 3500);\\n            trace = bulletTrace(start, finish, false, self);\\n            if (isDefined(trace) && isDefined(trace[\\\"position\\\"]))\\n            {\\n                hit = trace[\\\"position\\\"];\\n                if (self.shadow_nuke_rounds)\\n                    self shadow_trigger_shot_nuke();\\n                if (self.shadow_fx_enabled &&\\n                    getTime() - self.shadow_last_fx >=\\n                    self shadow_fx_cooldown())\\n                {\\n                    self.shadow_last_fx = getTime();\\n                    self shadow_impact_fx(hit);\\n                }\\n\\n                if (self.shadow_ammo_mode == 1)\\n                {\\n            ",
    "        radiusDamage(hit, 135, 300, 30, self);\\n                }\\n\\n                else if (isDefined(trace[\\\"entity\\\"]))\\n                {\\n                    victim = trace[\\\"entity\\\"];\\n                    if (isDefined(victim.health) && victim.health > 0)\\n                    {\\n                        if (self.shadow_ammo_mode == 2)\\n                            victim doDamage(1250, hit, self);\\n                        else if (self.shadow_ammo_mode == 3)\\n                            victim doDamage(victim.health + 1000, hit, self);\\n                        else if (self.shadow_ammo_mode == 4 &&\\n                            (!isDefined(victim.shadow_burn_active) || !victim.shadow_burn_active))\\n                            self thread shadow_burn_target(victim);\\n                    }\\n                }\\n\\n                if (self.shadow_shoot_tp &&\\n                    getTime() - self.shadow_last_shoot_tp >= 650 &&\\n                    isDefined(trace[\\\"fraction\\\"]) && trace[\\\"fraction\\\"] < 0.98 &&\\n                    distance(start, hit) >= 80)\\n                {\\n       ",
    "             landing = hit + (0, 0, 42);\\n                    if (isDefined(trace[\\\"normal\\\"]))\\n                        landing += trace[\\\"normal\\\"] * 24;\\n                    self.shadow_last_shoot_tp = getTime();\\n                    self shadow_warp(landing, \\\"shoot-to-TP impact\\\");\\n                }\\n            }\\n        }\\n\\n        last_attack = attack;\\n        wait 0.05;\\n    }\\n}\\n\\nshadow_impact_fx(hit)\\n{\\n    if (!isDefined(level._effect))\\n        return;\\n    if (self.shadow_fx_style == 0 && isDefined(level._effect[\\\"def_explosion\\\"]))\\n        playFX(level._effect[\\\"def_explosion\\\"], hit);\\n    else if (self.shadow_fx_style == 1 && isDefined(level._effect[\\\"tesla_head_light\\\"]))\\n        playFX(level._effect[\\\"tesla_head_light\\\"], hit);\\n    else if (self.shadow_fx_style == 2 && isDefined(level._effect[\\\"character_fire_pain_sm\\\"]))\\n        playFX(level._effect[\\\"character_fire_pain_sm\\\"], hit);\\n    else if (self.shadow_fx_style == 3 && isDefined(level._effect[\\\"bloodspurt\\\"]))\\n        playFX(level._effect[\\\"bloodspurt\\\"], hit);\\n    else if (self.shadow_fx_style",
    " == 4 && isDefined(level._effect[\\\"rise_burst\\\"]))\\n        playFX(level._effect[\\\"rise_burst\\\"], hit);\\n}\\n\\nshadow_burn_target(victim)\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    if (!isDefined(victim) || !isAlive(victim) ||\\n        (isDefined(victim.shadow_burn_active) && victim.shadow_burn_active))\\n        return;\\n    victim.shadow_burn_active = true;\\n\\n    for (tick = 0; tick < 5; tick++)\\n    {\\n        if (!isDefined(victim) || !isAlive(victim))\\n        {\\n            if (isDefined(victim))\\n                victim.shadow_burn_active = false;\\n            return;\\n        }\\n        victim doDamage(75, victim.origin, self);\\n        wait 0.35;\\n    }\\n    if (isDefined(victim))\\n        victim.shadow_burn_active = false;\\n}\\n\\nshadow_one_hit_loop()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    while (self.shadow_running)\\n    {\\n        if (self.shadow_one_hit)\\n        {\\n            zombies = getAiArray(\\\"axis\\\");\\n            for (i = 0; i < zombies.size && i < 128; i++)\\n            {\\n                if (isDefined(zombies[i]) && isAlive(zombies[i]) && zombies[i].health > ",
    "1)\\n                    zombies[i].health = 1;\\n            }\\n        }\\n        if (self.shadow_one_hit)\\n            wait 0.75;\\n        else\\n            wait 1.5;\\n    }\\n}\\n\\nshadow_achievement_loop()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    while (self.shadow_running)\\n    {\\n        if (isDefined(level.round_number) && level.round_number >= 5 &&\\n            !self.shadow_achievement_survivor)\\n        {\\n            self.shadow_achievement_survivor = true;\\n            self shadow_notice(\\\"^1SHADOW GARDEN ^7Challenge: Survivor V\\\");\\n        }\\n        if (isDefined(level.round_number) && level.round_number >= 10 &&\\n            !self.shadow_achievement_veteran)\\n        {\\n            self.shadow_achievement_veteran = true;\\n            self shadow_notice(\\\"^1SHADOW GARDEN ^7Challenge: Veteran X\\\");\\n        }\\n        if (isDefined(self.score) && self.score >= 10000 &&\\n            !self.shadow_achievement_rich)\\n        {\\n            self.shadow_achievement_rich = true;\\n            self shadow_notice(\\\"^1SHADOW GARDEN ^7Challenge: Wealth 10K\\\");\\n        }\\n        if ",
    "(isDefined(self.kills) && self.kills >= 100 &&\\n            !self.shadow_achievement_century)\\n        {\\n            self.shadow_achievement_century = true;\\n            self shadow_notice(\\\"^1SHADOW GARDEN ^7Challenge: Hunter 100\\\");\\n        }\\n        if (isDefined(self.score) && self.score >= 100000 &&\\n            !self.shadow_achievement_banker)\\n        {\\n            self.shadow_achievement_banker = true;\\n            self shadow_notice(\\\"^1SHADOW GARDEN ^7Challenge: Banker 100K\\\");\\n        }\\n        wait 4;\\n    }\\n}\\n\\nshadow_create_counter_hud()\\n{\\n    self.shadow_count_hud = newClientHudElem(self);\\n    self.shadow_count_hud.horzAlign = \\\"left\\\";\\n    self.shadow_count_hud.vertAlign = \\\"top\\\";\\n    self.shadow_count_hud.alignX = \\\"left\\\";\\n    self.shadow_count_hud.alignY = \\\"top\\\";\\n    self.shadow_count_hud.x = 18;\\n    self.shadow_count_hud.y = 121;\\n    self.shadow_count_hud.font = \\\"default\\\";\\n    self.shadow_count_hud.fontScale = 1.05;\\n    self.shadow_count_hud.color = self shadow_accent();\\n    self.shadow_count_hud.alpha = 1;\\n    self.shadow_count_hud.sort ",
    "= 8;\\n    self.shadow_count_hud.hideWhenInMenu = false;\\n    self.shadow_count_hud setText(\\\"ZOMBIES  0\\\");\\n}\\n\\nshadow_remove_counter_hud()\\n{\\n    if (isDefined(self.shadow_count_hud))\\n        self.shadow_count_hud destroy();\\n    self.shadow_count_hud = undefined;\\n}\\n\\nshadow_counter_loop()\\n{\\n    self endon(\\\"disconnect\\\");\\n    last_count = -1;\\n    while (self.shadow_running)\\n    {\\n        if (self.shadow_zombie_counter && !self.shadow_open)\\n        {\\n            if (!isDefined(self.shadow_count_hud))\\n            {\\n                self shadow_create_counter_hud();\\n                last_count = -1;\\n            }\\n            zombies = getAiArray(\\\"axis\\\");\\n            if (last_count != zombies.size)\\n            {\\n                self.shadow_count_hud setText(\\\"ZOMBIES  \\\" + zombies.size);\\n                last_count = zombies.size;\\n            }\\n        }\\n        else\\n        {\\n            if (isDefined(self.shadow_count_hud))\\n                self shadow_remove_counter_hud();\\n            last_count = -1;\\n        }\\n        wait 0.5;\\n    }\\n}\\n\\nshadow_aimb",
    "ot_loop()\\n{\\n    self endon(\\\"disconnect\\\");\\n    old_attack = false;\\n\\n    while (self.shadow_running)\\n    {\\n        if (self.shadow_open ||\\n            (!self.shadow_classic_aimbot && !self.shadow_unfair_aimbot))\\n        {\\n            self.shadow_aim_target = undefined;\\n            old_attack = false;\\n            wait 0.55;\\n            continue;\\n        }\\n\\n        attack = self attackButtonPressed();\\n        aim_active = self.shadow_classic_aimbot &&\\n            (self adsButtonPressed() || self.shadow_aim_always);\\n        shoot_active = self.shadow_unfair_aimbot && attack && !old_attack &&\\n            getTime() - self.shadow_unfair_last_shot >= 280;\\n\\n        if (aim_active || shoot_active)\\n        {\\n            if (getTime() >= self.shadow_aim_next_scan ||\\n                !isDefined(self.shadow_aim_target) ||\\n                !isAlive(self.shadow_aim_target))\\n            {\\n                self.shadow_aim_target = self shadow_nearest_zombie();\\n                self.shadow_aim_next_scan = getTime() + 250;\\n            }\\n\\n            target = self.shadow_aim_",
    "target;\\n            if (isDefined(target) && isAlive(target) &&\\n                distance(self.origin, target.origin) < 4200)\\n            {\\n                hit = target.origin + (0, 0, 37);\\n                if (self.shadow_aim_bone == \\\"j_head\\\")\\n                    hit = target.origin + (0, 0, 55);\\n\\n                if (aim_active)\\n                    self setPlayerAngles(vectorToAngles(hit - self getEye()));\\n\\n                if (shoot_active)\\n                {\\n                    weapon = self getCurrentWeapon();\\n                    if (isDefined(weapon) && weapon != \\\"none\\\" && target.health > 0)\\n                    {\\n                        self.shadow_unfair_last_shot = getTime();\\n                        target doDamage(target.health + 100, hit, self);\\n                    }\\n                }\\n            }\\n        }\\n\\n        old_attack = attack;\\n        wait 0.075;\\n    }\\n}\\n\\nshadow_nearest_zombie()\\n{\\n    zombies = getAiArray(\\\"axis\\\");\\n    best = undefined;\\n    best_distance = 4200;\\n    for (i = 0; i < zombies.size && i < 112; i++)\\n    {\\n        zom",
    "bie = zombies[i];\\n        if (!isDefined(zombie) || !isAlive(zombie))\\n            continue;\\n        d = distance(self.origin, zombie.origin);\\n        if (d < best_distance)\\n        {\\n            best_distance = d;\\n            best = zombie;\\n        }\\n    }\\n    return best;\\n}\\n\\nshadow_clear_zombies()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    if (self.shadow_busy_clear)\\n        return;\\n    self.shadow_busy_clear = true;\\n\\n    zombies = getAiArray(\\\"axis\\\");\\n    for (i = 0; i < zombies.size && i < 128; i++)\\n    {\\n        if (isDefined(zombies[i]) && isAlive(zombies[i]))\\n            zombies[i] doDamage(zombies[i].health + 1000, zombies[i].origin, self);\\n\\n        wait 0.05;\\n    }\\n    self shadow_notice(\\\"^1SHADOW ^7Spawned zombies cleared\\\");\\n    self.shadow_busy_clear = false;\\n}\\n\\nshadow_skip_round()\\n{\\n    self endon(\\\"disconnect\\\");\\n\\n    if (!isDefined(level.round_number) || !flag(\\\"begin_spawning\\\") ||\\n        is_true(level.intermission) || is_true(level.dog_intermission))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Wait for an active round\\\");\\n    ",
    "    return;\\n    }\\n    if ((isDefined(level.shadow_skip_round_busy) && level.shadow_skip_round_busy) ||\\n        (isDefined(level.shadow_last_round_skip) &&\\n        getTime() - level.shadow_last_round_skip < 3000))\\n        return;\\n\\n    level.shadow_skip_round_busy = true;\\n    level.shadow_last_round_skip = getTime();\\n    old_round = level.round_number;\\n\\n    level.zombie_total = 0;\\n    for (pass = 0; pass < 4; pass++)\\n    {\\n        zombies = getAiArray(\\\"axis\\\");\\n        for (i = 0; i < zombies.size && i < 128; i++)\\n        {\\n            if (isDefined(zombies[i]) && isAlive(zombies[i]))\\n                zombies[i] doDamage(zombies[i].health + 1000, zombies[i].origin, self);\\n        }\\n        wait 0.10;\\n    }\\n    if (level.round_number == old_round)\\n        level.zombie_total = 0;\\n    level.shadow_skip_round_busy = false;\\n    self shadow_notice(\\\"^1SHADOW ^7Round \\\" + old_round + \\\" cleared; advancing\\\");\\n}\\n\\nshadow_accent()\\n{\\n    return (self.shadow_color_r, self.shadow_color_g, self.shadow_color_b);\\n}\\n\\nshadow_step_color(value)\\n{\\n    value += 0.16;\\n    ",
    "if (value > 1)\\n        value = 0;\\n    return value;\\n}\\n\\nshadow_next_palette()\\n{\\n    self.shadow_palette++;\\n    if (self.shadow_palette > 4)\\n        self.shadow_palette = 0;\\n    if (self.shadow_palette == 0)\\n    {\\n        self.shadow_color_r = 0.90;\\n        self.shadow_color_g = 0.035;\\n        self.shadow_color_b = 0.022;\\n    }\\n    else if (self.shadow_palette == 1)\\n    {\\n        self.shadow_color_r = 0.30;\\n        self.shadow_color_g = 0.68;\\n        self.shadow_color_b = 1;\\n    }\\n    else if (self.shadow_palette == 2)\\n    {\\n        self.shadow_color_r = 0.50;\\n        self.shadow_color_g = 0.96;\\n        self.shadow_color_b = 0.28;\\n    }\\n    else if (self.shadow_palette == 3)\\n    {\\n        self.shadow_color_r = 0.88;\\n        self.shadow_color_g = 0.38;\\n        self.shadow_color_b = 1;\\n    }\\n    else\\n    {\\n        self.shadow_color_r = 1;\\n        self.shadow_color_g = 0.68;\\n        self.shadow_color_b = 0.20;\\n    }\\n}\\n\\nshadow_apply_theme()\\n{\\n    if (!self.shadow_open)\\n        return;\\n    if (isDefined(self.shadow_section))\\n        self.shadow",
    "_section.color = self shadow_accent();\\n    if (isDefined(self.shadow_subtitle))\\n        self.shadow_subtitle.color = self shadow_accent();\\n    if (isDefined(self.shadow_edge))\\n        self.shadow_edge.color = self shadow_accent();\\n    if (isDefined(self.shadow_rule))\\n        self.shadow_rule.color = self shadow_accent();\\n    if (isDefined(self.shadow_footer_rule))\\n        self.shadow_footer_rule.color = self shadow_accent();\\n    if (isDefined(self.shadow_scroll_thumb))\\n        self.shadow_scroll_thumb.color = self shadow_accent();\\n    self shadow_paint_cursor();\\n}\\n\\nshadow_spawn_powerup(type, activate)\\n{\\n    if (!isDefined(level.zombie_powerups) ||\\n        !isDefined(level.zombie_powerups[type]))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Power-up unavailable on this map\\\");\\n        return false;\\n    }\\n    if (getTime() - self.shadow_last_powerup_drop < 1200)\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Wait before spawning another power-up\\\");\\n        return false;\\n    }\\n    self.shadow_last_powerup_drop = getTime();\\n    if (activate)\\n        point = ",
    "self.origin;\\n    else\\n        point = self.origin + (anglesToForward(self getPlayerAngles()) * 96);\\n    level thread maps\\\\_zombiemode_powerups::specific_powerup_drop(type, point);\\n    self shadow_notice(\\\"^1SHADOW ^7Power-up spawned: \\\" + type);\\n    return true;\\n}\\n\\nshadow_trigger_shot_nuke()\\n{\\n    if (!self.shadow_nuke_rounds || !isDefined(level.zombie_powerups) ||\\n        !isDefined(level.zombie_powerups[\\\"nuke\\\"]) ||\\n        getTime() - self.shadow_last_nuke_shot < 1500)\\n        return;\\n\\n    self.shadow_last_nuke_shot = getTime();\\n    level thread maps\\\\_zombiemode_powerups::specific_powerup_drop(\\\"nuke\\\", self.origin);\\n}\\n\\nshadow_teleport_to_crosshair()\\n{\\n    start = self getEye();\\n    finish = start + (anglesToForward(self getPlayerAngles()) * 8000);\\n    trace = bulletTrace(start, finish, false, self);\\n\\n    if (!isDefined(trace) || !isDefined(trace[\\\"position\\\"]) ||\\n        (isDefined(trace[\\\"fraction\\\"]) && trace[\\\"fraction\\\"] >= 1))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7No safe crosshair surface found\\\");\\n        return;\\n    }\\n\\n    landin",
    "g = trace[\\\"position\\\"] + (0, 0, 42);\\n    if (isDefined(trace[\\\"normal\\\"]))\\n        landing += trace[\\\"normal\\\"] * 24;\\n    self shadow_warp(landing, \\\"crosshair impact\\\");\\n}\\n\\nshadow_unlock_all_doors(mode)\\n{\\n    self endon(\\\"disconnect\\\");\\n    if (self.shadow_busy_doors)\\n        return;\\n    self.shadow_busy_doors = true;\\n    if (!flag(\\\"begin_spawning\\\"))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Wait for map blockers to initialize\\\");\\n        self.shadow_busy_doors = false;\\n        return;\\n    }\\n\\n    previous_unlock = getDvarInt(\\\"zombie_unlock_all\\\");\\n    if (!isDefined(level.shadow_unlock_serial))\\n        level.shadow_unlock_serial = 0;\\n    level.shadow_unlock_serial++;\\n    level thread shadow_restore_unlock_failsafe(previous_unlock,\\n        level.shadow_unlock_serial);\\n    setDvar(\\\"zombie_unlock_all\\\", 1);\\n    count = 0;\\n    if (mode != 2)\\n    {\\n        count += self shadow_open_blockers(\\\"zombie_door\\\");\\n        count += self shadow_open_blockers(\\\"zombie_doors\\\");\\n    }\\n    if (mode != 1)\\n    {\\n        count += self shadow_open_blockers(\\\"z",
    "ombie_debris\\\");\\n        count += self shadow_open_blockers(\\\"zombie_airlock_buy\\\");\\n        count += self shadow_open_blockers(\\\"buyable_stairs\\\");\\n    }\\n    wait 0.15;\\n    setDvar(\\\"zombie_unlock_all\\\", previous_unlock);\\n    self.shadow_busy_doors = false;\\n    if (count == 0)\\n        self shadow_notice(\\\"^1SHADOW ^7No compatible unopened blockers found\\\");\\n    else\\n        self shadow_notice(\\\"^1SHADOW ^7Sent \\\" + count + \\\" forced opening requests\\\");\\n}\\n\\nshadow_open_blockers(name)\\n{\\n    blockers = getEntArray(name, \\\"targetname\\\");\\n    count = 0;\\n    for (i = 0; i < blockers.size && i < 96; i++)\\n    {\\n        blocker = blockers[i];\\n        if (!isDefined(blocker))\\n            continue;\\n        if (isDefined(blocker._door_open) && blocker._door_open)\\n            continue;\\n        blocker notify(\\\"trigger\\\", self, true);\\n        count++;\\n        wait 0.025;\\n    }\\n    return count;\\n}\\n\\nshadow_restore_unlock_failsafe(previous, serial)\\n{\\n    wait 18;\\n    if (level.shadow_unlock_serial == serial &&\\n        getDvarInt(\\\"zombie_unlock_all\\\") == 1 && previ",
    "ous != 1)\\n        setDvar(\\\"zombie_unlock_all\\\", previous);\\n}\\n\\nshadow_turn_power_on()\\n{\\n    self endon(\\\"disconnect\\\");\\n    if (flag(\\\"power_on\\\"))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Power is already on\\\");\\n        return;\\n    }\\n    if (!flag(\\\"begin_spawning\\\"))\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7Wait for map power to initialize\\\");\\n        return;\\n    }\\n    switches = getEntArray(\\\"use_power_switch\\\", \\\"targetname\\\");\\n    if (switches.size == 0)\\n        switches = getEntArray(\\\"use_elec_switch\\\", \\\"targetname\\\");\\n    if (switches.size == 0)\\n    {\\n        self shadow_notice(\\\"^1SHADOW ^7No scripted power switch on this map\\\");\\n        return;\\n    }\\n\\n    switches[0] notify(\\\"trigger\\\", self);\\n    wait 0.90;\\n    if (flag(\\\"power_on\\\"))\\n        self shadow_notice(\\\"^1SHADOW ^7Map power is now ON\\\");\\n    else\\n        self shadow_notice(\\\"^1SHADOW ^7Map rejected power request\\\");\\n}\\n\\nshadow_center_text(value, x, y, scale, rgb, sort)\\n{\\n    elem = newClientHudElem(self);\\n    elem.horzAlign = \\\"center\\\";\\n    elem.vertAlign = \\\"top\\\"",
    ";\\n    elem.alignX = \\\"left\\\";\\n    elem.alignY = \\\"top\\\";\\n    elem.x = x;\\n    elem.y = y;\\n    elem.font = \\\"default\\\";\\n    if (scale < 1.0)\\n        scale = 1.05;\\n    elem.fontScale = scale;\\n    elem setText(value);\\n    elem.color = rgb;\\n    elem.alpha = 1;\\n    elem.sort = sort;\\n    elem.hideWhenInMenu = false;\\n    return elem;\\n}\\n\\nshadow_center_bar(x, y, width, height, rgb, alpha, sort)\\n{\\n    elem = newClientHudElem(self);\\n    elem.horzAlign = \\\"center\\\";\\n    elem.vertAlign = \\\"top\\\";\\n    elem.alignX = \\\"center\\\";\\n    elem.alignY = \\\"top\\\";\\n    elem.x = x;\\n    elem.y = y;\\n    elem.sort = sort;\\n    elem.color = rgb;\\n    elem.alpha = alpha;\\n    elem setShader(\\\"white\\\", width, height);\\n    elem.hideWhenInMenu = false;\\n    return elem;\\n}\\n\\nshadow_fx_cooldown()\\n{\\n    if (self.shadow_low_effects)\\n        return 900;\\n    return 300;\\n}\\n\\nshadow_notice(value)\\n{\\n    if (!isDefined(self.shadow_notice_bg))\\n    {\\n        self.shadow_notice_bg = newClientHudElem(self);\\n        self.shadow_notice_bg.horzAlign = \\\"left\\\";\\n        self.shadow_notice_bg.vert",
    "Align = \\\"bottom\\\";\\n        self.shadow_notice_bg.alignX = \\\"left\\\";\\n        self.shadow_notice_bg.alignY = \\\"bottom\\\";\\n        self.shadow_notice_bg.x = 20;\\n        self.shadow_notice_bg.y = -128;\\n        self.shadow_notice_bg.color = self shadow_accent();\\n        self.shadow_notice_bg.sort = 25;\\n        self.shadow_notice_bg setShader(\\\"white\\\", 120, 2);\\n        self.shadow_notice_bg.hideWhenInMenu = false;\\n\\n        self.shadow_notice_text = newClientHudElem(self);\\n        self.shadow_notice_text.horzAlign = \\\"left\\\";\\n        self.shadow_notice_text.vertAlign = \\\"bottom\\\";\\n        self.shadow_notice_text.alignX = \\\"left\\\";\\n        self.shadow_notice_text.alignY = \\\"bottom\\\";\\n        self.shadow_notice_text.x = 20;\\n        self.shadow_notice_text.y = -144;\\n        self.shadow_notice_text.font = \\\"default\\\";\\n        self.shadow_notice_text.fontScale = 0.96;\\n        self.shadow_notice_text.color = (1, 1, 1);\\n        self.shadow_notice_text.sort = 26;\\n        self.shadow_notice_text.hideWhenInMenu = false;\\n    }\\n\\n    self.shadow_notice_bg.alpha = 1;\\n    self.sh",
    "adow_notice_text.alpha = 1;\\n    self.shadow_notice_bg.color = self shadow_accent();\\n    self.shadow_notice_text setText(value);\\n    self.shadow_notice_expires = getTime() + 5500;\\n}\\n\",\"user\":\"// Shadow Garden custom script entry point.\\n\\nmain()\\n{\\n}\\n\"}"
  ].join(''));
  const PATHS = Object.freeze({
    hooks: 'mods/shadow/maps/shadow/_hooks.gsc',
    menu: 'mods/shadow/maps/mod_shadow/_shadow_menu.gsc',
    user: 'mods/shadow/maps/shadow/_user.gsc'
  });
  const SLUGS = ['five', 'kino', 'riese', 'nacht', 'verruckt', 'shinonuma',
    'ascension', 'cotd', 'shangrila', 'moon'];
  const match = location.pathname.match(/^\/(?:bsz|bo1z)\/([a-z]+)(?:\.html)?\/?$/i);
  const current = match && SLUGS.includes(match[1].toLowerCase()) ? match[1].toLowerCase() : null;
  const isMapIndex = /^\/(?:bsz|bo1z)\/?$/i.test(location.pathname);
  const BUILTIN_ENTRY = '    self thread maps\\mod_shadow\\_shadow_menu::shadow_player_init();';
  const CUSTOM_ENTRY = '    self thread maps\\shadow\\_user::main();';
  const installed = new Set();
  const inflight = new Map();
  const modeWrites = new Map();
  let active = true;
  let stateObserved = null;
  let packHookInstalled = false;
  let previousWorkerPost = null;
  let wrappedWorkerPost = null;
  let panel = null;
  let message = null;
  let statusDot = null;
  let statsHud = null;
  let statsTimer = null;
  let welcomeHud = null;
  let welcomeTimer = null;

  if (window.Shadow?.__direct) {
    window.Shadow.open();
    return;
  }
  if (window.Shadow || window.ShadowGSC) {
    console.error('[SHADOW] Legacy Shadow detected. Reload this map page before pasting the direct injector.');
    return;
  }
  if (!current && !isMapIndex) {
    console.error('[SHADOW] Open https://vel.gg/bsz or a supported map page before pasting the loader.');
    return;
  }
  if (!window.isSecureContext || typeof navigator.storage?.getDirectory !== 'function') {
    console.error('[SHADOW] OPFS is unavailable. Use a secure tab with site storage enabled (Firefox 111+, Chrome, or Edge).');
    return;
  }

  function say(value, error = false) {
    if (error) console.error('[SHADOW]', value);
    if (message) {
      message.textContent = value;
      message.style.color = error ? '#ffadad' : '#e7e7eb';
    }
    if (statusDot) statusDot.style.background = error ? '#ef2929' : '#d91313';
  }

  async function fileAt(parent, path, create) {
    const bits = path.split('/');
    let dir = parent;
    for (const part of bits.slice(0, -1))
      dir = await dir.getDirectoryHandle(part, { create });
    return dir.getFileHandle(bits[bits.length - 1], { create });
  }

  async function readAt(parent, path) {
    try {
      const handle = await fileAt(parent, path, false);
      return await (await handle.getFile()).text();
    } catch (error) {
      if (error.name === 'NotFoundError') return null;
      throw error;
    }
  }

  function isPreviousShadowFile(path, original) {
    if (path === PATHS.hooks)
      return /^\s*\/\/ (?:SHADOW - per-map modstack entrypoint|Shadow Garden hooks)/.test(original);
    if (path === PATHS.menu)
      return /^\s*\/\*\s*(?:\n\s*\* SHADOW(?: Lite - Black Ops 1 \(T5\) Zombies in-game menu,| - BO1 Zombies menu v| GARDEN GSC - BO1 Zombies v)|SHADOW GARDEN GSC - BO1 Zombies v)/.test(original);
    return false;
  }

  async function writeAt(parent, path, source, overwrite = false) {
    const original = await readAt(parent, path);
    if (original === source) return 'identical';
    if (original !== null && !overwrite && !isPreviousShadowFile(path, original))
      throw new Error('Refusing to overwrite non-SHADOW file: ' + path);
    if (original !== null && overwrite) {
      const backup = await fileAt(parent, '.shadow-backup/' + path, true);
      const sink = await backup.createWritable();
      await sink.write(original);
      await sink.close();
    }
    const handle = await fileAt(parent, path, true);
    const sink = await handle.createWritable();
    await sink.write(source);
    await sink.close();
    if (await (await handle.getFile()).text() !== source)
      throw new Error('OPFS readback did not match: ' + path);
    return original === null ? 'created' : 'updated';
  }

  function mapFolder(slug) {
    return slug === 'five' ? 'pack' : 'pack-' + slug;
  }

  async function filesFor(slug) {
    if (!SLUGS.includes(slug)) throw new Error('Unknown BO1Z map: ' + slug);
    const root = await navigator.storage.getDirectory();
    const pack = await root.getDirectoryHandle(mapFolder(slug), { create: true });
    return pack.getDirectoryHandle('files', { create: true });
  }

  function isEmptyUser(source) {
    return source === null ||
      /^\s*(?:\/\/ Shadow Garden custom script entry point\.\s*)?main\s*\(\s*\)\s*\{\s*\}\s*$/.test(source);
  }

  function hooksFor(mode) {
    const entries = [
      mode.builtIn ? BUILTIN_ENTRY : '',
      mode.custom ? CUSTOM_ENTRY : ''
    ].filter(Boolean).join('\n');
    return SOURCES.hooks
      .replace('// Shadow Garden hooks', '// Shadow Garden hooks | builtIn=' +
        Number(mode.builtIn) + ' custom=' + Number(mode.custom))
      .replace(BUILTIN_ENTRY, entries);
  }

  async function modesFor(files) {
    const hooks = await readAt(files, PATHS.hooks);
    const flags = hooks?.match(/^\/\/ Shadow Garden hooks \| builtIn=([01]) custom=([01])/);
    if (flags)
      return { builtIn: flags[1] === '1', custom: flags[2] === '1' };
    const user = await readAt(files, PATHS.user);
    if (hooks?.includes(BUILTIN_ENTRY) && hooks.includes(CUSTOM_ENTRY) && !isEmptyUser(user))
      return { builtIn: false, custom: true };
    return { builtIn: true, custom: false };
  }

  async function getModes(slug = current) {
    const files = await filesFor(slug);
    return modesFor(files);
  }

  function setModes(change, slug = current) {
    if (!SLUGS.includes(slug)) return Promise.reject(new Error('Choose a map first'));
    const pending = modeWrites.get(slug) || Promise.resolve();
    const task = pending.catch(() => {}).then(async () => {
      await install(slug);
      const files = await filesFor(slug);
      const previous = await modesFor(files);
      const mode = {
        builtIn: change.builtIn === undefined ? previous.builtIn : Boolean(change.builtIn),
        custom: change.custom === undefined ? previous.custom : Boolean(change.custom)
      };
      if (mode.custom && isEmptyUser(await readAt(files, PATHS.user)))
        throw new Error('Load a custom GSC before enabling Custom GSC.');
      await writeAt(files, PATHS.hooks, hooksFor(mode));
      await updateModeControls();
      say('GSC selection saved for ' + slug + '. Start a new game to apply.');
      return mode;
    });
    modeWrites.set(slug, task);
    task.finally(() => {
      if (modeWrites.get(slug) === task) modeWrites.delete(slug);
    }).catch(() => {});
    return task;
  }

  function install(slug = current) {
    if (!SLUGS.includes(slug)) return Promise.reject(new Error('Unknown BO1Z map: ' + slug));
    if (inflight.has(slug)) return inflight.get(slug);
    const operation = (async () => {
      say('Installing on ' + slug + '…');
      const files = await filesFor(slug);
      const mode = await modesFor(files);
      await writeAt(files, PATHS.hooks, hooksFor(mode));
      await writeAt(files, PATHS.menu, SOURCES.menu);
      if (await readAt(files, PATHS.user) === null)
        await writeAt(files, PATHS.user, SOURCES.user);
      installed.add(slug);
      say('Ready to play');
      return true;
    })();
    inflight.set(slug, operation);
    operation.finally(() => { if (inflight.get(slug) === operation) inflight.delete(slug); }).catch(() => {});
    return operation;
  }

  async function installAll() {
    for (const slug of SLUGS) await install(slug);
    say('Ready on all 10 maps');
    return [...installed];
  }

  async function loadGSC(file, slug = current) {
    if (!file || typeof file.text !== 'function') throw new TypeError('Choose a .gsc File');
    if (!/\.gsc$/i.test(file.name || '') || file.size > 256 * 1024)
      throw new Error('Choose a UTF-8 .gsc file smaller than 256 KiB');
    const source = await file.text();
    if (!/\bmain\s*\(\s*\)/.test(source))
      throw new Error('Your custom GSC needs a main() function.');
    await install(slug);
    const files = await filesFor(slug);
    const wrapped = '// SHADOW custom GSC (user supplied)\n' + source;
    await writeAt(files, PATHS.user, wrapped, true);
    await setModes({ builtIn: false, custom: true }, slug);
    say('Custom GSC selected. Built-in menu disabled. Start a new game.');
    return true;
  }

  function modArgs(settings) {
    if (!active) return settings;
    const mods = Array.isArray(settings?.mods) ? settings.mods.filter(x => typeof x === 'string') : [];
    if (mods.includes('cstest')) {
      say('Select classic guns to use SHADOW.', true);
      return settings;
    }
    if (mods.includes('horde')) {
      say('Use normal solo mode for SHADOW.', true);
      return settings;
    }
    return { ...settings, mods: [...new Set([...mods, 'shadow'])] };
  }

  function hookPackSelection() {
    if (typeof Worker === 'undefined' || typeof Worker.prototype?.postMessage !== 'function')
      throw new Error('Worker API not available; SHADOW cannot add the mod stack to downloaded packs');
    const originalPost = Worker.prototype.postMessage;
    previousWorkerPost = originalPost;
    wrappedWorkerPost = function(message, ...rest) {
      if (active && message && (message.type === 'inspect' || message.type === 'download') &&
          Object.prototype.hasOwnProperty.call(message, 'mods') && message.mods !== undefined) {
        const mods = Array.isArray(message.mods) ? message.mods : [];
        if (!mods.includes('cstest') && !mods.includes('horde')) {
          message = { ...message, mods: [...new Set([...mods, 'shadow'])] };
        }
      }
      return originalPost.call(this, message, ...rest);
    };
    Worker.prototype.postMessage = wrappedWorkerPost;
    packHookInstalled = true;
  }

  function restoreWorkerHook() {
    if (packHookInstalled && typeof Worker !== 'undefined' &&
        Worker.prototype.postMessage === wrappedWorkerPost)
      Worker.prototype.postMessage = previousWorkerPost;
    packHookInstalled = false;
    wrappedWorkerPost = null;
    previousWorkerPost = null;
  }

  function wrapEngine(engine) {
    if (!engine || typeof engine.load !== 'function' || engine.__shadowWrapped) return;
    const original = engine.load;
    engine.load = async function(settings) {
      if (!active) return original.call(this, settings);
      clearGameHud();
      await install(current);
      const configured = modArgs(settings);
      if (configured !== settings) {
        say('Starting game…');
        hidePanel();
      }
      try {
        return await original.call(this, configured);
      } catch (error) {
        showPanel();
        say('Could not start the game. Check the console.', true);
        throw error;
      }
    };
    if (typeof engine.play === 'function') {
      const originalPlay = engine.play;
      engine.play = async function(...args) {
        const result = await originalPlay.apply(this, args);
        if (active) {
          startStatsHud(this);
          showLobbyWelcome();
        }
        return result;
      };
    }
    Object.defineProperty(engine, '__shadowWrapped', { value: true });
  }

  function watchState(state) {
    if (!active || !state || typeof state !== 'object' || state === stateObserved) return;
    stateObserved = state;
    const prior = Object.getOwnPropertyDescriptor(state, 'engine');
    if (prior && !prior.configurable) {
      wrapEngine(state.engine);
      return;
    }
    let engine = state.engine;
    Object.defineProperty(state, 'engine', {
      configurable: true, enumerable: true,
      get() { return engine; },
      set(value) { engine = value; wrapEngine(value); }
    });
    wrapEngine(engine);
  }

  function hookLaunch() {
    const descriptor = Object.getOwnPropertyDescriptor(window, 'five');
    if (descriptor && !descriptor.configurable) {
      watchState(window.five);
      if (!window.five) throw new Error('Cannot watch game startup: window.five is locked');
      return;
    }
    let five = window.five;
    Object.defineProperty(window, 'five', {
      configurable: true, enumerable: true,
      get() { return five; },
      set(value) { five = value; watchState(value); }
    });
    watchState(five);
  }

  let themeAdded = false;
  const MAP_NAMES = Object.freeze({
    kino: 'Kino der Toten', five: 'Five', riese: 'Der Riese',
    nacht: 'Nacht der Untoten', verruckt: 'Verrückt',
    shinonuma: 'Shi No Numa', ascension: 'Ascension',
    cotd: 'Call of the Dead', shangrila: 'Shangri-La', moon: 'Moon'
  });

  function getPlayerName() {
    const args = window.five?.arguments;
    let name = '';
    if (Array.isArray(args)) {
      const index = args.lastIndexOf('name');
      if (index >= 0 && typeof args[index + 1] === 'string')
        name = args[index + 1];
    }
    if (!name) {
      const state = window.five;
      name = state?.settings?.playerName || state?.profile?.displayName ||
        state?.player?.name || '';
    }
    return typeof name === 'string' && name.trim() ? name.trim().slice(0, 32) : 'Player';
  }

  function showLobbyWelcome() {
    clearTimeout(welcomeTimer);
    welcomeHud?.remove();
    if (!document.body) return;
    welcomeHud = node('div', '', `Welcome to ${getPlayerName()}'s Modded Lobby`);
    welcomeHud.id = 'shadow-welcome-hud';
    welcomeHud.style.cssText = `position:fixed;top:14%;left:50%;transform:translateX(-50%);
      z-index:2147483000;background:#100e16e0;border:1px solid #873333;
      border-radius:5px;box-shadow:0 5px 24px #0009;padding:7px 14px;
      color:#f8eded;font:600 12px/1.45 'Segoe UI',sans-serif;
      text-align:center;pointer-events:none;max-width:calc(100vw - 30px);`;
    welcomeHud.append(node('div', '', 'SHADOW GARDEN  /  BY JOSHUA'));
    document.body.append(welcomeHud);
    welcomeTimer = setTimeout(() => {
      welcomeHud?.remove();
      welcomeHud = null;
      welcomeTimer = null;
    }, 5500);
  }

  function startStatsHud(engine) {
    if (!document.body) return;
    clearInterval(statsTimer);
    statsHud?.remove();
    statsHud = node('div', '', '');
    statsHud.id = 'shadow-stats-hud';
    statsHud.style.cssText = `position:fixed;top:12px;left:12px;z-index:2147483000;
      min-width:132px;max-width:min(240px, calc(100vw - 24px));padding:7px 10px;background:#111016e8;
      border:1px solid #352323;border-left:2px solid #e62b2b;
      border-radius:5px;box-shadow:0 5px 20px #0008;isolation:isolate;color:#e9e2e2;
      font:500 10.5px/1.5 'Segoe UI',sans-serif;
      pointer-events:none;white-space:pre;overflow:hidden;`;
    document.body.append(statsHud);
    let frameReader = null;
    try {
      if (typeof engine.presentReader === 'function')
        frameReader = engine.presentReader();
    } catch (_) { frameReader = null; }
    const update = () => {
      let fps = '--';
      try {
        const frames = typeof frameReader === 'function' ? frameReader() : null;
        if (Array.isArray(frames?.intervals)) {
          let sum = 0;
          let count = 0;
          for (const n of frames.intervals) {
            if (Number.isFinite(n) && n > 0) { sum += n; count++; }
          }
          if (count && sum > 0) fps = String(Math.round(1000 * count / sum));
        }
      } catch (_) { /* FPS may be unavailable while frames initialize. */ }
      const playerName = getPlayerName();
      statsHud.textContent = `MAP   ${MAP_NAMES[current] || current}\nHOST  ${playerName} (solo)\nPING  Local\nFPS    ${fps}`;
    };
    update();
    statsTimer = setInterval(update, 1000);
  }

  function clearGameHud() {
    clearInterval(statsTimer);
    clearTimeout(welcomeTimer);
    statsTimer = null;
    welcomeTimer = null;
    statsHud?.remove();
    welcomeHud?.remove();
    statsHud = null;
    welcomeHud = null;
  }

  async function changeMap(slug) {
    if (!SLUGS.includes(slug)) throw new Error('Choose a supported map');
    if (isMapIndex) {
      location.assign('/' + (location.pathname.toLowerCase().startsWith('/bo1z') ? 'bo1z' : 'bsz') + '/' + slug);
      return;
    }
    if (slug === current) {
      say('You are already on ' + MAP_NAMES[slug]);
      return;
    }
    if (!window.confirm('Leave this game and load ' + MAP_NAMES[slug] + '? Current round progress will be lost.'))
      return;
    await install(slug);
    const rootPath = location.pathname.match(/^\/(bsz|bo1z)\//i)?.[1] || 'bsz';
    location.assign(`/${rootPath}/${slug}`);
  }

  function onShortcut(event) {
    if (!active || !event.shiftKey || event.key?.toLowerCase() !== 'm' ||
        event.repeat || /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement?.tagName || ''))
      return;
    event.preventDefault();
    if (document.pointerLockElement) {
      try { document.exitPointerLock(); } catch (_) { /* The browser owns pointer lock. */ }
    }
    if (panel) hidePanel(); else showPanel();
  }

  function node(tag, className, content) {
    const el = document.createElement(tag);
    if (className) el.className = className;
    if (content !== undefined) el.textContent = content;
    return el;
  }

  function addButton(row, label, fn, kind = 'plain') {
    const button = node('button', 'sh-button ' + kind, label);
    button.type = 'button';
    button.addEventListener('click', () => Promise.resolve().then(fn).catch(e => say(e.message, true)));
    row.append(button);
    return button;
  }

  async function updateModeControls() {
    if (!panel || !current) return;
    const mode = await getModes();
    for (const key of ['builtIn', 'custom']) {
      const input = panel.querySelector('input[data-shadow-mode="' + key + '"]');
      if (input) input.checked = mode[key];
    }
  }

  function addModeToggle(row, title, key) {
    const label = node('label', 'sh-toggle');
    label.append(node('span', '', title));
    const input = node('input');
    input.type = 'checkbox';
    input.dataset.shadowMode = key;
    input.setAttribute('aria-label', title);
    input.addEventListener('change', async () => {
      input.disabled = true;
      try {
        await setModes({ [key]: input.checked });
      } catch (error) {
        say(error.message, true);
        await updateModeControls();
      } finally {
        input.disabled = false;
      }
    });
    label.append(input);
    row.append(label);
  }

  function hidePanel() {
    panel?.remove();
    panel = null;
    message = null;
    statusDot = null;
  }

  function showPanel() {
    if (!active || !document.body || panel) return;
    if (!themeAdded) {
      const css = node('style', '', `
        #shadow-direct, #shadow-direct * { box-sizing: border-box; }
        #shadow-direct { position: fixed; z-index: 2147483647; right: 18px; bottom: 18px;
          width: min(306px, calc(100vw - 24px)); color: #f4f1f2; pointer-events: auto;
          font: 13px/1.42 -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          background: #111115; border: 1px solid #352424; border-radius: 12px;
          box-shadow: 0 14px 60px #000c, 0 0 0 1px #16080c inset; overflow: hidden; }
        #shadow-direct button { font: inherit; transition: background .14s, border-color .14s; }
        #shadow-direct button:focus-visible { outline: 2px solid #ff3838; outline-offset: 2px; }
        #shadow-direct .sh-accent { height: 3px; background: linear-gradient(90deg, #b91414, #ee2929 55%, #401010); }
        #shadow-direct .sh-main { padding: 14px 15px 13px; }
        #shadow-direct .sh-head { display: flex; align-items: center; gap: 10px; position: relative; }
        #shadow-direct .sh-mark { width: 35px; height: 35px; flex: none; display: grid; place-items: center;
          border: 1px solid #bd2222; border-radius: 8px; color: #fff; background: linear-gradient(145deg,#b11b1b,#471010);
          font-size: 20px; font-weight: 800; letter-spacing: -.07em; }
        #shadow-direct .sh-brand { font-weight: 850; font-size: 17px; letter-spacing: .14em; line-height: 1.05; }
        #shadow-direct .sh-small { font-size: 10px; letter-spacing: .14em; color: #8f898f; margin-top: 4px; }
        #shadow-direct .sh-close { position: absolute; right: -5px; top: -5px; border: 0; border-radius: 6px;
          width: 26px; height: 26px; background: transparent; color: #a8a2a7; cursor: pointer;
          font-size: 22px; line-height: 1; }
        #shadow-direct .sh-close:hover { color: white; background: #372222; }
        #shadow-direct .sh-status { margin: 13px 0 11px; padding: 10px; border: 1px solid #302424;
          background: #1c191e; border-radius: 8px; }
        #shadow-direct .sh-status-top { display: flex; align-items: center; gap: 8px; font-size: 11px;
          font-weight: 700; letter-spacing: .045em; }
        #shadow-direct .sh-dot { display: inline-block; flex: none; width: 7px; height: 7px;
          background: #d91313; border-radius: 50%; box-shadow: 0 0 0 3px #5c1212; }
        #shadow-direct .sh-map { margin-left: auto; font-weight: 600; color: #a9a1a8; font-size: 10px;
          max-width: 135px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        #shadow-direct .sh-message { margin-top: 8px; color: #e7e7eb; font-size: 12px; }
        #shadow-direct .sh-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
        #shadow-direct .sh-button { cursor: pointer; min-height: 37px; padding: 8px 7px; border-radius: 7px;
          font-size: 11.5px; font-weight: 650; white-space: nowrap; }
        #shadow-direct .sh-button.primary { color: #fff; background: #bc1616; border: 1px solid #df2c2c; }
        #shadow-direct .sh-button.primary:hover { background: #d32121; }
        #shadow-direct .sh-button.plain { color: #ebe4e7; background: #242027; border: 1px solid #423030; }
        #shadow-direct .sh-button.plain:hover { background: #352727; border-color: #754343; }
        #shadow-direct .sh-bottom { display: flex; align-items: center; justify-content: space-between;
          border-top: 1px solid #302424; margin-top: 14px; padding-top: 12px; gap: 8px; }
        #shadow-direct .sh-link { background: none; padding: 0; border: 0; color: #b5a7a7;
          font-size: 11px; font-weight: 600; cursor: pointer; }
        #shadow-direct .sh-link:hover { color: #fff; }
        #shadow-direct .sh-help { font-size: 10.5px; margin-top: 11px; color: #9e949b; white-space: pre-line; }
        #shadow-direct .sh-map-picker { display: grid; grid-template-columns: 1fr auto; gap: 8px;
          margin-top: 10px; }
        #shadow-direct .sh-map-picker select { min-width: 0; width: 100%; color: #f4f1f2;
          background: #242027; border: 1px solid #423030; border-radius: 7px;
          padding: 8px; font: inherit; }
        #shadow-direct .sh-modes { display: grid; gap: 7px; margin-top: 11px; }
        #shadow-direct .sh-toggle { display: flex; align-items: center; justify-content: space-between;
          padding: 8px 10px; min-height: 35px; border: 1px solid #392a2a;
          border-radius: 7px; background: #211c21; font-size: 11.5px; font-weight: 650; }
        #shadow-direct .sh-toggle input { appearance: none; width: 30px; height: 17px; margin: 0;
          background: #832828; border: 1px solid #bf4747; border-radius: 20px;
          cursor: pointer; position: relative; }
        #shadow-direct .sh-toggle input:checked { background: #267e4a; border-color: #3fb772; }
        #shadow-direct .sh-toggle input::after { content: ''; position: absolute; top: 2px; left: 2px;
          width: 11px; height: 11px; border-radius: 50%; background: #fff; }
        #shadow-direct .sh-toggle input:checked::after { left: 15px; }
        #shadow-direct .sh-toggle input:disabled { opacity: .55; cursor: wait; }
      `);
      css.id = 'shadow-direct-style';
      (document.head || document.body).append(css);
      themeAdded = true;
    }

    panel = node('section');
    panel.id = 'shadow-direct';
    panel.setAttribute('aria-label', 'Shadow Garden GSC injector');
    panel.append(node('div', 'sh-accent'));
    const main = node('div', 'sh-main');
    const head = node('div', 'sh-head');
    head.append(node('div', 'sh-mark', 'S'));
    const brand = node('div');
    brand.append(node('div', 'sh-brand', 'SHADOW GARDEN'));
    brand.append(node('div', 'sh-small', 'BLACK OPS ZOMBIES / BY JOSHUA'));
    head.append(brand);
    const dismiss = node('button', 'sh-close', '×');
    dismiss.type = 'button';
    dismiss.title = 'Close SHADOW injector panel';
    dismiss.setAttribute('aria-label', 'Close SHADOW injector panel');
    dismiss.addEventListener('click', () => window.Shadow.close());
    head.append(dismiss);
    main.append(head);

    const status = node('div', 'sh-status');
    const statusTop = node('div', 'sh-status-top');
    statusDot = node('span', 'sh-dot');
    statusTop.append(statusDot);
    statusTop.append(node('span', '', 'STATUS'));
    statusTop.append(node('span', 'sh-map', isMapIndex ? 'MAP SELECTION' : (MAP_NAMES[current] || current)));
    status.append(statusTop);
    message = node('div', 'sh-message', isMapIndex ? 'Select a map below to continue.' :
      (installed.has(current) ? 'Ready to play' : 'Preparing…'));
    status.append(message);
    main.append(status);

    if (!isMapIndex) {
      const actions = node('div', 'sh-actions');
      addButton(actions, 'Enable This Map', () => install(), 'primary');
      addButton(actions, 'Enable All Maps', installAll);
      main.append(actions);
    }

    const picker = node('div', 'sh-map-picker');
    const mapSelect = node('select');
    mapSelect.setAttribute('aria-label', 'Destination map');
    for (const slug of SLUGS) {
      const option = node('option', '', MAP_NAMES[slug]);
      option.value = slug;
      option.selected = slug === current;
      mapSelect.append(option);
    }
    picker.append(mapSelect);
    addButton(picker, isMapIndex ? 'Open Map' : 'Change Map', () => changeMap(mapSelect.value), 'primary');
    main.append(picker);

    if (isMapIndex) {
      main.append(node('div', 'sh-help',
        '1. Pick a map and select Open Map.\n2. On the map setup screen, paste the loader again.\n3. Choose your GSC and wait for Ready to play, then press Play.'));
      panel.append(main);
      document.body.append(panel);
      return;
    }

    const modes = node('div', 'sh-modes');
    addModeToggle(modes, 'Built-in Menu', 'builtIn');
    addModeToggle(modes, 'Custom GSC', 'custom');
    main.append(modes);

    const fileInput = node('input');
    fileInput.type = 'file';
    fileInput.accept = '.gsc';
    fileInput.style.display = 'none';
    fileInput.addEventListener('change', () => {
      if (fileInput.files?.[0]) loadGSC(fileInput.files[0]).catch(e => say(e.message, true));
      fileInput.value = '';
    });
    main.append(fileInput);

    const bottom = node('div', 'sh-bottom');
    const custom = node('button', 'sh-link', 'Load Custom Script');
    custom.type = 'button';
    custom.addEventListener('click', () => fileInput.click());
    bottom.append(custom);
    const hide = node('button', 'sh-link', 'Hide panel');
    hide.type = 'button';
    hide.addEventListener('click', () => window.Shadow.close());
    bottom.append(hide);
    main.append(bottom);
    main.append(node('div', 'sh-help', 'Shift+M: Launcher   ·   Changes apply next game   ·   ADS+MELEE: Built-in Menu'));
    panel.append(main);
    document.body.append(panel);
    updateModeControls().catch(error => say(error.message, true));
  }

  const api = {
    __direct: true, version: VERSION, maps: () => [...SLUGS],
    install, installAll, changeMap, loadGSC, getModes, setModes,
    close: hidePanel,
    open: showPanel,
    disable() {
      if (!active) return;
      active = false;
      clearGameHud();
      hidePanel();
      restoreWorkerHook();
      window.removeEventListener('keydown', onShortcut);
      say('Launcher stopped. Restart the game to remove active mods.');
    }
  };
  window.Shadow = api;
  if (!isMapIndex) {
    try {
      hookPackSelection();
      hookLaunch();
    } catch (error) {
      active = false;
      restoreWorkerHook();
      delete window.Shadow;
      say(error.message, true);
      return;
    }
  }
  window.addEventListener('keydown', onShortcut);
  if (document.body) showPanel();
  else document.addEventListener('DOMContentLoaded', () => {
    if (active) showPanel();
  }, { once: true });
  api.ready = isMapIndex ? Promise.resolve() :
    install(current).catch(error => { say(error.message, true); throw error; });
  api.ready.catch(() => {});
  Object.freeze(api);
})();
