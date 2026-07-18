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

The listener speaks **TLS**, not plaintext telnet (see Modernization Plan below) — a plain telnet client will not work. Connect with:

```
openssl s_client -connect 127.0.0.1:7777
```

(port configured via `Port` in `cfg/world.cfg`, currently `7777`). Requires `cfg/server.crt`/`cfg/server.key` to exist (`SSLCertFile`/`SSLKeyFile` in `cfg/world.cfg`) — the engine refuses to start without them.

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
- `Port` — TLS listener port (currently `7777`)
- `SSLCertFile` / `SSLKeyFile` — TLS cert/key (`cfg/server.crt` / `cfg/server.key`); engine refuses to start if missing
- `StartupRoom`, `InitialRoom`, `TheVoidRoom`, `DaemonRoom` — special rooms
- `DbiDriver` / `DbiMasterFile` — database (SQLite default at `db/sqlite/world.sqlite`)
- `UseTempMode = 2` — temp files written alongside originals as `.pm`, purely so a step debugger (originally OpenIDE, ~2009) has something to attach breakpoints to, since it couldn't debug `.pl` directly; the `.pl` is always the real source, the `.pm` is regenerated on every load and gitignored

Multi-language setups live under `cfg/setup_en/` and `cfg/setup_it/`.

## Key Conventions

- Object state is persisted via `store`/`config` (text config format, not serialized Perl).
- `Commons.pm` must be imported in every module.
- Lib paths `std/` and `bin/` are both in `@INC` (set in `driver.pl`).
- Area `.pl` files are dynamically loaded at runtime — not `require`d at startup.
- The `keyname` of an object is its filename plus a unique clone number (the object registry key in `Engine`).
- **Source files are Latin-1 (ISO-8859-1) encoded, not UTF-8.** Many `.pm`/`.pl` files contain raw accented characters (Italian text, e.g. `bin/Commons.pm`'s `wipe_accent`, area/message files). When editing these files, preserve the existing byte encoding — do not let tooling re-save them as UTF-8, or accented characters will be silently corrupted. When in doubt, prefer a byte-level/raw substitution over a full read-modify-write of the whole file.

## Live Scripting / Runtime World Editing

The wizard (admin) can create, modify, and reload world content **without restarting the server**. This is the core "programmable world" feature and must be preserved by any future refactor.

- `load_module($file, $refresh)` (`Commons.pm`) — loads a `.pl` file into the Perl namespace via `%INC`; `$refresh` forces `unload_module()` + reload.
- `call_other($obj, $method, @params)` (`Commons.pm`) — the dispatch core. If `$obj` is a module name (not a ref), it `load_module()`s it, then builds a Perl statement string and executes it via `eval qq{ ... }` (wrapped with `local $SIG{__DIE__}`/`__WARN__` handlers that log compile/runtime errors via `showcomperr`/`showwarnerr` instead of crashing the engine).
- `clone_object($file, @params)` — thin wrapper: `call_other($file, 'new', @params)`.
- Safety gates on the eval path: method name must match `^\w+$` (whitelist), path must not start with `/` or `..`, all calls logged to `command.log` (or `virus.log` on suspicious access).
- Wizard workflow (`cmd/wiz/_clone.pl`, `cmd/wiz/_update.pl`, `cmd/wiz/_unload.pl`):
  1. Edit the area/cmd `.pl` file directly on disk.
  2. `clone <path>` — instantiate a new object from a file (goes to wizard's inventory, or the room if not gettable).
  3. `update` (no args) — reloads the **current room**: moves all contained objects to the void, destroys the room object, force-reloads the module, re-instantiates, moves objects back, forces a `look` for any `User` present. Also accepts `update messages|emotes|constants|actions` to re-read the corresponding `.cfg` files.
  4. `unload <module>` — force-reloads an arbitrary already-loaded module (silences warnings during reload).
- Any future engine (Perl or otherwise) must keep this edit → reload → re-instantiate loop intact; it is the primary content-creation workflow (single wizard, no external tooling).

## Modernization Plan

Planning covers (1) replacing plaintext telnet with an encrypted transport and (2) evaluating a full Perl→Python rewrite.

**Option 1 — TLS on Perl: implemented.** `bin/Engine.pm` listens with `IO::Socket::SSL` (self-signed cert at `cfg/server.crt`/`cfg/server.key`, deferred handshake via `SSL_startHandshake => 0` completed blocking in `socket_logon()`). Complete break with plaintext telnet — no dual-protocol transition period, connect with `openssl s_client -connect 127.0.0.1:7777` (see "Running the MUD" above). Interactive user/password login and ANSI output are unchanged.

**Option 2 — Full Python rewrite: not started, decision deferred.** Would reimplement the engine on `asyncio`, port the `std/` object hierarchy, and re-express the live-reload/eval mechanism above using `importlib` instead of Perl `eval` (same wizard-facing workflow: edit file → `clone`/`update` → live reload). SQLite persistence would stay. Estimated 8-10 wks with 2 people, ~16-20 wks solo.

Full plan lives in [`plan/PLAN_MODERNIZATION.md`](plan/PLAN_MODERNIZATION.md) and the detailed breakdown in [`@plan/`](@plan/) (`00_overview.md`, `01_option_tls_perl.md`, `02_option_python_rewrite.md`) — treat those as the original planning record; this section reflects current implementation status.

Constraints established in discussion: single wizard/admin (no other scripters to retrain), no market/playerbase to preserve, so **no backward compatibility requirement** — a clean break was acceptable for both the transport and the language choice.
