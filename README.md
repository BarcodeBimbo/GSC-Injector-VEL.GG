# Shadow Garden GSC

**Black Ops Zombies menu for the browser game at [vel.gg/bsz](https://vel.gg/bsz)**
Release **v1.3** · By Joshua · [Discord](https://discord.gg/Shadowgarden)

Shadow Garden adds an in-game GSC menu to supported Black Ops Zombies maps. Install it by pasting one JavaScript file into your browser's developer console. The loader handles the built-in GSC files for you-no Tampermonkey, proxy, or FastFile replacement needed.

## Quick start

1. Open **[vel.gg/bsz](https://vel.gg/bsz)** or a supported map page (the `/bo1z/` address also works). **Don't press Play yet.**
2. Press **F12** to open Developer Tools, then select **Console**. In Firefox, **Ctrl+Shift+K** opens the console directly.
3. Open [`Shadow_GSC_Loader.js`](Shadow_GSC_Loader.js), copy the entire file, paste it into the console, and press **Enter**. If DevTools blocks pasting, follow its on-screen paste instructions.
4. **If you're on `/bsz` instead of a map:** choose a map in the launcher, click **Open Map**, and **paste the loader again** when the map's setup screen appears. Navigation cannot carry the console script into the next page.
5. Wait for **Ready to play**. The **Built-in Menu** switch starts ON. You can use **Enable This Map** to install again or **Enable All Maps** to prepare all supported maps.
6. Select **classic weapons** and a **normal solo game**, then press **Play**.
7. In the game, **hold ADS (aim) and press Melee / Knife** to open Shadow Garden when the built-in menu is enabled.

<details>
<summary>Watch the original installation and in-game previews</summary>

### Injection Preview
<div align="center">
  <video src="https://github.com/user-attachments/assets/233a0d5c-1548-4023-bf27-3e0f97888512.mp4"></video>
</div>

### In-Game Preview
<div align="center">
  <video src="https://github.com/user-attachments/assets/5ff04a93-c800-40c8-8c3a-8d69717062ef.mp4"></video>
</div>

</details>

> **Important:** The standalone `_shadow_menu.gsc` is already built into the loader. Do **not** choose it under **Load Custom Script**. That button is for your own separate GSC files.

### Which GSC runs?

The launcher has two independent ON/OFF switches:

| Switch | What it does |
| --- | --- |
| **Built-in Menu** | Runs Shadow Garden's included menu (open with ADS + Melee). |
| **Custom GSC** | Runs the `main()` function from your imported `_user.gsc`. |

- **Default:** Built-in Menu ON, Custom GSC OFF.
- **After importing a custom GSC:** Built-in Menu OFF, Custom GSC ON, so the custom script takes over.
- **Want both?** Turn both ON. If their controls or HUDs conflict, turn one OFF.
- **Want neither?** Turn both OFF. Neither menu will start in the next match.
- Changes apply **when you start a new game**, not immediately in a round that is already running.
- Each map remembers its own switches and custom file. Turning a script OFF does **not** delete it.

## Menu controls

| Key / button | Action |
| --- | --- |
| **ADS + Melee** | Open the menu when closed; exit immediately from any page when open |
| **W / S** | Move up / down |
| **D** or **Use** | Select |
| **A** | Go back one menu |
| **Melee** | Go back one menu, or close on the main menu |
| **Fire / ADS** | Alternate down / up controls |
| **Jump** | Alternate select |
| **Shift + M** | Show or hide the browser launcher |

The footer displays your current controls. You can change the control preset, direction, repeat speed, and NoClip key under **Settings → Controls & Keybinds**.

Shadow Garden remembers the last menu page and selected option when you close it. The next time you open it during the same game, it returns to where you left off.

### Main menu

| Category | What you'll find |
| --- | --- |
| **Player Mods** | God Mode, No Target, NoClip, player speed, heal, reset |
| **Weapons** | Give weapons, equipment, ammo, Pack-a-Punch, bullet effects, perks |
| **Lobby Mods** | Zombies & Points, power-ups, doors, debris, power, teleport, map controls |
| **Aimbot & Combat** | Classic Aimbot, Unfair Aimbot, aim settings, one-hit kills |
| **Settings** | Controls, NoClip bind, appearance, HUD, performance options |
| **Extras** | Game information, local challenges, map and launcher shortcuts |

**NoClip:** Turn it **ON** inside Player Mods first. Its key (Mouse4 by default, with alternatives under Controls & Keybinds) should work only while NoClip is enabled. Some browser ports apply native keybind requests at the next map start.

**Menu protection:** While the menu is open, it temporarily restricts gameplay controls and can protect you from zombies. Your own God Mode setting isn't supposed to be turned off when you close the menu.

### Supported maps

Kino der Toten, Five, Der Riese, Nacht der Untoten, Verrückt, Shi No Numa, Ascension, Call of the Dead, Shangri-La, and Moon.

Map-specific weapons, perks, power-ups, teleport destinations, and scripted events may not exist on every map. **Enable All Maps** only prepares Shadow Garden's files in storage; it does not download or unlock map content.

## Changing maps

1. Press **Shift + M** to show the launcher (or paste it on the `/bsz` map-selection page).
2. Choose a map and select **Change Map**.
3. After the new page loads, **paste `Shadow_GSC_Loader.js` again before pressing Play**.
4. Wait for **Ready to play**, then start the new game.

Changing maps ends your current match. Saved teleport points and menu state are for the current game session only.

## Loading your own GSC

You can load your own GSC without replacing or editing the embedded menu:

1. Open [`examples/shadow_custom_menu_example.gsc`](examples/shadow_custom_menu_example.gsc). This is a small, working example with **Heal Player**, **Add 1,000 Points**, and **Close**.
2. Copy it to a new file, for example `my_menu.gsc`, and make any changes in a plain-text editor.
3. On the map setup screen, load `Shadow_GSC_Loader.js` as usual.
4. Select **Load Custom Script**, choose your `.gsc` file, and wait for confirmation.
5. The loader enables **Custom GSC** and disables **Built-in Menu** automatically. **Start a new game** to run your script; imports do not hot-reload into an ongoing round.

The example opens with **ADS + Use**. While its menu is open, **Fire** moves to the next option, **Use** selects, and **Melee** closes it. The built-in menu opens with **ADS + Melee** only when **Built-in Menu** is ON.

Your custom GSC must:

- Be a UTF-8 plain-text `.gsc` file smaller than **256 KiB**.
- Define a `main()` function with no parameters.
- Use functions and assets supported by the current map and browser port.
- Be self-contained, unless you know how to stage the other required GSC files.

**Your imported GSC is kept separate from the built-in menu.** The loader places it at `mods/shadow/maps/shadow/_user.gsc` for the selected map. Once that file exists, **Enable This Map**, **Enable All Maps**, and loading the launcher again will not replace it with the embedded empty template. The per-map startup hook decides whether to launch the built-in menu, custom script, both, or neither.

If you intentionally load a different custom GSC, that new file replaces the previous custom script. The loader saves the previous text in `.shadow-backup/mods/shadow/maps/shadow/_user.gsc` for that map first. Importing a script on Kino does not automatically copy it to Five or other maps; import it separately on each map where you want it.

Avoid editing `mods/shadow/maps/mod_shadow/_shadow_menu.gsc` as a way to install your own separate script: that file belongs to the built-in Shadow Garden menu and can be refreshed from the embedded loader. See the example source for input handling, HUD creation, and cleanup.

## Browser console commands

Run these after loading `Shadow_GSC_Loader.js`:

```javascript
await Shadow.ready;               // Wait for the current-map install
await Shadow.installAll();        // Prepare GSC files for all supported maps
await Shadow.getModes();          // Read this map's built-in/custom ON/OFF settings
await Shadow.setModes({builtIn:true, custom:false}); // Select built-in menu only
await Shadow.setModes({builtIn:false, custom:true}); // Select custom GSC only
Shadow.open();                    // Show the launcher panel
Shadow.close();                   // Hide the launcher panel
Shadow.maps();                    // List supported map IDs
Shadow.disable();                 // Stop the launcher until the next page load
```

The launcher is separate from the in-game HUD. Hiding the browser panel does not close the GSC menu. Disabling the launcher does not remove GSC that was already loaded into a running match.

## Troubleshooting

| Problem | What to try |
| --- | --- |
| **No launcher appears** | Open `/bsz` or a supported `/bsz/<map>` / `/bo1z/<map>` page. Refresh and paste the entire JS file on the **setup screen**. |
| **Storage or OPFS error** | Use a secure browser tab with site storage allowed. Chrome and Edge are the main targets; Firefox requires working OPFS support in the browser game. |
| **Not ready / install failed** | Check the Console for the exact error. Refresh, paste the loader before Play, and try **Enable This Map**. |
| **ADS + Melee doesn't open the menu** | Check **Built-in Menu** is ON. Confirm classic weapons and normal solo mode, click inside the game, and start a fresh match after the loader says Ready. |
| **Menu text or controls seem wrong** | Make sure you're running the latest loader and not an older script cached in another tab. Restart the map after replacing files. |
| **NoClip key doesn't respond** | Enable NoClip in Player Mods, check **Settings → Controls & Keybinds**, and restart the map if the native bind hasn't taken effect. |
| **A feature does nothing** | Test on Kino and check the Console. Map assets and native GSC functions vary, so some options cannot work on every map. |
| **Map change loses the menu** | That's expected across page navigation: paste the loader again on the destination page **before** Play. |
| **Custom GSC won't run** | Confirm **Custom GSC** is ON, check for `main()`, UTF-8 encoding, the 256 KiB limit, and unsupported or missing dependencies. Start a new game after importing. |
| **Both menus open or controls conflict** | Disable one of the two launcher switches, then start a new match. |
| **Pasted loader on `/bsz`** | Select a map and click **Open Map**, then paste the loader again on that map's setup screen. |

### Requirements and limits

- Desktop browser, site storage enabled, and a supported `vel.gg` BO1 Zombies map.
- **Normal solo mode** using **classic weapons**. The current Shadow Garden release is solo-focused.
- The browser port must support the relevant native GSC operations. A successful file install does not guarantee every GSC function can run.
- Scripts cannot recover a game or browser process from a native crash or out-of-memory condition.

## Project files

```text
Shadow_GSC_Loader.js                       Paste this into the browser console
mods/shadow/maps/mod_shadow/_shadow_menu.gsc  Built-in in-game menu source
mods/shadow/maps/shadow/_hooks.gsc            Per-map startup hooks
mods/shadow/maps/shadow/_user.gsc             Custom-script entry point (empty until imported)
examples/shadow_custom_menu_example.gsc      Example of your own menu
```

The JavaScript loader contains the GSC sources above. If you edit the standalone GSC, it won't change the bundled loader automatically: rebuild or replace the embedded source before releasing.

## Credits

Shadow Garden GSC is by **Joshua**. GSC organization and BO1 API behavior were researched against community examples, including [EnCoReV8](https://github.com/mcabcon/encorev8) and [BO1 GSC sources](https://github.com/Jo-Milk/Black-Ops).

Use at your own risk. Test on a new solo session first, especially after changing map-specific GSC code.
