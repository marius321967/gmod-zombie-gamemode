include('sv_buyfunctions.lua')

hook.Add('ShowHelp', 'Help', function(ply) ply:ConCommand('zmb_showhelp') end)
hook.Add('ShowSpare1', 'Spare1', function(ply) ply:ConCommand('zmb_showspare1') end)
-- hook.Add('ShowSpare2', 'Spare2', function(ply) ply:ConCommand('zmb_menu_weapons') end)
