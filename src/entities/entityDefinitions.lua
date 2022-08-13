return {
    skeletonWarrior={
        name='skeletonWarrior',
        moveSpeed=100,
        attackRange=30,  
        attackSpeed=2,
        attackDamage=1,
        knockback=20,
        lungeSpeed=50,
        health=3,
        collider={
            width=12,
            height=5,
            corner=3,
            class='skeleton',
            modifiers={
                setLinearDamping=10,
                setMass=0.1,
                setBullet=true,
            },
        },
        drawData={
            xOffset=5,
            yOffset=17,
            frameWidth=10,
            frameHeight=17,
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
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
                duration=0.4,
                damagingFrames={1,1}
            },
        },
    },
    skeletonArcher={
        name='skeletonArcher',
        moveSpeed=90,     
        attackRange=150,  
        attackSpeed=1.5, 
        attackDamage=1,
        knockback=10,
        health=3,
        collider={
            width=12,
            height=5,
            corner=3,
            class='skeleton',
            modifiers={
                setLinearDamping=10,
                setMass=0.1,
            },
        },
        drawData={
            xOffset=21,
            yOffset=22,
            frameWidth=42,
            frameHeight=22,
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
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
                frames='1-4',
                row=4,
                duration={0.1,0.1,0.3,0.1},
                damagingFrames={4,4}
            },
        },
    },
    skeletonMageFire={
        name='skeletonMageFire',
        moveSpeed=80,  
        attackRange=60,  
        attackSpeed=1,   
        attackDamage=1, 
        knockback=1,
        health=3,
        collider={
            width=12,
            height=5,
            corner=3,
            class='skeleton',
            modifiers={
                setLinearDamping=10,
                setMass=0.1,
            },
        },
        drawData={
            xOffset=12,
            yOffset=24,
            frameWidth=24,
            frameHeight=24,
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
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
                frames='1-4',
                row=3,
                duration=0.1,
            },
        },
    },
    skeletonMageIce={
        name='skeletonMageIce',
        moveSpeed=80,    
        attackRange=60,     
        attackSpeed=1,
        attackDamage=1,
        knockback=1,
        health=3,
        collider={
            width=12,
            height=5,
            corner=3,
            class='skeleton',
            modifiers={
                setLinearDamping=10,
                setMass=0.1,
            },
        },
        drawData={
            xOffset=12,
            yOffset=24,
            frameWidth=24,
            frameHeight=24,
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
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
                frames='1-4',
                row=3,
                duration=0.1,
            },
        },
    },
    skeletonMageElectric={
        name='skeletonMageElectric',
        moveSpeed=80,    
        attackRange=60,     
        attackSpeed=1,
        attackDamage=1,
        knockback=1,
        health=3,
        collider={
            width=12,
            height=5,
            corner=3,
            class='skeleton',
            modifiers={
                setLinearDamping=10,
                setMass=0.1,
            },
        },
        drawData={
            xOffset=12,
            yOffset=24,
            frameWidth=24,
            frameHeight=24,
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
            },
            lower={
                frames='7-1',
                row=1,
                duration=0.1,
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
                frames='1-4',
                row=3,
                duration=0.1,
            },
        },
    },
    slime={
        name='slime',
        moveSpeed=50,
        attackRange=40,        
        attackSpeed=1.5,
        attackDamage=1,
        lungeSpeed=40,
        knockback=10,
        health=3,
        collider={
            width=10,
            height=4,
            corner=3,
            class='enemy',
            modifiers={
                setLinearDamping=10,
                setMass=0.1,
                setBullet=true,
            },
        },
        drawData={
            xOffset=8,
            yOffset=14,
            frameWidth=16,
            frameHeight=14,
        },
        animations={
            wake={
                frames='1-4',
                row=1,
                duration=0.1,
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
                frames='1-8',
                row=4,
                duration=0.1,
                damagingFrames={3,8}
            },
        },
    },
}