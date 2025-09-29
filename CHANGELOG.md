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
  
- Removed minimum limit when setting trade time via TradeTime command.

- Fixed search by name algorithm.
- Fixed ammo restoration to properly account for active perks.
- Fixed possible crashes caused by the RestoreAttributes command.
- Fixed auto attribute restoration not triggering for new players.
- Fixed incorrect player count calculation when setting fake players.
- Fixed incorrect zeds health calculation when resetting hp config to default.
- Fixed issues with access denial in commands supporting additional admin-only features for players with temporary admin status.
- Fixed cases when non-admin players could target someone other than themselves with regular commands.

- Modified the order of commands to improve grouping and readability when listing all the commands.
