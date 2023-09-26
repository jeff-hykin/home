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
                                "key_code": "left_arrow"
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "semicolon_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 0
                            }
                        ]
                    },
                    {
                        "type": "basic",
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
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "semicolon_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 0
                            }
                        ]
                    },
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
                                "key_code": "right_arrow"
                            }
                        ],
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "semicolon_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 0
                            }
                        ]
                    },
                    {
                        "type": "basic",
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
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            },
                            {
                                "type": "variable_if",
                                "name": "semicolon_layer pressed",
                                "value": 0
                            },
                            {
                                "type": "variable_if",
                                "name": "quote_layer pressed",
                                "value": 0
                            }
                        ]
                    },
                // 
                //  brackets 
                // 
                    {
                        "type": "basic",
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
                        "conditions": [
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
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
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
                // cursor undo
                // 
                    {
                        "type": "basic",
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
                        "conditions": [
                            {
                                "type": "variable_if",
                                "name": "spacebar_layer pressed",
                                "value": 1
                            }
                        ]
                    },
                
                // 
                // comma jump
                // 
                    {
                        "type": "basic",
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
                        "conditions": [
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
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "quote",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to_if_alone": [
                            {
                                "key_code": "quote"
                            }
                        ],
                        "to": [
                            {
                                "set_variable": {
                                    "name": "quote_layer pressed",
                                    "value": 1
                                }
                            }
                        ],
                        "to_after_key_up": [
                            {
                                "set_variable": {
                                    "name": "quote_layer pressed",
                                    "value": 0
                                }
                            }
                        ]
                    },
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "quote",
                            "modifiers": {
                                "mandatory": [
                                    "left_shift"
                                ]
                            }
                        },
                        "to_if_alone": [
                            {
                                "key_code": "quote"
                            }
                        ],
                        "to": [
                            {
                                "set_variable": {
                                    "name": "quote_layer pressed",
                                    "value": 1
                                }
                            },
                            {
                                "set_variable": {
                                    "name": "quote_shift_layer pressed",
                                    "value": 1
                                }
                            }
                        ],
                        "to_after_key_up": [
                            {
                                "set_variable": {
                                    "name": "quote_layer pressed",
                                    "value": 1
                                }
                            },
                            {
                                "set_variable": {
                                    "name": "quote_shift_layer pressed",
                                    "value": 0
                                }
                            }
                        ]
                    },
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "quote",
                            "modifiers": {
                                "mandatory": [
                                    "right_shift"
                                ]
                            }
                        },
                        "to_if_alone": [
                            {
                                "key_code": "quote"
                            }
                        ],
                        "to": [
                            {
                                "set_variable": {
                                    "name": "quote_layer pressed",
                                    "value": 1
                                }
                            },
                            {
                                "set_variable": {
                                    "name": "quote_shift_layer pressed",
                                    "value": 1
                                }
                            },
                        ],
                        "to_after_key_up": [
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
                            }
                        ]
                    },
                    {
                        "type": "basic",
                        "from": {
                            "key_code": "semicolon",
                            "modifiers": {
                                "optional": [
                                    "any"
                                ]
                            }
                        },
                        "to_if_alone": [
                            {
                                "key_code": "semicolon"
                            }
                        ],
                        "to": [
                            {
                                "set_variable": {
                                    "name": "semicolon_layer pressed",
                                    "value": 1
                                }
                            }
                        ],
                        "to_after_key_up": [
                            {
                                "set_variable": {
                                    "name": "semicolon_layer pressed",
                                    "value": 0
                                }
                            }
                        ]
                    },
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
                    }
             ]
        }
    ]
}

await FileSystem.write({
    data:JSON.stringify(karabinerMapping, 0, 4),
    path: `${FileSystem.home}/.config/karabiner/assets/complex_modifications/1695750720.json` 
})