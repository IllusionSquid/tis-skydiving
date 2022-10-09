local QBCore = exports['qb-core']:GetCoreObject()

local inSkydiveSession = false
local veh = nil

-- RegisterServerEvent("tis-skydiving:server:CreateLandingZone")
-- AddEventHandler("tis-skydiving:server:CreateLandingZone", function (coords)
--     TriggerClientEvent("tis-skydiving:client:PlaceFlares", -1, coords, 15, 6)
-- end)

RegisterServerEvent("tis-skydiving:server:DeleteLandingZone")
AddEventHandler("tis-skydiving:server:DeleteLandingZone", function ()
    TriggerClientEvent("tis-skydiving:client:RemoveFlares", -1)
end)

RegisterServerEvent("tis-skydiving:server:StartSkydiving")
AddEventHandler("tis-skydiving:server:StartSkydiving", function (vehPos, vehHeading, pos, flares)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if inSkydiveSession then
        TriggerClientEvent('QBCore:Notify', src, "There is currently already a skydiving session", "error")
        return
    end

	if Player.PlayerData.job.name == "skydive" then
        TriggerClientEvent("tis-skydiving:client:StartSkydiving", -1, pos, flares)
        veh = CreateVehicle(GetHashKey(Config.Transport.model), vehPos.x, vehPos.y, vehPos.z, vehHeading, true, true)
        inSkydiveSession = true
        Citizen.Wait(3000)
        TriggerClientEvent("vehiclekeys:client:SetOwner", src, QBCore.Shared.Trim(GetVehicleNumberPlateText(veh)))
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skyding instructor", "error")
	end
end)

RegisterServerEvent("tis-skydiving:server:EndSkydiving")
AddEventHandler("tis-skydiving:server:EndSkydiving", function ()
    TriggerClientEvent("tis-skydiving:client:EndSkydiving", -1)
    DeleteEntity(veh)
    inSkydiveSession = false
end)

RegisterServerEvent("tis-skydiving:server:AddLandingZone")
AddEventHandler("tis-skydiving:server:AddLandingZone", function (label, vehPos, vehHeading, pos, flares)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "skydive" then
        MySQL.Async.insert('INSERT INTO skydive_location (label, veh_pos, veh_heading, land_pos, flares) VALUES (:label, :veh_pos, :veh_heading, :land_pos, :flares)', {
            label = label,
            veh_pos = json.encode(vehPos),
            veh_heading = vehHeading,
            land_pos = json.encode(pos),
            flares = json.encode(flares)
        })
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skyding instructor", "error")
        -- Hacker?
	end
end)

-- RegisterServerEvent("inventory:server:SaveInventory")
-- AddEventHandler("inventory:server:SaveInventory", function ()
--     TriggerClientEvent("tis-skydiving:client:SetInTeam", source)
--     UpdateBlips();
-- end)

QBCore.Commands.Add("landplane", "Tell Autopilot to land and skydive yourself ;)", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "skydive" then
		TriggerClientEvent("tis-skydiving:client:LandPlane", src)
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skyding instructor", "error")
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
                        label = row.label,
                        veh_pos = json.decode(row.veh_pos),
                        veh_heading = row.veh_pos,
                        land_pos = json.decode(row.land_pos),
                        flares = json.decode(row.flares)
                    })
                end
                TriggerClientEvent("tis-skydiving:client:OpenMenu", src, locations, inSkydiveSession)
            end
        end)
	else
		TriggerClientEvent('QBCore:Notify', src, "You are not a skyding instructor", "error")
	end
end)

-- Radar for the skydiving team
local function UpdateBlips()
    local teamPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        -- print(v.Functions.GetItemByName(Config.Tracker) ~= nil)
        if v.Functions.GetItemByName(Config.Tracker) ~= nil then
            local coords = GetEntityCoords(GetPlayerPed(v.PlayerData.source))
            local heading = GetEntityHeading(GetPlayerPed(v.PlayerData.source))
            teamPlayers[#teamPlayers+1] = {
                source = v.PlayerData.source,
                label = v.PlayerData.charinfo.lastname,
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