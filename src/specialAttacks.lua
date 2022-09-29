local chainLightning=function(self,mage,targets)
    local damage=mage.attack.damage / #targets --split damage equally
    local knockback=mage.attack.knockback
    local points={mage.center}

    for i=1,#targets do --damage all targets, add their centers to points table
        local t=targets[i]
        local prevPoint=points[#points]
        local currPoint=t.center 
        local angle=getAngle(currPoint,prevPoint)
        t:takeDamage({
            damage=damage, knockback=knockback, angle=angle, textColor='yellow'
        })
        table.insert(points,currPoint)
    end

    local cl={
        points=points,
        duration=0.1,
        yellow=self.colors.yellow,
        white=self.colors.white,
        yOffset=-7,
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
                love.graphics.setColor(self.yellow) --draw yellow border
                love.graphics.setLineWidth(2)
                self.drawLine(p1,p2,self.yOffset)
                love.graphics.setColor(self.white) --draw white inner line
                love.graphics.setLineWidth(1)
                self.drawLine(p1,p2,self.yOffset)
                love.graphics.setColor(1,1,1) --reset color
            end
        end,
    }
    table.insert(self.table,cl)
end

return {
    chainLightning=chainLightning,

    colors={  
        yellow={227/255,194/255,91/255},
        white={237/255,228/255,218/255},
    },

    table={}, --holds all specialAttack instances    
    update=function(self)
        for i,special in ipairs(self.table) do 
            if special:update()==false then table.remove(self.table,i) end 
        end
    end,
    draw=function(self)
        for i,special in ipairs(self.table) do special:draw() end
    end,
}