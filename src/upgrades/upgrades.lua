 local definitions={
    --General------------------------------------------------------------------
    ['increaseMinionCapacity5']={
        name="Undead Army +5",
        desc="Command up to 5 additional skeletons",
        count=100,
    },
    ['increaseMinionCapacity15']={
        name="Undead Army  +15",
        desc="Command up to 15 additional skeletons",
        level="swampBoss",
    },
    ['increaseMinionCapacity30']={
        name="Undead Army  +30",
        desc="Command up to 30 additional skeletons",
        level="caveBoss",
    },
    ['increaseMinionsPerSummon']={
        name="Multi-Summon",
        desc="Raise an additional 2 skeletons each summon",
        req={'increaseMinionCapacity5'},
        count=3,
    },
    ['decreaseSummonCooldown']={
        name='Necromantic Agility',
        desc="Decrease cooldown of summoning",
        count=3,
    },
    ['boneShield']={
        name="Bone Sheild",
        desc="Fire a ring of bone upon taking damage",
    },
    ['corpseExplosion']={
        name="Corpse Explosion",
        desc="Slain enemies explode into a ring of bone",
        level="caveBoss",
    },
    ['bounceBone']={
        name="Bouncey Bone",
        desc="Bones bounce off solid objects",
        level="swampBoss",    
    },
    ['fastBone']={
        name="Fast Bone",
        desc="Bones travel more quickly",
    },
    ['panicSummon']={
        name="Panic Summon",
        desc="Summon 5 skeletons upon taking heavy damage",
        level="swampBoss",
    },
    ['vampiricEnergy']={
        name="Vampiric  Energy",
        desc="Slain enemies restore more of your health",
        level="swampBoss",
    },
    --Warrior------------------------------------------------------------------
    ['increaseHealth']={
        name="Undead   Vitality",
        desc="Increase health of all allies",
        count=100,
    },
    ['increaseKnockback']={
        name="Undead Strength",
        desc="Increase knockback of all allies",
    },
    ['increaseDamage']={
        name="Undead Power",
        desc="Increase damage of all allies",
        count=100,
    },
    ['increaseAttackSpeed']={
        name="Undead Vigor",
        desc="Increase attack speed of all allies",
        count=2,
    },
    ['increaseMovespeed']={
        name="Undead Speed",
        desc="Increase movespeed of all allies",
        count=3,
    },
    ['warriorFire']={
        name="Kamakaze",
        desc="Skeleton warriors explode upon death",
        req={"skeletonMageFire"},
    },
    ['warriorIce']={
        name="Ice Kick",
        desc="Skeleton warriors are more resilient and freeze enemies",
        req={"skeletonMageIce"},
    },
    ['warriorElectric']={
        name="Discharge",
        desc="Skeleton warriors shoot sparks upon taking damage",
        req={"skeletonMageElectric"},
    },
    --Archer-------------------------------------------------------------------
    ['skeletonArcher']={
        name="Summon  Skeleton  Archer",
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
        desc="Skeleton archers shoot 2 arrow volleys",
        req={"skeletonArcher"},
    },
    ['bounceArrow']={
        name="Ricochet",
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
        name="Chain   Lightning",
        desc="Skeleton electric mages zap up to 5 enemies at once",
        req={"skeletonMageElectric"},
    },
}

local activationFunctions={
    --General
    ['increaseMinionCapacity5']=function()        
        Player.maxMinions=Player.maxMinions+5
        Player.dialog:say("My army grows!")
    end,
    ['increaseMinionCapacity15']=function()        
        Player.maxMinions=Player.maxMinions+15
        Player.dialog:say("My army grows!")
    end,
    ['increaseMinionCapacity30']=function()        
        Player.maxMinions=Player.maxMinions+30
        Player.dialog:say("My army grows!")
    end,
    ['increaseMinionsPerSummon']=function()
        Player.minionsPerSummon=Player.minionsPerSummon+2
        Player.dialog:say("Multi-Summon!")
    end,
    ['decreaseSummonCooldown']=function()
        local cd=Player.canSummon
        cd.cooldownPeriod=cd.cooldownPeriod-1.5
        Player.dialog:say("Necromantic Agility!")
    end,
    ['boneShield']=function()
        Player.upgrades.boneShield=true 
        Player.dialog:say("Bone Shield!")
    end,
    ['corpseExplosion']=function()
        Player.upgrades.corpseExplosion=true
        Player.dialog:say("Corpse Explosion!")
    end,
    ['bounceBone']=function()        
        Player.upgrades.bounceBone=true
        local bone=Projectiles.definitions.bone 
        local travelTime=bone.travelTime or 4
        bone.travelTime=travelTime+2
        Player.dialog:say("Bouncey Bones!")
    end,
    ['fastBone']=function()
        local bone=Projectiles.definitions.bone        
        bone.moveSpeed=bone.moveSpeed+150
        local travelTime=bone.travelTime or 4
        bone.travelTime=travelTime+2
        Player.dialog:say("Fast Bones!")
    end,
    ['panicSummon']=function()
        Player.upgrades.panicSummon=true 
        Player.dialog:say("Panic Summon!")
    end,
    ['vampiricEnergy']=function()
        Player.healthPerParticle=0.5
        Player.dialog:say("Today I chose violence!")
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
        increaseHealth('skeletonWarrior',100)
        increaseHealth('skeletonArcher',50)
        increaseHealth('skeletonMageFire',50)
        increaseHealth('skeletonMageIce',80)
        increaseHealth('skeletonMageElectric',50)
        
        Player.dialog:say("Undead Vitality!")
    end,
    ['increaseKnockback']=function() 
        --increase player and all allies' knockback by 3x base values
        local increaseKnockback=function(name,val)
            local atk=Entities.definitions[name].attack
            atk.knockback=atk.knockback+val 
        end
        Player.attack.knockback=Player.attack.knockback+600
        increaseKnockback('skeletonWarrior',600)
        increaseKnockback('skeletonArcher',450)
        increaseKnockback('skeletonMageFire',300)
        increaseKnockback('skeletonMageIce',300)
        increaseKnockback('skeletonMageElectric',300)
        
        Player.dialog:say("Undead Strength!")
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
        
        Player.dialog:say("Undead Power!")
    end,
    ['increaseAttackSpeed']=function() 
        --decrease player and allies' attack period, enforce period limits.
        local playerAtk=Player.canAttack
        playerAtk.cooldownPeriod=playerAtk.cooldownPeriod-0.2
        local decreaseAttackPeriod=function(name,val)
            local atk=Entities.definitions[name].attack
            atk.period=atk.period-val
        end
        decreaseAttackPeriod('skeletonWarrior',0.5)
        decreaseAttackPeriod('skeletonArcher',0.4)
        decreaseAttackPeriod('skeletonMageFire',0.2)
        decreaseAttackPeriod('skeletonMageIce',0.2)
        decreaseAttackPeriod('skeletonMageElectric',0.2)

        --decrease archer's firing animation frame duration
        local attackAnim=Entities.definitions.skeletonArcher.animations.attack
        attackAnim.duration[3]=max(0.1,attackAnim.duration[3]-0.05)
        
        Player.dialog:say("Undead Vigor!")
    end,
    ['increaseMovespeed']=function() 
        --increase player and allies' movespeed by 2 unit/s
        local increaseMovespeed=function(name,val)
            local def=Entities.definitions[name]
            def.moveSpeed=def.moveSpeed+val
        end
        local moveBonus=4*60 --framerate sensitive
        Player.moveSpeedMax=Player.moveSpeedMax+moveBonus
        Player.moveSpeed=Player.moveSpeedMax
        increaseMovespeed('skeletonWarrior',moveBonus)
        increaseMovespeed('skeletonArcher',moveBonus)
        increaseMovespeed('skeletonMageFire',moveBonus)
        increaseMovespeed('skeletonMageIce',moveBonus)
        increaseMovespeed('skeletonMageElectric',moveBonus)
        
        Player.dialog:say("Undead Speed!")
    end,
    ['warriorFire']=function()
        pDef={
            count=1000,
            spread={x=4, y=8},
            maxSpeed=15,
            yOffset=7,
            colors={[0xede4da]=1,[0xca5954]=2,}
        }
        Entities.particleEmitters.skeletonWarrior=ParticleSystem:generateEmitter(pDef)
        Entities.behaviors.AI.skeletonWarrior.dead=Entities.behaviors.states.ally.kamakaze 
        
        Player.dialog:say("Kamakaze!")
    end,
    ['warriorIce']=function()
        --enable upgrade, greatly increase warrior knockback resist and health
        Player.upgrades.warriorIce=true 
        local warrior=Entities.definitions.skeletonWarrior
        local kbResistance=warrior.kbResistance or 0
        warrior.kbResistance=min(90,kbResistance+90)
        warrior.health=warrior.health+400

        Player.dialog:say("Ice Kick!")
    end,
    ['warriorElectric']=function()
        Player.upgrades.warriorElectric=true 
        Player.dialog:say("Discharge!")
    end,
    
    --Archer    
    ['skeletonArcher']=function()
        Player.upgrades.skeletonArcher=true        
        Player.dialog:say("Skeleton Archers!")
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
        
        Player.dialog:say("Sniper Skeletons!")
    end,
    ['spreadShot']=function() 
        --Increase projectile count by 3 and projectile spread by 0.2
        projectileDef=Entities.definitions.skeletonArcher.attack.projectile
        local count=projectileDef.count or 0
        local spread=projectileDef.spread or 0 
        projectileDef.count=count+2
        projectileDef.spread=spread+0.2
        
        Player.dialog:say("Spread Shot!")
    end,
    ['bounceArrow']=function()
        Player.upgrades.bounceArrow=true
        Player.dialog:say("Ricochet!")
    end,
    ['archerFire']=function()
        Player.upgrades.archerFire=true 
        Player.dialog:say("Flame Arrow!")                
    end,
    ['archerIce']=function() 
        Player.upgrades.archerIce=true 
        Player.dialog:say("Frost Arrow!")        
    end,
    ['archerElectric']=function() 
        Player.upgrades.archerElectric=true
        Player.dialog:say("Lightning Javelin!")
    end,

    --Mage    
    ['skeletonMageFire']=function()
        Player.upgrades.skeletonMageFire=true
        Player.selectedMage='Fire'
        
        Player.dialog:say("Skeleton Fire Mages!")
    end,
    ['mageFireUpgrade']=function()
        --Change projectile to 'fireball', increase knockback,range, and damage 
        Entities.definitions.skeletonMageFire.attack.projectile.name='fireball'
        local attackData=Entities.definitions.skeletonMageFire.attack
        attackData.knockback=attackData.knockback+500
        attackData.range=attackData.range+50
        attackData.damage=attackData.damage+15
        
        Player.dialog:say("Fireball!")
    end,
    ['skeletonMageIce']=function()
        Player.upgrades.skeletonMageIce=true
        Player.selectedMage='Ice'
        
        Player.dialog:say("Skeleton Ice Mages!")
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
        
        Player.dialog:say("Blizzard!")
    end,
    ['skeletonMageElectric']=function()
        Player.upgrades.skeletonMageElectric=true
        Player.selectedMage='Electric'
        
        Player.dialog:say("Skeleton Electric Mages!")
    end,
    ['mageElectricUpgrade']=function()
        --Change AI to have chainLightning attack, increase damage
        local attackData=Entities.definitions.skeletonMageElectric.attack 
        attackData.damage=attackData.damage+20
        attackData.range=attackData.range+50
        attackData.knockback=attackData.knockback+50
        local behaviors=Entities.behaviors
        behaviors.AI.skeletonMageElectric.attack=behaviors.states.ally.chainLightning
        
        Player.dialog:say("Chain Lightning!")
    end,
}

local unlock=function(self,name) 
    self.tally[name]=self.tally[name]+1
    self.activationFunctions[name]()
    Audio:playSfx('upgrade')
end 

--Go through upgrade definitions, check pre reqs and count limits
--to rebuild the pool of available upgrades for current level chest
local updatePool=function(self)
    local isUnlocked=function(name) return self.tally[name]>0 end 
    self.pool={} --clear pool

    for name,def in pairs(self.definitions) do 
        local hasAllReqs,belowLimit,levelSpecific=true,true,false 

        if def.count then --recurring upgrade, check limit
            if self.tally[name]>=def.count then belowLimit=false end 
        else --not recurring, check if already unlocked 
            if isUnlocked(name) then belowLimit=false end 
        end

        if def.req then --check upgrade requirements
            for i=1,#def.req do 
                if not isUnlocked(def.req[i]) then hasAllReqs=false end 
            end
        end

        if def.level then levelSpecific=true end 

        if hasAllReqs and belowLimit and not levelSpecific then 
            table.insert(self.pool,name) 
        end 
    end
end

--the tally is keep track of how many of each upgrade the player has obtained
local generateInitialTally=function(defs)
    local tally={}
    for name,_ in pairs(defs) do tally[name]=0 end 
    return tally 
end
local tally=generateInitialTally(definitions)

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

local resetTallyAndPool=function(self)
    local defs=self.definitions 
    for name,_ in pairs(defs) do self.tally[name]=0 end 
    self.pool={}
    for name,def in pairs(defs) do 
        if not (def.req or def.level) then table.insert(self.pool,name) end
    end
end

--returns a table of all level specific upgrades
local getLevelSpecificUpgrades=function(self,level)
    local levelUpgrades={}
    for name,def in pairs(self.definitions) do 
        if def.level and def.level==level then 
            table.insert(levelUpgrades,name) 
        end 
    end
    return levelUpgrades
end

--selects count number of upgrades from pool to present as upgrade cards
local pickUpgrades=function(self,count,isBossChest)
    Upgrades:updatePool()

    local currentLevel=LevelManager.currentLevel.name
    local levelUpgrades=self:getLevelSpecificUpgrades(currentLevel)

    local moveElement=function(insertTable,removeTable,index)
        table.insert(insertTable,removeTable[index])
        table.remove(removeTable,index)
    end

    --selected upgrades from either levelUpgrades or self.pool
    local selectedUpgrades={}
    for i=1,count do
        local index=rnd(#self.pool)
        local removeTable=self.pool 
        --always select an available level specific upgrade
        if #levelUpgrades>0 and isBossChest then 
            index=rnd(#levelUpgrades)
            removeTable=levelUpgrades 
        end
        moveElement(selectedUpgrades,removeTable,index)
    end

    return selectedUpgrades
end

return { --The Module
    chests=require 'src.upgrades.chests',
    definitions=definitions,
    activationFunctions=activationFunctions,
    tally=tally,
    pool=pool,
    resetTallyAndPool=resetTallyAndPool,
    getLevelSpecificUpgrades=getLevelSpecificUpgrades,
    pickUpgrades=pickUpgrades,
    unlock=unlock,
    updatePool=updatePool,
} 