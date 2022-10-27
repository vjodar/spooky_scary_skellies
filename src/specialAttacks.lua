local definitions={
    ['pyreTrail']={
        name='pyreTrail',
        travelTime=1,
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
}

local generateSprites=function(defs)
    local sprites,anims={},{}
    sprites['pyreTrail']=Projectiles.sprites.pyre 
    anims['pyreTrail']=Projectiles.animations.pyre 
    return sprites,anims 
end
local sprites,animations=generateSprites(defs)

local chainLightning=function(self,mage,targets,primary,secondary)
    local damage=mage.attack.damage / #targets --split damage equally
    local knockback=mage.attack.knockback
    local points={mage.center}

    for i=1,#targets do --damage all targets, add their centers to points table
        local t=targets[i]
        local prevPoint=points[#points]
        local currPoint=t.center 
        local angle=getAngle(prevPoint,currPoint)
        t:takeDamage({
            damage=damage, knockback=knockback, angle=angle, textColor='yellow'
        })
        table.insert(points,currPoint)
    end

    local cl={
        points=points,
        duration=0.1,
        primaryColor=self.colors[primary] or self.colors.yellow,
        secondaryColor=self.colors[secondary] or self.colors.white,
        width=GameScale,
        yOffset=-7,
        update=self.methods.chainLightning.update,
        drawLine=self.methods.chainLightning.drawLine,
        draw=self.methods.chainLightning.draw,
    }
    table.insert(self.table,cl)

    Audio:playSfx('chainLightning')
end

local spawnPyreTrail=function(self,args) --args={x,y,damage,knockback,yOffset}
    local def=self.definitions.pyreTrail 
    local pt={name='pyreTrail'} 

    --Collider Data
    local colliderDef=def.collider 
    pt.w,pt.h=colliderDef.w,colliderDef.h 
    pt.x=args.x-pt.w*0.5
    pt.y=args.y-pt.h*0.5
    pt.center=getCenter(pt)
    pt.collisionClass=colliderDef.class
    pt.filter=World.collisionFilters[pt.collisionClass]
    pt.queryFilter=World.queryFilters.ally 

    --General Data
    pt.attack={damage=args.damage, knockback=args.knockback, period=0.2}
    pt.duration=def.travelTime
    pt.timer=pt.attack.period

    --Draw Data    
    pt.sprite=self.sprites.pyreTrail 
    pt.animation=self.animations.pyreTrail:clone()
    pt.xOffset=pt.w*0.5
    pt.yOffset=pt.h*0.5+args.yOffset
    pt.xOrigin=def.animation.frameWidth*0.5
    pt.yOrigin=def.animation.frameHeight*0.5
    pt.shadow=Shadows:new(def.name,pt.w,pt.h)

    --Methods
    pt.update=self.methods.pyreTrail.update
    pt.draw=self.methods.pyreTrail.draw

    World:addItem(pt)
    table.insert(Objects.table,pt) --pyreTrail is a physical object
    return pt 
end

return {
    definitions=definitions,
    sprites=sprites,
    animations=animations,

    chainLightning=chainLightning,
    spawnPyreTrail=spawnPyreTrail,

    methods={
        chainLightning={
            update=function(self)
                self.duration=self.duration-dt 
                if self.duration<0 then return false end 
            end,
            drawLine=function(p1,p2,yOffset)
                love.graphics.line(p1.x,p1.y+yOffset,p2.x,p2.y+yOffset)
            end,
            draw=function(self)
                for i=1,#self.points-1 do 
                    local p1=self.points[i]
                    local p2=self.points[i+1]
                    love.graphics.setColor(self.primaryColor) --draw border
                    love.graphics.setLineWidth(self.width)
                    self.drawLine(p1,p2,self.yOffset)
                    love.graphics.setColor(self.secondaryColor) --draw inner line
                    love.graphics.setLineWidth(self.width*0.5)
                    self.drawLine(p1,p2,self.yOffset)
                    love.graphics.setColor(1,1,1) --reset color
                    love.graphics.setLineWidth(self.width) --reset line width
                end
            end,
        },

        pyreTrail={
            update=function(self)
                self.animation:update(dt)
                self.duration=self.duration-dt 
                if self.duration<0 then return false end 
                self.timer=self.timer+dt 
                if self.timer>self.attack.period then 
                    self.timer=0
                    local targets=World:queryRect(self.x,self.y,self.w,self.h,self.queryFilter)
                    for i=1,#targets do 
                        local target=targets[i]
                        target:takeDamage({
                            damage=self.attack.damage,
                            knockback=self.attack.knockback,
                            angle=getAngle(self.center,target.center),
                            textColor='red'
                        })
                    end
                end
            end,
            draw=function(self)
                self.shadow:draw(self.x,self.y)
                self.animation:draw(
                    self.sprite,self.x+self.xOffset,self.y+self.yOffset,
                    nil,1,1,self.xOrigin,self.yOrigin
                )
            end,
        },
    },

    colors={  
        yellow={227/255,194/255,91/255},
        white={237/255,228/255,218/255},
        purple={188/255,135/255,165/255},
        pink={217/255,166/255,166/255},
    },

    table={}, --holds specialAttack instances that aren't managed by Objects.lua
    update=function(self)
        for i,special in ipairs(self.table) do 
            if special:update()==false then table.remove(self.table,i) end 
        end
    end,
    draw=function(self)
        for i,special in ipairs(self.table) do special:draw() end
    end,
}