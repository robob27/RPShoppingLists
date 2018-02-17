require('UI/RPSLISTextEntryWithEnterBox');

RPUIInputOkCancelModal = ISTextBox:derive("RPUIInputOkCancelModal");

function RPUIInputOkCancelModal:initialise()
    ISCollapsableWindow.initialise(self);

	local fontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
	local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12
	local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12
	local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
	local buttonHgt = math.max(fontHgt + 6, 25)
	local padBottom = 10

    self.yes = ISButton:new((self:getWidth() / 2)  - 5 - buttonWid, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Ok"), self, RPUIInputOkCancelModal.onClick);
    self.yes.internal = "OK";
    self.yes:initialise();
    self.yes:instantiate();
    self.yes.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.yes);

    self.no = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Cancel"), self, RPUIInputOkCancelModal.onClick);
    self.no.internal = "CANCEL";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.no);

    self.fontHgt = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
    local inset = 2
    local height = inset + self.fontHgt + inset
    self.entry = RPSLISTextEntryWithEnterBox:new(self.defaultEntryText, self:getWidth() / 2 - ((self:getWidth() - 40) / 2), (self:getHeight() - height) / 2, self:getWidth() - 40, height, self, self.yes, self.player, self.target, true);
    self.entry.font = UIFont.Medium
    self.entry:initialise();
    self.entry:instantiate();
    self:addChild(self.entry);

    self.entry:focus();
end

function RPUIInputOkCancelModal:onClick(button)
    self:destroy();
    if self.onclick ~= nil then
        self.onclick(button, self.player, self.target, self.param1, self.param2, self.param3, self.param4);
    end
end

function RPUIInputOkCancelModal:close()
    ISCollapsableWindow.close(self)
    if JoypadState.players[self.playerIndex+1] then
        setJoypadFocus(self.playerIndex, nil);
    end
end

function RPUIInputOkCancelModal:new(x, y, width, height, text, defaultEntryText, onclick, target, playerIndex, param1, param2, param3, param4)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    local playerObj = playerIndex and getSpecificPlayer(playerIndex) or nil
    if y == 0 then
        if playerObj and playerObj:getJoypadBind() ~= -1 then
            o.y = getPlayerScreenTop(playerIndex) + (getPlayerScreenHeight(playerIndex) - height) / 2
        else
            o.y = o:getMouseY() - (height / 2)
        end
        o:setY(o.y)
    end
    if x == 0 then
        if playerObj and playerObj:getJoypadBind() ~= -1 then
            o.x = getPlayerScreenLeft(playerIndex) + (getPlayerScreenWidth(playerIndex) - width) / 2
        else
            o.x = o:getMouseX() - (width / 2)
        end
        o:setX(o.x)
    end
    o.name = nil;
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.width = width;
    local txtWidth = getTextManager():MeasureStringX(UIFont.Small, text) + 10;
    if width < txtWidth then
        o.width = txtWidth;
    end
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    o.text = text;
    o.target = target;
    o.onclick = onclick;
    o.player = getSpecificPlayer(playerIndex);
    o.playerIndex = playerIndex;
    o.param1 = param1;
    o.param2 = param2;
    o.param3 = param3;
    o.param4 = param4;
    o.defaultEntryText = defaultEntryText;
    return o;
end