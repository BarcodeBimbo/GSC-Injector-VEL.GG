# Shadow Garden GSC Guide

Shadow Garden GSC is a standalone console loader and in-game menu for the browser version at [vel.gg/bsz](https://vel.gg/bsz). It does not need Tampermonkey, a proxy, or a replacement FastFile.

### Injection Preview
<div align="center">
  <video src="https://github.com/user-attachments/assets/233a0d5c-1548-4023-bf27-3e0f97888512.mp4"></video>
</div>

### In-Game Preview
<div align="center">
  <video src="https://github.com/user-attachments/assets/5ff04a93-c800-40c8-8c3a-8d69717062ef.mp4"></video>
</div>

## 1. Install SHADOW

1. Open a supported Zombies map at `https://vel.gg/bsz/<map>` in Chrome or Edge. Stay on the setup screen.
2. Open developer tools (**F12**) and click **Console**.
3. Open `Shadow_GSC_Loader.js` in a text editor. Copy **all** of the JavaScript and paste it into the Console. Run it once.
4. The small SHADOW panel appears. Wait until it reads **Ready to play**.
5. Choose classic weapons and normal solo mode, then click **PLAY**.
6. Once the game is running, **hold ADS and press MELEE / KNIFE** to open the in-game menu.

The browser panel hides itself when you start the map. If you close it early, type `Shadow.open()` in the developer console to show it again.

**Do not use "Import custom GSC" to select `_shadow_menu.gsc`.** The JavaScript loader already installs the complete built-in menu.

### Supported maps

Kino der Toten, Five, Der Riese, Nacht der Untoten, Verrückt, Shi No Numa, Ascension, Call of the Dead, Shangri-La, and Moon.

Click **All 10 maps** to stage the GSC in the known map namespaces. This stages storage paths; it does **not** download missing game maps or bypass missing map content. You still need to paste the loader on each *new map page* before pressing Play.

## 2. In-game controls

| Input | Action |
| --- | --- |
| Hold ADS + press Melee / Knife | Open SHADOW |
| **W / S** | Scroll up / down (hold to repeat) |
| **D** | Select the highlighted option |
| **A** | Back to the parent category |
| Melee / Knife while menu is open | Close from any page |
| Fire / ADS / Use | Down / Up / Select fallback (Classic bind preset) |
| **Mouse4** (default) | Native NoClip bind, active only if NoClip has been enabled in the GSC menu |
| **Shift + M** | Toggle the launcher panel, including Change Map |
| Controls / HUD | Navigation, NoClip key, single side scrollbar, accent colors, protection, and low-effects setting |

The **SHADOW GARDEN** menu uses the old dark panel, maroon header, thin accent stripe, and divider. A burgundy highlight fills the currently selected row. The eight text rows use the older working `default` font settings. A single slim scrollbar thumb moves inside the menu's right gutter; there are no extra text objects for the scrollbar. The centered welcome HUD shows **SHADOW GARDEN / BY JOSHUA** on lobby start. The top-left is reserved for map, solo host, local ping, FPS, player name, and the optional zombie counter. There are no opening/closing notices there.

While the menu is open, walking, looking, and weapon use are locked. W and S still work for navigation. Temporary protection keeps zombies away, and God Mode that you enabled yourself stays on after the menu closes. No decorative upper-right watermark is created.

### What's included

- **Player / Movement:** God Mode, No Target, NoClip ON/OFF and an in-menu Mouse4/Mouse5/F6/Off bind selector, speed boost, health, and reset. NoClip is OFF by default, and the loader does not inject any bind at startup. Death Machine remains in the weapons menu.
- **Weapons:** Ray Gun, AK74u, MP40, Galil, HK21, RPK, M1911, Thundergun, Wunderwaffe, Winter's Howl, Scavenger, Wave Gun, and 31-79 JGb215. Entries are shown only when registered by the loaded map.
- **Ammo / Custom FX:** refill current weapon, infinite reserve/magazine, drop weapon, cycle Normal / Explosive / Heavy / One-Hit / Burn impact damage, plus independently toggled Explosion / Tesla / Flame / Blood / Dust visual FX at traced shot impacts. **Nuke Rounds** is its own ON/OFF entry in Custom Weapon FX; after a qualifying Fire press, it creates a stock Nuke pickup at your position (capped to one every 1.5 seconds). No Nuke is triggered by a round timer.
- **Perks:** Juggernog, Speed Cola, Double Tap, Quick Revive, Stamin-Up, PhD Flopper, Deadshot Daiquiri, Mule Kick; show only perk-machine entries found in the loaded map; give one, give all available, or clear perks.
- **Zombies / Points:** clear live enemies, one-hit toggle, compact live counter, current round, points grants, capped queue of 1 / 5 / 10 stock-map zombies, and registered stock Power-Ups (Nuke, Max Ammo, Insta-Kill, Double Points, Carpenter, and Fire Sale where supported).
- **Aimbot:** Classic (moves your aim toward the nearest live zombie), Unfair (fires a scripted hit at a zombie on a new Fire press, independently of Classic), ADS-only/always-on settings for Classic, head/torso target selection shared by both.
- **Points:** add 1,000 / 5,000 / 10,000 / 50,000 / 100,000.
- **Teleport / World:** shoot at a solid surface to teleport there when Shoot to TP is enabled; crosshair teleport; saved location; three named in-session room bookmark slots; dynamically discovered starting room / power / Pack-a-Punch / perk-machine locations where the current map exposes those entities; unlock doors/debris and activate power on supported maps; Change Map shortcut to the launcher.
- **Five / Pack-a-Punch:** on `zombie_pentagon` only, trigger the four real DEFCON switches after power is enabled, report DEFCON state, and use exposed top-floor / War Room / labs / Panic Room portal destinations when initialized. DEFCON countdown and actual weapon upgrading still follow the map's normal mechanics.
- **Controls / HUD:** WASD or classic button navigation, inverted W/S, swapped A/D, repeat speed, native NoClip key selection in the GSC menu, five accent presets plus adjustable red/green/blue channels, selection highlight toggle, slim side scrollbar, low-effects mode, and protection.
- **Achievements:** five self-contained SHADOW session badges for reaching rounds 5/10, 10,000/100,000 points, and 100 kills (when kill data is available); unlock all or reset local badges. **Not** Steam/Activision/platform achievement unlocks.
- **Information:** map name, current weapon, position, round.
- **Close Shadow:** remove owned HUD elements and restore controls.

### Multiplayer status

This is a **solo-focused** build. Multiplayer player targeting and the Host/Co-Host/Admin/Mod/VIP/Guest rank system have been removed for now. No multiplayer role/status labels appear in the menu, including in single-player matches.

Weapon/perk/map-entity availability varies by map. **Infinite Reserve** replenishes reserve ammunition and **Infinite Clip** refills the magazine. Impact effects are rate-limited. Shoot-to-TP uses a ray trace, landing offset, and cooldown; save your position before experimenting. NoClip is off initially: turn it on inside the Player menu to request the selected native bind. Turning it off requests an unbind. The GSC uses `activeAction` for these requests; depending on the browser port, they may only apply at the next map load, and immediate execution has not been verified. Room bookmarks last **only for the current session**. DEFCON, power-up and map teleports have map/entity guards.

**Stability:** Bounded zombie/door operations, capped spawn queues, fixed HUD allocations, rate limits, and a HUD-state watchdog are included. The old 16 ms camera/origin forcing loops are removed. The game freezes and unfreezes controls only during menu transitions. Status polling runs once per second and the centered welcome message uses the browser overlay, not the in-game notification corner. GSC cannot recover from a JavaScript/WebAssembly out-of-memory failure or native VM crash.

**Change Map:** Press Shift+M, choose the destination in the browser launcher, then Change Map. This saves the mod files to that map's local storage namespace before leaving the current game. After navigation, paste the loader again on the new page before Play. Changing maps ends the current round. The in-game Change Map option opens a short instruction page, since GSC cannot navigate a browser tab itself.

**Devices / Mouse4:** Chrome or Edge on a desktop with OPFS is the intended target. Mobile, consoles, controller-only systems, and browsers without the underlying game features are not guaranteed to run. Physical Mouse4 is mapped by the browser game itself; the loader does not bind it. Enable NoClip inside the Player menu to request the native bind. If your browser consumes Mouse4 for navigation, choose Mouse5 or F6 inside the GSC menu, then restart the map if necessary for the DVAR to apply.

**Aimbot:** Classic and Unfair are independent toggles. Classic rotates the camera toward the nearest live zombie while ADS is held, or continuously if you enable Classic Aim: Always. Unfair does not change camera angles or require ADS: on each fresh Fire press it sends a scripted shot toward the nearest live zombie. Both modes pause while the menu is open and ignore empty zombie waves. Unfair depends on the browser port supporting `MagicBullet` for the equipped weapon, so test it on each map.

**Zombie Counter:** Toggle it in Zombie Controls. A compact colored `ZOMBIES` count appears in the top-left beneath the status readout. It refreshes twice per second and releases its HUD element when hidden.

## 3. Install your own GSC

You can run a second custom GSC script alongside the built-in SHADOW menu. This is useful for learning or prototyping new menus without editing the built-in file.

1. Open the `examples/shadow_custom_menu_example.gsc` file from this package.
2. Save a copy as `my_menu.gsc`. Use a plain-text editor (VS Code or Notepad++) and **UTF-8** encoding.
3. On the game setup screen, paste `Shadow_Console_v0.8.8.js` into DevTools.
4. In the SHADOW panel, click **Import custom GSC** and select `my_menu.gsc`.
5. Wait until the panel confirms that the custom script was added.
6. Click **PLAY** to start a **new game session**. Existing in-game sessions do not hot-reload scripts.
7. With the included example, **ADS + USE** opens the separate custom menu. Fire moves down, Use selects, Melee closes.

The custom file **must have `main()` with no parameters**, and it must be under 256 KB. The loader calls `main()` on your player after the player hook runs. `self` means your in-game player.

If you import another custom GSC, the previous custom file is backed up before it is replaced. The built-in SHADOW menu remains installed.

## 4. Custom GSC menu tutorial

The included example has three choices: **Heal Player**, **Add 1,000 Points**, and **Close**. Open it and follow these steps.

### Step A: Entry point

```gsc
main()
{
    self endon("disconnect");
    self.custom_open = false;
    self.custom_cursor = 0;
    self thread custom_input();
}
```

The loader calls `main()`. It creates one input-handling thread for this player. `endon("disconnect")` prevents the thread from continuing after the player leaves.

### Step B: Open with a button combination

In `custom_input()`, the example checks:

```gsc
if (!self.custom_open)
{
    if (ads && use && (!old_ads || !old_use))
        self custom_show();
}
```

This is **edge detection**: keeping the buttons held doesn't keep reopening the menu. The included SHADOW menu uses ADS + Melee, so the example uses ADS + Use to reduce hotkey conflicts.

### Step C: Draw the HUD

Use direct HUD fields with a font scale of at least 1.0. Scales below 1.0 render at the browser game's enormous fallback size:

```gsc
hud = newClientHudElem(self);
hud.horzAlign = "center";
hud.vertAlign = "top";
hud.alignX = "left";
hud.alignY = "top";
hud.x = -110;
hud.y = 117;
hud.font = "default";
hud.fontScale = 1.08;
hud.color = (1, 0.2, 0.3);
hud setText("My First Option");
```

The included menu uses `newClientHudElem` directly and does not require `maps\_hud_util`. Do not lower its font scale below 1.0 when adding options.

Colors use normalized RGB values from 0 to 1. For example:

- Red: `(1, 0.1, 0.2)`
- White: `(1, 1, 1)`
- Dark gray: `(0.1, 0.1, 0.1)`

The included example deliberately has no background shader.

### Step D: Add or change an action

In `custom_select()`, one option restores health:

```gsc
if (self.custom_cursor == 0)
{
    if (isDefined(self.maxhealth))
        self.health = self.maxhealth;
    else
        self.health = 100;
}
```

Another option adds points:

```gsc
self maps\_zombiemode_score::add_to_player_score(1000);
```

You can add a new label to the `custom_rows` array in `custom_show()`, increase the cursor's maximum in `custom_input()`, and add its corresponding case in `custom_select()`.

For example, to create a fourth option, add another `self.custom_rows[3]`, change `self.custom_cursor > 2` to `> 3`, and change the row loops from 3 to 4. Move the footer down so the new row fits.

### Step E: Close the HUD

To close, mark the menu closed and `destroy()` each HUD element that was created. Also reset its references:

```gsc
self.custom_open = false;
self.custom_rows[0] destroy();
self.custom_rows = [];
```

Do not create new HUD elements during every frame or every cursor movement. Create once when the menu opens, update the existing element colors/positions during navigation, and destroy the elements on close.

### Step F: Test your changes

1. Test opening and closing several times.
2. Add one option, then test again.
3. Check that the option behaves as expected on Kino.
4. Test on another map; weapon names and map APIs can differ.
5. If it crashes, restore the last working .gsc and inspect the console stack trace.

## 5. Reference: functions used here

| GSC call | Purpose |
| --- | --- |
| `self iPrintLn("Text")` | Action confirmation on the player's screen |
| `self getCurrentWeapon()` | Find equipped weapon |
| `self giveWeapon("ray_gun_zm")` | Give a weapon if that map has it |
| `self giveMaxAmmo(name)` | Refill reserve ammo |
| `self setWeaponAmmoClip(name, amount)` | Top up the active magazine |
| `self maps\_zombiemode_perks::give_perk(id, false)` | Apply a map-supported perk through the Zombies system |
| `getEntArray("zombie_door", "targetname")` | Identify map door entities |
| `self getNormalizedMovement()` | Read directional movement for menu binds |
| `self enableInvulnerability()` | Enable God Mode |
| `self disableInvulnerability()` | Disable God Mode |
| `self setMoveSpeedScale(1.5)` | Change move speed |
| `self setOrigin(position)` | Teleport player |
| `getAiArray("axis")` | Retrieve currently spawned enemy AI |
| `self setPlayerAngles(angles)` | Set the player's aim direction |
| `MagicBullet(weapon, start, end, player)` | Fire a scripted shot, if supported by the port |
| `getDvar("mapname")` | Read the map identifier |

These APIs are designed for the BO1 GSC environment; some features and assets still vary by map and by the browser port.

## 6. Console commands

```javascript
await Shadow.ready           // Wait until the current map is installed
await Shadow.installAll()    // Install SHADOW files for all ten map packs
Shadow.open()                // Show the SHADOW browser panel
Shadow.close()               // Hide the browser panel (does not close in-game HUD)
Shadow.status()              // Show launch details
Shadow.diagnostics()         // Gather script-error details when troubleshooting
Shadow.disable()             // Disable the launch hook until next page load
```

## 7. Troubleshooting

**Nothing appears when I press ADS + Melee**

- Make sure the page was refreshed and the injector pasted **before** Play.
- Click into the game if the browser shows **Click to Resume**.
- Make sure you are using normal solo mode with classic guns.
- Check `Shadow.status()`. A launch argument containing `shadow` is necessary but does not prove your GSC compiled successfully.

**The red browser panel won't close**

Click × or **Hide panel**. You can also run `Shadow.close()`. The panel should hide automatically when the game launches. To reopen before the next launch, run `Shadow.open()`.

**I can see the dark in-game panel but no text**

Check `Shadow.diagnostics()` for script errors. Make sure you loaded version 0.8.8 and started a fresh game session.

**An option does nothing**

Inspect `Shadow.diagnostics()`. Browser ports may omit a native GSC function or map asset; staging and launch-hook tests cannot prove the mod actually compiled or that every action executed. Report the map, selected option, and any script exception for a targeted fix.

**My custom menu won't load**

Make sure it has `main()`, uses UTF-8 text, fits under 256 KB, and doesn't require additional scripts that you haven't staged. Importing just one GSC file cannot automatically load an entire multi-file mod project.

## 8. Credits and source references

SHADOW is an independent menu. EnCoReV8 by CabCon was reviewed as a **reference for GSC menu organization**; its original UI and assets are not bundled or copied.

- [EnCoReV8 source](https://github.com/mcabcon/encorev8)
- [BO1 raw GSC sources](https://github.com/Jo-Milk/Black-Ops)
- [vel.gg BO1Z](https://vel.gg/bsz)

The included checks cover JavaScript syntax and GSC source consistency. They do not replace testing in the game.
