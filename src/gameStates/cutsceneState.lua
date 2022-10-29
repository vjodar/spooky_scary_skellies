local tutorialCutscene=function(self)
    GameStates:addState(self)
    self.state='tutorial'
    self.cutsceneDone=false
    Hud:hide()

    --Spawn and setup witch and demon 'actors'
    --Use timers to facilitate dialog and actions
    local setupWitchActor=function()
        self.witch=Entities:new('witch',rnd(Player.x-48,Player.x+48),Player.y-32)
        local dialog=UI:newDialog(self.witch,45,'dialogWitch')
        dialog.speech.period=0.05 --dialog is slower than normal
        self.witch.dialog=dialog
    end
    local setWitchToIdle=function()
        self.witch:changeState('idleCutscene')
    end
    local spawnDemons=function()
        local demons={
            beholder=1,
            pyreFiend=1,
            gnasherDemon=3,
            imp=6,
        }
        LevelManager.gridClass:generateEnemies(
            demons,Entities,LevelManager.currentLevel.grid
        )
    end
    local despawnActors=function()
        local demons={}
        for i=1,#Objects.table do 
            local o=Objects.table[i]
            if o.collisionClass=='enemy' and o.name~='witch' then
                table.insert(demons,o) 
            end
        end
        self.witch:changeState('despawn')
        Audio:playSfx(Entities.definitions.witch.sfx.spawn)
        for i=1,#demons do 
            Timer:after(0.1*i,function() 
                demons[i]:changeState('despawn') 
                Audio:playSfx(Entities.definitions.imp.sfx.spawn)
            end)
        end
        local vol=Audio.musicVolume.default 
        Audio:setVolume(1,vol) --restore full vol
    end
    local endTutorialCutscene=function()
        CutsceneState.cutsceneDone=true
        CutsceneState.witch.dialog:destroy()
        CutsceneState.witch=nil
        Hud:show() --reveal Hud

        --Tutorial dialog
        local dialog1=function() Player.dialog:say("Hmph! I'll show her!") end
        local dialog2=function() Player.dialog:say("I can move around with [W/A/S/D] keys,") end
        local dialog3=function() Player.dialog:say("launch bones with [Left Mouse Button],") end
        local dialog4=function() Player.dialog:say("and summon skeletons with [1/2/3] keys.") end
        Timer:after(1,dialog1)
        Timer:after(4,dialog2)
        Timer:after(7,dialog3)
        Timer:after(11,dialog4)
    end

    --Cutscene dialog
    local dialog1=function() self.witch.dialog:say("AAAAAHAHAHAHAAA!") end
    local dialog2=function() self.witch.dialog:say("You'll never be a REAL summoner...") end
    local dialog3=function() self.witch.dialog:say("if all you can do is raise skeletons!") end
    local dialog4=function() self.witch.dialog:say("Anyway I'll be in my castle") end
    local dialog5=function() self.witch.dialog:say("with all the really cool Halloween monsters.") end
    local dialog6=function() self.witch.dialog:say("Try not to trip over your own shoes getting there!") end
    local dialog7=function() self.witch.dialog:say("AAAAAAAAAAAAAAAAHAHAHAHAHAHAAA!") end

    --Actual tutorial cutscene
    Timer:after(1,setupWitchActor)
    Timer:after(1.5,spawnDemons)
    Timer:after(1.7,setWitchToIdle)
    Timer:after(2,dialog1)
    Timer:after(4,dialog2)
    Timer:after(6.8,dialog3)
    Timer:after(11,dialog4)
    Timer:after(14,dialog5)
    Timer:after(17.5,dialog6)
    Timer:after(21,dialog7)
    Timer:after(23,despawnActors)
    Timer:after(25,endTutorialCutscene)
end

local bossCutscene=function(self)
    GameStates:addState(self)
    self.state='boss'
    self.cutsceneDone=false
    LevelManager:setEntityAggro(false)
    Hud:hide()
    Audio:playSong('dungeonBossWaves')
    
    local bossSpawnPos=LevelManager.currentLevel.bossData.spawnPos
    local setupWitchActor=function()
        self.witch=Entities:new('witch',bossSpawnPos.x,bossSpawnPos.y)        
        local dialog=UI:newDialog(self.witch,45,'dialogWitch')
        dialog.speech.period=0.05 --dialog is slower than normal
        self.witch.dialog=dialog
        
        local setWitchToIdle=function() self.witch:changeState('idleCutscene') end 
        Timer:after(0.7,setWitchToIdle)
    end
    local panToWitch=function() 
        PanState:panTo({{target=bossSpawnPos,afterFn=setupWitchActor}})
    end
    local despawnWitch=function()
        self.witch:changeState('despawn')
    end
    local endBossCutscene=function()
        PanState:panTo({
            {
                target=Player,
                afterFn=function() 
                    CutsceneState.cutsceneDone=true
                    CutsceneState.witch.dialog:destroy()
                    CutsceneState.witch=nil                    
                    LevelManager:setEntityAggro(true)
                    Hud:show()    
                end
            }
        })
    end

    local dialog1=function() self.witch.dialog:say("Well well well look who it is.") end 
    local dialog2=function() self.witch.dialog:say("I'm impressed you've made it this far") end 
    local dialog3=function() self.witch.dialog:say("with just those bunch of bones.") end 
    local dialog4=function() self.witch.dialog:say("But now witness the true power of summoning!") end 

    Timer:after(1,panToWitch)
    Timer:after(2,dialog1)
    Timer:after(5,dialog2)
    Timer:after(8,dialog3)
    Timer:after(11,dialog4)
    Timer:after(16,despawnWitch)
    Timer:after(17,endBossCutscene)
end

return { --The Module
    state='tutorial',
    cutsceneDone=false,
    witch=nil, --the witch actor
    tutorialCutscene=tutorialCutscene,
    bossCutscene=bossCutscene,
    update=function(self) 
        if self.cutsceneDone then return false end 

        --face player and witch toward each other
        if self.witch then 
            Player.scaleX=Player.center.x>self.witch.center.x and -1 or 1
            self.witch.scaleX=self.witch.center.x>Player.center.x and -1 or 1
        end
    end,
}