LETSGETNAKED = {}

-- Context Menu functions

local addInventoryUndress = function(player, context, text, inventoryContainer)
	if inventoryContainer ~= nil and inventoryContainer["getContainer"] then
		local container = inventoryContainer:getContainer() or nil
		context:addOption(text, player, LETSGETNAKED.Undress, container)
	end
end

local addInventoryDress = function(player, context, text, inventoryContainer)
	if inventoryContainer ~= nil and inventoryContainer["getContainer"] then
		local container = inventoryContainer:getContainer() or nil
		context:addOption(text, player, LETSGETNAKED.Dress, container)
	end
end


-- Builder functions

LETSGETNAKED.BuildMenuUndress = function(playerId, context, itemsOrWorldObjects)
	local player = getSpecificPlayer(playerId)

	local undressOption = context:addOption(getText("ContextMenu_Undress"), player, nil)
	local subMenu = ISContextMenu:getNew(context)
	context:addSubMenu(undressOption, subMenu)

	addInventoryUndress(player, subMenu, getText("ContextMenu_Inventory"), itemsOrWorldObjects[1]['items'] and itemsOrWorldObjects[1]['items'][1])
	addInventoryUndress(player, subMenu, getText("ContextMenu_Container"), itemsOrWorldObjects[1])
end

LETSGETNAKED.BuildMenuDress = function(playerId, context, itemsOrWorldObjects)
	local player = getSpecificPlayer(playerId)

	local dressOption = context:addOption(getText("ContextMenu_Dress"), player, nil)
	local subMenu = ISContextMenu:getNew(context)
	context:addSubMenu(dressOption, subMenu)

	addInventoryDress(player, subMenu, getText("ContextMenu_Inventory"), itemsOrWorldObjects[1]['items'] and itemsOrWorldObjects[1]['items'][1])
	addInventoryDress(player, subMenu, getText("ContextMenu_Container"), itemsOrWorldObjects[1])
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
	Events.OnFillWorldObjectContextMenu.Add(LETSGETNAKED.BuildMenuUndress)
	Events.OnFillWorldObjectContextMenu.Add(LETSGETNAKED.BuildMenuDress)
end

Events.OnGameStart.Add(func_Init)