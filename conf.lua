function love.conf(t)
    t.title="Spooky Scary Skellies"          --The title of the window the game is in (string)
    t.version="11.4"            --The LOVE version this game was made for (string)
    t.console=true              --Attach a console (boolean, Windows only)
    t.window.width=1200         --The window width (number)
    t.window.height=900         --The window height (number)
    t.resizable=true

    t.modules.joystick=false 
    t.modules.thread=false 
    t.modules.video=false 
end