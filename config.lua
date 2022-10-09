Config = {}

Config.Tracker = "skytracker"

Config.Plane = {
    spawn = {
        pos = vector3(-963.81, -2984.29, 13.95),
        heading = 60
    },
    model = "miljet"
}

Config.Transport = {
    model = "coach"
}

Config.runways = {
    {
        start = vector3(-929.84, -3183.41, 13.96),
        ending = vector3(-1607.73, -2792.37, 13.98)
    }
}

Config.Items = {
    label = "Skydiving Store",
    slots = 3,
    items = {
        [1] = {
            name = "radio",
            price = 50,
            amount = 50,
            info = {},
            type = "item",
            slot = 1,
        },
        [2] = {
            name = "parachute",
            price = 100,
            amount = 50,
            info = {},
            type = "item",
            slot = 2,
        },
        [3] = {
            name = "skytracker",
            price = 100,
            amount = 50,
            info = {},
            type = "item",
            slot = 3,
        }
    }
}