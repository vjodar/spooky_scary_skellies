local upgrades={}

upgrades.definitions={
    --General------------------------------------------------------------------
    ['increaseMinionCapacity']={
        name="Undead Expansion +5",
        desc="Command up to 5 additional skeletons",
        recurring=true,
    },
    ['increaseMinionsPerSummon']={
        name="Multi-Summon",
        desc="Raise an additional skeleton each summon",
        recurring=true,
    },
    ['decreaseSummonCooldown']={
        name='Necromantic Agility',
        desc="Decrease cooldown of summoning",
        recurring=true,
    },
    ['boneShield']={
        name="Bone Sheild",
        desc="Fire a ring of bone upon taking damage",
    },
    --Warrior------------------------------------------------------------------
    ['increaseSkeletonHealth']={
        name="Undead Vitality",
        desc="Increase health of all allies",
        recurring=true,
    },
    ['increaseKnockback']={
        name="Undead Strength",
        desc="Increase knockback of all allies",
        recurring=true,
    },
    ['increaseDamage']={
        name="Undead Power",
        desc="Increase damage of all allies",
        recurring=true,
    },
    ['increaseAttackSpeed']={
        name="Undead Vigor",
        desc="Increase attack speed of all allies",
        recurring=true,
    },
    ['increaseMovespeed']={
        name="Undead Speed",
        desc="Increase movespeed of all allies",
        recurring=true,
    },
    ['warriorFire']={
        name="Kamakaze",
        desc="Skeleton warriors explode upon death",
        req={"skeletonMageFire"},
    },
    ['warriorIce']={
        name="Ice Kick",
        desc="Skeleton warriors freeze enemies",
        req={"skeletonMageIce"},
    },
    ['warriorElectric']={
        name="Discharge",
        desc="Skeleton warriors shoot sparks upon taking damage",
        req={"skeletonMageElectric"},
    },
    --Archer-------------------------------------------------------------------
    ['skeletonArcher']={
        name="Summon Skeleton Archer",
        desc="Summon accurate, long range skeletal archers",        
    },
    ['increaseMinionRange']={
        name="Sniper Skeletons",
        desc="Skeletons' attack range is doubled",
        req={"skeletonArcher"},
    },
    ['spreadShot']={
        name="Spread Shot",
        desc="Skeleton archers shoot 3 arrow volleys",
        req={"skeletonArcher"},
    },
    ['bounceArrow']={
        name="Bounce Arrow",
        desc="Skeleton archers arrows ricochet off solid objects",
        req={"skeletonArcher"},
    },
    ['archerFire']={
        name="Flame Arrow",
        desc="Skeleton archers shoot burning arrows",
        req={"skeletonMageFire"},
    },
    ['archerIce']={
        name="Frost Arrow",
        desc="Skeleton archers shoot freezing arrows",
        req={"skeletonMageIce"},
    },
    ['archerElectric']={
        name="Lightning Javelin",
        desc="Skeleton archers shoot arrows that zap up to 3 enemies",
        req={"skeletonMageElectric"},
    },
    --Mage---------------------------------------------------------------------
    ['skeletonMageFire']={
        name="Summon Skeleton Fire Mage",
        desc="Summon skeleton mages that burn enemies",
    },
    ['mageFireUpgrade']={
        name="Fireball",
        desc="Skeleton fire mages shoot explosive fireballs",
        req={"skeletonMageFire"},
    },
    ['skeletonMageIce']={
        name="Summon Skeleton Ice Mage",
        desc="Summon skeleton mages that freeze enemies",
    },
    ['mageIceUpgrade']={
        name="Blizzard",
        desc="Skeleton ice mages shoot frost pulsing blizzards",
        req={"skeletonMageIce"},
    },
    ['skeletonMageElectric']={
        name="Summon Skeleton Electric Mage",
        desc="Summon skeleton mages that shoot erratic sparks",
    },
    ['mageElectricUpgrade']={
        name="Chain Lightning",
        desc="Skeleton electric mages zap up to 5 enemies at once",
        req={"skeletonMageElectric"},
    },
}

return upgrades 