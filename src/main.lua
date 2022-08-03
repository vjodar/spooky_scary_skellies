function love.load()
    --Modules
    wf=require 'modules/windfield'
    camera=require 'modules/camera'
    anim8=require 'modules/anim8'

    --GameStates
    Controls=require 'gameStates/controlState'
    Timer=require 'gameStates/timerState'
    Play=require 'gameStates/playState'

    love.graphics.setDefaultFilter('nearest','nearest') --set pixelated look

    dt=0 --delta time global
    gameStates={} --state stack
    acceptInput=false --flag to restrict inputs to one state at a time

    table.insert(gameStates,Controls) --controls first
    table.insert(gameStates,Timer) --timer second
    table.insert(gameStates,Play) --initial game state

    --Initialize all states in gamestates
    for i,state in pairs(gameStates) do state:load() end
end

function love.update(_dt)
    dt=_dt --update delta time
    for i,state in pairs(gameStates) do
        acceptInput=(i==#gameStates) --used to restrict inputs to top gameState
        --run each state in gameStates, remove any that return false
        if state:update()==false then table.remove(gameStates,i) end 
    end
end

function love.draw()
    for i,state in pairs(gameStates) do if state.draw then state:draw() end end
end
