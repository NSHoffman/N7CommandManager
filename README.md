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
  * Three-leveled notification system (for senders, for targets and global)

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

### Developers/Modders
For those who want to extend the existing API there is some more information in terms of internal structure of the command manager.

#### `CommandManager`
This is the entry file, the mutator itself that dispatches incoming `mutate` requests.
Each of the available commands must be specified as a part of `CommandManager.Commands` array. Initialization takes place in one of the command initializing methods:
  * `InitHelperCommands()`
  * `InitGameSettingsCommands()`
  * `InitGameplayCommands()`
  * `InitPlayerCommands()`

The distinction between commands initialized in these methods is purely aesthetic, just visual grouping. 
Furthermore, each command must be stated in `enum ECmd` to have its own index in `CommandManager.Commands` array.  

#### `GameStateUtils`
This file contains some useful methods that can be applied in variety of commands and take significant number of code lines.
Mostly these would affect some parts of ZEDs, players or game state.

Each command has access to `GameStateUtils` via `GSU` field which is defined in `CommandManager` file.

#### `CommandExecutionState`/`CommandPreservedState`
These classes keep track of command state when its execution is in progress.

`CommandExecutionState` contains information about current execution, namely:
  * The Sender
  * Targets (if there are any)
  * Status and Error Code (if status is failed)
  * Command Arguments

`CommandPreservedState` is the extension of `CommandExecutionState` which also allows for caching
of some temporary values that are needed across different execution stages but need not be recalculated.
It can cache:
  * a String
  * a TargetName
  * an Integer
  * a Float
  * a Boolean flag
  * and some more value types...

#### `Command`
Base class for all commands. Each new command must be derived from this class to inherit the base execution flow.
The execution flow consists of 5 stages:
  1. `CommandExecutionState` Initialization - Execution State literally gets its initial values.
  2. Arguments validation - Multi-step validation process when lots of conditions get checked (Gametype, Sender, Game State, Admin Access Restrictions etc.)
  3. Action Processing - Desired effects/actions are applied.
  4. Success/Error Notification - Depending on notification settings a selection of actors are notified about execution status.
  5. Optional Cleanup - If any values not related to `CommandExecutionState`/`CommandPreservedState` were used to keep track of execution progress those need to be reset.

This flow is `final` and cannot be altered in subclasses.
Usually one might want to override the following methods to alter the command execution:
  * `Check...(CommandExecutionState)`   - Checker methods.
  * `DoAction(CommandExecutionState)`   - This is where the actual action logic resides.
  * `Notify...(CommandExecutionState)`  - Notifications.

#### `GameSettingsCommand`/`TargetCommand` etc.
Classes derived from `Command` which provide common logic for specified sets of commands.

`GameSettingsCommand` provides some configuration and settings for commands whose sole purpose is to change
some game settings be it maximum players number or ZED-time status.

`TargetCommand` provides extended logic for commands that affect a selection of players.
Here resides the common logic for target validation and per-target command execution.

## Contacts
For questions/concerns/recommendations you can contact me via steam or email:

**Steam Profile:** [N7n](https://steamcommunity.com/id/NSHoffman/)

**Email:** [hoffmanmyst@gmail.com](mailto:hoffmanmyst@gmail.com)
