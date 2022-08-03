local controlState={}

function controlState:load()
    local function defaultInputs() --list of all inputs
        return {
            dirLeft=false,
            dirRight=false,
            dirUp=false,
            dirDown=false,
            btnA=false,
            btnB=false,
        }
    end

    local function defaultKeyMappings() --default keyboard mappings
        return {
            dirUp={'w','up'},
            dirDown={'s','down'},
            dirLeft={'a','left'},
            dirRight={'d','right'},
            btnA={'o'},
            btnB={'p'},
        }
    end

    self.down=defaultInputs()
    self.pressed=defaultInputs()
    self.released=defaultInputs()
    self.keyMappings=defaultKeyMappings()
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
end

return controlState