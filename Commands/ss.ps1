#!/usr/bin/env sh
"\"",`$(echo --% ' |out-null)" >$null;function :{};function dv{<#${/*'>/dev/null )` 2>/dev/null;dv() { #>
echo "2.1.6"; : --% ' |out-null <#'; }; deno_version="$(dv)"; deno="$HOME/.deno/$deno_version/bin/deno"; if [ -x "$deno" ];then  exec "$deno" run -q -A --no-lock --no-config "$0" "$@";  elif [ -f "$deno" ]; then  chmod +x "$deno" && exec "$deno" run -q -A --no-lock --no-config "$0" "$@"; fi; has () { command -v "$1" >/dev/null; };  set -e;  if ! has unzip && ! has 7z; then echo "Can I try to install unzip for you? (its required for this command to work) ";read ANSWER;echo;  if [ "$ANSWER" =~ ^[Yy] ]; then  if ! has brew; then  brew install unzip; elif has apt-get; then if [ "$(whoami)" = "root" ]; then  apt-get install unzip -y; elif has sudo; then  echo "I'm going to try sudo apt install unzip";read ANSWER;echo;  sudo apt-get install unzip -y;  elif has doas; then  echo "I'm going to try doas apt install unzip";read ANSWER;echo;  doas apt-get install unzip -y;  else apt-get install unzip -y;  fi;  fi;  fi;   if ! has unzip; then  echo ""; echo "So I couldn't find an 'unzip' command"; echo "And I tried to auto install it, but it seems that failed"; echo "(This script needs unzip and either curl or wget)"; echo "Please install the unzip command manually then re-run this script"; exit 1;  fi;  fi;   if ! has unzip && ! has 7z; then echo "Error: either unzip or 7z is required to install Deno (see: https://github.com/denoland/deno_install#either-unzip-or-7z-is-required )." 1>&2; exit 1; fi;  if [ "$OS" = "Windows_NT" ]; then target="x86_64-pc-windows-msvc"; else case $(uname -sm) in "Darwin x86_64") target="x86_64-apple-darwin" ;; "Darwin arm64") target="aarch64-apple-darwin" ;; "Linux aarch64") target="aarch64-unknown-linux-gnu" ;; *) target="x86_64-unknown-linux-gnu" ;; esac fi;  print_help_and_exit() { echo "Setup script for installing deno  Options: -y, --yes Skip interactive prompts and accept defaults --no-modify-path Don't add deno to the PATH environment variable -h, --help Print help " echo "Note: Deno was not installed"; exit 0; };  for arg in "$@"; do case "$arg" in "-h") print_help_and_exit ;; "--help") print_help_and_exit ;; "-"*) ;; *) if [ -z "$deno_version" ]; then deno_version="$arg"; fi ;; esac done; if [ -z "$deno_version" ]; then deno_version="$(curl -s https://dl.deno.land/release-latest.txt)"; fi;  deno_uri="https://dl.deno.land/release/v${deno_version}/deno-${target}.zip"; deno_install="${DENO_INSTALL:-$HOME/.deno/$deno_version}"; bin_dir="$deno_install/bin"; exe="$bin_dir/deno";  if [ ! -d "$bin_dir" ]; then mkdir -p "$bin_dir"; fi;  if has curl; then curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"; elif has wget; then wget --output-document="$exe.zip" "$deno_uri"; else echo "Error: curl or wget is required to download Deno (see: https://github.com/denoland/deno_install )." 1>&2; fi;  if has unzip; then unzip -d "$bin_dir" -o "$exe.zip"; else 7z x -o"$bin_dir" -y "$exe.zip"; fi; chmod +x "$exe"; rm "$exe.zip";  exec "$deno" run -q -A --no-lock --no-config "$0" "$@";     #>}; $DenoInstall = "${HOME}/.deno/$(dv)"; $BinDir = "$DenoInstall/bin"; $DenoExe = "$BinDir/deno.exe"; if (-not(Test-Path -Path "$DenoExe" -PathType Leaf)) { $DenoZip = "$BinDir/deno.zip"; $DenoUri = "https://github.com/denoland/deno/releases/download/v$(dv)/deno-x86_64-pc-windows-msvc.zip";  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;  if (!(Test-Path $BinDir)) { New-Item $BinDir -ItemType Directory | Out-Null; };  Function Test-CommandExists { Param ($command); $oldPreference = $ErrorActionPreference; $ErrorActionPreference = "stop"; try {if(Get-Command "$command"){RETURN $true}} Catch {Write-Host "$command does not exist"; RETURN $false}; Finally {$ErrorActionPreference=$oldPreference}; };  if (Test-CommandExists curl) { curl -Lo $DenoZip $DenoUri; } else { curl.exe -Lo $DenoZip $DenoUri; };  if (Test-CommandExists curl) { tar xf $DenoZip -C $BinDir; } else { tar -Lo $DenoZip $DenoUri; };  Remove-Item $DenoZip;  $User = [EnvironmentVariableTarget]::User; $Path = [Environment]::GetEnvironmentVariable('Path', $User); if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) { [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User); $Env:Path += ";$BinDir"; } }; & "$DenoExe" run -q -A --no-lock --no-config "$PSCommandPath" @args; Exit $LastExitCode; <# 
# */0}`;

import { FileSystem, glob } from "https://deno.land/x/quickr@0.7.0/main/file_system.js"
import { Console, clearAnsiStylesFrom, black, white, red, green, blue, yellow, cyan, magenta, lightBlack, lightWhite, lightRed, lightGreen, lightBlue, lightYellow, lightMagenta, lightCyan, blackBackground, whiteBackground, redBackground, greenBackground, blueBackground, yellowBackground, magentaBackground, cyanBackground, lightBlackBackground, lightRedBackground, lightGreenBackground, lightYellowBackground, lightBlueBackground, lightMagentaBackground, lightCyanBackground, lightWhiteBackground, bold, reset, dim, italic, underline, inverse, strikethrough, gray, grey, lightGray, lightGrey, grayBackground, greyBackground, lightGrayBackground, lightGreyBackground, } from "https://deno.land/x/quickr@0.7.0/main/console.js"
import { zip, enumerate, count, permute, combinations, wrapAroundGet } from "https://deno.land/x/good@1.14.3.0/array.js"
import { parseArgs, flag, required, initialValue } from "https://deno.land/x/good@1.14.3.0/flattened/parse_args.js"
import { toCamelCase } from "https://deno.land/x/good@1.14.3.0/flattened/to_camel_case.js"
import { toSnakeCase } from "https://deno.land/x/good@1.14.3.0/flattened/to_snake_case.js"

var {simplifiedNames: {help}} = parseArgs({
    rawArgs: Deno.args,
    fields: [
        [["--help"], flag],
    ],
})
if (help) {
    console.log(`example:`)
    console.log(`    ss \\`)
    console.log(`       --find '.+'`)
    console.log(`       --name-filter 'path=>path.endsWith(".js")'`)
    console.log(`       --replace '(matchString, { path, absPath, ext, name, basename, parentPath, folders, index, str }, ...groups)=>math.replace("")'`)
    console.log(`       ./*`)
}

var output = parseArgs({
    rawArgs: Deno.args,
    fields: [
        [["--find"], required, (str)=>new RegExp(str, "g")],
        [["--name-filter"], initialValue(()=>true), (str)=>eval(str)],
        [["--dry"], flag],
        [["--replace"], initialValue(null), (str)=>eval(str)],
        [["--print"], initialValue((...args)=>console.log(args[0])), (str)=>eval(str)],
        // [["--explcit-arg1"], initialValue(null), (str)=>parseInt(str)],
    ],
    nameTransformer: toCamelCase,
    namedArgsStopper: "--",
    allowNameRepeats: true,
    valueTransformer: JSON.parse,
    isolateArgsAfterStopper: false,
    argsByNameSatisfiesNumberedArg: true,
    implicitNamePattern: /^(--|-)[a-zA-Z0-9\-_]+$/,
    implictFlagPattern: null,
})
// console.debug(`output.argList is:`,output.argList) // [ 1, 2, 3 ]
// console.debug(`output.simplifiedNames is:`,output.simplifiedNames) // { debug: true, version: false, explcitArg1: NaN, imImplicit: "howdy" } 
// console.debug(`output.field.version is:`,output.field.version) // { debug: true, version: false, explcitArg1: NaN, imImplicit: "howdy" } 
// console.debug(`output.implicitArgsByNumber is:`,output.implicitArgsByNumber) // [1,2,3]
// console.debug(`output.directArgList is:`,output.directArgList)
// console.debug(`output.fields is:`,output.fields)
// console.debug(`output.explicitArgsByName is:`,output.explicitArgsByName)
// console.debug(`output.implicitArgsByName is:`,output.implicitArgsByName)

const args = output.simplifiedNames

await Promise.all(output.argList.map(async (eachPath)=>{
    let info = await FileSystem.info(eachPath)
    if (info.isFile && await args.nameFilter(info.path)) {
        let contents = await FileSystem.read(eachPath)
        const absPath = FileSystem.makeAbsolutePath(eachPath)
        const [ folders, name, itemExtensionWithDot ] = FileSystem.pathPieces(absPath)
        let relativePath =FileSystem.makeRelativePath({from: FileSystem.pwd, to:absPath})
        const argHelp = {
            path: relativePath,
            absPath,
            ext: itemExtensionWithDot,
            name,
            basename: FileSystem.basename(eachPath),
            parentPath: FileSystem.parentPath(absPath),
            folders: folders.filter(each=>each.length),
        }
        if (args.replace) {
            let replaceCount = 0
            contents = contents.replaceAll(args.find, (g0,...groupsAndOther)=>{
                const [ index, str ] = groupsAndOther.splice(-2,2)
                replaceCount++
                let output = args.replace(g0, {...argHelp, index, str}, ...groupsAndOther)
                if (args.dry) {
                    const lineNumber = str.slice(0,index).split(/\n/g).length
                    console.log(`from: "${green(JSON.stringify(g0).slice(1,-1))}", to: "${cyan(JSON.stringify(output).slice(1,-1))}", at: ${JSON.stringify(relativePath+":"+lineNumber)}`)
                }
            })
            if (!args.dry) {
                await FileSystem.write({
                    path: info.path,
                    data: contents,
                })
                console.log(`replaced ${green(replaceCount)} in ${cyan(info.path)}`)
            }
        } else {
            contents.replaceAll(args.find, (...argss)=>{
                return args.print(argss.shift(), argHelp, ...argss)
            })
        }
    }
}))
// (this comment is part of deno-guillotine, dont remove) #>