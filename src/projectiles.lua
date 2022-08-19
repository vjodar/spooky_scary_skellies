local projectileDefinitions=function()
    return {
        bone={
            name='bone',
            moveSpeed=100,
            collider={
                width=3,
                height=3,
                class='allyProjectile',
            }
        },
        arrow={
            name='arrow',
            moveSpeed=300,
            collider={
                width=3,
                height=3,
                class='allyProjectile',
            },
        },
        flame={
            name='flame',
            moveSpeed=200,
            collider={
                width=3,
                height=3,
                class='allyProjectile',
            },
        },
        icicle={
            name='icicle',
            moveSpeed=160,
            collider={
                width=3,
                height=3,
                class='allyProjectile',
            },
        },
        spark={
            name='spark',
            moveSpeed=150,
            collider={
                width=3,
                height=3,
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
            target:takeDamae(self)
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
                self:destroy()
                return false
            end
    
            self.x,self.y=self:getPosition()
    
            if self:enter('enemy') then
                local data=self:getEnterCollisionData('enemy')    
                local enemy=data.collider
                if enemy~=nil then
                    self:onHit(enemy)
                    self:destroy()
                    return false
                end
            end 
    
            if self:enter('solid') then
                self:destroy() 
                return false 
            end
        end,
    
        --Changes directions rapidly (every 0.1s-0.5s), bounces off solid walls.
        spark=function(self)
            self.remainingTravelTime=self.remainingTravelTime-dt
            if self.remainingTravelTime<0 
            or getDistance(self,Camera.target)>400 
            then
                self:destroy()
                return false
            end
    
            if self.changeDirectionTime==nil then
                self.changeDirectionTime=rnd()*0.5
                self.angles={}            
                for i=1,20 do -- (-0.2pi,0.2pi) spread from current angle
                    table.insert(self.angles,-(i*0.01*math.pi))
                    table.insert(self.angles,(i*0.01*math.pi))
                end
                self.angle=self.angle+(self.angles[rnd(#self.angles)])
            else
                self.changeDirectionTime=self.changeDirectionTime-dt 
                if self.changeDirectionTime<0 then 
                    self.changeDirectionTime=rnd()*0.5
                    self.angle=self.angle+(self.angles[rnd(#self.angles)])
                end
            end
    
            self.x,self.y=self:getPosition()
            self:setLinearVelocity(
                cos(self.angle)*self.moveSpeed,sin(self.angle)*self.moveSpeed
            )
    
            if self:enter('enemy') then
                local data=self:getEnterCollisionData('enemy')    
                local enemy=data.collider
                if enemy~=nil then
                    self:onHit(enemy)
                    self:destroy()
                    return false
                end
            end 
    
            --TODO: setup bounce off solid objects behavior
        end,

    }
end

--Defining how a projectile is drawn
local projectileDrawFunctions=function()
    return {
        
        --Projectile is angled toward it initial direction
        base=function(self)
            self.shadow:draw(self.x,self.y,self.angle)
            love.graphics.draw(
                self.sprite,self.x,self.y+self.yOffset,
                self.angle,1,1,self.origin.x,self.origin.y
            )
        end,
    
        --Projectile randomly rotates each frame
        spark=function(self)
            self.rotation=rnd()*6
            love.graphics.draw(
                self.sprite,self.x,self.y+self.yOffset,
                self.rotation,1,1,self.origin.x,self.origin.y
            )
        end,

        --Projectile spins
        bone=function(self)
            self.rotation=self.rotation+dt*20
            self.shadow:draw(self.x,self.y,self.rotation)
            love.graphics.draw(
                self.sprite,self.x,self.y+self.yOffset,
                self.rotation,1,1,self.origin.x,self.origin.y
            )
        end,

    }
end

--Creates a collider given a definition and position
local projectileCreateCollider=function()
    return {
        rectangle=function(x,y,cDef)
            return World:newRectangleCollider(x,y,cDef.width,cDef.height)
        end,
        bsg=function(x,y,cDef)
            return World:newBSGRectangleCollider(x,y,cDef.width,cDef.height,cDef.corner)
        end,
        circle=function(x,y,cDef)
            return World:newCircleCollider(x,y,cDef.radius)
        end,
    }
end

local projectiles={}
projectiles.definitions=projectileDefinitions()
projectiles.sprites=projectileSprites(projectiles.definitions)
projectiles.onHitFunctions=projectileOnHitFunctions()
projectiles.updateFunctions=projectileUpdateFunctions()
projectiles.drawFunctions=projectileDrawFunctions()
projectiles.createCollider=projectileCreateCollider()

function projectiles:new(args) --args={x,y,name,attackDamage,knockback,yOffset}
    local def=self.definitions[args.name]    
    local colliderType=def.collider.type or 'rectangle'

    --Collider 
    local p=self.createCollider[colliderType](args.x,args.y,def.collider)
    p:setBullet(true)
    p:setCollisionClass(def.collider.class)
    p:setFixedRotation(true)

    --General data
    p.name=args.name
    p.x,p.y=p:getPosition()
    p.attackDamage=args.attackDamage
    p.knockback=args.knockback
    p.angle=args.angle
    p.rotation=rnd()*3.15
    p.moveSpeed=def.moveSpeed
    p.remainingTravelTime=(200/def.moveSpeed)*2 --1sec per 100units/sec

    --Draw data
    p.sprite=self.sprites[def.name]
    p.yOffset=args.yOffset
    p.origin={x=p.sprite:getWidth()*0.5,y=p.sprite:getHeight()*0.5}
    p.shadow=Shadows:new(def.name)

    --Methods (update and draw)
    p.onHit=self.onHitFunctions[p.name] or self.onHitFunctions.base 
    p.update=self.updateFunctions[p.name] or self.updateFunctions.base
    p.draw=self.drawFunctions[p.name] or self.drawFunctions.base

    p:setLinearVelocity( --initial velocity (launch)
        cos(p.angle)*p.moveSpeed,sin(p.angle)*p.moveSpeed
    )
    
    table.insert(Objects.table,p)
    return p
end

return projectiles