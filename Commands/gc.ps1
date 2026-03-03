#!/usr/bin/env sh
"\"",`$(echo --% ' |out-null)" >$null;function :{};function getDenoVersion{<#${/*'>/dev/null )` 2>/dev/null;getDenoVersion() { #>
echo "2.5.3";: --% ' |out-null <#';};DENO_INSTALL="$HOME/.deno/$(getDenoVersion)";deno_version="v$(getDenoVersion)";deno="$DENO_INSTALL/bin/deno";target_script="$0";disable_url_run="";if [ -n "$url_" ] && [ -z "$disable_url_run" ];then if [ "${url_#http}" = "$url_" ];then url_="https://$url_";fi;target_script="$url_";fi;if [ -x "$deno" ];then exec "$deno" run -q -A --no-lock --no-config "$target_script" "$@";elif [ -f "$deno" ];then chmod +x "$deno" && exec "$deno" run -q -A --no-lock --no-config "$target_script" "$@";fi;has () { command -v "$1" >/dev/null;};if ! has curl;then if ! has wget;then curl () { wget --output-document="$5" "$6";};else echo "Sorry this script needs curl or wget, please install one or the other and re-run";exit 1;fi;fi;if [ "$(uname)" = "Darwin" ];then unzip () { /usr/bin/tar xvf "$4" -C "$2" 2>/dev/null 1>/dev/null;};fi;if ! has unzip && ! has 7z;then echo "Either the unzip or 7z command are needed for this script";echo "Should I try to install unzip for you?";read ANSWER;echo;if [ "$ANSWER" =~ ^[Yy] ];then if has nix-shell;then unzip_path="$(NIX_PATH='nixpkgs=https://github.com/NixOS/nixpkgs/archive/release-25.05.tar.gz' nix-shell -p unzip which --run "which unzip")" alias unzip="$unzip_path" else;if has apt-get;then _install="apt-get install unzip -y";elif has dnf;then _install="dnf install unzip -y";elif has pacman;then _install="pacman -S --noconfirm unzip";else echo "Sorry, I don't know how to install unzip on this system";echo "Please install unzip manually and re-run this script";exit 1;fi;if [ "$(whoami)" = "root" ];then "$_install";elif has sudo;then sudo "$_install";elif has doas;then doas "$_install";else "$_install";fi;fi;fi;if ! has unzip;then echo "";echo "So I couldn't find an 'unzip' or '7z' command";echo "And I tried to auto install unzip, but it seems that failed";echo "Please install the unzip or 7z command manually then re-run this script";exit 1;fi;fi;if ! command -v unzip >/dev/null && ! command -v 7z >/dev/null;then echo "Error: either unzip or 7z is required to install Deno (see: https://github.com/denoland/deno_install#either-unzip-or-7z-is-required )." 1>&2;exit 1;fi;if [ "$OS" = "Windows_NT" ];then target="x86_64-pc-windows-msvc";else case $(uname -sm) in "Darwin x86_64") target="x86_64-apple-darwin" ;;"Darwin arm64") target="aarch64-apple-darwin" ;;"Linux aarch64") target="aarch64-unknown-linux-gnu" ;;*) target="x86_64-unknown-linux-gnu" ;;esac fi;deno_uri="https://dl.deno.land/release/${deno_version}/deno-${target}.zip";deno_install="${DENO_INSTALL:-$HOME/.deno}";bin_dir="$deno_install/bin";exe="$bin_dir/deno";if [ ! -d "$bin_dir" ];then mkdir -p "$bin_dir";fi;curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri";if command -v unzip >/dev/null;then unzip -d "$bin_dir" -o "$exe.zip";else 7z x -o"$bin_dir" -y "$exe.zip";fi;chmod +x "$exe";rm "$exe.zip";exec "$deno" run -q -A --no-lock --no-config "$target_script" "$@";#>};$DenoInstall = "${HOME}/.deno/$(getDenoVersion)";$BinDir = "$DenoInstall/bin";$DenoExe = "$BinDir/deno.exe";$TargetScript = "$PSCommandPath";$DisableUrlRun = "";if ($url_ -and -not($DisableUrlRun)) { if (-not($url -match '^http')) { $url_="https://$url_";} $TargetScript = "$url_";};if (-not(Test-Path -Path "$DenoExe" -PathType Leaf)) { $DenoZip = "$BinDir/deno.zip";$DenoUri = "https://github.com/denoland/deno/releases/download/v$(getDenoVersion)/deno-x86_64-pc-windows-msvc.zip";[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;if (!(Test-Path $BinDir)) { New-Item $BinDir -ItemType Directory | Out-Null;};curl.exe --ssl-revoke-best-effort -Lo $DenoZip $DenoUri;tar.exe xf $DenoZip -C $BinDir;Remove-Item $DenoZip;};& "$DenoExe" run -q -A --no-lock --no-config "$TargetScript" @args;Exit $LastExitCode;<# 
# */0}`;

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
    options: branches.map(b => ({
        name: b.name,
        value: b.name,
        description: timeago(b.date),
    })),
})

await $`git switch ${selected}`

// (this comment is part of universify, dont remove) #>