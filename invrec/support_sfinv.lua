--------------------------------------------------------------
-- Native support 
--------------------------------------------------------------
sfinv.register_page(invrec.m_Name, {
	title = invrec.m_Title,
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, invrec._f, not invrec.m_isFull)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		invrec.events(self, player, context, fields);
		sfinv.set_player_inventory_formspec(player, context);
	end,
	on_enter = function(self, player, context)
		invrec.events(self, player, context, fields);
		sfinv.set_player_inventory_formspec(player, context);
	end
});