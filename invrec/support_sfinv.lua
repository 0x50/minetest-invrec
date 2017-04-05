--------------------------------------------------------------
-- Native support 
--------------------------------------------------------------
sfinv.register_page("invrecipe:recipes", {
	title = invrec.title,
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, invrec._f, false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		invrec.events(self, player, context, fields);
		sfinv.set_player_inventory_formspec(player, context);
	end,
	on_enter = function(self, player, context)
		invrec.events(self, player, context, nil);
		sfinv.set_player_inventory_formspec(player, context);
	end
});
