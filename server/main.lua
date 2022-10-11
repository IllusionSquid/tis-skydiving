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

local inSkydiveSession = false
local veh = nil

-- Skydiving Session events
RegisterServerEvent("tis-skydiving:server:StartSkydiving")
AddEventHandler("tis-skydiving:server:StartSkydiving", function (vehPos, vehHeading, pos, flares, radius)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if inSkydiveSession then
        TriggerClientEvent('QBCore:Notify', src, "There is currently already a skydiving session", "error")
        return
    end

	if Player.PlayerData.job.name == "skydive" then
        TriggerClientEvent("tis-skydiving:client:StartSkydiving", -1, pos, flares, radius)
        veh = CreateVehicle(GetHashKey(Config.Transport.model), vehPos.x, vehPos.y, vehPos.z, vehHeading, true, true)
        inSkydiveSession = true
        Citizen.Wait(3000)
        TriggerClientEvent("vehiclekeys:client:SetOwner", src, QBCore.Shared.Trim(GetVehicleNumberPlateText(veh)))
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skydiving instructor", "error")
	end
end)

RegisterServerEvent("tis-skydiving:server:EndSkydiving")
AddEventHandler("tis-skydiving:server:EndSkydiving", function ()
    TriggerClientEvent("tis-skydiving:client:EndSkydiving", -1)
    DeleteEntity(veh)
    inSkydiveSession = false
end)

-- Landing zone management
RegisterServerEvent("tis-skydiving:server:AddLandingZone")
AddEventHandler("tis-skydiving:server:AddLandingZone", function (label, vehPos, vehHeading, pos, flares, radius)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "skydive" then
        MySQL.Async.insert('INSERT INTO skydive_location (label, veh_pos, veh_heading, land_pos, flares, radius) VALUES (:label, :veh_pos, :veh_heading, :land_pos, :flares, :radius)', {
            label = label,
            veh_pos = json.encode(vehPos),
            veh_heading = vehHeading,
            land_pos = json.encode(pos),
            flares = json.encode(flares),
            radius = radius
        })
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skydiving instructor", "error")
        -- Hacker?
	end
end)

RegisterServerEvent("tis-skydiving:server:RemoveLandingZone")
AddEventHandler("tis-skydiving:server:RemoveLandingZone", function (id)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "skydive" then
        MySQL.Async.execute('DELETE FROM skydive_location WHERE id=:id;', {
            id = id
        })
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skydiving instructor", "error")
        -- Hacker?
	end
end)

-- Commands
QBCore.Commands.Add("landplane", "Tell Autopilot to land and skydive yourself ;)", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "skydive" then
		TriggerClientEvent("tis-skydiving:client:LandPlane", src)
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skydiving instructor", "error")
	end
end)

QBCore.Commands.Add("skydive", "Opens skydiving menu", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "skydive" then
        MySQL.query('SELECT * FROM skydive_location', {}, function(result)
            if result ~= nil then
                local locations = {}
                for _, row in pairs(result) do
                    table.insert(locations, {
                        id = row.id,
                        label = row.label,
                        veh_pos = json.decode(row.veh_pos),
                        veh_heading = row.veh_pos,
                        land_pos = json.decode(row.land_pos),
                        flares = json.decode(row.flares),
                        radius = row.radius*1.0 -- Make sure it's a float
                    })
                end
                TriggerClientEvent("tis-skydiving:client:OpenMenu", src, locations, inSkydiveSession)
            end
        end)
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skydiving instructor", "error")
	end
end)