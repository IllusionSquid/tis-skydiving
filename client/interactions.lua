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

-- Add polyzones
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