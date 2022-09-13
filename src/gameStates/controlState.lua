local function defaultInputs() --list of all inputs
    return {
        dirLeft=false,
        dirRight=false,
        dirUp=false,
        dirDown=false,
        mouse=false,
    }
end

local function defaultKeyMappings() --default keyboard mappings
    return {
        dirUp={'w','up'},
        dirDown={'s','down'},
        dirLeft={'a','left'},
        dirRight={'d','right'},
        btn1={'1'},
        btn2={'2'},
        btn3={'3'},
    }
end

local function defaultMouseMappings()
    return {
        mouse=1,
    }
end

love.mouse.setCursor(love.mouse.getSystemCursor('hand')) --set cursor

--The Module
return {
    down=defaultInputs(),
    pressed=defaultInputs(),
    released=defaultInputs(),
    keyMappings=defaultKeyMappings(),
    mouseMappings=defaultMouseMappings(),
    getMousePosition=function() return Camera:mousePosition() end,
    
    --Reads input to determine what inputs are down, pressed, and released this frame
    update=function(self)
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
}
