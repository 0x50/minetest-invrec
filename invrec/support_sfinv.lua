--------------------------------------------------------------
-- Native support 
--------------------------------------------------------------
sfinv.register_page("invrec:recipes", {
	title = invrec.title,
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, invrec.update_gui(player), false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.invrec then
			if invrec.events(nil, player, nil, fields) then 
				sfinv.set_player_inventory_formspec(player, context)
			end
		end
	end
});
