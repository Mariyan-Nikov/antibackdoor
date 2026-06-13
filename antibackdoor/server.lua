-- ==========================================
-- FiveM Anti Backdoor Scanner (Fixed)
-- ==========================================

-- 🔒 Trusted resources (Exact match)
local WHITELISTED_RESOURCES = {
    ["chat"] = true, 
    ["spawnmanager"] = true, 
    ["sessionmanager"] = true,
    ["hardcap"] = true, 
    ["baseevents"] = true, 
    ["ox_inventory"] = true,
    ["Ricky-VinewoodSign"] = true, 
    ["antibackdoor"] = true, 
    ["okokChatV2"] = true,
    ["qb-bankrobbery"] = true, 
    ["qb-vehicleshop"] = true, 
    ["PolyZone"] = true,
    ["tuff-loading"] = true, 
    ["qb-truckrobbery"] = true, 
    ["qb-jewelery"] = true,
    ["qb-scrapyard"] = true, 
    ["qb-streetraces"] = true, 
    ["qb-crypto"] = true,
    ["qb-weed"] = true, 
    ["qb-diving"] = true, 
    ["qb-doorlock"] = true,
    ["qb-houserobbery"] = true, 
    ["qb-houses"] = true, 
    ["qb-lapraces"] = true,
    ["qb-phone"] = true, 
    ["qb-scoreboard"] = true, 
    ["qb-storerobbery"] = true,
    ["qb-vehiclesales"] = true, 
    ["qb-weathersync"] = true, 
    ["izzy-multicharacterv4"] = true,
    
    -- Framework & Base System False-Positive Exclusions
    ["qb-core"] = true,
    ["qb-adminmenu"] = true,
    ["qb-ambulancejob"] = true,
    ["qb-radialmenu"] = true,
    ["qb-inventory"] = true,
    ["qb-drugs"] = true,
    ["qb-weapons"] = true,
    ["qb-prison"] = true,
    ["qb-mechanicjob"] = true,
    ["qb-policejob"] = true,
    ["qb-shops"] = true,
    ["interact-sound"] = true,
    ["mapmanager"] = true,
    ["playernames"] = true,
    ["monitor"] = true -- txAdmin
}

-- 🚨 Refined & Expanded Backdoor Signatures
local SUSPICIOUS_PATTERNS = {
    {pattern = "loadstring%s*Matching", label = "Dynamic Code Execution (loadstring)"},
    {pattern = "load%s*%(%s*.*%)", label = "Dynamic Code Execution (load)"},
    {pattern = "assert%s*%(%s*load", label = "Obfuscated Execution (assert/load)"},
    {pattern = "PerformHttpRequest%s*Matching", label = "External Web Request"},
    {pattern = "raw%.githubusercontent%.com", label = "Remote Script Fetching (GitHub)"},
    {pattern = "pastebin%.com", label = "Remote Script Fetching (Pastebin)"},
    {pattern = "discord%.com/api/webhooks", label = "Data Logging/Exfiltration (Webhook)"},
    {pattern = "TriggerClientEvent%s*%(%s*['\"]%s*.*%s*['\"]%s*,%s*%-1", label = "Global Client Trigger (-1 Spam)"},
    {pattern = "RconAuthenticate", label = "RCON Credential Exploit Attempt"},
    {pattern = "\\[0-9][0-9]?[0-9]?", label = "Heavy Byte/Hex Obfuscation"},
}

-- Helper to parse fxmanifest/resource.lua files safely
local function getServerScripts(resource)
    local files = {}
    local manifest = LoadResourceFile(resource, "fxmanifest.lua") or LoadResourceFile(resource, "__resource.lua")
    if not manifest then return files end

    -- Extract anything defined as a server_script or server_scripts
    for block in manifest:gmatch("server_script[s]?%s*%b{}") do
        for file in block:gmatch("['\"]([^'\"]+%.lua)['\"]") do
            table.insert(files, file)
        end
    end
    
    -- Single line definitions: server_script 'file.lua'
    for file in manifest:gmatch("server_script%s+['\"]([^'\"]+%.lua)['\"]") do
        table.insert(files, file)
    end

    return files
end

local function scanFile(resource, file)
    local content = LoadResourceFile(resource, file)
    if not content then return end

    local lineNumber = 0
    -- Split content into lines safely across platforms (\r\n vs \n)
    for line in content:gmatch("[^\r\n]+") do
        lineNumber = lineNumber + 1
        
        for _, data in ipairs(SUSPICIOUS_PATTERNS) do
            -- Case-insensitive check without breaking the Lua magic pattern characters
            if string.find(line:lower(), data.pattern:lower(), 1, false) then
                print("^1[ANTI-BACKDOOR]^7 Suspicious code detected!")
                print("^3Resource:^7 " .. resource)
                print("^3File:^7 " .. file .. " (Line " .. lineNumber .. ")")
                print("^3Threat Type:^7 " .. data.label)
                print("^3Code:^7 " .. line:match("^%s*(.-)%s*$")) -- Trim whitespace for clean logs
                print("^1---------------------------------------^7")
            end
        end
    end
end

local function scanResource(resource)
    if WHITELISTED_RESOURCES[resource] then return end
    if GetResourceState(resource) == "missing" then return end

    -- Find ALL explicitly declared server files via the manifest
    local serverScripts = getServerScripts(resource)
    
    -- Always force check common root file names just in case manifest is missed
    table.insert(serverScripts, "server.lua")
    table.insert(serverScripts, "server/server.lua")

    -- Track unique files to avoid scanning the same file twice
    local scanned = {}
    for _, file in ipairs(serverScripts) do
        if not scanned[file] then
            scanned[file] = true
            scanFile(resource, file)
        end
    end
end

CreateThread(function()
    Wait(5000)
    print("^2[ANTI-BACKDOOR]^7 Starting comprehensive resource scan...")

    local totalResources = GetNumResources()
    for i = 0, totalResources - 1 do
        local resource = GetResourceByFindIndex(i)
        if resource then
            scanResource(resource)
        end
    end

    print("^2[ANTI-BACKDOOR]^7 Scan completed safely across all folders.")
end)