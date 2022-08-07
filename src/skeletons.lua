local skeletons={}

function skeletons:load()
    self.spriteSheets={
        warrior=love.graphics.newImage('assets/entities/skeleton_warrior.png'),
        archer=love.graphics.newImage('assets/entities/skeleton_archer.png'),
        mageFire=love.graphics.newImage('assets/entities/skeleton_mage_fire.png'),
        mageIce=love.graphics.newImage('assets/entities/skeleton_mage_ice.png'),
        mageElectric=love.graphics.newImage('assets/entities/skeleton_mage_electric.png'),
    }
    local function getWidth(_type) return self.spriteSheets[_type]:getWidth() end 
    local function getHeight(_type) return self.spriteSheets[_type]:getHeight() end 
    self.grids={
        warrior=anim8.newGrid(10,17,getWidth('warrior'),getHeight('warrior')),
        archer=anim8.newGrid(42,22,getWidth('archer'),getHeight('archer')),
        mage=anim8.newGrid(24,24,getWidth('mageFire'),getHeight('mageFire')),
    }
    
    --Creates a table of animations given a skeleton, grid, and animation defs
    function self:parseAnimations(_skeleton,_grid,_animDefs)
        local anims={}  
        for anim,def in pairs(_animDefs) do
            local onLoopFn=function() end 
            if def.onLoop then
                onLoopFn=self.skeletonOnLoopFunctions[def.onLoop](_skeleton)
            end 
            anims[anim]=anim8.newAnimation(
                _grid(def.frames,def.row),def.duration,onLoopFn
            ) 
        end
        return anims
    end

    self.skeletonDefinitions={
        warrior={
            name='skeleton_warrior',
            collider={
                width=12,
                height=5,
                corner=3,
                linearDamping=20,
                mass=0.1,
            },
            drawData={
                xOffset=5,
                yOffset=17,
                spriteSheet='warrior',
                grid='warrior',
            },
            animations={
                wake={
                    frames='1-4',
                    row=1,
                    duration=0.1,
                    onLoop='changeToIdle'
                },
                idle={
                    frames='1-4',
                    row=2,
                    duration=0.1,
                },
                move={
                    frames='1-4',
                    row=3,
                    duration=0.1,
                },
                attack={
                    frames=1,
                    row=4,
                    duration=0.4
                }
            },
            moveSpeed=240,         
        },
    }

    self.skeletonOnLoopFunctions={
        changeToIdle=function(_s)
            return function()
                _s.state='idle'
                _s.animations.current=_s.animations.idle
            end
        end
    }

    self.skeletonBehaviors={
        wake=function(skl)
            return function()
                skl.x,skl.y=skl.collider:getPosition()
                skl.animations.current:update(dt*skl.animSpeed.current)
            end
        end,        
        idle=function(skl)
            return function()
                skl.x,skl.y=skl.collider:getPosition()
                skl.animations.current:update(dt*skl.animSpeed.current)
            end
        end,        
    }
end

function skeletons:new(_skeletonType,_x,_y)
    local def=self.skeletonDefinitions[_skeletonType]

    local skeleton={}
    function skeleton:load()
        self.name=def.name
        self.collider=World:newBSGRectangleCollider(
            _x,_y,def.collider.width,def.collider.height,def.collider.corner
        )
        self.collider:setLinearDamping(def.collider.linearDamping)
        self.collider:setMass(def.collider.mass)
        self.collider:setFixedRotation(true) 
        self.collider:setCollisionClass('skeleton')
        self.collider:setObject(self)
        self.x,self.y=self.collider:getPosition()
        self.moveSpeed=def.moveSpeed

        self.xOffset=def.drawData.xOffset
        self.yOffset=def.drawData.yOffset
        self.scaleX=1
        self.spriteSheet=skeletons.spriteSheets[def.drawData.spriteSheet]
        self.animations=skeletons:parseAnimations(
            self,skeletons.grids[def.drawData.grid],def.animations
        )
        self.animations.current=self.animations.wake
        self.animSpeed={min=0.25,max=3,current=1}

        self.behaviors={}
        for state,behavior in pairs(Skeletons.skeletonBehaviors) do 
            self.behaviors[state]=behavior(self)
        end
        self.state='wake'

        table.insert(Entities.table,self)
        return self 
    end

    function skeleton:update() self.behaviors[self.state]() end

    function skeleton:draw()
        self.animations.current:draw(
            self.spriteSheet,self.x,self.y,
            nil,self.scaleX,1,self.xOffset,self.yOffset
        )
    end

    return skeleton:load()
end

return skeletons
