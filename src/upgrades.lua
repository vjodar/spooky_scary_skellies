 local definitions={
    --General------------------------------------------------------------------
    ['increaseMinionCapacity']={
        name="Undead Army +5",
        desc="Command up to 5 additional skeletons",
        count=100,
    },
    ['increaseMinionsPerSummon']={
        name="Multi-Summon",
        desc="Raise an additional skeleton each summon",
        count=5,
    },
    ['decreaseSummonCooldown']={
        name='Necromantic Agility',
        desc="Decrease cooldown of summoning",
        count=9,
    },
    ['boneShield']={
        name="Bone Sheild",
        desc="Fire a ring of bone upon taking damage",
    },
    --Warrior------------------------------------------------------------------
    ['increaseHealth']={
        name="Undead Vitality",
        desc="Increase health of all allies",
        count=100,
    },
    ['increaseKnockback']={
        name="Undead Strength",
        desc="Increase knockback of all allies",
        count=10,
    },
    ['increaseDamage']={
        name="Undead Power",
        desc="Increase damage of all allies",
        count=100,
    },
    ['increaseAttackSpeed']={
        name="Undead Vigor",
        desc="Increase attack speed of all allies",
        count=5,
    },
    ['increaseMovespeed']={
        name="Undead Speed",
        desc="Increase movespeed of all allies",
        count=10,
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
        level="swampBoss",
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
        req={"skeletonArcher","skeletonMageFire"},
    },
    ['archerIce']={
        name="Frost Arrow",
        desc="Skeleton archers shoot freezing arrows",
        req={"skeletonArcher","skeletonMageIce"},
    },
    ['archerElectric']={
        name="Lightning Javelin",
        desc="Skeleton archers shoot arrows that zap up to 3 enemies",
        req={"skeletonArcher","skeletonMageElectric"},
    },
    --Mage---------------------------------------------------------------------
    ['skeletonMageFire']={
        name="Summon Skeleton Fire Mage",
        desc="Summon skeleton mages that burn enemies",
        level="caveBoss",
    },
    ['mageFireUpgrade']={
        name="Fireball",
        desc="Skeleton fire mages shoot explosive fireballs",
        req={"skeletonMageFire"},
    },
    ['skeletonMageIce']={
        name="Summon Skeleton Ice Mage",
        desc="Summon skeleton mages that freeze enemies",
        level="caveBoss",
    },
    ['mageIceUpgrade']={
        name="Blizzard",
        desc="Skeleton ice mages shoot frost pulsing blizzards",
        req={"skeletonMageIce"},
    },
    ['skeletonMageElectric']={
        name="Summon Skeleton Electric Mage",
        desc="Summon skeleton mages that shoot erratic sparks",
        level="caveBoss",
    },
    ['mageElectricUpgrade']={
        name="Chain Lightning",
        desc="Skeleton electric mages zap up to 5 enemies at once",
        req={"skeletonMageElectric"},
    },
}

local activationFunctions={
    --General
    ['increaseMinionCapacity']=function()        
        Player.maxMinions=Player.maxMinions+5
    end,
    ['increaseMinionsPerSummon']=function()
        Player.minionsPerSummon=Player.minionsPerSummon+1
    end,
    ['decreaseSummonCooldown']=function()
        local cd=Player.canSummon
        cd.cooldownPeriod=max(1,cd.cooldownPeriod-1)
    end,
    ['boneShield']=function()
        Player.upgrades.boneShield=true 
    end,
    
    --Warrior
    ['increaseHealth']=function()
        --Increase player health by 100, skeleton warriors by 60,
        --and archer and mages by 30
        Player.health.max=Player.health.max+100
        Player.health.current=Player.health.current+100
        Hud.health:calculateMaxHearts()
        Hud.health:calculateHeartPieces()

        local increaseHealth=function(name,val)
            local def=Entities.definitions[name]
            def.health=def.health+val 
        end        
        increaseHealth('skeletonWarrior',60)
        increaseHealth('skeletonArcher',30)
        increaseHealth('skeletonMageFire',30)
        increaseHealth('skeletonMageIce',30)
        increaseHealth('skeletonMageElectric',30)
    end,
    ['increaseKnockback']=function() 
        --increase player and all allies' knockback by their base values
        local increaseKnockback=function(name,val)
            local atk=Entities.definitions[name].attack
            atk.knockback=atk.knockback+val 
        end
        Player.attack.knockback=Player.attack.knockback+100
        increaseKnockback('skeletonWarrior',100)
        increaseKnockback('skeletonArcher',75)
        increaseKnockback('skeletonMageFire',50)
        increaseKnockback('skeletonMageIce',50)
        increaseKnockback('skeletonMageElectric',50)
    end,
    ['increaseDamage']=function()
        --increase player and all allies' damage by their base values
        local increaseDamage=function(name,val)
            local atk=Entities.definitions[name].attack
            atk.damage=atk.damage+val
        end
        Player.attack.damage=Player.attack.damage+10
        increaseDamage('skeletonWarrior',10)
        increaseDamage('skeletonArcher',10)
        increaseDamage('skeletonMageFire',5)
        increaseDamage('skeletonMageIce',5)
        increaseDamage('skeletonMageElectric',5)
    end,
    ['increaseAttackSpeed']=function() 
        --decrease player and allies' attack period by 0.1 for player, 0.5 for
        --allies. Enfore limit periods. Also decrease archer animation duration
        local playerAtk=Player.canAttack
        playerAtk.cooldownPeriod=max(0.1,playerAtk.cooldownPeriod-0.1)
        local decreaseAttackPeriod=function(name,val)
            local atk=Entities.definitions[name].attack
            atk.period=max(0.5,atk.period-val)
        end
        decreaseAttackPeriod('skeletonWarrior',0.2)
        decreaseAttackPeriod('skeletonArcher',0.2)
        decreaseAttackPeriod('skeletonMageFire',0.1)
        decreaseAttackPeriod('skeletonMageIce',0.1)
        decreaseAttackPeriod('skeletonMageElectric',0.1)

        --decrease archer's firing animation frame duration
        local attackAnim=Entities.definitions.skeletonArcher.animations.attack
        attackAnim.duration[3]=max(0.1,attackAnim.duration[3]-0.05)
    end,
    ['increaseMovespeed']=function() 
        --increase player and allies' movespeed by 2 unit/s
        local increaseMovespeed=function(name,val)
            local def=Entities.definitions[name]
            def.moveSpeed=def.moveSpeed+val
        end
        local moveBonus=2*60 --framerate sensitive
        Player.moveSpeedMax=Player.moveSpeedMax+moveBonus
        Player.moveSpeed=Player.moveSpeedMax
        increaseMovespeed('skeletonWarrior',moveBonus)
        increaseMovespeed('skeletonArcher',moveBonus)
        increaseMovespeed('skeletonMageFire',moveBonus)
        increaseMovespeed('skeletonMageIce',moveBonus)
        increaseMovespeed('skeletonMageElectric',moveBonus)
    end,
    ['warriorFire']=function()
        pDef={
            count=300,
            spread={x=4, y=8},
            yOffset=7,
            colors={[0xede4da]=1,[0xca5954]=2,}
        }
        Entities.particleEmitters.skeletonWarrior=ParticleSystem:generateEmitter(pDef)
        Entities.behaviors.AI.skeletonWarrior.dead=Entities.behaviors.states.ally.kamakaze 
    end,
    ['warriorIce']=function()
        Player.upgrades.warriorIce=true 
    end,
    ['warriorElectric']=function()
        Player.upgrades.warriorElectric=true         
    end,
    
    --Archer    
    ['skeletonArcher']=function()
        Player.upgrades.skeletonArcher=true
    end,
    ['increaseMinionRange']=function() 
        --Increases all allies' attack range by their base values
        --also increases warrior lungeForce by base value
        local increaseRange=function(name,val) 
            local atkDef=Entities.definitions[name].attack 
            atkDef.range=atkDef.range+val
            if name=='skeletonWarrior' then 
                atkDef.lungeForce=atkDef.lungeForce+500
            end
        end
        increaseRange('skeletonWarrior',40)
        increaseRange('skeletonArcher',200)
        increaseRange('skeletonMageFire',150)
        increaseRange('skeletonMageIce',150)
        increaseRange('skeletonMageElectric',150) 
    end,
    ['spreadShot']=function() 
        --Increase projectile count by 3 and projectile spread by 0.2
        projectileDef=Entities.definitions.skeletonArcher.attack.projectile
        local count=projectileDef.count or 0
        local spread=projectileDef.spread or 0 
        projectileDef.count=count+3
        projectileDef.spread=spread+0.2
    end,
    ['bounceArrow']=function()
        Player.upgrades.bounceArrow=true 
    end,
    ['archerFire']=function()
        Player.upgrades.archerFire=true         
    end,
    ['archerIce']=function() 
        Player.upgrades.archerIce=true         
    end,
    ['archerElectric']=function() 
        Player.upgrades.archerElectric=true         
    end,

    --Mage    
    ['skeletonMageFire']=function()
        Player.upgrades.skeletonMageFire=true
        Player.selectedMage='Fire'
    end,
    ['mageFireUpgrade']=function()
        --Change projectile to 'fireball', increase knockback,range, and damage 
        Entities.definitions.skeletonMageFire.attack.projectile.name='fireball'
        local attackData=Entities.definitions.skeletonMageFire.attack
        attackData.knockback=attackData.knockback+500
        attackData.range=attackData.range+50
        attackData.damage=attackData.damage+15
    end,
    ['skeletonMageIce']=function()
        Player.upgrades.skeletonMageIce=true
        Player.selectedMage='Ice'
    end,
    ['mageIceUpgrade']=function()
        --Change projectile to 'blizzard', decrease attack speed, increase damage
        Entities.definitions.skeletonMageIce.attack.projectile.name='blizzard'
        Entities.definitions.skeletonMageIce.attack.projectile.yOffset=-15
        local attackData=Entities.definitions.skeletonMageIce.attack
        attackData.period=attackData.period+2
        attackData.range=attackData.range+50
        attackData.knockback=attackData.knockback+50
        attackData.damage=attackData.damage+5
    end,
    ['skeletonMageElectric']=function()
        Player.upgrades.skeletonMageElectric=true
        Player.selectedMage='Electric'
    end,
    ['mageElectricUpgrade']=function()
        --Change AI to have chainLightning attack, increase damage
        local attackData=Entities.definitions.skeletonMageElectric.attack 
        attackData.damage=attackData.damage+20
        attackData.range=attackData.range+50
        attackData.knockback=attackData.knockback+50
        local behaviors=Entities.behaviors
        behaviors.AI.skeletonMageElectric.attack=behaviors.states.ally.chainLightning
    end,
}

local unlock=function(self,name) 
    self.tally[name]=self.tally[name]+1
    self.activationFunctions[name]()
    --testing-------------------------
    self:updatePool() --pool will actually update when chest is spawned or activated
    --testing-------------------------
end 

--Go through upgrade definitions, check level, reqs, and limits
--to rebuild the pool of available upgrades for current level chest
local updatePool=function(self)
    local isUnlocked=function(name) return self.tally[name]>0 end 
    self.pool={} --clear pool

    for name,def in pairs(self.definitions) do 
        local correctLevel,hasAllReqs,belowLimit=true,true,true

        if def.count then --recurring upgrade, check limit
            if self.tally[name]>=def.count then belowLimit=false end 
        else --not recurring, check if already unlocked 
            if isUnlocked(name) then belowLimit=false end 
        end

        if def.level then --check if current level matches level requirement
            if LevelManager.currentLevel.name~=def.level then 
                correctLevel=false
            end 
        end

        if def.req then --check upgrade requirements
            for i=1,#def.req do 
                if not isUnlocked(def.req[i]) then hasAllReqs=false end 
            end
        end

        if correctLevel and hasAllReqs and belowLimit then 
            table.insert(self.pool,name) 
        end 
    end

    --testing------------------------------------
    print('New Pool------------------------------')
    for i=1,#self.pool do print(self.pool[i]) end 
    --testing------------------------------------
end

--the tally is keep track of how many of each upgrade the player has obtained
local generateTally=function(defs)
    local tally={}
    for name,_ in pairs(defs) do tally[name]=0 end 
    return tally 
end
local tally=generateTally(definitions)

--current pool of available upgrades. Changes as the player unlocks more
local generateInitialPool=function(defs)
    local pool={}
    --initial pool consists of only upgrades that have no requirements
    --or are level specific
    for name,def in pairs(defs) do 
        if not (def.req or def.level) then table.insert(pool,name) end
    end
    return pool 
end
local pool=generateInitialPool(definitions)

return { --The Module
    definitions=definitions,
    activationFunctions=activationFunctions,
    tally=tally,
    pool=pool,
    unlock=unlock,
    updatePool=updatePool,
} 