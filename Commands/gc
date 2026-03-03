#!/usr/bin/env -S deno run --allow-all --no-lock
import $ from "https://esm.sh/dax-sh"
import { Select } from "https://esm.sh/jsr/@cliffy/prompt"
import { format as timeago } from "https://esm.sh/timeago.js"
import Fuse from "https://esm.sh/fuse.js"

// Get all branches with last commit dates, sorted by most recent
const refFormat = "%(refname:short)|%(committerdate:iso8601)"
const output = await $`git for-each-ref --sort=-committerdate --format=${refFormat} refs/heads/ refs/remotes/origin/`.text()

const seen = new Set()
const branches = []

for (const line of output.split("\n")) {
    if (!line.trim()) continue
    const [rawName, dateStr] = line.split("|")

    // Skip HEAD pointer and bare "origin"
    if (rawName === "origin/HEAD" || rawName.endsWith("/HEAD")) continue
    if (rawName === "origin") continue

    // Remove origin/ prefix from remote branches
    const name = rawName.replace(/^origin\//, "")

    // Deduplicate (first one wins = most recently edited due to sort order)
    if (seen.has(name)) continue
    seen.add(name)

    branches.push({ name, date: new Date(dateStr.trim()) })
}

const arg = Deno.args[0]

// Switch to previous branch (like `git checkout -`)
if (arg === "-") {
    await $`git switch -`
    Deno.exit(0)
}

// If argument is a valid branch name, just switch to it
if (arg && branches.some(b => b.name === arg)) {
    await $`git switch ${arg}`
    Deno.exit(0)
}

// If argument was provided but not a valid branch, do fuzzy search
if (arg) {
    const fuse = new Fuse(branches, { keys: ["name"], threshold: 0.6 })
    const results = fuse.search(arg)
    if (results.length > 0) {
        console.log(`Did you mean "${results[0].item.name}"?`)
    } else {
        console.log(`No close match found for "${arg}"`)
    }
    console.log()
}

// Interactive selection
const selected = await Select.prompt({
    message: "Select a branch to checkout:",
    search: true,
    options: branches.map(b => ({
        name: b.name,
        value: b.name,
        description: timeago(b.date),
    })),
})

await $`git switch ${selected}`

// (this comment is part of universify, dont remove) #>