local QBCore = exports['qb-core']:GetCoreObject()
-- local PlayerJob = nil
local inTeam = false

-- RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
--     PlayerJob = JobInfo
-- end)

-- RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
--     Wait(1000)
--     QBCore.Functions.GetPlayerData(function(PlayerData)
--         PlayerJob = PlayerData.job
--     end)
-- end)

-- AddEventHandler('onResourceStart', function(resource)
--     if resource == GetCurrentResourceName() then
--         while QBCore == nil do
--             Citizen.Wait(1)
--         end
--         QBCore.Functions.GetPlayerData(function(PlayerData)
--             if PlayerData.job ~= nil then
--                 PlayerJob = PlayerData.job
--             end
--             print(PlayerData.job.name)
--         end)
--     end
-- end)

local TeamBlips = {}

-- Functions
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
    -- print("ejijf")
end

local particle = nil
local particles = {}

function RemoveFlares()
    for k, v in pairs(particles) do
        StopParticleFxLooped(v)
        particles[k] = nil
    end
end

function PlaceFlares(coords, radius, count)
    local flares = {}
    local PtfxAsset = "core"
    if not HasNamedPtfxAssetLoaded(PtfxAsset) then
        RequestNamedPtfxAsset(PtfxAsset)
        print(PtfxAsset)
        while not HasNamedPtfxAssetLoaded(PtfxAsset) do
            Citizen.Wait(10)
        end
    end

    local p = 360 / count
    for i = 0, count - 1, 1 do
        local rad = (p * i) * math.pi / 180
        local offset = vector3(radius * math.sin(rad), radius * math.cos(rad), 0)
        local adjusted = coords + offset
        local retval --[[ boolean ]], groundZ --[[ number ]] =
        GetGroundZFor_3dCoord(
            adjusted.x,
            adjusted.y,
            adjusted.z
        )
        -- print(groundZ)
        -- adjusted.z = adjusted - groundZ
        -- print(offset.x, offset.y)
        if not retval then
            groundZ = adjusted.z
        end

        UseParticleFxAssetNextCall(PtfxAsset) -- Prepare the Particle FX for the next upcomming Particle FX call
        local part = StartParticleFxLoopedAtCoord("exp_grd_flare", adjusted.x, adjusted.y, groundZ, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        table.insert(particles, part)
        table.insert(flares, {x = adjusted.x, y = adjusted.y, z = groundZ})
    end

    local retval --[[ boolean ]], groundZ --[[ number ]] =
        GetGroundZFor_3dCoord(
            coords.x,
            coords.y,
            coords.z
        )
    
    if not retval then
        groundZ = coords.z
    end

    UseParticleFxAssetNextCall(PtfxAsset) -- Prepare the Particle FX for the next upcomming Particle FX call
    local part = StartParticleFxLoopedAtCoord("exp_grd_flare", coords.x, coords.y, groundZ, 0.0, 0.0, 1.0, 1.0, false, false, false, false)
    table.insert(particles, part)
    table.insert(flares, {x = coords.x, y = coords.y, z = groundZ})


    RemoveNamedPtfxAsset(PtfxAsset) -- Clean up
    return flares
end

function PlaceLocationFlares(flares)
    local PtfxAsset = "core"
    if not HasNamedPtfxAssetLoaded(PtfxAsset) then
        RequestNamedPtfxAsset(PtfxAsset)
        while not HasNamedPtfxAssetLoaded(PtfxAsset) do
            Citizen.Wait(10)
        end
    end

    for k, flare in pairs(flares) do
        UseParticleFxAssetNextCall(PtfxAsset) -- Prepare the Particle FX for the next upcomming Particle FX call
        local part = StartParticleFxLoopedAtCoord("exp_grd_flare", flare.x, flare.y, flare.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        table.insert(particles, part)
    end

    RemoveNamedPtfxAsset(PtfxAsset) -- Clean up
end

function ReqMod(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        StopParticleFxLooped(particle)
    end
end)

-- RegisterCommand("landplane", function ()
-- end)

-- RegisterCommand("startvfx", function ()
--     local blip = GetFirstBlipInfoId(8)
--     if not DoesBlipExist(blip) then return end
--     local blipCoords = GetBlipCoords(blip)
--     TriggerServerEvent("tis-skydiving:server:CreateLandingZone", blipCoords)
-- end)

RegisterCommand("endvfx", function ()
    TriggerServerEvent("tis-skydiving:server:DeleteLandingZone")
end)

RegisterNetEvent("tis-skydiving:client:PlaceFlares")
AddEventHandler("tis-skydiving:client:PlaceFlares", PlaceFlares)


RegisterNetEvent("tis-skydiving:client:RemoveFlares")
AddEventHandler("tis-skydiving:client:RemoveFlares", RemoveFlares)

RegisterNetEvent('tis-skydiving:client:OpenStore', function()
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "skydiving", Config.Items)
end)

RegisterNetEvent('tis-skydiving:client:SpawnPlane', function()
    QBCore.Functions.SpawnVehicle(Config.Plane.model, function(veh)
            SetVehicleNumberPlateText(veh, "SkwidDiving")
            exports['LegacyFuel']:SetFuel(veh, 100.0)
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true)
            SetEntityHeading(veh, 60)
    end, vector4(Config.Plane.spawn.pos.x, Config.Plane.spawn.pos.y, Config.Plane.spawn.pos.z, 60), true)
end)

RegisterNetEvent('tis-skydiving:client:LandPlane', function()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false);
    local model = "a_f_y_femaleagent"

    SetPedIntoVehicle(ped, vehicle, 0) -- Switch our seat

    -- Create the pilot ped
    ReqMod(model)
    local pilot = CreatePedInsideVehicle(vehicle, 4, GetHashKey(model), -1, true, false);
    SetModelAsNoLongerNeeded(model)

    TaskPlaneLand(pilot, vehicle, Config.runways[1].start, Config.runways[1].ending)

    -- Jump out after it has been set to fly away
    TaskLeaveVehicle(ped, vehicle, 4160)

    -- Delete the plane and ped after some time
    Citizen.Wait(10000)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(ped, true, true)
    DeleteEntity(ped)
end)

-- Citizen.CreateThread(function ()
--     local veh = nil
--     while true do
--         Citizen.Wait(10)
--     end
-- end)


Citizen.CreateThread(function ()
    exports['qb-target']:AddBoxZone("SkydivingStore", vector3(-912.59, -3022.16, 13.95), 1, 1, {
        name = "SkydivingStore",
        heading = 240,
        debugPoly = false,
        minZ = 12.95,
        maxZ = 14.95,
    }, {
        options = {
            {
                type = "client",
                event = "tis-skydiving:client:OpenStore",
                icon = "fas fa-sign-in-alt",
                label = "Store",
                job = "skydive",
            },
        },
        distance = 2.5
    })
    print(#Config)
    exports['qb-target']:AddBoxZone("SkydivingPlane", Config.Plane.spawn.pos, 20, 20, {
        name = "SkydivingPlane",
        heading = Config.Plane.spawn.heading,
        debugPoly = false,
        minZ = Config.Plane.spawn.pos.z - 2,
        maxZ = Config.Plane.spawn.pos.z + 1,
    }, {
        options = {
            {
                type = "client",
                event = "tis-skydiving:client:SpawnPlane",
                icon = "fas fa-sign-in-alt",
                label = "Spawn Plane",
                job = "skydive",
            },
        },
        distance = 2.5
    })
end)

-- Citizen.CreateThread(function ()
--     while true do
--         if inTeam then
            
--             Citizen.Wait(0)
--         else
--             Citizen.Wait(1000)
--         end
--     end
-- end)

RegisterNetEvent('tis-skydiving:client:StartSkydiving', function(pos, flares)
    inTeam = QBCore.Functions.HasItem(Config.Tracker)

    if inTeam then
        local dropzone = AddBlipForCoord(pos.x, pos.y, pos.z)
        SetBlipSprite (dropzone, 164)
        SetBlipDisplay(dropzone, 4)
        -- SetBlipScale(dropzone, 1)
        SetBlipAsShortRange(dropzone, true)
        SetBlipColour(dropzone, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Drop Zone")
        EndTextCommandSetBlipName(dropzone)
    end

    PlaceLocationFlares(flares)
end)

RegisterNetEvent('tis-skydiving:client:SetInTeam', function(pos, flares)
end)

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