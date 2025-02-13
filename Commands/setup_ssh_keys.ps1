#!/usr/bin/env sh
"\"",`$(echo --% ' |out-null)" >$null;function :{};function dv{<#${/*'>/dev/null )` 2>/dev/null;dv() { #>
echo "1.41.3"; : --% ' |out-null <#'; }; version="$(dv)"; deno="$HOME/.deno/$version/bin/deno"; if [ -x "$deno" ]; then  exec "$deno" run -q -A --no-lock "$0" "$@";  elif [ -f "$deno" ]; then  chmod +x "$deno" && exec "$deno" run -q -A --no-lock "$0" "$@";  fi; bin_dir="$HOME/.deno/$version/bin"; exe="$bin_dir/deno"; has () { command -v "$1" >/dev/null; } ;  if ! has unzip; then if ! has apt-get; then  has brew && brew install unzip; else  if [ "$(whoami)" = "root" ]; then  apt-get install unzip -y; elif has sudo; then  echo "Can I install unzip for you? (its required for this command to work) ";read ANSWER;echo;  if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "yes" ] || [ "$ANSWER" = "Y" ]; then  sudo apt-get install unzip -y; fi; elif has doas; then  echo "Can I install unzip for you? (its required for this command to work) ";read ANSWER;echo;  if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "yes" ] || [ "$ANSWER" = "Y" ]; then  doas apt-get install unzip -y; fi; fi;  fi;  fi;  if ! has unzip; then  echo ""; echo "So I couldn't find an 'unzip' command"; echo "And I tried to auto install it, but it seems that failed"; echo "(This script needs unzip and either curl or wget)"; echo "Please install the unzip command manually then re-run this script"; exit 1;  fi;  repo="denoland/deno"; if [ "$OS" = "Windows_NT" ]; then target="x86_64-pc-windows-msvc"; else :;  case $(uname -sm) in "Darwin x86_64") target="x86_64-apple-darwin" ;; "Darwin arm64") target="aarch64-apple-darwin" ;; "Linux aarch64") repo="LukeChannings/deno-arm64" target="linux-arm64" ;; "Linux armhf") echo "deno sadly doesn't support 32-bit ARM. Please check your hardware and possibly install a 64-bit operating system." exit 1 ;; *) target="x86_64-unknown-linux-gnu" ;; esac; fi; deno_uri="https://github.com/$repo/releases/download/v$version/deno-$target.zip"; exe="$bin_dir/deno"; if [ ! -d "$bin_dir" ]; then mkdir -p "$bin_dir"; fi;  if ! curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"; then if ! wget --output-document="$exe.zip" "$deno_uri"; then echo "Howdy! I looked for the 'curl' and for 'wget' commands but I didn't see either of them. Please install one of them, otherwise I have no way to install the missing deno version needed to run this code"; exit 1; fi; fi; unzip -d "$bin_dir" -o "$exe.zip"; chmod +x "$exe"; rm "$exe.zip"; exec "$deno" run -q -A --no-lock "$0" "$@"; #>}; $DenoInstall = "${HOME}/.deno/$(dv)"; $BinDir = "$DenoInstall/bin"; $DenoExe = "$BinDir/deno.exe"; if (-not(Test-Path -Path "$DenoExe" -PathType Leaf)) { $DenoZip = "$BinDir/deno.zip"; $DenoUri = "https://github.com/denoland/deno/releases/download/v$(dv)/deno-x86_64-pc-windows-msvc.zip";  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;  if (!(Test-Path $BinDir)) { New-Item $BinDir -ItemType Directory | Out-Null; };  Function Test-CommandExists { Param ($command); $oldPreference = $ErrorActionPreference; $ErrorActionPreference = "stop"; try {if(Get-Command "$command"){RETURN $true}} Catch {Write-Host "$command does not exist"; RETURN $false}; Finally {$ErrorActionPreference=$oldPreference}; };  if (Test-CommandExists curl) { curl -Lo $DenoZip $DenoUri; } else { curl.exe -Lo $DenoZip $DenoUri; };  if (Test-CommandExists curl) { tar xf $DenoZip -C $BinDir; } else { tar -Lo $DenoZip $DenoUri; };  Remove-Item $DenoZip;  $User = [EnvironmentVariableTarget]::User; $Path = [Environment]::GetEnvironmentVariable('Path', $User); if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) { [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User); $Env:Path += ";$BinDir"; } }; & "$DenoExe" run -q -A --no-lock "$PSCommandPath" @args; Exit $LastExitCode; <# 
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
// (this comment is part of deno-guillotine, dont remove) #>