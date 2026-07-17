# Overview: Current State & Analysis

## Project Context

**SandpitMUD** is a Multi User Dungeon (MUD) server originally written in Perl, deployed 10+ years ago on both Windows and Linux. It has been dormant for years and requires modernization for:
- **Security**: Remove plaintext telnet, add encryption (TLS/SSH)
- **Maintainability**: Evaluate language choice (Perl vs. Python)
- **Sustainability**: Long-term support and extensibility

---

## Codebase Snapshot

### Size & Structure

```
Total files:       363 (.pm + .pl)
Core engine:       3,977 lines (Engine.pm: 1393, Commons.pm: 2584)
Object hierarchy:  28 classes (std/)
Game content:      181 files (area/*/room, mon, obj)
Commands:          101 files (cmd/*)
Database:          SQLite (DBI wrapper)
```

### Directory Layout

```
bin/
  driver.pl          Main entry point (forks Engine + Mudmon)
  Engine.pm          Core loop: sockets, selector, heartbeat, object registry
  Commons.pm         Global utility library (exported everywhere)
  Database.pm        DBI wrapper for SQLite
  Mudmon.pm          Monitor/watchdog process

std/
  Object.pm          Base class
  Room.pm            Rooms (+ subclasses: Shop, BackShop, PostOffice, VirtualRoom)
  Living.pm          Base for interactive entities
  User.pm            Players
  Mobile.pm          NPCs (mobs)
  Garment.pm         Equipment hierarchy (Helmet, Boots, Armour, etc.)
  Weapon.pm          Weapons
  [... 20 more classes ...]

area/
  <areaname>/
    room/            Room .pl files
    mon/             Mobile .pl files
    obj/             Object .pl files
    <areaname>_0_0.pl Area metadata / grid anchor
```

---

## Architecture: How It Works

### Main Loop (Engine.pm)

```
driver.pl spawns:
  ├─ Engine.pm (main MUD loop)
  │   ├─ Socket listener (telnet port 23)
  │   ├─ Selector poll for client input
  │   ├─ Heartbeat (fires every 2 seconds)
  │   ├─ Callout queue (delayed calls)
  │   └─ Object registry (keyname → object mapping)
  │
  └─ Mudmon.pm (monitor, restarts Engine on crash)
```

### Object System

All game entities inherit from `Object` via the hierarchy:

```
Object
  ├─ Room (and subclasses)
  ├─ Daemon (system services: combat, mail, time, etc.)
  ├─ Living
  │  ├─ User (player)
  │  └─ Mobile (NPC)
  ├─ Garment (+ Helmet, Boots, Armour, etc.)
  ├─ Weapon
  ├─ Book, Key, Money, Exit
```

### Command Dispatch

```
Player input → Engine.socket_process()
  → process_normal()
  → do_command('verb', @args)
  → call_other(cmd/verb/file, 'cmd_verb', @args)
  → Executes wizard-defined command
```

---

## Live Scripting System (The Magic)

Wizards can create/modify the world at runtime. Here's how:

### 1. Create a Room

Create file: `area/myarea/room/tavern.pl`

```perl
use Room;

sub new {
    my $self = shift->SUPER::new;
    $self->short('The Tavern')
         ->desc('A cozy tavern with a bar.')
         ->add_exit('north', './street')
         ->add_object('../mob/bartender')
         ->add_object('../obj/ale_bottle');
    return $self;
}
```

### 2. Instantiate It (Runtime)

Wizard command: `clone area/myarea/room/tavern`

Internally:
```perl
load_module('area/myarea/room/tavern')  # Load .pl into Perl namespace
call_other('area/myarea/room/tavern', 'new')  # Call new() via eval
# Result: Room object in wizard's inventory
```

### 3. Modify It (Runtime)

Edit the tavern.pl file, then:
```
update
```

Internally:
```perl
# 1. Move all objects in tavern to void
# 2. Destroy tavern object
# 3. load_module('area/myarea/room/tavern', 1)  # Force reload
# 4. Re-instantiate tavern
# 5. Move objects back
```

### How `call_other` Works (The Eval)

```perl
sub call_other {
    my ($obj, $cmd, @params) = @_;
    
    # Load module if needed
    load_module($obj) if not already loaded;
    
    # Build a Perl statement string
    my $statement = "$pkg->$cmd(@params)";
    
    # Execute it (!)
    {
        local $SIG{__DIE__} = sub { showcomperr($obj, $_[0]) };
        $result = eval qq{ $statement };
    }
    
    return $result;
}
```

**Safety mechanisms**:
- Command name must match `^\w+$` (whitelist)
- Path validation (no `../` or leading `/`)
- Compile errors caught and logged
- All access logged to command.log / virus.log

---

## Database

**Current**: SQLite (file-based, `db/sqlite/world.sqlite`)

**Via**: DBI wrapper in Database.pm with configurable drivers (SQLite default, but can use Oracle/CSV/etc.)

**Persistence**: 
- Objects stored via `store()`/`restore_config()` (text config format, not serialized)
- User profiles saved to `cfg/users/*.cfg`

---

## Key Observations

### Strengths

1. **Flexible scripting model** — Wizards can extend the world with simple .pl files
2. **Hot reload** — No server restart needed to modify rooms/mobs/objects
3. **Simple object hierarchy** — Easy to understand and extend
4. **Portable** — Ran on Windows and Linux 10+ years ago
5. **Lightweight** — ~4K LOC core, no heavy dependencies

### Weaknesses

1. **Plaintext telnet** — No encryption, INSECURE by modern standards
2. **Dated language** — Perl syntax is archaic, hard to maintain
3. **Eval-based dispatch** — Works but feels fragile (though safely gated)
4. **Synchronous I/O** — Uses select/fork instead of modern async
5. **No async library** — Perl's async story is weak compared to Python
6. **One wizard** — Code only you understand; high bus factor

---

## Modernization Goals

1. **Security first** — Encrypt all traffic (TLS/SSH)
2. **Better language** — Python offers cleaner syntax, better async (asyncio)
3. **Maintain scripting model** — Wizards should still be able to create content easily
4. **Preserve game world** — All 181 area files should work (with minimal translation)

---

## Next Steps

Choose path:
- **Option 1 (TLS on Perl)**: Add encryption quickly, migrate Python later (low risk)
- **Option 2 (Full Python)**: Complete rewrite now, cleaner long-term (more work)

See: [01_option_tls_perl.md](01_option_tls_perl.md) and [02_option_python_rewrite.md](02_option_python_rewrite.md)
