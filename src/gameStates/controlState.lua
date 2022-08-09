local controlState={}

function controlState:load()
    local function defaultInputs() --list of all inputs
        return {
            dirLeft=false,
            dirRight=false,
            dirUp=false,
            dirDown=false,
            mouse=false,
            --testing-----------
            mouse2=false,
            --testing-----------
        }
    end

    local function defaultKeyMappings() --default keyboard mappings
        return {
            dirUp={'w','up'},
            dirDown={'s','down'},
            dirLeft={'a','left'},
            dirRight={'d','right'},
        }
    end

    local function defaultMouseMappings()
        return {
            mouse=1,
            --testing-------------
            mouse2=2,
            --testing-------------
        }
    end
    
    self.down=defaultInputs()
    self.pressed=defaultInputs()
    self.released=defaultInputs()
    self.keyMappings=defaultKeyMappings() 
    self.mouseMappings=defaultMouseMappings() 

    love.mouse.setCursor(love.mouse.getSystemCursor('hand'))
end

--Reads input to determine what inputs are down, pressed, and released this frame
function controlState:update()
    for input,key in pairs(self.keyMappings) do
        if love.keyboard.isDown(key) and not self.released[input] then 
            self.pressed[input]=not self.down[input]
            self.down[input]=true 
        else 
            self.released[input]=self.down[input]
            self.down[input]=false
            self.pressed[input]=false
        end
    end

    for input,mouseBtn in pairs(self.mouseMappings) do 
        if love.mouse.isDown(mouseBtn) and not self.released[input] then 
            self.pressed[input]=not self.down[input]
            self.down[input]=true 
        else 
            self.released[input]=self.down[input]
            self.down[input]=false
            self.pressed[input]=false
        end
    end
end

function controlState.getMousePosition() return Camera.cam:mousePosition() end

return controlState