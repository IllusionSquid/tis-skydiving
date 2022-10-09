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
local menu_jumps_options = MenuV:CreateMenu(false, "Skydiving Locations", menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test3')
local menu_jumps_options_delete = MenuV:CreateMenu(false, "REMOVE LOCATION?", menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test4')
local menu_creation = MenuV:CreateMenu(false, "Skydiving Creation", menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'test5')

menu1:On("close", function ()
    menu1.ClearItems(menu1, true)
    menu1.ClearItems(menu_jumps, true)
end)

local start_button = menu_jumps_options:AddButton({
    icon = "📍",
    label = "Start Jump",
    value = "location",
    description = "Starts the skydiving session",
    select = function (btn)
        print(btn.location)
        TriggerServerEvent("tis-skydiving:server:StartSkydiving", btn.location.veh_pos, btn.location.veh_heading, btn.location.land_pos, btn.location.flares, btn.location.radius)
        MenuV:CloseMenu(menu_jumps_options)
        MenuV:CloseMenu(menu_jumps)
        MenuV:CloseMenu(menu1)
    end
})

local delete_button = menu_jumps_options:AddButton({
    icon = "🗑️",
    label = "Delete Jump",
    value = menu_jumps_options_delete,
    description = "Deletes the jump",
})

menu_jumps_options_delete:AddButton({
    icon = "🛑",
    label = "No, take me back",
    value = "jump",
    description = "Deleteds the jump",
    select = function (_)
        MenuV:CloseMenu(menu_jumps_options_delete)
        MenuV:CloseMenu(menu_jumps_options)
    end
})

local confirm_button = menu_jumps_options_delete:AddButton({
    icon = "🗑️",
    label = "Yes, I'm aware this is permanently deleted",
    value = "jump",
    description = "Deleteds the jump",
    select = function (btn)
        TriggerServerEvent("tis-skydiving:server:RemoveLandingZone", btn.location.id)
        MenuV:CloseMenu(menu_jumps_options_delete)
        MenuV:CloseMenu(menu_jumps_options)
        MenuV:CloseMenu(menu_jumps)
        MenuV:CloseMenu(menu1)
    end
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
    TriggerServerEvent("tis-skydiving:server:AddLandingZone", label, vehPos, vehHeading, pos, flares, radius)
    count = 6
    radius = 5
    MenuV:CloseMenu(menu_creation)
    MenuV:CloseMenu(menu1)
end)

RegisterNetEvent('tis-skydiving:client:OpenMenu', function(locations, inSkydiveSession)
    print(inSkydiveSession)
    if inSkydiveSession then
        menu1:AddButton({
            icon = '🛑',
            label = "End Session",
            value = "endsession",
            description = "Ends skydiving Session",
            select = function (_)
                TriggerServerEvent("tis-skydiving:server:EndSkydiving")
                MenuV:CloseMenu(menu1)
            end
        })

    else
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
        for k, location in pairs(locations) do

            menu_jumps:AddButton({
                icon = "",
                label = location.label,
                value = menu_jumps_options,
                select = function (_)
                    start_button.location = location
                    confirm_button.location = location
                end
            })
        end
    end
    MenuV:OpenMenu(menu1)
end)