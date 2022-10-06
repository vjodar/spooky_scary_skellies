local projectileDefinitions={
    ['bone']={
        name='bone',
        moveSpeed=150,
        collider={
            w=6,
            h=6,
            class='allyProjectile',
        }
    },
    ['arrow']={
        name='arrow',
        moveSpeed=300,
        collider={
            w=3,
            h=3,
            class='allyProjectile',
        },
    },
    ['flame']={
        name='flame',
        moveSpeed=200,
        collider={
            w=3,
            h=3,
            class='allyProjectile',
        },
    },
    ['icicle']={
        name='icicle',
        moveSpeed=160,
        collider={
            w=3,
            h=3,
            class='allyProjectile',
        },
    },
    ['spark']={
        name='spark',
        moveSpeed=150,
        collider={
            w=3,
            h=3,
            class='allyProjectile',
        },
    },
    ['darkArrow']={
        name='darkArrow',
        moveSpeed=250,
        collider={
            w=3,
            h=3,
            class='enemyProjectile',
        },
    },
    ['pickaxe']={
        name='pickaxe',
        moveSpeed=130,
        collider={
            w=3,
            h=3,
            class='enemyProjectile',
        },
    },
    ['apple']={
        name='apple',
        moveSpeed=130,
        collider={
            w=3,
            h=3,
            class='enemyProjectile',
        },
    },
    ['jack-o-lantern']={
        name='jack-o-lantern',
        moveSpeed=150,
        explosionRadius=50,
        collider={
            w=12,
            h=8,
            class='enemyProjectile',
        },
        particles={
            count=300,
            spread={x=6, y=5},
            yOffset=18,
            maxSpeed=12,
            colors={
                [0xe3c25b]=4,
                [0xe39347]=2,
                [0xe56f4b]=1,
            }
        },
        shake={magnitude=5},
    },
    ['blueSpark']={
        name='blueSpark',
        moveSpeed=150,
        collider={
            w=3,
            h=3,
            class='enemyProjectile',
        },
    },
    ['mug']={
        name='mug', moveSpeed=130,
        collider={w=3, h=3, class='enemyProjectile'}
    },
    ['bottle']={
        name='bottle', moveSpeed=130,
        collider={w=3, h=3, class='enemyProjectile'}
    },
    ['candle']={
        name='candle', moveSpeed=130,
        collider={w=3, h=3, class='enemyProjectile'}
    },
    ['fireball']={
        name='fireball',
        moveSpeed=200,
        explosionRadius=50,
        collider={
            w=6,
            h=6,
            class='allyProjectile',
        },
        animation={
            frameWidth=16,
            frameHeight=10,
            frames='1-4',
            durations=0.1,
        },
        particles={
            count=200,
            spread={x=4, y=3},
            yOffset=18,
            maxSpeed=8,
            colors={
                [0xe3c25b]=2,
                [0xe39347]=3,
                [0xe56f4b]=1,
            }
        },
        shake={magnitude=2},
    },
    ['blizzard']={
        name='blizzard',
        moveSpeed=80,
        travelTime=4,
        collider={
            w=10,
            h=6,
            class='intangible',
        },
        animation={
            frameWidth=28,
            frameHeight=24,
            frames='1-6',
            durations=0.07,
        },
        particles={
            count=10,
            spread={x=5, y=4},
            yOffset=15,
            colors={
                [0x769fa6]=4,
                [0xede4da]=1,
                [0x668da9]=1,
                [0x5c699f]=1,
            }
        }
    },
    ['laser']={
        name='laser',
        moveSpeed=250,
        collider={
            w=3,
            h=3,
            class='enemyProjectile',
        },
    },
    ['pyre']={
        name='pyre',
        moveSpeed=100,
        travelTime=2,
        collider={
            w=8,
            h=6,
            class='intangible',
        },
        animation={
            frameWidth=10,
            frameHeight=12,
            frames='1-4',
            durations=0.1,
        },
    },
    ['orb']={
        name='orb',
        moveSpeed=100,
        explosionRadius=60,
        travelTime=20,
        collider={
            w=6,
            h=6,
            class='intangible',
        },
        particles={
            count=400,
            spread={x=6, y=6},
            yOffset=18,
            maxSpeed=14,
            colors={
                [0xe3c25b]=2,
                [0xe39347]=3,
                [0xe56f4b]=1,
            }
        },
        shake={magnitude=10},
    },
    ['obsidianFireball']={
        name='obsidianFireball',
        moveSpeed=150,
        explosionRadius=50,
        collider={
            w=10,
            h=8,
            class='enemyProjectile',
        },
        animation={
            frameWidth=16,
            frameHeight=10,
            frames='1-4',
            durations=0.1,
        },
        particles={
            count=300,
            spread={x=6, y=5},
            yOffset=18,
            maxSpeed=12,
            colors={
                [0xeeb551]=1,
                [0xe39347]=1,
                [0xe56f4b]=1,
                [0xb24c4c]=1,
            }
        },
        shake={magnitude=5},
    },
}

local generateDrawData=function(defs)
    local sprites,anims={},{}
    for p,def in pairs(defs) do 
        local path='assets/projectiles/'..def.name..'.png'
        sprites[p]=love.graphics.newImage(path)

        if def.animation then 
            local animDef=def.animation 
            local grid=anim8.newGrid(
                animDef.frameWidth,animDef.frameHeight,
                sprites[p]:getWidth(),animDef.frameHeight 
            )
            anims[p]=anim8.newAnimation(grid(animDef.frames,1),animDef.durations)
        end
    end
    return sprites,anims 
end
local sprites,animations=generateDrawData(projectileDefinitions)

local generateParticleEmitters=function(defs)
    local emitters={}
    for name,def in pairs(defs) do
        if def.particles~=nil then 
            emitters[name]=ParticleSystem:generateEmitter(def.particles)
        end
    end
    return emitters 
end
local particleEmitters=generateParticleEmitters(projectileDefinitions)

--Defining how a projectile behaves upon collisions.
local projectileOnHitFunctions=function()
    local onHitFunctions={
    
        --damages targets, destroys upon hitting solids
        ['base']=function(self,target,touch)
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then return false end

            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                target:takeDamage({
                    damage=self.attack.damage,
                    knockback=self.attack.knockback,
                    angle=getAngle(self.center,target.center),
                }) 
                return false
            end 
        end,
    
        --damages and sets targets on fire, destroys upon hitting solids
        ['flame']=function(self,target,touch)
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then return false end

            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                target:takeDamage({
                    damage=self.attack.damage,
                    knockback=self.attack.knockback,
                    angle=getAngle(self.center,target.center),
                    textColor='red'
                })
                if target.state~='dead' then 
                    target.status:burn(self.attack.damage,3) --apply 3sec burn
                end 
                return false
            end 
        end,
    
        --damages and freezes targets, destroys upon hitting solids
        ['icicle']=function(self,target,touch)
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then return false end
               
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                target:takeDamage({
                    damage=self.attack.damage,
                    knockback=self.attack.knockback,
                    angle=getAngle(self.center,target.center),
                    textColor='blue'
                })
                if target.state~='dead' then 
                    target.status:freeze(target,1,0.5) --slow to half speed for 1s
                end
                return false
            end 
        end,

        --damages targets, bounces off solids
        ['spark']=function(self,target,touch)     
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then 
                local angle=getAngle(touch,self)
                self.vx=cos(angle)*self.moveSpeed 
                self.vy=sin(angle)*self.moveSpeed
                self.angle=angle
                return
            end
               
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                target:takeDamage({
                    damage=self.attack.damage,
                    knockback=self.attack.knockback,
                    angle=getAngle(self.center,target.center),
                    textColor='yellow'
                })
                return false
            end 
        end,

        --damages all targets within AOE upon hitting a target or solid
        ['explode']=function(self,target,touch) 
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            or target.collisionClass=='solid'
            or target.collisionClass=='exit'
            then 
                local queryData={
                    x=self.x-self.explosionRadius*0.5,
                    y=self.y-self.explosionRadius*0.5,
                    w=self.explosionRadius,h=self.explosionRadius
                }
                local filter=World.queryFilters.enemy
                if self.collisionClass=='enemyProjectile' then 
                    filter=World.queryFilters.ally
                end
                local targets=World:queryRect(
                    queryData.x,queryData.y,queryData.w,queryData.h,filter
                )
                for i=1,#targets do 
                    local target=targets[i]
                    target:takeDamage({                 
                        damage=self.attack.damage,
                        knockback=self.attack.knockback,
                        angle=getAngle(self.center,targets[i].center),
                        textColor='red',
                    })
                    if target.state~='dead' then 
                        target.status:burn(self.attack.damage*0.5,5) --burn for 5s
                    end
                end
                self.particles:emit(self.center.x,self.center.y)
                if self.shake then 
                    local shake=self.shake 
                    Camera:shake({
                        magnitude=shake.magnitude,
                        period=shake.period,
                        damping=shake.damping,
                        stopThreshold=shake.stopThreshold,
                    })
                end
                return false
            end 
        end,
        
        --bounces off solids, slows each bounce
        ['blizzard']=function(self,target,touch)     
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then 
                self.moveSpeed=self.moveSpeed*0.9
                local angle=getAngle(touch,self)
                self.vx=cos(angle)*self.moveSpeed 
                self.vy=sin(angle)*self.moveSpeed
                self.angle=angle
            end
        end,    

        --bounces off solids, speeds up each bounce
        ['orb']=function(self,target,touch)     
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then 
                self.moveSpeed=self.moveSpeed*1.2
                self.moveSpeed=(min(self.moveSpeed,300))
                local angle=getAngle(touch,self)
                self.vx=cos(angle)*self.moveSpeed 
                self.vy=sin(angle)*self.moveSpeed
                self.angle=angle
            end
        end,    

        --damages and freezes targets, bounces off solids
        ['laser']=function(self,target,touch)     
            if target.collisionClass=='solid' 
            or target.collisionClass=='exit' 
            then 
                local angle=getAngle(touch,self)
                self.vx=cos(angle)*self.moveSpeed 
                self.vy=sin(angle)*self.moveSpeed
                self.angle=angle
                return
            end
               
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                target:takeDamage({
                    damage=self.attack.damage,
                    knockback=self.attack.knockback,
                    angle=getAngle(self.center,target.center),
                    textColor='blue'
                })
                if target.state~='dead' then 
                    target.status:freeze(target,1,0.5) --slow to half speed for 1s
                end
                return false
            end 
        end,
    }

    onHitFunctions['jack-o-lantern']=onHitFunctions.explode
    onHitFunctions['blueSpark']=onHitFunctions.spark
    onHitFunctions['fireball']=onHitFunctions.explode
    onHitFunctions['pyre']=onHitFunctions.blizzard
    onHitFunctions['obsidianFireball']=onHitFunctions.explode

    return onHitFunctions
end

--Defining how a projectile travels.
local projectileUpdateFunctions=function()
    local updateFunctions={

        --Travel in a straight line until hitting an target, solid wall, or expiring.
        ['base']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt 
            if self.remainingTravelTime<0
            or getDistance(self.center,Camera.target)>600 
            then 
                return false
            end

            if self.animation then self.animation:update(dt) end 
    
            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 
            local c=getCenter(self)
            self.center.x,self.center.y=c.x,c.y

            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,
    
        --Changes directions rapidly (every 0.1s-0.5s), 
        ['spark']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt
            if self.remainingTravelTime<0 
            or getDistance(self,Camera.target)>400 
            then
                return false
            end

            if self.animation then self.animation:update(dt) end 
    
            if self.changeDirectionTime==nil then
                self.changeDirectionTime=rnd()*0.5
                self.angles={}            
                for i=1,20 do -- (-0.2pi,0.2pi) spread from current angle
                    table.insert(self.angles,-(i*0.01*pi))
                    table.insert(self.angles,(i*0.01*pi))
                end
                self.angle=self.angle+(rndElement(self.angles))
                    
                --update direction
                local magnitude=getMagnitude(self.vy,self.vx)
                self.vx=cos(self.angle)*magnitude
                self.vy=sin(self.angle)*magnitude
            else
                self.changeDirectionTime=self.changeDirectionTime-dt 
                if self.changeDirectionTime<0 then 
                    self.changeDirectionTime=rnd()*0.5
                    self.angle=self.angle+(rndElement(self.angles))
                    
                    --update direction
                    local magnitude=getMagnitude(self.vy,self.vx)
                    self.vx=cos(self.angle)*magnitude
                    self.vy=sin(self.angle)*magnitude
                end
            end
            
            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 
            local c=getCenter(self)
            self.center.x,self.center.y=c.x,c.y

            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,

        --Travel in a straight line until hitting an target, solid wall, or expiring.
        --repeatedly queryies for nearby targets to damage and apply freeze.
        ['blizzard']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt 
            if self.remainingTravelTime<0
            or getDistance(self.center,Camera.target)>600 
            then 
                return false
            end

            if self.animation then self.animation:update(dt) end 

            if self.attackPeriod==nil then 
                self.attackPeriod=0.2
                self.attackTimer=0
            else
                self.attackTimer=self.attackTimer+dt 
                if self.attackTimer>self.attackPeriod then 
                    self.attackTimer=0
                    self.freezeArea={w=32,h=26}
                    local queryFilter=World.queryFilters.enemy 
                    local targets=World:queryRect(
                        self.center.x-self.freezeArea.w*0.5,
                        self.center.y-self.freezeArea.h*0.5,
                        self.freezeArea.w,self.freezeArea.h,queryFilter
                    )
                    for i=1,#targets do 
                        local target=targets[i]                  
                        target:takeDamage({                 
                            damage=self.attack.damage,
                            knockback=0,
                            angle=getAngle(self.center,targets[i].center),
                            textColor='blue',
                        })
                        if target.state~='dead' then 
                            target.status:freeze(target,0.5,0.25) --slow to 1/4 speed for 0.5s
                        end
                    end
                    self.particles:emit(self.center.x,self.center.y)
                end
            end

            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 
            local c=getCenter(self)
            self.center.x,self.center.y=c.x,c.y

            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,

        --every 0.2s, spawn a pyreTrail special attack
        ['pyre']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt 
            if self.remainingTravelTime<0
            or getDistance(self.center,Camera.target)>600 
            then 
                SpecialAttacks:spawnPyreTrail({
                    x=self.center.x,y=self.center.y,damage=self.attack.damage,
                    knockback=self.attack.knockback,yOffset=self.yOffset,
                })
                return false
            end

            if self.animation then self.animation:update(dt) end 

            if self.changeDirectionTime==nil then
                self.changeDirectionTime=rnd()*0.5
                self.angles={}            
                for i=1,20 do -- (-0.2pi,0.2pi) spread from current angle
                    table.insert(self.angles,-(i*0.01*pi))
                    table.insert(self.angles,(i*0.01*pi))
                end
                self.angle=self.angle+(rndElement(self.angles))
                    
                --update direction
                local magnitude=getMagnitude(self.vy,self.vx)
                self.vx=cos(self.angle)*magnitude
                self.vy=sin(self.angle)*magnitude
            else
                self.changeDirectionTime=self.changeDirectionTime-dt 
                if self.changeDirectionTime<0 then 
                    self.changeDirectionTime=rnd()*0.5
                    self.angle=self.angle+(rndElement(self.angles))
                    
                    --update direction
                    local magnitude=getMagnitude(self.vy,self.vx)
                    self.vx=cos(self.angle)*magnitude
                    self.vy=sin(self.angle)*magnitude
                end
            end
            
            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 
            local c=getCenter(self)
            self.center.x,self.center.y=c.x,c.y

            --spawn a pyreTrail every 0.1s
            if self.attackPeriod==nil then 
                self.attackPeriod=0.1
                self.attackTimer=0
            else
                self.attackTimer=self.attackTimer+dt 
                if self.attackTimer>self.attackPeriod then 
                    self.attackTimer=0
                    SpecialAttacks:spawnPyreTrail({
                        x=self.center.x,y=self.center.y,damage=self.attack.damage,
                        knockback=self.attack.knockback,yOffset=self.yOffset,
                    })
                end
            end
            
            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,

        --Same as base, except will randomly explode during travel
        ['orb']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt 
            if self.remainingTravelTime<0
            or getDistance(self.center,Camera.target)>600 
            then 
                return false
            end

            if self.animation then self.animation:update(dt) end 

            if self.attackPeriod==nil then --will decide on exploding every 0.5s
                self.attackPeriod=0.5
                self.attackTimer=0
            else 
                self.attackTimer=self.attackTimer+dt 
                if self.attackTimer>self.attackPeriod then 
                    self.attackTimer=0

                    --chance to explode increases as orb travels
                    if rnd(ceil(self.remainingTravelTime))==1 then 
                        local queryData={
                            x=self.x-self.explosionRadius*0.5,
                            y=self.y-self.explosionRadius*0.5,
                            w=self.explosionRadius,h=self.explosionRadius
                        }
                        local filter=World.queryFilters.ally
                        local targets=World:queryRect(
                            queryData.x,queryData.y,queryData.w,queryData.h,filter
                        )
                        for i=1,#targets do 
                            local target=targets[i]
                            target:takeDamage({                 
                                damage=self.attack.damage,
                                knockback=self.attack.knockback,
                                angle=getAngle(self.center,targets[i].center),
                                textColor='red',
                            })
                            if target.state~='dead' then 
                                target.status:burn(self.attack.damage*0.5,5) --burn for 5s
                            end
                        end
                        self.particles:emit(self.center.x,self.center.y)
                        if self.shake then 
                            local shake=self.shake 
                            Camera:shake({
                                magnitude=shake.magnitude,
                                period=shake.period,
                                damping=shake.damping,
                                stopThreshold=shake.stopThreshold,
                            })
                        end
                        return false
                    end
                end
            end
    
            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 
            local c=getCenter(self)
            self.center.x,self.center.y=c.x,c.y

            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,
    } 

    updateFunctions['blueSpark']=updateFunctions.spark

    return updateFunctions
end

--Defining how a projectile is drawn
local projectileDrawFunctions=function()
    local drawFunctions={
        
        --Projectile is angled toward its initial direction
        ['base']=function(self)
            self.shadow:draw(self.x,self.y,self.angle)
            if self.animation then 
                self.animation:draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    self.angle,1,1,self.xOrigin,self.yOrigin
                )
            else 
                love.graphics.draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    self.angle,1,1,self.xOrigin,self.yOrigin
                )
            end
        end,
    
        --Projectile randomly rotates each frame
        ['spark']=function(self)
            self.rotation=rnd()*6
            self.shadow:draw(self.x,self.y,self.rotation)
            if self.animation then 
                self.animation:draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    self.rotation,1,1,self.xOrigin,self.yOrigin
                )
            else
                love.graphics.draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    self.rotation,1,1,self.xOrigin,self.yOrigin
                )
            end
        end,

        --Projectile spins
        ['bone']=function(self)
            if self.vx>0 then self.rotation=self.rotation+dt*self.moveSpeed*0.15
            else self.rotation=self.rotation-dt*self.moveSpeed*0.15
            end
            self.shadow:draw(self.x,self.y,self.rotation)
            if self.animation then 
                self.animation:draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    self.rotation,1,1,self.xOrigin,self.yOrigin
                )
            else
                love.graphics.draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    self.rotation,1,1,self.xOrigin,self.yOrigin
                )
            end
        end,

        --Projectile doesn't rotate, but still faces the correct side
        ['apple']=function(self)
            self.shadow:draw(self.x,self.y)
            if self.animation then 
                self.animation:draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    nil,getSign(self.vx),1,self.xOrigin,self.yOrigin
                )
            else 
                love.graphics.draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    nil,getSign(self.vx),1,self.xOrigin,self.yOrigin
                )
            end
        end,

    }
    drawFunctions['pickaxe']=drawFunctions.bone
    drawFunctions['jack-o-lantern']=drawFunctions.apple
    drawFunctions['blueSpark']=drawFunctions.spark 
    drawFunctions['mug']=drawFunctions.bone 
    drawFunctions['bottle']=drawFunctions.bone 
    drawFunctions['candle']=drawFunctions.bone 
    drawFunctions['blizzard']=drawFunctions.apple
    drawFunctions['pyre']=drawFunctions.apple
    drawFunctions['orb']=drawFunctions.apple

    return drawFunctions
end

--Module
return {
    definitions=projectileDefinitions,
    sprites=sprites,
    animations=animations,
    particleEmitters=particleEmitters,
    onHitFunctions=projectileOnHitFunctions(),
    updateFunctions=projectileUpdateFunctions(),
    drawFunctions=projectileDrawFunctions(),

    --constructor
    new=function(self,args) --args={x,y,name,damage,knockback,angle,yOffset} 
        local def=self.definitions[args.name]
        local p={name=def.name} --projectile
    
        --Collider Data
        p.w,p.h=def.collider.w,def.collider.h
        p.x,p.y=args.x-p.w*0.5,args.y-p.h*0.5 --align center with spawn pos
        p.center=getCenter(p)
        p.collisionClass=def.collider.class
        p.filter=World.collisionFilters[p.collisionClass]
    
        --General data
        p.angle=args.angle
        p.rotation=rnd()*pi
        p.moveSpeed=def.moveSpeed
        p.attack={
            damage=args.damage,
            knockback=args.knockback
        } 
        p.explosionRadius=def.explosionRadius or nil
        p.remainingTravelTime=def.travelTime or (200/def.moveSpeed)*4 --2sec per 100units/sec
    
        --Draw data
        p.sprite=self.sprites[def.name]
        p.animation=def.animation and self.animations[def.name]:clone() or nil 
        p.xOffset=p.w*0.5
        p.yOffset=p.h*0.5+args.yOffset
        p.xOrigin=def.animation and def.animation.frameWidth*0.5 or p.sprite:getWidth()*0.5
        p.yOrigin=p.sprite:getHeight()*0.5
        p.shadow=Shadows:new(def.name,p.w,p.h)

        --Particle emitter
        p.particles=self.particleEmitters[p.name]
        p.shake=def.shake or nil
    
        --Methods (update and draw)
        p.onHit=self.onHitFunctions[p.name] or self.onHitFunctions.base 
        p.update=self.updateFunctions[p.name] or self.updateFunctions.base
        p.draw=self.drawFunctions[p.name] or self.drawFunctions.base
    
        --Set initial/launch velocity
        p.vx=cos(p.angle)*p.moveSpeed 
        p.vy=sin(p.angle)*p.moveSpeed
        
        World:addItem(p)
        table.insert(Objects.table,p)
        return p
    end,
}