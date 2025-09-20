# N7 Command Manager Changelog

## `1.0.0`

### Fixes

#### `1.0.1`

- Added automatic config file generation on game start.

## `1.1.0`

- Added ClearLevel command to remove all projectiles and pickups from the level.
- Added Gravity command to modify gravity settings.
- Added InfiniteAmmo command to enable infinite ammo for players.

- Added BlowerBile and ZedGun projectiles support for the SpawnProj command.
- Updated BreakDoors command behavior to destroy all doors, including unwelded ones.
- Updated GiveWeapon command to use a weapon list from the configuration file.
- Updated GiveWeapon command to support giving all possible weapons to players.
- Updated Status command to show game speed information.
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
