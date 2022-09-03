return {
    ['skeletonWarrior']={
        name='skeletonWarrior',
        moveSpeed=20*60,
        attackRange=40,  
        attackPeriod=2,
        attackDamage=1,
        knockback=220,
        lungeForce=500,
        health=6,
        startState='raise',
        collider={
            w=10,
            h=6,
            class='ally',
        },
        drawData={
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
    ['skeletonArcher']={
        name='skeletonArcher',
        moveSpeed=19*60,     
        attackRange=200,  
        attackPeriod=1, 
        attackDamage=1,
        projectile={name='arrow',xOffset=12,yOffset=-10},
        knockback=200,
        health=3,
        startState='raise',
        collider={
            w=10,
            h=6,
            class='ally',
        },
        drawData={
            frameWidth=38,
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
                firingFrame=4,
            },
        },
    },
    ['skeletonMageFire']={
        name='skeletonMageFire',
        moveSpeed=18*60,  
        attackRange=150,  
        attackPeriod=1.5,   
        attackDamage=1, 
        projectile={name='flame',xOffset=6,yOffset=-7},
        knockback=150,
        health=3,
        startState='raise',
        collider={
            w=10,
            h=6,
            class='ally',
        },
        drawData={
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
                frames=1,
                row=4,
                duration=0.4,
                firingFrame=1,
            },
        },
    },
    ['skeletonMageIce']={
        name='skeletonMageIce',
        moveSpeed=18*60,    
        attackRange=150,     
        attackPeriod=1,
        attackDamage=1,
        projectile={name='icicle',xOffset=6,yOffset=-7},
        knockback=150,
        health=3,
        startState='raise',
        collider={
            w=10,
            h=6,
            class='ally',
        },
        drawData={
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
                frames=1,
                row=4,
                duration=0.4,
                firingFrame=1,
            },
        },
    },
    ['skeletonMageElectric']={
        name='skeletonMageElectric',
        moveSpeed=18*60,    
        attackRange=100,     
        attackPeriod=1,
        attackDamage=1,
        projectile={name='spark',xOffset=6,yOffset=-7},
        projectilesPerShot=2,
        knockback=100,
        health=3,
        startState='raise',
        collider={
            w=10,
            h=6,
            class='ally',
        },
        drawData={
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
                frames=1,
                row=4,
                duration=0.4,
                firingFrame=1,
            },
        },
    },
    ['slime']={
        name='slime',
        moveSpeed=15*60,
        attackRange=40,        
        attackPeriod=1.5,
        attackDamage=1,
        knockback=200,
        lungeForce=500,
        health=3,
        startState='raise',
        collider={
            w=11,
            h=5,
            class='enemy',
            restitution=0.7,
        },
        drawData={
            frameWidth=16,
            frameHeight=14,
        },
        animations={
            raise={
                frames='1-7',
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
    ['pumpkin']={
        name='pumpkin',
        moveSpeed=15*60,
        attackRange=40,        
        attackPeriod=2,
        attackDamage=1,
        knockback=200,
        lungeForce=400,
        health=3,
        collider={
            w=12,
            h=7,
            class='enemy',
            restitution=0.7,
        },
        drawData={
            frameWidth=16,
            frameHeight=16,
        },
        animations={
            wake={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames=1,
                row=3,
                duration=0.4,
                damagingFrames={1,1}
            },
        },
    },
    ['golem']={
        name='golem',
        moveSpeed=10*60,
        attackRange=70,        
        attackPeriod=3,
        attackDamage=1,
        knockback=400,
        kbResistance=70,
        lungeForce=800,
        health=10,
        collider={
            w=14,
            h=8,
            class='enemy',
            restitution=0,
            linearDamping=7,
        },
        drawData={
            frameWidth=16,
            frameHeight=19,
        },
        animations={
            wake={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames='1-9',
                row=3,
                duration=0.1,
                damagingFrames={4,9}
            },
        },
    },
    ['spider']={
        name='spider',
        moveSpeed=18*60,
        attackRange=50,        
        attackPeriod=1,
        attackDamage=1,
        knockback=100,
        lungeForce=800,
        health=3,
        collider={
            w=12,
            h=7,
            class='enemy',
            restitution=0.2,
        },
        drawData={
            frameWidth=14,
            frameHeight=16,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.04,
            },
            attack={
                frames='1-2',
                row=3,
                duration=0.2,
                damagingFrames={2,2}
            },
        },
    },
    ['bat']={
        name='bat',
        moveSpeed=17*60,
        attackRange=30,        
        attackPeriod=1,
        attackDamage=1,
        knockback=100,
        lungeForce=500,
        health=3,
        collider={
            w=6,
            h=4,
            class='enemy',
        },
        drawData={
            frameWidth=16,
            frameHeight=12,
        },
        animations={
            idle={
                frames='1-3',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-3',
                row=1,
                duration=0.07,
            },
            attack={
                frames=1,
                row=1,
                duration=0.3,
                damagingFrames={1,1}
            },
        },
    },
    ['zombie']={
        name='zombie',
        moveSpeed=8*60,
        attackRange=30,        
        attackPeriod=2,
        attackDamage=1,
        knockback=100,
        lungeForce=500,
        health=6,
        startState='raise',
        collider={
            w=10,
            h=6,
            class='enemy',
        },
        drawData={
            altSpriteSheets={'zombie_2','zombie_3'},
            frameWidth=18,
            frameHeight=21,
        },
        animations={
            raise={
                frames='1-13',
                row=1,
                duration=0.1,
            },
            idle={
                frames='1-4',
                row=2,
                duration=0.15,
            },
            move={
                frames='1-4',
                row=3,
                duration=0.15,
            },
            attack={
                frames='1-4',
                row=4,
                duration={0.2,0.1,0.1,0.3},
                damagingFrames={2,4}
            },
        },
    },
    ['possessedArcher']={
        name='possessedArcher',
        moveSpeed=15*60,     
        attackRange=140,  
        attackPeriod=2, 
        attackDamage=1,
        projectile={name='darkArrow',xOffset=12,yOffset=-10},
        knockback=300,
        health=3,
        collider={
            w=12,
            h=7,
            class='enemy',
        },
        drawData={
            frameWidth=34,
            frameHeight=26,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames='1-4',
                row=3,
                duration={0.1,0.1,0.3,0.1},
                firingFrame=4,
            },
        },
    },
    ['possessedKnight']={
        name='possessedKnight',
        moveSpeed=20*60,
        attackRange=40,        
        attackPeriod=1.5,
        attackDamage=1,
        knockback=100,
        lungeForce=700,
        health=6,
        collider={
            w=12,
            h=7,
            class='enemy',
            restitution=0.3,
        },
        drawData={
            frameWidth=38,
            frameHeight=23,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames='1-4',
                row=3,
                duration={0.2,0.1,0.1,0.3},
                damagingFrames={2,4}
            },
        },
    },
    ['undeadMiner']={
        name='undeadMiner',
        moveSpeed=10*60,     
        attackRange=100,  
        attackPeriod=2, 
        attackDamage=1,
        projectile={name='pickaxe',xOffset=10,yOffset=-10},
        knockback=150,
        health=3,
        collider={
            w=10,
            h=6,
            class='enemy',
        },
        drawData={
            frameWidth=20,
            frameHeight=24,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames='1-3',
                row=3,
                duration={0.2,0.1,0.2},
                firingFrame=3,
            },
        },
    },    
    ['ent']={
        name='ent',
        moveSpeed=10*60,     
        attackRange=100,  
        attackPeriod=2.5, 
        attackDamage=1,
        projectile={name='apple',xOffset=10,yOffset=-10},
        knockback=150,
        health=3,
        collider={
            w=16,
            h=9,
            class='enemy',
        },
        drawData={
            frameWidth=23,
            frameHeight=32,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames=1,
                row=1,
                duration=0.4,
                firingFrame=1,
            },
        },
    },
    ['headlessHorseman']={
        name='headlessHorseman',
        moveSpeed=15*60,     
        attackRange=100,  
        attackPeriod=4, 
        attackDamage=1,
        projectile={name='jack-o-lantern',xOffset=0,yOffset=-24},
        knockback=600,
        health=5,
        collider={
            w=27,
            h=10,
            class='enemy',
        },
        drawData={
            frameWidth=33,
            frameHeight=30,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=2,
                duration=0.1,
            },
            attack={
                frames='1-10',
                row=3,
                duration={['1-4']=0.1,[5]=0.4,['6-10']=0.1},
                firingFrame=5,
            },
        },
    },
}