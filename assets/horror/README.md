# Horror asset candidates

These files are reference candidates only. No sprite, sound, included file, or death effect has been registered in either GameMaker project. Do not execute archive contents. PNG and WAV assets can be previewed before importing.

## Enemy: Animated Creepy Ghost Sprite
- Author: ZaninDevelopers
- License: CC0
- Source: https://opengameart.org/content/animated-creepy-ghost-sprite
- Original archive: enemies/zanindevelopers/dark_ghost_enemy.zip
- Original sheets: idle.png, fly.png, attack.png, death.png
- The downloaded idle sheet is 2560 x 640 pixels; verify actual frame dimensions before importing. The source page describes a 32 x 32 style but the distributed image is upscaled.

## Alternative enemy: Ghost monster
- Author: ImogiaGames, remixed from Ghost and Skeleton by Balmer
- License: CC0
- Source: https://opengameart.org/content/ghost-monster
- File: enemies/imogiagames/anim-nme-ghost.png
- Layout: six 32 x 32 frames, 192 x 32 sheet.

## Death jumpscare portrait candidate
- Author: ZaninDevelopers
- License: CC0
- Source: https://opengameart.org/content/animated-creepy-ghost-sprite
- File: jumpscare/creepyghostsprite.png
- Original 2048 x 2048 dark portrait; not an implemented jumpscare animation.

## Death sting audio candidates
- Author: psychhead_
- License: CC0
- Source: https://opengameart.org/content/horror-hit-soundpack-1
- File: jumpscare/horror_hit_soundpack_1.zip
- Contains 55 WAV effects and the author's README, also copied as soundpack_README.txt.
- Not auditioned or normalized. Preview at low playback volume and select one before integration.

## Proposed later integration
Keep the hunter and friendly ghost readable. Use the dark enemy sprite as contrast.
On hunter death, play one brief portrait/attack-frame reveal and one short sound, then display the restart prompt. Trigger once per death, with a jumpscare toggle. No automatic playback has been added.
