-- Radar for the skydiving team
local function UpdateBlips()
    local teamPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for _, player in pairs(players) do
        if player.Functions.GetItemByName(Config.Tracker) ~= nil then
            local coords = GetEntityCoords(GetPlayerPed(player.PlayerData.source))
            local heading = GetEntityHeading(GetPlayerPed(player.PlayerData.source))
            teamPlayers[#teamPlayers+1] = {
                source = player.PlayerData.source,
                label = player.PlayerData.charinfo.lastname,
                location = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    w = heading
                }
            }
        end
    end
    TriggerClientEvent("tis-skydiving:client:UpdateBlips", -1, teamPlayers)
end

CreateThread(function()
    while true do
        Wait(10000)
        UpdateBlips()
    end
end)