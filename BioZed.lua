if myHero.charName ~= "Zed" then return end
if VIP_USER then
       PrintChat("<font color=\"#FF0000\" >>BioZed Customize Version By bollovefeel v 1.5<</font> ")
end
 
local RREADY, QREADY, WREADY, EREADY
local prediction
local VP
local ts
local UltTargets = GetEnemyHeroes()
local version = 1.5
local scriptName = "BioZed"

-- Change autoUpdate to false if you wish to not receive auto updates.
-- Change silentUpdate to true if you wish not to receive any message regarding updates
local autoUpdate   = false
local silentUpdate = false


-- Lib Downloader --

local REQUIRED_LIBS = {
    ["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
    ["SOW"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
    ["SourceLib"] = "https://raw.githubusercontent.com/TheRealSource/public/master/common/SourceLib.lua",
                    }
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""

function AfterDownload()
    DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
    if DOWNLOAD_COUNT == 0 then
        DOWNLOADING_LIBS = false
        print("<b>Required libraries downloaded successfully, please reload (double F9).</b>")
    end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
    if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
        require(DOWNLOAD_LIB_NAME)
    else
        DOWNLOADING_LIBS = true
        DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
        DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
    end
end

if DOWNLOADING_LIBS then print("Downloading required libraries, please wait...") return end

if autoUpdate then
    SourceUpdater(scriptName, version, "raw.github.com", "/LucasRPC/Scripts/master/BioZed.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME):SetSilent(silentUpdate):CheckUpdate()
end

--
 
function OnLoad()
        ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 900 ,DAMAGE_PHYSICAL)
        ts.name = "Zed"
        if VIP_USER then
            VP = VPrediction()
        end
        SOWi = SOW(VP)
        LoadVariables()
        LoadMenu()
        Ignite()
    for i=1, heroManager.iCount do
        local champ = heroManager:GetHero(i)
        if champ.team ~= myHero.team then
        EnemysInTable = EnemysInTable + 1
        EnemyTable[EnemysInTable] = { hero = champ, Name = champ.charName, p = 0, q = 0, q2 = 0, e = 0, r = 0, IndicatorText = "", IndicatorPos, NotReady = false, Pct = 0}
                end
        end
        PrintFloatText(myHero,11,"LETS RAPE >:D !")
    EnemyMinions = minionManager(MINION_ENEMY, 900, myHero, MINION_SORT_HEALTH_ASC)
       qEnergy = {75, 70, 65, 60, 55}
       wEnergy = {40, 35, 30, 25, 20}
       eCost = 50
             qDelay, qWidth, qRange, qSpeed = 0.25, 45, 900, 902
           wDelay, wWidth, wRange, wSpeed = 0.25, 40, 550, 1600
             wSwap = false
             wCast = false
end
 
function OnTick()
    ts:update()
    tstarget = ts.target
    if ValidTarget(tstarget) and tstarget.type == "obj_AI_Hero" then
        Target = tstarget
    else
        Target = nil
    end
    Calculations()
    GlobalInfos()
    HarassKey = Config.harass.harassKey
    if HarassKey then Harass() end
    for i = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(i)
                if enemyhero.team ~= myHero.team and TargetHaveBuff("zedulttargetmark", enemyhero) then        
                        ts.target = enemyhero
                end
     end
     SetCooldowns()
     if Config.ComboS.Fight then Fight() end
     if Config.lfarm.farmKey then
            EnemyMinions:update()
            for _, minion in pairs(EnemyMinions.objects) do
                if Config.lfarm.farmQ then
                    if minion.health <= getDmg("Q", minion, myHero) then
                        if GetDistance(myHero.visionPos, minion) <= qRange then CastSpell(_Q, minion.x, minion.z) end
                    end
                end
                if Config.lfarm.FarmE then
                    if minion.health <= getDmg("E", minion, myHero) then
                        if GetDistance(myHero.visionPos, minion) <= eRange then CastSpell(_E, myHero) end
                    end
                end
            end
        end
end
 
function OnUnload()
    PrintFloatText(myHero,9,"U NO RAPE ?! :,( ")
end
 
function LoadVariables()
	UseSwap = true
	ChampCount = nil
    wClone, rClone = nil, nil
    RREADY, QREADY, WREADY, EREADY = false, false, false, false
    ignite = nil
    lastW = 0
    delay, qspeed = 235, 1.742
           
    --Helpers
    EnemyTable = {}
    EnemysInTable = 0
    HealthLeft = 0
    PctLeft = 0
    BarPct = 0
    orange = 0xFFFFE303
    green = ARGB(255,0,255,0)
    blue = ARGB(255,0,0,255)
    red = ARGB(255,255,0,0)
    eRange = 280
    Target = nil
    QREADY = nil
    WREADY = nil
    EREADY = nil
    RREADY = nil
    QMana = nil
    WMana = nil
    EMana = nil
    RMana = nil
    MyMana = nil
end

function LoadMenu()
     Config = scriptConfig("BioZed Customize Version by bollovefeel", "Die")
     
     Config:addSubMenu("BioZed - Combo Settings", "ComboS")          
        Config.ComboS:addParam("Fight", "BioCombo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        Config.ComboS:addParam("SwapUlt","Swap back with ult if hp < %", SCRIPT_PARAM_SLICE, 15, 2, 100, 0)
        Config.ComboS:addParam("NoWWhenUlt","Don't use W when Zed ult", SCRIPT_PARAM_ONOFF, true)
        Config.ComboS:addParam("rSwap", "Swap to R shadow if safer when mark kills", SCRIPT_PARAM_ONOFF, false)
        Config.ComboS:addParam("wSwap", "Swap with W to get closer to target", SCRIPT_PARAM_ONOFF, false)
        
   
     Config:addSubMenu("BioZed - Harass Settings", "harass")
        Config.harass:addParam("harassKey", "Harass Key (T)", SCRIPT_PARAM_ONKEYDOWN, false,string.byte("T"))
        Config.harass:addParam("mode", "True = QWE, False = Q", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("V"))
        Config.harass:permaShow("harassKey")
        Config.harass:permaShow("mode")
   
    Config:addSubMenu("BioZed - Ignite Settings", "lignite")    
        Config.lignite:addParam("igniteOptions", "Ignite Options", SCRIPT_PARAM_LIST, 2, { "Don't use", "Burst"})
        Config.lignite:permaShow("igniteOptions")
        Config.lignite:addParam("autoIgnite", "Ks Ignite", SCRIPT_PARAM_ONOFF, true)
           
    Config:addSubMenu("BioZed - Drawing Setting", "draw")
        Config.draw:addParam("DmgIndic","Kill text", SCRIPT_PARAM_ONOFF, true)
        Config.draw:addParam("Edraw", "Draw E", SCRIPT_PARAM_ONOFF, true)
        Config.draw:addParam("Qdraw", "Draw Q", SCRIPT_PARAM_ONOFF, true)
               
    Config:addSubMenu("BioZed - Misc", "lmisc")
        Config.lmisc:addParam("AutoE", "Auto E", SCRIPT_PARAM_ONOFF, true)
 
    Config:addSubMenu("BioZed - Farm", "lfarm")
        Config.lfarm:addParam("farmKey", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
        Config.lfarm:addParam("farmQ", "Farm With Q", SCRIPT_PARAM_ONOFF, true)
        Config.lfarm:addParam("FarmE", "Farm With E", SCRIPT_PARAM_ONOFF, true)
        Config.lfarm:permaShow("farmKey")

    Config:addSubMenu("BioZed - Orbwalking", "Orbwalking")
        SOWi:LoadToMenu(Config.Orbwalking)
       
    Config.ComboS:permaShow("Fight")
    Config:addTS(ts)
end
 
function autoIgnite()
        if Config.lignite.autoIgnite then
                if iReady then
                        local ignitedmg = 0
                        for i = 1, heroManager.iCount, 1 do
                                local enemyhero = heroManager:getHero(i)
                                        if ValidTarget(enemyhero,600) then
                                                ignitedmg = 50 + 20 * myHero.level
                                                if enemyhero.health <= ignitedmg then
                                                        CastSpell(ignite, enemyhero)
                                                end
                                        end
                        end
                end
        end
end

function Swap()
    local wDist = nil
    if UseSwap == true then
	    if ts.target then
	        if wClone and wClone.valid then 
	            wDist = GetDistance(ts.target, wClone) 
	        else
	            return false
	        end
	        if GetDistance(ts.target) > 250 then
	            if wDist and wDist ~= 0 and (GetDistance(ts.target, myHero) > wDist) and (myHero:CanUseSpell(_W) == READY) and not EREADY then
	            CastSpell(_W)
	            end
	        end
	    end
	end
end

function CountEnemies(point, range)
	local ChampCount = 0
    for j = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(j)
        if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, 750) then
            if GetDistanceSqr(enemyhero, point) <= range*range then
                ChampCount = ChampCount + 1
            end
        end
    end            
    return ChampCount
end

function Fight()
    if Config.ComboS.wSwap then Swap() end
    if QREADY and EREADY and WREADY then 
        ts.range = 900
    else
        ts.range = 900
    end
    if ts.target then
        for i = 1, heroManager.iCount, 1 do
        if not (TargetHaveBuff("JudicatorIntervention", ts.target) or TargetHaveBuff("Undying Rage", ts.target)) then
            for i = 1, heroManager.iCount, 1 do
	                if myHero:GetSpellData(_W).name ~= "zedw2" and WREADY and ((GetDistance(ts.target) < 700) or (GetDistance(ts.target) > 125)) then
	            			if MyMana > (WMana+EMana) then
	                            CastSpell(_W, ts.target.x, ts.target.z)
	                        end
	                    end
	                end
	                                   
		            if (not WREADY or wClone ~= nil or Config.ComboS.NoWWhenUlt or wUsed) then  
		                if EREADY then  
		                    CastE()
		                end                                                
		                if QREADY and GetDistance(ts.target, myHero) < qRange then
		                    CastQ()
		                end
		            end
		        end
            end
                       
                       
            if Config.lignite.igniteOptions == 2 then
                if iReady then
                    if GetDistance(ts.target) <= 600 then
                        CastSpell(ignite, ts.target)
                    end
                end
            end
            CastItems(ts.target)
        if RREADY and rClone ~= nil and Config.ComboS.rSwap then
        	if isDead then
        		if CountEnemies(myHero, 250) > CountEnemies(rClone, 250) then
        		--PrintChat("DEAD")
        			UseSwap = false
        			CastSpell(_R)
        			DelayAction(function() UseSwap = true end, 5)
        		end
        	end
        end
    end
end
 
function Harass()
    ts.range = 1500
    if ts.target then
        if Config.harass.mode then
            if QREADY and WREADY and (GetDistance(ts.target, myHero) < 700) and (MyMana > QMana+WMana+EMana) then
                if myHero:GetSpellData(_W).name ~= "zedw2" and GetTickCount() > lastW + 1000 then
                    CastSpell(_W, ts.target.x, ts.target.z)
                    if wUsed then CastSpell(_E) end
                end
            end
            if wUsed then
                CastQ()
            end
            if not WREADY then 
                CastQ()
                CastQClone()
            end
            CastE()
            if GetDistance(ts.target, myHero) < 1450 and GetDistance(ts.target, myHero) > 900 then
                local DashPos = myHero + Vector(ts.target.x - myHero.x, 0, ts.target.z - myHero.z):normalized()*550
                        if QREADY and WREADY and (MyMana > QMana+WMana) then
                                                    --PrintChat("Gapclose")
                            if myHero:GetSpellData(_W).name == "ZedShadowDash" then CastSpell(_W, DashPos.x, DashPos.z) end
                        end
                        if wClone and wClone.valid then
                            CastQClone()
                        end
                       
            end

        else
       
 
        if not Config.harass.mode then
            if QREADY and GetDistance(ts.target, myHero) < qRange then
                CastQ()
            end
        end
    end
           
 end
 end
 
function CastQ()
     if ValidTarget(ts.target) and (GetDistance(ts.target, myHero) < qRange or GetDistance(ts.target, wClone) < qRange or GetDistance(ts.target, rClone) < qRange) then
     local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.25, 50, 925, 1700, myHero, false)
        if HitChance >= 1 then
            CastSpell(_Q, CastPosition.x, CastPosition.z)    
        end
    end
end

function CastQClone()
    if ValidTarget(ts.target) and GetDistance(ts.target, wClone) < qRange then
     local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.25, 50, 925, 1700, wClone, false)
        if HitChance >= 1 then
            CastSpell(_Q, CastPosition.x, CastPosition.z)    
        end
    end
end


    
function CastE()
    if ValidTarget(ts.target) and (GetDistance(ts.target, myHero) < eRange or GetDistance(ts.target, wClone) < eRange or GetDistance(ts.target, rClone) < eRange) then
        CastSpell(_E, myHero)
    end
end



function rUsed()
        if myHero:GetSpellData(_R).name == "ZedR2" then
                return true
        else
                return false
        end
end
 
function GlobalInfos()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        QMana = myHero:GetSpellData(_Q).mana
        WMana = myHero:GetSpellData(_W).mana
        EMana = myHero:GetSpellData(_E).mana
        RMana = myHero:GetSpellData(_R).mana
        MyMana = myHero.mana
       
        TemSlot = GetInventorySlotItem(3153)
        BOTRKREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Blade Of The Ruined King
       
        TemSlot = GetInventorySlotItem(3144)    
        BCREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Bilgewater Cutlass
       
        TemSlot = GetInventorySlotItem(3074)
        HYDRAREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Ravenous Hydra
       
        TemSlot = GetInventorySlotItem(3077)
        TIAMATREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Tiamat
       
        iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end
 
function OnCreateObj(obj)
        if obj.valid and obj.name:find("Zed_Clone_idle.troy") then
                if wClone == nil then
                        wClone = obj
                elseif rClone == nil then
                        rClone = obj
                end
        end
end
 
function OnDeleteObj(obj)
        if obj.valid and wClone and obj == wClone then
                wClone = nil
        elseif obj.valid and rClone and obj == rClone then
                rClone = nil
        end
end
 
function Ignite()
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
        end
end
 
function SetCooldowns()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end
 
function CastItems(target)
        if not ValidTarget(target) then
                return
        else
                if GetDistance(ts.target) <=480 then
                        CastItem(3144, target) --Bilgewater Cutlass
                        CastItem(3153, target) --Blade Of The Ruined King
                end
                if GetDistance(ts.target) <=400 then
                        CastItem(3146, target) --Hextech Gunblade
                end
                if GetDistance(ts.target) <= 350 then
                        CastItem(3184, target) --Entropy
                        CastItem(3143, target) --Randuin's Omen
                        CastItem(3074, target) --Ravenous Hydra
                        CastItem(3131, target) --Sword of the Divine
                        CastItem(3077, target) --Tiamat
                        CastItem(3142, target) --Youmuu's Ghostblade
                end
                if GetDistance(ts.target) <= 1000 then
                        CastItem(3023, target) --Twin Shadows
                end
        end
end
 
function Calculations()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        QMana = myHero:GetSpellData(_Q).mana
        WMana = myHero:GetSpellData(_W).mana
        EMana = myHero:GetSpellData(_E).mana
        RMana = myHero:GetSpellData(_R).mana
        MyMana = myHero.mana
        for i=1, EnemysInTable do
               
                local enemy = EnemyTable[i].hero
                if ValidTarget(enemy) and enemy.visible then
                        caaDmg = getDmg("AD",enemy,myHero)
                        cpDmg = getDmg("P", enemy, myHero)
                        cqDmg = getDmg("Q", enemy, myHero)
                        ceDmg = getDmg("E", enemy, myHero)
                        ciDmg = getDmg("IGNITE", enemy, myHero)
               
                        UltExtraDmg = 0
                        cItemDmg = 0
                        cTotal = 0
       
                        if BCREADY then
                                cItemDmg = cItemDmg + getDmg("BWC", enemy, myHero)
                        end
                        if BOTRKREADY then
                                cItemDmg = cItemDmg + getDmg("RUINEDKING", enemy, myHero, 2)
                        end
                        if HYDRAREADY then
                                cItemDmg = cItemDmg + getDmg("HYDRA", enemy, myHero)
                        end
                        if TIAMATREADY then
                                cItemDmg = cItemDmg + getDmg("TIAMAT", enemy, myHero)
                        end
                       
                        EnemyTable[i].p = cpDmg
                       
                        EnemyTable[i].q = cqDmg
                       
                        if WillQCol then
                                EnemyTable[i].q = EnemyTable[i].q / 2          
                        end
                        EnemyTable[i].q2 = EnemyTable[i].q + (cqDmg / 2)
                       
                        EnemyTable[i].e = ceDmg
                        if RREADY then
                                UltExtraDmg = myHero.totalDamage
                                if WREADY then
                                        UltExtraDmg = UltExtraDmg + (.15*myHero:GetSpellData(_R).level+5) * (EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + caaDmg)
                                else
                                        UltExtraDmg = UltExtraDmg + (.15*myHero:GetSpellData(_R).level+5) * (EnemyTable[i].q + EnemyTable[i].e + EnemyTable[i].p + caaDmg)
                                end
                                UltExtraDmg = myHero:CalcDamage(enemy, UltExtraDmg)
                        end
                        EnemyTable[i].r = UltExtraDmg
                       
                       
                        if enemy.health < EnemyTable[i].e  then
                                EnemyTable[i].IndicatorText = "E Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if not EReady then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end    
                elseif enemy.health < EnemyTable[i].q then
                                EnemyTable[i].IndicatorText = "Q Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if not QREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end    
                elseif enemy.health < EnemyTable[i].q2 then
                                EnemyTable[i].IndicatorText = "W+Q Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana > MyMana or not QREADY or not WREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end            
                elseif enemy.health < EnemyTable[i].q2 + EnemyTable[i].e then
                                EnemyTable[i].IndicatorText = "W+E+Q Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana + EMana > MyMana or not QREADY or not WREADY or not EREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end
                --elseif enemy.health < EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + caaDmg then
                                --EnemyTable[i].IndicatorText = "W+E+Q+AA Kill"
                                --EnemyTable[i].IndicatorPos = 0
                        --if QMana + WMana + EMana > MyMana or not QREADY or not WREADY or not EREADY then
                                        --EnemyTable[i].NotReady = true
                                --else
                                        --EnemyTable[i].NotReady = false
                        --end
                elseif (not RREADY) and enemy.health < EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + caaDmg + ciDmg + cItemDmg then
                                EnemyTable[i].IndicatorText = "SBTW"
                                EnemyTable[i].IndicatorPos = 0
                        if (QMana + WMana + EMana > MyMana) or not QREADY or not WREADY or not EREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end    
                elseif (not WREADY) and enemy.health < EnemyTable[i].q + EnemyTable[i].e + EnemyTable[i].p + EnemyTable[i].r + caaDmg + ciDmg + cItemDmg then
                                EnemyTable[i].IndicatorText = "All In Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + EMana > MyMana or not QREADY or not EREADY or not RREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end
                elseif enemy.health < EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + EnemyTable[i].r + caaDmg + ciDmg + cItemDmg then
                                EnemyTable[i].IndicatorText = "Just Rape"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana + EMana + RMana > MyMana or not QREADY or not WREADY or not EREADY or not RREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end
                else
                        cTotal = cTotal + EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + EnemyTable[i].r + caaDmg
                               
                                HealthLeft = math.round(enemy.health - cTotal)
                                PctLeft = math.round(HealthLeft / enemy.maxHealth * 100)
                                BarPct = PctLeft / 103 * 100
                                EnemyTable[i].Pct = PctLeft
                                EnemyTable[i].IndicatorPos = BarPct
                                EnemyTable[i].IndicatorText = PctLeft .. "% Harass"
                                if not qReady or not wReady or not eReady then
                                        EnemyTable[i].NotReady =  true
                                else
                                        EnemyTable[i].NotReady = false
                                end
                end
                end    
        end
end
 
--CallBacks--
 
function OnCreateObj(obj)
        if obj.valid and obj.name:find("Zed_Clone_idle.troy") then
                if wUsed and wClone == nil then
                        wClone = obj
                elseif rClone == nil then
                        rClone = obj
                end
        end
        if obj.valid and obj.name:find("Zed_Base_R_buf_tell.troy") then
        	isDead = true
        	PrintChat("DEAD")
        end
end
 
function OnDeleteObj(obj)
        if obj.valid and wClone and obj == wClone then
                wUsed = false
                wClone = nil  
        elseif obj.valid and rClone and obj == rClone then
                rClone = nil
        end
        if obj.valid and obj.name:find("Zed_Base_R_buf_tell.troy") then
        	isDead = false
        end
end
 
function OnProcessSpell(unit, spell)
        if unit.isMe and spell.name == "ZedShadowDash" then
                wUsed = true
                lastW = GetTickCount()
                        wCast = true
        end
end

 
function OnAnimation(unit, animationName)
        if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end
 
--Lagfree Circles by barasia, vadash and viseversa
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
        quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
        quality = 2 * math.pi / quality
        radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end
 
function round(num)
    if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end
 
function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75)    
    end
end
 
 
function OnDraw()
 if Config.draw.Qdraw then
 
                        DrawCircle(myHero.x, myHero.y, myHero.z, 900, ARGB(255,255,0,0))
 
        end
        if Config.draw.Edraw then
                        DrawCircle(myHero.x, myHero.y, myHero.z, 290, ARGB(255,255,0,0))
 
        end
 
 
        if Config.draw.DmgIndic then
                for i=1, EnemysInTable, 1 do
                        local enemy = EnemyTable[i].hero
                        if ValidTarget(enemy) then
--                              enemy.barData = GetEnemyBarData()
                                local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                local PosX = barPos.x - 35
                local PosY = barPos.y - 50
--                              local barPosOffset = GetUnitHPBarOffset(enemy)
--                              local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
--                              local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
--                              local BarPosOffsetX = 171
--                              local BarPosOffsetY = 46
--                              local CorrectionY =  14.5
--                              local StartHpPos = 31
--                              local IndicatorPos = EnemyTable[i].IndicatorPos
                                local Text = EnemyTable[i].IndicatorText
--                              barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos
--                              barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY
                                if EnemyTable[i].NotReady == true then
               
                                        DrawText(tostring(Text),15,PosX ,PosY  ,orange)
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y ,orange)
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-9 ,orange)
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-18 ,orange)
                                else
                                        DrawText(tostring(Text),15,PosX ,PosY ,ARGB(255,0,255,0))      
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y ,ARGB(255,0,255,0))
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-9 ,ARGB(255,0,255,0))
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-18 ,ARGB(255,0,255,0))
                                end
                        end
                end
        end
end
