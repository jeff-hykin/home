#!/usr/bin/env -S deno run --allow-read --allow-write --allow-net --allow-env --allow-ffi --unstable-ffi

import { Database } from "jsr:@db/sqlite@0.12"

// --- CLI ---
const args = [...Deno.args]
let dbPath = null
let stream = null
let dryRun = false
let assumeYes = false

for (let i = 0; i < args.length; i++) {
    if (args[i] === "--dry-run" || args[i] === "-n") {
        dryRun = true
    } else if (args[i] === "-y" || args[i] === "--yes") {
        assumeYes = true
    } else if (args[i] === "-h" || args[i] === "--help") {
        console.log(`db_delete — Delete a stream (table + companions) from a dimos memory2 .db

Usage: db_delete <recording.db> <stream> [--dry-run] [-y]

A memory2 stream is stored as several tables — the main table plus
"<stream>_blob", "<stream>_vec", "<stream>_rtree" (and the rtree's shadow
tables) — and a row in the "_streams" registry. Dropping only the main table
leaves the rest orphaned, so this removes the whole family and the registry row
(mirrors SqliteStore.delete_stream).

Options:
  -n, --dry-run   Show what would be dropped, change nothing
  -y, --yes       Skip the confirmation prompt`)
        Deno.exit(0)
    } else if (!dbPath) {
        dbPath = args[i]
    } else if (!stream) {
        stream = args[i]
    }
}

if (!dbPath || !stream) {
    console.error("error: need <recording.db> and <stream> (see --help)")
    Deno.exit(1)
}

const db = new Database(dbPath)

// All tables physically present in the db.
const present = new Set(
    db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all().map((r) => r.name),
)

// The stream's table family. Dropping "<stream>_rtree" (an r-tree virtual
// table) also removes its _node/_parent/_rowid shadow tables, but we list them
// explicitly so --dry-run is honest and cleanup is robust either way.
const candidates = [
    stream,
    `${stream}_blob`,
    `${stream}_vec`,
    `${stream}_rtree`,
    `${stream}_rtree_node`,
    `${stream}_rtree_parent`,
    `${stream}_rtree_rowid`,
]
const toDrop = candidates.filter((t) => present.has(t))

const hasRegistry = present.has("_streams")
const inRegistry = hasRegistry &&
    db.prepare("SELECT COUNT(*) AS c FROM _streams WHERE name = ?").get(stream).c > 0

if (toDrop.length === 0 && !inRegistry) {
    console.error(`error: no tables or registry entry found for stream "${stream}"`)
    const streams = hasRegistry
        ? db.prepare("SELECT name FROM _streams ORDER BY name").all().map((r) => r.name)
        : [...present].sort()
    console.error(`available: ${streams.join(", ")}`)
    db.close()
    Deno.exit(1)
}

console.log(`stream "${stream}" in ${dbPath}`)
for (const t of toDrop) {
    const n = db.prepare(`SELECT COUNT(*) AS c FROM "${t}"`).get().c
    console.log(`  drop table  ${t}  (${n} rows)`)
}
if (inRegistry) {
    console.log(`  delete _streams row  ${stream}`)
}

if (dryRun) {
    console.log("dry run — nothing changed")
    db.close()
    Deno.exit(0)
}

if (!assumeYes) {
    const ok = confirm(`Delete stream "${stream}"? This cannot be undone.`)
    if (!ok) {
        console.log("aborted")
        db.close()
        Deno.exit(0)
    }
}

db.exec("BEGIN")
try {
    for (const t of toDrop) {
        db.exec(`DROP TABLE IF EXISTS "${t}"`)
    }
    if (inRegistry) {
        db.prepare("DELETE FROM _streams WHERE name = ?").run(stream)
    }
    db.exec("COMMIT")
} catch (e) {
    db.exec("ROLLBACK")
    console.error("failed, rolled back:", e.message)
    db.close()
    Deno.exit(1)
}

db.exec("VACUUM")
db.close()
console.log(`deleted stream "${stream}"`)
