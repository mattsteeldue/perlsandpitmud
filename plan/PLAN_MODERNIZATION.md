# SandpitMUD Modernization Plan

**Date**: 2026-07-14  
**Status**: Planning Phase (decisions deferred)

## Overview

Modernization roadmap for SandpitMUD, focusing on:
1. **Security**: Migrate from telnet (plaintext) to TLS/SSH
2. **Language**: Evaluate Perl vs. Python rewrite
3. **Database**: Keep SQLite, evaluate improvements

## Current State

### Codebase Size
- **363 files total** (.pm + .pl)
- **Core engine**: 3,977 lines (Engine.pm: 1393, Commons.pm: 2584)
- **Object hierarchy**: 28 std/ classes
- **Game content**: 181 area files (rooms/mobs/objects)
- **Commands**: 101 cmd files
- **Configuration**: SQLite database (DBI wrapper)

### Architecture
```
bin/driver.pl          Entry point (main loop + Mudmon monitor)
bin/Engine.pm          Core: sockets, selector, heartbeat, object registry
bin/Commons.pm         Utility library (exported everywhere)
bin/Database.pm        DBI wrapper
std/*.pm               Object hierarchy (Room, Mobile, User, Garment, Weapon...)
area/*/                Game world (rooms, mobs, objects)
cmd/*/                 Commands
cfg/                   Configuration files
```

### Live Reloading System
The MUD supports runtime code modification via:
- `load_module()` → reloads .pl files into Perl namespace
- `call_other()` → dynamic method calls via eval'd strings
- `_update` wizard command → reload world from void, reinit zone
- `_clone` wizard command → instantiate objects at runtime

**Eval complexity**: Moderate. Uses string interpolation + eval for method dispatch, whitelist filtering on commands, path validation.

## Option 1: TLS on Perl (Short term)

### Approach
- Add `IO::Socket::SSL` listener to Engine.pm
- Maintain interactive login (user/password) over encrypted channel
- ANSI colors work normally
- Complete break with telnet

### Effort
- **Estimated**: 1-2 weeks (1 person)
- **Risk**: Low (isolated change to listener socket)
- **Trade-off**: Keeps Perl stack, defers full modernization

### Benefits
- Encryption live quickly
- No migration risk
- Can migrate to Python incrementally later

---

## Option 2: Full Python Rewrite (Long term)

### Approach
- Migrate entire codebase to Python
- Use `asyncio` for event loop (cleaner than Perl select/fork)
- Equivalent object hierarchy and scripting model
- Same interactive login over TLS
- SQLite via `sqlite3` module

### Effort Estimate

**1 person**: ~10-14 weeks (~2.5-3 months)
- Engine refactor (asyncio): 2 wks
- Commons utilities: 1 wk
- Object hierarchy classes: 1-2 wks
- Area files migration: 2-3 wks (semi-automatic)
- Commands: 1 wk
- Testing + bugfix: 2-3 wks

**2 people**: ~6-8 weeks (~1.5-2 months)
- Parallel work on independent modules

### Benefits
- Cleaner async model (asyncio > Perl select)
- Better maintainability
- Easier to extend (Python > Perl for readability)
- Modern language ecosystem
- Same scripting model for wizards (Python eval instead of Perl eval)

### Risks
- Large rework requires sustained focus
- Wizard scripting needs documentation update
- Testing burden (181 area files to verify)
- No incremental deployment path

---

## Scripting Model (Both Options)

### Current (Perl)
```perl
use Room;
sub new {
    my $self = shift->SUPER::new;
    $self->short('Palace')
         ->desc('A grand palace')
         ->add_exit('north', './next_room')
         ->add_object('../mob/guard');
    return $self;
}
```

### Equivalent (Python)
```python
from std.room import Room
class Palace(Room):
    def __init__(self):
        super().__init__()
        self.short('Palace')
        self.desc('A grand palace')
        self.add_exit('north', './next_room')
        self.add_object('../mob/guard')
```

Wizard workflow remains nearly identical: edit file → `update` command → live reload.

---

## Decision Points (Deferred)

- [ ] **Timeline**: When to start modernization? (6 months? immediately?)
- [ ] **Hybrid approach**: Use Option 1 (TLS on Perl) now, Option 2 (Python) later?
- [ ] **Resources**: Can you commit sustained effort (6-10 weeks for full rewrite)?
- [ ] **Backwards compat**: Any existing wizard scripts/content to preserve?
- [ ] **Database**: Migrate to PostgreSQL/MariaDB, or keep SQLite?

---

## Recommended Path (Awaiting Decision)

**If Quick Security Needed**: Option 1 (TLS on Perl, 1-2 wks)  
**If Full Modernization**: Option 2 (Python, 8-10 wks with 2 people)  
**If Gradual**: Option 1 now + incremental Python migration over 3-4 months

---

## Next Steps

1. Review this plan
2. Decide on timeline and resources
3. Determine if hybrid approach is preferred
4. Lock decision on Python vs. Perl
5. Begin implementation
