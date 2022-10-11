# Documentation

## tis-skydiving
A script that adds a skydiving instructor job. This adds a couple quality of life features for skydiving:
- A shop close to the airport accessible by the instructor
    - Parachute
    - Radio
    - Skydiving Tracker
        - This item adds people to the a map radar
- A way for the instructor to spawn a plane
- A skydiving session menu
    - Add landing zones
    - Remove landing zones
- A command for the instructor to put the plane on autopilot so they can skydive themselves

### Skydiving sessions
The instructor can start a session using the menu. When a session is started, it will put a marker on the map of everyone that has the skydiving tracker in their inventory. On that spot there will be a cirle of flares indicating the landing zone. As well as a vehicle to transport people back.

The landing zones need to be added by the skydiving instructor manually using the menu. These zones are saved in a database table.

## Plans
- Point system for landing in the zone?

## Dependencies
- **[qb-core](https://github.com/qbcore-framework/qb-core)**
- **[qb-target](https://github.com/BerkieBb/qb-target)**
- **[MenuV](https://github.com/ThymonA/menuv)**
- **[oxmysql](https://github.com/overextended/oxmysql)**
- **[LegacyFuel](https://github.com/InZidiuZ/LegacyFuel)** (Or alternatively you can use **[ps-fuel](https://github.com/Project-Sloth/ps-fuel)** if you follow [step 2](https://github.com/Project-Sloth/ps-fuel#step-2) in their `README.md`) 

## Installation
1. Download .zip file
2. Open the .zip file
3. Drop the folder `tis-skydiving-master` inside recourse folder
4. Rename `tis-skydiving-master` to `tis-skydiving`
5. Add the line `ensure tis-skydiving` in your `server.cfg`
6. Add this to your `items.lua:QBShared.Items`:
```lua
['skytracker'] 			 	 	 = {['name'] = 'skytracker', 			  		['label'] = 'Skydiving Tracker', 		['weight'] = 500, 		['type'] = 'item', 		['image'] = 'fitbit.png', 				['unique'] = true, 		['useable'] = false, 	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Gives skydiving team radar'},
```
7. Add this to your `jobs.lua:QBShared.Jobs`:
```lua
['skydive'] = {
    label = 'Skydiving',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Instructor',
            payment = 500
        },
    },
},
```
8. Don't forget to run the `tis-skydiving.sql` on your database to add the required table(s).
9. Have fun!

# License
```
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
```