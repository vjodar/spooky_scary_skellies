local PlayState={}

function PlayState:startGame()
    GameScale=2
    Camera:zoomTo(GameScale)
    love.graphics.setPointSize(GameScale)
    love.graphics.setLineWidth(GameScale)
    Camera.target=Player.center

    local allyCount={
        skeletonWarrior=100,
        skeletonArcher=0,
        skeletonMageFire=0,
        skeletonMageIce=0,
        skeletonMageElectric=0,
    }
    LevelManager:buildLevel('test',allyCount)
end

function PlayState:update()
    Camera:update()
    LevelManager:update()
    Objects:update()
    SpecialAttacks:update()
    ParticleSystem:update()
    UI:update()
end

function PlayState:draw()
    LevelManager:draw()
    Objects:draw()
    SpecialAttacks:draw()
    LevelManager:drawForeground()
    ParticleSystem:draw()
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
        -- FadeState:fadeBoth({fadeTime=2,afterFn=function() print('done') end, holdTime=1})
        Entities.behaviors.AI.skeletonMageElectric.attack=Entities.behaviors.states.ally.chainLightning
        Entities.definitions.skeletonMageFire.attack.projectile.name='fireball'
        Entities.definitions.skeletonMageFire.attack.knockback=600
        Entities.definitions.skeletonMageFire.attack.range=200
        Entities.definitions.skeletonMageIce.attack.projectile.name='blizzard'
        Entities.definitions.skeletonMageIce.attack.projectile.yOffset=-15
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
    end
end
--testing-------------------

return PlayState
