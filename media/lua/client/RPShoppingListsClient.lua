--not implemented yet
local Commands = {};
local shoppingListsClient = {};

function shoppingListsClient.OnServerCommand(module, command, args)
    if not isClient() then return end
    if module ~= 'RPShoppingLists' then return end

    if Commands[command] then
        Commands[command](args);
    end
end


Events.OnServerCommand.Add(shoppingListsClient.OnServerCommand);