local TeamBlips = {}

local function CreateTeamBlips(playerId, playerLabel, playerLocation)
    local ped = GetPlayerPed(playerId)
    local blip = GetBlipFromEntity(ped)
    if not DoesBlipExist(blip) then
        if NetworkIsPlayerActive(playerId) then
            blip = AddBlipForEntity(ped)
        else
            blip = AddBlipForCoord(playerLocation.x, playerLocation.y, playerLocation.z)
        end
        SetBlipSprite(blip, 1)
        ShowHeadingIndicatorOnBlip(blip, true)
        SetBlipRotation(blip, math.ceil(playerLocation.w))
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 27)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(playerLabel)
        EndTextCommandSetBlipName(blip)
        TeamBlips[#TeamBlips+1] = blip
    end

    -- if GetBlipFromEntity(PlayerPedId()) == blip then
    --     -- Ensure we remove our own blip.
    --     RemoveBlip(blip)
    -- end
end

RegisterNetEvent('tis-skydiving:client:UpdateBlips', function(players)
    if TeamBlips then
        for k, v in pairs(TeamBlips) do
            RemoveBlip(v)
        end
    end
    if QBCore.Functions.HasItem(Config.Tracker) then
        TeamBlips = {}
        if players then
            for k, data in pairs(players) do
                local id = GetPlayerFromServerId(data.source)
                CreateTeamBlips(id, data.label, data.location)
            end
        end
    end
end)