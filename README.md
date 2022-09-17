# N7 Command Manager

## Description
Killing Floor Mutate API initially designed and developed for Three Hundred Pounds server.
Provides various commands for both players and admins to change game settings and trigger gameplay actions/events.

## Motivation
The motivation and reasoning behind development of the command manager is that most publicly available APIs have:
  * Limited availability for certain actor groups (i.e. AdminPlus is admin-only API)
  * Little potential for further extension (Adding new commands when needed, editing the existing ones)
  * Poor configuration capabilities
  * Inconsistent and not thorough validation mechanism

## What N7CM is offering
  * Large number of built-in commands
  * Ability to provide multiple aliases for a single command (so it can be called in the way you are used to)
  * Access configuration (Players/Spectators/Admins)
  * MinMax values configuration for numeric arguments
  * Rich and consistent validation for sender, targets, arguments, game state etc.
  * Structure flexible enough to allow for API extension when new commands are needed
  * Three-level notification system (for senders, for targets and global)
  * Color highlighting configuration capabilities for certain parts of notifications/messages

## How to use
### Regular Players
Regular players can use any non-admin command from this pack.
The common signature is: `mutate [command] [...args]`.
The list of available commands for players can be requested via `mutate help`.
To get information or (if available) some extended details regarding specific command one can use `mutate help [command]`.

### Admins
Admins can use all of the regular commands + bunch of commands with admin-only access
The list of available commands for admins can be requested via `mutate ahelp` or `mutate adminhelp` (check `N7_AdminHelpCommand` aliases).
To get information or (if available) some extended details regarding specific admin command one can use `mutate ahelp [command]`.

> [`CONFIG.md`](./CONFIG.md) contains basic guidelines for command settings configuration

### Developers/Modders
For those who want to extend the existing API there is some more information in terms of internal structure of the command manager.

#### `N7_CommandManager`
This is the entry file, the mutator itself that dispatches incoming `mutate` requests.
Each of the available commands must be specified as a part of `N7_CommandManager.Commands` array. Initialization takes place in one of the command initializing methods:
  * `InitHelperCommands()`
  * `InitGameSettingsCommands()`
  * `InitGameplayCommands()`
  * `InitPlayerCommands()`

The distinction between commands initialized in these methods is purely aesthetic, just visual grouping. 
Furthermore, each command must be stated in `enum ECmd` to have its own index in `N7_CommandManager.Commands` array.  

#### `N7_GameStateUtils`
This file contains some useful methods that can be applied in variety of commands and take significant number of code lines.
Mostly these would affect some parts of ZEDs, players or game state.

Each command has access to `N7_GameStateUtils` via `GSU` field which is defined in `N7_CommandManager` file.

#### `N7_CommandValidator`
This class provides validation API that is used to check user input and various aspects of game state. 

#### `N7_CommandExecutionState`
These classes keep track of command state when its execution is in progress.

`N7_CommandExecutionState` contains information about current execution, namely:
  * The Sender
  * Targets (if there are any)
  * Status and Error Code (if status is failed)
  * Command Arguments

It also allows for caching of some temporary values that are needed across different execution stages but need not be recalculated.
It can cache:
  * String
  * TargetName
  * Integer
  * Float
  * Boolean

#### `N7_Command`
Base class for all commands. Each new command must be derived from this class to inherit the base execution flow.
The execution flow consists of 5 stages:
  1. `N7_CommandExecutionState` Initialization - Execution State literally gets its initial values.
  2. Arguments validation - Multi-step validation process when lots of conditions get checked (Gametype, Sender, Game State, Admin Access Restrictions etc.)
  3. Action Processing - Desired effects/actions are applied.
  4. Success/Error Notification - Depending on notification settings a selection of actors are notified about execution status.
  5. Optional Cleanup - If any values not related to `N7_CommandExecutionState` were used to keep track of execution progress those need to be reset.

This flow is `final` and cannot be altered in subclasses.
Usually one might want to override the following methods to alter the command execution:
  * `Check...(N7_CommandExecutionState)`   - Checker methods.
  * `DoAction(N7_CommandExecutionState)`   - This is where the actual action logic resides.
  * `Notify...(N7_CommandExecutionState)`  - Notifications.

#### `N7_GameSettingsCommand`/`N7_TargetCommand` etc.
Classes derived from `N7_Command` which provide common logic for specified sets of commands.

`N7_GameSettingsCommand` provides some configuration and settings for commands whose sole purpose is to change
some game settings be it maximum players number or ZED-time status.

`N7_TargetCommand` provides extended logic for commands that affect a selection of players.
Here resides the common logic for target validation and per-target command execution.

#### `N7_ColorManager`/`N7_CommandMessageColors`
These classes are responsible for coloring of messages and notifications.

`N7_ColorManager` is the class that provides color collection based on [Material Design colors](https://materialui.co/colors/).
It also provides API for text coloring and color picking based on IDs rather than RGBA structs. 
All color IDs follow the same structure: `<color>:<tint>`. Also `black`, `white` or `rgb(byte, byte, byte)` compliant values are supported.
Information on both colors and tints can be found on Material Design colors page.

`N7_CommandMessageColors` is just a class that keeps configurable color IDs for various messages/notifications parts.
It is also responsible for providing colorization API for commands.
One is not strictly tied to the cases defined in base `N7_CommandMessageColors` class as it can be extended and assigned to `N7_CommandManager.ColorsClass` field.

## Contacts
For questions/concerns/recommendations you can contact me via steam or email:

**Steam Profile:** [N7n](https://steamcommunity.com/id/NSHoffman/)

**Email:** [hoffmanmyst@gmail.com](mailto:hoffmanmyst@gmail.com)
