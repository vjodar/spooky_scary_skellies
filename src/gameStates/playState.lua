local PlayState={}

function PlayState:load()    
    World=wf.newWorld()
    World:addCollisionClass('player')
    World:addCollisionClass('skeleton')

    Entities:load()
    Skeletons:load()
    -- Skeletons:new('warrior',20,20)
    Player:load(10,10)
    Camera.target=Player
    Camera.cam:zoomTo(3)
end

function PlayState:update()
    Camera:update()
    World:update(dt)
    Entities:update()
    if Controls.released.btnB then 
        Skeletons:new('warrior',rnd(-10,10),rnd(-10,10))
    end
end

function PlayState:draw()
    World:draw()
    Entities:draw()
end

return PlayState
