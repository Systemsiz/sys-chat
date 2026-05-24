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

-- OOC Chat Mesafesi (Varsayılan: Global ise false, Yakın Mesafe ise sayısal değer (örn 20.0))
Config.OOCProximity = false -- false olursa herkes görür. 

-- /me ve /do komutları için gösterim mesafesi
Config.RoleplayProximity = 20.0
