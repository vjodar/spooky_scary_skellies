return {
    ['test']={
        map='swamp3',
        waves={
            {
                obsidianGolem=1,
            },
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
        maxEnemies=100, --used to limit summoner enemies' minion spawns
        exit={name='swampWallHole',pos={x=245,y=26+31}}, --small swamp
        -- exit={name='swampWallHole',pos={x=288,y=26+31}}, --swamp boss
        -- exit={name='ladderUp'},
        nextLevel='test',
    },
    ['swampL1']={
        map='swamp3',
        waves={
            {
                pumpkin=1,
            },
            {
                pumpkin=2,
            },
            {
                pumpkin=2,
                ghost=1
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
                spider=3,
            },
            {
                spider=3,
                bat=3,
            },
            {
                spider=3,
                spiderEgg=3,
            },
        },
        maxEnemies=10,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampL3',
    },
    ['swampL3']={
        map='swamp2',
        waves={
            {
                zombie=5,
            },
            {
                zombie=10,
            },
            {
                zombie=10,
                tombstone=5,
            },
        },
        maxEnemies=20,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampL4',
    },
    ['swampL4']={
        map='swamp2',
        waves={
            {
                ghost=3,
                pumpkin=3,
                werewolf=3
            },
            {
                werewolf=3,
                bat=3,
                spiderEgg=3,
            },
            {
                werewolf=5,
                ent=5,
            },
        },
        maxEnemies=20,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampL5',
    },
    ['swampL5']={
        map='swamp2',
        waves={
            {
                ghost=5,
                pumpkin=5,
                bat=5,
                spider=5,
            },
            {
                werewolf=5,
                ent=5,
                spiderEgg=5,
                tombstone=5,
            },
        },
        maxEnemies=20,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampL6',
    },
    ['swampL6']={
        map='swamp2',
        waves={
            {
                pumpkin=5,
            },
            {
                pumpkin=15,
            },
            {
                headlessHorseman=1,
            },
        },
        maxEnemies=20,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampL7',
    },
    ['swampL7']={
        map='swamp2',
        waves={
            {
                zombie=10,
            },
            {
                zombie=20,
            },
            {
                frankenstein=1,
            },
        },
        maxEnemies=20,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampL8',
    },
    ['swampL8']={
        map='swamp2',
        waves={
            {
                pumpkin=5,
                headlessHorseman=1,
            },
            {
                zombie=5,
                frankenstein=1,
            },
            {
                pumpkin=10,
                zombie=10,
                ghost=10,
                frankenstein=1,
                headlessHorseman=1
            },
        },
        maxEnemies=20,
        exit={name='swampWallHole',pos={x=373,y=26+31}},
        nextLevel='swampBoss',
    },
    ['swampBoss']={
        map='swampBoss',
        bossData={
            wave=1, name='giantTombstone',
            spawnPos={x=288,y=192},
            spawnAnimDuration=4,
            deathAnimDuration=3,
        },
        waves={
            {
                giantTombstone=1,
            },
        },
        maxEnemies=50,
        exit={name='swampWallHole',pos={x=288,y=26+31}}, --swamp boss
        nextLevel='caveL1',
    },
    ['caveL1']={
        map='cave2',
        waves={
            {
                slime=10,
            },
            {
                slime=20,
            },
            {
                slime=10,
                slimeMatron=10,
            },
        },
        maxEnemies=50,
        exit={name='caveWallHole',pos={x=380,y=32+26}},
        nextLevel='caveL2',
    },
    ['caveL2']={
        map='cave2',
        waves={
            {
                slimeMatron=3,
                undeadMiner=10,
            },
            {
                undeadMiner=20,
                frankenstein=2,
            },
        },
        maxEnemies=30,
        exit={name='caveWallHole',pos={x=380,y=32+26}},
        nextLevel='caveL3',
    },
    ['caveL3']={
        map='cave2',
        waves={
            {
                spiderEgg=40,
                ghost=20,
            },
        },
        maxEnemies=30,
        exit={name='caveWallHole',pos={x=380,y=32+26}},
        nextLevel='caveL4',
    },
    ['caveL4']={
        map='cave2',
        waves={
            {
                bat=30,
            },
            {
                vampire=12,
            },
        },
        maxEnemies=40,
        exit={name='ladderDown'},
        nextLevel='caveL5',
    },
    ['caveL5']={
        map='cave2',
        waves={
            {
                werewolf=10,
            },
            {
                werewolf=10,
                werebear=3,
            },
        },
        maxEnemies=40,
        exit={name='ladderDown'},
        nextLevel='caveL6',
    },
    ['caveL6']={
        map='cave2',
        waves={
            {
                undeadMiner=10,
                golem=5,
            },
            {
                slimeMatron=5,
                golem=5,
            },
            {
                werebear=5,
                golem=10,
            },
        },
        maxEnemies=40,
        exit={name='ladderDown'},
        nextLevel='caveBoss',
    },
    ['caveBoss']={
        map='caveBoss',
        bossData={
            wave=1, name='obsidianGolem',
            spawnPos={x=413,y=240},
            spawnAnimDuration=1.5,
            deathAnimDuration=3,
        },
        waves={
            {
                obsidianGolem=1,
            },
        },
        maxEnemies=50,
        exit={name='ladderUp'},
        nextLevel='dungeonL1',
    },
    ['dungeonL1']={
        map='dungeon1',
        waves={
            {
                poltergeist=20,
            },
            {
                floatingEyeball=20,
            },
            {
                possessedArcher=20,
            },
        },
        maxEnemies=50,
        exit={name='dungeonStairs'},
        nextLevel='dungeonL2',
    },
    ['dungeonL2']={
        map='dungeon2',
        waves={
            {
                imp=40,
            },
            {
                gnasherDemon=20,
            },
            {
                possessedKnight=20,
            },
        },
        maxEnemies=100,
        exit={name='dungeonStairs'},
        nextLevel='dungeonL3',
    },
    ['dungeonL3']={
        map='dungeon3',
        waves={
            {
                possessedKnight=15,
                vampire=15,
            },
            {
                possessedArcher=15,
                imp=15,
            },
        },
        maxEnemies=100,
        exit={name='dungeonStairs'},
        nextLevel='dungeonL4',
    },
    ['dungeonL4']={
        map='dungeon4',
        waves={
            {
                ghost=20,
                poltergeist=10,
            },
            {
                floatingEyeball=10,
                gnasherDemon=20,
            },
            {
                possessedArcher=20,
                possessedKnight=20,
            },
        },
        maxEnemies=100,
        exit={name='dungeonStairs'},
        nextLevel='dungeonL5',
    },
    ['dungeonL5']={
        map='dungeon6',
        waves={
            {
                headlessHorseman=10,
            },
            {
                imp=20,
                gnasherDemon=10,
                floatingEyeball=5,
            },
            {
                gnasherDemon=10,
                imp=10,
                pyreFiend=3,
            },
        },
        maxEnemies=100,
        exit={name='dungeonStairs'},
        nextLevel='dungeonL6',
    },
    ['dungeonL6']={
        map='dungeon5',
        waves={
            {
                frankenstein=10,
            },
            {
                imp=20,
                gnasherDemon=10,
                possessedArcher=5,
                possessedKnight=5,             
            },
            {
                gnasherDemon=10,
                imp=10,
                beholder=3,
            },
        },
        maxEnemies=100,
        exit={name='dungeonStairs'},
        nextLevel='dungeonBoss',
    },
    ['dungeonBoss']={
        map='dungeonBoss',
        bossData={
            wave=11, name='witch',
            spawnPos={x=400,y=64},
            spawnAnimDuration=1,
            deathAnimDuration=3,
        },
        waves={
            {
                pumpkin=100,
            },
            {
                spider=200,
            },
            {
                ghost=50,
                poltergeist=50,
            },
            {
                zombie=70,
                undeadMiner=50,
            },
            {
                werewolf=80,
                werebear=10,
            },
            {
                slime=30,
                slimeMatron=70,
            },
            {
                bat=30,
                vampire=70,
            },
            {
                possessedKnight=50,
                possessedArcher=50,
            },
            {
                frankenstein=25,
            },
            {
                headlessHorseman=25,
            },
            {
                witch=1,
            },
        },
        maxEnemies=200,
        exit={name='dungeonStairs'},
        nextLevel='test',
    },
}