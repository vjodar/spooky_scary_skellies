local generateFonts=function()
    local fonts={}

    local glyphs=(
        " abcdefghijklmnopqrstuvwxyz"..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
        "1234567890.:!,'+-/()"
    )

    local colors={'white','yellow','gray','blue','red','green'}
    for i=1,#colors do
        local path='assets/fonts/'..colors[i]..'.png'
        fonts[colors[i]]=love.graphics.newImageFont(path,glyphs)
    end

    love.graphics.setFont(fonts.white) --default to white

    return fonts 
end
local fonts=generateFonts()

local generateDamageSystem=function()
    local new=function(self,x,y,val,color) --damage object constructor
        local angle=-pi*(0.3+rnd()*0.4) --angle=[0.3pi,0.7pi]
        local moveSpeed=(3+(rnd()*3))*60 --speed=[3,6]
        local color=color or 'gray'
        local font=self.fonts[color]
        local d={
            x=x+rnd(-8,8), y=y-rnd(10), val=val,
            vx=cos(angle)*moveSpeed,
            vy=sin(angle)*moveSpeed,
            font=font,
            linearDamping=7,
            stopThreshold=3*60,
            holdTime=0.3,
            update=function(self)
                --update position
                self.x=self.x+self.vx*dt 
                self.y=self.y+self.vy*dt 
                
                --apply friction/linearDamping
                self.vx=self.vx-(self.vx*self.linearDamping*dt)
                self.vy=self.vy-(self.vy*self.linearDamping*dt)

                --stop moving when sufficiently slow
                if abs(self.vx)<self.stopThreshold*dt then self.vx=0 end
                if abs(self.vy)<self.stopThreshold*dt then self.vy=0 end

                --when stopped, change state to 'hold'
                if self.vx==0 and self.vy==0 then self.update=self.hold end
            end,
            hold=function(self)
                self.holdTime=self.holdTime-dt 
                if self.holdTime<0 then return false end 
            end,
            draw=function(self)
                love.graphics.print(self.val,self.font,self.x,self.y)
            end
        }
        table.insert(self.table,d)
    end

    local update=function(self)
        for i,damage in ipairs(self.table) do 
            if damage:update()==false then table.remove(self.table,i) end 
        end
    end

    local draw=function(self) for i=1,#self.table do self.table[i]:draw() end end

    return {
        table={},
        fonts=fonts,
        new=new,
        update=update,
        draw=draw,
    }
end

return {
    fonts=fonts,
    damage=generateDamageSystem(fonts),

    update=function(self)
        self.damage:update()
    end,

    draw=function(self)
        self.damage:draw()
    end,
}