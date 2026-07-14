# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SandpitMUD is a Multi User Dungeon (MUD) server written in Perl. Players connect via telnet and interact with a text-based world made up of rooms, objects, monsters (mobiles), and daemons.

## Running the MUD

From the project root:

```bat
rem Windows — loops automatically on clean exit, waits 30s on error
mud.bat

rem Or directly (with monitor process via fork):
perl bin/driver.pl cfg/world.cfg -f

rem Single-process (no monitor):
perl bin/driver.pl cfg/world.cfg
```

For the IDE/debug configuration use `cfg/terradelvento_ide.cfg` as the config argument.

Connect via any telnet client to `localhost:23` (port configured in `cfg/world.cfg`).

## Architecture

```
bin/driver.pl        Entry point. Forks into Engine (MUD) + Mudmon (monitor/watchdog).
bin/Engine.pm        Core server loop: socket listener, selector, heartbeat, callout queue,
                     object registry, login/command dispatch.
bin/Commons.pm       Shared library imported everywhere: file I/O, config parsing, colors,
                     dice rolls, standard messages, database helpers.
bin/Mudmon.pm        Monitor process that restarts the engine on crash.
bin/Database.pm      DBI wrapper (SQLite by default, configurable to Oracle/CSV).
```

### Object Hierarchy (`std/`)

All in-world entities inherit from `Object` (`std/Object.pm`):

```
Object
  ├── Room  →  Shop, BackShop, PostOffice, VirtualRoom
  ├── Daemon  (system services: combat, mail, time, level, etc.)
  ├── Living  →  Mobile (NPC/mob), User (player)
  ├── Garment  →  Helmet, Boots, Gloves, Armour, Shield, Cloak, Ring, Amulet, Earring, Belt
  ├── Weapon
  ├── Book, Key, Money, Exit
```

Each class lives in `std/<ClassName>.pm`. Area-specific subclasses are plain `.pl` files that `use` the relevant std class.

### Areas (`area/`)

```
area/<areaname>/
  room/         room .pl files
  mon/          mobile (NPC) .pl files
  obj/          object .pl files
  <area>_0_0.pl area metadata / grid anchor
  <area>_6_5.pl area map grid
```

Room files call `add_exit('direction', 'relative/path')` and `add_object(...)` in their `new` sub. Paths are relative to the room file's location.

### Configuration (`cfg/`)

`cfg/world.cfg` is the main config. Key parameters:
- `Port` — telnet port (default 23)
- `StartupRoom`, `InitialRoom`, `TheVoidRoom`, `DaemonRoom` — special rooms
- `DbiDriver` / `DbiMasterFile` — database (SQLite default at `db/sqlite/world.sqlite`)
- `UseTempMode = 2` — temp files written alongside originals as `.pm`

Multi-language setups live under `cfg/setup_en/` and `cfg/setup_it/`.

## Key Conventions

- Object state is persisted via `store`/`config` (text config format, not serialized Perl).
- `Commons.pm` must be imported in every module.
- Lib paths `std/` and `bin/` are both in `@INC` (set in `driver.pl`).
- Area `.pl` files are dynamically loaded at runtime — not `require`d at startup.
- The `keyname` of an object is its filename plus a unique clone number (the object registry key in `Engine`).
