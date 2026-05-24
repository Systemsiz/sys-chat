local QBCore = exports[Config.CoreName]:GetCoreObject()
local isChatActive = false

-- Komutları sunucudan çekip NUI'ye yollama
local customSuggestions = {}

local function RefreshCommands()
    QBCore.Functions.TriggerCallback('sys-chat:server:GetCommands', function(cmds)
        -- Sunucudan gelen QBCore komutları ile diğer scriptlerin (chat:addSuggestion) komutlarını birleştir
        local finalCommands = {}
        local added = {}

        for _, cmd in ipairs(cmds) do
            table.insert(finalCommands, cmd)
            added[cmd.cmd] = true
        end

        for cmdName, helpText in pairs(customSuggestions) do
            if not added[cmdName] then
                table.insert(finalCommands, {
                    cmd = cmdName,
                    desc = helpText
                })
                added[cmdName] = true
            end
        end

        SendNUIMessage({
            type = 'LOAD_COMMANDS',
            commands = finalCommands
        })
    end)
end

-- Diğer scriptlerin eklediği komut önerilerini yakalama
RegisterNetEvent('chat:addSuggestion', function(name, help, params)
    local cmdName = name
    if string.sub(cmdName, 1, 1) ~= "/" then
        cmdName = "/" .. cmdName
    end
    customSuggestions[cmdName] = help or "Komut"
    RefreshCommands()
end)

RegisterNetEvent('chat:addSuggestions', function(suggestions)
    for _, sug in ipairs(suggestions) do
        local cmdName = sug.name
        if string.sub(cmdName, 1, 1) ~= "/" then
            cmdName = "/" .. cmdName
        end
        customSuggestions[cmdName] = sug.help or "Komut"
    end
    RefreshCommands()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    RefreshCommands()
end)

-- Script restart yediğinde vs. (oyuncu zaten oyundaysa)
CreateThread(function()
    Wait(1000)
    RefreshCommands()
end)

-- Chat'i açma tuşu
RegisterNetEvent('sys-chat:client:openChat', function()
    if not isChatActive then
        isChatActive = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'ON_OPEN'
        })
    end
end)

-- Varsayılan chat komutunu engelleme ve kendi arayüzümüzü tetikleme
CreateThread(function()
    SetTextChatEnabled(false) -- Varsayılan FiveM chat'ini kapat
    SetNuiFocus(false, false)

    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.ChatKey) then
            TriggerEvent('sys-chat:client:openChat')
        end
    end
end)

-- UI'dan gelen mesaj kapama isteği
RegisterNUICallback('closeChat', function(data, cb)
    isChatActive = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- UI'dan gelen mesaj gönderme isteği
RegisterNUICallback('sendMessage', function(data, cb)
    local message = data.message
    
    if message and message ~= "" then
        if string.sub(message, 1, 1) == "/" then
            -- Bu bir komut
            local cmdName = string.match(message, "^/([^%s]+)")
            local rest = string.match(message, "^/[^%s]+%s+(.*)") or ""
            
            if cmdName == "/me" or cmdName == "/do" then
                -- Başka scriptlerin /me veya /do komutunu ezip chatte görünmesini engellemesine karşı doğrudan sys-chat'e gönder:
                TriggerServerEvent('sys-chat:server:RoleplayCommand', string.sub(cmdName, 2), rest)
                -- İsteğe bağlı olarak diğer scriptler (3d text vs) için de ExecuteCommand çalıştırılır:
                ExecuteCommand(string.sub(message, 2))
            else
                ExecuteCommand(string.sub(message, 2))
            end
        else
            -- Normal mesaj ise yakındaki oyunculara yolla (Say)
            TriggerServerEvent('sys-chat:server:SendMessage', "say", message)
        end
    end

    isChatActive = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Sunucudan gelen mesajı UI'a yollama
RegisterNetEvent('sys-chat:client:addMessage', function(messageData)
    if messageData.senderId == GetPlayerServerId(PlayerId()) then
        messageData.isMine = true
    else
        messageData.isMine = false
    end

    SendNUIMessage({
        type = 'ON_MESSAGE',
        message = messageData
    })
end)
