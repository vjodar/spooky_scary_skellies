return {
    new=function()
        local burn=function(self,damage,duration)
            local period=1 --damages every 1s
            local cycles=duration/period 
            local b={
                damage=damage,
                knockback=50,
                period=period,
                cycles=cycles,
                timer=0,
                update=self.statusMethods.burnUpdate,
            }
            table.insert(self.table.burn,b)
        end

        local freeze=function(self,entity,duration,slow)
            local f={
                duration=duration,
                timer=0,
                update=self.statusMethods.freezeUpdate,
            }
            table.insert(self.table.freeze,f)
            entity.moveSpeed=entity.moveSpeedMax*slow 
            entity.animSpeed=entity.animSpeed*slow
        end

        return {
            table={ --status instances table
                burn={},
                freeze={},
            },
            burn=burn, --burn instance constructor
            freeze=freeze, --freeze instance constructor
            statusMethods={
                burnUpdate=function(self,entity)
                    self.timer=self.timer+dt 
                    if self.timer>self.period then 
                        entity:takeDamage({
                            damage=self.damage,
                            knockback=self.knockback,
                            angle=rnd()*pi*2,
                            textColor='red',
                            sfx='burn',
                        })
                        self.cycles=self.cycles-1
                        self.timer=0
                    end
                    if self.cycles==0 then return false end
                end,
                freezeUpdate=function(self,entity) 
                    self.timer=self.timer+dt 
                    if self.timer>self.duration then 
                        entity.moveSpeed=entity.moveSpeedMax 
                        entity.animSpeed=entity.animSpeedMax 
                        return false 
                    end  
                end,
            },
            update=function(self,entity) --updates all status instances
                for statusType,_ in pairs(self.table) do 
                    for i,status in ipairs(self.table[statusType]) do 
                        if status:update(entity)==false then 
                            table.remove(self.table[statusType],i)
                        end
                    end
                end
            end,
            clear=function(self,entity)
                self.table.burn={}
                self.table.freeze={}
                entity.moveSpeed=entity.moveSpeedMax 
                entity.animSpeed=entity.animSpeedMax 
            end,
        }
    end
}