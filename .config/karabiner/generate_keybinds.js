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
    'spacebar',
    'semicolon',
    'quote',
]
const layerInteractionKeys = Object.fromEntries(layerKeys.map(each=>[`${each}_layer`, []]))
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
const layerKeyShiftFixer = ({ layer, keys, conditions })=>{
    const keyShiftHelper = ({ shiftOfLayerInput, shiftOfKeyInput,  })=>
        leftOrRight("shift").map(shift=>
            ({
                "type": "basic",
                "from": {
                    "key_code": each,
                    "modifiers": {
                        ...(
                            shiftOfKeyInput ?
                                { mandatory: [ shiftKey ] }
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
                                { modifiers: [ shiftKey ] }
                            :
                                {}
                        ),
                    },
                    {
                        "key_code": each,
                        ...(
                            shiftOfKeyInput ?
                                { modifiers: [ shiftKey ] }
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

    return keys.map(each=>[
        keyShiftHelper({ shiftOfLayerInput: true, shiftOfKeyInput: true }),
        keyShiftHelper({ shiftOfLayerInput: true, shiftOfKeyInput: false }),
        keyShiftHelper({ shiftOfLayerInput: false, shiftOfKeyInput: true }),
        keyShiftHelper({ shiftOfLayerInput: false, shiftOfKeyInput: false }),
    ]) 
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
                    ...[
                        letterKeys.map(each=>({
                            "type": "basic",
                            "from": {
                                "key_code": each,
                                "modifiers": {
                                    "optional": [
                                        ...modifiers.filter(each=>!each.match(/shift/))
                                    ]
                                }
                            },
                            "to": [
                                {
                                    "key_code": "quote",
                                },
                                {
                                    "key_code": each,
                                },
                                // "consume" the quote button
                                {
                                    "set_variable": {
                                        "name": "quote_layer pressed",
                                        "value": 0
                                    }
                                },
                                {
                                    "set_variable": {
                                        "name": "quote_shift_layer pressed",
                                        "value": 0
                                    }
                                },
                            ],
                            "conditions": [
                                {
                                    "type": "variable_if",
                                    "name": "quote_layer pressed",
                                    "value": 1
                                },
                                {
                                    "type": "variable_if",
                                    "name": "quote_shift_layer pressed",
                                    "value": 0
                                },
                                {
                                    "type": "variable_if",
                                    "name": "spacebar_layer pressed",
                                    "value": 0
                                },
                             ] 
                        })),
                        letterKeys.map(each=>({
                            "type": "basic",
                            "from": {
                                "key_code": each,
                                "modifiers": {
                                    "mandatory": [
                                        "left_shift",
                                    ]
                                }
                            },
                            "to": [
                                {
                                    "key_code": "quote",
                                    modifiers: [
                                        "left_shift"
                                    ]
                                },
                                {
                                    "key_code": each,
                                },
                                // "consume" the quote button
                                {
                                    "set_variable": {
                                        "name": "quote_layer pressed",
                                        "value": 0
                                    }
                                },
                                {
                                    "set_variable": {
                                        "name": "quote_shift_layer pressed",
                                        "value": 0
                                    }
                                },
                            ],
                            "conditions": [
                                {
                                    "type": "variable_if",
                                    "name": "quote_layer pressed",
                                    "value": 1
                                },
                                {
                                    "type": "variable_if",
                                    "name": "quote_shift_layer pressed",
                                    "value": 1
                                },
                                {
                                    "type": "variable_if",
                                    "name": "spacebar_layer pressed",
                                    "value": 0
                                },
                             ] 
                        })),
                        letterKeys.map(each=>({
                            "type": "basic",
                            "from": {
                                "key_code": each,
                                "modifiers": {
                                    "mandatory": [
                                        "left_shift",
                                    ]
                                }
                            },
                            "to": [
                                {
                                    "key_code": "quote",
                                    modifiers: [
                                        "left_shift"
                                    ],
                                },
                                {
                                    "key_code": each,
                                    modifiers: [
                                        "left_shift"
                                    ],
                                },
                                // "consume" the quote button
                                {
                                    "set_variable": {
                                        "name": "quote_layer pressed",
                                        "value": 0
                                    }
                                },
                                {
                                    "set_variable": {
                                        "name": "quote_shift_layer pressed",
                                        "value": 0
                                    }
                                },
                            ],
                            "conditions": [
                                {
                                    "type": "variable_if",
                                    "name": "quote_layer pressed",
                                    "value": 1
                                },
                                {
                                    "type": "variable_if",
                                    "name": "quote_shift_layer pressed",
                                    "value": 1
                                },
                                {
                                    "type": "variable_if",
                                    "name": "spacebar_layer pressed",
                                    "value": 0
                                },
                             ] 
                        })),
                        // leftOrRight('shift').map(
                        //     leftOrRightShift=>letterKeys.map(
                        //         eachLetterKey=>({
                        //             "type": "basic",
                        //             "from": {
                        //                 "key_code": eachLetterKey,
                        //                 "modifiers": {
                        //                     "mandatory": [
                        //                         leftOrRightShift
                        //                     ]
                        //                 },
                        //             },
                        //             "to": [
                        //                 {
                        //                     "key_code": "quote",
                        //                 },
                        //                 {
                        //                     "key_code": eachLetterKey,
                        //                     "modifiers": [
                        //                         leftOrRightShift,
                        //                     ],
                        //                 },
                        //                 // consume the quote button
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "quote_layer pressed",
                        //                     "value": 0
                        //                 },
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "quote_shift_layer pressed",
                        //                     "value": 0
                        //                 },
                        //             ],
                        //             "conditions": [
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "quote_layer pressed",
                        //                     "value": 1
                        //                 },
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "quote_shift_layer pressed",
                        //                     "value": 0
                        //                 },
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "spacebar_layer pressed",
                        //                     "value": 0
                        //                 },
                        //             ]
                        //         })
                        //     )
                        // ),
                        // NOTE: this command doesn't work/activate yet
                        // leftOrRight('shift').map(
                        //     leftOrRightShift=>letterKeys.map(
                        //         eachLetterKey=>({
                        //             "type": "basic",
                        //             "from": {
                        //                 "key_code": eachLetterKey,
                        //                 "modifiers": {
                        //                     "mandatory": [
                        //                         leftOrRightShift
                        //                     ]
                        //                 },
                        //             },
                        //             "to": [
                        //                 {
                        //                     "key_code": "quote",
                        //                     "modifiers": [
                        //                         leftOrRightShift,
                        //                     ],
                        //                 },
                        //                 {
                        //                     "key_code": eachLetterKey,
                        //                     "modifiers": [
                        //                         leftOrRightShift,
                        //                     ],
                        //                 }
                        //             ],
                        //             "conditions": [
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "quote_layer pressed",
                        //                     "value": 1
                        //                 },
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "quote_shift_layer pressed",
                        //                     "value": 1
                        //                 },
                        //                 {
                        //                     "type": "variable_if",
                        //                     "name": "spacebar_layer pressed",
                        //                     "value": 0
                        //                 },
                        //             ]
                        //         })
                        //     )
                        // )
                    ].flat(Infinity),
                // 
                // layers
                // 
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

await FileSystem.write({
    data:JSON.stringify(karabinerMapping, 0, 4),
    path: `${FileSystem.home}/.config/karabiner/assets/complex_modifications/1695750720.json` 
})