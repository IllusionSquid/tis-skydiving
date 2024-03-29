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

local dropzone = nil
local dropRadiusBlip = nil
local particles = {}

function ReqPtfxAsset(ptfxAsset)
    if not HasNamedPtfxAssetLoaded(ptfxAsset) then
        RequestNamedPtfxAsset(ptfxAsset)
        while not HasNamedPtfxAssetLoaded(ptfxAsset) do
            Citizen.Wait(10)
        end
    end
end

function ReqMod(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
end

function RemoveFlares()
    for k, v in pairs(particles) do
        StopParticleFxLooped(v)
        particles[k] = nil
    end
end

function CalculateFlareOffset(radius, count, flareIndex)
    local degreePerFlare = 360 / count
    local rad = (degreePerFlare * flareIndex) * math.pi / 180
    return vector3(radius * math.sin(rad), radius * math.cos(rad), 0)
end

function PlaceFlares(coords, radius, count)
    local flares = {}
    local PtfxAsset = "core"
    ReqPtfxAsset(PtfxAsset)

    -- Circle flares
    for i = 0, count - 1, 1 do
        local adjusted = coords + CalculateFlareOffset(radius, count, i)
        local foundGround, groundZ = GetGroundZFor_3dCoord(adjusted.x, adjusted.y, adjusted.z)
        if not foundGround then
            groundZ = adjusted.z
        end

        UseParticleFxAssetNextCall(PtfxAsset) -- Prepare the Particle FX for the next upcomming Particle FX call
        local part = StartParticleFxLoopedAtCoord("exp_grd_flare", adjusted.x, adjusted.y, groundZ, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        table.insert(particles, part)
        table.insert(flares, {x = adjusted.x, y = adjusted.y, z = groundZ})
    end

    -- Center flare
    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z)
    if not foundGround then
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
    ReqPtfxAsset(PtfxAsset)

    for _, flare in pairs(flares) do
        UseParticleFxAssetNextCall(PtfxAsset) -- Prepare the Particle FX for the next upcomming Particle FX call
        local part = StartParticleFxLoopedAtCoord("exp_grd_flare", flare.x, flare.y, flare.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        table.insert(particles, part)
    end

    RemoveNamedPtfxAsset(PtfxAsset) -- Clean up
end

local function createDropzoneFlagBlip(pos)
    dropzone = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite (dropzone, 164)
    SetBlipDisplay(dropzone, 6)
    SetBlipAsShortRange(dropzone, false)
    SetBlipColour(dropzone, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Drop Zone")
    EndTextCommandSetBlipName(dropzone)
end

local function createDropzoneRadiusBlip(pos, radius)
    dropRadiusBlip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
    SetBlipColour(dropRadiusBlip, 3)
    SetBlipAlpha(dropRadiusBlip, 128)
end

local function createDropzoneBlips(pos, radius)
    createDropzoneFlagBlip(pos)
    createDropzoneRadiusBlip(pos, radius)
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
        createDropzoneBlips(pos, radius)
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
