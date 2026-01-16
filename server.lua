local ESX = nil
local QBCore = nil

-- Initialize framework
Citizen.CreateThread(function()
    if Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

-- Function to get phone number based on phone script
local function getPhoneNumber(source, identifier, citizenid)
    local phoneNumber = nil
    
    if Config.PhoneScript == 'default' then
        -- Use default from users table (handled in main function)
        return nil
    elseif Config.PhoneScript == 'gcphone' then
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM users WHERE identifier = ?', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    elseif Config.PhoneScript == 'd-phone' or Config.PhoneScript == 'd_phone' then
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM users WHERE identifier = ?', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    elseif Config.PhoneScript == 'qs-smartphone' then
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM users WHERE identifier = ?', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    elseif Config.PhoneScript == 'qb-phone' then
        local result = exports.oxmysql:executeSync('SELECT charinfo FROM players WHERE citizenid = ?', {citizenid})
        if result and result[1] and result[1].charinfo then
            local charinfo = json.decode(result[1].charinfo)
            phoneNumber = charinfo.phone
        end
    elseif Config.PhoneScript == 'lb-phone' then
        -- LB Phone stores in phone_phones table
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM phone_phones WHERE id = (SELECT phone_id FROM users WHERE identifier = ?)', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    elseif Config.PhoneScript == 'yflip-phone' then
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM users WHERE identifier = ?', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    elseif Config.PhoneScript == 'okokPhone' then
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM users WHERE identifier = ?', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    elseif Config.PhoneScript == 'high_phone' then
        local result = exports.oxmysql:executeSync('SELECT phone_number FROM users WHERE identifier = ?', {identifier})
        if result and result[1] then
            phoneNumber = result[1].phone_number
        end
    end
    
    return phoneNumber
end

-- Function to send Discord webhook
local function sendWebhook(playerData, playerName, playerId)
    if not Config.Webhook.enabled or not Config.Webhook.url or Config.Webhook.url == '' then
        return
    end
    
    local embed = {
        {
            ["color"] = Config.Webhook.color,
            ["title"] = Config.Webhook.title,
            ["description"] = "Player **" .. playerName .. "** (ID: " .. playerId .. ") used the /" .. Config.Command .. " command",
            ["fields"] = {
                {
                    ["name"] = "Character Name",
                    ["value"] = playerData.name or "Unknown",
                    ["inline"] = true
                },
                {
                    ["name"] = "Player ID",
                    ["value"] = tostring(playerId),
                    ["inline"] = true
                },
                {
                    ["name"] = "Date of Birth",
                    ["value"] = playerData.dateOfBirth or "Unknown",
                    ["inline"] = true
                },
                {
                    ["name"] = "Job",
                    ["value"] = (playerData.job and (playerData.job.label or playerData.job.name)) or "Unemployed",
                    ["inline"] = true
                },
                {
                    ["name"] = "Bank Money",
                    ["value"] = "$" .. (playerData.bankMoney or 0),
                    ["inline"] = true
                },
                {
                    ["name"] = "Cash Money",
                    ["value"] = "$" .. (playerData.cashMoney or 0),
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "zd_charinfo by ZydeDevelopment • " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }
    
    PerformHttpRequest(Config.Webhook.url, function(err, text, headers) end, 'POST', json.encode({
        username = Config.Webhook.botName,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Function to get ESX player data
local function getESXPlayerData(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        return nil 
    end
    
    local playerData = {
        name = xPlayer.getName(),
        playerId = source,
        job = {
            name = xPlayer.job.name,
            label = xPlayer.job.label,
            grade = xPlayer.job.grade,
            grade_label = xPlayer.job.grade_label
        },
        bankMoney = xPlayer.getAccount('bank').money,
        cashMoney = xPlayer.getMoney(),
        dateOfBirth = nil,
        phoneNumber = nil,
        hunger = nil,
        thirst = nil
    }
    
    -- Get additional data from database using oxmysql
    local result = exports.oxmysql:executeSync('SELECT dateofbirth, phone_number FROM users WHERE identifier = ?', {xPlayer.identifier})
    
    if result and result[1] then
        playerData.dateOfBirth = result[1].dateofbirth
        
        -- Get phone number based on phone script config
        if Config.PhoneScript == 'default' then
            playerData.phoneNumber = result[1].phone_number
        else
            playerData.phoneNumber = getPhoneNumber(source, xPlayer.identifier, nil)
        end
        
        print('[zd_charinfo] Loaded from DB - DOB: ' .. tostring(playerData.dateOfBirth) .. ', Phone: ' .. tostring(playerData.phoneNumber))
    else
        print('[zd_charinfo] No data found in users table for identifier: ' .. xPlayer.identifier)
    end
    
    -- Get status data if esx_status exists
    if GetResourceState('esx_status') == 'started' then
        TriggerEvent('esx_status:getStatus', source, 'hunger', function(status)
            if status then
                playerData.hunger = math.floor((status.getPercent and status.getPercent() or (status.val / 1000000 * 100)))
            end
        end)
        
        TriggerEvent('esx_status:getStatus', source, 'thirst', function(status)
            if status then
                playerData.thirst = math.floor((status.getPercent and status.getPercent() or (status.val / 1000000 * 100)))
            end
        end)
        
        -- Wait a bit for callbacks to complete
        Wait(100)
    end
    
    TriggerClientEvent('zd_charinfo:showPlayerInfo', source, playerData)
    sendWebhook(playerData, GetPlayerName(source), source)
end

-- Function to get QB-Core player data
local function getQBPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        return nil 
    end
    
    local playerData = {
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        dateOfBirth = Player.PlayerData.charinfo.birthdate,
        playerId = source,
        citizenId = Player.PlayerData.citizenid,
        phoneNumber = nil,
        job = {
            name = Player.PlayerData.job.name,
            label = Player.PlayerData.job.label,
            grade = Player.PlayerData.job.grade.level,
            grade_label = Player.PlayerData.job.grade.name
        },
        gang = {
            name = Player.PlayerData.gang.name,
            label = Player.PlayerData.gang.label,
            grade = Player.PlayerData.gang.grade
        },
        bankMoney = Player.PlayerData.money.bank,
        cashMoney = Player.PlayerData.money.cash,
        hunger = Player.PlayerData.metadata.hunger or 0,
        thirst = Player.PlayerData.metadata.thirst or 0
    }
    
    -- Get phone number based on phone script config
    if Config.PhoneScript == 'default' then
        playerData.phoneNumber = Player.PlayerData.charinfo.phone
    else
        playerData.phoneNumber = getPhoneNumber(source, nil, Player.PlayerData.citizenid)
    end
    
    TriggerClientEvent('zd_charinfo:showPlayerInfo', source, playerData)
    sendWebhook(playerData, GetPlayerName(source), source)
end

-- Handle player info request
RegisterNetEvent('zd_charinfo:getPlayerInfo', function()
    local source = source
    
    if Config.Framework == 'esx' then
        getESXPlayerData(source)
    elseif Config.Framework == 'qb' then
        getQBPlayerData(source)
    else
        print('[zd_charinfo] Error: Invalid framework specified in config!')
    end
end)
