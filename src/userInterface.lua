local generateDamageSystem=function(fonts)
    local new=function(self,x,y,val,color) --damage object constructor
        local angle=-pi*(0.3+rnd()*0.4) --angle=[0.3pi,0.7pi]
        local moveSpeed=(3+(rnd()*3))*60 --speed=[3,6]
        local color=color or 'gray'
        local font=self.fonts[color]
        local d={
            x=x+rnd(-8,8), y=y-rnd(20), val=val,
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

local dialogMethods={
    update=function(self)
        if self.isDoneTalking then return end

        local ownerPos=self.owner.center or self.owner 
        self.x,self.y=ownerPos.x,ownerPos.y

        --Done forming speech, start duration countdown
        if self.isFormingSpeech==false then
            self.timer=self.timer+dt 
            if self.timer>self.duration then 
                self.isDoneTalking=true 
                self.speech.current=""
                self.speech.finished=""
            end
            return 
        end
        
        --Still forming speech
        local speech=self.speech 
        speech.timer=speech.timer+dt 
        if speech.timer>speech.period then --add another letter to current speech
            speech.timer=0
            speech.current=speech.finished:sub(1,speech.index)
            speech.index=speech.index+1

            if speech.index>#speech.finished then --finished forming speech
                self.isFormingSpeech=false
                speech.index=1
            end
        end
    end,
    draw=function(self)
        if self.isDoneTalking then return end 
        love.graphics.printf(
            self.speech.current,
            self.x-375,self.y-self.yOffset,
            750,'center'
        )
    end,
    say=function(self,speech)
        self.speech.finished=speech 
        self.isDoneTalking=false 
        self.isFormingSpeech=true 
        self.timer=0
        self.speech.index=1
    end,
}

local newDialog=function(self,entity,yOffset) --dialog constructor
    local dialog={
        owner=entity,
        x=0, y=0,
        yOffset=yOffset or 0,
        duration=3,
        timer=0,
        isDoneTalking=true,
        isFormingSpeech=false,
        speech={ --used to manage building of speech gradually
            finished="",
            current="",
            index=1,
            timer=0,
            period=0.03,
        },
        font=self.fonts.white,
        update=self.dialogMethods.update,
        draw=self.dialogMethods.draw,
        say=self.dialogMethods.say,
    }
    table.insert(self.dialogs,dialog)
    return dialog
end

return { --The Module
    fonts=Fonts,
    damage=generateDamageSystem(Fonts),
    dialogs={}, --holds all dialogs
    dialogMethods=dialogMethods,
    newDialog=newDialog,
    update=function(self) 
        self.damage:update()
        for i=1, #self.dialogs do self.dialogs[i]:update() end 
    end,
    draw=function(self)
        self.damage:draw()
        for i=1, #self.dialogs do self.dialogs[i]:draw() end 
    end,
}