# il_fx

A lightweight FiveM core — characters, occupations (jobs), affiliations (gangs), StateID UIDs,
and cron-based paychecks. Built on ox_lib and oxmysql.

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

## Install

Ensure it after its dependencies:

```cfg
ensure ox_lib
ensure oxmysql
ensure il_fx
```

Tables are created on first start (or import `install.sql`). Give yourself admin with
`add_principal identifier.fivem:YOUR_ID group.admin`.

## Config

Everything lives in `config/`.

- `Config.StateId.StartsAt` — the first character UID (1000, 100, whatever). Each new character
  increments from there.
- `Config.Paycheck.Schedule` — an ox_lib cron expression (default `*/15 * * * *`). Pay accrues
  to `metadata.pendingPaycheck` and is collected from the ped in `Config.Paycheck.Ped`.
- Jobs in `config/jobs.lua`, gangs in `config/gangs.lua`. A rank's `salary` drives the paycheck;
  a salary of `0` falls back to UBI. Jobs also take optional `business`, `hasGarage`, and
  `locations` fields (a `vector3` list or `{ type, pos, dist }` entries) for other resources to
  read via `GetJob`/`GetJobs`.

## Commands

Admin commands are gated to `Config.AdminGroup`.

- `/setjob [id] [job] [rank]`
- `/setgang [id] [gang] [rank]`
- `/setstateid [id] [newId]`
- `/givemoney [id] [cash|bank] [amount]`
- `/stateid` — show your own

## Server exports

```lua
local core = exports.il_fx

core:GetCharacter(src)
core:GetCharacterByStateId(stateId)
core:GetStateId(src)              core:SetStateId(src, newId)
core:GetOccupation(src)           core:SetOccupation(src, job, rank)
core:GetAffiliation(src)          core:SetAffiliation(src, gang, rank)
core:GetBalance(src, account)     core:AddBalance(src, account, amount)
core:RemoveBalance(src, account, amount)
core:GetMetadata(src, key)        core:SetMetadata(src, key, value)
core:GetJob(jobId)                core:GetJobs()
core:GetGangs()
```

Use the flat exports from other resources — the object returned by `GetCharacter` only keeps its
methods inside il_fx.

## Client exports

```lua
exports.il_fx:IsLoaded()
exports.il_fx:GetCharacter()
exports.il_fx:GetStateId()
exports.il_fx:GetJob(jobId)   exports.il_fx:GetJobs()
exports.il_fx:GetGang(gangId) exports.il_fx:GetGangs()
```

## Events

- `core:client:onCharacterLoaded` — character is ready (client)
- `core:server:characterLoaded` / `occupationChanged` / `affiliationChanged` (server)

## Security

Server-authoritative throughout. The `stateId`, `occupation`, `affiliation`, and `displayName`
state bags are reverted if a client tampers with them, so authorize using the exports rather than
the bags. Paycheck collection is range-checked and debounced, and character-creation input is
validated server-side.

## qbx / qb-core bridge

Optional and off by default. Set `setr il_fx:qbxCompat true` to expose qb-shaped exports
(`GetCoreObject`, `GetPlayer`, `PlayerData`) and `QBCore:*` events, so a qb script can be ported
by swapping its resource name to `il_fx`. It covers the common surface, not all of it.

## License

© 2026 5hahfivem. Use it, modify it, run it on your servers, and send PRs — just don't sell it
or claim it as your own, and keep the credit intact. See [LICENSE](LICENSE).
