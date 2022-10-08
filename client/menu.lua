local inCreation = false
local pos = nil
local count = 6
local radius = 5
local vehPos = nil
local vehHeading = nil
local veh = nil
local flares = {}

local function LocalInput(text, number, windows)
    AddTextEntry("FMMC_MPM_NA", text)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", windows or "", "", "", "", number or 30)
    while (UpdateOnscreenKeyboard() == 0) do
    DisableAllControlActions(0)
    Wait(0)
    end

    if (GetOnscreenKeyboardResult()) then
    local result = GetOnscreenKeyboardResult()
        return result
    end
end

local function updateVehicle()
    if veh == nil then
        ReqMod(Config.Transport.model)
        veh = CreateVehicle(GetHashKey(Config.Transport.model), vehPos, vehHeading, false, true)
        SetEntityCollision(veh, false, false)
        SetVehicleOnGroundProperly(veh)
        FreezeEntityPosition(veh, true)
        SetEntityAlpha(veh, 200)
        SetVehicleNumberPlateText(veh, "SkwidFal")
        SetModelAsNoLongerNeeded(Config.Transport.model)
    else
        SetEntityCoords(veh, vehPos)
        SetEntityHeading(veh, vehHeading)
    end
end

local function removeVehicle()
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
    veh = nil
end

local menuLocation = 'topright' -- e.g. topright (default), topleft, bottomright, bottomleft

-- Main Menus
local menu1 = MenuV:CreateMenu(false, "Skydiving", menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test1')

local menu_jumps = MenuV:CreateMenu(false, "Skydiving Locations", menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test2')
local menu_creation = MenuV:CreateMenu(false, "Skydiving Creation", menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test3')

menu1:AddButton({
    icon = '📍',
    label = "Locations",
    value = menu_jumps,
    description = "Jump Locations"
})

menu1:AddButton({
    icon = '🔧',
    label = "Add Locations",
    value = menu_creation,
    description = "Jump Locations"
})

menu_creation:On("open", function ()
    RemoveFlares()
    pos = GetEntityCoords(GetPlayerPed(-1))
    flares = PlaceFlares(pos, radius, count)
    local ped = GetPlayerPed(-1)
    vehPos = GetEntityCoords(ped)
    vehHeading = GetEntityHeading(ped)
    updateVehicle()
    inCreation = true
end)

-- Handle canceled creation
menu_creation:On("close", function ()
    RemoveFlares()
    removeVehicle()
    inCreation = false
end)

local menu_creation_location = menu_creation:AddButton({
    icon = "📍",
    label = "Zone Location",
    value = "location",
    description = "Move the landing zone"
})

menu_creation_location:On("select", function (_)
    RemoveFlares()
    pos = GetEntityCoords(GetPlayerPed(-1))
    flares = PlaceFlares(pos, radius, count)
end)

local menu_creation_count = menu_creation:AddRange({
    icon = "📋",
    label = "Flare Count",
    description = "Amount of flares in the landing zone",
    value = 6,
    min = 6,
    max = 16
})

menu_creation_count:On("change", function (_, newValue, _)
    count = newValue
    RemoveFlares()
    flares = PlaceFlares(pos, radius, count)
end)

local menu_creation_radius = menu_creation:AddRange({
    icon = "📏",
    label = "Radius",
    description = "Radius of the landing zone",
    value = 5,
    min = 5,
    max = 30
})

menu_creation_radius:On("change", function (_, newValue, _)
    radius = newValue
    RemoveFlares()
    flares = PlaceFlares(pos, radius, count)
end)

local menu_creation_veh = menu_creation:AddButton({
    icon = "🚘",
    label = "Vehicle Location",
    value = "location",
    description = "Move the transport vehicle"
})

menu_creation_veh:On("select", function (_)
    local ped = GetPlayerPed(-1)
    vehPos = GetEntityCoords(ped)
    vehHeading = GetEntityHeading(ped)
    updateVehicle()
end)

local menu_creation_finish = menu_creation:AddButton({
    icon = "⚡️",
    label = "Finish",
    value = "finish",
    description = "Move the landing zone"
})

menu_creation_finish:On("select", function (_)
    local label = LocalInput("Landing Zone Name", 255)
    TriggerServerEvent("tis-skydiving:server:AddLandingZone", label, vehPos, vehHeading, pos, flares)
    count = 6
    radius = 5
    MenuV:CloseMenu(menu_creation)
end)

RegisterNetEvent('tis-skydiving:client:OpenMenu', function(locations)
    for k, location in pairs(locations) do
        menu_jumps:AddButton({
            icon = "",
            label = location.label,
            value = location.label,
            select = function (_)
                PlaceLocationFlares(location.flares)
                PlaceLocationVehicle(location.veh_pos, location.veh_heading)
            end
        })
    end
    MenuV:OpenMenu(menu1)
end)