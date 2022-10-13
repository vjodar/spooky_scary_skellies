local getImage=function(name) return love.graphics.newImage('assets/hud/'..name..'.png') end 

local health={x=0,y=0,}

health.sprites={
    full=getImage('heartFull'),
    threeFourths=getImage('heartThreeFourths'),
    half=getImage('heartHalf'),
    quarter=getImage('heartQuarter'),
    empty=getImage('heartEmpty'),
}

health.piecesToSprite={
    [4]='full',
    [3]='threeFourths',
    [2]='half',
    [1]='quarter',
}

health.particlesDef={
    count=500,
    spread={x=5,y=8},
    yOffset=8,
    maxSpeed=15,
    colors={[0xca5954]=1},
}

health.particles=ParticleSystem:generateEmitter(health.particlesDef)

health.update=function(self,x,y)
    self.x=x-256
    self.y=y-192
end

health.draw=function(self)
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
health.calculateMaxHearts=function(self)
    --1 heart for every 1-100hp
    self.maxHearts=floor(Player.health.max/100)+min(1,Player.health.max%100)
end

health.calculateHeartPieces=function(self)
    local previousCount=self.heartPieces 
    self.heartPieces=ceil(Player.health.current/25) --1 piece for every 1-25hp

    --lost a heart piece, emit particles
    if previousCount and self.heartPieces<previousCount then 
        self.particles:emit(Player.center.x,Player.center.y)
        Camera:shake({magnitude=10})
    end
end

health:calculateMaxHearts()
health:calculateHeartPieces()

return health 