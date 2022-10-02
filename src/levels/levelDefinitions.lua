return {
    ['test']={
        map='swamp3',
        waves={
            {
                tombstone=1,
            },
            -- {
            --     zombie=10,            
            --     tombstone=10,            
            -- },
            -- {
            --     spider=10,            
            --     spiderEgg=10,            
            -- },
            -- {
            --     pumpkin=10,       
            --     ent=10,  
            --     headlessHorseman=4,     
            -- },
        },
        maxEnemies=10, --used to limit summoner enemies' minion spawns
        -- exit={name='swampWallHole',pos={x=245,y=26+31}}, --small swamp
        exit={name='swampWallHole',pos={x=288,y=26+31}}, --swamp boss
        -- exit={name='ladderUp'},
        nextLevel='test',
    },
    ['swampL1']={
        map='swamp3',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='swampWallHole',pos={x=245,y=26+31}},
        nextLevel='swampL2',
    },
    ['swampL2']={
        map='swamp2',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampBoss',
    },
    ['swampBoss']={
        map='swampBoss',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='swampWallHole',pos={x=288,y=26+31}},
        nextLevel='caveL1',
    },
    ['caveL1']={
        map='cave2',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='caveWallHole',pos={x=380,y=32+26}},
        nextLevel='caveL2',
    },
    ['caveL2']={
        map='cave2',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='ladderDown'},
        nextLevel='caveBoss',
    },
    ['caveBoss']={
        map='caveBoss',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='ladderUp'},
        nextLevel='dungeonL1',
    },
    ['dungeonL1']={
        map='dungeon1',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='dungeonStairs'},
        nextLevel='dungeonL2',
    },
    ['dungeonL2']={
        map='dungeon6',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='dungeonStairs'},
        nextLevel='dungeonBoss',
    },
    ['dungeonL2']={
        map='dungeonBoss',
        waves={
            {
                pumpkin=1,
            },
        },
        maxEnemies=10,
        exit={name='dungeonStairs'},
        nextLevel='test',
    },
}