# N7 Command Manager Changelog

## `1.0.0`

### Fixes

#### `1.0.1`

- Added automatic config file generation on game start.

## `1.1.0`

- Added ClearLevel command to remove all projectiles and pickups from the level.
- Added Gravity command to modify gravity settings.
- Added InfiniteAmmo command to enable infinite ammo for players.

- Updated SpawnProj command so it now supports BlowerBile and ZedGun projectiles.
- Updated BreakDoors command behavior so it destroys all doors, including unwelded ones.
- Updated GiveWeapon command so it uses a weapon list from the configuration file.
- Updated GiveWeapon command so it supports giving all possible weapons to players.
- Updated Status command so it shows game speed information.
- Updated Gravity, GameSpeed, MaxZeds, SpawnRate and ZedHPConfig commands so they now display a reset message when values are reset to default.
  
- Removed minimum limit when setting trade time via TradeTime command.

- Fixed/improved name matching algorithm when searching for players and other entities by name.
- Fixed ammo restoration to properly account for active perks.
- Fixed possible crashes caused by the RestoreAttributes command.
- Fixed auto attribute restoration not triggering for new players.
- Fixed incorrect player count calculation when setting fake players.
- Fixed incorrect zeds health calculation when resetting hp config to default.
- Fixed issues with access denial when players with temporary admin status use commands supporting additional admin-only features.
- Fixed cases when non-admin players could target someone other than themselves with regular commands.

- Rearranged the list of commands to improve grouping and readability.
