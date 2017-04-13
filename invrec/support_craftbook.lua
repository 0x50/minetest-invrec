--------------------------------------------------------------
-- Add craftbook to see recipes. 
--------------------------------------------------------------
local craftbook_on_use = function(itemstack, player)
	local p = player:get_player_name()

	minetest.show_formspec(p, "invrec:craftbook", "size[8,8.5]bgcolor[#080808BB;true]" .. default.gui_bg .. default.gui_bg_img .. invrec.update_gui(player))
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
	if fields.invrec then -- handle events
		local p = player:get_player_name()
		if invrec.events(nil, player, nil, fields) then
			minetest.show_formspec(p, "invrec:craftbook", "size[8,8.5] bgcolor[#080808BB;true]".. default.gui_bg .. default.gui_bg_img .. invrec.update_gui(player))
		end
	end
end)

minetest.register_tool("invrec:craftbook",
{
	description = "Craft book",
	inventory_image = "invrec_book.png",
	groups = {book = 1, flammable = 3},
	stack_max = 1,
	on_use = craftbook_on_use
});

minetest.register_craft({
	output = 'invrec:craftbook',
	width = 2,
	recipe = {
		{'default:book'},
		{'default:steel_ingot'}
	}
})