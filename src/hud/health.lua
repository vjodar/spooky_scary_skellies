local getImage=function(name) return love.graphics.newImage('assets/hud/'..name..'.png') end 

local sprites={
    full=getImage('heartFull'),
    threeFourths=getImage('heartThreeFourths'),
    half=getImage('heartHalf'),
    quarter=getImage('heartQuarter'),
    empty=getImage('heartEmpty'),
}

local piecesToSprite={
    [4]='full',
    [3]='threeFourths',
    [2]='half',
    [1]='quarter',
}

local particlesDef={
    count=500,
    spread={x=5,y=8},
    yOffset=8,
    maxSpeed=15,
    colors={[0xca5954]=1},
}
local particles=ParticleSystem:generateEmitter(particlesDef)

local update=function(self,x,y)
    self.x=x-256
    self.y=y-192
end

local draw=function(self)
    for i=1,self.maxHearts do --draw heart borders
        love.graphics.draw(self.sprites.empty,self.x+(i*15),self.y+10)
    end

    for i=1,self.maxHearts do --fill hearts
        if self.heartPieces>=4*i then 
            love.graphics.draw(self.sprites.full,self.x+(i*15),self.y+10)
        else --not enough for full heart, fill with remaining pieces
            local pieces=self.heartPieces-(4*(i-1))
            if pieces<4 and pieces>0 then 
                love.graphics.draw(
                    self.sprites[self.piecesToSprite[pieces]],
                    self.x+(i*15),self.y+10
                )
            end
            break --subsequent hearts will be empty, break out of loop
        end
    end
end

--called once initially, then each time the player's max health changes
local calculateMaxHearts=function(self)
    --1 heart for every 1-100hp
    self.maxHearts=floor(Player.health.max/100)+min(1,Player.health.max%100)
end

local calculateHeartPieces=function(self)
    local previousCount=self.heartPieces 
    self.heartPieces=ceil(Player.health.current/25) --1 piece for every 1-25hp

    --lost a heart piece, emit particles
    if self.heartPieces<previousCount then 
        self.particles:emit(Player.center.x,Player.center.y)
        Camera:shake({magnitude=10})
        if Player.upgrades.panicSummon then 
            local skellies={'skeletonWarrior','skeletonWarrior','skeletonWarrior'}
            local unlocked=Player.upgrades
            if unlocked.skeletonArcher then skellies[2]='skeletonArcher' end 
            if unlocked.skeletonMageFire then skellies[3]='skeletonMageFire' end 
            if unlocked.skeletonMageIce then skellies[3]='skeletonMageIce' end 
            if unlocked.skeletonMageElectric then skellies[3]='skeletonMageElectric' end 
            for i=1,5 do Player:summon(rndElement(skellies),1) end
        end
    end
end

return { --The Module
    x=0, y=0,
    sprites=sprites,
    piecesToSprite=piecesToSprite,
    particles=particles,
    maxHearts=floor(Player.health.max/100)+min(1,Player.health.max%100),
    heartPieces=ceil(Player.health.current/25),
    calculateMaxHearts=calculateMaxHearts,
    calculateHeartPieces=calculateHeartPieces,
    update=update,
    draw=draw,    
} 