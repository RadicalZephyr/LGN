LETSGETNAKED = {}
-- Builder functions
LETSGETNAKED.BuildMenuUndress = function(player, context, items)
	local player = getSpecificPlayer(player)
	if items[1]['items'] ~= nil then
		local check_container = items[1]['items'][1]:getContainer() 
		local check_clothing = items[1]['items'][1]:getCategory()
		if  check_container == player:getInventory() and check_clothing == "Clothing" then
			context:addOption(getText("ContextMenu_Undress"), player, LETSGETNAKED.Undress, nil)
		end
	end
end

LETSGETNAKED.BuildMenuDress = function(player, context, items)	
	local player = getSpecificPlayer(player)
	if items[1]['items'] ~= nil then
		local check = items[1]['items'][1]:getCategory() 
		if check == "Clothing" then
			local container = items[1]['items'][1]:getContainer() or nil
			context:addOption(getText("ContextMenu_Dress"), player, LETSGETNAKED.Dress, container)
		end
	end
end

LETSGETNAKED.BuildMenuUndressToContainer = function(player, context, worldobjects)
	if worldobjects[1]:getContainer() ~= nil then
		local player = getSpecificPlayer(player)
		local container_X = worldobjects[1]:getSquare():getX()
		local container_Y = worldobjects[1]:getSquare():getY()
		if math.abs(player:getX() - container_X) < 2 and math.abs(player:getY() - container_Y) then
			local container = worldobjects[1]:getContainer()
			context:addOption(getText("ContextMenu_UndressContainer"), player, LETSGETNAKED.Undress, container)
		end
	end
end

LETSGETNAKED.BuildMenuDressFromContainer = function(player, context, worldobjects)
	if worldobjects[1]:getContainer() ~= nil then
		local selectedContainer = worldobjects[1]:getContainer() 
		local player = getSpecificPlayer(player)
		local container_X = worldobjects[1]:getSquare():getX()
		local container_Y = worldobjects[1]:getSquare():getY()
		if math.abs(player:getX() - container_X) < 2 and math.abs(player:getY() - container_Y) then
			local container = worldobjects[1]:getContainer()
			context:addOption(getText("ContextMenu_DressContainer"), player, LETSGETNAKED.Dress, container)
		end
	end
end

LETSGETNAKED.BuildMenuUndressToFloor = function(playerNum, context, worldobjects)
	local loot = getPlayerLoot(playerNum)
	local backpacks = loot.backpacks
	local floorContainer = nil
	for i,b in ipairs(backpacks) do
		local bp = backpacks[i]
		local name = bp.name
		if bp.name == "Floor" then
			local player = getSpecificPlayer(playerNum)
			local container = bp.inventory
			context:addOption(getText("ContextMenu_UndressFloor"), player, LETSGETNAKED.Undress, container)
			break
		end
	end
end

LETSGETNAKED.BuildMenuDressFromFloor = function(playerNum, context, worldobjects)
	local loot = getPlayerLoot(playerNum)
	local backpacks = loot.backpacks
	for i,b in ipairs(backpacks) do
		local bp = backpacks[i]
		local name = bp.name
		if bp.name == "Floor" then
			local player = getSpecificPlayer(playerNum)
			local container = bp.inventory
			context:addOption(getText("ContextMenu_DressFloor"), player, LETSGETNAKED.Dress, container)
		end
	end
end

-- Action functions
LETSGETNAKED.Undress = function(player, container)
	local container = container
	local inv = player:getInventory():getItemsFromCategory('Clothing')
	if inv:size() == 0 then
		player:Say('I am naked!')
	else 
		for i=0, inv:size() - 1 do
			item = inv:get(i)
			-- We don't want to unequip belts
			if item:isEquipped() == true and item:getBodyLocation() ~= "Belt" and item:getBodyLocation() ~= "BeltExtra" then
				ISTimedActionQueue.add(ISUnequipAction:new(player, item, 50))
				if container ~= nil then
					ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, player:getInventory(), container, 20))
				end
			end
		end
	end
end

LETSGETNAKED.Dress = function(player, container)
	local clothing = container:getItemsFromCategory('Clothing')
	local player_inv = player:getInventory():getItemsFromCategory('Clothing')
	local equipped_clothing = {}
	
	-- Get table with equipped clothing type as keys and 'true' as values
	if player_inv:size() ~= 0 then
		for i=0, player_inv:size() - 1 do
			item = player_inv:get(i)
			if item:isEquipped() == true then
				equipped_clothing[item:getBodyLocation()] = true
			end
		end
	end
	
	if clothing:size() ~= 0 then
		for i=0, clothing:size() - 1 do
			item = clothing:get(i)
			if equipped_clothing[item:getBodyLocation()] ~= true then
				ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, container, player:getInventory(), 20)) 
				ISTimedActionQueue.add(ISWearClothing:new(player, item, 50))
				equipped_clothing[item:getBodyLocation()] = true
			end
		end
	end
end



-- TODO: swap clothing with inventory
LETSGETNAKED.SwapClothingWithContainer = function(player, items)
end

-- Init function
local function func_Init()
	Events.OnFillInventoryObjectContextMenu.Add(LETSGETNAKED.BuildMenuUndress)
	Events.OnFillInventoryObjectContextMenu.Add(LETSGETNAKED.BuildMenuDress)
	Events.OnFillWorldObjectContextMenu.Add(LETSGETNAKED.BuildMenuUndressToContainer)
	Events.OnFillWorldObjectContextMenu.Add(LETSGETNAKED.BuildMenuDressFromContainer)
	Events.OnFillWorldObjectContextMenu.Add(LETSGETNAKED.BuildMenuUndressToFloor)
	Events.OnFillWorldObjectContextMenu.Add(LETSGETNAKED.BuildMenuDressFromFloor)
end

Events.OnGameStart.Add(func_Init)