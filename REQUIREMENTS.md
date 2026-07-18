# Requirements

Dipendenze necessarie per eseguire `bin/driver.pl`.

## Versione Perl

- Perl >= 5.10 (`require 5.010;` in `bin/driver.pl`)

## Moduli core (inclusi nella distribuzione standard Perl)

Nessuna installazione aggiuntiva richiesta:

- `IO::Socket`
- `IO::Select`
- `Net::hostent`
- `Socket`
- `Opcode`
- `File::Copy`
- `Time::HiRes`

## Moduli CPAN (da installare)

- `IO::Socket::SSL` — listener TLS in `bin/Engine.pm` (porta con dipendenza `Net::SSLeay`)
- `DBI` — accesso al database in `bin/Engine.pm` / `bin/Database.pm`
- `DBD::SQLite` — driver DBI usato di default (`cfg/world.cfg`, `DbiDriver = dbi:SQLite:dbname=$0`)

Installazione (Strawberry Perl / cpanm):

```bat
cpanm IO::Socket::SSL DBI DBD::SQLite
```

Se `DbiDriver` in `cfg/world.cfg` viene cambiato a Oracle, serve `DBD::Oracle` al posto di `DBD::SQLite`.

## Altri prerequisiti di runtime (non librerie Perl)

- Certificato TLS: `cfg/server.crt` e `cfg/server.key` devono esistere (`SSLCertFile`/`SSLKeyFile` in `cfg/world.cfg`) — il motore non si avvia senza.
- Database SQLite: `db/sqlite/world.sqlite` deve esistere ed essere accessibile in scrittura.
