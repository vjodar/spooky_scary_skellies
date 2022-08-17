function love.load()
    dt=0 --delta time global
    acceptInput=false --flag to restrict inputs to one state at a time
    paletteBlack={53/255,53/255,64/255} --black in our palette
    gameStates={} --state stack

    love.graphics.setDefaultFilter('nearest','nearest') --set pixelated look
    love.graphics.setBackgroundColor(paletteBlack) --set background color

    --common math functions
    abs,floor,ceil=math.abs,math.floor,math.ceil
    min,max,rnd=math.min,math.max,love.math.random
    pi,cos,sin,atan2=math.pi,math.cos,math.sin,math.atan2
    getAngle=function(s,t) return atan2((t.y-s.y),(t.x-s.x)) end
    getDistance=function(a,b) return ((abs(b.x-a.x))^2+(abs(b.y-a.y))^2)^0.5 end
    
    --Libraries
    wf=require 'src/libraries/windfield'
    humpCam=require 'src/libraries/camera'
    anim8=require 'src/libraries/anim8'

    --Modules
    Camera=require 'src/camera'
    World=require 'src/world'
    Objects=require 'src/objects'
    Shadows=require 'src/shadows'
    Player=require 'src/player'
    Entities=require 'src/entities/entityClass'
    Projectiles=require 'src/projectiles'

    --GameStates
    Controls=require 'src/gameStates/controlState'
    Timer=require 'src/gameStates/timerState'
    PlayState=require 'src/gameStates/playState'        
    
    table.insert(gameStates,Controls) --controls first
    table.insert(gameStates,Timer) --timer second
    table.insert(gameStates,PlayState) --initial game state
    
    PlayState:startGame() --start the game
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
    Camera:attach()
    for i,state in pairs(gameStates) do
        if state.draw then state:draw() end 
    end
    Camera:detach()
end