local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = nil

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        while QBCore == nil do
            Citizen.Wait(1)
        end
        QBCore.Functions.GetPlayerData(function(PlayerData)
            if PlayerData.job ~= nil then
                PlayerJob = PlayerData.job
            end
            print(PlayerData.job.name)
        end)
    end
end)

local particle = nil
local particles = {}

local function removeFlares()
    for k, v in pairs(particles) do
        StopParticleFxLooped(v)
        particles[k] = nil
    end
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

RegisterCommand("landplane", function ()
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

RegisterCommand("startvfx", function ()
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then return end
    local blipCoords = GetBlipCoords(blip)
    TriggerServerEvent("tis-skydiving:server:CreateLandingZone", blipCoords)
end)

RegisterCommand("endvfx", function ()
    TriggerServerEvent("tis-skydiving:server:DeleteLandingZone")
end)

RegisterNetEvent("tis-skydiving:client:PlaceFlares")
AddEventHandler("tis-skydiving:client:PlaceFlares", function (coords)
    local PtfxAsset = "core"
    if not HasNamedPtfxAssetLoaded(PtfxAsset) then
        RequestNamedPtfxAsset(PtfxAsset)
        print(PtfxAsset)
        while not HasNamedPtfxAssetLoaded(PtfxAsset) do
            Wait(10)
        end
    end

    local r = 15
    local nPoints = 6
    local p = 360 / nPoints
    for i = 0, nPoints - 1, 1 do
        local rad = (p * i) * math.pi / 180
        local offset = vector3(r * math.sin(rad), r * math.cos(rad), 0)
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
    end


    RemoveNamedPtfxAsset(PtfxAsset) -- Clean up
end)

RegisterNetEvent("tis-skydiving:client:RemoveFlares")
AddEventHandler("tis-skydiving:client:RemoveFlares", removeFlares)

-- Citizen.CreateThread(function ()
--     local veh = nil
--     while true do
--         Citizen.Wait(10)
--     end
-- end)