local projectileDefinitions=function()
    return {
        arrow={
            name='arrow',
            moveSpeed=300,
            collider={
                width=1,
                height=1,
            },
        },
        flame={
            name='flame',
            moveSpeed=200,
            collider={
                width=1,
                height=1,
            },
        },
        icicle={
            name='icicle',
            moveSpeed=160,
            collider={
                width=1,
                height=1,
            },
        },
        spark={
            name='spark',
            moveSpeed=150,
            collider={
                width=1,
                height=1,
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

local projectileUpdateFunctions=function()
    local fns={}

    fns.base=function(self)
        self.remainingTravelTime=self.remainingTravelTime-dt 
        if self.remainingTravelTime<0 then 
            self:destroy()
            return false
        end

        self.x,self.y=self:getPosition()

        if self:enter('enemy') then
            local data=self:getEnterCollisionData('enemy')    
            local enemy=data.collider:getObject()
            if enemy~=nil then
                enemy:takeDamage(self)
                self:destroy()
                return false
            end
        end 

        if self:enter('solid') then --destroy upon hitting a wall
            self:destroy() 
            return false 
        end
    end

    fns.spark=function(self)
        self.remainingTravelTime=self.remainingTravelTime-dt 
        if self.remainingTravelTime<0 then 
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
            local enemy=data.collider:getObject()
            if enemy~=nil then
                enemy:takeDamage(self)
                self:destroy()
                return false
            end
        end 
    end
    
    fns.bone=fns.base 
    fns.arrow=fns.base 
    fns.flame=fns.base
    fns.icicle=fns.base

    return fns 
end

local projectileDrawFunctions=function()
    return function(self)
        self.shadow:draw(self.x,self.y,self.angle)
        love.graphics.draw(
            self.sprite,self.x,self.y+self.yOffset,
            self.angle,1,1,self.origin.x,self.origin.y
        )
    end
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
projectiles.updateFunctions=projectileUpdateFunctions()
projectiles.drawFunction=projectileDrawFunctions()
projectiles.createCollider=projectileCreateCollider()

function projectiles:new(args)
    local def=self.definitions[args.name]    
    local colliderType=def.collider.type or 'rectangle'

    --Collider 
    local p=self.createCollider[colliderType](args.x,args.y,def.collider)
    p:setBullet(true)
    p:setCollisionClass('projectile')
    p:setFixedRotation(true)

    --General data
    p.name=args.name
    p.x,p.y=p:getPosition()
    p.attackDamage=args.attackDamage
    p.knockback=args.knockback
    p.angle=args.angle
    p.moveSpeed=def.moveSpeed
    p.remainingTravelTime=(200/def.moveSpeed)*2 --1sec per 100units/sec

    --Draw data
    p.sprite=self.sprites[def.name]
    p.yOffset=args.yOffset
    p.origin={x=p.sprite:getWidth()*0.5,y=p.sprite:getHeight()*0.5}
    p.shadow=Shadows:new(def.name)

    --Methods (update and draw)
    p.update=self.updateFunctions[p.name]
    p.draw=self.drawFunction

    p:setLinearVelocity( --initial velocity (launch)
        cos(p.angle)*p.moveSpeed,sin(p.angle)*p.moveSpeed
    )
    
    table.insert(Objects.table,p)
    return p
end

return projectiles