--[[
* Ashita - Copyright (c) 2014 - 2022 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'Almavivaconte';
_addon.name     = 'ticker';
_addon.version  = '0.0.1';

require 'common'

local colors = {   
    4279301120,
    4280084480,
    4280867840,
    4281651200,
    4282434560,
    4283217920,
    4284001280,
    4284784640,
    4285568000,
    4286351360,
    4287134720,
    4287918080,
    4288701440,
    4289484800,
    4290268160,
    4291051520,
    4291834880,
    4292618240,
    4293401600,
    4294184960,
    4294901760
}

local ticker_config =
{
    font =
    {
        family      = 'Arial',
        size        = 6,
        color       = 0xFFFFFFFF,
        position    = { -30, -30 },
        bgcolor     = 0x80000000,
        bgvisible   = true
    },
};

local tickerBlocked = false;
local entityBlocked = false;
local tickTime = 21;
local currentMP = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0);
local currentHP = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0);
local currenstatus = 0;

local function tickerUnblocker()
    tickerBlocked = false;
end

local function tickerBlocker()
    tickerBlocked = true;
    ashita.timer.once(.25, tickerUnblocker);
end

local function unblockEntity()
    entityBlocked = false;
end

local function blockEntity()
    entityBlocked = true;
    ashita.timer.once(20, unblockEntity);
end

local currentLevel = AshitaCore:GetDataManager():GetPlayer():GetMainJobLevel();
local levelMod;
if(currentLevel <= 25) then
    levelMod = 0;
elseif(currentLevel <= 40) then
    levelMod = 5;
elseif(currentLevel <= 60) then
    levelMod = 7;
else
    levelMod = 10;
end

local function getStatus(index)
    return GetEntity(index).Status;
end

local function errHandler()
    return;
end
    

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the configuration..
    ticker_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', ticker_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():Create('__ticker_addon');
    f:SetColor(ticker_config.font.color);
    f:SetFontFamily(ticker_config.font.family);
    f:SetFontHeight(ticker_config.font.size);
    f:SetBold(false);
    f:SetPositionX(ticker_config.font.position[1]);
    f:SetPositionY(ticker_config.font.position[2]);
    f:SetVisibility(false);
    f:GetBackground():SetColor(ticker_config.font.bgcolor);
    f:GetBackground():SetVisibility(ticker_config.font.bgvisible);
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():Get('__ticker_addon');
    ticker_config.font.position = { f:GetPositionX(), f:GetPositionY() };
    -- Save the configuration..
    ashita.settings.save(_addon.path .. 'settings/settings.json', ticker_config);
    
    -- Unload the font object..
    AshitaCore:GetFontManager():Delete('__ticker_addon');
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    
    local f = AshitaCore:GetFontManager():Get('__ticker_addon');
    local selfIndex;
    if not entityBlocked then
        selfIndex = AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(0);
        currentStatus = GetEntity(selfIndex).Status;
    end
    
    if tickTime >= 1 and tickTime <= 21 then
        f:SetColor(colors[tickTime]);
    end
    f:SetText(tostring(tickTime));
    
    if currentStatus ~= nil then
        if currentStatus == 33 and not (AshitaCore:GetDataManager():GetParty():GetMemberCurrentMPP(0) == 100 and AshitaCore:GetDataManager():GetParty():GetMemberCurrentHPP(0) == 100) then
            f:SetVisibility(true);
            if not tickerBlocked then
                tickerBlocker();
                if tickTime > 0 then
                    tickTime = tickTime - 1;
                    if tickTime == 4 then
                    currentMP = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0);
                    currentHP = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0);
                    end
                end 
                if AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0) - currentMP > (10 + levelMod) or AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0) - currentHP > (10 + levelMod) then
                    tickTime = 10;
                    currentMP = AshitaCore:GetDataManager():GetParty():GetMemberCurrentMP(0);
                    currentHP = AshitaCore:GetDataManager():GetParty():GetMemberCurrentHP(0);
                end
            end
        else
            tickTime = 21;
            f:SetVisibility(false);
        end
    end
    
    return;
end);

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when our addon receives an incoming packet.
---------------------------------------------------------------------------------------------------
ashita.register_event('outgoing_packet', function(id, size, data, modified, blocked)
    
    if (id == 0x00D) then
        local f = AshitaCore:GetFontManager():Get('__ticker_addon');
        entityBlocked = true;
        f:SetVisibility(false);
    elseif (id == 0x0E8) then
        entityBlocked = false;
    end
    return false;
    
end);