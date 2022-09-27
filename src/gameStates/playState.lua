local PlayState={}

function PlayState:startGame()
    local allyCount={
        skeletonWarrior=0,
        skeletonArcher=0,
        skeletonMageFire=0,
        skeletonMageIce=0,
        skeletonMageElectric=0,
    }
    LevelManager:buildLevel('test',allyCount)
    Camera:zoomTo(2)
    Camera.target=Player.center
end

function PlayState:update()
    Camera:update()
    LevelManager:update()
    Objects:update()
    UI:update()
end

function PlayState:draw()
    LevelManager:draw()
    Objects:draw()
    LevelManager:drawForeground()
    UI:draw()
end

--testing-------------------
function love.keyreleased(k) 
    if k=='escape' then love.event.quit() end 
    if k=='o' then 
        LevelManager:destroyLevel()
        LevelManager:buildLevel(
            LevelManager.currentLevel.name,LevelManager.currentLevel.allyCount
        )
    end
    if k=='p' then 
        -- for i=1,1 do Entities:new('werebear',Controls.getMousePosition()) end
        -- FadeState:fadeBoth({fadeTime=2,afterFn=function() print('done') end, holdTime=1})
        Player.status:burn(5,3)
        Player.status:freeze(Player,2,0.3)
    end
    if k=='l' then
        local panObjects={
            {target={x=0,y=0},afterFn=function() print('hi there!') end,holdTime=0.5},
            {target={x=600,y=0},afterFn=function() print('hello!') end,holdTime=0.5},
            {target=Player.center}
        }
        PanState:panTo(panObjects)
    end
end
--testing-------------------

return PlayState
