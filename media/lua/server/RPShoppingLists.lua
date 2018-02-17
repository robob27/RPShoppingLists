function RP_shoppingListCreate(items, shoppingListItem, player)
	local modData = shoppingListItem:getModData();

	modData.rpslUniqueID = player:getUsername() .. (ZombRand(1000000) + 1);

	RPSLOnAddTag(shoppingListItem, player, player:getPlayerNum(), false);
end

function RP_shoppingListCopy(items, shoppingListItem, player)
	local newListModData = shoppingListItem:getModData();
	local oldShoppingList;

	for i=0, items:size() do
		local item = items:get(i);

		if item:getType() == "RPShoppingList" then
			oldShoppingList = item;
			break;
		end
	end

	if oldShoppingList then
		newListModData.rpsltags = oldShoppingList:getModData().rpsltags;
		newListModData.rpslUniqueID = player:getUsername() .. (ZombRand(1000000) + 1);

		shoppingListItem:setName('Copy of ' .. oldShoppingList:getName());
	end
end

local Commands = {};
local shoppingLists = {};

function Commands.updateShoppingListModData(playerObj, args)
	if args.modData and args.playerUsername then
		local players = getOnlinePlayers();

		for i=0, #players do
			local player = players:get(i);
			if player:getUsername() == args.playerUsername then
				local inventory = player:getInventory();
				local items = inventory:getItems();
				local itemFound = false;

				for ii=0, #items do
					local item = items[ii];
					local itemModData = item:getModData();

					if itemModData.rpslUniqueID == args.ModData.rpslUniqueID then
						item.modData = args.modData;
						itemFound = true;
						break;
					end
				end

				if not itemFound then
					local playerSquare = player:getSquare();
					local nearbyContainers = playerSquare:getWorldObjects();

					for iii=0, #nearbyContainers do
						local container = nearbyContainers[iii];
						container = container:getItem();
						local containerInventory = container:getInventory();
						local containerItems = containerInventory:getItems();

						for iiii=0, #containerItems do
							local containerItem = containerItems[iiii];
							local itemModData = containerItem:getModData();

							if itemModData.rpslUniqueID == args.ModData.rpslUniqueID then
								item.modData = args.modData;
								itemFound = true;
								break;
							end
						end

					end
				end
			end
		end
	end
end

function shoppingLists.OnClientCommand(module, command, player, args)
	if not isServer() then return end
	if module ~= 'RPShoppingLists' then return end
	if Commands[command] then
		Commands[command](player, args);
	end
end


Events.OnClientCommand.Add(shoppingLists.OnClientCommand);