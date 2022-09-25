local panTo=function(self,panObjects)
    for i=1,#panObjects do table.insert(self.panObjects,panObjects[i]) end
    self.update=self.nextTargetUpdate
    table.insert(gameStates,self)
end

local nextTargetUpdate=function(self)
    if #self.panObjects==0 then return false end 
    Camera.target=self.panObjects[1].target
    self.update=self.panUpdate 
end

local panUpdate=function(self)
    if abs(Camera.x-self.panObjects[1].target.x)<1
    and abs(Camera.y-self.panObjects[1].target.y)<1
    then 
        if self.panObjects[1].afterFn then self.panObjects[1].afterFn() end 
        if self.panObjects[1].holdTime then 
            self.update=self.holdUpdate 
        else
            table.remove(self.panObjects,1)
            self.update=self.nextTargetUpdate      
        end 
    end
end

local holdUpdate=function(self)
    self.panObjects[1].holdTime=self.panObjects[1].holdTime-dt 
    if self.panObjects[1].holdTime<0 then 
        table.remove(self.panObjects,1)
        self.update=self.nextTargetUpdate 
    end
end

return {
    panObjects={},
    panTo=panTo,
    nextTargetUpdate=nextTargetUpdate,
    panUpdate=panUpdate,
    holdUpdate=holdUpdate,
    update=nextTargetUpdate,
}