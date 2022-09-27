return {
    ['test']={
        map='swamp2',
        waves={
            {
                werebear=1,
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
        maxEnemies=20, --used to limit summoner enemies' minion spawns
        nextLevel='test',
    },
    ['swampL1']={
        map='swamp2',
        waves={
            {
                pumpkin=1,
            },
            {
                pumpkin=2,
            },
            {
                pumpkin=2,
                ent=2,
            },
        },
        maxEnemies=10,
        nextLevel='swampL2',
    },
    ['swampL2']={
        map='swamp2',
        waves={
            {
                zombie=3,
            },
            {
                zombie=3,
                tombstone=3,
            },
        },
        maxEnemies=10,
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
        nextLevel='test',
    },
}