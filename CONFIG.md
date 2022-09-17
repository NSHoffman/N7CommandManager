# Command Manager Configuration
This Command Manager along with its dependent classes provide various configuration capabilities.
The following guide will cover most (if not all) of them.

All the configuration must reside in `N7CommandManager.ini` file.

## `N7_CommandManager`

**Example:**
```python
[N7CommandManager.N7_CommandManager]
# If False, all command requests will be ignored
bAllowMutate=True
```

## `N7_ColorManager`
In color manager one can set up their own set of colors by defining custom palettes.
Each palette is a `struct` which represents a single color with finite number of tints.
Each palette has following tints: 
 * `T50` 
 * `T100`
 * `T200`
 * `T300`
 * `T400`
 * `T500`
 * `T600`
 * `T700`
 * `T800`
 * `T900`
 * `A100`
 * `A200`
 * `A400`
 * `A700`

Tints are `struct Color` with `RGBA` format properties, so one tint can be defined as `(R=255,G=255,B=255,A=255)`. 
It's not common that one will need to directly change the default palettes but just in case there is such an option.
If you ever find yourself willing to override default palettes make sure you provide values for every tint inside a palette
As unspecified tints will automatically resolve to default `(R=0,G=0,B=0,A=0)` which is a transparent color.

Also one can change `DefaultColor` if needed.

**Example:**
```python
[N7CommandManager.N7_ColorManager]
DefaultColor=(R=255,G=255,B=255,A=255)
# Tints that are omitted will resolve to transparent color (0,0,0,0)
# So make sure to provide every tint with valid color value if you happen to override default colors
Reds=(T50=(R=255,G=255,B=255,A=255),T100=...)
Pinks=(T50=(R=255,G=255,B=255,A=255),T100=...)
Purples=(T50=(R=255,G=255,B=255,A=255),T100=...)
DeepPurples=(T50=(R=255,G=255,B=255,A=255),T100=...)
Indigos=(T50=(R=255,G=255,B=255,A=255),T100=...)
Blues=(T50=(R=255,G=255,B=255,A=255),T100=...)
LightBlues=(T50=(R=255,G=255,B=255,A=255),T100=...)
Cyans=(T50=(R=255,G=255,B=255,A=255),T100=...)
Teals=(T50=(R=255,G=255,B=255,A=255),T100=...)
Greens=(T50=(R=255,G=255,B=255,A=255),T100=...)
LightGreens=(T50=(R=255,G=255,B=255,A=255),T100=...)
Limes=(T50=(R=255,G=255,B=255,A=255),T100=...)
Yellows=(T50=(R=255,G=255,B=255,A=255),T100=...)
Ambers=(T50=(R=255,G=255,B=255,A=255),T100=...)
Oranges=(T50=(R=255,G=255,B=255,A=255),T100=...)
DeepOranges=(T50=(R=255,G=255,B=255,A=255),T100=...)
Browns=(T50=(R=255,G=255,B=255,A=255),T100=...)
Greys=(T50=(R=255,G=255,B=255,A=255),T100=...)
BlueGreys=(T50=(R=255,G=255,B=255,A=255),T100=...)
```

## `N7_CommandMessageColors`
These are colors that will be used to colorize certain parts of messages/notifications.
Colors are defined using the following format: `<Color>:<Tint>` | `rgb(0-255, 0-255, 0-255)` | `black` | `white`.

Message parts that support color highlighting:
 * `Main`       - Default color
 * `Sender`     - Command sender's name
 * `Target`     - Target name
 * `Entity`     - Non-living non-playable game entity. (e.g. Weapons)
 * `Value`      - Numeric/non-numeric value that is set when command gets executed
 * `Signature`  - Command signature when `help` is requested
 * `Emphasis`   - Important text that needs highlighting
 * `Error`      - Error messages

**Example:**
```python
[N7CommandManager.N7_CommandMessageColors]
Main="white"
Signature="white"
Sender="white"
Target="white"
Entity="white"
Value="white"
Emphasis="white"
Error="white"
```

## `N7_Command`
One usually won't want to configure this class directly. Instead it's better to change general command
settings defined here for deriving command classes.

The list of existing command classes can be found in this repository's `Classes/` directory.

**Example:**
```python
[N7CommandManager.N7_<Any-Command-Class-Name>]
# If True only admins will be able to execute this command
bAdminOnly=False
# If True coloring won't be applied
bDisableColoring=False
# If True players won't be notified about command execution status
bDisableNotifications=False
# Sets Aliases by which a command can be addressed
Aliases="FIRST"
Aliases="SECOND"
Aliases="THIRD"
```

## `N7_TargetCommand`
All commands that are derived from `N7_TargetCommand` class share some targeting-related settings.
These settings determine how strict the validation is towards selected targets.

**Example:**
```python
[N7CommandManager.N7_<Target-Command-Class-Name>]
bOnlyAliveTargets=False
bOnlyDeadTargets=False
bOnlyPlayerTargets=True
bOnlySpectatorTargets=False
bOnlyAdminTargets=False
bOnlyNonAdminTargets=False
```

## `N7_GameSettingsCommand`
Most commands that use numeric value as an argument have lower and upper boundaries.
Mostly these commands are derived from but not limited to `N7_GameSettingsCommand`.

To prevent configuring `MinLimit` with negative values 
oftentimes out of `MinLimit` and `MaxLimit` params only the latter is configurable, but that's not always the case.

Make sure you provide reasonable values when configuring these boundaries (avoid negative or inadequately large numbers)

**Example:**
```python
[N7CommandManager.N7_<Numeric-Command-Class-Name>]
# In case command supports configuring MinLimit
MinLimit=0
MaxLimit=10
```
## Other commands
Other commands might have some specific configurable fields.
Feel free to explore them in the source code. Those are marked as `config`. 
