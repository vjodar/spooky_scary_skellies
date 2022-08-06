local PlayState={}

function PlayState:load()    
    World=wf.newWorld()
    World:addCollisionClass('player')

    Entities:load()
    Player:load(10,10)
    Camera.target=Player
    Camera.cam:zoomTo(3)
end

function PlayState:update()
    Camera:update()
    World:update(dt)
    Entities:update()
end

function PlayState:draw()
    World:draw()
    Entities:draw()
end

return PlayState
