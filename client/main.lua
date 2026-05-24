local QBCore = exports[Config.CoreName]:GetCoreObject()
local isChatActive = false

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
            ExecuteCommand(string.sub(message, 2))
        else
            -- Normal mesaj ise OOC olarak yolla (varsayılan davranış)
            TriggerServerEvent('sys-chat:server:SendMessage', "ooc", message)
        end
    end

    isChatActive = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Sunucudan gelen mesajı UI'a yollama
RegisterNetEvent('sys-chat:client:addMessage', function(messageData)
    SendNUIMessage({
        type = 'ON_MESSAGE',
        message = messageData
    })
end)
