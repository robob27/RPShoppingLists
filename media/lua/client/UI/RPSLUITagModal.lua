--RPSLUITagModal forked from code written by RoboMat for Convenient Bags http://steamcommunity.com/sharedfiles/filedetails/?id=670807387
require('UI/RPSLISTextEntryWithEnterBox');
RPSLUITagModal = ISPanel:derive("RPSLUITagModal");

local DEFAULT_FONT = UIFont.Small;
local BUTTON_ADD_ID = 'ADD';
local BUTTON_DISMISS_ID = 'DISMISS';
local HIGHLIGHT_COLORS =    {
                                {r = 0.00, g = 0.00, b = 0.00, a = 0.00},       -- Highlighting off as alpha = 0.0
                                {r = 1.00, g = 0.00, b = 0.00, a = 1.00},       -- Red
                                {r = 1.00, g = 0.50, b = 0.00, a = 1.00},       -- Orange
                                {r = 1.00, g = 1.00, b = 0.00, a = 1.00},       -- Yellow
                                {r = 0.00, g = 1.00, b = 0.00, a = 1.00},       -- Green
                                {r = 0.00, g = 1.00, b = 1.00, a = 1.00},       -- Cyan
                                {r = 0.00, g = 0.50, b = 1.00, a = 1.00},       -- Blue
                                {r = 0.50, g = 0.25, b = 0.75, a = 1.00},       -- Violet
                                {r = 1.00, g = 0.00, b = 1.00, a = 1.00},       -- Magenta
                            };

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
    local modData = self.shoppingListItem:getModData();

    local fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight();
    local buttonAddW = getTextManager():MeasureStringX(DEFAULT_FONT, "Add") + 12;
    local buttonDismissW = getTextManager():MeasureStringX(DEFAULT_FONT, "Dismiss") + 12;
    local buttonHgt = fontHgt + 6
    local padding = 5;
    local dismissH = self:getHeight() - padding - buttonHgt
    local colorSelectH = dismissH - padding - buttonHgt
    local addFieldsH = colorSelectH - padding - buttonHgt
    local addTextH = addFieldsH - padding - fontHgt       -- Not used, reserved for the title of the two fields
    local listEndH = addTextH - padding - buttonHgt

    local totalWidth = buttonDismissW;

    local posX = self:getWidth() * 0.8 - totalWidth * 0.8;
    -- Create button for updating
    self.dismiss = ISButton:new((self:getWidth() / 2) - (buttonDismissW / 2), self:getHeight() - 12 - buttonHgt, buttonDismissW, buttonHgt, 'Dismiss', self, RPSLUITagModal.onClick);
    self.dismiss.internal = BUTTON_DISMISS_ID;
    self.dismiss:initialise();
    self.dismiss:instantiate();
    self.dismiss.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.dismiss);

    -- Create buttons for highlighting colour selection
    local highlightButtonPos = padding
    self.highlightColorBtn = {}
    for color = 1, #HIGHLIGHT_COLORS do
        self.highlightColorBtn[color] = ISButton:new(highlightButtonPos, colorSelectH, buttonHgt, buttonHgt, "", self, RPSLUITagModal.onClickColorSelect);
        self.highlightColorBtn[color]:initialise();
        self.highlightColorBtn[color].internal = "HCOLOR";
        self.highlightColorBtn[color].backgroundColor = {
            r = HIGHLIGHT_COLORS[color]["r"], 
            g = HIGHLIGHT_COLORS[color]["g"], 
            b = HIGHLIGHT_COLORS[color]["b"], 
            a = HIGHLIGHT_COLORS[color]["a"]};
        if( (self.highlightColorBtn[color].backgroundColor["r"] == modData.highlightColorR) and
            (self.highlightColorBtn[color].backgroundColor["g"] == modData.highlightColorG) and
            (self.highlightColorBtn[color].backgroundColor["b"] == modData.highlightColorB) and
            (self.highlightColorBtn[color].backgroundColor["a"] == modData.highlightColorA)) then
            self.highlightColorBtn[color].borderColor = {r=1, g=1, b=1, a=1};
        else
            self.highlightColorBtn[color].borderColor = {r=0.2, g=0.2, b=0.2, a=0.4};
        end
        self:addChild(self.highlightColorBtn[color]);
        self.highlightColorBtn[color].enable = true;
        highlightButtonPos = highlightButtonPos + padding + buttonHgt
    end
    -- Create button for adding
    self.add = ISButton:new(240, addFieldsH, buttonAddW, buttonHgt, 'Add', self, RPSLUITagModal.onClick);
    self.add.internal = BUTTON_ADD_ID;
    self.add:initialise();
    self.add:instantiate();
    self.add.borderColor = {r=1, g=1, b=1, a=0.1};
    -- create item name and quantity fields
    self.fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight()
    local inset = 2
    local height = inset + self.fontHgt + inset

    self.entryItemName = RPSLISTextEntryWithEnterBox:new(self.defaultEntryText, 10, addFieldsH, self:getWidth() - 120, height, self, self.add, self.player, false);
    self.entryItemName:initialise();
    self.entryItemName:instantiate();

    self.entryItemQuantity = RPSLISTextEntryWithEnterBox:new(self.defaultEntryText, 180, addFieldsH, self:getWidth() - 230, height, self, self.add, self.player, false);
    self.entryItemQuantity:initialise();
    self.entryItemQuantity:instantiate();

    posX = posX + buttonAddW + padding;
    self.tagList = RPSLUIMultiTargetScrollingListBox:new(10, 25, 260, listEndH, self.player);
    self.tagList:setFont(getTextManager():getFontFromEnum(DEFAULT_FONT));

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

function RPSLUITagModal:onClickColorSelect(button)
    local modData = self.shoppingListItem:getModData();
    
    for cbutton = 1, #(self.highlightColorBtn) do
        self.highlightColorBtn[cbutton].borderColor = {r=0.2, g=0.2, b=0.2, a=0.4};
    end
   
    button.borderColor = {r=1, g=1, b=1, a=1};
    button.backgroundColor["a"] = 1
    modData.highlightColorR = button.backgroundColor["r"]
    modData.highlightColorG = button.backgroundColor["g"]
    modData.highlightColorB = button.backgroundColor["b"]
    modData.highlightColorA = button.backgroundColor["a"]   -- only used for highlighting activation
    
    self:syncModData(modData)
end

function RPSLUITagModal:prerender()
    local fontHgt = getTextManager():getFontFromEnum(DEFAULT_FONT):getLineHeight();
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(self.text, self:getWidth() / 2, 5, 1, 1, 1, 1, DEFAULT_FONT);

    if not self.readOnly then
        self:drawText('Item Name:', self.entryItemName:getX(), self.entryItemName:getY() - fontHgt - 5, 1, 1, 1, 1, DEFAULT_FONT);
        self:drawText('Quantity:', self.entryItemQuantity:getX(), self.entryItemQuantity:getY() - fontHgt - 5, 1, 1, 1, 1, DEFAULT_FONT);
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