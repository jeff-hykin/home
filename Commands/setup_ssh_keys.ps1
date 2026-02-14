#!/usr/bin/env sh
"\"",`$(echo --% ' |out-null)" >$null;function :{};function getDenoVersion{<#${/*'>/dev/null )` 2>/dev/null;getDenoVersion() { #>
echo "2.5.3";: --% ' |out-null <#';};DENO_INSTALL="$HOME/.deno/$(getDenoVersion)";deno_version="v$(getDenoVersion)";deno="$DENO_INSTALL/bin/deno";target_script="$0";disable_url_run="";if [ -n "$url_" ] && [ -z "$disable_url_run" ];then if [ "${url_#http}" = "$url_" ];then url_="https://$url_";fi;target_script="$url_";fi;if [ -x "$deno" ];then exec "$deno" run -q -A --no-lock --no-config "$target_script" "$@";elif [ -f "$deno" ];then chmod +x "$deno" && exec "$deno" run -q -A --no-lock --no-config "$target_script" "$@";fi;has () { command -v "$1" >/dev/null;};if ! has curl;then if ! has wget;then curl () { wget --output-document="$5" "$6";};else echo "Sorry this script needs curl or wget, please install one or the other and re-run";exit 1;fi;fi;if [ "$(uname)" = "Darwin" ];then unzip () { /usr/bin/tar xvf "$4" -C "$2" 2>/dev/null 1>/dev/null;};fi;if ! has unzip && ! has 7z;then echo "Either the unzip or 7z command are needed for this script";echo "Should I try to install unzip for you?";read ANSWER;echo;if [ "$ANSWER" =~ ^[Yy] ];then if has nix-shell;then unzip_path="$(NIX_PATH='nixpkgs=https://github.com/NixOS/nixpkgs/archive/release-25.05.tar.gz' nix-shell -p unzip which --run "which unzip")" alias unzip="$unzip_path" else;if has apt-get;then _install="apt-get install unzip -y";elif has dnf;then _install="dnf install unzip -y";elif has pacman;then _install="pacman -S --noconfirm unzip";else echo "Sorry, I don't know how to install unzip on this system";echo "Please install unzip manually and re-run this script";exit 1;fi;if [ "$(whoami)" = "root" ];then "$_install";elif has sudo;then sudo "$_install";elif has doas;then doas "$_install";else "$_install";fi;fi;fi;if ! has unzip;then echo "";echo "So I couldn't find an 'unzip' or '7z' command";echo "And I tried to auto install unzip, but it seems that failed";echo "Please install the unzip or 7z command manually then re-run this script";exit 1;fi;fi;if ! command -v unzip >/dev/null && ! command -v 7z >/dev/null;then echo "Error: either unzip or 7z is required to install Deno (see: https://github.com/denoland/deno_install#either-unzip-or-7z-is-required )." 1>&2;exit 1;fi;if [ "$OS" = "Windows_NT" ];then target="x86_64-pc-windows-msvc";else case $(uname -sm) in "Darwin x86_64") target="x86_64-apple-darwin" ;;"Darwin arm64") target="aarch64-apple-darwin" ;;"Linux aarch64") target="aarch64-unknown-linux-gnu" ;;*) target="x86_64-unknown-linux-gnu" ;;esac fi;deno_uri="https://dl.deno.land/release/${deno_version}/deno-${target}.zip";deno_install="${DENO_INSTALL:-$HOME/.deno}";bin_dir="$deno_install/bin";exe="$bin_dir/deno";if [ ! -d "$bin_dir" ];then mkdir -p "$bin_dir";fi;curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri";if command -v unzip >/dev/null;then unzip -d "$bin_dir" -o "$exe.zip";else 7z x -o"$bin_dir" -y "$exe.zip";fi;chmod +x "$exe";rm "$exe.zip";exec "$deno" run -q -A --no-lock --no-config "$target_script" "$@";#>};$DenoInstall = "${HOME}/.deno/$(getDenoVersion)";$BinDir = "$DenoInstall/bin";$DenoExe = "$BinDir/deno.exe";$TargetScript = "$PSCommandPath";$DisableUrlRun = "";if ($url_ -and -not($DisableUrlRun)) { if (-not($url -match '^http')) { $url_="https://$url_";} $TargetScript = "$url_";};if (-not(Test-Path -Path "$DenoExe" -PathType Leaf)) { $DenoZip = "$BinDir/deno.zip";$DenoUri = "https://github.com/denoland/deno/releases/download/v$(getDenoVersion)/deno-x86_64-pc-windows-msvc.zip";[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;if (!(Test-Path $BinDir)) { New-Item $BinDir -ItemType Directory | Out-Null;};curl.exe --ssl-revoke-best-effort -Lo $DenoZip $DenoUri;tar.exe xf $DenoZip -C $BinDir;Remove-Item $DenoZip;};& "$DenoExe" run -q -A --no-lock --no-config "$TargetScript" @args;Exit $LastExitCode;<# 
# */0}`;
import { run, Timeout, Env, Cwd, Stdin, Stdout, Stderr, Out, Overwrite, AppendTo, zipInto, mergeInto, returnAsString, } from "https://deno.land/x/quickr@0.6.63/main/run.js"
import { FileSystem } from "https://deno.land/x/quickr@0.6.63/main/file_system.js"
import { Console, cyan, white } from "https://deno.land/x/quickr@0.6.63/main/console.js"

const sshFolder = `${FileSystem.home}/.ssh/`
const authorizedKeysPath = `${FileSystem.home}/.ssh/authorized_keys`
const defaultPrivateKeyPath = `${sshFolder}/id_rsa`
const defaultPublicKeyPath = `${sshFolder}/id_rsa.pub`
const configPath = `${sshFolder}/config`

// ssh-keygen -t rsa
// cat "$HOME/.ssh/id_rsa.pub"
// - paste into github
// git clone ssh_url

// 
// 
// main 
// 
// 
await verifyAndSetupSshFolderStructure()
console.log(`

    __________________      __________________
    | "Your" Machine |  ->  | Remote Machine | 
    ------------------      ------------------  

`)
if (await Console.askFor.yesNo("Is this script running on your machine right now?")) {
    await ensurePrivatePublicRsaKeyExistsWithCorrectPermissions()
    console.log("\nOkay, now run this same script on the remote server")
    console.log("Paste the value below when it asks for your public key")
    console.log()
    console.log("(and FYI you can show this to anyone, its not private)")
    console.log()
    console.log(cyan.blackBackground(await FileSystem.read(defaultPublicKeyPath)))
    console.log()
    console.log()
} else {
    let publicKeyString = ""
    while (publicKeyString.length == 0) {
        publicKeyString = await Console.askFor.line(`Whats the public key of your machine?\n(run this script on your machine to get it)`)
    }
    await FileSystem.append({
        path: authorizedKeysPath,
        data: publicKeyString+"\n",
    })
    // TODO: assumes debian/ubuntu
    if (await Console.askFor.yesNo(`Would you like to restart ssh to make the change take effect?`)) {
        await run("sudo", "systemctl", "restart", "ssh.service")
    }
}

function escapeShellArgument(string) {
    return `'${string.replace(/'/,`'"'"'`)}'`
}

async function ensurePrivatePublicRsaKeyExistsWithCorrectPermissions() {
    let privateKey = await FileSystem.info(defaultPrivateKeyPath)
    let publicKey = await FileSystem.info(defaultPublicKeyPath)
    while (!privateKey.isFile || !publicKey.isFile) {
        console.log(`Checking...`)
        console.log(`    Default private key exists (${defaultPrivateKeyPath})? ${privateKey.isFile}`)
        console.log(`    Default public key exists (${defaultPublicKeyPath})? ${publicKey.isFile}`)
        console.log("\nLooks like your default key pair doesn't exist")
        if (!(await Console.askFor.yesNo(`Would you like to create them?`))) {
            console.log(`okay, exiting program`)
            return
        }
        console.log(white.blackBackground`    running: `.cyan`ssh-keygen -t rsa`)
        await run("ssh-keygen", "-t", "rsa", "-f", defaultPrivateKeyPath)
        privateKey = await FileSystem.info(defaultPrivateKeyPath)
        publicKey = await FileSystem.info(defaultPublicKeyPath)
    }
    // ensure permissions are correct
    await FileSystem.addPermissions({
        path: publicKey,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: false,
            }, 
            group:{
                canRead: true,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: true,
                canWrite: false,
                canExecute: false,

            }
        },
    })
    // ensure permissions are correct
    await FileSystem.addPermissions({
        path: privateKey,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: false,
            }, 
            group:{
                canRead: false,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: false,
                canWrite: false,
                canExecute: false,

            }
        },
    })
}

async function getFingerprint(path=defaultPublicKeyPath) {
    return run("ssh-keygen", "-lf", path, Stdout(returnAsString))
}

async function verifyAndSetupSshFolderStructure() {
    console.log(`Verifying folder structure and permissions`)
    await FileSystem.ensureIsFolder(sshFolder)
    const authInfo = await FileSystem.info(authorizedKeysPath)
    if (!authInfo.exists) {
        await Deno.writeTextFile(authorizedKeysPath, "")
    }
    // following: https://superuser.com/a/925859/399438

    // SSH folder on the server needs 700 permissions: chmod 700 $HOME/.ssh
    await FileSystem.addPermissions({
        path: sshFolder,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: true,
            }, 
            group:{
                canRead: true,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: true,
                canWrite: false,
                canExecute: false,

            }
        },
    })
    
    // sudo chmod 600 ~/.ssh/config
    const configInfo = await FileSystem.info(configPath)
    if (!configInfo.exists) {
        await FileSystem.write({
            data: `# Read more about SSH config files: https://linux.die.net/man/5/ssh_config\n# Host alias\n#     HostName hostname\n#     User user\n`,
            path: configPath,
        })
    }
    await FileSystem.addPermissions({
        path: configPath,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: false,
            }, 
            group:{
                canRead: false,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: false,
                canWrite: false,
                canExecute: false,

            }
        },
    })
    const permissions = await FileSystem.getPermissions({path: configPath,})

    // authorized_keys file needs 644 permissions: chmod 644 $HOME/.ssh/authorized_keys
    await FileSystem.addPermissions({
        path: authorizedKeysPath,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: false,
            }, 
            group:{
                canRead: true,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: true,
                canWrite: false,
                canExecute: false,

            }
        },
    })
    
    // all individual keys
    for (const [publicKeyPath, privateKeyPath] of await findAllKeyPairs(`${FileSystem.home}/.ssh/`)) {
        console.log(`    found key: ${publicKeyPath} ... validating permissions`)
        await fixPermissionsOnKeyPairs(privateKeyPath, publicKeyPath)
    }

    // Make sure that user owns the files/folders and not root: chown user:user authorized_keys and chown user:user /home/$USER/.ssh
    const username = (await run("whoami", Stdout(returnAsString))).trim()
    const userId = (await run("id", "-u", username, Stdout(returnAsString))).trim()
    const { uid } = await Deno.lstat(sshFolder)
    if (`${userId}` !== `${uid}`) {
        console.log(`\nFor some reason you're not the owner of your own home/.ssh/ folder (strange)`)
        console.log(`    your  username: ${username}`)
        // console.log(`    owner username: ${fileOwner}`) // currently don't have folder owner name
        console.log(`Lets change that:\n`)
        await run("sudo", "chown", username, sshFolder)
    }
}

async function fixPermissionsOnKeyPairs(privateKey, publicKey) {
    // ensure permissions are correct
    await FileSystem.addPermissions({
        path: publicKey,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: false,
            }, 
            group:{
                canRead: true,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: true,
                canWrite: false,
                canExecute: false,

            }
        },
    })
    // ensure permissions are correct
    await FileSystem.addPermissions({
        path: privateKey,
        permissions: {
            owner:{
                canRead: true,
                canWrite: true,
                canExecute: false,
            }, 
            group:{
                canRead: false,
                canWrite: false,
                canExecute: false,
            },
            others:{
                canRead: false,
                canWrite: false,
                canExecute: false,

            }
        },
    })
}

/**
 * @example
 *     ```js
 *     for (const [publicKeyPath, privateKeyPath] of await findAllKeyPairs(`${FileSystem.home}/.ssh/`)) {
 *        console.log(publicKeyPath)
 *        console.log(privateKeyPath)
 *     } 
 *     ```
 *
 */
async function findAllKeyPairs(sshFolder) {
    var pubKeyNames = []
    var noPubNames = []
    for (const eachFileInfo of await FileSystem.listFileItemsIn(sshFolder)) {
        if (eachFileInfo.path.endsWith(".pub")) {
            pubKeyNames.push(eachFileInfo.name)
        } else {
            noPubNames.push(eachFileInfo.basename)
        }
    }
    const keyPairs = pubKeyNames.filter(each=>noPubNames.includes(each)).map(each=>[ `${sshFolder}/${each}`, `${sshFolder}/${each}.pub` ])
    return keyPairs
}
// (this comment is part of universify, dont remove) #>