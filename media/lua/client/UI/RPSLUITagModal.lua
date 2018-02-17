--RPSLUITagModal forked from code written by RoboMat for Convenient Bags http://steamcommunity.com/sharedfiles/filedetails/?id=670807387
require('UI/RPSLISTextEntryWithEnterBox');
RPSLUITagModal = ISPanel:derive("RPSLUITagModal");

local DEFAULT_FONT = UIFont.Small;
local BUTTON_ADD_ID = 'ADD';
local BUTTON_DISMISS_ID = 'DISMISS';

function RPSLUITagModal:syncModData(newModData)
    local playerObj = self.player and getSpecificPlayer(self.player) or nil

    if not playerObj then
        print(">>>>>>>>>>>>> NO PLAYER OBJECT! RETURNING. PLZ REPORT <3");
        return;
    end

    local username = playerObj:getUsername();

    sendClientCommand(playerObj, 'RPShoppingLists', 'updateShoppingListModData', { playerUsername = username, modData = newModData });
end

function RPSLUITagModal:initialise()
    ISPanel.initialise(self);

    local fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight();
    local buttonAddW = getTextManager():MeasureStringX(DEFAULT_FONT, "Add") + 12;
    local buttonDismissW = getTextManager():MeasureStringX(DEFAULT_FONT, "Dismiss") + 12;
    local textboxHgt = 20;
    local textboxW = 20;

    local buttonHgt = fontHgt + 6
    local padding = 5;

    local totalWidth = buttonDismissW;

    -- Create button for adding
    self.add = ISButton:new(240, 155, buttonAddW, buttonHgt, 'Add', self, RPSLUITagModal.onClick);
    self.add.internal = BUTTON_ADD_ID;
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = {r=1, g=1, b=1, a=0.1};

    local posX = self:getWidth() * 0.8 - totalWidth * 0.8;
    -- Create button for updating
    self.dismiss = ISButton:new((self:getWidth() / 2) - (buttonDismissW / 2), self:getHeight() - 12 - buttonHgt, buttonDismissW, buttonHgt, 'Dismiss', self, RPSLUITagModal.onClick);
    self.dismiss.internal = BUTTON_DISMISS_ID;
    self.dismiss:initialise();
    self.dismiss:instantiate();
    self.dismiss.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.dismiss);

    self.fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight()
    local inset = 2
    local height = inset + self.fontHgt + inset

    self.entryItemName = RPSLISTextEntryWithEnterBox:new(self.defaultEntryText, 10, 155, self:getWidth() - 120, height, self, self.add, self.player, false);
    self.entryItemName:initialise();
    self.entryItemName:instantiate();

    self.entryItemQuantity = RPSLISTextEntryWithEnterBox:new(self.defaultEntryText, 180, 155, self:getWidth() - 230, height, self, self.add, self.player, false);
    self.entryItemQuantity:initialise();
    self.entryItemQuantity:instantiate();

    posX = posX + buttonAddW + padding;
    self.tagList = RPSLUIMultiTargetScrollingListBox:new(10, 25, 260, 95, self.player);
    self.tagList:setFont(getTextManager():getFontFromEnum(DEFAULT_FONT));

    local modData = self.shoppingListItem:getModData();

    if modData.rpsltags then
        for tag, _ in pairs(modData.rpsltags) do
            local itemQuantityTable = {};
            itemQuantityTable[tag] = _;
            self.tagList:addItem(tag .. ' x ' .. _, itemQuantityTable);
        end
    end

    self.tagList:initialise();
    self:addChild(self.tagList);

    if not self.readOnly then
        self:addChild(self.add);
        self:addChild(self.entryItemName);
        self:addChild(self.entryItemQuantity);
        self.tagList:setOnMouseDoubleClick(RPSLUITagModallistItemDoubleClickEvent, self.entryItemName, self.entryItemQuantity);
        self:addChild(self.entryItemName);
        self.entryItemName:focus();
    end
end

function RPSLUITagModallistItemDoubleClickEvent(selectedItem, nameTarget, quantityTarget)
    for tag, _ in pairs(selectedItem) do
        nameTarget:setText(tag);
        quantityTarget:setText(_);
        quantityTarget:focus();
        return;
    end
end

function RPSLUITagModal:setOnlyNumbers(onlyNumbers)
    self.entry:setOnlyNumbers(onlyNumbers);
end

function RPSLUITagModal:destroy()
    self:setVisible(false);
    self:removeFromUIManager();
end

function RPSLUITagModal:onClick(button)
    if self.onclick then
        self.onclick(button);
    end
end

function RPSLUITagModal:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(self.text, self:getWidth() / 2, 5, 1, 1, 1, 1, DEFAULT_FONT);

    if not self.readOnly then
        self:drawText('Item Name:', 10, 135, 1, 1, 1, 1, DEFAULT_FONT);
        self:drawText('Quantity:', 180, 135, 1, 1, 1, 1, DEFAULT_FONT);
    end
end

function RPSLUITagModal:render()
    return;
end

function RPSLUITagModal:new(x, y, width, height, onclick, player, shoppingListItem, readOnly)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    -- TODO rewrite
    local playerObj = player and getSpecificPlayer(player) or nil
    if y == 0 then
        if playerObj and playerObj:getJoypadBind() ~= -1 then
            o.y = getPlayerScreenTop(player) + (getPlayerScreenHeight(player) - height) / 2
        else
            o.y = o:getMouseY() - (height / 2)
        end
        o:setY(o.y)
    end
    if x == 0 then
        if playerObj and playerObj:getJoypadBind() ~= -1 then
            o.x = getPlayerScreenLeft(player) + (getPlayerScreenWidth(player) - width) / 2
        else
            o.x = o:getMouseX() - (width / 2)
        end
        o:setX(o.x)
    end

    o.backgroundColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.5 };
    o.borderColor     = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 };

    local txtWidth = getTextManager():MeasureStringX(DEFAULT_FONT, text) + 10;
    o.width = width < txtWidth and txtWidth or width;
    o.height = height;

    o.anchorLeft = true;
    o.anchorRight = false;  
    o.anchorTop = true;
    o.anchorBottom = false;
    o.moveWithMouse = true;

    o.shoppingListItem = shoppingListItem;

    if readOnly then
        o.text = shoppingListItem:getName();
    else
        o.text = "Edit " .. shoppingListItem:getName();
    end

    o.onclick = onclick;
    o.player = player;
    o.defaultEntryText = '';
    o.readOnly = readOnly;
    return o;
end