RegisterServerEvent("tis-skydiving:server:CreateLandingZone")
AddEventHandler("tis-skydiving:server:CreateLandingZone", function (coords)
    TriggerClientEvent("tis-skydiving:client:PlaceFlares", -1, coords)
end)

RegisterServerEvent("tis-skydiving:server:DeleteLandingZone")
AddEventHandler("tis-skydiving:server:DeleteLandingZone", function ()
    TriggerClientEvent("tis-skydiving:client:RemoveFlares", -1)
end)