-- Context Menu functions

local addInventoryUndress = function(playerNum, context, text, inventoryContainer)
   if inventoryContainer and inventoryContainer["getContainer"] then
      local container = inventoryContainer:getContainer()
      local name = getText("ContextMenu_LGN_Undress") .. text;
      context:addOption(name, playerNum, LGN.Undress, container)
   end
end

local addInventoryDress = function(playerNum, context, text, inventoryContainer)
   if inventoryContainer and inventoryContainer["getContainer"] then
      local container = inventoryContainer:getContainer()
      local name = getText("ContextMenu_LGN_Dress") .. text;
      context:addOption(name, playerNum, LGN.Dress, container)
   end
end

ISInventoryMenuElements = ISInventoryMenuElements or {};

function ISInventoryMenuElements.UnDressMenu()
   local self = ISMenuElement.new();

   function self.init()
   end

   function self.createMenu(data)
      local playerNum = data.player;
      local dressMenu = data.context:addOptionOnTop(getText("ContextMenu_LGN_Menu"), playerNum, nil)
      local subMenu = ISContextMenu:getNew(context)
      context:addSubMenu(menuOption, subMenu)

      local items = data.objects;
      addInventoryUndress(playerNum, subMenu, getText("ContextMenu_LGN_Inventory"), items[1]['items'] and items[1]['items'][1])
      addInventoryDress(playerNum, subMenu, getText("ContextMenu_LGN_Inventory"), items[1]['items'] and items[1]['items'][1])

      local loot = getPlayerLoot(playerNum)
      local backpacks = loot.backpacks
      for i,_b in ipairs(backpacks) do
         local b = backpacks[i]
         if b.name == "Floor" then
            b['getContainer'] = function () return b.inventory end
            addInventoryUndress(playerNum, subMenu, getText("ContextMenu_LGN_Floor"), b)
            addInventoryDress(playerNum, subMenu, getText("ContextMenu_LGN_Floor"), b)
            break
         end
      end
   end

   return self;
end

ISWorldMenuElements = ISWorldMenuElements or {};

function ISWorldMenuElements.UnDressMenu()
   local self = ISMenuElement.new();

   function self.init()
   end

   function self.createMenu(data)
      local playerNum = data.player;
      local undressOption = data.context:addOptionOnTop(getText("ContextMenu_LGN_Menu"), playerNum, nil)
      local subMenu = ISContextMenu:getNew(context)
      context:addSubMenu(undressOption, subMenu)

      for _,o in ipairs(data.objects) do
         addInventoryUndress(playerNum, subMenu, getText("ContextMenu_LGN_Container") .. o:getName(), o)
      end

      for _,o in ipairs(data.objects) do
         addInventoryDress(playerNum, subMenu, getText("ContextMenu_LGN_Container") .. o:getName(), o)
      end

      local loot = getPlayerLoot(playerNum)
      local backpacks = loot.backpacks
      for i,_b in ipairs(backpacks) do
         local b = backpacks[i]
         if b.name == "Floor" then
            b['getContainer'] = function () return b.inventory end
            addInventoryUndress(playerNum, subMenu, getText("ContextMenu_LGN_Floor"), b)
            addInventoryDress(playerNum, subMenu, getText("ContextMenu_LGN_Floor"), b)
            break
         end
      end
   end

   return self;
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
   Events.OnFillInventoryObjectContextMenu.Add(LGN.BuildInventoryMenu)
   Events.OnFillWorldObjectContextMenu.Add(LGN.BuildWorldMenu)
end

Events.OnGameStart.Add(func_Init)

return LGN
