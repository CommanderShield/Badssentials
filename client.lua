--------------------
--- Badssentials ---
--------------------
function Draw2DText(x, y, text, scale, center)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
tickDegree = 0;
local nearest = nil;
local postals = Postals;
function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
currentTime = "0:00";
RegisterNetEvent('Badssentials:SetTime')
AddEventHandler('Badssentials:SetTime', function(time)
	currentTime = time;
end)
currentDay = 1;
RegisterNetEvent('Badssentials:SetDay')
AddEventHandler('Badssentials:SetDay', function(day)
	currentDay = day;
end)
currentMonth = 1;
RegisterNetEvent('Badssentials:SetMonth')
AddEventHandler('Badssentials:SetMonth', function(month)
	currentMonth = month;
end)
currentYear = "2021";
RegisterNetEvent('Badssentials:SetYear')
AddEventHandler('Badssentials:SetYear', function(year)
	currentYear = year;
end)
peacetime = false;
function ShowInfo(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(true, false)
end
currentAOP = "Sandy Shores"
RegisterNetEvent('Badssentials:SetAOP')
AddEventHandler('Badssentials:SetAOP', function(aop)
	currentAOP = aop;
end)
RegisterNetEvent('Badssentials:SetPT')
AddEventHandler('Badssentials:SetPT', function(pt)
	peacetime = pt;
end)
displaysHidden = false;
RegisterCommand("toggle-hud", function()
	displaysHidden = not displaysHidden;
	TriggerEvent('Badger-Priorities:HideDisplay')
	if displaysHidden then 
		DisplayRadar(false);
	else 
		DisplayRadar(true);
	end
end)
RegisterCommand("postal", function(source, args, raw)
	if #args > 0 then 
		local postalCoords = getPostalCoords(args[1]);
		if postalCoords ~= nil then 
			-- It is valid 
			SetNewWaypoint(postalCoords.x, postalCoords.y);
			TriggerEvent('chatMessage', Config.Prefix .. "Your waypoint has been set to postal ^5" .. args[1]);
		else 
			TriggerEvent('chatMessage', Config.Prefix .. "^1ERROR: That is not a valid postal code...");
		end
	else 
		SetWaypointOff();
		TriggerEvent('chatMessage', Config.Prefix .. "Your waypoint has been reset!");
	end
end)
function getPostalCoords(postal)
	for _, v in pairs(postals) do 
		if v.code == postal then 
			return {x=v.x, y=v.y};
		end
	end
	return nil;
end

local cooldown = 0
local ispriority = false
local ishold = false

RegisterCommand("resetpcd", function()
	if IsPlayerAceAllowed(src, "Badssentials.PeaceTime") then
	    TriggerServerEvent("cancelcooldown")
	end
end, false)

RegisterNetEvent('UpdateCooldown')
AddEventHandler('UpdateCooldown', function(newCooldown)
    cooldown = newCooldown
end)

RegisterNetEvent('UpdatePriority')
AddEventHandler('UpdatePriority', function(newispriority)
    ispriority = newispriority
end)

RegisterNetEvent('UpdateHold')
AddEventHandler('UpdateHold', function(newishold)
    ishold = newishold
end)

Citizen.CreateThread(function()
	while true do 
		Wait(0);
		local pos = GetEntityCoords(PlayerPedId())
		local playerX, playerY = table.unpack(pos)
		local ndm = -1 -- nearest distance magnitude
		local ni = -1 -- nearest index
		for i, p in ipairs(postals) do
			local dm = (playerX - p.x) ^ 2 + (playerY - p.y) ^ 2 -- distance magnitude
			if ndm == -1 or dm < ndm then
				ni = i
				ndm = dm
			end
		end

		--setting the nearest
		if ni ~= -1 then
			local nd = math.sqrt(ndm) -- nearest distance
			nearest = {i = ni, d = nd}
		end
		local postal = postals[nearest.i].code;
		local postalDist = round(nearest.d, 2);
		local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
		local zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z));
		local degree = degreesToIntercardinalDirection(GetCardinalDirection());
		local streetName = GetStreetNameFromHashKey(var1);
		for _, v in pairs(Config.Displays) do 
			local x = v.x;
			local y = v.y;
			local enabled = v.enabled;
			if enabled and not displaysHidden then 
				local disp = v.display;
				if (disp:find("{NEAREST_POSTAL}") or disp:find("{NEAREST_POSTAL_DISTANCE}")) then 
					disp = disp:gsub("{NEAREST_POSTAL}", postal);
					disp = disp:gsub("{NEAREST_POSTAL_DISTANCE}", postalDist)
				end
				if (disp:find("{STREET_NAME}")) then 
					disp = disp:gsub("{STREET_NAME}", streetName);
				end 
				if (disp:find("{CITY}")) then 
					disp = disp:gsub("{CITY}", zone);
				end
				if (disp:find("{COMPASS}")) then 
					disp = disp:gsub("{COMPASS}", degree);
				end
				disp = disp:gsub("{EST_TIME}", currentTime);
				disp = disp:gsub("{US_DAY}", currentDay);
				disp = disp:gsub("{US_MONTH}", currentMonth);
				disp = disp:gsub("{US_YEAR}", currentYear);
				disp = disp:gsub("{CURRENT_AOP}", currentAOP);
				if (disp:find("{PRIORITY_STATUS}")) then 
					if ishold == true then
						disp = disp:gsub("{PRIORITY_STATUS}", "~b~Priorities Are On Hold")
					elseif cooldown == 0 then 
						disp = disp:gsub("{PRIORITY_STATUS}", "~g~Available")
					elseif ispriority == true then 
						disp = disp:gsub("{PRIORITY_STATUS}", "~g~Priority In Progress")
					elseif ispriority == false then 
						disp = disp:gsub("{PRIORITY_STATUS}", "~r~".. cooldown .." ~w~Mins")
					end
				end
				local scale = v.textScale;
				Draw2DText(x, y, disp, scale, false);
			end
			tickDegree = tickDegree + 9.0;
		end
	end
end)

function GetCardinalDirection()
	local camRot = Citizen.InvokeNative( 0x837765A25378F0BB, 0, Citizen.ResultAsVector() )
    local playerHeadingDegrees = 360.0 - ((camRot.z + 360.0) % 360.0)
    local tickDegree = playerHeadingDegrees - 180 / 2
    local tickDegreeRemainder = 9.0 - (tickDegree % 9.0)
   
    tickDegree = tickDegree + tickDegreeRemainder
    return tickDegree;
end
function degreesToIntercardinalDirection( dgr )
	dgr = dgr % 360.0
	
	if (dgr >= 0.0 and dgr < 22.5) or dgr >= 337.5 then
		return " E "
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "SE"
	elseif dgr >= 67.5 and dgr < 112.5 then
		return " S "
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "SW"
	elseif dgr >= 157.5 and dgr < 202.5 then
		return " W "
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "NW"
	elseif dgr >= 247.5 and dgr < 292.5 then
		return " N "
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "NE"
	end
end
