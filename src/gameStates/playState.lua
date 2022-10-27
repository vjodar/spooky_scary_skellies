local startTitleScreen=function(self)
    GameScale=2
    Camera:zoomTo(GameScale)
    love.graphics.setPointSize(GameScale)
    love.graphics.setLineWidth(GameScale)

    LevelManager:buildTitleScreenLevel()
    TitleScreenState:start()
end

local startGame=function(self)
    local buildStartingLevel=function()
        World:addItem(Player)
        table.insert(Objects.table,Player)
        Camera.smoother=Camera.smooth.damped(10)
        Camera.target=Player.center    
        LevelManager.currentLevel.boundaries={}
        Objects:clear()
        LevelManager.update=LevelManager.updateStandard
        LevelManager:buildTutorialLevel()
        -- CutsceneState:tutorialCutscene()
        Upgrades:unlock('mageElectricUpgrade')
    end
    FadeState:fadeBoth({fadeTime=0.4,afterFn=buildStartingLevel,holdTime=0.4})
end

--testing-------------------
function love.keyreleased(k) 
    if k=='escape' then love.event.quit() end 
    if k=='p' then 
        -- GameOverState:win()
        -- Upgrades.chests:new('chestSmall',Controls.getMousePosition())
        -- for name,_ in pairs(Upgrades.definitions) do Upgrades:unlock(name) end
        -- UpgradeSelectionState:presentCards(5)
        -- FadeState:fadeBoth({fadeTime=2,afterFn=function() print('done') end, holdTime=1})
        -- local particles=ParticleSystem:generateEmitter({
        --     count=200,
        --     spread={x=30, y=10},
        --     yOffset=10,
        --     colors={
        --         [0xb24c4c]=2,
        --         [0x557d55]=3,
        --         [0xbc87a5]=1,
        --     }
        -- })
        -- particles:emit(Player.center.x,Player.center.y)
    end
    if k=='l' then
        Entities:new('skeletonMageElectric',Controls:getMousePosition())
        -- Player.dialog:say('I can summon skeletons with [1/2/3] keys.')
        -- LevelManager:setEntityAggro(not LevelManager:getEntityAggro())
        -- for name,def in pairs(Entities.definitions) do             
        --     if def.collider.class=='enemy' then 
        --         Entities:new(name,rnd(200,600),rnd(100,400))
        --     end
        -- end
        -- for i=1,1 do Entities:new('skeletonWarrior',Controls.getMousePosition()) end        
        -- local panObjects={
        --     {target={x=0,y=0},afterFn=function() print('hi there!') end,holdTime=0.5},
        --     {target={x=600,y=0},afterFn=function() print('hello!') end,holdTime=0.5},
        --     {target=Player.center}
        -- }
        -- PanState:panTo(panObjects)
        -- Camera:shake({
        --     magnitude=20,
        --     damping=3,
        -- })
        -- local goalX,goalY=Controls.getMousePosition()
        -- Player.x,Player.y=goalX,goalY 
        -- World:update(Player,goalX,goalY)
        -- Player.canSummon.cooldownPeriod=0.1
        -- Player:updateHealth(-1)
        -- Upgrades.chests:new('chestLarge',Controls.getMousePosition())
    end
end
--testing-------------------

return { --The Module
    startTitleScreen=startTitleScreen,
    startGame=startGame,
    update=function(self)
        Camera:update()
        LevelManager:update()
        Objects:update()
        SpecialAttacks:update()
        ParticleSystem:update()
        UI:update()
        Hud:update()
    end,
    draw=function(self)
        LevelManager:draw()
        Objects:draw()
        SpecialAttacks:draw()
        LevelManager:drawForeground()
        ParticleSystem:draw()
        UI:draw()
        Hud:draw()
    end,
}
