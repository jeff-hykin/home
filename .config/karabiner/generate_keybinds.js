import { FileSystem, glob } from "https://deno.land/x/quickr@0.6.47/main/file_system.js"

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
    'semicolon',
    'quote',
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
    "title": "Hold Space for ijkl arrow keys and more",
    "rules": [
        {
            "description": "Hold Space for ijkl arrow keys and more",
            "manipulators": [

                // 
                // 
                // ijkl
                // 
                // 
                    ...whenLayers({
                        layerValues: {
                            spacebar_layer: 1,
                            semicolon_layer: 0,
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
                            }
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
                        // comma jump
                        // 
                            {
                                "from": {
                                    "key_code": "period",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "period",
                                        "modifiers": [
                                            "left_alt"
                                        ]
                                    }
                                ],
                            },
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
                                        "key_code": "comma",
                                        "modifiers": [
                                            "left_alt"
                                        ]
                                    }
                                ],
                            },
                        ],
                    }),
                // 
                // backspace
                // 
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "0",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to": [
                            {
                                "key_code": "delete_or_backspace"
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
                
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
                                "name": "semicolon_layer pressed",
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
                                "name": "semicolon_layer pressed",
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
                // bracket jump
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
                                "key_code": "close_bracket",
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
                                "name": "semicolon_layer pressed",
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
                                "key_code": "open_bracket",
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
                                "name": "semicolon_layer pressed",
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