return {
    warrior={
        name='skeleton_warrior',
        collider={
            width=12,
            height=5,
            corner=3,
            linearDamping=20,
            mass=0.1,
        },
        drawData={
            xOffset=5,
            yOffset=17,
            spriteSheet='warrior',
            grid='warrior',
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
                onLoop='changeToIdle'
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
                onLoop='changeToRaise'
            },
            idle={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=3,
                duration=0.1,
            },
            attack={
                frames=1,
                row=4,
                duration=0.4
            },
        },
        moveSpeed=240,         
    },
    archer={
        name='skeleton_archer',
        collider={
            width=12,
            height=5,
            corner=3,
            linearDamping=20,
            mass=0.1,
        },
        drawData={
            xOffset=21,
            yOffset=22,
            spriteSheet='archer',
            grid='archer',
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
                onLoop='changeToIdle'
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
                onLoop='changeToRaise'
            },
            idle={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=3,
                duration=0.1,
            },
            attack={
                frames=1,
                row=4,
                duration=0.4
            },
        },
        moveSpeed=240,         
    },
    mageFire={
        name='skeleton_mage_fire',
        collider={
            width=12,
            height=5,
            corner=3,
            linearDamping=20,
            mass=0.1,
        },
        drawData={
            xOffset=12,
            yOffset=24,
            spriteSheet='mageFire',
            grid='mage',
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
                onLoop='changeToIdle'
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
                onLoop='changeToRaise'
            },
            idle={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=3,
                duration=0.1,
            },
            -- attack={
            --     frames=1,
            --     row=4,
            --     duration=0.4
            -- },
        },
        moveSpeed=240,         
    },
    mageIce={
        name='skeleton_mage_ice',
        collider={
            width=12,
            height=5,
            corner=3,
            linearDamping=20,
            mass=0.1,
        },
        drawData={
            xOffset=12,
            yOffset=24,
            spriteSheet='mageIce',
            grid='mage',
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
                onLoop='changeToIdle'
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
                onLoop='changeToRaise'
            },
            idle={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=3,
                duration=0.1,
            },
            -- attack={
            --     frames=1,
            --     row=4,
            --     duration=0.4
            -- },
        },
        moveSpeed=240,         
    },
    mageElectric={
        name='skeleton_mage_electric',
        collider={
            width=12,
            height=5,
            corner=3,
            linearDamping=20,
            mass=0.1,
        },
        drawData={
            xOffset=12,
            yOffset=24,
            spriteSheet='mageElectric',
            grid='mage',
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
                onLoop='changeToIdle'
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
                onLoop='changeToRaise'
            },
            idle={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=3,
                duration=0.1,
            },
            -- attack={
            --     frames=1,
            --     row=4,
            --     duration=0.4
            -- },
        },
        moveSpeed=240,         
    },
}