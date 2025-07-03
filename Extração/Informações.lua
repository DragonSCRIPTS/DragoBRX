local ExtractionModule = {}
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ==================== CONFIGURAÇÕES ====================

local Config = {
    -- Performance
    MAX_THREADS = 12,
    BATCH_SIZE = 50,
    YIELD_INTERVAL = 0.05,
    TIMEOUT_SECONDS = 30,
    
    -- Segurança
    MAX_RECURSION_DEPTH = 10,
    SAFE_MODE = true,
    
    -- Exportação
    EXPORT_FORMAT = "JSON", -- JSON, CSV, XML
    MAX_EXPORT_SIZE = 1024 * 1024 * 5, -- 5MB
    
    -- Monitoramento
    WATCH_INTERVAL = 5,
    ALERT_THRESHOLD = 0.8,
}

-- ==================== PADRÕES E FILTROS ====================

local DefaultKeywords = {
    -- Pets
    "Pet", "Pets", "SpawnPet", "EquipPet", "PetHandler", "PetController", "PetInventory",
    "PetData", "PetStats", "PetEquip", "PetShop", "PetEgg", "Hatch",
    
    -- Harvest/Coleta
    "Harvest", "CollectController", "FruitNuker", "SummerHarvestHandler",
    "setupFruitListeners", "giveallfruits", "clearfruit", "localsummerharvest",
    "HoldToCollectExperiment", "SummerHarvestNPCDialogue",
    
    -- Sistema de pontos/recompensas
    "PointSystem", "EventHandler", "RewardManager", "ScoreController", 
    "CollectSystem", "Currency", "Money", "Coins", "Gems", "Cash",
    
    -- Exploits comuns
    "Exploit", "Hack", "Cheat", "Bypass", "Infinite", "Auto", "Bot",
    "Speed", "Fly", "Noclip", "Godmode", "ESP", "Aimbot",
    
    -- Segurança
    "AntiCheat", "Security", "Verify", "Check", "Validate", "Guard",
    "Protection", "Monitor", "Detect", "Ban", "Kick"
}

local DangerousPatterns = {
    -- Execução dinâmica
    "loadstring", "require", "getfenv", "setfenv", "debug%.getupvalue",
    "debug%.setupvalue", "debug%.getregistry", "rawget", "rawset",
    
    -- Manipulação de metatables
    "getmetatable", "setmetatable", "__index", "__newindex", "__call",
    
    -- Hooks e interceptação
    "hookfunction", "hookmetamethod", "replaceclosure", "islclosure",
    
    -- Obfuscação
    "string%.char", "string%.byte", "string%.rep", "table%.concat",
    "bit32%.", "bit%.", "tonumber%(.+16%)", "fromhex", "tohex",
    
    -- Network
    "HttpService", "TeleportService", "MessagingService", "DataStoreService",
    "RemoteEvent", "RemoteFunction", "BindableEvent", "BindableFunction"
}

-- ==================== CLASSES E ESTRUTURAS ====================

local ObjectData = {}
ObjectData.__index = ObjectData

function ObjectData.new(obj)
    local self = setmetatable({}, ObjectData)
    self.name = obj.Name
    self.className = obj.ClassName
    self.path = self:_getFullPath(obj)
    self.parent = obj.Parent and obj.Parent.Name or "nil"
    self.children = {}
    self.properties = {}
    self.metadata = {}
    self.flags = {}
    self.hash = nil
    self.source = nil
    self.timestamp = tick()
    self.risk_level = 0
    return self
end

function ObjectData:_getFullPath(obj)
    local path = {}
    local current = obj
    while current and current ~= game do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    return table.concat(path, ".")
end

function ObjectData:addFlag(flag, severity)
    severity = severity or 1
    table.insert(self.flags, {flag = flag, severity = severity, timestamp = tick()})
    self.risk_level = self.risk_level + severity
end

function ObjectData:addProperty(key, value)
    self.properties[key] = {value = value, type = type(value), timestamp = tick()}
end

function ObjectData:addMetadata(key, value)
    self.metadata[key] = value
end

-- ==================== SISTEMA DE ANÁLISE ====================

local Analyzer = {}

function Analyzer:analyzeScript(script, data)
    local source = self:_extractSource(script)
    if not source then return false end
    
    data.source = source
    data.hash = self:_generateHash(source)
    
    -- Análise de padrões perigosos
    for _, pattern in pairs(DangerousPatterns) do
        if source:find(pattern) then
            data:addFlag("DANGEROUS_PATTERN: " .. pattern, 3)
        end
    end
    
    -- Análise de complexidade
    local complexity = self:_calculateComplexity(source)
    data:addMetadata("complexity", complexity)
    if complexity > 100 then
        data:addFlag("HIGH_COMPLEXITY", 2)
    end
    
    -- Análise de obfuscação
    local obfuscation_score = self:_detectObfuscation(source)
    data:addMetadata("obfuscation_score", obfuscation_score)
    if obfuscation_score > 0.7 then
        data:addFlag("OBFUSCATED", 3)
    end
    
    -- Análise de imports/requires
    local imports = self:_findImports(source)
    data:addMetadata("imports", imports)
    if #imports > 0 then
        data:addFlag("EXTERNAL_DEPENDENCIES", 1)
    end
    
    return true
end

function Analyzer:_extractSource(script)
    -- Método 1: Tentar acessar Source diretamente
    local success, source = pcall(function()
        return script.Source
    end)
    if success and source and source ~= "" then
        return source
    end
    
    -- Método 2: Decompilação (se disponível)
    if type(decompile) == "function" then
        local success, decompiled = pcall(decompile, script)
        if success and decompiled then
            return "-- [DECOMPILED]\n" .. decompiled
        end
    end
    
    -- Método 3: Análise de ModuleScript
    if script:IsA("ModuleScript") then
        local success, result = pcall(require, script)
        if success then
            return self:_analyzeModuleResult(result)
        end
    end
    
    return nil
end

function Analyzer:_analyzeModuleResult(result)
    local analysis = "-- [MODULE ANALYSIS]\n"
    local resultType = type(result)
    
    if resultType == "table" then
        local keys = {}
        for k, v in pairs(result) do
            table.insert(keys, string.format("%s: %s", tostring(k), type(v)))
        end
        analysis = analysis .. "-- Table with keys: " .. table.concat(keys, ", ")
    elseif resultType == "function" then
        analysis = analysis .. "-- Returns function"
    else
        analysis = analysis .. "-- Returns: " .. tostring(result)
    end
    
    return analysis
end

function Analyzer:_generateHash(content)
    -- Gerar hash simples (MD5-like)
    local hash = 0
    for i = 1, #content do
        hash = (hash * 31 + string.byte(content, i)) % 2147483647
    end
    return string.format("%x", hash)
end

function Analyzer:_calculateComplexity(source)
    local complexity = 0
    
    -- Contar estruturas de controle
    complexity = complexity + (select(2, source:gsub("if ", "")) * 2)
    complexity = complexity + (select(2, source:gsub("for ", "")) * 3)
    complexity = complexity + (select(2, source:gsub("while ", "")) * 3)
    complexity = complexity + (select(2, source:gsub("function ", "")) * 2)
    complexity = complexity + (select(2, source:gsub("coroutine", "")) * 2)
    
    -- Contar aninhamento
    local depth = 0
    local max_depth = 0
    for char in source:gmatch(".") do
        if char == "{" or char == "(" then
            depth = depth + 1
            max_depth = math.max(max_depth, depth)
        elseif char == "}" or char == ")" then
            depth = depth - 1
        end
    end
    
    complexity = complexity + max_depth
    return complexity
end

function Analyzer:_detectObfuscation(source)
    local score = 0
    
    -- Variáveis com nomes suspeitos
    local suspicious_vars = source:match("local%s+[_%w]*[0-9]+[_%w]*%s*=") and 0.2 or 0
    
    -- Strings hexadecimais
    local hex_strings = select(2, source:gsub("\\x%x%x", "")) / math.max(#source / 100, 1)
    
    -- Caracteres especiais em excesso
    local special_chars = select(2, source:gsub("[^%w%s]", "")) / math.max(#source / 10, 1)
    
    -- Strings concatenadas em excesso
    local concat_strings = select(2, source:gsub("%.%.", "")) / math.max(#source / 50, 1)
    
    score = math.min(suspicious_vars + hex_strings + special_chars + concat_strings, 1)
    return score
end

function Analyzer:_findImports(source)
    local imports = {}
    
    -- Encontrar requires
    for match in source:gmatch("require%s*%(%s*([^)]+)%s*%)") do
        table.insert(imports, {type = "require", target = match})
    end
    
    -- Encontrar getService
    for match in source:gmatch("GetService%s*%(%s*['\"]([^'\"]+)['\"]%s*%)") do
        table.insert(imports, {type = "service", target = match})
    end
    
    return imports
end

function Analyzer:analyzeRemoteObject(obj, data)
    data:addFlag("REMOTE_OBJECT", 1)
    
    -- Analisar conexões
    local connections = 0
    local success, _ = pcall(function()
        if obj:IsA("RemoteEvent") then
            connections = #obj.OnServerEvent:GetConnections()
        elseif obj:IsA("RemoteFunction") then
            connections = obj.OnServerInvoke and 1 or 0
        end
    end)
    
    data:addMetadata("connections", connections)
    if connections > 5 then
        data:addFlag("HIGH_CONNECTIONS", 2)
    end
    
    return true
end

function Analyzer:analyzeValueObject(obj, data)
    data:addProperty("value", obj.Value)
    data:addFlag("VALUE_OBJECT", 1)
    
    -- Monitorar mudanças
    local connection
    connection = obj.Changed:Connect(function(newValue)
        data:addMetadata("last_change", {
            old_value = data.properties.value.value,
            new_value = newValue,
            timestamp = tick()
        })
    end)
    
    -- Limpar conexão após um tempo
    spawn(function()
        wait(60)
        if connection then connection:Disconnect() end
    end)
    
    return true
end

-- ==================== SCANNER PRINCIPAL ====================

local Scanner = {}

function Scanner:new(config)
    local self = setmetatable({}, {__index = Scanner})
    self.config = config or Config
    self.services = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Workspace"),
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer"),
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"),
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("Players")
    }
    self.filters = {}
    self.results = {}
    self.performance = {}
    self.alerts = {}
    self.running = false
    return self
end

function Scanner:addFilter(filter)
    table.insert(self.filters, filter)
end

function Scanner:setKeywords(keywords)
    self.keywords = keywords or DefaultKeywords
end

function Scanner:scan(searchPattern, customFilters)
    self.running = true
    self.results = {}
    self.performance = {start_time = tick(), objects_scanned = 0}
    
    local keywords = customFilters or self.keywords or DefaultKeywords
    
    -- Coletar todos os objetos
    local allObjects = {}
    for _, service in pairs(self.services) do
        local serviceStart = tick()
        local objects = service:GetDescendants()
        
        for _, obj in pairs(objects) do
            if self:_shouldScanObject(obj, keywords, searchPattern) then
                table.insert(allObjects, obj)
            end
        end
        
        self.performance[service.Name] = {
            duration = tick() - serviceStart,
            object_count = #objects
        }
    end
    
    -- Processar objetos em lotes
    local totalObjects = #allObjects
    local processed = 0
    
    while processed < totalObjects and self.running do
        local batch = {}
        local batchSize = math.min(self.config.BATCH_SIZE, totalObjects - processed)
        
        for i = 1, batchSize do
            table.insert(batch, allObjects[processed + i])
        end
        
        self:_processBatch(batch)
        processed = processed + batchSize
        
        -- Yield para evitar freeze
        if processed % (self.config.BATCH_SIZE * 2) == 0 then
            wait(self.config.YIELD_INTERVAL)
        end
    end
    
    self.performance.total_duration = tick() - self.performance.start_time
    self.performance.objects_scanned = processed
    
    -- Gerar alertas
    self:_generateAlerts()
    
    return self.results, self.performance, self.alerts
end

function Scanner:_shouldScanObject(obj, keywords, searchPattern)
    local objName = obj.Name:lower()
    
    -- Filtro por padrão de busca
    if searchPattern and searchPattern ~= "" then
        local pattern = searchPattern:lower()
        if not objName:find(pattern) then
            return false
        end
    end
    
    -- Filtro por palavras-chave
    for _, keyword in pairs(keywords) do
        if objName:find(keyword:lower()) then
            return true
        end
    end
    
    -- Filtro por tipo de objeto importante
    local importantTypes = {
        "Script", "LocalScript", "ModuleScript",
        "RemoteEvent", "RemoteFunction",
        "IntValue", "StringValue", "BoolValue", "NumberValue"
    }
    
    for _, objType in pairs(importantTypes) do
        if obj:IsA(objType) then
            return true
        end
    end
    
    return false
end

function Scanner:_processBatch(batch)
    for _, obj in pairs(batch) do
        local success, result = pcall(function()
            return self:_processObject(obj)
        end)
        
        if success and result then
            self.results[obj.Name .. "_" .. tostring(obj)] = result
        end
    end
end

function Scanner:_processObject(obj)
    local data = ObjectData.new(obj)
    
    -- Capturar propriedades básicas
    data:addProperty("ClassName", obj.ClassName)
    data:addProperty("Parent", obj.Parent and obj.Parent.Name or "nil")
    
    -- Capturar filhos
    for _, child in pairs(obj:GetChildren()) do
        table.insert(data.children, {
            name = child.Name,
            className = child.ClassName
        })
    end
    
    -- Análise específica por tipo
    if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        if not Analyzer:analyzeScript(obj, data) then
            return nil
        end
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        Analyzer:analyzeRemoteObject(obj, data)
    elseif obj:IsA("IntValue") or obj:IsA("StringValue") or obj:IsA("BoolValue") or obj:IsA("NumberValue") then
        Analyzer:analyzeValueObject(obj, data)
    end
    
    return data
end

function Scanner:_generateAlerts()
    self.alerts = {}
    
    for name, data in pairs(self.results) do
        if data.risk_level >= self.config.ALERT_THRESHOLD then
            table.insert(self.alerts, {
                object = name,
                risk_level = data.risk_level,
                flags = data.flags,
                timestamp = tick()
            })
        end
    end
    
    -- Ordenar por nível de risco
    table.sort(self.alerts, function(a, b)
        return a.risk_level > b.risk_level
    end)
end

function Scanner:stop()
    self.running = false
end

-- ==================== SISTEMA DE EXPORTAÇÃO ====================

local Exporter = {}

function Exporter:exportJSON(data, performance, alerts)
    local exportData = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        version = "2.0",
        data = data,
        performance = performance,
        alerts = alerts,
        statistics = self:_generateStatistics(data, alerts)
    }
    
    local json = HttpService:JSONEncode(exportData)
    return json
end

function Exporter:exportCSV(data)
    local csv = "Name,Path,Type,Parent,RiskLevel,Flags\n"
    
    for name, objData in pairs(data) do
        local flags = {}
        for _, flag in pairs(objData.flags) do
            table.insert(flags, flag.flag)
        end
        
        csv = csv .. string.format("%s,%s,%s,%s,%d,%s\n",
            objData.name,
            objData.path,
            objData.className,
            objData.parent,
            objData.risk_level,
            table.concat(flags, ";")
        )
    end
    
    return csv
end

function Exporter:_generateStatistics(data, alerts)
    local stats = {
        total_objects = 0,
        by_type = {},
        by_risk_level = {low = 0, medium = 0, high = 0},
        total_alerts = #alerts,
        most_common_flags = {}
    }
    
    local flagCount = {}
    
    for _, objData in pairs(data) do
        stats.total_objects = stats.total_objects + 1
        
        -- Contar por tipo
        stats.by_type[objData.className] = (stats.by_type[objData.className] or 0) + 1
        
        -- Contar por nível de risco
        if objData.risk_level < 2 then
            stats.by_risk_level.low = stats.by_risk_level.low + 1
        elseif objData.risk_level < 5 then
            stats.by_risk_level.medium = stats.by_risk_level.medium + 1
        else
            stats.by_risk_level.high = stats.by_risk_level.high + 1
        end
        
        -- Contar flags
        for _, flag in pairs(objData.flags) do
            flagCount[flag.flag] = (flagCount[flag.flag] or 0) + 1
        end
    end
    
    -- Flags mais comuns
    for flag, count in pairs(flagCount) do
        table.insert(stats.most_common_flags, {flag = flag, count = count})
    end
    
    table.sort(stats.most_common_flags, function(a, b)
        return a.count > b.count
    end)
    
    return stats
end

function Exporter:saveToGame(data, filename)
    filename = filename or "ExtractedData_" .. os.time()
    
    local success, result = pcall(function()
        local exportFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ExtractionExports")
        if not exportFolder then
            exportFolder = Instance.new("Folder")
            exportFolder.Name = "ExtractionExports"
            exportFolder.Parent = game:GetService("ReplicatedStorage")
        end
        
        local exportValue = Instance.new("StringValue")
        exportValue.Name = filename
        exportValue.Value = data
        exportValue.Parent = exportFolder
        
        return exportValue
    end)
    
    return success, result
end

-- ==================== MONITOR CONTÍNUO ====================

local Monitor = {}

function Monitor:new(scanner, interval)
    local self = setmetatable({}, {__index = Monitor})
    self.scanner = scanner
    self.interval = interval or Config.WATCH_INTERVAL
    self.running = false
    self.lastScan = nil
    self.history = {}
    return self
end

function Monitor:start()
    self.running = true
    
    spawn(function()
        while self.running do
            local results, performance, alerts = self.scanner:scan()
            
            -- Comparar com scan anterior
            if self.lastScan then
                local changes = self:_compareScans(self.lastScan, results)
                if #changes > 0 then
                    self:_notifyChanges(changes)
                end
            end
            
            -- Salvar histórico
            table.insert(self.history, {
                timestamp = tick(),
                results = results,
                performance = performance,
                alerts = alerts
            })
            
            -- Limitar histórico
            if #self.history > 10 then
                table.remove(self.history, 1)
            end
            
            self.lastScan = results
            wait(self.interval)
        end
    end)
end

function Monitor:stop()
    self.running = false
end

function Monitor:_compareScans(oldScan, newScan)
    local changes = {}
    
    -- Objetos adicionados
    for name, data in pairs(newScan) do
        if not oldScan[name] then
            table.insert(changes, {
                type = "ADDED",
                object = name,
                data = data
            })
        end
    end
    
    -- Objetos removidos
    for name, _ in pairs(oldScan) do
        if not newScan[name] then
            table.insert(changes, {
                type = "REMOVED",
                object = name
            })
        end
    end
    
    return changes
end

function Monitor:_notifyChanges(changes)
    for _, change in pairs(changes) do
        print(string.format("[MONITOR] %s: %s", change.type, change.object))
        
        if change.type == "ADDED" and change.data.risk_level > 3 then
            warn(string.format("[ALERT] High-risk object detected: %s (Risk: %d)", 
                change.object, change.data.risk_level))
        end
    end
end

-- ==================== INTERFACE PRINCIPAL ====================

function ExtractionModule:CreateScanner(config)
    local scanner = Scanner:new(config)
    scanner:setKeywords(DefaultKeywords)
    return scanner
end

function ExtractionModule:QuickScan(searchPattern, keywords)
    local scanner = self:CreateScanner()
    if keywords then
        scanner:setKeywords(keywords)
    end
    
    local results, performance, alerts = scanner:scan(searchPattern)
    
    -- Exportar automaticamente
    local json = Exporter:exportJSON(results, performance, alerts)
    Exporter:saveToGame(json)
    
    -- Relatório rápido
    print(string.format("=== RELATÓRIO DE EXTRAÇÃO ==="))
    print(string.format("Objetos encontrados: %d", performance.objects_scanned))
    print(string.format("Tempo total: %.2fs", performance.total_duration))
    print(string.format("Alertas gerados: %d", #alerts))
    
    if #alerts > 0 then
        print("=== ALERTAS DE ALTO RISCO ===")
        for i, alert in ipairs(alerts) do
            if i <= 5 then -- Mostrar apenas os 5 primeiros
                print(string.format("• %s (Risco: %d)", alert.object, alert.risk_level))
            end
        end
    end
    
    return results, performance, alerts
end

function ExtractionModule:StartMonitoring(interval, config)
    local scanner = self:CreateScanner(config)
    local monitor = Monitor:new(scanner, interval)
    monitor:start()
    
    print(string.format("Monitor iniciado com intervalo de %ds", interval or Config.WATCH_INTERVAL))
    return monitor
end

function ExtractionModule:FindDuplicates(results)
    local duplicates = {}
    local hashMap = {}
    
    for name, data in pairs(results) do
        if data.hash then
            if hashMap[data.hash] then
                if not duplicates[data.hash] then
                    duplicates[data.hash] = {hashMap[data.hash]}
                end
                table.insert(duplicates[data.hash], name)
            else
                hashMap[data.hash] = name
            end
        end
    end
    
    return duplicates
end

function ExtractionModule:GetSecurityReport(results)
    local report = {
        high_risk_objects = {},
        suspicious_patterns = {},
        network_objects = {},
        obfuscated_scripts = {}
    }
    
    for name, data in pairs(results) do
        if data.risk_level >= 5 then
            table.insert(report.high_risk_objects, {name = name, risk = data.risk_level})
        end
        
        if data.metadata.obfuscation_score and data.metadata.obfuscation_score > 0.7 then
            table.insert(report.obfuscated_scripts, {name = name, score = data.metadata.obfuscation_score})
        end
        
        for _, flag in pairs(data.flags) do
            if flag.flag:find("DANGEROUS_PATTERN") then
                table.insert(report.suspicious_patterns, {object = name, pattern = flag.flag})
            elseif flag.flag == "REMOTE_OBJECT" then
                table.insert(report.network_objects, name)
            end
        end
    end
    
    return report
end

-- ==================== BACKWARDS COMPATIBILITY ====================

function ExtractionModule:ScanGame(searchPattern)
    return self:QuickScan(searchPattern)
end

function ExtractionModule:GetCapturedData()
    -- Método legado - retorna dados do último scan
    return self.lastResults or {}, {}
end

function ExtractionModule:StartWatch(interval)
    return self:StartMonitoring(interval)
end

-- ==================== INICIALIZAÇÃO ====================

-- Guardar referência para compatibilidade
ExtractionModule.Config = Config
ExtractionModule.DefaultKeywords = DefaultKeywords
ExtractionModule.DangerousPatterns = DangerousPatterns

return ExtractionModule
