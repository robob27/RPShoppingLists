--Forked from code written by RoboMat for Convenient Bags http://steamcommunity.com/sharedfiles/filedetails/?id=670807387
require('TimedActions/ISTimedActionQueue');
require('TimedActions/ISBaseTimedAction');
require('TimedActions/ISInventoryTransferAction');
require('UI/RPSLUITagModal');
require('UI/RPUIInputOkCancelModal');
require('luautils');

local MENU_ENTRY_EDIT_LIST  = "View or update shopping list";
local MENU_ENTRY_EDIT_LIST_READ_ONLY  = "View shopping list";
local MENU_ENTRY_RENAME_LIST  = "Rename shopping list";
local SPLIT_IDENTIFIER = ',';

local function convertArrayList(arrayList)
    local itemTable = {};

    for i = 1, arrayList:size() do
        itemTable[i] = arrayList:get(i - 1);
    end

    return itemTable;
end

local function storeNewTag(button)
    local tagName = button.parent.entryItemName:getText();
    local tagQuantity = button.parent.entryItemQuantity:getText();

    local modData = button.parent.shoppingListItem:getModData();
    modData.rpsltags = modData.rpsltags or {};

    if button.internal == 'ADD' then
        tagName = tagName:gsub('^%s*(.-)%s*$', '%1'); -- Trim whitespace.

        if tagQuantity and tagQuantity ~= '' then
            if not tagQuantity:match('^%s*%d-%s*$') then
                tagQuantity = nil;
            else
                tagQuantity = tagQuantity:gsub('^%s*(%d-)%s*$', '%1');
            end
        end

        if (not tagQuantity or tagQuantity == '') and (not tagName or tagName == '') then
            storeNewTag(button.parent.dismiss);
            return;
        elseif not tagQuantity or tagQuantity == '' then
            button.parent.entryItemName:unfocus();
            button.parent.entryItemQuantity:focus();
        elseif not tagName or tagName == '' then
            button.parent.entryItemQuantity:unfocus();
            button.parent.entryItemName:focus();
        else
            modData.rpsltags[tagName] = tagQuantity;
            button.parent.tagList:renderItemsFromModData(modData.rpsltags);
            button.parent.entryItemName:setText('');
            button.parent.entryItemQuantity:setText('');
            button.parent.entryItemQuantity:unfocus();
            button.parent.entryItemName:focus();
            button.parent:syncModData(modData);
        end

    elseif button.internal == 'DISMISS' then
        button.parent:destroy();
    end
end

function RPSLOnAddTag(shoppingListItem, player, playerIndex, readOnly)
    if shoppingListItem:getContainer() and luautils.haveToBeTransfered(player, shoppingListItem) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, shoppingListItem, shoppingListItem:getContainer(), player:getInventory()));
    end
    
    local modal = RPSLUITagModal:new(0, 0, 280, 220, storeNewTag, playerIndex, shoppingListItem, readOnly);
    modal.backgroundColor.r =   0;
    modal.backgroundColor.g =   0;
    modal.backgroundColor.b =   0;
    modal.backgroundColor.a = 0.9;
    modal:initialise();
    modal:addToUIManager();
end

local function createShoppingListMenuEntries(player, playerIndex, context, shoppingListItem, readOnly)
    local editListMenuEntryText;

    if readOnly then
        editListMenuEntryText = MENU_ENTRY_EDIT_LIST_READ_ONLY;
    else
        editListMenuEntryText = MENU_ENTRY_EDIT_LIST;
    end

    context:addOption(editListMenuEntryText, shoppingListItem, RPSLOnAddTag, player, playerIndex, readOnly);

    if not readOnly then
        context:addOption(MENU_ENTRY_RENAME_LIST, shoppingListItem, RPSLOnRenameList, playerIndex);
    end
end


local function createInventoryMenu(playerIndex, context, items)
    local player = getSpecificPlayer(playerIndex);

    if #items > 1 then
        return;
    end

    local playerInventory = player:getInventory();
    local hasWritingTool = playerInventory:FindAndReturn('Pen') or playerInventory:FindAndReturn('Pencil');

    local item;
    local stack;

    -- Iterate through all clicked items
    for _, entry in ipairs(items) do
        local isShoppingList = instanceof(entry, "InventoryItem") and entry:getType() == "RPShoppingList";

        if isShoppingList and hasWritingTool then
            item = entry; -- store in local variable
            break;
        elseif isShoppingList then
            item = entry;
            break;
        elseif type(entry) == "table" then
            stack = entry;
            break;
        end
    end

    if item and hasWritingTool then
        createShoppingListMenuEntries(player, playerIndex, context, item, false);
        return;
    elseif item then
        createShoppingListMenuEntries(player, playerIndex, context, item, true);
    end

    if stack and stack.items then
        for i = 1, #stack.items do
            local stackItem = stack.items[i];
            local isShoppingList = instanceof(stackItem, "InventoryItem") and stackItem:getType() == "RPShoppingList";

            if isShoppingList and hasWritingTool then
                createShoppingListMenuEntries(player, playerIndex, context, stackItem, false);
                return;
            elseif isShoppingList then
                createShoppingListMenuEntries(player, playerIndex, context, stackItem, true);
                return;
            end
        end
    end
end

function RPSLOnRenameList(list, playerIndex)
    local modal = RPUIInputOkCancelModal:new(0, 0, 280, 180, 'Rename shopping list:', list:getName(), RPSLOnRenameListClick, list, playerIndex);
    modal:initialise();
    modal:addToUIManager();
end

function RPSLOnRenameListClick(button, player, item)
    if button.internal == "OK" then
        if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
            item:setName(button.parent.entry:getText());
            local pdata = getPlayerData(player:getPlayerNum());
            pdata.playerInventory:refreshBackpacks();
            pdata.lootInventory:refreshBackpacks();
        end
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(createInventoryMenu);