#!/usr/bin/env sh
"\"",`$(echo --% ' |out-null)" >$null;function :{};function dv{<#${/*'>/dev/null )` 2>/dev/null;dv() { #>
echo "1.38.3"; : --% ' |out-null <#'; }; version="$(dv)"; deno="$HOME/.deno/$version/bin/deno"; if [ -x "$deno" ]; then  exec "$deno" run -q -A "$0" "$@";  elif [ -f "$deno" ]; then  chmod +x "$deno" && exec "$deno" run -q -A "$0" "$@";  fi; bin_dir="$HOME/.deno/$version/bin"; exe="$bin_dir/deno"; has () { command -v "$1" >/dev/null; } ;  if ! has unzip; then if ! has apt-get; then  has brew && brew install unzip; else  if [ "$(whoami)" = "root" ]; then  apt-get install unzip -y; elif has sudo; then  echo "Can I install unzip for you? (its required for this command to work) ";read ANSWER;echo;  if [ "$ANSWER" =~ ^[Yy] ]; then  sudo apt-get install unzip -y; fi; elif has doas; then  echo "Can I install unzip for you? (its required for this command to work) ";read ANSWER;echo;  if [ "$ANSWER" =~ ^[Yy] ]; then  doas apt-get install unzip -y; fi; fi;  fi;  fi;  if ! has unzip; then  echo ""; echo "So I couldn't find an 'unzip' command"; echo "And I tried to auto install it, but it seems that failed"; echo "(This script needs unzip and either curl or wget)"; echo "Please install the unzip command manually then re-run this script"; exit 1;  fi;  repo="denoland/deno"; if [ "$OS" = "Windows_NT" ]; then target="x86_64-pc-windows-msvc"; else :;  case $(uname -sm) in "Darwin x86_64") target="x86_64-apple-darwin" ;; "Darwin arm64") target="aarch64-apple-darwin" ;; "Linux aarch64") repo="LukeChannings/deno-arm64" target="linux-arm64" ;; "Linux armhf") echo "deno sadly doesn't support 32-bit ARM. Please check your hardware and possibly install a 64-bit operating system." exit 1 ;; *) target="x86_64-unknown-linux-gnu" ;; esac; fi; deno_uri="https://github.com/$repo/releases/download/v$version/deno-$target.zip"; exe="$bin_dir/deno"; if [ ! -d "$bin_dir" ]; then mkdir -p "$bin_dir"; fi;  if ! curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"; then if ! wget --output-document="$exe.zip" "$deno_uri"; then echo "Howdy! I looked for the 'curl' and for 'wget' commands but I didn't see either of them. Please install one of them, otherwise I have no way to install the missing deno version needed to run this code"; exit 1; fi; fi; unzip -d "$bin_dir" -o "$exe.zip"; chmod +x "$exe"; rm "$exe.zip"; exec "$deno" run -q -A "$0" "$@"; #>}; $DenoInstall = "${HOME}/.deno/$(dv)"; $BinDir = "$DenoInstall/bin"; $DenoExe = "$BinDir/deno.exe"; if (-not(Test-Path -Path "$DenoExe" -PathType Leaf)) { $DenoZip = "$BinDir/deno.zip"; $DenoUri = "https://github.com/denoland/deno/releases/download/v$(dv)/deno-x86_64-pc-windows-msvc.zip";  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;  if (!(Test-Path $BinDir)) { New-Item $BinDir -ItemType Directory | Out-Null; };  Function Test-CommandExists { Param ($command); $oldPreference = $ErrorActionPreference; $ErrorActionPreference = "stop"; try {if(Get-Command "$command"){RETURN $true}} Catch {Write-Host "$command does not exist"; RETURN $false}; Finally {$ErrorActionPreference=$oldPreference}; };  if (Test-CommandExists curl) { curl -Lo $DenoZip $DenoUri; } else { curl.exe -Lo $DenoZip $DenoUri; };  if (Test-CommandExists curl) { tar xf $DenoZip -C $BinDir; } else { tar -Lo $DenoZip $DenoUri; };  Remove-Item $DenoZip;  $User = [EnvironmentVariableTarget]::User; $Path = [Environment]::GetEnvironmentVariable('Path', $User); if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) { [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User); $Env:Path += ";$BinDir"; } }; & "$DenoExe" run -q -A "$PSCommandPath" @args; Exit $LastExitCode; <# 
# */0}`;

const { FileSystem } = await import(`https://deno.land/x/quickr@0.6.15/main/file_system.js`)
const { Console } = await import(`https://deno.land/x/quickr@0.6.15/main/console.js`)
// const { run, throwIfFails, zipInto, mergeInto, returnAsString, Timeout, Env, Cwd, Stdin, Stdout, Stderr, Out, Overwrite, AppendTo } = await import("https://deno.land/x/quickr@0.6.15/main/run.js")
import { parse } from "https://deno.land/std@0.168.0/flags/mod.ts"
const _ = (await import('https://cdn.skypack.dev/lodash'))

const args = parse(Deno.args)

const isNonInteractive = !Deno.isatty(Deno.stdin.rid)

let escapeFind = false
let escapeReplacement = false

if (args.literal) {
    escapeFind = true
    escapeReplacement = true
}

if (args.literalReplacement) {
    escapeReplacement = true
}

let paths = args._

if (isNonInteractive) {
    const content = (new TextDecoder()).decode(await Deno.readAll(Deno.stdin))
    console.log(await replace({
        content,
        find: args.find == null ? args._[0] : args.find,
        replacement: args.replacement == null ? args._[1] : args.replacement,
        escapeFind,
        escapeReplacement,
    }))
} else {
    await Promise.all(
        paths.map(eachPath=>fileReplace({
            filePath: eachPath,
            find: args.find,
            replacement: args.replacement,
            escapeFind,
            escapeReplacement,
        }))
    )
}

async function replace({content, find, replacement, escapeFind, escapeReplacement}) {
    if (escapeFind) {
        find = _.escapeRegExp(find)
    }
    if (escapeReplacement) {
        replacement = replacement.replace(/\$/g,"$$")
    }
    find = new RegExp(find, "g")

    const replaced = content.replace(find, replacement)
    return replaced
}

async function fileReplace({filePath, find, replacement, escapeFind, escapeReplacement}) {
    const content = (await FileSystem.read(filePath))
    if (!content) {
        console.warn(`Can't replace text inside of ${filePath}, because it doesn't seem to be a file`)
    }
    const replaced = replace({content, find, replacement, escapeFind, escapeReplacement})
    if (content != replaced) {
        await FileSystem.write({
            path: filePath,
            data: replaced,
        })
        console.log(`Replacing on: ${filePath}`)
    }
}
// (this comment is part of deno-guillotine, dont remove) #>