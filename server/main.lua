local QBCore = exports[Config.CoreName]:GetCoreObject()

-- Yardımcı Fonksiyon: Karakter ismini alma
local function GetCharacterName(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    end
    return "Unknown"
end

-- Yardımcı Fonksiyon: Mesajı Yakındakilere Gönderme
local function SendProximityMessage(source, radius, messageData)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)

        if distance <= radius then
            TriggerClientEvent('sys-chat:client:addMessage', playerId, messageData)
        end
    end
end

-- Genel Mesaj İşleyici (Arayüzden gönderilen default mesajlar)
RegisterNetEvent('sys-chat:server:SendMessage', function(type, message)
    local src = source
    local name = GetCharacterName(src)

    if type == "ooc" then
        local msgData = {
            templateId = "ooc",
            author = "OOC | " .. GetPlayerName(src),
            text = message
        }

        if Config.OOCProximity then
            SendProximityMessage(src, Config.OOCProximity, msgData)
        else
            TriggerClientEvent('sys-chat:client:addMessage', -1, msgData)
        end
    end
end)

-- Komutlar

-- /ooc
QBCore.Commands.Add('ooc', 'OOC Sohbet (Karakter Dışı)', {{name = 'mesaj', help = 'Gönderilecek mesaj'}}, false, function(source, args)
    local src = source
    local message = table.concat(args, " ")
    
    local msgData = {
        templateId = "ooc",
        author = "OOC | " .. GetPlayerName(src),
        text = message
    }

    if Config.OOCProximity then
        SendProximityMessage(src, Config.OOCProximity, msgData)
    else
        TriggerClientEvent('sys-chat:client:addMessage', -1, msgData)
    end
end)

-- /me
QBCore.Commands.Add('me', 'Kişisel bir eylem belirtir (Rol)', {{name = 'eylem', help = 'Yapılan eylem'}}, false, function(source, args)
    local src = source
    local message = table.concat(args, " ")
    local name = GetCharacterName(src)
    
    local msgData = {
        templateId = "me",
        author = name,
        text = message
    }

    SendProximityMessage(src, Config.RoleplayProximity, msgData)
end)

-- /do
QBCore.Commands.Add('do', 'Çevresel bir durumu belirtir (Rol)', {{name = 'durum', help = 'Çevresel durum'}}, false, function(source, args)
    local src = source
    local message = table.concat(args, " ")
    local name = GetCharacterName(src)
    
    local msgData = {
        templateId = "do",
        author = name,
        text = message
    }

    SendProximityMessage(src, Config.RoleplayProximity, msgData)
end)

-- /police
QBCore.Commands.Add('police', 'Polis Departmanı Duyurusu', {{name = 'mesaj', help = 'Duyuru metni'}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player and Config.PoliceJobs[Player.PlayerData.job.name] then
        local message = table.concat(args, " ")
        local msgData = {
            templateId = "police",
            author = "LSPD Duyuru",
            text = message
        }
        TriggerClientEvent('sys-chat:client:addMessage', -1, msgData)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanmak için yetkiniz yok.', 'error')
    end
end)

-- /ems
QBCore.Commands.Add('ems', 'Sağlık Departmanı Duyurusu', {{name = 'mesaj', help = 'Duyuru metni'}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player and Config.AmbulanceJobs[Player.PlayerData.job.name] then
        local message = table.concat(args, " ")
        local msgData = {
            templateId = "ems",
            author = "EMS Duyuru",
            text = message
        }
        TriggerClientEvent('sys-chat:client:addMessage', -1, msgData)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Bu komutu kullanmak için yetkiniz yok.', 'error')
    end
end)

-- /anon
QBCore.Commands.Add('anon', 'Anonim Mesaj Gönder', {{name = 'mesaj', help = 'Gönderilecek mesaj'}}, false, function(source, args)
    local src = source
    local message = table.concat(args, " ")
    
    local msgData = {
        templateId = "anon",
        author = "Anonim",
        text = message
    }

    TriggerClientEvent('sys-chat:client:addMessage', -1, msgData)
end)

-- Eski veya varsayılan chat kaynaklarını kapatmak için event eklenebilir
AddEventHandler('chatMessage', function(source, name, message)
    CancelEvent()
end)
