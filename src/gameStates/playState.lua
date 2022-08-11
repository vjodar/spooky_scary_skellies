local PlayState={}

function PlayState:load()    
    World=wf.newWorld()
    World:addCollisionClass('player')
    World:addCollisionClass('skeleton')
    World:addCollisionClass('enemy')
    --testing--------------------------------
    World:setQueryDebugDrawing(true)
    --testing--------------------------------

    map=love.graphics.newImage('assets/maps/placeholder.png')

    Entities:load()
    Player:load(10,10)
    Skeletons:load()
    Enemies:load()
    Camera.target=Player
    Camera.cam:zoomTo(3)
end

function PlayState:update()
    Camera:update()
    World:update(dt)
    Entities:update()
    if Controls.pressed.mouse then
        Skeletons:new('skeletonWarrior',Controls.getMousePosition())
        -- Skeletons:new('skeletonArcher',Controls.getMousePosition())
        -- Skeletons:new('skeletonMageFire',Controls.getMousePosition())
        -- Skeletons:new('skeletonMageIce',Controls.getMousePosition())
        -- Skeletons:new('skeletonMageElectric',Controls.getMousePosition())
    end
    if Controls.pressed.mouse2 then 
        Enemies:new('slime',Controls.getMousePosition())
    end
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    -- World:draw()
    Entities:draw()
end

return PlayState
