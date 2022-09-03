local projectileDefinitions=function()
    return {
        ['bone']={
            name='bone',
            moveSpeed=150,
            collider={
                w=3,
                h=3,
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
            moveSpeed=300,
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
                w=5,
                h=5,
                class='enemyProjectile',
            },
        },
    }
end

local projectileSprites=function()
    local sprites={}
    for p,def in pairs(projectileDefinitions()) do 
        local path='assets/projectiles/'..def.name..'.png'
        sprites[p]=love.graphics.newImage(path)
    end
    return sprites 
end

--Defining how a projectile behaves upon collisions.
local projectileOnHitFunctions=function()
    local onHitFunctions={
    
        --damages targets, destroys upon hitting solids
        ['base']=function(self,target,touch)
            if target.collisionClass=='solid' then 
                World:remove(self)
                return false
            end

            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                if target.state=='dead' then return end  
                target:takeDamage(self) 
                World:remove(self)
                return false
            end 
        end,
    
        --damages and sets targets on fire, destroys upon hitting solids
        ['flame']=function(self,target,touch)
            if target.collisionClass=='solid' then 
                World:remove(self)
                return false
            end

            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                if target.state=='dead' then return end  
                target:takeDamage(self)
                --TODO: set target on fire
                World:remove(self)
                return false
            end 
        end,
    
        --damages and freezes targets, destroys upon hitting solids
        ['icicle']=function(self,target,touch)
            if target.collisionClass=='solid' then 
                World:remove(self)
                return false
            end
               
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                if target.state=='dead' then return end  
                target:takeDamage(self)
                --TODO: freeze target
                World:remove(self)
                return false
            end 
        end,

        --damages targets, bounces off solids
        ['spark']=function(self,target,touch)     
            if target.collisionClass=='solid' then 
                local angle=getAngle(touch,self)
                self.vx=cos(angle)*self.moveSpeed 
                self.vy=sin(angle)*self.moveSpeed
                self.angle=angle
                return
            end
               
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            then 
                if target.state=='dead' then return end  
                target:takeDamage(self)
                --TODO: freeze target
                World:remove(self)
                return false
            end 
        end,

        --damages all targets within AOE upon hitting a target or solid
        ['explode']=function(self,target,touch) 
            if (self.collisionClass=='allyProjectile' and target.collisionClass=='enemy')
            or (self.collisionClass=='enemyProjectile' and target.collisionClass=='ally')
            or target.collisionClass=='solid'
            then 
                local queryData={
                    x=self.x-self.explosionRadius*0.5,
                    y=self.y-self.explosionRadius*0.5,
                    w=self.explosionRadius,h=self.explosionRadius
                }
                local filter=World.queryFilters.ally
                if self.collisionClass=='enemyProjectile' then 
                    filter=World.queryFilters.enemy
                end
                local targets=World:queryRect(
                    queryData.x,queryData.y,queryData.w,queryData.h,filter
                )
                for i=1,#targets do 
                    if targets[i].state~='dead' then targets[i]:takeDamage(self) end
                end
                World:remove(self)
                return false
            end 
        end,
        
    }

    onHitFunctions['jack-o-lantern']=onHitFunctions.explode

    return onHitFunctions
end

--Defining how a projectile travels.
local projectileUpdateFunctions=function()
    return {

        --Travel in a straight line until hitting an target, solid wall, or expiring.
        ['base']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt 
            if self.remainingTravelTime<0
            or getDistance(self.center,Camera.target.center)>600 
            then 
                World:remove(self)
                return false
            end
    
            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 
            self.center=getCenter(self)

            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,
    
        --Changes directions rapidly (every 0.1s-0.5s), bounces off solid walls.
        ['spark']=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt
            if self.remainingTravelTime<0 
            or getDistance(self,Camera.target)>400 
            then
                World:remove(self)
                return false
            end
    
            if self.changeDirectionTime==nil then
                self.changeDirectionTime=rnd()*0.5
                self.angles={}            
                for i=1,20 do -- (-0.2pi,0.2pi) spread from current angle
                    table.insert(self.angles,-(i*0.01*pi))
                    table.insert(self.angles,(i*0.01*pi))
                end
                self.angle=self.angle+(self.angles[rnd(#self.angles)])
                    
                --update direction
                local magnitude=getMagnitude(self.vy,self.vx)
                self.vx=cos(self.angle)*magnitude
                self.vy=sin(self.angle)*magnitude
            else
                self.changeDirectionTime=self.changeDirectionTime-dt 
                if self.changeDirectionTime<0 then 
                    self.changeDirectionTime=rnd()*0.5
                    self.angle=self.angle+(self.angles[rnd(#self.angles)])
                    
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
            self.center=getCenter(self)

            --handle collisions
            for i=1,#cols do return self:onHit(cols[i].other,cols[i].touch) end
        end,

    }
end

--Defining how a projectile is drawn
local projectileDrawFunctions=function()
    local drawFunctions={
        
        --Projectile is angled toward its initial direction
        ['base']=function(self)
            self.shadow:draw(self.x,self.y,self.angle)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                self.angle,1,1,self.xOrigin,self.yOrigin
            )
        end,
    
        --Projectile randomly rotates each frame
        ['spark']=function(self)
            self.rotation=rnd()*6
            self.shadow:draw(self.x,self.y,self.rotation)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                self.rotation,1,1,self.xOrigin,self.yOrigin
            )
        end,

        --Projectile spins
        ['bone']=function(self)
            if self.vx>0 then self.rotation=self.rotation+dt*self.moveSpeed*0.15
            else self.rotation=self.rotation-dt*self.moveSpeed*0.15
            end
            self.shadow:draw(self.x,self.y,self.rotation)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                self.rotation,1,1,self.xOrigin,self.yOrigin
            )
        end,

        --Projectile doesn't rotate, but still faces the correct side
        ['apple']=function(self)
            self.shadow:draw(self.x,self.y)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                nil,getSign(self.vx),1,self.xOrigin,self.yOrigin
            )
            -- if self.explosionRadius then 
            --     love.graphics.rectangle(
            --         'line',self.x-self.explosionRadius*0.5,
            --         self.y-self.explosionRadius*0.5,
            --         self.explosionRadius,self.explosionRadius
            --     )
            -- end
        end,

    }
    drawFunctions['pickaxe']=drawFunctions.bone
    drawFunctions['jack-o-lantern']=drawFunctions.apple

    return drawFunctions
end

--Module
return {
    definitions=projectileDefinitions(),
    sprites=projectileSprites(),
    onHitFunctions=projectileOnHitFunctions(),
    updateFunctions=projectileUpdateFunctions(),
    drawFunctions=projectileDrawFunctions(),

    --constructor
    new=function(self,args) --args={x,y,name,attackDamage,knockback,yOffset} 
        local def=self.definitions[args.name]
        local p={name=def.name} --projectile
    
        --Collider Data
        p.x,p.y=args.x,args.y 
        p.w,p.h=def.collider.w,def.collider.h
        p.center=getCenter(p)
        p.collisionClass=def.collider.class
        p.filter=World.collisionFilters[p.collisionClass]
    
        --General data
        p.angle=args.angle
        p.attackDamage=args.attackDamage
        p.knockback=args.knockback
        p.rotation=rnd()*pi
        p.moveSpeed=def.moveSpeed
        p.explosionRadius=def.explosionRadius or nil
        p.remainingTravelTime=(200/def.moveSpeed)*4 --2sec per 100units/sec
    
        --Draw data
        p.sprite=self.sprites[def.name]
        p.xOffset=p.w*0.5
        p.yOffset=p.h*0.5+args.yOffset
        p.xOrigin=p.sprite:getWidth()*0.5
        p.yOrigin=p.sprite:getHeight()*0.5
        p.shadow=Shadows:new(def.name,p.w,p.h)
    
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