# Option 2: Full Python Rewrite (Long-term, Comprehensive)

**Timeline**: 8-10 weeks (with 2 people)  
**Effort**: 1 person = 16-20 weeks; 2 people = 8-10 weeks (parallel work)  
**Risk**: Moderate (large rewrite, requires discipline)  
**Trade-off**: Full modernization, cleaner async, higher short-term effort

---

## Vision

Rewrite SandpitMUD entirely in Python:
- Modern async I/O via `asyncio` (cleaner than Perl select/fork)
- Equivalent object hierarchy (same design, Python classes)
- Equivalent scripting model (wizard .py files instead of .pl)
- Same TLS/encryption
- Same SQLite database (via `sqlite3` module)

**Result**: A modern, maintainable MUD that's easier to understand and extend.

---

## Architecture (Python)

```
bin/
  driver.py          Main entry point + Mudmon equivalent
  engine.py          Core loop (asyncio-based)
  commons.py         Utility library
  database.py        SQLite wrapper

std/
  object.py          Base class
  room.py            Room hierarchy
  living.py          Living entities
  user.py            Player
  mobile.py          NPC
  garment.py         Equipment
  weapon.py          Weapons
  [... equivalent to Perl std/ ...]

area/                Game content (wizard-created .py files)
  <areaname>/
    rooms/
    mobs/
    objects/

cmd/
  <command_files>/   Command implementations
```

### Key Differences from Perl

| Aspect | Perl | Python |
|--------|------|--------|
| **Async** | select/fork (manual) | asyncio (built-in, cleaner) |
| **Syntax** | Archaic, line-noise | Clear, modern |
| **Object model** | Ad-hoc blessed hashes | Proper classes |
| **Imports** | `use`, package-based | `import`, module-based |
| **Eval** | `eval qq{ ... }` | `exec()`, `importlib` |
| **Type hints** | No | Yes (optional but helpful) |

---

## Breakdown: Component-by-Component

### Phase 1: Engine & Core (2 weeks)

**Goal**: Get async socket loop running, basic login working.

**Files**:
- `bin/engine.py` — Rewrite Engine.pm's main loop using asyncio
  - `asyncio.start_server()` for TLS listener
  - `asyncio.wait_for()` for timeouts
  - Task management for heartbeat, callouts, selector
  
- `bin/commons.py` — Utility library
  - `call_other()` (async version: `async_call_other()`)
  - Object registry, notification system
  - File I/O, color parsing, etc.

- `bin/database.py` — SQLite wrapper
  - Same interface as Perl version
  - Use `sqlite3` module (standard library)

**Outcome**: Can connect, login, see initial room.

### Phase 2: Object Hierarchy (1-2 weeks)

**Goal**: Implement std/ classes in Python.

**Files**:
- `std/object.py` — Base Object class
- `std/room.py` — Room, Shop, BackShop, PostOffice, VirtualRoom
- `std/living.py` — Living base
- `std/user.py` — Player
- `std/mobile.py` — NPC
- `std/garment.py` — Equipment hierarchy (Helmet, Boots, etc.)
- `std/weapon.py` — Weapons
- `std/{book,key,money,exit}.py` — Other objects

**Key pattern**:
```python
from std.object import Object

class Tavern(Object):
    def __init__(self):
        super().__init__()
        self.short = "The Tavern"
        self.desc = "A cozy tavern with a bar."
        self.add_exit('north', './street')
        self.add_object('../mob/bartender')
```

### Phase 3: Area Files Migration (2-3 weeks)

**Goal**: Convert 181 .pl files to Python.

**Approach**: Semi-automatic
1. Parse Perl syntax (identify class, method calls, structure)
2. Generate Python skeleton
3. Manual pass to fix edge cases

**Example conversion**:

**Perl** (`area/dummy/room/building.pl`):
```perl
use Room;
sub new {
    my $self = shift->SUPER::new;
    $self->short('Palace')
         ->desc('A grand palace')
         ->add_exit('north', './alley_north')
         ->add_object('../mon/ronda_follower');
    return $self;
}
```

**Python** (`area/dummy/room/building.py`):
```python
from std.room import Room

class Palace(Room):
    def __init__(self):
        super().__init__()
        self.short("Palace")
        self.desc("A grand palace")
        self.add_exit("north", "./alley_north")
        self.add_object("../mon/ronda_follower")
```

Most conversions are straightforward (method chaining → assignment/call).

### Phase 4: Commands (1 week)

**Goal**: Implement all 101 cmd files.

**Similar pattern**:

**Perl** (`cmd/wiz/_clone.pl`):
```perl
sub cmd_clone {
    my $me = shift;
    my $verb = shift;
    my $file = shift;
    my $pl = current_user();
    # ... logic ...
}
```

**Python** (`cmd/wiz/clone.py`):
```python
async def cmd_clone(me, verb, file, pl=None):
    pl = current_user() if pl is None
    # ... logic ...
    return 1  # or -1 for fail
```

### Phase 5: Testing & Bugfix (2-3 weeks)

- Functional testing (all commands work)
- Area testing (all 181 files load and behave correctly)
- Multi-client stress testing
- Crash recovery (Mudmon equivalent)
- Performance baseline

---

## Wizard Scripting (Python)

### Current (Perl)

Wizard creates `area/myarea/room/tavern.pl`:
```perl
use Room;
sub new {
    my $self = shift->SUPER::new;
    $self->short('Tavern')->desc('...');
    return $self;
}

sub action {
    my $this = shift;
    # custom logic
}
```

Wizard loads with: `clone area/myarea/room/tavern`

Wizard reloads with: `update`

### New (Python)

Wizard creates `area/myarea/room/tavern.py`:
```python
from std.room import Room

class Tavern(Room):
    def __init__(self):
        super().__init__()
        self.short('Tavern')
        self.desc('...')
    
    def action(self):
        # custom logic
```

Wizard loads with: `clone area/myarea/room/tavern`

Wizard reloads with: `update`

**Experience**: Nearly identical. Syntax is cleaner (less noise), logic is more readable.

---

## Live Reload in Python

Instead of Perl's `load_module()` and `eval`:

```python
import importlib
import sys

def load_module(module_name, refresh=False):
    """Load/reload a Python module"""
    if refresh and module_name in sys.modules:
        importlib.reload(sys.modules[module_name])
    else:
        importlib.import_module(module_name)

def clone_object(module_name):
    """Clone an object by dynamically loading and instantiating"""
    module = sys.modules[module_name]
    
    # Find the class (convention: module name → ClassName)
    class_name = camel_case(module_name.split('.')[-1])
    cls = getattr(module, class_name)
    
    return cls()  # Instantiate
```

**Safer than Perl's eval** (no string interpolation), **cleaner** (uses Python's module system).

---

## Benefits

✓ **Modern language** — Python syntax is clear and readable  
✓ **Native async** — asyncio handles 100+ simultaneous clients elegantly  
✓ **Better maintainability** — easier to understand and extend  
✓ **Wizard experience** — nearly identical, slightly cleaner  
✓ **Ecosystem** — Python has better libraries for everything  
✓ **Performance** — asyncio is faster than Perl select/fork  
✓ **Type hints** — optional but helpful for large codebases  

---

## Drawbacks

✗ **Large rewrite** — 8-10 weeks of concentrated work  
✗ **Testing burden** — 181 area files must be verified  
✗ **Knowledge transfer** — only you know the codebase (high risk if something goes wrong)  
✗ **No incremental deployment** — can't ship Python gradually while Perl runs  
✗ **Upfront risk** — if priorities change mid-rewrite, you're stuck with half-done Python  

---

## Timeline (with 2 people)

```
Week 1-2:  Engine + Core (asyncio, login, heartbeat)
Week 3:    Object hierarchy
Week 4-5:  Area files migration (parallel: one person per 90 files)
Week 6:    Commands + integration
Week 7-8:  Testing, bugfix, stress testing
Week 9-10: Buffer/performance optimization, final polish
```

**With 1 person**: Double the timeline (~16-20 weeks).

---

## Testing Strategy

1. **Unit tests** — test each std/ class in isolation
2. **Integration tests** — load a full area, verify all objects exist
3. **Functional tests** — play through a scenario (login, move, combat, etc.)
4. **Stress tests** — 20+ simultaneous clients, measure CPU/memory
5. **Regression tests** — compare behavior vs. Perl version (logging, output)

---

## Recommended If

- You can commit 2 people for 8-10 weeks
- You want full modernization (not a half-measure)
- You're willing to accept upfront risk for long-term payoff
- You think Python MUD is a unique offering (interesting portfolio project!)
- You plan to actively develop the world going forward
