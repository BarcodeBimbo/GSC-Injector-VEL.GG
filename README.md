# Shadow Garden GSC Guide

Shadow Garden GSC is a standalone console loader and in-game menu for the browser version at [vel.gg/bsz](https://vel.gg/bsz). It does not need Tampermonkey, a proxy, or a replacement FastFile.

Version 0.6.1. The loader passes static checks. Test the menu features in the game before relying on them.

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
| **ADS + Jump** (default) | Toggle NoClip outside the menu; choose another bind or OFF under Controls / HUD |
| Controls / HUD | Navigation, NoClip key, shaders, banner, animation, protection, and low-effects setting |

The **SHADOW GARDEN** menu uses a five-row scrolling list, dark-red background, highlighted selection, and optional scrollbar. The opening message reads **ShadowGarden Menu By Joshua**.

While the menu is open, walking, looking, and weapon use are locked. W and S still work for navigation. Temporary protection keeps zombies away, and God Mode that you enabled yourself stays on after the menu closes. A small colored name appears in the upper-right corner and can be hidden under Controls / HUD.

### What's included

- **Player / Movement:** God Mode, No Target, direct-position free-flight NoClip (WASD, Jump up, Melee down), configurable NoClip key bind, adjustable speed, speed boost, restore health, return to NoClip start, reset options.
- **Weapons:** Ray Gun, AK74u, MP40, Galil, HK21, RPK, M1911, Thundergun, Wunderwaffe, Winter's Howl, Scavenger, Wave Gun, and 31-79 JGb215. Entries are shown only when registered by the loaded map.
- **Ammo / Custom FX:** refill current weapon, infinite reserve/magazine, drop weapon, cycle Normal / Explosive / Heavy / One-Hit / Burn impact damage, plus independently toggled Explosion / Tesla / Flame / Blood / Dust visual FX at traced shot impacts.
- **Perks:** Juggernog, Speed Cola, Double Tap, Quick Revive, Stamin-Up, PhD Flopper, Deadshot Daiquiri, Mule Kick; show only perk-machine entries found in the loaded map; give one, give all available, or clear perks.
- **Zombies / Points:** clear live enemies, one-hit zombie toggle, live counter, active count, round info, points grants, and a capped queue of 1 / 5 / 10 stock-map zombies. The native round manager performs actual spawning; it is not an arbitrary-entity spawner.
- **Aimbot:** Classic (aims at the nearest live zombie), Unfair (adds a magic bullet on a new Fire press), ADS-only/always-on targeting, head/torso target selection.
- **Points:** add 1,000 / 5,000 / 10,000 / 50,000 / 100,000.
- **Teleport / World:** shoot at a solid surface to teleport there when Shoot to TP is enabled; crosshair teleport; saved location; three named in-session room bookmark slots; dynamically discovered starting room / power / Pack-a-Punch / perk-machine locations where the current map exposes those entities; unlock doors/debris and activate power on supported maps.
- **Five / Pack-a-Punch:** on `zombie_pentagon` only, trigger the four real DEFCON switches after power is enabled, report DEFCON state, and use exposed top-floor / War Room / labs / Panic Room portal destinations when initialized. DEFCON countdown and actual weapon upgrading still follow the map's normal mechanics.
- **Controls / HUD:** WASD or classic navigation, inverted W/S, swapped A/D, repeat speed, NoClip bind (Off / ADS+Jump / Use+Jump / Use+Melee), panel opacity, selection and scrollbar shaders, HUD credit banner, low-effects mode, animation, protection, rainbow name.
- **Achievements:** five self-contained SHADOW session badges for reaching rounds 5/10, 10,000/100,000 points, and 100 kills (when kill data is available); unlock all or reset local badges. **Not** Steam/Activision/platform achievement unlocks.
- **Information:** map name, current weapon, position, round.
- **Close Shadow:** animate out and free owned HUD elements.

### Multiplayer status

This is a **solo-focused** build. Multiplayer player targeting and the Host/Co-Host/Admin/Mod/VIP/Guest rank system have been removed for now. No multiplayer role/status labels appear in the menu, including in single-player matches.

Weapon/perk/map-entity availability varies by map. **Infinite Reserve** replenishes reserve ammunition and **Infinite Clip** refills the magazine. Impact damage and custom FX run on the trigger's rising edge, with a 220 ms FX rate limit. Shoot-to-TP uses a ray trace, landing offset, and 650 ms cooldown; it is still possible for an unusual surface or missing collision geometry to yield an unsafe landing, so save a position first. NoClip uses position updates and has a single guarded worker; its collision behavior depends on the browser port. The room bookmarks are saved **for the current session** and are not pre-filled with unverified coordinates. Defcon controls and map teleports are guarded by map/entity checks.

**Stability:** This version uses bounded loops for bulk zombie/door operations, a capped zombie queue, fixed HUD allocations, cooldowns, a recoverable HUD-state watchdog, and a separate movement/view lock. The GSC language cannot guarantee recovery from a JavaScript/WebAssembly engine out-of-memory failure or a native game VM crash; there is no universal exception handler for those failures.

**Aimbot:** In the Aimbot page, turn on Classic for view-angle aiming while you hold ADS. Unfair enables Classic automatically and additionally fires at the selected zombie when you press Fire. The activation control can change ADS-only to always on. Both modes pause while the menu is open and ignore empty zombie waves. Unfair mode depends on the browser port supporting `MagicBullet` for the equipped weapon, so test it on each map.

**Zombie Counter:** Toggle it in the Zombies page. A small red `ZOMBIES` count appears in the game HUD. It refreshes twice per second and can be hidden without closing the main menu.

## 3. Install your own GSC

You can run a second custom GSC script alongside the built-in SHADOW menu. This is useful for learning or prototyping new menus without editing the built-in file.

1. Open the `examples/shadow_custom_menu_example.gsc` file from this package.
2. Save a copy as `my_menu.gsc`. Use a plain-text editor (VS Code or Notepad++) and **UTF-8** encoding.
3. On the game setup screen, paste `Shadow_GSC_Loader.js` into DevTools.
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

Use `newClientHudElem(self)`. Set positions directly:

```gsc
hud = newClientHudElem(self);
hud.horzAlign = "left";
hud.vertAlign = "top";
hud.alignX = "left";
hud.alignY = "top";
hud.x = 345;
hud.y = 163;
hud.font = "default";
hud.fontScale = 1;
hud.color = (1, 0.2, 0.3);
hud setText("My First Option");
```

**Important:** Avoid `#include maps\_hud_util` and `setPoint()` for this browser menu. The previous SHADOW HUD repeatedly entered that utility's `updateChildren` function and tripped the script watchdog. Positioning directly avoids that particular crash path.

Colors use normalized RGB values from 0 to 1. For example:

- Red: `(1, 0.1, 0.2)`
- White: `(1, 1, 1)`
- Dark gray: `(0.1, 0.1, 0.1)`

A plain rectangular background uses `hud setShader("white", width, height)` with `hud.color` set to the desired shade.

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

For example, to create a fourth option, add another `self.custom_rows[3]`, change `self.custom_cursor > 2` to `> 3`, and change the row loops from 3 to 4. Increase the background height and adjust the footer down so the new row fits.

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

Check `Shadow.diagnostics()` for script errors. Make sure you loaded version 0.6.1 and started a fresh game session.

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
