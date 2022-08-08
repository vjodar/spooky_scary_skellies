local PlayState={}

function PlayState:load()    
    World=wf.newWorld()
    World:addCollisionClass('player')
    World:addCollisionClass('skeleton')

    map=love.graphics.newImage('assets/maps/placeholder.png')

    Entities:load()
    Player:load(10,10)
    Skeletons:load()
    Camera.target=Player
    Camera.cam:zoomTo(2)
end

function PlayState:update()
    Camera:update()
    World:update(dt)
    Entities:update()
    if Controls.released.btnB then 
        Skeletons:new('warrior',0,0)
        Skeletons:new('archer',15,0)
        Skeletons:new('mageFire',30,0)
        Skeletons:new('mageIce',45,0)
        Skeletons:new('mageElectric',60,0)
    end
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    World:draw()
    Entities:draw()
end

return PlayState
