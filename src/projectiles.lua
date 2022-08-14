local projectiles={}

projectiles.definitions=function()
    return {
        arrow={
            name='arrow',
            moveSpeed=300,
            collider={
                width=3,
                height=3,
                corner=1,
            },
        },
        flame={
            name='flame',
            moveSpeed=200,
            collider={
                width=3,
                height=3,
                corner=1,
            },
        },
        icicle={
            name='icicle',
            moveSpeed=160,
            collider={
                width=3,
                height=3,
                corner=1,
            },
        },
        spark={
            name='spark',
            moveSpeed=150,
            collider={
                width=3,
                height=3,
                corner=1,
            },
        },
    }
end

function projectiles:load()
    self.definitions=self.definitions()
    self.updateFunctions={}
    self.updateFunctions.base=function(self)
        self.remainingTravelTime=self.remainingTravelTime-dt 
        if self.remainingTravelTime<0 then 
            self.collider:destroy()
            return false
        end

        self.x,self.y=self.collider:getPosition()

        if self.collider:enter('enemy') then
            local data=self.collider:getEnterCollisionData('enemy')    
            local enemy=data.collider:getObject()
            if enemy~=nil then
                enemy:takeDamage(self)
                self.collider:destroy()
                return false
            end
        end 

        if self.collider:enter('solid') then --destroy upon hitting a wall
            self.collider:destroy() 
            return false 
        end
    end
    self.updateFunctions.arrow=self.updateFunctions.base 
    self.updateFunctions.flame=self.updateFunctions.base
    self.updateFunctions.icicle=self.updateFunctions.base

    self.updateFunctions.spark=function(self)
        self.remainingTravelTime=self.remainingTravelTime-dt 
        if self.remainingTravelTime<0 then 
            self.collider:destroy()
            return false
        end

        if self.changeDirectionTime==nil then 
            self.changeDirectionTime=0.1
            self.angles={}            
            for i=1,20 do -- (-0.2pi,0.2pi) spread from current angle
                table.insert(self.angles,-(i*0.01*math.pi))
                table.insert(self.angles,(i*0.01*math.pi))
            end
            self.angle=self.angle+(self.angles[rnd(#self.angles)])
        else
            self.changeDirectionTime=self.changeDirectionTime-dt 
            if self.changeDirectionTime<0 then 
                self.changeDirectionTime=0.1
                self.angle=self.angle+(self.angles[rnd(#self.angles)])
            end
        end

        self.x,self.y=self.collider:getPosition()
        self.collider:setLinearVelocity(
            cos(self.angle)*self.moveSpeed,sin(self.angle)*self.moveSpeed
        )

        if self.collider:enter('enemy') then
            local data=self.collider:getEnterCollisionData('enemy')    
            local enemy=data.collider:getObject()
            if enemy~=nil then
                enemy:takeDamage(self)
                self.collider:destroy()
                return false
            end
        end 
    end

    self.drawFunction=function(self)
        love.graphics.draw(
            self.sprite,self.x,self.y+self.yOffset,
            self.angle,1,1,self.origin.x,self.origin.y
        )
    end
    
    self.sprites={}
    for p,def in pairs(self.definitions) do 
        local path='assets/projectiles/'..def.name..'.png'
        self.sprites[p]=love.graphics.newImage(path)
    end
end

function projectiles:new(_args)
    local def=self.definitions[_args.name]    
    local p={name=_args.name}

    --Collider 
    p.collider=World:newBSGRectangleCollider(
        _args.x,_args.y,def.collider.width,
        def.collider.height,def.collider.corner
    )
    p.collider:setBullet(true)
    p.collider:setCollisionClass('projectile')
    p.collider:setFixedRotation(true)
    p.collider:setObject(p)

    --General data
    p.x,p.y=p.collider:getPosition()
    p.attackDamage=_args.attackDamage
    p.knockback=_args.knockback
    p.angle=_args.angle
    p.moveSpeed=def.moveSpeed
    p.remainingTravelTime=(200/def.moveSpeed)*2 --1s per 100 movespeed

    --Draw data
    p.sprite=self.sprites[def.name]
    p.yOffset=_args.yOffset
    p.origin={x=p.sprite:getWidth()*0.5,y=p.sprite:getHeight()*0.5}

    --Methods (update and draw)
    p.update=self.updateFunctions[p.name]
    p.draw=self.drawFunction

    p.collider:setLinearVelocity(
        cos(p.angle)*p.moveSpeed,sin(p.angle)*p.moveSpeed
    )
    
    table.insert(Objects.table,p)
    return p
end

return projectiles