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
    ['increaseHealth']={
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

upgrades.activationFunctions={
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
            local atk=Entities.definitions[name]
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
        decreaseAttackPeriod('skeletonWarrior',0.5)
        decreaseAttackPeriod('skeletonArcher',0.5)
        decreaseAttackPeriod('skeletonMageFire',0.5)
        decreaseAttackPeriod('skeletonMageIce',0.5)
        decreaseAttackPeriod('skeletonMageElectric',0.5)

        --decrease archer's firing animation frame duration
        local attackAnim=Entities.definitions.skeletonArcher.animations.attack
        attackAnim.duration[3]=max(0.05,attackAnim.duration[3]-0.1)
    end,
    ['increaseMovespeed']=function() 
        --increase player and allies' movespeed by 1 unit/s
        local increaseMovespeed=function(name,val)
            local def=Entities.definitions[name]
            def.moveSpeed=def.moveSpeed+val
        end
        local moveBonus=1*60 --framerate sensitive
        Player.moveSpeedMax=Player.moveSpeedMax+moveBonus
        Player.moveSpeed=Player.moveSpeedMax
        increaseMovespeed('skeletonWarrior',moveBonus)
        increaseMovespeed('skeletonArcher',moveBonus)
        increaseMovespeed('skeletonMageFire',moveBonus)
        increaseMovespeed('skeletonMageIce',moveBonus)
        increaseMovespeed('skeletonMageElectric',moveBonus)
    end,
    ['warriorFire']=function() end,
    ['warriorIce']=function() end,
    ['warriorElectric']=function() end,
    
    --Archer    
    ['skeletonArcher']=function()
        Player.upgrades.skeletonArcher=true
    end,
    ['increaseMinionRange']=function(self) 
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
    ['spreadShot']=function() end,
    ['bounceArrow']=function() end,
    ['archerFire']=function() end,
    ['archerIce']=function() end,
    ['archerElectric']=function() end,

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

upgrades.unlock=function(self,name) 
    self.activationFunctions[name](self)
    self.tally[name]=self.tally[name]+1
    self:updatePool()
end 

--Go through upgrade definitions, if all required upgrades have been unlocked,
--add upgrade to pool. Will ignore upgrades that are already unlocked or in pool
upgrades.updatePool=function(self)
    for name,def in pairs(self.definitions) do 
        if def.req and self.tally[name]==0 then --has req and isn't unlocked
            local alreadyInPool=false    
            for i=1,#self.pool do 
                if self.pool[i]==name then alreadyInPool=true end 
            end

            if not alreadyInPool then 
                local unlockedAllReqs=true 
                for i=1,#def.req do 
                    if self.tally[def.req[i]]==0 then unlockedAllReqs=false end 
                end
    
                if unlockedAllReqs then
                    table.insert(self.pool,name) 
                    print('added to pool',name) 
                end 
            end
        end
    end
end

--the tally is keep track of how many of each upgrade the player has obtained
local generateTally=function(defs)
    local tally={}
    for name,_ in pairs(defs) do tally[name]=0 end 
    return tally 
end
upgrades.tally=generateTally(upgrades.definitions)

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
upgrades.pool=generateInitialPool(upgrades.definitions)

return upgrades 