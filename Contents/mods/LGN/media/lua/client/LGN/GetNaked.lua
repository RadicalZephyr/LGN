LGN = {}

-- Context Menu functions

local addInventoryUndress = function(playerNum, context, text, inventoryContainer)
   if inventoryContainer and inventoryContainer["getContainer"] then
      local container = inventoryContainer:getContainer()
      context:addOption(text, playerNum, LGN.Undress, container)
   end
end

local addInventoryDress = function(playerNum, context, text, inventoryContainer)
   if inventoryContainer and inventoryContainer["getContainer"] then
      local container = inventoryContainer:getContainer()
      context:addOption(text, playerNum, LGN.Dress, container)
   end
end


-- Builder functions

LGN.BuildMenuUndress = function(playerNum, context, itemsOrWorldObjects)
   local undressOption = context:addOption(getText("ContextMenu_Undress"), playerNum, nil)
   local subMenu = ISContextMenu:getNew(context)
   context:addSubMenu(undressOption, subMenu)

   addInventoryUndress(playerNum, subMenu, getText("ContextMenu_Inventory"), itemsOrWorldObjects[1]['items'] and itemsOrWorldObjects[1]['items'][1])
   addInventoryUndress(playerNum, subMenu, getText("ContextMenu_Container"), itemsOrWorldObjects[1])
   local loot = getPlayerLoot(playerNum)
   local backpacks = loot.backpacks
   for i,_b in ipairs(backpacks) do
      local b = backpacks[i]
      if b.name == "Floor" then
         b['getContainer'] = function () return b.inventory end
         addInventoryUndress(playerNum, subMenu, getText("ContextMenu_Floor"), b)
         break
      end
   end
end

LGN.BuildMenuDress = function(playerNum, context, itemsOrWorldObjects)
   local dressOption = context:addOption(getText("ContextMenu_Dress"), playerNum, nil)
   local subMenu = ISContextMenu:getNew(context)
   context:addSubMenu(dressOption, subMenu)

   addInventoryDress(playerNum, subMenu, getText("ContextMenu_Inventory"), itemsOrWorldObjects[1]['items'] and itemsOrWorldObjects[1]['items'][1])
   addInventoryDress(playerNum, subMenu, getText("ContextMenu_Container"), itemsOrWorldObjects[1])
   local loot = getPlayerLoot(playerNum)
   local backpacks = loot.backpacks
   for i,_b in ipairs(backpacks) do
      local b = backpacks[i]
      if b.name == "Floor" then
         b['getContainer'] = function () return b.inventory end
         addInventoryDress(playerNum, subMenu, getText("ContextMenu_Floor"), b)
         break
      end
   end
end

-- Action functions
LGN.Undress = function(playerNum, container)
   local player = getSpecificPlayer(playerNum)
   -- If the container is a player inventory we don't need to check distance
   if container and container:getParent() ~= player then
      luautils.walkToContainer(container, playerNum)
   end

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

LGN.Dress = function(playerNum, container)
   local player = getSpecificPlayer(playerNum)
   -- If the container is a player inventory we don't need to check distance
   if container and container:getParent() ~= player then
      luautils.walkToContainer(container, playerNum)
   end

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


-- Init function
local function func_Init()
   Events.OnFillInventoryObjectContextMenu.Add(LGN.BuildMenuUndress)
   Events.OnFillInventoryObjectContextMenu.Add(LGN.BuildMenuDress)
   Events.OnFillWorldObjectContextMenu.Add(LGN.BuildMenuUndress)
   Events.OnFillWorldObjectContextMenu.Add(LGN.BuildMenuDress)
end

Events.OnGameStart.Add(func_Init)
