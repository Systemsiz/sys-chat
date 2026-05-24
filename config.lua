Config = {}

Config.CoreName = "qb-core" -- Eğer core adınız farklıysa buradan değiştirebilirsiniz.

-- Chat Tuşu (T varsayılan)
Config.ChatKey = 245 

-- Hangi Meslekler Komutları Kullanabilir
Config.PoliceJobs = {
    ['police'] = true,
    ['sheriff'] = true,
}

Config.AmbulanceJobs = {
    ['ambulance'] = true,
}

-- /me ve /do komutları için gösterim mesafesi
Config.RoleplayProximity = 20.0
