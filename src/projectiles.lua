local projectileDefinitions=function()
    return {
        bone={
            name='bone',
            moveSpeed=100,
            collider={
                w=3,
                h=3,
                class='allyProjectile',
            }
        },
        arrow={
            name='arrow',
            moveSpeed=300,
            collider={
                w=3,
                h=3,
                class='allyProjectile',
            },
        },
        flame={
            name='flame',
            moveSpeed=200,
            collider={
                w=3,
                h=3,
                class='allyProjectile',
            },
        },
        icicle={
            name='icicle',
            moveSpeed=160,
            collider={
                w=3,
                h=3,
                class='allyProjectile',
            },
        },
        spark={
            name='spark',
            moveSpeed=150,
            collider={
                w=3,
                h=3,
                class='allyProjectile',
            },
        },
    }
end

local projectileSprites=function(defs)
    local sprites={}
    for p,def in pairs(defs) do 
        local path='assets/projectiles/'..def.name..'.png'
        sprites[p]=love.graphics.newImage(path)
    end
    return sprites 
end

--Defining how a projectile behaves upon collisions.
local projectileOnHitFunctions=function()
    return {
    
        base=function(self,target) 
            if target.state=='dead' then return end  
            target:takeDamage(self) 
        end,
    
        flame=function(self,target)
            if target.state=='dead' then return end 
            target:takeDamage(self)
            --TODO: AOE burning effect
        end,
    
        icicle=function(self,target)
            if target.state=='dead' then return end 
            target:takeDamage(self)
            --TODO: freeze/slow target
        end,
        
    }
end

--Defining how a projectile travels.
local projectileUpdateFunctions=function()
    return {

        --Travel in a straight line until hitting an target, solid wall, or expiring.
        base=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt 
            if self.remainingTravelTime<0
            or getDistance(self,Camera.target)>400 
            then 
                World:remove(self)
                return false
            end
    
            --update position
            local goalX=self.x+self.vx*dt 
            local goalY=self.y+self.vy*dt 
            local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
            self.x,self.y=realX,realY 

            --handle collisions
            for i=1,#cols do 
                local other=cols[i].other 
                local touch=cols[i].touch 

                if other.collisionClass=='enemy' then
                    self:onHit(other)
                    World:remove(self)
                    return false 
                end 

                if other.collisionClass=='solid' then 
                    World:remove(self)
                    return false 
                end
            end
        end,
    
        --Changes directions rapidly (every 0.1s-0.5s), bounces off solid walls.
        spark=function(self)
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

            --handle collisions
            for i=1,#cols do 
                local other=cols[i].other 
                local touch=cols[i].touch 

                if other.collisionClass=='enemy' then
                    self:onHit(other)
                    World:remove(self)
                    return false 
                end 

                if other.collisionClass=='solid' then 
                    --TODO: setup bounce off solid objects behavior
                end
            end    
        end,

    }
end

--Defining how a projectile is drawn
local projectileDrawFunctions=function()
    return {
        
        --Projectile is angled toward its initial direction
        base=function(self)
            self.shadow:draw(self.x,self.y,self.angle)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                self.angle,1,1,self.xOrigin,self.yOrigin
            )
        end,
    
        --Projectile randomly rotates each frame
        spark=function(self)
            self.rotation=rnd()*6
            self.shadow:draw(self.x,self.y,self.rotation)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                self.rotation,1,1,self.xOrigin,self.yOrigin
            )
        end,

        --Projectile spins
        bone=function(self)
            self.rotation=self.rotation+dt*self.moveSpeed*0.15
            self.shadow:draw(self.x,self.y,self.rotation)
            love.graphics.draw(
                self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                self.rotation,1,1,self.xOrigin,self.yOrigin
            )
        end,

    }
end

local projectiles={}
projectiles.definitions=projectileDefinitions()
projectiles.sprites=projectileSprites(projectiles.definitions)
projectiles.onHitFunctions=projectileOnHitFunctions()
projectiles.updateFunctions=projectileUpdateFunctions()
projectiles.drawFunctions=projectileDrawFunctions()

function projectiles:new(args) --args={x,y,name,attackDamage,knockback,yOffset}
    local def=self.definitions[args.name]
    local p={name=def.name} --projectile

    --Collider Data
    p.x,p.y=args.x,args.y 
    p.w,p.h=def.collider.w,def.collider.h
    p.collisionClass=def.collider.class
    p.filter=World.collisionFilters[p.collisionClass]

    --General data
    p.angle=args.angle
    p.attackDamage=args.attackDamage
    p.knockback=args.knockback
    p.rotation=rnd()*pi
    p.moveSpeed=def.moveSpeed
    p.remainingTravelTime=(200/def.moveSpeed)*2 --1sec per 100units/sec

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
end

return projectiles