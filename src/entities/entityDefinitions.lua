return {
    ['skeletonWarrior']={
        name='skeletonWarrior',
        moveSpeed=20*60,
        health=6,
        startState='raise',
        attack={
            range=40,
            period=2,
            damage=1,
            knockback=220,
            lungeForce=500,
        },
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
        health=3,
        startState='raise',
        attack={
            range=200,  
            period=1, 
            damage=1,
            knockback=200,
            projectile={name='arrow',xOffset=12,yOffset=-10},
        },
        collider={
            w=10,
            h=6,
            class='ally',
            losFilter='solid',
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
        health=3,
        startState='raise',
        attack={
            range=150,  
            period=1.5,   
            damage=1, 
            knockback=150,
            projectile={name='flame',xOffset=6,yOffset=-7,spread=0.3},
        },
        collider={
            w=10,
            h=6,
            class='ally',
            losFilter='solid',
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
        health=3,
        startState='raise',        
        attack={
            range=150,  
            period=1,   
            damage=1, 
            knockback=150,
            projectile={name='icicle',xOffset=6,yOffset=-7,spread=0.3},
        },
        collider={
            w=10,
            h=6,
            class='ally',
            losFilter='solid',
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
        health=3,
        startState='raise',
        attack={
            range=100,
            period=1,
            damage=1,
            knockback=100,
            projectile={name='spark',xOffset=6,yOffset=-7,count=2,spread=0.5},
        },
        collider={
            w=10,
            h=6,
            class='ally',
            losFilter='solid',
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
        health=3,
        startState='raise',
        attack={
            range=40,
            period=1.5,
            damage=1,
            knockback=200,
            lungeForce=500,
        },
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
        health=3,
        attack={
            range=40,        
            period=2,
            damage=1,
            knockback=200,
            lungeForce=400,            
        },
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
        kbResistance=70,
        health=10,
        attack={
            range=70,        
            period=3,
            damage=1,
            knockback=800,
            lungeForce=1000,
        },
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
        health=3,
        attack={
            range=50,        
            period=1,
            damage=1,
            knockback=100,
            lungeForce=800,
        },
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
        health=3,
        attack={
            range=30,        
            period=1,
            damage=1,
            knockback=100,
            lungeForce=500,
        },
        collider={
            w=6,
            h=4,
            class='enemy',
            moveFilter='enemyFlying',
            losFilter='solid',
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
        health=6,
        startState='raise',
        attack={
            range=30,        
            period=2,
            damage=1,
            knockback=100,
            lungeForce=500,            
        },
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
                frames='1-8',
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
        health=3,
        attack={
            range=140,  
            period=2, 
            damage=1,
            knockback=300,
            projectile={name='darkArrow',xOffset=12,yOffset=-10,spread=0.3},
        },
        collider={
            w=12,
            h=7,
            class='enemy',
            losFilter='solid',
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
        health=6,
        attack={
            range=40,        
            period=1.5,
            damage=1,
            knockback=500,
            lungeForce=700,
        },
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
        attack={
            range=100,  
            period=2, 
            damage=1,
            knockback=150,
            projectile={name='pickaxe',xOffset=10,yOffset=-10,spread=0.8},
        },
        health=3,
        collider={
            w=10,
            h=6,
            class='enemy',
            losFilter='solid',
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
        health=3,
        attack={
            range=90,  
            period=2.5, 
            damage=1,
            knockback=150,
            projectile={name='apple',xOffset=10,yOffset=-10,spread=1},            
        },
        collider={
            w=16,
            h=9,
            class='enemy',
            losFilter='solid',
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
        attack={
            range=120,  
            period=4, 
            damage=1,
            knockback=600,
            projectile={name='jack-o-lantern',xOffset=0,yOffset=-24},
        },
        health=5,
        collider={
            w=27,
            h=10,
            class='enemy',
            losFilter='solid',
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
    ['slimeMatron']={
        name='slimeMatron',
        moveSpeed=10*60,
        attack={
            range=130,  
            period=5, 
            minion={name='slime',spawnPoint='facing'},
        },
        health=5,
        collider={
            w=14,
            h=5,
            class='enemy',
        },
        drawData={
            frameWidth=14,
            frameHeight=15,
        },
        animations={
            idle={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            move={
                frames='1-4',
                row=1,
                duration=0.1,
            },
            attack={
                frames='1-13',
                row=2,
                duration=0.1,
                spawnMinionFrame=7,
            },
        },
    },
    ['vampire']={
        name='vampire',
        moveSpeed=14*60,
        attack={
            range=160,  
            period=3, 
            minion={name='bat',count=2,spawnPoint='facing'},
        },
        health=5,
        collider={
            w=12,
            h=7,
            class='enemy',
            moveFilter='enemyFlying',
            losFilter='solid',
        },
        drawData={
            frameWidth=28,
            frameHeight=22,
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
                duration=0.1,
            },
            attack={
                frames='1-18',
                row=2,
                duration={['1-8']=0.05,[9]=0.2,[10]=0.4,['11-18']=0.05},
                spawnMinionFrame=10,
            },
        },
    },
    ['tombstone']={
        name='tombstone',
        moveSpeed=0,
        attack={
            range=100,  
            period=5, 
            minion={name='zombie',spawnPoint='random'},
        },
        health=5,
        kbResistance=100,
        startState='raise',
        collider={
            w=19,
            h=5,
            class='enemy',
        },
        drawData={
            altSpriteSheets={'tombstone_2','tombstone_3','tombstone_4'},
            frameWidth=19,
            frameHeight=20,
            scaleX=1,
        },
        animations={
            raise={
                frames='1-7',
                row=1,
                duration=0.1,
            },
            idle={
                frames=7,
                row=1,
                duration=10,
            },
            attack={
                frames=7,
                row=1,
                duration=0.1,
                spawnMinionFrame=1,
            },
        },
    },
    ['spiderEgg']={
        name='spiderEgg',
        moveSpeed=0,
        health=5,
        kbResistance=100,
        attack={
            range=120,  
            period=5, 
            minion={name='spider',count=3},
        },
        collider={
            w=20,
            h=8,
            class='enemy',
        },
        drawData={
            frameWidth=20,
            frameHeight=13,
        },
        animations={
            idle={
                frames=1,
                row=1,
                duration=10,
            },
            attack={
                frames='1-8',
                row=1,
                duration=0.05,
            },
        },
    },
    ['imp']={
        name='imp',
        moveSpeed=15*60,
        health=3,
        attack={
            range=50,
            period=1.5,
            damage=1,
            knockback=200,
            lungeForce=500,
        },
        collider={
            w=9,
            h=6,
            class='enemy',
        },
        drawData={
            frameWidth=12,
            frameHeight=14,
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
                row=3,
                duration=0.4,
                damagingFrames={1,1}
            },
        },
    },
    ['gnasherDemon']={
        name='gnasherDemon',
        moveSpeed=20*60,
        health=6,
        attack={
            range=70,
            period=1,
            damage=1,
            knockback=200,
            lungeForce=1000,
        },
        collider={
            w=12,
            h=7,
            class='enemy',
            restitution=0.4,
        },
        drawData={
            frameWidth=14,
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
                duration={0.2,0.1,0.3},
                damagingFrames={2,3}
            },
        },
    },
    ['frankenstein']={
        name='frankenstein',
        moveSpeed=10*60,     
        kbResistance=70,
        health=5,
        attack={
            range=90,  
            period=2, 
            damage=1,
            knockback=200,
            projectile={name='blueSpark',xOffset=0,yOffset=-7,count=6,spread=6.3},
        },
        collider={
            w=20,
            h=11,
            class='enemy',
            losFilter='solid',
        },
        drawData={
            frameWidth=22,
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
                frames='1-5',
                row=3,
                duration=0.1,
                firingFrame=4,
            },
        },
    },
}