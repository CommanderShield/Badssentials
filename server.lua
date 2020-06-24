--------------------
--- Badssentials ---
--------------------
function sendMsg(src, msg)
  TriggerClientEvent('chatMessage', src, Config.Prefix .. msg);
end

Citizen.CreateThread(function()
  while true do 
    Wait(1000);
    TriggerClientEvent('Badssentials:SetAOP', -1, currentAOP);
    TriggerClientEvent('Badssentials:SetPT', -1, peacetime);
    local time = format_time(os.time(), "%H:%M", "+01:00", "EST");
    local date = format_time(os.time(), "%m %d %Y", "+01:00", "EST");
    local timeHour = split(time, ":")[1]
    local dateData = split(date, " ");
    TriggerClientEvent('Badssentials:SetMonth', -1, dateData[1])
    TriggerClientEvent('Badssentials:SetDay', -1, dateData[2])
    TriggerClientEvent('Badssentials:SetYear', -1, dateData[3])
    if tonumber(timeHour) > 12 then 
      local timeStr = tostring(tonumber(timeHour) - 12) .. ":" .. split(time, ":")[2]
      TriggerClientEvent('Badssentials:SetTime', -1, timeStr);
    end
    if timeHour == "00" then 
      local timeStr = "12" .. ":" .. split(time, ":")[2]
      TriggerClientEvent('Badssentials:SetTime', -1, timeStr);
    end 
    if timeHour ~= "00" and tonumber(timeHour) <= 12 then 
      TriggerClientEvent('Badssentials:SetTime', -1, time);
    end
  end
end)
peacetime = false;
currentAOP = "Sandy Shores"; -- By default 
RegisterCommand("aop", function(source, args, rawCommand)
  local src = source;
  if IsPlayerAceAllowed(src, "Badssentials.AOP") then 
    -- Allowed to use /aop <aop>
    if #args > 0 then 
      currentAOP = table.concat(args, " ");
      sendMsg(src, "You have set the AOP to: " .. currentAOP);
      TriggerClientEvent('Badssentials:SetAOP', -1, currentAOP);
    else 
      -- Not enough arguments
      sendMsg(src, "^1ERROR: Proper usage: /aop <zone>");
    end
  end
end)

RegisterCommand("cooldown", function()
    TriggerEvent("cooldownt")
end, false)

RegisterCommand("priority", function()
	TriggerEvent('isPriority')
end, false)

RegisterCommand("onhold", function()
    if IsPlayerAceAllowed(src, "Badssentials.Priority") then
	    TriggerEvent('isOnHold')
    end
end, false)

RegisterNetEvent('isPriority')
AddEventHandler('isPriority', function()
	ispriority = true
	Citizen.Wait(1)
	TriggerClientEvent('UpdatePriority', -1, ispriority)
	TriggerClientEvent('chatMessage', -1, "WARNING", {255, 0, 0}, "^1A priority call is in progress. Please do not interfere, otherwise you will be ^1kicked. ^7All calls are on ^3hold ^7until this one concludes.")
end)

RegisterNetEvent('isOnHold')
AddEventHandler('isOnHold', function()
	ishold = true
	Citizen.Wait(1)
	TriggerClientEvent('UpdateHold', -1, ishold)
end)

RegisterNetEvent("cooldownt")
AddEventHandler("cooldownt", function()
	if ispriority == true then
		ispriority = false
		TriggerClientEvent('UpdatePriority', -1, ispriority)
	end
	Citizen.Wait(1)
	if ishold == true then
		ishold = false
		TriggerClientEvent('UpdateHold', -1, ishold)
	end
	Citizen.Wait(1)
	if cooldown == 0 then
		cooldown = 0
		cooldown = cooldown + 21
		TriggerClientEvent('chatMessage', -1, "WARNING", {255, 0, 0}, "^1A priority call was just conducted. ^3All civilians must wait 20 minutes before conducting another one. ^7Failure to abide by this rule will lead to you being ^1kicked.")
		while cooldown > 0 do
			cooldown = cooldown - 1
			TriggerClientEvent('UpdateCooldown', -1, cooldown)
			Citizen.Wait(60000)
		end
	elseif cooldown ~= 0 then
		CancelEvent()
	end
end)

RegisterNetEvent("cancelcooldown")
AddEventHandler("cancelcooldown", function()
	Citizen.Wait(1)
	while cooldown > 0 do
		cooldown = cooldown - 1
		TriggerClientEvent('UpdateCooldown', -1, cooldown)
		Citizen.Wait(100)
	end	
end)

function split(source, sep)
    local result, i = {}, 1
    while true do
        local a, b = source:find(sep)
        if not a then break end
        local candidat = source:sub(1, a - 1)
        if candidat ~= "" then 
            result[i] = candidat
        end i=i+1
        source = source:sub(b + 1)
    end
    if source ~= "" then 
        result[i] = source
    end
    return result
end
function format_time(timestamp, format, tzoffset, tzname)
   if tzoffset == "local" then  -- calculate local time zone (for the server)
      local now = os.time()
      local local_t = os.date("*t", now)
      local utc_t = os.date("!*t", now)
      local delta = (local_t.hour - utc_t.hour)*60 + (local_t.min - utc_t.min)
      local h, m = math.modf( delta / 60)
      tzoffset = string.format("%+.4d", 100 * h + 60 * m)
   end
   tzoffset = tzoffset or "GMT"
   format = format:gsub("%%z", tzname or tzoffset)
   if tzoffset == "GMT" then
      tzoffset = "+0000"
   end
   tzoffset = tzoffset:gsub(":", "")

   local sign = 1
   if tzoffset:sub(1,1) == "-" then
      sign = -1
      tzoffset = tzoffset:sub(2)
   elseif tzoffset:sub(1,1) == "+" then
      tzoffset = tzoffset:sub(2)
   end
   tzoffset = sign * (tonumber(tzoffset:sub(1,2))*60 +
tonumber(tzoffset:sub(3,4)))*60
   return os.date(format, timestamp + tzoffset)
end
