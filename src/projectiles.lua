local projectiles={}

projectiles.definitions=function()
    return {
        arrow={
            name='arrow',
            moveSpeed=50,
            collider={
                width=3,
                height=3,
                corner=1,
            },
            drawData={
                offset={x=0,y=-9},
            },
        },
    }
end

function projectiles:load()
    self.definitions=self.definitions()
    self.updateFunctions={
        arrow=function(self)
            self.remainingTravelDistance=self.remainingTravelDistance-dt 
            if self.remainingTravelDistance<0 then 
                self.collider:destroy()
                return false
            end

            self.x,self.y=self.collider:getPosition()
            self.collider:applyForce(
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
        end,
    }
    self.drawFunctions={
        arrow=function(self)
            love.graphics.draw(
                self.sprite,self.x+self.offset.x,self.y+self.offset.y,
                self.angle,1,1,self.origin.x,self.origin.y
            )
        end,
    }
    
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
    p.collider:setLinearDamping(10)
    p.collider:setMass(1)
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
    p.remainingTravelDistance=p.moveSpeed/50

    --Draw data
    p.sprite=self.sprites[def.name]
    p.offset={x=def.drawData.offset.x,y=def.drawData.offset.y}
    p.origin={x=p.sprite:getWidth()*0.5,y=p.sprite:getHeight()*0.5}

    --Methods (update and draw)
    p.update=self.updateFunctions[p.name]
    p.draw=self.drawFunctions[p.name]

    p.collider:setLinearVelocity(cos(p.angle)*p.moveSpeed,sin(p.angle)*p.moveSpeed)
    
    table.insert(Objects.table,p)
    return p
end

return projectiles