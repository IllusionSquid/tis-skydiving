--[[
    tis-skydiving
    Copyright (C) 2022 IllusionSquid

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

QBCore = exports['qb-core']:GetCoreObject()

local TeamBlips = {}
local dropzone = nil
local dropRadiusBlip = nil
local particles = {}

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

RegisterNetEvent('tis-skydiving:client:StartSkydiving', function(pos, flares, radius)
    if QBCore.Functions.HasItem(Config.Tracker) then
        dropzone = AddBlipForCoord(pos.x, pos.y, pos.z)
        SetBlipSprite (dropzone, 164)
        SetBlipDisplay(dropzone, 6)
        -- SetBlipScale(dropzone, 1)
        SetBlipAsShortRange(dropzone, false)
        SetBlipColour(dropzone, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Drop Zone")
        EndTextCommandSetBlipName(dropzone)
        dropRadiusBlip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
        SetBlipColour(dropRadiusBlip, 3)
        SetBlipAlpha(dropRadiusBlip, 128)
    end

    PlaceLocationFlares(flares)
end)

RegisterNetEvent('tis-skydiving:client:EndSkydiving', function()
    if dropzone ~= nil then
        RemoveBlip(dropzone)
        dropzone = nil
    end
    if dropRadiusBlip ~= nil then
        RemoveBlip(dropRadiusBlip)
        dropRadiusBlip = nil
    end
    RemoveFlares()
end)

-- Radar
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