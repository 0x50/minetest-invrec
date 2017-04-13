--------------------------------------------------------------
-- Inventory Plus/++ I/O
--------------------------------------------------------------
minetest.register_on_joinplayer(function(player)
	inventory_plus.register_button(player,"invrec",invrec.title)
end)

minetest.register_on_player_receive_fields(function(player,formname,fields)
	if fields.main then -- back to default page
		inventory_plus.get_formspec(player, inventory_plus.default)
		return
	end
	if fields.invrec then
		if invrec.events(nil, player, nil, fields) then 
			inventory_plus.set_inventory_formspec(player,  "size[8,7.5] bgcolor[#080808BB;true] button[0,0.4;2,.5;main;Back]" 
				.. default.gui_bg .. default.gui_bg_img .. invrec.update_gui(player))
		end
	end
end)
