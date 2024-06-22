require "lib.moonloader" 
local sampev = require ("lib.samp.events")
local memory = require("memory")
local ffi           = require ("ffi")
local imgui = require 'imgui'
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local ffi        = require('ffi')
local http = require("socket.http")
--local ltn12 = require("ltn12")


local other_font = renderCreateFont('Tahoma', 7, 5)

local getbonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local stun_anims = {'DAM_armL_frmBK', 'DAM_armL_frmFT', 'DAM_armL_frmLT', 'DAM_armR_frmBK', 'DAM_armR_frmFT', 'DAM_armR_frmRT', 'DAM_LegL_frmBK', 'DAM_LegL_frmFT', 'DAM_LegL_frmLT', 'DAM_LegR_frmBK', 'DAM_LegR_frmFT', 'DAM_LegR_frmRT', 'DAM_stomach_frmBK', 'DAM_stomach_frmFT', 'DAM_stomach_frmLT', 'DAM_stomach_frmRT'}


local luasql = require "luasql.mysql"

local paskov = "NFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23"
--local paskov = "rNFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23"
local piskeva = "qnwudnu9213"
local piskev1o = "qnwudnu9213"


function getPlayerHWID()
    -- Recuperar informações do sistema (requer a biblioteca 'ffi')
    local ffi = require("ffi")
    ffi.cdef[[
        int GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, unsigned long nVolumeNameSize,
            unsigned long* lpVolumeSerialNumber, unsigned long* lpMaximumComponentLength, unsigned long* lpFileSystemFlags,
            char* lpFileSystemNameBuffer, unsigned long nFileSystemNameSize);
    ]]

    local function getVolumeSerialNumber()
        local volumeNameBuffer = ffi.new("char[256]")
        local volumeSerialNumber = ffi.new("unsigned long[1]")

        local success = ffi.C.GetVolumeInformationA(
            nil,
            volumeNameBuffer,
            256,
            volumeSerialNumber,
            nil,
            nil,
            nil,
            0
        )

        if success ~= 0 then
            return tonumber(volumeSerialNumber[0])
        else
            return nil
        end
    end

    -- Concatenar informações relevantes do hardware (por exemplo, disco rígido e placa-mãe)
    local hwid = getVolumeSerialNumber()
    if hwid then
        return tostring(hwid)
    else
        return nil
    end
end



function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end



togglecasa = 0
toggleempresa = 0

btnbotcasaon = "(OFF): BOT CASA"
btnbotempreon = "(OFF): BOT EMPRESA"

local directIni = "../cvr/configs.ini"
local ini = inicfg.load(inicfg.load({
    esp= {
        espline = false,
        espskeleto = false,
    },
    androidpc={
        pc = false,
        rb_selectp = 1
    },
    macros={
        iniautopm = false,
        inipmautoID = true,
        inipmfov = 160,
        iniautoparamedico = false,
        iniparamedicoautoID = true,
        initempo = 10,
        inihora = 12,
        iniacitvartemporal = false,
        autolg = false,
        senha = "",
        autofov = false
    },
    usuario={
        autologar = false,
        key = "",
    },
}, directIni))
inicfg.save(ini, directIni)


--local http = require("socket.http")



--[[

function login(key, hwid)
    local host = "10061"
    local user = "id21123488_root"
    local password = "pizk*Hj12ji3"
    local database = "id21123488_cvr_mkstar"

    -- Crie a conexão com o banco de dados
    local env = assert(luasql.mysql())
    local conn = assert(env:connect(database, user, password, host))

    -- Consulta para verificar se a chave de acesso existe e o status do HWID
    local sql = string.format("SELECT * FROM usuarios WHERE `key` = '%s'", key)
    local cur = assert(conn:execute(sql))

    -- Verificar se a chave de acesso existe
    local row = cur:fetch({}, "a")
    if row then
        if row.hwid == "0" then
            -- HWID ainda não está registrado, atualize o HWID com o valor fornecido
            sql = string.format("UPDATE usuarios SET hwid = '%s' WHERE `key` = '%s'", hwid, key)
            assert(conn:execute(sql))
        elseif row.hwid ~= hwid then
            --print("Você não tem permissão, pois o HWID é de outra máquina.")
            sampAddChatMessage('Voce Nao tem Permissao para Usar, Pois o HWID eh de outra Maquina.', -1)
            -- Faça algo aqui, como mostrar uma mensagem de erro de permissão.
            return
        end

        -- Verificar se a data de vencimento é válida
        local today = os.date("%Y-%m-%d")
        if row.vencimento >= today then
            sampAddChatMessage('Logado com Sucesso.', -1)
            -- Faça algo aqui, como redirecionar o usuário para a página inicial do painel.
            if piskeva == piskev1o then
                ini.usuario.autologar = true
                ini.usuario.key = key
                paskov = piskeva..piskev1o;
            end
            inicfg.save(ini, directIni)
        else
            sampAddChatMessage('A chave de acesso expirou.', -1)
            -- Faça algo aqui, como mostrar uma mensagem de erro de vencimento.
        end
    else
        sampAddChatMessage('Key Invalida.', -1)
        -- Faça algo aqui, como mostrar uma mensagem de erro de chave inválida.
    end

    cur:close()

    -- Feche a conexão com o banco de dados
    conn:close()
end]]



--local http = require("socket.http")
local ltn12 = require("ltn12")

function login(key, hwid)
    local url = "https://mokstarscript12.000webhostapp.com/abcdefg779045.php?key=" .. key .. "&hwid=" .. hwid

    local response_body = {}
    local res, code, response_headers = http.request {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response_body)
    }

    if code == 200 then
        local response = table.concat(response_body)
        if response == "LOGADO" then
            sampAddChatMessage('Logado com Sucesso.', -1)
            if piskeva == piskev1o then
                ini.usuario.autologar = true
                ini.usuario.key = key
                paskov = piskeva..piskev1o;
            end
            inicfg.save(ini, directIni)
            -- Faça algo aqui, como redirecionar o usuário para a página inicial do painel.
        elseif response == "HWID_INVALIDO" then
           -- sampAddChatMessage('Voce nao tem permissao, pois o HWID e de outra maquina.', -1)
           sampAddChatMessage('Logado com Sucesso.', -1)
            if piskeva == piskev1o then
                ini.usuario.autologar = true
                ini.usuario.key = key
                paskov = piskeva..piskev1o;
            end
            inicfg.save(ini, directIni)
        elseif response == "CHAVE_EXPIRADA" then
            sampAddChatMessage('A chave de acesso expirou.', -1)
            thisScript():unload()
        else
            sampAddChatMessage('Chave Invalida.', -1)

        end
    else
        sampAddChatMessage('Erro ao fazer a solicitacao.', -1)

    end
end








--|-------------  Variables -------------|--
local xtab = 1
local rb_select = ini.androidpc.rb_selectp
local AbrirImgui = imgui.ImBool(false)
local EspLine = imgui.ImBool(ini.esp.espline)
local EspBox = imgui.ImBool(ini.esp.espskeleto)
--|-------------  Variables of Macros -------------|--
local autoPM = imgui.ImBool(false)
local pmautoID = imgui.ImBool(true)
local autoMedico = imgui.ImBool(false)
local autoMedicoID = imgui.ImBool(true)
local activartemporall = imgui.ImBool(ini.macros.iniacitvartemporal)
local fovpm        = imgui.ImInt(ini.macros.inipmfov)
local tempo          = imgui.ImInt(ini.macros.initempo)
local hora             = imgui.ImInt(ini.macros.inihora)
local valores           = imgui.ImInt(2500)
local drawfov = imgui.ImBool(ini.macros.autofov)

local autologin = imgui.ImBool(ini.macros.autolg)
local senhap = imgui.ImBuffer(256)

local inputpmID = imgui.ImBuffer(256)
local inputKeyuss = imgui.ImBuffer(256)

isLoggedServer = 0






function conectarAoBanco()
    local env = assert(luasql.mysql())
    local conn = assert(env:connect(database, user, password, host))
    return env, conn
end

-- Função para verificar se o HWID existe na tabela
function verificarHWID(conn, hwid)
    local query = string.format("SELECT * FROM chaves WHERE hwid = '%s'", hwid)
    local cur = assert(conn:execute(query))
    local row = cur:fetch({}, "a")
    cur:close()
    return row -- Se o HWID existir, será um registro da tabela. Caso contrário, será nil.
end

-- Função para adicionar o HWID na tabela, caso não exista
function adicionarHWIDSeNaoExistir(conn, hwid)
    if not verificarHWID(conn, hwid) then
        local query = string.format("INSERT INTO users (hwid, access) VALUES ('%s', 1)", hwid)
        assert(conn:execute(query))
        print("HWID adicionado com acesso permitido.")
    end
end

-- Função para verificar se o acesso está permitido para o HWID
function verificarAcesso(conn, hwid)
    local row = verificarHWID(conn, hwid)
    if row and row.access == 1 then
        return true -- Acesso permitido
    else
        return false -- Acesso negado ou HWID não existe
    end
end





textisSHowedorNot = ""









function main()
    repeat wait(10) until isSampAvailable()
    sampAddChatMessage(string.format('[CVR MOKSTAR]: Carregado Com Sucesso... Divirta-se | Aperta END Para Abrir'), -1)
    lua_thread.create(Visual)
    lua_thread.create(othersp)
    lua_thread.create(temporalsds)
    local hwid = getPlayerHWID()

    if ini.usuario.autologar then
        login(ini.usuario.key, getPlayerHWID())
    end
    sampRegisterChatCommand('verlista', function()
        sampShowDialog(0, 'Lista', textisSHowedorNot,  'btn1', 'btn2', 0)
    end)

    while true do
        wait(10)
        imgui.Process = AbrirImgui.v
        if isKeyJustPressed(vkeys.VK_END) then
            AbrirImgui.v = not AbrirImgui.v
        end
        local resX, resY = getScreenResolution()
       --[[] renderFigure2D(resX / 2, resY / 2, 200, circleRadius, 0xFFff004d)
        for _, ped in ipairs(getAllChars()) do
            if ped ~= PLAYER_PED and isCharOnScreen(ped) then
                local sX, sY = convert3DCoordsToScreen(getCharCoordinates(ped))
                if getDistanceBetweenCoords2d(sX, sY, resX / 2, resY / 2) <= circleRadius then
                    renderDrawLine(resX / 2, resY / 2, sX, sY, 2, 0xFFff004d)
                end
            end
        end
        module1()]]

    if paskov == "NFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23" then
            
    else
            module1()
            if drawfov.v then
                renderFigure2D(resX / 2, resY / 2, 200, fovpm.v, 0xFFff004d)
            end
        end   
    end
end

function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getbonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end

function imgui.OnDrawFrame()
    X, Y = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(406,210), imgui.Cond.FirstUseEver)
    if AbrirImgui.v then
        imgui.Begin("Mokstar xD >> CVR << | < Cheat > ONLINE",AbrirImgui.v,imgui.WindowFlags.NoResize+imgui.WindowFlags.NoCollapse)

        if paskov == "NFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23" then
            imgui.InputText('Key: ', inputKeyuss)
            if imgui.Button('Logar', imgui.ImVec2(-1, 0)) then
                login(inputKeyuss.v, getPlayerHWID())
            end
            imgui.Button('Buy Key', imgui.ImVec2(-1, 0))
        else
            if imgui.Button('ESP ( VISUAL )', imgui.ImVec2(95, 0)) then
                xtab = 1
            end imgui.SameLine()
            if imgui.Button('MODS CVR', imgui.ImVec2(95, 0)) then
                xtab = 2
            end imgui.SameLine()
            if imgui.Button('ESSENCIALS', imgui.ImVec2(95, 0)) then
                xtab = 3
            end imgui.SameLine()
            if imgui.Button('ACERCA', imgui.ImVec2(95, 0)) then
                xtab = 4
            end
            imgui.Separator()
            if xtab ==1 then
                TextQuestion("Desenha Linhas na Posicao dos Jogadores ao seu REDOR\n\nObs: this function is saved automatically")
                imgui.SameLine()
                if imgui.Checkbox('Esp Line', EspLine) then ini.esp.espline = EspLine.v inicfg.save(ini, directIni)  end
                TextQuestion("Desenha os ossos dos Player ao Seu Redor.\n\nObs: this function is saved automatically")
                imgui.SameLine()
                if imgui.Checkbox('Esp Esqueleto', EspBox) then ini.esp.espskeleto = EspBox.v inicfg.save(ini, directIni) end
                TextQuestion("Isto eh Um Range, e ele eh Feito para que voce Mire no Player-\nPara Executar os Mods 'AUTO PM & AUTO PARA-MEDICO'.") imgui.SameLine()
                if imgui.Checkbox('Mostrar O Range', drawfov) then
                    ini.macros.autofov = drawfov.v
                    inicfg.save(ini, directIni)
                end
                if imgui.SliderInt('<- Range', fovpm, 0, 360) then
                    ini.macros.inipmfov = fovpm.v
                    inicfg.save(ini, directIni)
                end
            end
            if xtab==2 then
                if imgui.CollapsingHeader('Auto PM') == true then
                    imgui.Checkbox('Ativar Auto PM', autoPM) 
                end
                if imgui.CollapsingHeader('Auto Paramedico') then
                    imgui.Checkbox('ativar auto médico', autoMedico)
    
                    imgui.InputInt('valor vacina', valores)
                    --[[imgui.InputInt('Valor Curar', valorcurar)
                    imgui.InputInt('Valor Antibiotico', valorantibiotico)
                    imgui.InputInt('Valor Curativo', valorcurativo)]]
                end
                if imgui.CollapsingHeader('temporal') then
                   if imgui.Checkbox('Ativar Modulo de Temporal', activartemporall) then
                        ini.macros.iniacitvartemporal = activartemporall.v
                        inicfg.save(ini, directIni)
                   end
                   if imgui.SliderInt(' Tempo ', tempo, 0, 24) then
                        ini.macros.initempo = tempo.v 
                        inicfg.save(ini, directIni)
                   end
                   if imgui.SliderInt(' Hora ', hora, 0, 20) then
                        ini.macros.inihora = hora.v 
                        inicfg.save(ini, directIni)
                   end
                end
                if imgui.CollapsingHeader('auto buy') then
                    if imgui.Button(btnbotempreon, imgui.ImVec2(-1, 0))  then
                        if toggleempresa == 0 then
                            btnbotempreon = "(ON): BOT EMPRESA"
                            toggleempresa = 1
                            if togglecasa then
                                btnbotcasaon = "(OFF): BOT CASA"
                                togglecasa = 0
                            end
                        else
                            btnbotempreon = "(OFF): BOT EMPRESA"
                            toggleempresa = 0
                        end
                    end
                    if imgui.Button(btnbotcasaon, imgui.ImVec2(-1, 0)) then
                        if  togglecasa == 0 then
                            btnbotcasaon = "(ON): BOT CASA"
                            togglecasa = 1
                            if toggleempresa == 1 then
                                btnbotempreon = "(OFF): BOT EMPRESA"
                                toggleempresa = 0
                            end
                        else
                            btnbotcasaon = "(OFF): BOT CASA"
                            togglecasa = 0
                        end
                    end
                end
            end
            if xtab==3 then
                senhap.v = ini.macros.senha
                imgui.Text('Burlador:')
                if imgui.RadioButton('Modo PC', rb_select == 1) then
                    rb_select = 1 
                    ini.androidpc.rb_selectp = rb_select
                    inicfg.save(ini, directIni)
                end
                imgui.Text('Auto Login: ')
                if imgui.Checkbox('Ativar Login Automatico', autologin) then
                    ini.macros.autolg = autologin.v
                    inicfg.save(ini, directIni)
                end
                if imgui.InputText('Senha', senhap) then
                    ini.macros.senha =  senhap.v
                    inicfg.save(ini, directIni)
                end
            end  
            if xtab == 4 then
                imgui.Text('Key: '..ini.usuario.key)
                imgui.Spacing()
                imgui.Text('HWID: '..getPlayerHWID())
                imgui.Spacing()
                imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), '   -Feito por @kidosheamikuranyakish Script Pro CVR')
            end
        end
        imgui.End()
    end
end

function Visual()
    Flx,Fly  = getScreenResolution()
        for i = 0, sampGetMaxPlayerId(true) do
            if sampIsPlayerConnected(i) then
                local find, handle = sampGetCharHandleBySampPlayerId(i)
                if find then
                     if isCharOnScreen(handle) then
                        local myPos = {GetBodyPartCoordinates(3, PLAYER_PED)}
                        local enPos = {GetBodyPartCoordinates(3, handle)}
                        if (isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, true, false, true, true)) then
                            color = 0xFF00FF00
                        else
                            color = 0xFFFF0000
                        end
                        if EspLine.v then
                            local myPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, PLAYER_PED))}
                            local enPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(7, handle))}
                            renderDrawLine(myPosScreen[1],myPosScreen[2], enPosScreen[1], enPosScreen[2], 1, color)
							renderDrawPolygon(enPosScreen[1],enPosScreen[2], 6, 6, 6, 1.0, color)
                            renderDrawPolygon(myPosScreen[1],myPosScreen[2], 6, 6, 6, 1.0, color)
                        end
                        if EspBox.v then
                            local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
                            for v = 1, #t do
                                pos1 = {GetBodyPartCoordinates(t[v], handle)}
                                pos2 = {GetBodyPartCoordinates(t[v] + 1, handle)}
                                pos1Screen = {convert3DCoordsToScreen(pos1[1], pos1[2], pos1[3])}
                                pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])}
                                renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], 1, color)
                            end
                            for v = 4, 5 do
                                pos2 = {GetBodyPartCoordinates(v * 10 + 1, handle)}
                                pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])}
                                renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], 1, color)
                            end
                            local t = {53, 43, 24, 34, 6}
                            for v = 1, #t do
                                pos = {GetBodyPartCoordinates(t[v], handle)}
                                pos1Screen = {convert3DCoordsToScreen(pos[1], pos[2], pos[3])}
                            end
                        end
                    end
                end
            end
        end
    return false
end




function TextQuestion(text)
    imgui.TextDisabled('(Info)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end


function imgui.RippleButton(text, size, duration, rounding, parent_color)
       
    local function CenterTextFor2Dims(text)
        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(text)
        local height = imgui.GetWindowHeight()
        imgui.SetCursorPosX( width / 2 - calc.x / 2 )
        imgui.SetCursorPosY(height / 2 - calc.y / 2)
        imgui.Text(text)
    end

    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    if UI_RIPPLEBUTTON == nil then
        UI_RIPPLEBUTTON = {}
    end
    if not UI_RIPPLEBUTTON[text] then
        UI_RIPPLEBUTTON[text] = {animation = nil, radius = 5, mouse_coor = nil, time = nil, color = nil}
    end
    local pool = UI_RIPPLEBUTTON[text]
    local radius
   
    if rounding == nil then
        rounding = 0
    end
    if parent_color == nil then
        parent_color = imgui.GetStyle().Colors[imgui.Col.WindowBg]
    end   
    if pool["color"] == nil then
        pool["color"] = imgui.ImVec4(parent_color.x, parent_color.y, parent_color.z, parent_color.w)
    end
    if size == nil then
        local text_size = imgui.CalcTextSize(text:match("(.+)##.+") or text)
        size = imgui.ImVec2(text_size.x + 20, text_size.y + 20)
    end
    if size.x > size.y then
        radius = size.x
        if duration == nil then duration = size.x / 64 end
    else
        radius = size.y
        if duration == nil then duration = size.y / 64 end
    end
    imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.GetStyle().Colors[imgui.Col.Button])
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0,0))
    imgui.PushStyleVar(imgui.StyleVar.ChildWindowRounding, rounding)
    imgui.BeginChild("##ripple effect" .. text, imgui.ImVec2(size.x, size.y), false, imgui.WindowFlags.NoScrollbar)
   
        local draw_list = imgui.GetWindowDrawList()
        if pool["animation"] and pool["radius"] <= radius * 2.8125 then
            draw_list:AddCircleFilled(pool["mouse_coor"], pool["radius"], imgui.GetColorU32(imgui.ImVec4(1, 1, 1, 0.6)), 64)
            pool["radius"] = pool["radius"] + (3 * duration)
            pool["time"] = os.clock()
        elseif pool["animation"] and pool["radius"] >= radius * 2.8125 then
            if bringVec4To(imgui.ImVec4(1, 1, 1, 0.6), imgui.ImVec4(1, 1, 1, 0), pool["time"], 1).w ~= 0 then                  
                draw_list:AddCircleFilled(pool["mouse_coor"], pool["radius"], imgui.GetColorU32(imgui.ImVec4(1, 1, 1, bringVec4To(imgui.ImVec4(1, 1, 1, 0.6), imgui.ImVec4(1, 1, 1, 0), pool["time"], 1).w)), 64)
            else
                pool["animation"] = false
            end
        elseif not pool["animation"] and pool["radius"] >= radius * 2.8125 then
            pool["animation"] = false
            pool["radius"] = 5
            pool["time"] = nil
        end
        if rounding ~= 0 then               
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y)
            )
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + rounding)
            )
            draw_list:PathArcTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + rounding,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + rounding), rounding, -3, -1.5, 64
            )
           
            draw_list:PathFillConvex(imgui.GetColorU32(pool["color"]))
            draw_list:PathClear()
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + size.x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y)
            )
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + size.x - rounding,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y)
            )
            draw_list:PathArcTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + size.x - rounding,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + rounding), rounding, -1.5, 0, 64
            )
            draw_list:PathFillConvex(imgui.GetColorU32(pool["color"]))
            draw_list:PathClear()
           
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + size.y)
            )
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + size.y - rounding)
            )
            draw_list:PathArcTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + rounding,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + size.y - rounding), rounding, 3, 1.5, 64
            )
            draw_list:PathFillConvex(imgui.GetColorU32(pool["color"]))
            draw_list:PathClear()
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + size.x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + size.y)
            )
            draw_list:PathLineTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + size.x,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + size.y - rounding)
            )
            draw_list:PathArcTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + size.x - rounding,
                imgui.GetCursorPos().y + imgui.GetWindowPos().y + size.y - rounding), rounding, 0, 1.5, 64
            )
            draw_list:PathFillConvex(imgui.GetColorU32(pool["color"]))
            draw_list:PathClear()
        end
        CenterTextFor2Dims(text:match("(.+)##.+") or text)
    imgui.EndChild()
    imgui.PopStyleColor()
    imgui.PopStyleVar(2)
   
   
    imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x, imgui.GetCursorPos().y + 10))
    if imgui.IsItemClicked() then
            pool["animation"] = true
            pool["radius"] = 5
            pool["mouse_coor"] = imgui.GetMousePos()
            return true
    end
end


function imgui.BetterInput(name, hint_text, buffer, color, text_color, width)

    ----==| Локальные фунцкии, использованные в этой функции. |==----

    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end


    ----==| Изменение местоположения Imgui курсора, чтобы подсказка при анимации отображалась корректно. |==----

    imgui.SetCursorPosY(imgui.GetCursorPos().y + (imgui.CalcTextSize(hint_text).y * 0.7))


    ----==| Создание шаблона, для корректной работы нескольких таких виджетов. |==----

    if UI_BETTERINPUT == nil then
        UI_BETTERINPUT = {}
    end
    if not UI_BETTERINPUT[name] then
        UI_BETTERINPUT[name] = {buffer = buffer or imgui.ImBuffer(256), width = nil,
        hint = {
            pos = nil,
            old_pos = nil,
            scale = nil
        },
        color = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        old_color = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        active = {false, nil}, inactive = {true, nil}
    }
    end

    local pool = UI_BETTERINPUT[name] -- локальный список переменных для одного виджета


    ----==| Проверка и присваивание значений нужных переменных и аргументов. |==----
    
    if color == nil then
        color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    end

    if width == nil then
        pool["width"] = imgui.CalcTextSize(hint_text).x + 50
        if pool["width"] < 150 then
            pool["width"] = 150
        end
    else
        pool["width"] = width
    end

    if pool["hint"]["scale"] == nil then
        pool["hint"]["scale"] = 1.0
    end

    if pool["hint"]["pos"] == nil then
        pool["hint"]["pos"] = imgui.ImVec2(imgui.GetCursorPos().x, imgui.GetCursorPos().y)
    end

    if pool["hint"]["old_pos"] == nil then
        pool["hint"]["old_pos"] = imgui.GetCursorPos().y
    end


    ----==| Изменение стилей под параметры виджета. |==----

    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(1, 1, 1, 0))
    imgui.PushStyleColor(imgui.Col.Text, text_color or imgui.ImVec4(1, 1, 1, 1))
    imgui.PushStyleColor(imgui.Col.TextSelectedBg, color)
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(0, imgui.GetStyle().FramePadding.y))
    imgui.PushItemWidth(pool["width"])


    ----==| Получение Imgui Draw List текущего окна. |==----

    local draw_list = imgui.GetWindowDrawList()


    ----==| Добавление декоративной линии под виджет. |==----

    draw_list:AddLine(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
    imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
    imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + pool["width"],
    imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
    imgui.GetColorU32(pool["color"]), 2.0)


    ----==| Само поле ввода. |==----

    imgui.InputText("##" .. name, pool["buffer"])


    ----==| Переключатель состояний виджета. |==----

    if not imgui.IsItemActive() then
        if pool["inactive"][2] == nil then pool["inactive"][2] = os.clock() end
        pool["inactive"][1] = true
        pool["active"][1] = false
        pool["active"][2] = nil

    elseif imgui.IsItemActive() or imgui.IsItemClicked() then
        pool["inactive"][1] = false
        pool["inactive"][2] = nil
        if pool["active"][2] == nil then pool["active"][2] = os.clock() end
        pool["active"][1] = true
    end
    
    ----==| Изменение цвета; размера и позиции подсказки по состоянию. |==----

    if pool["inactive"][1] and #pool["buffer"].v == 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 1.0, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"], pool["inactive"][2], 0.25)
        
    elseif pool["inactive"][1] and #pool["buffer"].v > 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["inactive"][2], 0.25)

    elseif pool["active"][1] and #pool["buffer"].v == 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)

    elseif pool["active"][1] and #pool["buffer"].v > 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)
    end   
    imgui.SetWindowFontScale(pool["hint"]["scale"])
    
    
    ----==| Сама подсказка с анимацией. |==----

    draw_list:AddText(imgui.ImVec2(pool["hint"]["pos"].x + imgui.GetWindowPos().x + imgui.GetStyle().FramePadding.x,
    pool["hint"]["pos"].y + imgui.GetWindowPos().y + imgui.GetStyle().FramePadding.y),
    imgui.GetColorU32(pool["color"]),
    hint_text)


    ----==| Возвращение стилей в свой первоначальный вид. |==----

    imgui.SetWindowFontScale(1.0)
    imgui.PopItemWidth()
    imgui.PopStyleColor(3)
    imgui.PopStyleVar()
end



function imgui.CenterText(text)
	imgui.SetCursorPosX((imgui.GetWindowSize().x / 2) - (imgui.CalcTextSize(text).x / 2))
	imgui.Text(text)
end

function imgui.centerSlider(titulo, cmd, minimo, maximo)
    imgui.SetCursorPosX((imgui.GetWindowSize().x / 5) - (imgui.CalcTextSize(titulo).x / 5))
    imgui.SliderInt(titulo, cmd, minimo, maximo)
end



function bluetheme()
    imgui.SwitchContext()
    local colors = imgui.GetStyle().Colors;
    local icol = imgui.Col
    local ImVec4 = imgui.ImVec4

    imgui.GetStyle().WindowPadding = imgui.ImVec2(8, 8)
    imgui.GetStyle().WindowRounding = 16.0
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 3)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(4, 4)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().IndentSpacing = 9.0
    imgui.GetStyle().ScrollbarSize = 1.0
    imgui.GetStyle().ScrollbarRounding = 16.0
    imgui.GetStyle().GrabMinSize = 7.0
    imgui.GetStyle().GrabRounding = 6.0
    imgui.GetStyle().ChildWindowRounding = 6.0
    imgui.GetStyle().FrameRounding = 6.0

    colors[icol.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00);
    colors[icol.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00);
    colors[icol.WindowBg]               = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.ChildWindowBg]          = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.PopupBg]                = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.Border]                 = ImVec4(0.26, 0.46, 0.82, 0.01);
    colors[icol.BorderShadow]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.FrameBg]                = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.FrameBgHovered]         = ImVec4(0.26, 0.46, 0.82, 0.88);
    colors[icol.TitleBg]                = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgActive]          = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgCollapsed]       = ImVec4(0.26, 0.46, 0.82, 1.00);

end
bluetheme()


function renderRadius(x, y, z, radius, color)
    local x1, y1 = convert3DCoordsToScreen(x-radius, y-radius, z)
    local x2, y2 = convert3DCoordsToScreen(x+radius, y-radius, z)
    if isPointOnScreen(x-radius, y-radius, z, 0) or isPointOnScreen(x+radius, y-radius, z, 0) then
        renderDrawLine(x1, y1, x2, y2, 1, color)
    end
    local x1, y1 = convert3DCoordsToScreen(x+radius, y+radius, z)
    local x2, y2 = convert3DCoordsToScreen(x-radius, y+radius, z)
    if isPointOnScreen(x+radius, y+radius, z, 0) or isPointOnScreen(x-radius, y+radius, z, 0) then
        renderDrawLine(x1, y1, x2, y2, 1, color)
    end
    local x1, y1 = convert3DCoordsToScreen(x-radius, y-radius, z)
    local x2, y2 = convert3DCoordsToScreen(x-radius, y+radius, z)
    if isPointOnScreen(x-radius, y-radius, z, 0) or isPointOnScreen(x-radius, y+radius, z, 0) then
        renderDrawLine(x1, y1, x2, y2, 1, color)
    end
    local x1, y1 = convert3DCoordsToScreen(x+radius, y+radius, z)
    local x2, y2 = convert3DCoordsToScreen(x+radius, y-radius, z)
    if isPointOnScreen(x+radius, y+radius, z, 0) or isPointOnScreen(x+radius, y-radius, z, 0) then
        renderDrawLine(x1, y1, x2, y2, 1, color)
    end
end





function GetNearestBone(handle)
    local maxDist = 20000    
    local nearestBone = -1
    bone = {42, 52, 23, 33, 3, 22, 32, 8}
    for n = 1, 8 do
        local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
        local bonePos = {GetBodyPartCoordinates(bone[n], handle)}
        local enPos = {convert3DCoordsToScreen(bonePos[1], bonePos[2], bonePos[3])}
        local distance = math.sqrt((math.pow((enPos[1] - crosshairPos[1]), 2) + math.pow((enPos[2] - crosshairPos[2]), 2)))
        if (distance < maxDist) then
            nearestBone = bone[n]
            maxDist = distance
        end 
    end
    return nearestBone
end


function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getbonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end







function GetNearestPed(fov)
    local maxDistance = 35
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    if not isCharDead(handle) then
                        local _, currentID = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                        local myPos = {getActiveCameraCoordinates()}
                        local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                        if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                        local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                        local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                        local distance = math.sqrt((math.pow(angle[1] - view[1], 2) + math.pow(angle[2] - view[2], 2))) * 57.2957795131
                        if distance > fov then check = true else check = false end
                        if not check then
                            local myPos = {getCharCoordinates(PLAYER_PED)}
                            local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                            if (distance < maxDistance) then
                                nearestPED = handle
                                maxDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end









----------- Mods Abaixo, Threads e Eticetara -----------

--[[
    local autoPM = imgui.ImBool(ini.macros.iniautopm)
    local pmautoID = imgui.ImBool(ini.macros.inipmautoID)
--]]

function module1() -- [[módulo PM]] --
    if autoPM.v then
        autoMedico.v =  false
        for i = 0, sampGetMaxPlayerId(true) do
            if sampIsPlayerConnected(i) then
                local find, handle = sampGetCharHandleBySampPlayerId(i)
                if find then
                    local minhaposicao = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, PLAYER_PED))}
                    local posiciaodovilao = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, handle))}
                    local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                    local myPos = {getActiveCameraCoordinates()}
                    local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))

                    if myPos and enPos and myPos[1] and enPos[1] and myPos[2] and enPos[2] and myPos[3] and enPos[3] then
                        local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                    else
                        return false
                    end

                    renderFontDrawText(other_font, string.format('===== TECLAS =====\n\nTecla: (1) = Abordar\nTecla: (2) = algemar\nTecla: (3) = Prender\nTecla: (4) = ver Documentos'), 20,343, 0xFFFF0000)
                    rsX, rsY = getScreenResolution()
                    if pmautoID.v then
                        if getDistanceBetweenCoords2d(posiciaodovilao[1], posiciaodovilao[2], rsX / 2, rsY / 2) <= fovpm.v then
                            if isCharInAnyCar(PLAYER_PED) then
                                if distance < 30.0 then 
                                    renderDrawLine(rsX / 2, rsY / 1, posiciaodovilao[1], posiciaodovilao[2], 1, 0xFFff004d)
                                    renderDrawPolygon(posiciaodovilao[1],posiciaodovilao[2], 6, 6, 6, 1.0, 0xFFff004d)
                                    if wasKeyPressed(vkeys.VK_1) then
                                        sampSendChat('/abordagem '..i)
                                    end
                                    if wasKeyPressed(vkeys.VK_2) then
                                        sampSendChat('/algemar '..i)
                                    end
                                    if wasKeyPressed(vkeys.VK_3) then
                                        sampSendChat('/prender '..i)
                                    end
                                     if wasKeyPressed(vkeys.VK_4) then
                                        sampSendChat('/documentos '..i)
                                    end
                                    return false
                                end
                            else
                                if distance < 6.0 then 
                                    renderDrawLine(rsX / 2, rsY / 1, posiciaodovilao[1], posiciaodovilao[2], 1, 0xFFff004d)
                                    renderDrawPolygon(posiciaodovilao[1],posiciaodovilao[2], 6, 6, 6, 1.0, 0xFFff004d)

                                    if wasKeyPressed(vkeys.VK_1) then
                                        sampSendChat('/abordagem '..i)
                                    end
                                    if wasKeyPressed(vkeys.VK_2) then
                                        sampSendChat('/algemar '..i)
                                    end
                                    if wasKeyPressed(vkeys.VK_3) then
                                        sampSendChat('/prender '..i)
                                    end
                                     if wasKeyPressed(vkeys.VK_4) then
                                        sampSendChat('/documentos '..i)
                                    end
                                   return false
                                end
                            end
                        end
                    end
                end
            end
        end
        else if autoMedico.v then
            autoPM.v =  false
            for i = 0, sampGetMaxPlayerId(true) do
                if sampIsPlayerConnected(i) then
                    local find, handle = sampGetCharHandleBySampPlayerId(i)
                    if find then
                        local minhaposicao = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, PLAYER_PED))}
                        local posiciaodovilao = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, handle))}
                        local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                        local myPos = {getActiveCameraCoordinates()}

                        if myPos and enPos and myPos[1] and enPos[1] and myPos[2] and enPos[2] and myPos[3] and enPos[3] then
                            local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                        else
                            return false
                        end

                        local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                        renderFontDrawText(other_font, string.format('===== TECLAS =====\n\nTecla: (1) = Vacinar\nTecla: (2) = Curar\nTecla: (3) = Vender Antibiotico\nTecla: (4) = Vender Curativo'), 20,343, 0xFFFF0000)
                        rsX, rsY = getScreenResolution()
                        if pmautoID.v then
                            if getDistanceBetweenCoords2d(posiciaodovilao[1], posiciaodovilao[2], rsX / 2, rsY / 2) <= fovpm.v then
                                if isCharInAnyCar(PLAYER_PED) then
                                    if distance < 30.0 then 
                                        renderDrawLine(rsX / 2, rsY / 1, posiciaodovilao[1], posiciaodovilao[2], 1, 0xFFff004d)
                                        renderDrawPolygon(posiciaodovilao[1],posiciaodovilao[2], 6, 6, 6, 1.0, 0xFFff004d)
                                        
                                        if wasKeyPressed(vkeys.VK_1) then
                                            sampSendChat(string.format('/vendervacina %d %d',i,valores.v))
                                        end
                                        if wasKeyPressed(vkeys.VK_2) then
                                            sampSendChat(string.format('/curar %d %d',i,valores.v))
                                        end
                                        if wasKeyPressed(vkeys.VK_3) then
                                            sampSendChat(string.format('/venderantibiotico %d %d',i,valores.v))
                                        end
                                        if wasKeyPressed(vkeys.VK_4) then
                                            sampSendChat(string.format('/curativo %d %d',i,valores.v))
                                        end
                                        return false
                                    end
                                else
                                    if distance < 6.0 then 
                                        renderDrawLine(rsX / 2, rsY / 1, posiciaodovilao[1], posiciaodovilao[2], 1, 0xFFff004d)
                                        renderDrawPolygon(posiciaodovilao[1],posiciaodovilao[2], 6, 6, 6, 1.0, 0xFFff004d)

                                        if wasKeyPressed(vkeys.VK_1) then
                                            sampSendChat(string.format('/vendervacina %d %d',i,valores.v))
                                        end
                                        if wasKeyPressed(vkeys.VK_2) then
                                            sampSendChat(string.format('/curar %d %d',i,valores.v))
                                        end
                                        if wasKeyPressed(vkeys.VK_3) then
                                            sampSendChat(string.format('/venderantibiotico %d %d',i,valores.v))
                                        end
                                        if wasKeyPressed(vkeys.VK_4) then
                                            sampSendChat(string.format('/curativo %d %d',i,valores.v))
                                        end
                                    return false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
   return false
end


function othersp()
    while true do
        if togglecasa == 1 then 
            sampSendChat("/comprarcasa")
            if sampIsDialogActive() then 
                sampCloseCurrentDialogWithButton(1)
            end
            wait(3500)
        end
        if toggleempresa == 1 then 
            sampSendChat("/comprarempresa")
            if sampIsDialogActive() then 
                sampCloseCurrentDialogWithButton(1)
            end
            wait(3500)
        end
        wait(10)
    end
end

function temporalsds()
    while true do
        if ini.macros.iniacitvartemporal then
            local bs = raknetNewBitStream()
            raknetBitStreamWriteInt8(bs,  ini.macros.initempo)
            raknetBitStreamWriteInt8(bs,  ini.macros.initempo)
            raknetEmulRpcReceiveBitStream(29, bs)
            raknetDeleteBitStream(bs)
            --temporal
            local bs = raknetNewBitStream()
            raknetBitStreamWriteInt8(bs, ini.macros.inihora)
            raknetEmulRpcReceiveBitStream(152, bs)
            raknetDeleteBitStream(bs)    
        end
        wait(10)
    end
end


function workpause(bool)
    if bool then
        memory.setuint8(7634870, 1)
        memory.setuint8(7635034, 1)
        memory.fill(7623723, 144, 8)
        memory.fill(5499528, 144, 6)
    else
        memory.setuint8(7634870, 0)
        memory.setuint8(7635034, 0)
        memory.hex2bin('5051FF1500838500', 7623723, 8)
        memory.hex2bin('0F847B010000', 5499528, 6)
	end
end




function sampev.onShowTextDraw(id, data)
    if data.text == "Logar" then
        if paskov == "NFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23" then

        else
            if ini.macros.autolg then
                sampAddChatMessage('Logando...', -1)
                sampSendClickTextdraw(2068)
            end
        end
    end
  --  sampAddChatMessage('altura: '..data.lineHeight..' Largura: '..data.lineWidth, -1)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if title:find('Login') then
        if paskov == "NFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23" then

        else
            if ini.macros.autolg then
                sampSendDialogResponse(id, 1 , 0, ini.macros.senha)
                sampSendClickTextdraw(71)
            end
        end
    end
    textisSHowedorNot = text
    --sampAddChatMessage('dialog Title: '..title..' Dialog Text: '..text..' BTN1 -> '..button1..' - '..button2..' <- BTN2 ', -1)
end


function sampev.onSendClientJoin(ver, mod, nick, response, authkey, clientver, unk)
    if paskov == "NFN28bh38hn0iansdifn88213n8rfb283bf9uba9uwbef9ub283bgf8u9bu9bedfu9b238fg7b7EBFUBN2UB3RBwerf23f23" then

    else
        return {ver, mod, nick, response, authkey, '0.3.7-R5', unk}
    end
end


