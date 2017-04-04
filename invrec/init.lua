--------------------------------------------------------------
--	Inventory Recipe Page for Minetest Game.
--	v0.0.02b
--
--	License: GPLv3	 <0x50000@gmail.com>
--  Version tested: 0.4.15
--------------------------------------------------------------

invrec = {}
invrec.m_isFull =	 true
invrec.m_Name = 	"invrecipe:recipes"
invrec.m_Title = 	"Craft guide"

invrec._f = 		""
invrec._rs =		4	-- height is 8.5
invrec.items = 		{}
invrec.groups = 	{}
invrec.pdata = 		{}

--------------------------------------------------------------
-- get_item_group for multiple group(s)
--------------------------------------------------------------
local is_item_in_group = function(itemname, filter)
	assert(filter)
	assert(itemname)
	
	filter = filter:sub(7)	-- get "group:%s"

	-- FIXME: DUCT TAPE (How get high prioritet??)
	-- Groups for [MOD] flowers should be correct. Try to remove collision
	local temp =
	{
	-- [what item]			[always have this group]
		{"dye:pink", 		"dye,unicolor_light_red"},
		{"dye:brown", 		"dye,unicolor_dark_orange"},
		{"dye:violet", 		"dye,excolor_violet"},
		{"dye:dark_green", 	"dye,unicolor_dark_green"},
		{"dye:dark_grey", 	"dye,unicolor_darkgrey"}
	}
	for _, i in ipairs(temp) do
		if itemname == i[1] then 
			if i[2] == filter then
				return 1;
			else
				return 0
			end
		 end
	end
	-- END DUCT TAPE
	
	for _, i in ipairs(filter:split(',')) do		
		local k = minetest.get_item_group(itemname, i);
		if k == 0 then return 0 end
	end
	
	return 1;
end

--------------------------------------------------------------
-- get_table_size for multiple group(s)
--------------------------------------------------------------
local get_table_size = function(table)
	local i = 0;
	for _ in pairs(table) do
	   i = i + 1
	end
	return i
end

--------------------------------------------------------------
-- Init recipes and groups
--------------------------------------------------------------
invrec.init = function()
	local i = 0;
	
	for name in pairs(minetest.registered_items) do
		if (name and name ~= "") then
			local rec = minetest.get_all_craft_recipes(name)
			if rec then
				table.insert(invrec.items, name)
				for _,recipe in ipairs(rec) do
					if (recipe and recipe.items) then
						for _, recgr in ipairs(recipe.items) do
							if(  recgr:sub(0,6) == "group:")  then
								table.insert(invrec.groups,  recgr)
							end
						end
					end
				end
			end
		end
	end
	
	table.sort(invrec.items)
	table.sort(invrec.groups)
	
	i = #invrec.groups
	while (i > 0) do
		   if (invrec.groups[i] == invrec.groups[i - 1]) then
				table.remove(invrec.groups, i);
			end
		i = i - 1
	end
	
	for j in ipairs(invrec.groups) do
		i = {}
		for k in pairs(minetest.registered_items) do
			if (is_item_in_group( k, invrec.groups[j]) == 1) then
				table.insert(i, k);
			end
		end
		table.sort(i)
		invrec.groups[j] = {invrec.groups[j], recipe = i}
	end
end

--------------------------------------------------------------
-- Search elements 
--------------------------------------------------------------
invrec.search = function(player)
	local p = player:get_player_name();
	local query = invrec.pdata[p].query:lower();
	invrec.pdata[p].qitems = {}

	if(  query:sub(0,6) == "group:")  then
		-- search by craft groupname
		for _ , item in pairs(invrec.groups) do
			if(item[1] == query) then
				invrec.pdata[p].qitems = item.recipe;
				break;
			end
		end
	else
		-- search string
		for _ , item in pairs(invrec.items) do
			if minetest.registered_items[item] then
				local str = minetest.registered_items[item].description:lower();
				if string.match(str, query) then
				  table.insert(invrec.pdata[p].qitems, item)
				end
			end
		end
		table.sort(invrec.pdata[p].qitems)
	end
	
	invrec.pdata[p].page.max = math.floor(#invrec.pdata[p].qitems/(invrec._rs*8) + 1);
end

--------------------------------------------------------------
-- Generate item_image_button for craft item.
--------------------------------------------------------------
invrec.item_craft_button = function(x,y,parent,item)
	local is_group = false;
	local img = item;
	local desc = "No items found for " .. minetest.colorize("#FFFF00", tostring(item:sub(7))) .. " group";
	local tooltip = ""
	
	if (item:sub(0,6) == "group:") then 
		img = "doors:hidden";
		is_group = 1;
		for gitem in pairs(invrec.groups) do
			if (invrec.groups[gitem][1] == item) then
				if(#invrec.groups[gitem].recipe == 1) then
					img = invrec.groups[gitem].recipe[1];
					item = invrec.groups[gitem].recipe[1];
					is_group = nil;
				end
				if(#invrec.groups[gitem].recipe > 0) then
					img = invrec.groups[gitem].recipe[1];
					desc = "Any items belong to " .. minetest.colorize("#FFFF00", tostring(item:sub(7))) .. " group";
				end
				break;
			end
		end
		tooltip = "tooltip[invgrp:".. item ..";".. desc.."]";
	end
	
	if(parent.type == "cooking") then
		if(minetest.registered_items[item]) then
			desc = minetest.registered_items[item].description .. "\nCooking time: " .. minetest.colorize("#FFFF00", tostring(minetest.get_craft_result({method = "cooking", width = 1, items = {ItemStack(item)}}).time)) .. "sec"
			tooltip = "tooltip[invrec:".. item ..";".. desc.."]";
		else
			desc = desc .. "\nCooking time: " .. minetest.colorize("#FFFF00", tostring(minetest.get_craft_result({method = "cooking", width = 1, items = {ItemStack(img)}}).time)) .. "sec";
			tooltip = "tooltip[invgrp:".. item ..";".. desc.."]";
		end
	end
	
	if(is_group) then
		return "item_image_button["..x..","..y..";1.05,1.05;".. img ..";invgrp:".. item ..";G]" .. tooltip;
	end
	
	return "item_image_button["..x..","..y..";1.05,1.05;".. img ..";invrec:".. item ..";]" .. tooltip;	
end

--------------------------------------------------------------
-- GUI
--------------------------------------------------------------
invrec.update_gui = function(player)
	local p = player:get_player_name();
	
	-- Reset formspec and show correct scheme indeed 
	invrec._f = ""
	if invrec.m_isFull == true then invrec._f = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]" end
		
	-- Show list of items
	local parseitem = invrec.items
	if(invrec.pdata[p].query) then
		if(invrec.pdata[p].ns) then
			invrec.search(player)
			invrec.pdata[p].ns = nil;
		end
		parseitem = invrec.pdata[p].qitems
	end
	
	local i = 0
	if(#parseitem > 0) then
		for _ , item in next,parseitem,((invrec.pdata[p].page.pid - 1 )*invrec._rs*8) do
			if(i >= invrec._rs*8) then break end
			invrec._f = invrec._f .. "item_image_button["..(i%8)..","..(math.floor(i/8)+3.5)..";1.05,1.05;".. item  ..";invrec:" .. item .. ";] "
			i = i+1
		end
	end
	
	-- Show pages count
	invrec._f = invrec._f .. 
		"label[1.0,"..tostring(invrec._rs+3.7+ 0.25)..";" .. minetest.colorize("#FFFF00", tostring(invrec.pdata[p].page.pid)) .. " / " .. invrec.pdata[p].page.max .. "]"
	
	-- Show recipe and alternate
	if(invrec.pdata[p].recipe.name) then
		local itemname = invrec.pdata[p].recipe.name;
		local craft = minetest.get_all_craft_recipes(itemname);
		local recipeid = invrec.pdata[p].recipe.cid;
		local maxrecipe = #craft;
		
		if(recipeid > maxrecipe) then 
			recipeid = 1
			invrec.pdata[p].recipe.cid = 1
		end
		local item = {};
		
		if (get_table_size(craft[recipeid].items) == 1) then
			invrec._f = invrec._f .. invrec.item_craft_button(0%1 + 2 + math.abs((3 - 1)), math.floor(0/1) + 0.3, craft[recipeid], craft[recipeid].items[1]);
		else
			local i = 0;
			local j = craft[recipeid].width;
			if j <= 0 then j = 2 end
			if j > 3 then j = 3 end		--FIXME: Why flour width=15?
			while i < 3*3 do
				if(craft[recipeid].items[i+1]) then
					invrec._f = invrec._f .. invrec.item_craft_button(i%j + 2 + math.abs((3 - j)), math.floor(i/j) + 0.3, craft[recipeid], craft[recipeid].items[i+1]);
				end
				i = i + 1;
			end
		end
		
		invrec._f  = invrec._f  ..
					"image[5.00,0.25;1,1;gui_furnace_arrow_bg.png^[transformR270]" ..
					"item_image_button[6.0,0.3;1.05,1.05;".. craft[recipeid].output ..";invnot:".. itemname ..";]"
		
		if craft[recipeid].type == "cooking" then
			invrec._f   = invrec._f   .. "image[5.00,1.25;1,1;default_furnace_fire_fg.png]"
		end
		
		if(maxrecipe > 1) then
			invrec._f = invrec._f ..
						"label[0.0,1.55;Recipe:]" ..
						"label[0.0,2.0;"  .. minetest.colorize("#FFFF00", tostring(recipeid)) .. " / " .. tostring(math.floor(maxrecipe)) .. "]" ..
						"button[0.0,2.65;2,0.5;invrec_alternate;Alternate]"
		end
	end
	
	-- Show control buttons
	invrec._f = invrec._f .. 
		"button[0,"..tostring(invrec._rs+3.54 + 0.25)..";0.8,0.9;invrec_prev;<]" ..
		"tooltip[invrec_prev;Previous page]"..
		"button[2.1,"..tostring(invrec._rs+3.54 + 0.25)..";0.8,0.9;invrec_next;>]"..
		"tooltip[invrec_next;Next page]"..
		"button[5.8,"..tostring(invrec._rs+3.7 + 0.25)..";1.5,0.5;invrec_search;Search]" .. 
		"field_close_on_enter[invrec_search_input;false]" .. 		
		"button[7.245,"..tostring(invrec._rs+3.7 + 0.25)..";0.8,0.5;invrec_search_reset;X]" .. 
		"tooltip[invrec_search_reset;Reset search]"
	
	if(invrec.pdata[p].query) then
		invrec._f = invrec._f .. "field[3.2,"..tostring(invrec._rs+3.8+ 0.25)..";3.0,1;invrec_search_input;;".. tostring(invrec.pdata[p].query) .."]";
	else
		invrec._f = invrec._f .. "field[3.2,"..tostring(invrec._rs+3.8+ 0.25)..";3.0,1;invrec_search_input;; ]";
	end

end
--------------------------------------------------------------
-- Catch Events
--------------------------------------------------------------
invrec.events = function (self, player, context, fields)
	local p = player:get_player_name();
	local need = 1;
	
	if fields then		
		if (fields.key_enter_field == "invrec_search_input" and fields.key_enter == "true") or fields.invrec_search then
			if(invrec.pdata[p].query == minetest.formspec_escape(fields.invrec_search_input)) then
				need = nil
			end
			if(fields.invrec_search_input == "") then
				invrec.pdata[p].query = nil
				invrec.pdata[p].qitems = {}
				invrec.pdata[p].page.max = math.floor(#invrec.items/(invrec._rs*8) + 1);
			else
				local q = fields.invrec_search_input; 
				q = string.sub(q,0,64);
				q = minetest.formspec_escape(q);
				invrec.pdata[p].query = q;
				invrec.pdata[p].page.pid = 1
				invrec.pdata[p].ns = 1;
			end
		end
		if fields.invrec_search_reset then
			invrec.pdata[p].query = nil
			invrec.pdata[p].page.max = math.floor(#invrec.items/(invrec._rs*8) + 1);
			invrec.pdata[p].page.pid = 1
		end
		if fields.invrec_alternate then
			invrec.pdata[p].recipe.cid = invrec.pdata[p].recipe.cid + 1;
		end
		if fields.invrec_next then
			invrec.pdata[p].page.pid = invrec.pdata[p].page.pid + 1;
			if(invrec.pdata[p].page.max < invrec.pdata[p].page.pid) then invrec.pdata[p].page.pid = 1 end
		end
		if fields.invrec_prev then
			invrec.pdata[p].page.pid = invrec.pdata[p].page.pid - 1;
			if(invrec.pdata[p].page.pid < 1) then invrec.pdata[p].page.pid = invrec.pdata[p].page.max end
		end
		for i in pairs(fields) do
			if (i:sub(0,7) == "invrec:") then
					for _, items in pairs(invrec.items) do
						if( items == i:sub(8) ) then
							if(invrec.pdata[p].recipe.name == i:sub(8)) then
								need = nil;
							end
							invrec.pdata[p].recipe.cid = 1
							invrec.pdata[p].recipe.name = i:sub(8);
						end
					end
				break
			end
			if (i:sub(0,7) == "invgrp:") then
					if(invrec.pdata[p].query == i:sub(8)) then
						need = nil;
					end
					invrec.pdata[p].query = minetest.formspec_escape(i:sub(8));
					invrec.pdata[p].page.pid = 1
					invrec.pdata[p].ns = 1;
				break
			end
			if (i:sub(0,7) == "invnot:") then
				need = nil;
				break
			end
		end
	end
	
	if need then
		invrec.update_gui(player)
	end
end

--------------------------------------------------------------
-- Catch when player joined to init
--------------------------------------------------------------
minetest.register_on_joinplayer(function(player)
	local p = player:get_player_name();
		
	if(invrec._int == nil) then 
			invrec.init() 
			invrec._int = 1;
	end
		
	if (invrec.pdata[p] == nil) then
		invrec.pdata[p] = {page = {pid = 1, max = math.floor(#invrec.items/(invrec._rs*8) + 1)}, query = nil, ns = nil, recipe = {name = nil, cid = 1}, qitems = {}}
	end
		
	invrec.update_gui(player)
end)
--------------------------------------------------------------
-- Clear some data
--------------------------------------------------------------
minetest.register_on_leaveplayer(function(player)
	local p = player:get_player_name();
		
	invrec.pdata[p].qitems = {};
	invrec.pdata[p].ns = 1;
end)

--------------------------------------------------------------
-- GUI/MOD bridge
--------------------------------------------------------------

if(rawget(_G, "inventory_plus") and not minetest.setting_getbool("creative_mode")) then
	invrec._rs = 3	-- height is 7.5
	dofile(minetest.get_modpath( minetest.get_current_modname() ).."/support_ipp.lua")
else
	dofile(minetest.get_modpath( minetest.get_current_modname() ).."/support_sfinv.lua")
end

minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
