local PlayState={}

function PlayState:startGame()
    LevelManager:buildLevel('test')
    Camera:zoomTo(2)
    Camera.target=Player
end

function PlayState:update()
    Camera:update()
    LevelManager:update()
    Objects:update()
end

function PlayState:draw()
    LevelManager:draw()
    Objects:draw()
    LevelManager:drawForeground()
end

--testing-------------------
function love.keyreleased(k) 
    if k=='escape' then love.event.quit() end 
    if k=='o' then 
        LevelManager:destroyLevel()
        LevelManager:buildLevel(LevelManager.currentLevel.name)
    end
    if k=='p' then 
        for i=1,1 do Entities:new('werebear',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('spider',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('bat',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('headlessHorseman',Controls.getMousePosition()) end
    end
    if k=='l' then 
        for i=1,50 do Entities:new('bat',rnd(100,800),rnd(100,600)) end
        -- for i=1,50 do Entities:new('gnasherDemon',rnd(0,400),rnd(0,300)) end
    end
    if k=='j' then 
        for i,def in pairs(Entities.definitions) do
            if def.collider.class=='enemy' then
                for j=1,5 do Entities:new(def.name,rnd(100,800),rnd(100,600)) end
            end
        end
    end
end
--testing-------------------

return PlayState
