function love.load()
    dt=0 --delta time global
    acceptInput=false --flag to restrict inputs to one state at a time
    gameStates={} --state stack

    love.graphics.setDefaultFilter('nearest','nearest') --set pixelated look
    love.graphics.setLineStyle('rough') --pixelated lines

    Fonts=generateFonts() --fonts
    generateCommonMaths() --common math functions
    
    --Libraries
    bump=require 'src/libraries/bump'
    humpCam=require 'src/libraries/camera'
    anim8=require 'src/libraries/anim8'

    --Game States
    Controls=require 'src/gameStates/controlState'
    Timer=require 'src/gameStates/timerState'
    PlayState=require 'src/gameStates/playState'  
    FadeState=require 'src/gameStates/fadeState'
    PanState=require 'src/gameStates/panState'
    UpgradeSelectionState=require 'src/gameStates/upgradeSelectionState'

    --Modules
    UI=require 'src/userInterface'
    Camera=require 'src/camera'
    World=require 'src/world'
    Objects=require 'src/objects'
    Shadows=require 'src/shadows'
    Statuses=require 'src/statuses'
    ParticleSystem=require 'src/particleSystem'
    Player=require 'src/player'
    Hud=require 'src/hud/hud'
    LevelManager=require 'src/levels/levelManager'
    Entities=require 'src/entities/entityClass'
    Projectiles=require 'src/projectiles' 
    SpecialAttacks=require 'src/specialAttacks'
    Upgrades=require 'src/upgrades/upgrades'
    
    table.insert(gameStates,Timer) --timer first
    table.insert(gameStates,Controls) --controls second
    table.insert(gameStates,PlayState) --initial game state
    
    PlayState:startGame() --start the game
end

function love.update(_dt)
    dt=_dt --update delta time
    --testing-----------------------------------------------------------------------
    -- if not love.keyboard.isDown('space') then return end --step 1 frame at a time
    --testing-----------------------------------------------------------------------
    for i=1, #gameStates do 
        acceptInput=(i==#gameStates) --used to restrict inputs to top gameState
        --run each state in gameStates, remove any that return false
        if gameStates[i]:update()==false then table.remove(gameStates,i) end 
    end
end

function love.draw()
    Camera:attach()
    for i=1, #gameStates do 
        if gameStates[i].draw then gameStates[i]:draw() end
    end
    Camera.curtain:draw()
    Camera:detach()
end

function generateFonts()
    local fonts={}

    local glyphs=(
        " abcdefghijklmnopqrstuvwxyz"..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
        "1234567890.:!,'+-/()[]"
    )

    local colors={'white','yellow','gray','blue','red','green','big'}
    for i=1,#colors do
        local path='assets/fonts/'..colors[i]..'.png'
        fonts[colors[i]]=love.graphics.newImageFont(path,glyphs)
    end

    love.graphics.setFont(fonts.white) --default to white

    return fonts 
end

function generateCommonMaths()
    abs,floor,ceil=math.abs,math.floor,math.ceil
    min,max,rnd=math.min,math.max,love.math.random
    pi,cos,sin,atan2=math.pi,math.cos,math.sin,math.atan2
    rndSign=function() local t={-1,1} return t[rnd(2)] end
    rndElement=function(t) return t[rnd(#t)] end
    getSign=function(n) if n>0 then return 1 else return -1 end end 
    getAngle=function(s,t) return atan2((t.y-s.y),(t.x-s.x)) end
    getDistance=function(a,b) return ((abs(b.x-a.x))^2+(abs(b.y-a.y))^2)^0.5 end
    getMagnitude=function(a,b) return abs((a^2+b^2)^0.5) end
    getCenter=function(a) return {x=a.x+a.w*0.5,y=a.y+a.h*0.5} end
    getRectDistance=function(a,b) --shortest distance between two rectangles
        local A={
            center={x=a.x+a.w*0.5,y=a.y+a.h*0.5},
            topLeft={x=a.x,y=a.y},
            topRight={x=a.x+a.w,y=a.y},
            botLeft={x=a.x,y=a.y+a.h},
            botRight={x=a.x+a.w,y=a.y+a.h},
        }

        local B={
            center={x=b.x+b.w*0.5,y=b.y+b.h*0.5},
            topLeft={x=b.x,y=b.y},
            topRight={x=b.x+b.w,y=b.y},
            botLeft={x=b.x,y=b.y+b.h},
            botRight={x=b.x+b.w,y=b.y+b.h},
        }       

        local w=abs(B.center.x-A.center.x)*0.5
        local h=abs(B.center.y-A.center.y)*0.5

        local closestPointA,closestPointB={x=0,y=0},{x=0,y=0}

        --A's center is somewhere to the left of B's center
        if A.center.x<B.center.x then
            if A.center.y<B.center.y then --A is in upper left quadrant
                if A.botRight.x>B.topLeft.x then 
                    closestPointA={x=A.center.x+w,y=A.botLeft.y}
                    closestPointB={x=B.center.x-w,y=B.topLeft.y}
                elseif A.botRight.y>B.topLeft.y then 
                    closestPointA={x=A.topRight.x,y=A.center.y+h}
                    closestPointB={x=B.topLeft.x,y=B.center.y-h}
                else 
                    closestPointA={x=A.botRight.x,y=A.botRight.y}
                    closestPointB={x=B.topLeft.x,y=B.topLeft.y}
                end

            else --A is in lower left quadrant
                if A.topRight.x>B.botLeft.x then 
                    closestPointA={x=A.center.x+w,y=A.topLeft.y}
                    closestPointB={x=B.center.x-w,y=B.botLeft.y }
                elseif A.topRight.y<B.botLeft.y then 
                    closestPointA={x=A.topRight.x,y=A.center.y-h}
                    closestPointB={x=B.topLeft.x,y=B.center.y+h}
                else
                    closestPointA={x=A.topRight.x,y=A.topRight.y}
                    closestPointB={x=B.botLeft.x,y=B.botLeft.y}
                end
            end
            
        --A's center is somewhere to the right of B's center
        else                 
            if A.center.y<B.center.y then --A is in upper right quadrant
                if A.botLeft.x<B.topRight.x then 
                    closestPointA={x=A.center.x-w,y=A.botLeft.y}
                    closestPointB={x=B.center.x+w,y=B.topLeft.y}
                elseif A.botLeft.y>B.topRight.y then 
                    closestPointA={x=A.topLeft.x,y=A.center.y+h}
                    closestPointB={x=B.topRight.x,y=B.center.y-h }
                else 
                    closestPointA={x=A.botLeft.x,y=A.botLeft.y}
                    closestPointB={x=B.topRight.x,y=B.topRight.y}
                end

            else --A is in lower right quadrant 
                if A.topLeft.x<B.botRight.x then 
                    closestPointA={x=A.center.x-w,y=A.topLeft.y}
                    closestPointB={x=B.center.x+w,y=B.botLeft.y}
                elseif A.topLeft.y<B.botRight.y then 
                    closestPointA={x=A.topLeft.x,y=A.center.y-h}
                    closestPointB={x=B.topRight.x,y=B.center.y+h }
                else
                    closestPointA={x=A.topLeft.x,y=A.topLeft.y}
                    closestPointB={x=B.botRight.x,y=B.botRight.y}
                end
            end
        end

        return getDistance(closestPointA,closestPointB)
    end
    alignRectCenters=function(small,big)
        --returns the x,y of small after aligning its center with that of big
        local smallCenter,bigCenter=getCenter(small),getCenter(big)
        local centerDifference={
            x=bigCenter.x-smallCenter.x,
            y=bigCenter.y-smallCenter.y
        }
        return small.x+centerDifference.x, small.y+centerDifference.y
    end
end