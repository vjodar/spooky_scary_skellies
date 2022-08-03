local PlayState={}

function PlayState:load()
    --load PlayState stuff here
    Player={talkOnCooldown=false}
end

function PlayState:update()
    --update PlayState stuff here    
    if Player.talkOnCooldown==false then 
        print("Hello") 
        local cdPeriod=love.math.random(2)
        Timer:setOnCooldown(Player,'talkOnCooldown',cdPeriod)
    end
end

function PlayState:draw()
    --draw PlayState stuff here     
end

return PlayState
