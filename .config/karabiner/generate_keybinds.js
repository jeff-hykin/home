#!/usr/bin/env sh
"\"",`$(echo --% ' |out-null)" >$null;function :{};function dv{<#${/*'>/dev/null )` 2>/dev/null;dv() { #>
echo "1.31.3"; : --% ' |out-null <#';};v="$(dv)";d="$HOME/.deno/$v/bin/deno";if [ -x "$d" ];then exec "$d" run --no-lock -q -A "$0" "$@";elif [ -f "$d" ];then chmod +x "$d" && exec "$d" run --no-lock -q -A "$0" "$@";fi;bin_dir="$HOME/.deno/$v/bin";exe="$bin_dir/deno";has() { command -v "$1" >/dev/null; };if ! has unzip;then :;if ! has apt-get;then has brew && brew install unzip;else if [ "$(whoami)" = "root" ];then apt-get install unzip -y;elif has sudo;then echo "Can I install unzip for you? (its required for this command to work) ";read ANSWER;echo;if [ "$ANSWER" =~ ^[Yy] ];then sudo apt-get install unzip -y;fi;elif has doas;then echo "Can I install unzip for you? (its required for this command to work) ";read ANSWER;echo;if [ "$ANSWER" =~ ^[Yy] ];then doas apt-get install unzip -y;fi;fi;fi;fi;if ! has unzip;then echo "";echo "So I couldn't find an 'unzip' command";echo "And I tried to auto install it, but it seems that failed";echo "(This script needs unzip and either curl or wget)";echo "Please install the unzip command manually then re-run this script";exit 1;fi;if [ "$OS" = "Windows_NT" ];then target="x86_64-pc-windows-msvc";else :; case $(uname -sm) in "Darwin x86_64") target="x86_64-apple-darwin" ;; "Darwin arm64") target="aarch64-apple-darwin" ;; *) target="x86_64-unknown-linux-gnu" ;; esac;fi;deno_uri="https://github.com/denoland/deno/releases/download/v$v/deno-$target.zip";if [ ! -d "$bin_dir" ];then mkdir -p "$bin_dir";fi;if has curl;then curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri";elif has wget;then wget --output-document="$exe.zip" "$deno_uri";else echo "Howdy! I looked for the 'curl' and for 'wget' commands but I didn't see either of them.";echo "Please install one of them";echo "Otherwise I have no way to install the missing deno version needed to run this code";fi;unzip -d "$bin_dir" -o "$exe.zip";chmod +x "$exe";rm "$exe.zip";exec "$d" run --no-lock -q -A "$0" "$@"; #>}; $DenoInstall = "${HOME}/.deno/$(dv)"; $BinDir = "$DenoInstall/bin"; $DenoExe = "$BinDir/deno.exe"; if (-not(Test-Path -Path "$DenoExe" -PathType Leaf)) { $DenoZip = "$BinDir/deno.zip"; $DenoUri = "https://github.com/denoland/deno/releases/download/v$(dv)/deno-x86_64-pc-windows-msvc.zip"; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; if (!(Test-Path $BinDir)) { New-Item $BinDir -ItemType Directory | Out-Null; } Function Test-CommandExists { Param ($command); $oldPreference = $ErrorActionPreference; $ErrorActionPreference = "stop"; try {if(Get-Command "$command"){RETURN $true}} Catch {Write-Host "$command does not exist"; RETURN $false} Finally {$ErrorActionPreference=$oldPreference}; } if (Test-CommandExists curl) { curl -Lo $DenoZip $DenoUri; } else { curl.exe -Lo $DenoZip $DenoUri; } if (Test-CommandExists curl) { tar xf $DenoZip -C $BinDir; } else { tar.exe   xf $DenoZip -C $BinDir; } Remove-Item $DenoZip; $User = [EnvironmentVariableTarget]::User; $Path = [Environment]::GetEnvironmentVariable('Path', $User); if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) { [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User); $Env:Path += ";$BinDir"; } }; & "$DenoExe" run --no-lock -q -A "$PSCommandPath" @args; Exit $LastExitCode; <#
# */0}`;
import { FileSystem, glob } from "https://deno.land/x/quickr@0.6.47/main/file_system.js"

// https://genesy.github.io/karabiner-complex-rules-generator/

const leftOrRight = (name)=> [`left_${name}`, `right_${name}`]

const letterKeys = [
    ..."qwertyuiop",
    ..."asdfghjkl",
    ..."zxcvbnm",
]
const numberKeys = [
    ..."1234567890",
]
const modifiers = [
    ...leftOrRight("alt"),
    ...leftOrRight("control"),
    ...leftOrRight("shift"),
    ...leftOrRight("gui"), // CMD
    "fn",
]

const layerKeys = [
    'quote',
    'period',
]
const layerInteractionKeys = Object.fromEntries(layerKeys.map(each=>[`${each}_layer`, []]))
layerInteractionKeys["spacebar_layer"] = []
const whenLayers = ({layerValues, keyBehaviors,})=>{
    const outputRules = []
    for (let {from, to, conditions} of keyBehaviors) {
        conditions = conditions||[]
        for (const [key, value] of Object.entries(layerValues)) {
            if (value) {
                layerInteractionKeys[key].push(from['key_code'])
            }
            conditions.push({
                "type": "variable_if",
                "name": `${key} pressed`,
                "value": value,
            })
        }
        outputRules.push({
            type: 'basic',
            from,
            to,
            conditions,
        })
    }
    return outputRules
}
const layerKeyShiftFixer = ({ layer, keys, conditions }) => {
    const keyShiftHelper = ({ shiftOfLayerInput, shiftOfKeyInput, key })=>
        leftOrRight("shift").map(shift=>
            ({
                "type": "basic",
                "from": {
                    "key_code": key,
                    "modifiers": {
                        ...(
                            shiftOfKeyInput ?
                                { mandatory: [ shift ] }
                            :
                                { optional: modifiers.filter(each=>!each.match(/shift/)) }
                        ),
                    }
                },
                "to": [
                    {
                        "key_code": "quote",
                        ...(
                            shiftOfLayerInput ?
                                { modifiers: [ shift ] }
                            :
                                {}
                        ),
                    },
                    {
                        "key_code": key,
                        ...(
                            shiftOfKeyInput ?
                                { modifiers: [ shift ] }
                            :
                                {}
                        ),
                    },
                    // "consume" the quote button
                    {
                        "set_variable": {
                            "name": `${layer}_layer pressed`,
                            "value": 0
                        }
                    },
                    {
                        "set_variable": {
                            "name": `${layer}_shift_layer pressed`,
                            "value": 0,
                        }
                    },
                ],
                "conditions": [
                    {
                        "type": "variable_if",
                        "name": `${layer}_layer pressed`,
                        "value": 1
                    },
                    {
                        "type": "variable_if",
                        "name": `${layer}_shift_layer pressed`,
                        "value": shiftOfLayerInput ? 1 : 0,
                    },
                    ...conditions
                ] 
            })
        )
    
    const output =  keys.map(each=>[
        keyShiftHelper({ key:each, shiftOfLayerInput: true, shiftOfKeyInput: true }),
        keyShiftHelper({ key:each, shiftOfLayerInput: true, shiftOfKeyInput: false }),
        keyShiftHelper({ key:each, shiftOfLayerInput: false, shiftOfKeyInput: true }),
        keyShiftHelper({ key:each, shiftOfLayerInput: false, shiftOfKeyInput: false }),
    ])
    return output.flat(Infinity)
}

const karabinerMapping = {
    "title": `Hold Space for ijkl arrow keys and more: ${Math.random()}`,
     "rules": [
        {
            "description": "Hold Space for ijkl arrow keys and more" ,
            "manipulators": [

                // 
                // 
                // ijkl
                // 
                // 
                    ...whenLayers({
                        layerValues: {
                            spacebar_layer: 1,
                            period_layer: 0,
                            quote_layer: 0,
                        },
                        keyBehaviors: [
                            {
                                "from": {
                                    "key_code": "j",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_arrow"
                                    }
                                ],
                            },
                            {
                                "from": {
                                    "key_code": "k",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "down_arrow"
                                    }
                                ],
                            },
                            {
                                "from": {
                                    "key_code": "l",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_arrow"
                                    }
                                ],
                            },
                            {
                                "from": {
                                    "key_code": "i",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "up_arrow"
                                    }
                                ],
                            },
                            // {
                            //     "from": {
                            //         "key_code": "h",
                            //         "modifiers": {
                            //             "mandatory": [
                            //                 "left_shift",
                            //             ]
                            //         }
                            //     },
                            //     "to": [
                            //         {
                            //             "key_code": "hyphen",
                            //             "modifiers": [
                            //             ],
                            //         }
                            //     ],
                            // },
                            // {
                            //     "from": {
                            //         "key_code": "h",
                            //         "modifiers": {
                            //             "optional": modifiers.filter(each=>!each.endsWith("_shift")),
                            //         }
                            //     },
                            //     "to": [
                            //         {
                            //             "key_code": "hyphen",
                            //             "modifiers": [
                            //                 "left_shift", 
                            //             ],
                            //         }
                            //     ],
                            // },
                        ],
                    }),
                //
                // spacebar layer
                //
                    ...whenLayers({
                        layerValues: {
                            spacebar_layer: 1,
                        },
                        keyBehaviors: [
                            // 
                            //  dash and underscore
                            // 
                            {
                                "from": {
                                    "key_code": "n",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "hyphen",
                                        "modifiers": [
                                            "left_shift"
                                        ]
                                    }
                                ],
                            },
                            {
                                "from": {
                                    "key_code": "m",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "hyphen",
                                    }
                                ],
                            },
                            // 
                            // plus equals
                            // 
                            {
                                "from": {
                                    "key_code": "comma",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "equal_sign",
                                    }
                                ],
                            }
                            // 
                            //  brackets 
                            // 
                            {
                                "from": {
                                    "key_code": "u",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "open_bracket"
                                    }
                                ],
                            },
                            {
                                "from": {
                                    "key_code": "o",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "close_bracket"
                                    }
                                ],
                            },

                            // 
                            // cursor undo
                            // 
                                {
                                    "from": {
                                        "key_code": "z",
                                        "modifiers": {
                                            "optional": [
                                                "any"
                                            ]
                                        }
                                    },
                                    "to": [
                                        {
                                            "key_code": "z",
                                            "modifiers": [
                                                "left_alt"
                                            ]
                                        }
                                    ],
                                },
                            
                        // 
                        // alternative backspace
                        //
                            {
                                "from": {
                                    "key_code": "semicolon",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "delete_or_backspace",
                                    }
                                ],
                            },
                        ],
                    }),
                // 
                // quote jump
                // 
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "l",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to": [
                            {
                                "key_code": "quote",
                                "modifiers": [
                                    "left_alt"
                                ]
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "period_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "j",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to": [
                            {
                                "key_code": "semicolon",
                                "modifiers": [
                                    "left_alt"
                                ]
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "period_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
                // 
                // period jump
                // 
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "l",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to": [
                            {
                                "key_code": "quote",
                                "modifiers": [
                                    "left_alt"
                                ]
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "period_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "j",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to": [
                            {
                                "key_code": "comma",
                                "modifiers": [
                                    "left_alt"
                                ]
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "period_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
                // 
                // bracket jump
                // 
                    // {
                    //     "type": "basic",
                    //     "from": {
                    //         "key_code": "l",
                    //         "modifiers": {
                    //             "optional": [
                    //                 "any"
                    //             ]
                    //         }
                    //     },
                    //     "to": [
                    //         {
                    //             "key_code": "close_bracket",
                    //             "modifiers": [
                    //                 "left_alt"
                    //             ]
                    //         }
                    //     ],
                    //     "conditions": [
                    //         {
                    //             "type": "variable_if",
                    //             "name": "quote_layer pressed",
                    //             "value": 0
                    //         },
                    //         {
                    //             "type": "variable_if",
                    //             "name": "period_layer pressed",
                    //             "value": 1
                    //         },
                    //         {
                    //             "type": "variable_if",
                    //             "name": "spacebar_layer pressed",
                    //             "value": 1
                    //         }
                    //     ]
                    // },
                    // {
                    //     "type": "basic",
                    //     "from": {
                    //         "key_code": "j",
                    //         "modifiers": {
                    //             "optional": [
                    //                 "any"
                    //             ]
                    //         }
                    //     },
                    //     "to": [
                    //         {
                    //             "key_code": "open_bracket",
                    //             "modifiers": [
                    //                 "left_alt"
                    //             ]
                    //         }
                    //     ],
                    //     "conditions": [
                    //         {
                    //             "type": "variable_if",
                    //             "name": "quote_layer pressed",
                    //             "value": 0
                    //         },
                    //         {
                    //             "type": "variable_if",
                    //             "name": "period_layer pressed",
                    //             "value": 1
                    //         },
                    //         {
                    //             "type": "variable_if",
                    //             "name": "spacebar_layer pressed",
                    //             "value": 1
                    //         }
                    //     ]
                    // },
                // 
                // disable stuff
                // 
                    // 
                    // disable underscore
                    // 
                        //  {
                        //     "type": "basic",
                        //     "from": {
                        //         "key_code": "hyphen",
                        //         "modifiers": [
                        //             "left_shift", 
                        //         ],
                        //     },
                        //     "to": [
                        //         {
                        //             "key_code": "vk_none",
                        //         }
                        //     ],
                        //     "conditions": [
                        //     ]
                        // },
                // 
                // fixers / layer-avoiders
                // 
                    ...layerKeyShiftFixer({
                        layer: "quote",
                        keys: letterKeys,
                        conditions: [
                             {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 0
                            },
                        ]
                    }),
                // 
                // layers
                // 
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "spacebar",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to_if_alone": [
                            {
                                "key_code": "spacebar"
                            }
                        ],
                        "to": [
                            {
                                "set_variable": {
                                    "name": "spacebar_layer pressed",
                                    "value": 1
                                }
                            }
                        ],
                        "to_after_key_up": [
                            {
                                "set_variable": {
                                    "name": "spacebar_layer pressed",
                                    "value": 0
                                }
                            }
                        ]
                    },
                    ...layerKeys.map(eachKey=>[
                        {
                            "type": "basic",
                            "from": {
                                "key_code": eachKey,
                                "modifiers": {
                                    "optional": [
                                        ...modifiers.filter(each=>!each.match(/shift/))
                                    ]
                                }
                            },
                            "to_if_alone": [
                                {
                                    "key_code": eachKey,
                                }
                            ],
                            "to": [
                                {
                                    "set_variable": {
                                        "name": `${eachKey}_layer pressed`,
                                        "value": 1
                                    }
                                }
                            ],
                            "to_after_key_up": [
                                {
                                    "set_variable": {
                                        "name": `${eachKey}_layer pressed`,
                                        "value": 0
                                    }
                                }
                            ]
                        },
                        ...leftOrRight('shift').map(shift=>({

                            "type": "basic",
                            "from": {
                                "key_code": eachKey,
                                "modifiers": {
                                    "mandatory": [
                                        shift
                                    ]
                                }
                            },
                            "to_if_alone": [
                                {
                                    "key_code": eachKey,
                                    modifiers: [
                                        shift,
                                    ]
                                }
                            ],
                            "to": [
                                {
                                    "set_variable": {
                                        "name": `${eachKey}_layer pressed`,
                                        "value": 1
                                    }
                                },
                                {
                                    "set_variable": {
                                        "name": `${eachKey}_shift_layer pressed`,
                                        "value": 1
                                    }
                                }
                            ],
                            "to_after_key_up": [
                                {
                                    "set_variable": {
                                        "name": `${eachKey}_layer pressed`,
                                        "value": 0
                                    }
                                },
                                {
                                    "set_variable": {
                                        "name": `${eachKey}_shift_layer pressed`,
                                        "value": 0
                                    }
                                }
                            ],
                        }))
                    ]).flat(Infinity),
             ]
        }
    ]
}

console.log(`writing file`)
await FileSystem.write({
    data:JSON.stringify(karabinerMapping, 0, 4),
    path: `${FileSystem.home}/.config/karabiner/assets/complex_modifications/1695750720.json` 
})
// (this comment is part of deno-guillotine, dont remove) #>