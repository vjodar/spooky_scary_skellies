local paletteInHex={
    0x000000, 0xf6f0eb, 0xd6cec7, 0xede4da, 0xbfb8b4,
    0x918d8d, 0x636167, 0x4c4b54, 0x41404a, 0x353540,
    0x302e38, 0xd2c1b1, 0xbdaa97, 0x7e674c, 0x86735b,
    0x735b42, 0x604b3d, 0x5d483c, 0x4d3f38, 0xb24c4c,
    0xca5954, 0xe56f4b, 0xe39347, 0xeeb551, 0xe3c25b,
    0xbda351, 0x8b9150, 0x557d55, 0x446350, 0x3b5247,
    0x80aaa7, 0x6fa6a5, 0x769fa6, 0x668da9, 0x5c699f,
    0x5a5888, 0x7c6da2, 0x947a9d, 0xbc87a5, 0xd9a6a6,
}

--https://love2d.org/forums/viewtopic.php?t=86347
local getRGB=function(hex)
    -- clamp between 0x000000 and 0xffffff
    hex = hex%0x1000000 -- 0xffffff + 1

    -- extract each color
    local b = hex%0x100 -- 0xff + 1 or 256
    local g = (hex - b)%0x10000 -- 0xffff + 1
    local r = (hex - g - b)
    -- shift right
    g = g/0x100 -- 0xff + 1 or 256
    r = r/0x10000 -- 0xffff + 1

    return {r/255, g/255, b/255}
end 

local generatePalette=function(hexTable)
    local palette={}

    for i=1,#hexTable do 
        local hexVal=hexTable[i]
        palette[hexVal]=getRGB(hexVal)
    end

    return palette 
end

local generateRGBColorTable=function(self,colorsDef)
    local RGBTable={}

    --insert a hex's corresponding RBG 'weight' amount of times into the table
    for hex,weight in pairs(colorsDef) do 
        for i=1,weight do table.insert(RGBTable,self.palette[hex]) end
    end
    return RGBTable 
end

local pSystem={ --The Module
    table={},
    palette=generatePalette(paletteInHex),
    borderColor={53/255,53/255,64/255},
    generateRGBColorTable=generateRGBColorTable,
    update=function(self)
        for i,p in ipairs(self.table) do 
            if p:update()==false then table.remove(self.table,i) end 
        end
    end,
    draw=function(self) for i=1,#self.table do self.table[i]:draw() end end,
    particleUpdate=function(self)
        self.x=self.x+self.vx*dt
        self.y=self.y+self.vy*dt 
        self.vx=self.vx-(self.vx*self.linearDamping*dt)
        self.vy=self.vy-(self.vy*self.linearDamping*dt)
        self.duration=self.duration-dt 
        if self.duration<0 then 
            if self.willHealPlayer then
                self.speed=300
                self.update=self.travelToPlayer 
                return
            end 
            return false 
        end
    end,
    particleTravelToPlayer=function(self)
        if Player.state=='dead' then return false end 
        local target={x=Player.center.x, y=Player.center.y-8}
        if getDistance(self,target)<10 then 
            Player:updateHealth(0.1) --heal the player
            return false 
        end 
        local angle=getAngle(self,target)
        self.vx=cos(angle)*self.speed
        self.vy=sin(angle)*self.speed
        self.x=self.x+self.vx*dt 
        self.y=self.y+self.vy*dt
    end,
    particleDraw=function(self)
        love.graphics.setColor(self.borderColor)     
        for i=-1,1 do 
            for j=-1,1 do 
                love.graphics.points(self.x+i,self.y+j)
            end
        end
        love.graphics.setColor(self.color)
        love.graphics.points(self.x,self.y)
        love.graphics.setColor(1,1,1)
    end,
    addParticles=function(self,args)
        for i=1,args.count do 
            local angle=rnd()*2*pi 
            local speed=rnd()*args.maxSpeed 
            local startX=args.x+cos(angle)*rnd()*args.xSpread
            local startY=args.y+sin(angle)*rnd()*args.ySpread
            local vx=cos(angle)*speed*60
            local vy=sin(angle)*speed*60
            local duration=speed<3 and speed*0.2 or speed*0.05
            local linearDamping=5+rnd()*20
            local particle={
                x=startX, y=startY, 
                vx=vx, vy=vy, duration=duration,
                linearDamping=linearDamping, 
                color=rndElement(args.colors),
                borderColor=self.borderColor,
                willHealPlayer=args.willHealPlayer,             
                update=self.particleUpdate,
                travelToPlayer=self.particleTravelToPlayer,
                draw=self.particleDraw,
            }
            table.insert(self.table,particle)
        end
    end,
    emitParticles=function(self,x,y)
        ParticleSystem:addParticles({
            x=x, y=y-self.yOffset, count=self.count, maxSpeed=self.maxSpeed,
            xSpread=self.xSpread, ySpread=self.ySpread, colors=self.colors, 
            willHealPlayer=self.willHealPlayer,
        })
    end,
    generateEmitter=function(self,particlesDef) 
        local def=particlesDef
        return { --particle emitter constructor
            count=def.count,
            xSpread=def.spread.x,
            ySpread=def.spread.y,
            yOffset=def.yOffset,
            maxSpeed=def.maxSpeed or 10,
            colors=self:generateRGBColorTable(def.colors),
            willHealPlayer=def.willHealPlayer,
            emit=self.emitParticles,
        }
    end,
}
return pSystem