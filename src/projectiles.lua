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
        arrow=function(_p)
            _p.x,_p.y=_p.collider:getPosition()
            _p.collider:applyForce(
                cos(_p.angle)*_p.moveSpeed,sin(_p.angle)*_p.moveSpeed
            )

            if _p.collider:enter('enemy') then
                local data=_p.collider:getEnterCollisionData('enemy')    
                local enemy=data.collider:getObject()
                if enemy~=nil then
                    enemy:takeDamage(_p)
                    _p.collider:destroy()
                    return false
                end
            end 
        end,
    }
    self.drawFunctions={
        arrow=function(_p)
            love.graphics.draw(
                _p.sprite,_p.x+_p.offset.x,_p.y+_p.offset.y,
                _p.angle,1,1,_p.origin.x,_p.origin.y
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

    --Draw data
    p.sprite=self.sprites[def.name]
    p.offset={x=def.drawData.offset.x,y=def.drawData.offset.y}
    p.origin={x=p.sprite:getWidth()*0.5,y=p.sprite:getHeight()*0.5}

    --Methods (update and draw)
    p.update=self.updateFunctions[p.name]
    p.draw=self.drawFunctions[p.name]

    p.collider:setLinearVelocity(cos(p.angle)*p.moveSpeed,sin(p.angle)*p.moveSpeed)
    
    table.insert(Entities.table,p)
    return p
end

return projectiles