script_name("MedicalHelper")
script_authors("Alberto Kane")
script_description("Script for the Ministries of Health Arizona Role Play")
script_version("3.0.7")
script_properties("work-in-pause")
setver = 1

local sampfuncsNot = [[
 Не обнаружен файл SAMPFUNCS.asi в папке игры, вследствие чего
скрипту не удалось запуститься.

		Для решения проблемы:
1. Закройте игру;
2. Выключите антивирусные программы или в их настройках внесите папку игры в исключение.
• Возможные антивирусы: 
Защитник Windows, McAfree, Avast, 360 Total и другие.
О том как внести в исключение папку воспользуйтесь интернетом.
3. Произведите повторную установку скрипта.

При возникновении проблем обращайтесь в сообщения:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
]]

local errorText = [[
		  Внимание! 
Не обнаружены некоторые важные файлы для работы скрипта.
В следствии чего, скрипт перестал работать.
	Список необнаруженных файлов:
		%s

		Для решения проблемы:
1. Закройте игру;
2. Выключите антивирусные программы или в их настройках внесите папку игры в исключение.
• Возможные антивирусы: 
Защитник Windows, McAfree, Avast, 360 Total и другие.
О том как внести в исключение папку воспользуйтесь интернетом.
3. Произведите повторную установку скрипта.

При возникновении проблем обращайтесь в сообщения:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
]]

if doesFileExist(getWorkingDirectory().."/lib/rkeysMH.lua") then
	local f = io.open(getWorkingDirectory().."/lib/rkeysMH.lua")
	f:close()
	print("{82E28C}Чтение библиотеки rkeysMH...")
else 
	local textrkeys = [[
local vkeys = require 'vkeys'

vkeys.key_names[vkeys.VK_LMENU] = "LAlt"
vkeys.key_names[vkeys.VK_RMENU] = "RAlt"
vkeys.key_names[vkeys.VK_LSHIFT] = "LShift"
vkeys.key_names[vkeys.VK_RSHIFT] = "RShift"
vkeys.key_names[vkeys.VK_LCONTROL] = "LCtrl"
vkeys.key_names[vkeys.VK_RCONTROL] = "RCtrl"

local tHotKey = {}
local tKeyList = {}
local tKeysCheck = {}
local iCountCheck = 0
local tBlockKeys = {[vkeys.VK_LMENU] = true, [vkeys.VK_RMENU] = true, [vkeys.VK_RSHIFT] = true, [vkeys.VK_LSHIFT] = true, [vkeys.VK_LCONTROL] = true, [vkeys.VK_RCONTROL] = true}
local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true}
local tBlockNext = {}
local module = {}
module._VERSION = "1.0.7"
module._MODKEYS = tModKeys
module._LOCKKEYS = false

local function getKeyNum(id)
   for k, v in pairs(tKeyList) do
      if v == id then
         return k
      end
   end
   return 0
end

function module.blockNextHotKey(keys)
   local bool = false
   if not module.isBlockedHotKey(keys) then
      tBlockNext[#tBlockNext + 1] = keys
      bool = true
   end
   return bool
end

function module.isHotKeyHotKey(keys, keys2)
   local bool
   for k, v in pairs(keys) do
      local lBool = true
      for i = 1, #keys2 do
         if v ~= keys2[i] then
            lBool = false
            break
         end
      end
      if lBool then
         bool = true
         break
      end
   end
   return bool
end


function module.isBlockedHotKey(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tBlockNext) do
      if module.isHotKeyHotKey(keys, v) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.unBlockNextHotKey(keys)
   local result = false
   local count = 0
   while module.isBlockedHotKey(keys) do
      local _, id = module.isBlockedHotKey(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   for k, v in pairs(tBlockNext) do
      tBlockNext[id] = v
      id = id + 1
   end
   return result, count
end

function module.isKeyModified(id)
   return (tModKeys[id] or false) or (tBlockKeys[id] or false)
end

function module.isModifiedDown()
   local bool = false
   for k, v in pairs(tModKeys) do
      if isKeyDown(k) then
         bool = true
         break
      end
   end
   return bool
end

lua_thread.create(function ()
   while true do
      wait(0)
      local tDownKeys = module.getCurrentHotKey()
      for k, v in pairs(tHotKey) do
         if #v.keys > 0 then
            local bool = true
            for i = 1, #v.keys do
               if i ~= #v.keys and (getKeyNum(v.keys[i]) > getKeyNum(v.keys[i + 1]) or getKeyNum(v.keys[i]) == 0) then
                  bool = false
                  break
               elseif i == #v.keys and (v.pressed and not wasKeyPressed(v.keys[i]) or not v.pressed and not isKeyDown(v.keys[i])) or (#v.keys == 1 and module.isModifiedDown()) then
                  bool = false
                  break
               end
            end
            if bool and ((module.onHotKey and module.onHotKey(k, v.keys) ~= false) or module.onHotKey == nil) then
               local result, id = module.isBlockedHotKey(v.keys)
               if not result then
                  v.callback(k, v.keys)
               else
                  tBlockNext[id] = nil
               end
            end
         end
      end
   end
end)

function module.registerHotKey(keys, pressed, callback)
   tHotKey[#tHotKey + 1] = {keys = keys, pressed = pressed, callback = callback}
   return true, #tHotKey
end

function module.getAllHotKey()
   return tHotKey
end

function module.unRegisterHotKey(keys)

   local result = false
   local count = 0
   while module.isHotKeyDefined(keys) do
      local _, id = module.isHotKeyDefined(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   local tNewHotKey = {}
   for k, v in pairs(tHotKey) do
      tNewHotKey[id] = v
      id = id + 1
   end
   tHotKey = tNewHotKey
   return result, count
 
end

function module.isHotKeyDefined(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tHotKey) do
      if module.isHotKeyHotKey(keys, v.keys) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.getKeysName(keys)
   local tKeysName = {}
   for k, v in ipairs(keys) do
      tKeysName[k] = vkeys.id_to_name(v)
   end
   return tKeysName
end

function module.getCurrentHotKey(type)
   local type = type or 0
   local tCurKeys = {}
   for k, v in pairs(vkeys) do
      if tBlockKeys[v] == nil then
         local num, down = getKeyNum(v), isKeyDown(v)
         if down and num == 0 then
            tKeyList[#tKeyList + 1] = v
         elseif num > 0 and not down then
            tKeyList[num] = nil
         end
      end
   end
   local i = 1
   for k, v in pairs(tKeyList) do
      tCurKeys[i] = type == 0 and v or vkeys.id_to_name(v)
      i = i + 1
   end
   return tCurKeys
end

return module

]]
	local f = io.open(getWorkingDirectory().."/lib/rkeysMH.lua", "w")
	print("{F54A4A}Ошибка. Отсутствует библиотека rkeysMH {82E28C}Создание библиотеки rkeysMH..")
	f:write(textrkeys)
	f:close()			
end

local files = {
"/lib/imgui.lua",
"/lib/samp/events.lua",
"/lib/rkeysMH.lua",
"/lib/faIcons.lua",
"/lib/crc32ffi.lua",
"/lib/bitex.lua",
"/lib/MoonImGui.dll",
"/lib/matrix3x3.lua"
}
local nofiles = {}
for i,v in ipairs(files) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(nofiles, v)
	end
end

local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]

require "lib.sampfuncs"
require "lib.moonloader"
local mem = require "memory"
local vkeys = require "vkeys"
local encoding = require "encoding"
encoding.default = "CP1251"
local u8 = encoding.UTF8
local dlstatus = require("moonloader").download_status

local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

if not doesFileExist(getGameDirectory().."/SAMPFUNCS.asi") then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, sampfuncsNot, "MedicalHelper", 0x00000030 + 0x00010000) 
end
if #nofiles > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, errorText:format(table.concat(nofiles, "\n\t\t")), "MedicalHelper", 0x00000030 + 0x00010000) 
end

local res, hook = pcall(require, 'lib.samp.events')
assert(res, "Библиотека SAMP Event не найдена")
----------------------------------------
local res, imgui = pcall(require, "imgui")
assert(res, "Библиотека Imgui не найдена")
-----------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, "Библиотека faIcons не найдена")
-----------------------------------------
local res, rkeys = pcall(require, 'rkeysMH')
assert(res, "Библиотека Rkeys не найдена")
vkeys.key_names[vkeys.VK_RBUTTON] = "RBut"
vkeys.key_names[vkeys.VK_XBUTTON1] = "XBut1"
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'


--> Файловая система
local deck = getFolderPath(0) --> Деск
local doc = getFolderPath(5) --> Скрины
local dirml = getWorkingDirectory() ---> Мун
local dirGame = getGameDirectory()
local scr = thisScript()
local font = renderCreateFont("Trebuchet MS", 14, 5)
local fontPD = renderCreateFont("Trebuchet MS", 12, 5)
local fontH =  renderGetFontDrawHeight(font)
local sx, sy = getScreenResolution()

local mainWin	= imgui.ImBool(false) --> Гл.окно
local paramWin = imgui.ImBool(false) --> Окно параметров
local actingOutWind = imgui.ImBool(false) ---> Окно редактора отыгровки
local spurBig = imgui.ImBool(false) --> Большое окно шпоры
local sobWin = imgui.ImBool(false) --> Окно собески
local depWin = imgui.ImBool(false) --> Окно департамента
local updWin = imgui.ImBool(false) --> Окно обновлений
local mcEditWin = imgui.ImBool(false) --> Окно редактора мед. карты
local iconwin	= imgui.ImBool(false)
local profbWin = imgui.ImBool(false)
local select_menu = {true, false, false, false, false, false, false, false, false} --> Для переключения меню

--> Транслитизаторные переменные
local trstl1 = {['ph'] = 'ф',['Ph'] = 'Ф',['Ch'] = 'Ч',['ch'] = 'ч',['Th'] = 'Т',['th'] = 'т',['Sh'] = 'Ш',['sh'] = 'ш', ['ea'] = 'и',['Ae'] = 'Э',['ae'] = 'э',['size'] = 'сайз',['Jj'] = 'Джейджей',['Whi'] = 'Вай',['lack'] = 'лэк',['whi'] = 'вай',['Ck'] = 'К',['ck'] = 'к',['Kh'] = 'Х',['kh'] = 'х',['hn'] = 'н',['Hen'] = 'Ген',['Zh'] = 'Ж',['zh'] = 'ж',['Yu'] = 'Ю',['yu'] = 'ю',['Yo'] = 'Ё',['yo'] = 'ё',['Cz'] = 'Ц',['cz'] = 'ц', ['ia'] = 'я', ['ea'] = 'и',['Ya'] = 'Я', ['ya'] = 'я', ['ove'] = 'ав',['ay'] = 'эй', ['rise'] = 'райз',['oo'] = 'у', ['Oo'] = 'У', ['Ee'] = 'И', ['ee'] = 'и', ['Un'] = 'Ан', ['un'] = 'ан', ['Ci'] = 'Ци', ['ci'] = 'ци', ['yse'] = 'уз', ['cate'] = 'кейт', ['eow'] = 'яу', ['rown'] = 'раун', ['yev'] = 'уев', ['Babe'] = 'Бэйби', ['Jason'] = 'Джейсон', ['liy'] = 'лий', ['ane'] = 'ейн', ['ame'] = 'ейм'}
local trstl = {['B'] = 'Б',['Z'] = 'З',['T'] = 'Т',['Y'] = 'Й',['P'] = 'П',['J'] = 'Дж',['X'] = 'Кс',['G'] = 'Г',['V'] = 'В',['H'] = 'Х',['N'] = 'Н',['E'] = 'Е',['I'] = 'И',['D'] = 'Д',['O'] = 'О',['K'] = 'К',['F'] = 'Ф',['y`'] = 'ы',['e`'] = 'э',['A'] = 'А',['C'] = 'К',['L'] = 'Л',['M'] = 'М',['W'] = 'В',['Q'] = 'К',['U'] = 'А',['R'] = 'Р',['S'] = 'С',['zm'] = 'зьм',['h'] = 'х',['q'] = 'к',['y'] = 'и',['a'] = 'а',['w'] = 'в',['b'] = 'б',['v'] = 'в',['g'] = 'г',['d'] = 'д',['e'] = 'е',['z'] = 'з',['i'] = 'и',['j'] = 'ж',['k'] = 'к',['l'] = 'л',['m'] = 'м',['n'] = 'н',['o'] = 'о',['p'] = 'п',['r'] = 'р',['s'] = 'с',['t'] = 'т',['u'] = 'у',['f'] = 'ф',['x'] = 'x',['c'] = 'к',['``'] = 'ъ',['`'] = 'ь',['_'] = ' '}
local trsliterCMD = {['q'] = 'й',['w'] = 'ц',['e'] = 'у',['r'] = 'к',['t'] = 'е',['y'] = 'н',['u'] = 'г',['i'] = 'ш', ['o'] = 'щ',['p'] = 'з',['a'] = 'ф',['s'] = 'ы',['d'] = 'в',['f'] = 'а',['g'] = 'п',['h'] = 'р',['j'] = 'о',['k'] = 'л',['l'] = 'д',['z'] = 'я',['x'] = 'ч',['c'] = 'с',['v'] = 'м',['b'] = 'и',['n'] = 'т',['m'] = 'ь',['/'] = '.'}
local trsliterEng = {['а'] = 'a',['б'] = 'b',['в'] = 'v',['г'] = 'g',['д'] = 'd',['е'] = 'e',['ё'] = 'e',['ж'] = 'zh', ['з'] = 'z',['и'] = 'i',['й'] = 'i',['к'] = 'k',['л'] = 'l',['м'] = 'm',['н'] = 'n',['о'] = 'o',['п'] = 'p',['р'] = 'r',['с'] = 's',['т'] = 't',['у'] = 'u',['ф'] = 'f',['х'] = 'kh',['ц'] = 'ts',['ч'] = 'ch',['ш'] = 'sh',['щ'] = 'shch',['ъ'] = 'ie',['ы'] = 'y',['ь'] = '',['э'] = 'e',['ю'] = 'iu',['я'] = 'ia',['А'] = 'a',['Б'] = 'b',['В'] = 'v',['Г'] = 'g',['Д'] = 'd',['Е'] = 'e',['Ё'] = 'e',['Ж'] = 'zh', ['З'] = 'z',['И'] = 'i',['Й'] = 'i',['К'] = 'k',['Л'] = 'l',['М'] = 'm',['Н'] = 'n',['О'] = 'o',['П'] = 'p',['Р'] = 'r',['С'] = 's',['Т'] = 't',['У'] = 'u',['Ф'] = 'f',['Х'] = 'kh',['Ц'] = 'ts',['Ч'] = 'ch',['Ш'] = 'sh',['Щ'] = 'shch',['Ъ'] = 'ie',['Ы'] = 'y',['Ь'] = '',['Э'] = 'e',['Ю'] = 'iu',['Я'] = 'ia'}

--> Транслитизация и де/переКодирование ников
function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local hooks = {
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },   

    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
	  bs_io[p]['write'](bs, parameters[i])
                end
        end

    end
end

require('samp.events').onPlayerJoin = function(id, color, isNpc, nickname)
    emul_rpc('onSetPlayerName', {id, trst(nickname), true}) 
end

--> Транслитизатор
function trst(name)
if name:match('%a+') then
        for k, v in pairs(trstl1) do
            name = name:gsub(k, v) 
        end
		for k, v in pairs(trstl) do
            name = name:gsub(k, v) 
        end
        return name
    end
 return name
end

--> Главные настройки
local setting = {
	nick = "",
	teg = "",
	org = 0,
	sex = 0,
	rank = 0,
	time = false,
	timeDo = false, 
	timeTx = "",
	rac = false,
	racTx = "",
	lec = "",
	mede = {"20000", "40000", "60000", "80000"},
	upmede = {"40000", "60000", "80000", "100000"},
	rec = "",
	narko = "",
	tatu = "",
	ant = "",
	chat1 = false,
	chat2 = false,
	chat3 = false,
	chathud = false,
	arp = false,
	setver = 1,
	imageUp = false,
	imageDis = false,
	theme = 0,
	themAngle = true,
	spawn = false,
	autolec = false,
	prikol = false
}
setdepteg = {
	tegtext_one = u8"к",
	tegtext_two = u8" от ",
	tegtext_three = ":",
	tegpref_one = 0,
	tegpref_two = 2,
	prefix = {u8"ВСЕМ", u8"Пра-во", u8"ГЦЛ", u8"СТК", u8"ЦБ", u8"ЛСа", u8"СФа", u8"ТСР", u8"ФБР", u8"РКШД", u8"ЛСПД", u8"СФПД", u8"ЛВМПД", u8"ЛСМЦ", u8"СФМЦ", u8"ЛВМЦ", u8"ЧБЛС", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"ЦА", u8"МО", u8"МЗ", u8"МЮ"}
}
local buf_nick	= imgui.ImBuffer(256)
local buf_teg 	= imgui.ImBuffer(256)
local num_org		= imgui.ImInt(0)
local num_sex		= imgui.ImInt(0)
local num_dep		= imgui.ImInt(0)
local num_dep2		= imgui.ImInt(0)
local num_dep3		= imgui.ImInt(0)
local num_pref		= imgui.ImInt(0)
local num_theme		= imgui.ImInt(0)
local num_rank	= imgui.ImInt(0)
local chgName = {}
chgDepSetD = {imgui.ImBuffer(128),imgui.ImBuffer(128),imgui.ImBuffer(128)}
chgDepSetTeg = imgui.ImBuffer(128)
chgDepSetPref = imgui.ImBuffer(128)
chgCmdSet = {imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256),imgui.ImBuffer(256)}
chgCmd = {imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5),imgui.ImFloat(0.5)}
chgName.inp = imgui.ImBuffer(100)
chgName.org = {u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон"}
chgName.rank = {u8"Интерн", u8"Участковый врач", u8"Терапевт", u8"Нарколог", u8"Окулист", u8"Хирург", u8"Психолог", u8"Завед. отделением", u8"Зам.Гл.Врача", u8"Глав.Врач", u8"Министр Здравоохранения"}
list_cmd = {u8"mh", u8"r", u8"rb", u8"mb", u8"hl", u8"post", u8"mc", u8"narko", u8"recep", u8"osm", u8"dep", u8"sob", u8"tatu", u8"vig", u8"unvig", u8"muteorg", u8"unmuteorg", u8"gr", u8"inv", u8"unv", u8"time", u8"exp", u8"vac", u8"info", u8"za", u8"zd", u8"ant", u8"strah", u8"cur", u8"hall", u8"hilka", u8"shpora"}
prefix_end = {"","","","",""}

local list_org_BL = {"Больница LS", "Больница SF", "Больница LV", "Больница Jafferson"} 
local list_org	= {u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон"}
local list_org_en = {"Los-Santos Medical Center","San-Fierro Medical Center","Las-Venturas Medical Center","Jafferson Medical Center"}
local list_sex	= {fa.ICON_MALE .. u8" Мужской", fa.ICON_FEMALE .. u8" Женский"--[[, fa.ICON_TRANSGENDER_ALT .. u8" Другой"]]} 
local list_rank	= {u8"Интерн", u8"Участковый врач", u8"Терапевт", u8"Нарколог", u8"Окулист", u8"Хирург", u8"Психолог", u8"Завед. отделением", u8"Зам.Гл.Врача", u8"Глав.Врач", u8"Министр Здравоохранения"}
local list_theme = {u8"Пурпурная", u8"Синяя", u8"Красная", u8"Голубая", u8"Оранжевая", u8"Чёрно-белая", u8"Зелёная", u8"Монохром"}
local list_dep_pref_one	= {u8"Тег к обращаемому \nсо скобками",u8"Тег к обращаемому \nбез скобок",u8"Ваш тег \nсо скобками",u8"Ваш тег \nбез скобок",u8"Без тега"}
local list_dep_pref_two	= {u8"Тег к обращаемому \nсо скобками",u8"Тег к обращаемому \nбез скобок",u8"Ваш тег \nсо скобками",u8"Ваш тег \nбез скобок",u8"Без тега"} 
--> Чат
local cb_chat1	= imgui.ImBool(false)
local cb_chat2	= imgui.ImBool(false)
local cb_chat3	= imgui.ImBool(false)
local cb_hud		= imgui.ImBool(false)
local hudPing = false
local cb_hudTime	= imgui.ImBool(false)
local theme_Angle = imgui.ImBool(true)
local accept_spawn = imgui.ImBool(false)
local accept_autolec = imgui.ImBool(false)
--> Время
local cb_time		= imgui.ImBool(false)
local cb_timeDo	= imgui.ImBool(false)
local cb_rac		= imgui.ImBool(false)
local buf_time	= imgui.ImBuffer(256)
local buf_rac		= imgui.ImBuffer(256)
--> Цены
local buf_lec		= imgui.ImBuffer(10);
local buf_mede = {imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10)}
local buf_upmede = {imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10)}
local buf_rec		= imgui.ImBuffer(10);
local buf_narko	= imgui.ImBuffer(10);
local buf_tatu	= imgui.ImBuffer(10);
local buf_ant	= imgui.ImBuffer(10);
buf_mede[1].v = "20000"
buf_mede[2].v = "40000"
buf_mede[3].v = "60000"
buf_mede[4].v = "80000"
buf_upmede[1].v = "40000"
buf_upmede[2].v = "60000"
buf_upmede[3].v = "80000"
buf_upmede[4].v = "100000"
local lectime = false
local statusvac = false
local errorspawn = false
local prikol = true
--> Изображения
local cb_imageUp	= imgui.ImBool(false)
local cb_imageDis	= imgui.ImBool(false)
--> Шпора
local spur = {
text = imgui.ImBuffer(51200),
name = imgui.ImBuffer(256),
list = {},
select_spur = -1,
edit = false
}

--> Для команды бинда
function translatizator(name)
	if name:match('%a+') then
        for k, v in pairs(trsliterCMD) do
            name = name:gsub(k, v) 
        end
        return name
    end
 return name
end
function translatizatorEng(name)
	if name:match('%A+') then
        for k, v in pairs(trsliterEng) do
            name = name:gsub(k, v)
        end
        return name
    end
 return name
end

--> Функции главных настроек
local PlayerSet = {}
function PlayerSet.name()
	if buf_nick.v ~= "" then
		return buf_nick.v
	else
		return u8"Не указаны"
	end
end
function PlayerSet.org()
	return chgName.org[num_org.v+1]
end
function PlayerSet.rank()
	return chgName.rank[num_rank.v+1]
end
function PlayerSet.sex()
	return list_sex[num_sex.v+1]
end
function PlayerSet.dep()
	return list_dep_pref_one[num_dep.v+1]
end
function PlayerSet.depTwo()
	return setdepteg.prefix[num_org.v+14]
end
function PlayerSet.theme()
	return list_theme[num_theme.v+1]
end
function DepTxtEnd(textbox)
	if setdepteg.tegtext_one ~= "" then
		spacetext_one = setdepteg.tegtext_one.." "
	else
		spacetext_one = ""
	end
	if setdepteg.tegtext_two ~= "" then
		if setdepteg.tegpref_two ~= 4 then
			spacetext_two = setdepteg.tegtext_two
		else
			spacetext_two = setdepteg.tegtext_two.." "
		end
	elseif setdepteg.tegpref_one ~= 4 and setdepteg.tegpref_two ~= 4 then
		spacetext_two = " "
	elseif setdepteg.tegpref_one < 5 or setdepteg.tegpref_two < 5 then
		spacetext_two = ""
	end
	if setdepteg.tegtext_three ~= "" then
		spacetext_three = setdepteg.tegtext_three.." "
	elseif setdepteg.tegpref_two < 4 then
		spacetext_three = " "
	else
		spacetext_three = ""
	end
	if setdepteg.tegtext_two == "" and setdepteg.tegtext_three == "" and setdepteg.tegpref_one < 4 and setdepteg.tegpref_two == 4 then
		spacetext_three = " "
	end
	if select_depart == 2 then
		if setdepteg.tegpref_one < 2 then
			if setdepteg.tegpref_one == 0 then
				oneteg = "[".. setdepteg.prefix[num_dep3.v + 1] .."]"
			else
				oneteg = setdepteg.prefix[num_dep3.v + 1]
			end
		elseif setdepteg.tegpref_one == 4 then
			oneteg = u8""
		elseif setdepteg.tegpref_one ~= 4 then
			if setdepteg.tegpref_one == 2 then
				if num_rank.v == 10 then
					oneteg = "[".. setdepteg.prefix[23] .."]"
				else
					oneteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
				end
			else
				if num_rank.v == 10 then
					oneteg = setdepteg.prefix[23]
				else
					oneteg = setdepteg.prefix[num_org.v + 14]
				end
			end
		end
		if setdepteg.tegpref_two < 2 then
			if setdepteg.tegpref_two == 0 then
				twoteg = "[".. setdepteg.prefix[num_dep3.v + 1] .."]"
			else
				twoteg = setdepteg.prefix[num_dep3.v + 1]
			end
		elseif setdepteg.tegpref_two == 4 then
			twoteg = u8""
		elseif setdepteg.tegpref_two ~= 4 then
			if setdepteg.tegpref_two == 2 then
				if num_rank.v == 10 then
					twoteg = "[".. setdepteg.prefix[23] .."]"
				else
					twoteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
				end
			else
				if num_rank.v == 10 then
					twoteg = setdepteg.prefix[23]
				else
					twoteg = setdepteg.prefix[num_org.v + 14]
				end
			end
		end
	else
		if setdepteg.tegpref_one < 2 then
			if setdepteg.tegpref_one == 0 then
				oneteg = "[".. setdepteg.prefix[1] .."]"
			else
				oneteg = setdepteg.prefix[1]
			end
		elseif setdepteg.tegpref_one == 4 then
			oneteg = u8""
		elseif setdepteg.tegpref_one ~= 4 then
			if setdepteg.tegpref_one == 2 then
				oneteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			else
				oneteg = setdepteg.prefix[num_org.v + 14]
			end
		end
		if setdepteg.tegpref_two < 2 then
			if setdepteg.tegpref_two == 0 then
				twoteg = "[".. setdepteg.prefix[1] .."]"
			else
				twoteg = setdepteg.prefix[1]
			end
		elseif setdepteg.tegpref_two == 4 then
			twoteg = u8""
		elseif setdepteg.tegpref_two ~= 4 then
			if setdepteg.tegpref_two == 2 then
				twoteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			else
				twoteg = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	textbox = spacetext_one.. oneteg ..spacetext_two.. twoteg ..spacetext_three
	return textbox
end
function DepTxtEndSetting(textbox)
	if chgDepSetD[1].v ~= "" then
		spacetext_oneset = chgDepSetD[1].v.." "
	else
		spacetext_oneset = ""
	end
	if chgDepSetD[2].v ~= "" then
		if num_dep2.v ~= 4 then
			spacetext_twoset = chgDepSetD[2].v
		else
			spacetext_twoset = chgDepSetD[2].v.." "
		end
	elseif num_dep.v ~= 4 and num_dep2.v ~= 4 then
		spacetext_twoset = " "
	elseif num_dep.v < 5 or num_dep2.v < 5 then
		spacetext_twoset = ""
	end
	if chgDepSetD[3].v ~= "" then
		spacetext_threeset = chgDepSetD[3].v.." "
	elseif num_dep2.v < 4 then
		spacetext_threeset = " "
	else
		spacetext_threeset = ""
	end
	if chgDepSetD[2].v == "" and chgDepSetD[3].v == "" and num_dep.v < 4 and num_dep2.v == 4 then
		spacetext_threeset = " "
	end
	if num_dep.v < 2 then
		if num_dep.v == 0 then
			onetegset = "[".. setdepteg.prefix[9] .."]"
		else
			onetegset = setdepteg.prefix[9]
		end
	elseif num_dep.v == 4 then
		onetegset = u8""
	elseif num_dep.v ~= 4 then
		if num_dep.v == 2 then
			if num_rank.v == 10 then
				onetegset = "[".. setdepteg.prefix[23] .."]"
			else
				onetegset = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			end
		else
			if num_rank.v == 10 then
				onetegset = setdepteg.prefix[23]
			else
				onetegset = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	if num_dep2.v < 2 then
		if num_dep2.v == 0 then
			twotegset = "[".. setdepteg.prefix[9] .."]"
		else
			twotegset = setdepteg.prefix[9]
		end
	elseif num_dep2.v == 4 then
		twotegset = u8""
	elseif num_dep2.v ~= 4 then
		if num_dep2.v == 2 then
			if num_rank.v == 10 then
				twotegset = "[".. setdepteg.prefix[23] .."]"
			else
				twotegset = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			end
		else
			if num_rank.v == 10 then
				twotegset = setdepteg.prefix[23]
			else
				twotegset = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	textbox = spacetext_oneset.. onetegset ..spacetext_twoset.. twotegset ..spacetext_threeset
	return textbox
end
--> Для биндера
local selected_cmd = 1
local currentKey	= {"",{}}
local cb_RBUT		= imgui.ImBool(false)
local cb_x1		= imgui.ImBool(false)
local cb_x2		= imgui.ImBool(false)
local isHotKeyDefined = false
local p_open = false
local helpd = {}
helpd.exp = imgui.ImBuffer(256)
binder = {
	list = {},
	select_bind,
	edit = false,
	sleep = imgui.ImFloat(0.5),
	name = imgui.ImBuffer(256),
	cmd = imgui.ImBuffer(256),
	text = imgui.ImBuffer(51200),
	key = {}
}
helpd.exp.v =  u8[[
{dialog}
[name]=Выдача мед.карты
[1]=Полностью здоровый
Отыгровка №1
Отыгровка №2
[2]=Имеются отклонения 
Отыгровка №1
Отыгровка №2
{dialogEnd}
]]
helpd.key = {
	{k = "MBUTTON", n = 'Кнопка мыши'},
	{k = "XBUTTON1", n = 'Боковая кнопка мыши 1'},
	{k = "XBUTTON2", n = 'Боковая кнопка мыши 2'},
	{k = "BACK", n = 'Backspace'},
	{k = "SHIFT", n = 'Shift'},
	{k = "CONTROL", n = 'Ctrl'},
	{k = "PAUSE", n = 'Pause'},
	{k = "CAPITAL", n = 'Caps Lock'},
	{k = "SPACE", n = 'Space'},
	{k = "PRIOR", n = 'Page Up'},
	{k = "NEXT", n = 'Page Down'},
	{k = "END", n = 'End'},
	{k = "HOME", n = 'Home'},
	{k = "LEFT", n = 'Стрелка влево'},
	{k = "UP", n = 'Стрелка вверх'},
	{k = "RIGHT", n = 'Стрелка вправо'},
	{k = "DOWN", n = 'Стрелка вниз'},
	{k = "SNAPSHOT", n = 'Print Screen'},
	{k = "INSERT", n = 'Insert'},
	{k = "DELETE", n = 'Delete'},
	{k = "0", n = '0'},
	{k = "1", n = '1'},
	{k = "2", n = '2'},
	{k = "3", n = '3'},
	{k = "4", n = '4'},
	{k = "5", n = '5'},
	{k = "6", n = '6'},
	{k = "7", n = '7'},
	{k = "8", n = '8'},
	{k = "9", n = '9'},
	{k = "A", n = 'A'},
	{k = "B", n = 'B'},
	{k = "C", n = 'C'},
	{k = "D", n = 'D'},
	{k = "E", n = 'E'},
	{k = "F", n = 'F'},
	{k = "G", n = 'G'},
	{k = "H", n = 'H'},
	{k = "I", n = 'I'},
	{k = "J", n = 'J'},
	{k = "K", n = 'K'},
	{k = "L", n = 'L'},
	{k = "M", n = 'M'},
	{k = "N", n = 'N'},
	{k = "O", n = 'O'},
	{k = "P", n = 'P'},
	{k = "Q", n = 'Q'},
	{k = "R", n = 'R'},
	{k = "S", n = 'S'},
	{k = "T", n = 'T'},
	{k = "U", n = 'U'},
	{k = "V", n = 'V'},
	{k = "W", n = 'W'},
	{k = "X", n = 'X'},
	{k = "Y", n = 'Y'},
	{k = "Z", n = 'Z'},
	{k = "NUMPAD0", n = 'Numpad 0'},
	{k = "NUMPAD1", n = 'Numpad 1'},
	{k = "NUMPAD2", n = 'Numpad 2'},
	{k = "NUMPAD3", n = 'Numpad 3'},
	{k = "NUMPAD4", n = 'Numpad 4'},
	{k = "NUMPAD5", n = 'Numpad 5'},
	{k = "NUMPAD6", n = 'Numpad 6'},
	{k = "NUMPAD7", n = 'Numpad 7'},
	{k = "NUMPAD8", n = 'Numpad 8'},
	{k = "NUMPAD9", n = 'Numpad 9'},
	{k = "MULTIPLY", n = 'Numpad *'},
	{k = "ADD", n = 'Numpad +'},
	{k = "SEPARATOR", n = 'Separator'},
	{k = "SUBTRACT", n = 'Numpad -'},
	{k = "DECIMAL", n = 'Numpad .'},
	{k = "DIVIDE", n = 'Numpad /'},
	{k = "F1", n = 'F1'},
	{k = "F2", n = 'F2'},
	{k = "F3", n = 'F3'},
	{k = "F4", n = 'F4'},
	{k = "F5", n = 'F5'},
	{k = "F6", n = 'F6'},
	{k = "F7", n = 'F7'},
	{k = "F8", n = 'F8'},
	{k = "F9", n = 'F9'},
	{k = "F10", n = 'F10'},
	{k = "F11", n = 'F11'},
	{k = "F12", n = 'F12'},
	{k = "F13", n = 'F13'},
	{k = "F14", n = 'F14'},
	{k = "F15", n = 'F15'},
	{k = "F16", n = 'F16'},
	{k = "F17", n = 'F17'},
	{k = "F18", n = 'F18'},
	{k = "F19", n = 'F19'},
	{k = "F20", n = 'F20'},
	{k = "F21", n = 'F21'},
	{k = "F22", n = 'F22'},
	{k = "F23", n = 'F23'},
	{k = "F24", n = 'F24'},
	{k = "LSHIFT", n = 'Левый Shift'},
	{k = "RSHIFT", n = 'Правый Shift'},
	{k = "LCONTROL", n = 'Левый Ctrl'},
	{k = "RCONTROL", n = 'Правый Ctrl'},
	{k = "LMENU", n = 'Левый Alt'},
	{k = "RMENU", n = 'Правый Alt'},
	{k = "OEM_1", n = '; :'},
	{k = "OEM_PLUS", n = '= +'},
	{k = "OEM_MINUS", n = '- _'},
	{k = "OEM_COMMA", n = ', <'},
	{k = "OEM_PERIOD", n = '. >'},
	{k = "OEM_2", n = '/ ?'},
	{k = "OEM_4", n = ' { '},
	{k = "OEM_6", n = ' } '},
	{k = "OEM_5", n = '\\ |'},
	{k = "OEM_8", n = '! §'},
	{k = "OEM_102", n = '> <'}
}
--> Собеседование
local sobes = {
	input = imgui.ImBuffer(101),
	player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1},
	selID = imgui.ImBuffer(5),
	logChat = {},
	nextQ = false,
	num = 0
}
--> Департамент
local dep = {
	list = {"Все гос. структуры", "Конкретная организация", "nil", "nil", "Собеседование", "[Инфо] - Тех. неполадки","/gov - Новости"},
	sel_all = {u8"Все структуры", u8"Правительство", u8"Центр Лицензирования", u8"Страховая Компания", u8"Центральный банк", u8"Армия ЛС", u8"Армия СФ", u8"ТСР", u8"ФБР", u8"Областная полиция", u8"Полиция ЛС", u8"Полиция СФ", u8"Полиция ЛВ", u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"Центральный Аппарат", u8"Министерство Обороны", u8"Министерство Здравоохранения", u8"Министерство Юстиции"},
	sel_chp = {u8"Все структуры", u8"Правительство", u8"Центр Лицензирования", u8"Страховая Компания", u8"Центральный банк", u8"Армия ЛС", u8"Армия СФ", u8"ТСР", u8"ФБР", u8"Областная полиция", u8"Полиция ЛС", u8"Полиция СФ", u8"Полиция ЛВ", u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"Центральный Аппарат", u8"Министерство Обороны", u8"Министерство Здравоохранения", u8"Министерство Юстиции"},
	sel_tsr = {u8"Тюрьма ЛВ", u8"Министр Обороны"},
	sel_mzmomu = {u8"Армия ЛС", u8"ВМС", u8"Тюрьма ЛВ", u8"Полиция ЛС", u8"Полиция СФ", u8"Полиция ЛВ", u8"Областная полиция", u8"ФБР", u8"Министр Обороны", u8"Министр Юстиций"},
	sel = imgui.ImInt(0),
	select_dep = {0, 0},
	input = imgui.ImBuffer(101),
	bool = {false, false, false, false, false, false},
	time = {0,0}, 
	newsN = imgui.ImInt(0),
	news = {},
	dlog = {}
}
prefixDefolt = {u8"ВСЕМ", u8"Пра-во", u8"ГЦЛ", u8"СТК", u8"ЦБ", u8"ЛСа", u8"СФа", u8"ТСР", u8"ФБР", u8"РКШД", u8"ЛСПД", u8"СФПД", u8"ЛВПД", u8"ЛСМЦ", u8"СФМЦ", u8"ЛВМЦ", u8"ЧБЛС", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"ЦА", u8"МО", u8"МЗ", u8"МЮ"}
trtxt = {}
trtxt = {imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000)}
--> Вспомогательные для мед. карты
local buf_mcedit = imgui.ImBuffer(51200) 
local error_mce = ""

--> ЧатХуд
local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
local textFont = renderCreateFont("Trebuchet MS", 12, FCR_BORDER + FCR_BOLD)
local fontPing = renderCreateFont("Trebuchet MS", 10, 5)
local pingLog = {}

lua_thread.create(function()
	while true do
		repeat wait(100) until isSampAvailable()
		repeat wait(100) until sampIsLocalPlayerSpawned()
		wait(1500)
		if sampIsLocalPlayerSpawned() then
			local ping = sampGetPlayerPing(myid)
			table.insert(pingLog, ping)
			if #pingLog == 41 then table.remove(pingLog, 1) end
		end
	end
end)
--> ЧатХуд
local week = {"Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"}
local month = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"}
editKey = false
keysList = {}
arep = false
newversion = ""
updinfo = ""
needSave = false
needSaveColor = imgui.ImColor(250, 66, 66, 102):GetVec4()
urlupd = ""

local BlockKeys = {{vkeys.VK_T}, {vkeys.VK_F6}, {vkeys.VK_F8}, {vkeys.VK_RETURN}, {vkeys.VK_OEM_3}, {vkeys.VK_LWIN}, {vkeys.VK_RWIN}}

rkeys.isBlockedHotKey = function(keys)
	local bool, hkId = false, -1
	for k, v in pairs(BlockKeys) do
	   if rkeys.isHotKeyHotKey(keys, v) then
		  bool = true
		  hkId = k
		  break
	   end
	end
	return bool, hkId
end

function rkeys.isHotKeyExist(keys)
local bool = false
	for i,v in ipairs(keysList) do
		if table.concat(v,"+") == table.concat(keys, "+") then
			if #keys ~= 0 then
				bool = true
				break
			end
		end
	end
	return bool
end

function unRegisterHotKey(keys)
	for i,v in ipairs(keysList) do
		if v == keys then
			keysList[i] = nil
			break
		end
	end
	local listRes = {}
	for i,v in ipairs(keysList) do
		if #v > 0 then
			listRes[#listRes+1] = v
		end
	end
	keysList = listRes
end
--> Для редактора отыгровок
setCmdEdit = {
	[5] = {
		sec = {"2100", "2100", "2100", "", "", "", "", "", "", ""},
		text = {u8"Не волнуйтесь, сейчас я Вам помогу!", u8"/do В правой руке медицинский саквояж.", u8"/me открыв саквояж, вытащил{sex:|а} необходимое средство и передал{sex:|а} пациенту напротив", u8"", u8"", u8"", u8"", u8"", u8"", u8""},
	},
}
setCmdEditDefolt = {
	[5] = {
		sec = {"2100", "2100", "2100", "", "", "", "", "", "", ""},
		text = {u8"Не волнуйтесь, сейчас я Вам помогу!", u8"/do В правой руке медицинский саквояж.", u8"/me открыв саквояж, вытащил{sex:|а} необходимое средство и передал{sex:|а} пациенту напротив", u8"", u8"", u8"", u8"", u8"", u8"", u8""},
	},
}
--> Для департамента
setDep = {"","",""}
--> Настройки основных команд
cmdBind = {
	[1] = {
		cmd = "mh",
		key = {},
		desc = "Открывает меню скрипта.",
		rank = 1,
		rb = false
	},
	[2] = {
		cmd = "r",
		key = {},
		desc = "Команда для вызова рации с тегом (если тег прописан).",
		rank = 1,
		rb = false
	},
	[3] = {
		cmd = "rb",
		key = {},
		desc = "Команда для написания НонРп сообщения в рацию.",
		rank = 1,
		rb = false
	},
	[4] = {
		cmd = "mb",
		key = {},
		desc = "Сокращённая команда /members",
		rank = 1,
		rb = false
	},
	[5] = {
		cmd = "hl",
		key = {},
		desc = "Лечение с автоматической РП отыгровкой.",
		rank = 2,
		rb = false
	},
	[6] = {
		cmd = "post",
		key = {},
		desc = "Доклад с мобильного поста. Также информация о постах.",
		rank = 2,
		rb = false
	},
	[7] = {
		cmd = "mc",
		key = {},
		desc = "Выдача или обновление медицинской карты.",
		rank = 2,
		rb = false
	},
	[8] = {
		cmd = "narko",
		key = {},
		desc = "Лечение от наркозависимости.",
		rank = 4,
		rb = false
	},
	[9] = {
		cmd = "recep",
		key = {},
		desc = "Выдача рецептов.",
		rank = 4,
		rb = false
	},
	[10] = {
		cmd = "osm",
		key = {},
		desc = "Произвести медицинский осмотр.",
		rank = 5,
		rb = false
	},
	[11] = {
		cmd = "dep",
		key = {},
		desc = "Меню рации депортамента.",
		rank = 5,
		rb = false
	},
	[12] = {
		cmd = "sob",
		key = {},
		desc = "Меню собеседования с игроком.",
		rank = 5,
		rb = false
	},
	[13] = {
		cmd = "tatu",
		key = {},
		desc = "Сведение татуировки с тела.",
		rank = 7,
		rb = false
	},
	[14] = {
		cmd = "vig",
		key = {},
		desc = "Выдача выговора сотруднику.",
		rank = 8,
		rb = false
	},
	[15] = {
		cmd = "unvig",
		key = {},
		desc = "Снять выговор сотруднику.",
		rank = 8,
		rb = false
	},
	[16] = {
		cmd = "muteorg",
		key = {},
		desc = "Выдать мут сотруднику.",
		rank = 8,
		rb = false
	},
	[17] = {
		cmd = "unmuteorg",
		key = {},
		desc = "Снять мут сотруднику.",
		rank = 8,
		rb = false
	},
	[18] = {
		cmd = "gr",
		key = {},
		desc = "Изменить ранг (должность) сотруднику с РП отыгровкой.",
		rank = 9,
		rb = false
	},
	[19] = {
		cmd = "inv",
		key = {},
		desc = "Принять в организацию игрока с РП отыгровкой.",
		rank = 9,
		rb = false
	},
	[20] = {
		cmd = "unv",
		key = {},
		desc = "Уволить сотрудника из организации с РП отыгровкой.",
		rank = 9,
		rb = false
	},
	[21] = {
		cmd = "time",
		key = {},
		desc = "Посмотреть на часы с гравировкой.",
		rank = 1,
		rb = false
	},
	[22] = {
		cmd = "exp",
		key = {},
		desc = "Выгнать из больницы с РП отыгровкой.",
		rank = 1,
		rb = false
	},
	[23] = {
		cmd = "vac",
		key = {},
		desc = "Вакцинация с РП отыгровкой.",
		rank = 3,
		rb = false
	},
	[24] = {
		cmd = "info",
		key = {},
		desc = "Информацию о частых командах выведет в чат.",
		rank = 1,
		rb = false
	},
	[25] = {
		cmd = "za",
		key = {},
		desc = "Отправляет в чат фразу \"Пройдёмте за мной.\"",
		rank = 1,
		rb = false
	},
	[26] = {
		cmd = "zd",
		key = {},
		desc = "Отправляет в чат приветствие.",
		rank = 1,
		rb = false
	},
	[27] = {
		cmd = "ant",
		key = {},
		desc = "Продать антибиотики с РП отыгровкой.",
		rank = 4,
		rb = false
	},
	[28] = {
		cmd = "strah",
		key = {},
		desc = "Выдать медицинскую страховку с РП отыгровкой.",
		rank = 3,
		rb = false
	},
	[29] = {
		cmd = "cur",
		key = {},
		desc = "Поднять человека на ноги на вызове с РП отыгровкой.",
		rank = 2,
		rb = false
	},
	[30] = {
		cmd = "hall",
		key = {2,50},
		desc = "Вылечить игрока по прицелу мыши на него. (работает плохо)",
		rank = 1.5,
		rb = false
	},
	[31] = {
		cmd = "hilka",
		key = {2,49},
		desc = "Вылечить ближайшего игрока с РП отыгровкой.",
		rank = 1.5,
		rb = false
	},
	[32] = {
		cmd = "shpora",
		key = {},
		desc = "Открыть шпаргалку по его порядковому номеру.",
		rank = 1,
		rb = false
	}
}
--> Подсветка кнопки выбранного меню
function ButtonMenu(desk, bool)
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		if select_menu[4] then
			retBool = imgui.Button(desk, imgui.ImVec2(141, 45))
		else
			retBool = imgui.Button(desk, imgui.ImVec2(140, 45))
		end
		imgui.SameLine()
		imgui.SetCursorPosX(116)
		imgui.ButtonArrow()
		imgui.SameLine()
		imgui.SetCursorPosX(0)
		imgui.ButtonArrowLine()
		imgui.Dummy(imgui.ImVec2(0, 1))
		imgui.PopStyleColor(1)
	elseif not bool then
		retBool = imgui.Button(desk, imgui.ImVec2(132, 45))
	end
	return retBool
end

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
  if fa_font == nil then
    local font_config = imgui.ImFontConfig()
    font_config.MergeMode = true

    fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/lib/fontawesome-webfont.ttf', 15.0, font_config, fa_glyph_ranges)
  end
end

function main()	
	repeat wait(300) until isSampAvailable()

	local base = getModuleHandle("samp.dll")
	local sampVer = mem.tohex( base + 0xBABE, 10, true )
	if sampVer == "E86D9A0A0083C41C85C0" then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	if script.this.filename:find("%.luac") then
		os.rename(getWorkingDirectory().."\\MedicalHelper.luac", getWorkingDirectory().."\\MedicalHelper.lua") 
	end
	------------
	thread = lua_thread.create(function() return end)
	lua_thread.create(function()
		while true do
		wait(1000)
		needSaveColor = colBut
			if needSave then
				wait(1000)
				needSaveColor = colButActive
			end
		end
	end)  
	------------
		

		
		--Проверка на существование папкок
		if not doesDirectoryExist(dirml.."/MedicalHelper/files/") then
			print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки под файлы")
			createDirectory(dirml.."/MedicalHelper/files/")
		end
		if not doesDirectoryExist(dirml.."/MedicalHelper/Binder/") then
			print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для биндера.")
			createDirectory(dirml.."/MedicalHelper/Binder/")
		end
		if not doesDirectoryExist(dirml.."/MedicalHelper/Шпаргалки/") then
			print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для шпор")
			createDirectory(dirml.."/MedicalHelper/Шпаргалки/")
		end
		if not doesDirectoryExist(dirml.."/MedicalHelper/Департамент/") then
			print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для новостей в департамент")
			createDirectory(dirml.."/MedicalHelper/Департамент/")
		end
		--Загрузка файла настроек
		if doesDirectoryExist(dirml.."/MedicalHelper/Департамент/") then
			getGovFile()
		end
	local function check_table(arg, table, mode)
		if mode == 1 then -- Поиск по ключу
			for k, v in pairs(table) do
				if k == arg then
					return true
				end
			end
		else -- Поиск по значению
			for k, v in pairs(table) do
				if v == arg then
					return true
				end
			end
		end
		return false
	end
	
	if doesFileExist(dirml.."/MedicalHelper/rp-medcard.txt") then
			local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt")
			buf_mcedit.v = u8(f:read("*a"))
			f:close()
			print("{82E28C}Чтение отыгровки мед.карты...")
		else 
			local textrp = [[
// Цены на выдачу новой мед.карты
#med7=20.000$
#med14=40.000$
#med30=60.000$
#med60=80.000$
// Цены на обновление мед.карты
#medup7=40.000$
#medup14=60.000$
#medup30=80.000$
#medup60=100.000$

{sleep:0}
Здравствуйте, Вы хотите получить медицинскую карту впервые или обновить существующую?
Предоставьте, пожалуйста, Ваш паспорт
/b /showpass {myID}
{pause}
/todo Благодорю вас!*взяв паспорт в руки и начав его изучать.
{dialog}
[name]=Выдача мед.карты
[1]=Новая мед.карта
Хорошо, я Вас {sex:понял|поняла}. Вам нужно оформить новую мед.карту.
Стоимость мед. карты зависит от её срока.
На 7 дней - #med7, на 14 дней - #med14
На 30 дней #med30, на 60 дней - #med60.
Вы согласны? Если да, то на какой срок Вам?
/b Оплата в конце, система сама предложит.

{dialog}
[name]=Срок выдачи
[1]=7 дней
#timeID=0
#money=20000
[2]=14 дней
#timeID=1
#money=40000
[3]=30 дней
#timeID=2
#money=60000
[4]=60 дей
#timeID=3
#money=80000
{dialogEnd}

Хорошо, тогда приступим к оформлению.
/me {sex:вытащил|вытащила} из нагрудного кармана шариковую ручку
/me открыл{sex:|а} шкафчик, затем достал{sex:|а} оттуда пустые бланки для мед.карты
/me разложил{sex:|а} пальцами правой руки паспорт на нужной страничке и начал{sex:|а} переписывать данные в бланк
/me открыл{sex:|а} пустую мед.карту и паспорт, затем начал{sex:|а} переписывать данные из паспорта
/do Спустя минуту данные паспорта были переписаны на бланк.

[2]=Обновление данных
Хорошо, я Вас понял{sex:|а}. Вам нужно обновить данные в мед.карте.
Стоимость мед. карты зависит от её срока.
На 7 дней - #medup7, на 14 дней - #medup14
На 30 дней #medup30, на 60 дней - #medup60.
Вы согласны? Если да, то на какой срок Вам?
/b Оплата в конце, система сама предложит.

{dialog}
[name]=Срок выдачи
[1]=7 дней
#timeID=0
#money=40000
[2]=14 дней
#timeID=1
#money=60000
[3]=30 дней
#timeID=2
#money=80000
[4]=60 дней
#timeID=3
#money=100000
{dialogEnd}

Хорошо, тогда приступим к оформлению.
/me вытащил{sex:|а} из нагрудного кармана шариковую ручку
/me открыл{sex:|а} шкафчик, затем начал{sex:|а} искать мед.карту c индификатором №#playerID
/me разложил{sex:|а} пальцами правой руки паспорт на нужной страничке и начал переписывать данные в бланк
/me открыл{sex:|а} пустую мед.карту и паспорт, затем начал переписывать данные из паспорта
/do Спустя минуту данные паспорта были переписаны на бланк.
{dialogEnd}
/me отложил{sex:|а} паспорт в сторону его хозяина и приготовил{sex:ся|ась} к продолжению занесения информации
Так, сейчас задам несколько вопросов касаемо здоровья...
Жалобы на здоровье имеются?
{pause}
Имеются ли вредные привычки, а также аллергические реакции?
{pause}
/me записал{sex:|а} все сказанное пациентом в мед.карту
{dialog}
[name]=Сост. здоровья
[1]=Полноcтью здоров(ая)
#healID=3
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Полностью здоров(а).'
[2]=Наблюдаются отклоненияются
#healID=2
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Имеются отклонения.'
[3]=Психически не здоров(ая)
#healID=1
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Псих. нездоров.'
{dialogEnd}
/me взял{sex:|а} штамп {myHospEn} и проставил{sex:|а} печать в необходимых местах
/do Страница мед.карты заполнена.
Всё готово, держите свою мед. карту, не болейте.
/medcard #playerID #healID #timeID #money]]  
			local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
			f:write(textrp) 
			f:close()
			buf_mcedit.v = u8(textrp)
		end
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		myNick = sampGetPlayerNickname(myid)
		mynickname = trst(myNick)
		
		--//!!
		if doesFileExist(dirml.."/MedicalHelper/Отыгровки.med") then
		print("{82E28C}Чтение настроек отыгровок...")
		local f = io.open(dirml.."/MedicalHelper/Отыгровки.med")
		local setf = f:read("*a")
		f:close()
		local res, sets = pcall(decodeJson, setf)
			if res and type(sets) == "table" then 
				setCmdEdit[5].text = sets[5].text
				setCmdEdit[5].sec = sets[5].sec
			else
				os.remove(dirml.."/MedicalHelper/Отыгровки.med")
				print("{F54A4A}Ошибка. Файл отыгровок повреждён.")
				print("{82E28C}Создание файла отыгровок...")
				local f = io.open(dirml.."/MedicalHelper/Отыгровки.med", "w")
				f:write(encodeJson(setCmdEdit))
				f:flush()
				f:close()
			end
		else
			print("{F54A4A}Ошибка. Файл отыгровки не найден.")
			print("{82E28C}Создание файла отыгровок...")
			if not doesFileExist(dirml.."/MedicalHelper/Отыгровки.med") then
				local f = io.open(dirml.."/MedicalHelper/Отыгровки.med", "w")
				f:write(encodeJson(setCmdEdit))
				f:flush()
				f:close()
			end
		end
--//!! 
	
--//Настройки департамента
		if doesFileExist(dirml.."/MedicalHelper/depsetting.med") then
		print("{82E28C}Чтение настроек департамента...")
		local f = io.open(dirml.."/MedicalHelper/depsetting.med")
		local setf = f:read("*a")
		f:close()
		local res, setdept = pcall(decodeJson, setf)
			if res and type(setdept) == "table" then 
				setdepteg.tegtext_one = setdept.tegtext_one
				setdepteg.tegtext_two = setdept.tegtext_two
				setdepteg.tegtext_three = setdept.tegtext_three
				setdepteg.tegpref_one = setdept.tegpref_one
				setdepteg.tegpref_two = setdept.tegpref_two
				setdepteg.prefix = setdept.prefix
			else
				os.remove(dirml.."/MedicalHelper/depsetting.med")
				print("{F54A4A}Ошибка. Файл настроек департамента повреждён.")
				print("{82E28C}Пересоздание файла настроек департамента...")
				local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
				f:write(encodeJson(setdepteg))
				f:flush()
				f:close()
			end
		else
			print("{F54A4A}Ошибка. Файл настроек департамента не найден.")
			print("{82E28C}Создание файла настроек департамента...")
			if not doesFileExist(dirml.."/MedicalHelper/depsetting.med") then
				local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
				f:write(encodeJson(setdepteg))
				f:flush()
				f:close()
			end
		end
--//Конец настройки департамента

--//Настройки заработка
profit_money = {
	payday = {0, 0, 0, 0, 0, 0, 0}, --> Зарплата
	lec = {0, 0, 0, 0, 0, 0, 0}, --> Лечение
	medcard = {0, 0, 0, 0, 0, 0, 0}, --> Мед. карта
	narko = {0, 0, 0, 0, 0, 0, 0}, --> Наркозависимость
	vac = {0, 0, 0, 0, 0, 0, 0}, --> Вакцинация
	ant = {0, 0, 0, 0, 0, 0, 0}, --> Антибиотики
	rec = {0, 0, 0, 0, 0, 0, 0}, --> Рецепты
	medcam = {0, 0, 0, 0, 0, 0, 0}, --> Медикаменты
	cure = {0, 0, 0, 0, 0, 0, 0}, --> Поднятие на ноги
	strah = {0, 0, 0, 0, 0, 0, 0}, --> Страховка
	tatu = {0, 0, 0, 0, 0, 0, 0}, --> Татуировка
	premium = {0, 0, 0, 0, 0, 0, 0}, --> Премия
	other = {0, 0, 0, 0, 0, 0, 0}, --> Другое
	total_week = 0, --> Всего за неделю
	total_all = 0, --> Итого
	date_num = {0, 0}, --> Дата в цифровом формате {Сегодня, вчера}
	date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0}, --> Дата захода в реальном времени в формате {день, месяц, год}
	date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0}, --> Дата вчерашняя в формате {день, месяц, год}
	date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""} --> Дата за неделю в формате [день, месяц, год]
}
		if doesFileExist(dirml.."/MedicalHelper/profit.med") then
		print("{82E28C}Чтение настроек прибыли...")
		local f = io.open(dirml.."/MedicalHelper/profit.med")
		local setp = f:read("*a")
		f:close()
		local res, setprofit = pcall(decodeJson, setp)
			if res and type(setprofit) == "table" then 
				profit_money = setprofit 
				profit_money.date_today[1] = os.date("%d") + 0
				profit_money.date_today[2] = os.date("%m") + 0
				profit_money.date_today[3] = os.date("%Y") + 0
				if profit_money.date_today[1] ~= profit_money.date_last[1] or profit_money.date_today[2] ~= profit_money.date_last[2] or profit_money.date_today[3] ~= profit_money.date_last[3] then
					profit_money.date_num[1] = profit_money.date_num[1] + 1
				end
				if profit_money.date_num[1] > profit_money.date_num[2] then --> Если сегодняшняя дата отличается от вчерашней
					profit_money.date_last[1] = os.date("%d") + 0
					profit_money.date_last[2] = os.date("%m") + 0
					profit_money.date_last[3] = os.date("%Y") + 0
					profit_money.date_num[2] = profit_money.date_num[1]
					profit_money.date_week[1], profit_money.date_week[2], profit_money.date_week[3], profit_money.date_week[4], profit_money.date_week[5], profit_money.date_week[6], profit_money.date_week[7] = os.date("%d.%m.%Y"), setprofit.date_week[1], setprofit.date_week[2], setprofit.date_week[3], setprofit.date_week[4], setprofit.date_week[5], setprofit.date_week[6]
					profit_money.payday[1], profit_money.payday[2], profit_money.payday[3], profit_money.payday[4], profit_money.payday[5], profit_money.payday[6], profit_money.payday[7] = 		 			  0, setprofit.payday[1], setprofit.payday[2], setprofit.payday[3], setprofit.payday[4], setprofit.payday[5], setprofit.payday[6]
					profit_money.lec[1], profit_money.lec[2], profit_money.lec[3], profit_money.lec[4], profit_money.lec[5], profit_money.lec[6], profit_money.lec[7] = 										  0, setprofit.lec[1], setprofit.lec[2], setprofit.lec[3], setprofit.lec[4], setprofit.lec[5], setprofit.lec[6]
					profit_money.medcard[1], profit_money.medcard[2], profit_money.medcard[3], profit_money.medcard[4], profit_money.medcard[5], profit_money.medcard[6], profit_money.medcard[7] = 			  0, setprofit.medcard[1], setprofit.medcard[2], setprofit.medcard[3], setprofit.medcard[4], setprofit.medcard[5], setprofit.medcard[6]
					profit_money.narko[1], profit_money.narko[2], profit_money.narko[3], profit_money.narko[4], profit_money.narko[5], profit_money.narko[6], profit_money.narko[7] = 				 			  0, setprofit.narko[1], setprofit.narko[2], setprofit.narko[3], setprofit.narko[4], setprofit.narko[5], setprofit.narko[6]
					profit_money.vac[1], profit_money.vac[2], profit_money.vac[3], profit_money.vac[4], profit_money.vac[5], profit_money.vac[6], profit_money.vac[7] = 										  0, setprofit.vac[1], setprofit.vac[2], setprofit.vac[3], setprofit.vac[4], setprofit.vac[5], setprofit.vac[6]
					profit_money.ant[1], profit_money.ant[2], profit_money.ant[3], profit_money.ant[4], profit_money.ant[5], profit_money.ant[6], profit_money.ant[7] = 										  0, setprofit.ant[1], setprofit.ant[2], setprofit.ant[3], setprofit.ant[4], setprofit.ant[5], setprofit.ant[6]
					profit_money.rec[1], profit_money.rec[2], profit_money.rec[3], profit_money.rec[4], profit_money.rec[5], profit_money.rec[6], profit_money.rec[7] = 										  0, setprofit.rec[1], setprofit.rec[2], setprofit.rec[3], setprofit.rec[4], setprofit.rec[5], setprofit.rec[6]
					profit_money.medcam[1], profit_money.medcam[2], profit_money.medcam[3], profit_money.medcam[4], profit_money.medcam[5], profit_money.medcam[6], profit_money.medcam[7] = 		 			  0, setprofit.medcam[1], setprofit.medcam[2], setprofit.medcam[3], setprofit.medcam[4], setprofit.medcam[5], setprofit.medcam[6]
					profit_money.cure[1], profit_money.cure[2], profit_money.cure[3], profit_money.cure[4], profit_money.cure[5], profit_money.cure[6], profit_money.cure[7] = 								   	  0, setprofit.cure[1], setprofit.cure[2], setprofit.cure[3], setprofit.cure[4], setprofit.cure[5], setprofit.cure[6]
					profit_money.strah[1], profit_money.strah[2], profit_money.strah[3], profit_money.strah[4], profit_money.strah[5], profit_money.strah[6], profit_money.strah[7] = 							  0, setprofit.strah[1], setprofit.strah[2], setprofit.strah[3], setprofit.strah[4], setprofit.strah[5], setprofit.strah[6]
					profit_money.tatu[1], profit_money.tatu[2], profit_money.tatu[3], profit_money.tatu[4], profit_money.tatu[5], profit_money.tatu[6], profit_money.tatu[7] = 								  	  0, setprofit.tatu[1], setprofit.tatu[2], setprofit.tatu[3], setprofit.tatu[4], setprofit.tatu[5], setprofit.tatu[6]
					profit_money.premium[1], profit_money.premium[2], profit_money.premium[3], profit_money.premium[4], profit_money.premium[5], profit_money.premium[6], profit_money.premium[7] =			  	  0, setprofit.premium[1], setprofit.premium[2], setprofit.premium[3], setprofit.premium[4], setprofit.premium[5], setprofit.premium[6]
					profit_money.other[1], profit_money.other[2], profit_money.other[3], profit_money.other[4], profit_money.other[5], profit_money.other[6], profit_money.other[7] = 				 			  0, setprofit.other[1], setprofit.other[2], setprofit.other[3], setprofit.other[4], setprofit.other[5], setprofit.other[6]
				end
					profit_money.total_week = profit_money.payday[1] + profit_money.payday[2] + profit_money.payday[3] + profit_money.payday[4] + profit_money.payday[5] + profit_money.payday[6] + profit_money.payday[7] +
					profit_money.lec[1] + profit_money.lec[2] + profit_money.lec[3] + profit_money.lec[4] + profit_money.lec[5] + profit_money.lec[6] + profit_money.lec[7] +
					profit_money.medcard[1] + profit_money.medcard[2] + profit_money.medcard[3] + profit_money.medcard[4] + profit_money.medcard[5] + profit_money.medcard[6] + profit_money.medcard[7] +
					profit_money.narko[1] + profit_money.narko[2] + profit_money.narko[3] + profit_money.narko[4] + profit_money.narko[5] + profit_money.narko[6] + profit_money.narko[7] +
					profit_money.vac[1] + profit_money.vac[2] + profit_money.vac[3] + profit_money.vac[4] + profit_money.vac[5] + profit_money.vac[6] + profit_money.vac[7] +
					profit_money.ant[1] + profit_money.ant[2] + profit_money.ant[3] + profit_money.ant[4] + profit_money.ant[5] + profit_money.ant[6] + profit_money.ant[7] +
					profit_money.rec[1] + profit_money.rec[2] + profit_money.rec[3] + profit_money.rec[4] + profit_money.rec[5] + profit_money.rec[6] + profit_money.rec[7] +
					profit_money.medcam[1] + profit_money.medcam[2] + profit_money.medcam[3] + profit_money.medcam[4] + profit_money.medcam[5] + profit_money.medcam[6] + profit_money.medcam[7] +
					profit_money.cure[1] + profit_money.cure[2] + profit_money.cure[3] + profit_money.cure[4] + profit_money.cure[5] + profit_money.cure[6] + profit_money.cure[7] +
					profit_money.strah[1] + profit_money.strah[2] + profit_money.strah[3] + profit_money.strah[4] + profit_money.strah[5] + profit_money.strah[6] + profit_money.strah[7] +
					profit_money.tatu[1] + profit_money.tatu[2] + profit_money.tatu[3] + profit_money.tatu[4] + profit_money.tatu[5] + profit_money.tatu[6] + profit_money.tatu[7] +
					profit_money.premium[1] + profit_money.premium[2] + profit_money.premium[3] + profit_money.premium[4] + profit_money.premium[5] + profit_money.premium[6] + profit_money.premium[7] +
					profit_money.other[1] + profit_money.other[2] + profit_money.other[3] + profit_money.other[4] + profit_money.other[5] + profit_money.other[6] + profit_money.other[7]
				local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
				f:write(encodeJson(profit_money))
				f:flush()
				f:close()
			else
				os.remove(dirml.."/MedicalHelper/profit.med")
				print("{F54A4A}Ошибка. Файл настроек прибыли повреждён.")
				print("{82E28C}Пересоздание файла настроек прибыли...")
				local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
				f:write(encodeJson(profit_money))
				f:flush()
				f:close()
			end
		else
			print("{F54A4A}Ошибка. Файл настроек прибыли не найден.")
			print("{82E28C}Создание файла настроек прибыли...")
			if not doesFileExist(dirml.."/MedicalHelper/profit.med") then
				local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
				f:write(encodeJson(profit_money))
				f:flush()
				f:close()
			end
		end
--//Конец настройки заработка	
		if doesFileExist(dirml.."/MedicalHelper/rp-medcard.txt") then
			local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt")
			buf_mcedit.v =  u8(f:read("*a"))
			f:close()
			print("{82E28C}Чтение отыгровки мед.карты...")
		else 
			local textrp = [[
// Цены на выдачу новой мед.карты
#med7=20.000$
#med14=40.000$
#med30=60.000$
#med60=80.000$
// Цены на обновление мед.карты
#medup7=40.000$
#medup14=60.000$
#medup30=80.000$
#medup60=100.000$

{sleep:0}
Здравствуйте, Вы хотите получить медицинскую карту впервые или обновить существующую?
Предоставьте, пожалуйста, Ваш паспорт
/b /showpass {myID}
{pause}
/todo Благодорю вас!*взяв паспорт в руки и начав его изучать.
{dialog}
[name]=Выдача мед.карты
[1]=Новая мед.карта
Хорошо, я Вас {sex:понял|поняла}. Вам нужно оформить новую мед.карту.
Стоимость мед. карты зависит от её срока.
На 7 дней - #med7, на 14 дней - #med14
На 30 дней #med30, на 60 дней - #med60.
Вы согласны? Если да, то на какой срок Вам?
/b Оплата в конце, система сама предложит.

{dialog}
[name]=Срок выдачи
[1]=7 дней
#timeID=0
#money=20000
[2]=14 дней
#timeID=1
#money=40000
[3]=30 дней
#timeID=2
#money=60000
[4]=60 дей
#timeID=3
#money=80000
{dialogEnd}

Хорошо, тогда приступим к оформлению.
/me {sex:вытащил|вытащила} из нагрудного кармана шариковую ручку
/me открыл{sex:|а} шкафчик, затем достал{sex:|а} оттуда пустые бланки для мед.карты
/me разложил{sex:|а} пальцами правой руки паспорт на нужной страничке и начал{sex:|а} переписывать данные в бланк
/me открыл{sex:|а} пустую мед.карту и паспорт, затем начал{sex:|а} переписывать данные из паспорта
/do Спустя минуту данные паспорта были переписаны на бланк.

[2]=Обновление данных
Хорошо, я Вас понял{sex:|а}. Вам нужно обновить данные в мед.карте.
Стоимость мед. карты зависит от её срока.
На 7 дней - #medup7, на 14 дней - #medup14
На 30 дней #medup30, на 60 дней - #medup60.
Вы согласны? Если да, то на какой срок Вам?
/b Оплата в конце, система сама предложит.

{dialog}
[name]=Срок выдачи
[1]=7 дней
#timeID=0
#money=40000
[2]=14 дней
#timeID=1
#money=60000
[3]=30 дней
#timeID=2
#money=80000
[4]=60 дней
#timeID=3
#money=100000
{dialogEnd}

Хорошо, тогда приступим к оформлению.
/me вытащил{sex:|а} из нагрудного кармана шариковую ручку
/me открыл{sex:|а} шкафчик, затем начал{sex:|а} искать мед.карту c индификатором №#playerID
/me разложил{sex:|а} пальцами правой руки паспорт на нужной страничке и начал переписывать данные в бланк
/me открыл{sex:|а} пустую мед.карту и паспорт, затем начал переписывать данные из паспорта
/do Спустя минуту данные паспорта были переписаны на бланк.
{dialogEnd}
/me отложил{sex:|а} паспорт в сторону его хозяина и приготовил{sex:ся|ась} к продолжению занесения информации
Так, сейчас задам несколько вопросов касаемо здоровья...
Жалобы на здоровье имеются?
{pause}
Имеются ли вредные привычки, а также аллергические реакции?
{pause}
/me записал{sex:|а} все сказанное пациентом в мед.карту
{dialog}
[name]=Сост. здоровья
[1]=Полноcтью здоров(ая)
#healID=3
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Полностью здоров(а).'
[2]=Наблюдаются отклоненияются
#healID=2
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Имеются отклонения.'
[3]=Психически не здоров(ая)
#healID=1
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Псих. нездоров.'
{dialogEnd}
/me взял{sex:|а} штамп {myHospEn} и проставил{sex:|а} печать в необходимых местах
/do Страница мед.карты заполнена.
Всё готово, держите свою мед. карту, не болейте.
/medcard #playerID #healID #timeID #money]]  
			local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
			f:write(textrp) 
			f:close()
			buf_mcedit.v = u8(textrp)
		end
		local function settingMassiveStart()
			setting.nick = u8:decode(buf_nick.v)
			setting.teg = u8:decode(buf_teg.v)
			setting.org = num_org.v
			setting.sex = num_sex.v
			setting.rank = num_rank.v
			setting.time = cb_time.v
			setting.timeTx = u8:decode(buf_time.v)
			setting.timeDo = cb_timeDo.v
			setting.rac = cb_rac.v
			setting.racTx = u8:decode(buf_rac.v)
			setting.lec = buf_lec.v
			setting.rec = buf_rec.v
			setting.narko = buf_narko.v
			setting.tatu = buf_tatu.v
			setting.ant = buf_ant.v
			setting.chat1 = cb_chat1.v
			setting.chat2 = cb_chat2.v
			setting.chat3 = cb_chat3.v
			setting.chathud = cb_hud.v
			setting.arp = arep
			setting.setver = setver
			setting.imageDis = cb_imageDis.v
			setting.htime = cb_hudTime.v
			setting.hping = hudPing
			setting.orgl = {}
			setting.rankl = {}
			setting.theme = num_theme.v
		end
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		myNick = sampGetPlayerNickname(myid)
		mynickname = trst(myNick)
		if doesFileExist(dirml.."/MedicalHelper/MainSetting.med") then
		print("{82E28C}Чтение настроек...")
		local f = io.open(dirml.."/MedicalHelper/MainSetting.med")
			local setf = f:read("*a")
			f:close()
			local res, set = pcall(decodeJson, setf)
			if res and type(set) == "table" then 
				buf_nick.v = u8(set.nick)
				buf_teg.v = u8(set.teg)
				num_org.v = set.org
				num_sex.v = set.sex
				num_rank.v = set.rank
				cb_time.v = set.time
				buf_time.v = u8(set.timeTx)
				cb_timeDo.v = set.timeDo
				cb_rac.v = set.rac
				buf_rac.v = u8(set.racTx)
				buf_lec.v = u8(set.lec)
				buf_rec.v = u8(set.rec)
				buf_narko.v = u8(set.narko)
				buf_tatu.v = u8(set.tatu)
				buf_ant.v = u8(set.ant)
				cb_chat1.v = set.chat1
				cb_chat2.v = set.chat2
				cb_chat3.v = set.chat3
				cb_hud.v = set.chathud
				arep = set.arp
				setver = set.setver
				cb_imageDis.v = set.imageDis
				hudPing = set.hping
				cb_hudTime.v = set.htime
				if check_table('theme', set, 1) then
					num_theme.v = set.theme
					num_themeTest = set.theme
				else
					settingMassiveStart()
					local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
					f:write(encodeJson(setting))
					f:flush()
					f:close()
				end
				if check_table('themAngle', set, 1) then
					theme_Angle.v = set.themAngle
					theme_AngleTest = set.themAngle
				else
					settingMassiveStart()
					setting_themAngle = theme_Angle.v
					local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
					f:write(encodeJson(setting))
					f:flush()
					f:close()
				end
				if check_table('mede', set, 1) then
					buf_mede[1].v = u8(set.mede[1])
					buf_mede[2].v = u8(set.mede[2])
					buf_mede[3].v = u8(set.mede[3])
					buf_mede[4].v = u8(set.mede[4])
					buf_upmede[1].v = u8(set.upmede[1])
					buf_upmede[2].v = u8(set.upmede[2])
					buf_upmede[3].v = u8(set.upmede[3])
					buf_upmede[4].v = u8(set.upmede[4])
					accept_spawn.v = set.spawn
					accept_autolec.v = set.autolec
					prikol = set.prikol
				else
					settingMassiveStart()
					setting_themAngle = theme_Angle.v
					setting.mede[1] = buf_mede[1].v
					setting.mede[2] = buf_mede[2].v
					setting.mede[3] = buf_mede[3].v
					setting.mede[4] = buf_mede[4].v
					setting.upmede[1] = buf_upmede[1].v
					setting.upmede[2] = buf_upmede[2].v
					setting.upmede[3] = buf_upmede[3].v
					setting.upmede[4] = buf_upmede[4].v
					setting.spawn = accept_spawn.v
					setting.autolec = accept_autolec.v
					setting.prikol = prikol
					local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
					f:write(encodeJson(setting))
					f:flush()
					f:close()
				end
				if set.orgl then
					for i,v in ipairs(set.orgl) do
						chgName.org[tonumber(i)] = u8(v)
					end
				end
				if set.rankl then
					for i,v in ipairs(set.rankl) do
						chgName.rank[tonumber(i)] = u8(v)
					end
				end
			else
				os.remove(dirml.."/MedicalHelper/MainSetting.med")
				print("{F54A4A}Ошибка. Файл настроек повреждён.")
				print("{82E28C}Создание новых собственных настроек...")
				buf_nick.v = u8(mynickname)
				buf_lec.v = "10000"
				buf_mede[1].v = "20000"
				buf_mede[2].v = "40000"
				buf_mede[3].v = "60000"
				buf_mede[4].v = "80000"
				buf_upmede[1].v = "40000"
				buf_upmede[2].v = "60000"
				buf_upmede[3].v = "80000"
				buf_upmede[4].v = "100000"
				buf_narko.v = "100000"
				buf_tatu.v = "50000"
				buf_rec.v = "30000"
				buf_ant.v = "25000"
				num_theme.v = 0
				
				buf_time.v = u8"/me посмотрел на часы с гравировкой \"Made in China\""
				buf_rac.v = u8"/me сняв рацию с пояса, что-то сказал в неё"
			end
		else
			print("{F54A4A}Ошибка. Файл настроек не найден.")
			print("{82E28C}Создание собственных настроек...")
			buf_nick.v = u8(mynickname)
			buf_lec.v = "10000"
			buf_mede[1].v = "20000"
			buf_mede[2].v = "40000"
			buf_mede[3].v = "60000"
			buf_mede[4].v = "80000"
			buf_upmede[1].v = "40000"
			buf_upmede[2].v = "60000"
			buf_upmede[3].v = "80000"
			buf_upmede[4].v = "100000"
			buf_narko.v = "100000"
			buf_tatu.v = "50000"
			buf_rec.v = "30000"
			buf_ant.v = "25000"
			num_theme.v = 0
			
			buf_time.v = u8"/me посмотрел на часы с гравировкой \"Made in China\""
			buf_rac.v = u8"/me сняв рацию с пояса, что-то сказал в неё"
			
		end

	print("{82E28C}Чтение настроек команд...")
	if doesFileExist(dirml.."/MedicalHelper/cmdSetting.med") then
	
	--register cmd
		local f = io.open(dirml.."/MedicalHelper/cmdSetting.med")
		local res, keys = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(keys) == "table" then
			for i, v in ipairs(keys) do
				cmdBind[i].cmd = v.cmd
				if #v.key > 0 then
					rkeys.registerHotKey(v.key, true, onHotKeyCMD)
					cmdBind[i].key = v.key
					table.insert(keysList, v.key)
				end
			end
		
		else
			--print("{F54A4A}Ошибка. Файл настроек команд повреждён.")
			print("{82E28C}Применины стандартные настройки команд")
			os.remove(dirml.."/MedicalHelper/cmdSetting.med")
		end
	end
	
	--register binder 
	print("{82E28C}Чтение настроек биндера...")
	if doesFileExist(dirml.."/MedicalHelper/bindSetting.med") then
	
		local f = io.open(dirml.."/MedicalHelper/bindSetting.med")
		local res, list = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(list) == "table" then
			binder.list = list
			for i, v in ipairs(binder.list) do
				if #v.key > 0 then
					binder.list[i].key = v.key
					rkeys.registerHotKey(v.key, true, onHotKeyBIND)
					table.insert(keysList, v.key)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/bindSetting.med")
			print("{F54A4A}Ошибка. Файл настроек биндера повреждён.")
			print("{82E28C}Применины стандартные настройки")
		end
	else 
		--print("{F54A4A}Ошибка. Файл настроек биндера не найден.")
		print("{82E28C}Применины стандартные настройки биндера")
	end
	
	lockPlayerControl(false)
		sampfuncsRegisterConsoleCommand("arep", function(bool) 
			if tonumber(bool) == 1 then 
				arep = true 
				print("Rep: On")
			else 
				arep = false 
			end 
		end)
		
	function styleWin()
	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	if theme_Angle.v == true then
		style.WindowRounding = 12.0
		style.ChildWindowRounding = 12.0
		style.FrameRounding = 9.0
	else
		style.WindowRounding = 1.0
		style.ChildWindowRounding = 1.0
		style.FrameRounding = 1.0
	end
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ScrollbarSize = 15.0
	style.FramePadding = imgui.ImVec2(5, 3)
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	
	if num_theme.v == 0 then --> Пурпурная
    colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
    colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
    colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00) --!!!
    colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
    colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00) --!!
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00) --!!
    colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.69, 0.17, 0.43, 1.00) --!!!
    colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00) --!!!
    colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
	if num_theme.v == 1 then --> Синяя
    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.26, 0.59, 0.98, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.26, 0.59, 0.98, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
	if num_theme.v == 2 then --> Красная
    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.98, 0.26, 0.26, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
	if num_theme.v == 3 then --> Голубая
    colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.81, 0.81, 0.81, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
	if num_theme.v == 4 then --> Оранжевая
    colors[clr.Text]                 = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.44, 0.44, 0.44, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.06, 0.06, 0.06, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.Button]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.Header]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.HeaderActive]         = ImVec4(0.93, 0.65, 0.14, 1.00)
    colors[clr.Separator]            = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.67, 0.67, 0.67, 0.90)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
	if num_theme.v == 5 then --> Чёрно-белая
    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.08, 0.08, 0.08, 0.54)
    colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 0.94)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.94)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(1.00, 1.00, 1.00, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.80, 0.80, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.80, 0.80, 0.80, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
	end
	if num_theme.v == 6 then --> Зелёная
	colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.13, 0.75, 0.55, 0.40)
    colors[clr.FrameBgHovered]       = ImVec4(0.13, 0.75, 0.75, 0.60)
    colors[clr.FrameBgActive]        = ImVec4(0.13, 0.75, 1.00, 0.80)
    colors[clr.TitleBg]              = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.13, 0.75, 0.55, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.MenuBarBg]            = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.13, 0.75, 0.55, 0.80)
    colors[clr.SliderGrab]           = ImVec4(0.13, 0.75, 0.75, 0.80)
    colors[clr.SliderGrabActive]     = ImVec4(0.13, 0.75, 1.00, 0.80)
    colors[clr.Button]               = ImVec4(0.13, 0.75, 0.55, 0.40)
    colors[clr.ButtonHovered]        = ImVec4(0.13, 0.75, 0.75, 0.60)
    colors[clr.ButtonActive]         = ImVec4(0.13, 0.75, 1.00, 0.80)
    colors[clr.Header]               = ImVec4(0.13, 0.75, 0.55, 0.40)
    colors[clr.HeaderHovered]        = ImVec4(0.13, 0.75, 0.75, 0.60)
    colors[clr.HeaderActive]         = ImVec4(0.13, 0.75, 1.00, 0.80)
    colors[clr.Separator]            = ImVec4(0.13, 0.75, 0.55, 0.40)
    colors[clr.SeparatorHovered]     = ImVec4(0.13, 0.75, 0.75, 0.60)
    colors[clr.SeparatorActive]      = ImVec4(0.13, 0.75, 1.00, 0.80)
    colors[clr.ResizeGrip]           = ImVec4(0.13, 0.75, 0.55, 0.40)
    colors[clr.ResizeGripHovered]    = ImVec4(0.13, 0.75, 0.75, 0.60)
    colors[clr.ResizeGripActive]     = ImVec4(0.13, 0.75, 1.00, 0.80)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
	if num_theme.v == 7 then --> Монохром
	colors[clr.Text] 				 = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] 		 = ImVec4(0.00, 0.40, 0.41, 1.00)
	colors[clr.WindowBg] 			 = ImVec4(0.08, 0.08, 0.08, 1.00)
	colors[clr.PopupBg] 			 = ImVec4(0.12, 0.12, 0.12, 1.00)
	colors[clr.ChildWindowBg] 		 = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.Border]  			 = ImVec4(0.00, 1.00, 1.00, 0.65)
	colors[clr.BorderShadow]		 = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] 			 = ImVec4(0.44, 0.80, 0.80, 0.18)
	colors[clr.FrameBgHovered] 		 = ImVec4(0.44, 0.80, 0.80, 0.27)
	colors[clr.FrameBgActive]  		 = ImVec4(0.44, 0.81, 0.86, 0.66)
	colors[clr.TitleBg]  			 = ImVec4(0.14, 0.18, 0.21, 0.73)
	colors[clr.TitleBgCollapsed]	 = ImVec4(0.00, 0.00, 0.00, 0.54)
	colors[clr.TitleBgActive] 		 = ImVec4(0.00, 0.65, 0.65, 1.00)
	colors[clr.MenuBarBg] 			 = ImVec4(0.00, 0.00, 0.00, 0.20)
	colors[clr.ScrollbarBg]			 = ImVec4(0.22, 0.29, 0.30, 0.71)
	colors[clr.ScrollbarGrab]		 = ImVec4(0.00, 1.00, 1.00, 0.44)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.ComboBg] 			 = ImVec4(0.16, 0.24, 0.22, 0.60)
	colors[clr.CheckMark] 			 = ImVec4(0.00, 1.00, 1.00, 0.68)
	colors[clr.SliderGrab] 			 = ImVec4(0.00, 1.00, 1.00, 0.36)
	colors[clr.SliderGrabActive]	 = ImVec4(0.00, 1.00, 1.00, 0.76)
	colors[clr.Button] 				 = ImVec4(0.00, 0.65, 0.65, 0.46)
	colors[clr.ButtonHovered]		 = ImVec4(0.01, 1.00, 1.00, 0.43)
	colors[clr.ButtonActive]		 = ImVec4(0.00, 1.00, 1.00, 0.62)
	colors[clr.Header] 				 = ImVec4(0.00, 1.00, 1.00, 0.33)
	colors[clr.HeaderHovered] 		 = ImVec4(0.00, 1.00, 1.00, 0.42)
	colors[clr.HeaderActive] 		 = ImVec4(0.00, 1.00, 1.00, 0.54)
	colors[clr.ResizeGrip] 			 = ImVec4(0.00, 1.00, 1.00, 0.54)
	colors[clr.ResizeGripHovered]	 = ImVec4(0.00, 1.00, 1.00, 0.74)
	colors[clr.ResizeGripActive]	 = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.CloseButton] 		 = ImVec4(0.60, 0.88, 0.88, 0.75)
	colors[clr.CloseButtonHovered]	 = ImVec4(0.00, 0.78, 0.78, 0.47)
	colors[clr.CloseButtonActive]	 = ImVec4(0.00, 0.78, 0.78, 1.00)
	colors[clr.PlotLines] 			 = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.PlotLinesHovered]	 = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogram] 		 = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.TextSelectedBg] 		 = ImVec4(0.00, 1.00, 1.00, 0.22)
	colors[clr.ModalWindowDarkening] = ImVec4(0.04, 0.10, 0.09, 0.51)
	end
colBut = colors[clr.Button]
colButActive = colors[clr.ButtonActive]
if num_theme.v == 0 then colButActiveMenu = imgui.ImColor(235, 19, 60, 220):GetVec4() end
if num_theme.v == 1 then colButActiveMenu = imgui.ImColor(148, 31, 255, 220):GetVec4() end
if num_theme.v == 2 then colButActiveMenu = imgui.ImColor(230, 73, 45, 220):GetVec4() end
if num_theme.v == 3 then colButActiveMenu = imgui.ImColor(28, 186, 26, 220):GetVec4() end
if num_theme.v == 4 then colButActiveMenu = imgui.ImColor(285, 47, 26, 220):GetVec4() end 
if num_theme.v == 5 then colButActiveMenu = imgui.ImColor(173, 173, 173, 220):GetVec4() end--
if num_theme.v == 6 then colButActiveMenu = imgui.ImColor(47, 190, 212, 220):GetVec4() end
if num_theme.v == 7 then colButActiveMenu = imgui.ImColor(0, 198, 201, 220):GetVec4() end
end
styleWin()
 
		
		sampRegCMDLoadScript()
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Скрипт инициализирован!", 0xFF8FA2)
		repeat wait(100) until sampIsLocalPlayerSpawned()
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		myNick = sampGetPlayerNickname(myid)
		sampAddChatMessage(string.format("{FF8FA2}[MedHelper]{FFFFFF} С возвращением, %s. Для активации главного меню пропишите в чат {22E9E3}/"..cmdBind[1].cmd, sampGetPlayerNickname(myid):gsub("_"," ")), 0xFF8FA2)
		--sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Режим разработчика включён {22E9E3}/testmh{FFFFFF}. {fa1635}Не забудь отключить перед публикацией!!", 0xFF8FA2)
		wait(200)
		if buf_nick.v == "" then  
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Обнаружилось, что у Вас не настроена основная информация.", 0xFF8FA2)
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Зайдите в главном меню в раздел \"Настройки\" и заполните необходимую информацию.", 0xFF8FA2)
		end
		--// ПРОВЕРКА ОБНОВЛЕНИЙ
		lua_thread.create(funCMD.updateCheck)
  while true do
	wait(0)
	local fuck
		resTarg, pedTar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if resTarg then
			_, targID = sampGetPlayerIdByCharHandle(pedTar)
			renderFontDrawText(fontPD, "[{F25D33}Num 2{FFFFFF}] - Вылечить игрока с ID "..targID, 900, sy-30, 0xFFFFFFFF)
		end
	if isKeyDown(VK_LMENU) and isKeyJustPressed(VK_K) and not sampIsChatInputActive() then
		mainWin.v = not mainWin.v 
	end
	if thread:status() ~= "dead" and not isGamePaused() then 
		renderFontDrawText(fontPD, "Отыгровка: [{F25D33}Page Down{FFFFFF}] - Приостановить", 20, sy-30, 0xFFFFFFFF)
		if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() then
			thread:terminate()
			statusvac = false
		end
	end
	if sampIsDialogActive() then
		if arep then
			local idD = sampGetCurrentDialogId()
			if idD == 1333 then
				HideDialog()
			lockPlayerControl(false)
			end
		end
	end
	if cb_hud.v then showInputHelp() end
	if cb_hudTime.v and not isPauseMenuActive() then hudTimeF() end
		imgui.Process = mainWin.v or iconwin.v or sobWin.v or depWin.v or updWin.v or spurBig.v
  end
 
end

function sampRegCMDLoadScript()
	sampRegisterChatCommand(cmdBind[1].cmd, function() mainWin.v = not mainWin.v end)
	sampRegisterChatCommand(cmdBind[4].cmd, funCMD.memb)
	sampRegisterChatCommand(cmdBind[5].cmd, funCMD.lec)
	sampRegisterChatCommand(cmdBind[6].cmd, funCMD.post)
	sampRegisterChatCommand(cmdBind[7].cmd, funCMD.med)
	sampRegisterChatCommand(cmdBind[8].cmd, funCMD.narko)
	sampRegisterChatCommand(cmdBind[9].cmd, funCMD.recep)
	sampRegisterChatCommand(cmdBind[10].cmd, funCMD.osm)
	sampRegisterChatCommand(cmdBind[11].cmd, funCMD.dep)
	sampRegisterChatCommand(cmdBind[12].cmd, funCMD.sob)
	sampRegisterChatCommand(cmdBind[13].cmd, funCMD.tatu)
	sampRegisterChatCommand(cmdBind[14].cmd, funCMD.warn)
	sampRegisterChatCommand(cmdBind[15].cmd, funCMD.uwarn)
	sampRegisterChatCommand(cmdBind[16].cmd, funCMD.mute)
	sampRegisterChatCommand(cmdBind[17].cmd, funCMD.umute)
	sampRegisterChatCommand(cmdBind[18].cmd, funCMD.rank)
	sampRegisterChatCommand(cmdBind[19].cmd, funCMD.inv)
	sampRegisterChatCommand(cmdBind[20].cmd, funCMD.unv)
	sampRegisterChatCommand(cmdBind[22].cmd, funCMD.expel)
	sampRegisterChatCommand(cmdBind[23].cmd, funCMD.vac)
	sampRegisterChatCommand(cmdBind[24].cmd, funCMD.info)
	sampRegisterChatCommand(cmdBind[25].cmd, funCMD.za)
	sampRegisterChatCommand(cmdBind[26].cmd, funCMD.zd)
	sampRegisterChatCommand(cmdBind[27].cmd, funCMD.ant)
	sampRegisterChatCommand(cmdBind[28].cmd, funCMD.strah)
	sampRegisterChatCommand(cmdBind[29].cmd, funCMD.cur)
	sampRegisterChatCommand(cmdBind[32].cmd, funCMD.shpora)
	sampRegisterChatCommand("hall", funCMD.hall)
	sampRegisterChatCommand("hilka", funCMD.hilka)
	sampRegisterChatCommand("reload", function() scr:reload() end)
	--sampRegisterChatCommand("hme", funCMD.hme)
	sampRegisterChatCommand("update", function() updWin.v = not updWin.v end)
	sampRegisterChatCommand("ts", funCMD.time)
	sampRegisterChatCommand("downloadupd", downloadupd)
	--sampRegisterChatCommand("testmh", funCMD.testmh)
	sampRegisterChatCommand("mh-delete", funCMD.del)
	for i,v in ipairs(binder.list) do
		sampRegisterChatCommand(binder.list[i].cmd, function() binderCmdStart() end)
	end
end

function sampRegCMD()
	if cmdBind[selected_cmd].cmd ==	cmdBind[1].cmd then sampRegisterChatCommand(cmdBind[1].cmd, function() mainWin.v = not mainWin.v end) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[4].cmd then	sampRegisterChatCommand(cmdBind[4].cmd, funCMD.memb) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[5].cmd then	sampRegisterChatCommand(cmdBind[5].cmd, funCMD.lec) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[6].cmd then	sampRegisterChatCommand(cmdBind[6].cmd, funCMD.post) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[7].cmd then	sampRegisterChatCommand(cmdBind[7].cmd, funCMD.med) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[8].cmd then	sampRegisterChatCommand(cmdBind[8].cmd, funCMD.narko) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[9].cmd then	sampRegisterChatCommand(cmdBind[9].cmd, funCMD.recep) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[10].cmd then sampRegisterChatCommand(cmdBind[10].cmd, funCMD.osm) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[11].cmd then sampRegisterChatCommand(cmdBind[11].cmd, funCMD.dep) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[12].cmd then sampRegisterChatCommand(cmdBind[12].cmd, funCMD.sob) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[13].cmd then sampRegisterChatCommand(cmdBind[13].cmd, funCMD.tatu) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[14].cmd then sampRegisterChatCommand(cmdBind[14].cmd, funCMD.warn) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[15].cmd then sampRegisterChatCommand(cmdBind[15].cmd, funCMD.uwarn) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[16].cmd then sampRegisterChatCommand(cmdBind[16].cmd, funCMD.mute) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[17].cmd then sampRegisterChatCommand(cmdBind[17].cmd, funCMD.umute) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[18].cmd then sampRegisterChatCommand(cmdBind[18].cmd, funCMD.rank) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[19].cmd then sampRegisterChatCommand(cmdBind[19].cmd, funCMD.inv) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[20].cmd then sampRegisterChatCommand(cmdBind[20].cmd, funCMD.unv) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[22].cmd then sampRegisterChatCommand(cmdBind[22].cmd, funCMD.expel) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[23].cmd then sampRegisterChatCommand(cmdBind[23].cmd, funCMD.vac) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[24].cmd then sampRegisterChatCommand(cmdBind[24].cmd, funCMD.info) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[25].cmd then sampRegisterChatCommand(cmdBind[25].cmd, funCMD.za) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[26].cmd then sampRegisterChatCommand(cmdBind[26].cmd, funCMD.zd) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[27].cmd then sampRegisterChatCommand(cmdBind[27].cmd, funCMD.ant) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[28].cmd then sampRegisterChatCommand(cmdBind[28].cmd, funCMD.strah) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[29].cmd then sampRegisterChatCommand(cmdBind[29].cmd, funCMD.cur) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[32].cmd then sampRegisterChatCommand(cmdBind[32].cmd, funCMD.shpora) end
	for i,v in ipairs(binder.list) do
		sampRegisterChatCommand(binder.list[i].cmd, function() binderCmdStart() end)
	end
end

function HideDialog(bool)
	lua_thread.create(function()
		repeat wait(0) until sampIsDialogActive()
		while sampIsDialogActive() do
			local memory = require 'memory'
			memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
			sampToggleCursor(bool)
		end
	end)
end
imgui.GetIO().FontGlobalScale = 1.1

function getNearestID()
    local chars = getAllChars()
    local mx, my, mz = getCharCoordinates(PLAYER_PED)
    local nearId, dist = nil, 10000
    for i,v in ipairs(chars) do
        if doesCharExist(v) and v ~= PLAYER_PED then
            local vx, vy, vz = getCharCoordinates(v)
            local cDist = getDistanceBetweenCoords3d(mx, my, mz, vx, vy, vz)
            local r, id = sampGetPlayerIdByCharHandle(v)
            if r and cDist < dist then
                dist = cDist
                nearId = id
            end
        end
    end
    return nearId
end

function mainSet()
imgui.SetCursorPosX(25)
imgui.BeginGroup()
imgui.PushItemWidth(300);
	if imgui.InputText(u8"Имя и Фамилия: ", buf_nick, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[а-Я%s]+")) then needSave = true end
		if not imgui.IsItemActive() and buf_nick.v == "" then
			imgui.SameLine()
			ShowHelpMarker(u8"Имя и Фамилия заполняется на \nрусском без нижнего подчёркивания.\n\n  Пример: Кевин Хатико")
			imgui.SameLine()
			imgui.SetCursorPosX(30)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите Ваше Имя и Фамилию");
		else
			imgui.SameLine()
			ShowHelpMarker(u8"Имя и Фамилия заполняется на \nрусском без нижнего подчёркивания.\n\n  Пример: Кевин Хатико")
		end
			if imgui.InputText(u8"Тег в рацию ", buf_teg) then needSave = true end
			imgui.SameLine(); ShowHelpMarker(u8"Тег для рации может быть необязательным,\n уточните у других сотрудников или Лидера.\n\nПример: [Ваш Тег]")
			imgui.PushItemWidth(278);
			imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
				if imgui.Button(fa.ICON_COG.."##1", imgui.ImVec2(21,20)) then
					chgName.inp.v = chgName.org[num_org.v+1]
					imgui.OpenPopup(u8"MH | Изменение названия больницы")
				end
			imgui.PopStyleVar(1)
			imgui.SameLine(22)
			if imgui.Combo(u8"Организация ", num_org, chgName.org) then needSave = true end
			imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
				if imgui.Button(fa.ICON_COG.."##2", imgui.ImVec2(21,20)) then
					chgName.inp.v = chgName.rank[num_rank.v+1]
					imgui.OpenPopup(u8"MH | Изменение названия должности")
				end
			imgui.PopStyleVar(1)
			imgui.SameLine(22)
			if imgui.Combo(u8"Должность ", num_rank, chgName.rank) then needSave = true end
		imgui.PopItemWidth()
		if imgui.Combo(u8"Ваш пол ", num_sex, list_sex) then needSave = true end
	imgui.PopItemWidth()
	imgui.EndGroup()
	if imgui.BeginPopupModal(u8"MH | Изменение названия больницы", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"Название больницы будет применено к текущему названию")
		imgui.PushItemWidth(390)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"Сохранить", imgui.ImVec2(126,23)) then
			local exist = false
			for i,v in ipairs(chgName.org) do
				if v == chgName.inp.v and i ~= num_org.v+1 then
					exist = true
				end
			end
			if not exist then
				chgName.org[num_org.v+1] = chgName.inp.v
				needSave = true
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
			chgName.org[num_org.v+1] = list_org[num_org.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"Отмена", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8"MH | Изменение названия должности", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"Название должности будет применено к текущему названию")

		imgui.PushItemWidth(200)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"Сохранить", imgui.ImVec2(126,23)) then
			local exist = false
			for i,v in ipairs(chgName.rank) do
				if v == chgName.inp.v and i ~= num_rank.v+1 then
					exist = true
				end
			end
			if not exist then
				chgName.rank[num_rank.v+1] = chgName.inp.v
				needSave = true
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
			chgName.rank[num_rank.v+1] = list_rank[num_rank.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"Отмена", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function mainTheme()
	imgui.SetCursorPosX(25)
	imgui.BeginGroup()
	imgui.PushItemWidth(150);
	if imgui.Combo(u8" Цвет темы главного меню", num_theme, list_theme) then needSave = true end
	imgui.Dummy(imgui.ImVec2(0, 2))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 2))
	if imgui.Checkbox(u8"Закругление углов интерфейса", theme_Angle) then needSave = true end
	imgui.PopItemWidth()
	imgui.EndGroup()
end

function mainGameSimplification()
	imgui.SetCursorPosX(25)
	imgui.BeginGroup()
	imgui.PushItemWidth(150);
	imgui.Dummy(imgui.ImVec2(0, 2))
	if imgui.Checkbox(u8"Уведомлять звуковым сигналом о спавне авто", accept_spawn) then needSave = true end
	imgui.SameLine()
	ShowHelpMarker(u8"Когда в чате от администрации появится сообщение о том, что в скором\nвремени будет спавн авто, Вы будете уведомлены звуковым сигналом.")
	imgui.Dummy(imgui.ImVec2(0, 2))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 2))
	if imgui.Checkbox(u8"Автолечение по просьбе", accept_autolec) then needSave = true end
	imgui.SameLine()
	ShowHelpMarker(u8"Когда игрок в чат напишет сообщение, что его нужно вылечить,\nВам будет предложено вылечить его по нажатию кнопки.")
	imgui.PopItemWidth()
	imgui.EndGroup()
end

function point_sum(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
function imgui.ButtonArrow()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddTriangleFilled(imgui.ImVec2(p.x + 39, p.y), imgui.ImVec2(p.x + 50, p.y + 64),imgui.ImVec2(p.x + 7, p.y - 2), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
	imgui.GetWindowDrawList():AddTriangleFilled(imgui.ImVec2(p.x + 59, p.y + 50), imgui.ImVec2(p.x + 8, p.y + 47),imgui.ImVec2(p.x + 72, p.y - 58), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
end
function imgui.ButtonArrowLine()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 122, p.y + 3), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]), 0.0)
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 100), imgui.ImVec2(p.x + 123, p.y + 42), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]), 0.0)
end
function imgui.ses()
local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + 30, p.y+ 30), imgui.ImVec2(p.x+ 30, p.y+ 30), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Button]), 0.0, 12.0)
end

function imgui.OnDrawFrame()
	if mainWin.v then
	--sampCreate3dTextEx(1, string.format('ТРЕБУЕТ ЛЕЧЕНИЯ'), 0x60FFFFFF, 0, 0, -0.5, 3, false, 27, -1)
		--testwin()
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(854, 454), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_HEARTBEAT .. " Medical Helper by Kane "..scr.version, mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			--///// Func menu button
			imgui.BeginChild("Mine menu", imgui.ImVec2(139, 0), false)
			--imgui.SameLine()
			--imgui.SetCursorPosX(52)
			--imgui.ses()
				if select_menu[1] then
					if ButtonMenu(fa.ICON_USERS .. u8"  Главное", select_menu[1]) then select_menu = {true, false, false, false, false, false, false, false, false}; end
				else
					if ButtonMenu("  ".. fa.ICON_USERS .. u8"  Главное", select_menu[1]) then select_menu = {true, false, false, false, false, false, false, false, false}; end
				end
				imgui.Spacing()
				if select_menu[2] then
					if ButtonMenu(fa.ICON_WRENCH .. u8"  Наcтрoйки", select_menu[2]) then select_menu = {false, true, false, false, false, false, false, false, false} end
				else
					if ButtonMenu("  ".. fa.ICON_WRENCH .. u8"  Настройки", select_menu[2]) then select_menu = {false, true, false, false, false, false, false, false, false} end
				end	
				imgui.Spacing()
				if select_menu[3] then
					if ButtonMenu(fa.ICON_TERMINAL .. u8"  Команды", select_menu[3]) then select_menu = {false, false, true, false , false, false, false, false, false} end	
				else
					if ButtonMenu("  "..fa.ICON_TERMINAL .. u8"  Команды", select_menu[3]) then select_menu = {false, false, true, false , false, false, false, false, false} end	
				end
				imgui.Spacing()
				if select_menu[4] then
					if ButtonMenu(fa.ICON_KEYBOARD_O .. u8"  Биндер", select_menu[4]) then select_menu = {false, false, false, true, false, false, false, false, false} end
				else
					if ButtonMenu("  "..fa.ICON_KEYBOARD_O .. u8"  Биндер", select_menu[4]) then select_menu = {false, false, false, true, false, false, false, false, false} end
				end
				imgui.Spacing()
				if select_menu[5] then
					if ButtonMenu(fa.ICON_FILE .. u8"  Шпоры", select_menu[5]) then select_menu = {false, false, false, false, true, false, false, false, false}; 
						getSpurFile() 
						spur.name.v = ""
						spur.text.v = ""
						spur.edit = false
						spurBig.v = false
						spur.select_spur = -1
					end
				else
					if ButtonMenu("  "..fa.ICON_FILE .. u8"  Шпоры", select_menu[5]) then select_menu = {false, false, false, false, true, false, false, false, false}; 
						getSpurFile() 
						spur.name.v = ""
						spur.text.v = ""
						spur.edit = false
						spurBig.v = false
						spur.select_spur = -1
					end
				end
				imgui.Spacing()
				if select_menu[7] then
					if ButtonMenu(fa.ICON_MONEY .. u8"  Прибыль", select_menu[7]) then select_menu = {false, false, false, false, false, false, true, false, false} end
				else
					if ButtonMenu("  "..fa.ICON_MONEY .. u8"  Прибыль", select_menu[7]) then select_menu = {false, false, false, false, false, false, true, false, false} end
				end
				imgui.Spacing()
				if select_menu[6] then
					if ButtonMenu(fa.ICON_QUESTION .. u8"  Помощь", select_menu[6]) then select_menu = {false, false, false, false, false, true, false, false, false} end
				else
					if ButtonMenu("  "..fa.ICON_QUESTION .. u8"  Помощь", select_menu[6]) then select_menu = {false, false, false, false, false, true, false, false, false} end
				end
				imgui.Spacing()
				if select_menu[9] then
					if ButtonMenu(fa.ICON_CODE .. u8"  О скрипте", select_menu[9]) then select_menu = {false, false, false, false, false, false, false, false, true} end
				else
					if ButtonMenu("  "..fa.ICON_CODE .. u8"  О скрипте", select_menu[9]) then select_menu = {false, false, false, false, false, false, false, false, true} end
				end
			imgui.EndChild();
			
			--///// Main menu
			if select_menu[1] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginGroup()
				imgui.Dummy(imgui.ImVec2(0, 130))
				local colorInfo = imgui.ImColor(240, 170, 40, 255):GetVec4()
				imgui.Separator()
				imgui.Separator()
				imgui.SetCursorPosX(425)
				imgui.TextColoredRGB("Информация о Вас"); 
				imgui.Separator()
				imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Indent(10)
					imgui.Text(fa.ICON_ADDRESS_CARD .. u8"  Имя и Фамилия: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.name())
						imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(fa.ICON_HOSPITAL_O .. u8"  Организация: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.org());
						imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(fa.ICON_USER .. u8"  Должность: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.rank());
						imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(fa.ICON_TRANSGENDER .. u8"  Пол: ");
						imgui.SameLine();
						imgui.TextColored(colorInfo, PlayerSet.sex())
						PlayerSet.theme()
				
			imgui.EndGroup()
			imgui.Separator()
			imgui.Spacing()
			imgui.EndGroup()
			end
			--/////Setting
			if select_menu[2] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("settig", imgui.ImVec2(0, 386), true)
				imgui.Text(fa.ICON_ANGLE_RIGHT .. u8" Данный раздел предназначен для полной настройки скрипта под свой вкус");
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 8))
				imgui.Indent(2)
				if imgui.CollapsingHeader(u8"Основная информация") then
					mainSet()
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"Настройки чата") then
					imgui.SetCursorPosX(25)
					imgui.BeginGroup()
						if imgui.Checkbox(u8"Скрыть объявления", cb_chat1) then needSave = true end
						if imgui.Checkbox(u8"Скрыть подсказки сервера", cb_chat2) then needSave = true end
						if imgui.Checkbox(u8"Скрыть новости СМИ", cb_chat3) then needSave = true end
						if imgui.Checkbox(u8"ChatHUD", cb_hud) then needSave = true end;
						imgui.SameLine(); ShowHelpMarker(u8"Полезная информация под \nокном ввода чата")
						if imgui.Checkbox(u8"TimeHUD", cb_hudTime) then needSave = true end
						imgui.SameLine(); ShowHelpMarker(u8"Отобржение времени, языка и Caps Lock\n в нижней левой части экрана")
					imgui.EndGroup()
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"Отыгровки") then
					imgui.Separator()
					imgui.SetCursorPosX(25)
					imgui.BeginGroup()
						imgui.PushItemWidth(450); 
							imgui.SetCursorPosX(255)
							imgui.Text(u8"Часы")
								if imgui.Checkbox(u8"Отыгровка /me", cb_time) then needSave = true end
								if imgui.InputText(u8"Текст отыгровки", buf_time) then needSave = true end
							imgui.Separator()
							imgui.SetCursorPosX(255)
							imgui.Text(u8"Рация")
								if imgui.Checkbox(u8"Отыгровка /me##1", cb_rac) then needSave = true end
								if imgui.InputText(u8"Текст отыгровки##1", buf_rac) then needSave = true end
						imgui.PopItemWidth()
						imgui.Spacing()
						if imgui.Button(u8"Редактировать отыгровку Мед.карты", imgui.ImVec2(270, 25)) then 
							mcEditWin.v = not mcEditWin.v
						end
					imgui.EndGroup();
				end
				imgui.Dummy(imgui.ImVec2(0, 3)) 
				if imgui.CollapsingHeader(u8"Ценовая политика") then
					imgui.SetCursorPosX(25);
					imgui.BeginGroup()
						imgui.PushItemWidth(100); 
							if imgui.InputText(u8"Лечение", buf_lec, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"Сведение тату", buf_tatu, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"Выдача рецептов (цену устанавливает сервер автоматически)", buf_rec, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"Лечение от наркозависимости (цену устанавливает сервер автоматически)", buf_narko, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							if imgui.InputText(u8"Антибиотик (цену устанавливает сервер автоматически)", buf_ant, imgui.InputTextFlags.CharsDecimal) then needSave = true end
							imgui.Text(u8"Цены на мед. карту выставляются в самой отыгровке мед. карты через переменные \nв подразделе \"Отыгровки\"")
							imgui.Spacing()
						imgui.PopItemWidth()
					imgui.EndGroup();
					imgui.TextWrapped(u8"Более подробно можете узнать на форуме по пути forum.arizona-rp.com -> Игровые сервра: Ваш текущий сервер -> Гос. стурктуры -> Мин.Здрав.")
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"Кастомизация интерфейса") then
					mainTheme()
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.CollapsingHeader(u8"Упрощение игры") then
					mainGameSimplification()
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				--[[if imgui.CollapsingHeader(u8"Загрузка изображений") then
					imgui.TextWrapped(u8"Вы можете отключить большую часть картинок во вкладке \"Дискорд\", чтобы лишний раз не нагружать игру.")
					imgui.Spacing()
					if imgui.Checkbox(u8"Отключить изображения во вкладке - Дискорд", cb_imageDis) then needSave = true end
				end]]

			imgui.EndChild();
			
			imgui.PushStyleColor(imgui.Col.Button, needSaveColor)
			if imgui.Button(u8"Сохранить", imgui.ImVec2(695, 25)) then 
				settingMassiveSave()
					for i,v in ipairs(chgName.org) do
						setting.orgl[i] = u8:decode(v)
					end
					for i,v in ipairs(chgName.rank) do
						setting.rankl[i] = u8:decode(v)
					end
				local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
					f:write(encodeJson(setting))
					f:flush()
					f:close()
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
				needSave = false
			end
			imgui.PopStyleColor(1)
			imgui.EndGroup()
				if reloadScriptStyleWin == true then
					scr:reload()
				end
			end
			--/////Command
			if select_menu[3] then
			imgui.SameLine()
			imgui.BeginGroup()
				imgui.Text(u8"Здесь находится список новых команд, к которым можете применить клавишу активации.")
				imgui.Separator();
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.BeginChild("cmd list", imgui.ImVec2(0, 335), true)
					imgui.Columns(3, "keybinds", true); 
					imgui.SetColumnWidth(-1, 105); 
					imgui.Text(u8"Команда"); 
					imgui.NextColumn()
					imgui.SetColumnWidth(-1, 465); 
					imgui.Text(u8"Описание"); 
					imgui.NextColumn(); 
					imgui.Text(u8"Клавиша"); 
					imgui.NextColumn(); 
					imgui.Separator();
					for i,v in ipairs(cmdBind) do
						if num_rank.v+1 >= v.rank and 1.5 ~= v.rank then
							if imgui.Selectable(u8((string.format("/%s", u8:decode(v.cmd)))), selected_cmd == i, imgui.SelectableFlags.SpanAllColumns) then selected_cmd = i end
							imgui.NextColumn(); 
							imgui.Text(u8(v.desc)); 
							imgui.NextColumn();
							if #v.key == 0 then imgui.Text(u8"Нет") else imgui.Text(table.concat(rkeys.getKeysName(v.key), " + ")) end	
							imgui.NextColumn()
						else
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(228, 70, 70, 202):GetVec4())
							if imgui.Selectable(u8((string.format("/%s", u8:decode(v.cmd)))), selected_cmd == i, imgui.SelectableFlags.SpanAllColumns) then selected_cmd = i end
							imgui.NextColumn(); 
							imgui.Text(u8(v.desc)); 
							imgui.NextColumn(); 
							if #v.key == 0 then imgui.Text(u8"Нет") else imgui.Text(table.concat(rkeys.getKeysName(v.key), " + ")) end	
							imgui.NextColumn()
							imgui.PopStyleColor(1)
						end
					end
				imgui.EndChild();
					if cmdBind[selected_cmd].rank <= num_rank.v+1 and cmdBind[selected_cmd].rank ~= 1.5 then
						imgui.Text(u8"Выберите сначала интересующую Вас команду, после чего можете производить редактирование.")
						--imgui.Dummy(imgui.ImVec2(0, 1))
						if imgui.Button(u8"Назначить клавишу", imgui.ImVec2(165, 25)) then 
							imgui.OpenPopup(u8"MH | Установка клавиши для активации");
							lockPlayerControl(true)
							editKey = true
						end
						imgui.SameLine();
						if imgui.Button(u8"Очистить активацию", imgui.ImVec2(165, 25)) then 
							rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
							unRegisterHotKey(cmdBind[selected_cmd].key)
							cmdBind[selected_cmd].key = {}
								local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
								f:write(encodeJson(cmdBind))
								f:flush()
								f:close()
						end
						--//Изменить команду
						imgui.SameLine();
						if cmdBind[selected_cmd].cmd ~= "r" and cmdBind[selected_cmd].cmd ~= "rb" and cmdBind[selected_cmd].cmd ~= "time" then
						if imgui.Button(u8"Изменить команду", imgui.ImVec2(165, 25)) then 
							chgName.inp.v = cmdBind[selected_cmd].cmd
							unregcmd = chgName.inp.v
							imgui.OpenPopup(u8"MH | Редактирование команды");
						end
						else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Изменить команду", imgui.ImVec2(165, 25))
						imgui.PopStyleColor(3)
						end
						--//Редактировать отыгровку
						imgui.SameLine();
						if selected_cmd == 5 or selected_cmd == 7 then
							if imgui.Button(u8"Редактировать отыгровку", imgui.ImVec2(185, 25)) then
								if selected_cmd == 5 then
									local numbe = 1
									while setCmdEdit[5].text[numbe] ~= nil do
										chgCmdSet[numbe].v = setCmdEdit[5].text[numbe]
										if setCmdEdit[5].sec[numbe] ~= "" then
											chgCmd[numbe].v = setCmdEdit[5].sec[numbe] / 1000
										else
											chgCmd[numbe].v = 2100 / 1000
										end
										numbe = numbe + 1
									end
									actingOutWind.v = not actingOutWind.v
								end
								if selected_cmd == 7 then
									mcEditWin.v = not mcEditWin.v
								end
							end
						else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Редактировать отыгровку", imgui.ImVec2(185, 25))
						imgui.PopStyleColor(3)
						end
						imgui.SameLine();
					else 
						if cmdBind[selected_cmd].rank == 1.5 then
						imgui.Text(u8"Данная команда существует здесь для возможности быстрого взаимодействия")
						imgui.Text(u8"с игроками (правая кнопка мыши). Редактирование запрещено!")
						end
						if cmdBind[selected_cmd].rank ~= 1.5 then
						imgui.Text(u8"Данная команда Вам недоступна. Доступна только от " .. cmdBind[selected_cmd].rank .. u8" ранга")
						imgui.Text(u8"Если Ваш ранг соответствует требованиям, пожалуйста, измените должность в настройках.")
						end
					end
					
			imgui.EndGroup()
			end
			--/////shpora
			if select_menu[5] then
			imgui.SameLine()
				imgui.BeginGroup()
					imgui.BeginChild("spur list", imgui.ImVec2(140, 386), true)
						imgui.SetCursorPosX(10)
						imgui.Text(u8"Список шпаргалок")
						imgui.Separator()
							for i,v in ipairs(spur.list) do
								if imgui.Selectable(u8(spur.list[i]), spur.select_spur == i) then 
									spur.select_spur = i 
									spur.text.v = ""
									spur.name.v = ""
									spur.edit = false
									spurBig.v = false
								end
							end
					imgui.EndChild()
					if imgui.Button(u8"Добавить", imgui.ImVec2(140, 25)) then
						if #spur.list ~= 20 then
							for i = 1, 20 do
								if not table.concat(spur.list, "|"):find("Шпаргалка '"..i.."'") then
									table.insert(spur.list, "Шпаргалка '"..i.."'")
									spur.edit = true
									spur.select_spur = #spur.list
									spur.name.v = ""
									spur.text.v = ""
									spurBig.v = false
									local f = io.open(dirml.."/MedicalHelper/Шпаргалки/Шпаргалка '"..i.."'.txt", "w")
									f:write("")
									f:flush()
									f:close()
									break
								end
							end
						end
					end
				imgui.EndGroup()
					imgui.SameLine()
				imgui.BeginGroup()
					--	
						if spur.edit and not spurBig.v then
							imgui.SetCursorPosX(515)
							imgui.Text(u8"Поле для заполнения")
							imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
							imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(550, 300))
							imgui.PopStyleColor(1)
							imgui.PushItemWidth(400)
						--	imgui.SetCursorPosX(155+140+110)
							if imgui.Button(u8"Открыть большой редактор/просмотр", imgui.ImVec2(550, 25)) then spurBig.v = not spurBig.v end
							imgui.Spacing() 
						--	imgui.SetCursorPosX(445)
							imgui.InputText(u8"Название шпоры", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)]"))
							imgui.Spacing()
							imgui.PopItemWidth()
						--	imgui.SetCursorPosX(415)
							if imgui.Button(u8"Удалить", imgui.ImVec2(272, 25)) then
								if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
									os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
								end
								table.remove(spur.list, spur.select_spur) 
								spur.edit = false
								spur.select_spur = -1
								spur.name.v = ""
								spur.text.v = ""
							end
							imgui.SameLine()
							if imgui.Button(u8"Сохранить", imgui.ImVec2(272, 25)) then
								local name = ""
								local bool = false
								if spur.name.v ~= "" then 
										name = u8:decode(spur.name.v)
										if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
											bool = true
											imgui.OpenPopup(u8"Ошибка")
										else
											os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
											spur.list[spur.select_spur] = u8:decode(spur.name.v)
										end
								else
									name = spur.list[spur.select_spur]
								end
								if not bool then
									local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
									f:write(u8:decode(spur.text.v))
									f:flush()
									f:close()
									spur.text.v = ""
									spur.name.v = ""
									spur.edit = false
								end
							end
						elseif spurBig.v then
							imgui.Dummy(imgui.ImVec2(0, 150))
							imgui.SetCursorPosX(500)
							imgui.TextColoredRGB("Включено большое окно")
						elseif not spurBig.v and (spur.select_spur >= 1 and spur.select_spur <= 20) then
							imgui.Dummy(imgui.ImVec2(0, 150))
							imgui.SetCursorPosX(515)
							imgui.Text(u8"Выберите действие")
							imgui.Spacing()
							imgui.Spacing()
							imgui.SetCursorPosX(490)
							if imgui.Button(u8"Открыть для просмотра", imgui.ImVec2(170, 25)) then
								spurBig.v = true
							end
							imgui.Spacing()
							imgui.SetCursorPosX(490)
							if imgui.Button(u8"Редактировать", imgui.ImVec2(170, 25)) then
								spur.edit = true
								local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
								spur.text.v = u8(f:read("*a"))
								f:close()
								spur.name.v = u8(spur.list[spur.select_spur])
							end
							imgui.Spacing()
							imgui.SetCursorPosX(490)
							if imgui.Button(u8"Удалить", imgui.ImVec2(170, 25)) then
								if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
									os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
								end
								table.remove(spur.list, spur.select_spur) 
								spur.select_spur = -1
							end
						else
						imgui.Dummy(imgui.ImVec2(0, 150))
						imgui.SetCursorPosX(370)
						imgui.TextColoredRGB("Нажмите на кнопку {FF8400} \"Добавить\"")
						imgui.SameLine()
						imgui.TextColoredRGB("для создания новой шпаргалки\n\t\t\t\t\t\t\t\t\tили выберите уже существующую.")
						end

				imgui.EndGroup()
			end

			--//////Binder
			if select_menu[4] then
			
				imgui.SameLine()
				imgui.BeginGroup()
					imgui.BeginChild("bind list", imgui.ImVec2(140, 386), true)
						imgui.SetCursorPosX(23)
						imgui.Text(u8"Список биндов")
						imgui.Separator()
							for i,v in ipairs(binder.list) do
								if imgui.Selectable(u8(binder.list[i].name), binder.select_bind == i) then 
									binder.select_bind = i;
									
									binder.name.v = u8(binder.list[binder.select_bind].name)
									binder.sleep.v = binder.list[binder.select_bind].sleep
									binder.cmd.v = u8(binder.list[binder.select_bind].cmd)
									binder.key = binder.list[binder.select_bind].key
									if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
										local f = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "r")
										binder.text.v = u8(f:read("*a"))
										f:flush()
										f:close()
									end
									binder.edit = true 
								end
							end
					imgui.EndChild()
					if imgui.Button(u8"Добавить", imgui.ImVec2(140, 25)) then
						if #binder.list < 100 then
							for i = 1, 100 do
								local bool = false
								for ix,v in ipairs(binder.list) do
									if v.name == "Noname bind '"..i.."'" then bool = true end
								end
								if not bool then
									binder.list[#binder.list+1] = {name = "Noname bind '"..i.."'", key = {}, sleep = 0.5, cmd = ""}
									binder.edit = true
									binder.select_bind = #binder.list
									binder.name.v = ""
									binder.cmd.v = ""
									binder.sleep.v = 0.5
									binder.text.v = ""
									binder.key = {}
									break 
								end
							end
						end
					end

				imgui.EndGroup() 
					imgui.SameLine()
				imgui.BeginGroup()
					--	
						if binder.edit then
							imgui.SetCursorPosX(500)
							imgui.Text(u8"Поле для заполнения")
							imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
							imgui.InputTextMultiline("##bind", binder.text, imgui.ImVec2(550, 263))
							imgui.PopStyleColor(1)
							imgui.PushItemWidth(200)
							imgui.InputText(u8"Название бинда", binder.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)]"))
							
							if imgui.Button(u8"Назначить клавишу", imgui.ImVec2(200, 25)) then 
								imgui.OpenPopup(u8"MH | Установка клавиши для активации")
								editKey = true
							end 
							if #binder.list[binder.select_bind].key == 0 and #binder.key == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("Текущая клавиша: {F02626}Отсутствует")
							else
							imgui.SameLine()
							imgui.TextColoredRGB("Текущая клавиша: {1AEB1D}"..table.concat(rkeys.getKeysName(binder.key), " + "))
							end
							if imgui.Button(u8"Задать команду", imgui.ImVec2(200, 25)) then 
								chgName.inp.v = binder.cmd.v
								unregcmd = chgName.inp.v
								imgui.OpenPopup(u8"MH | Редактирование команды")
								editKey = true
							end 
							if binder.cmd.v == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("Текущая команда: {F02626}Отсутствует")
							else
							imgui.SameLine()
							imgui.TextColoredRGB("Текущая команда: {1AEB1D}/"..binder.cmd.v)
							end
							imgui.PushItemWidth(150)
							imgui.DragFloat("##sleep", binder.sleep, 0.1, 0.5, 10.0, u8"Задержка = %.1f сек.")
							imgui.SameLine()
							if imgui.Button("-", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 0.5 then binder.sleep.v = binder.sleep.v - 0.1 end
							imgui.SameLine()
							if imgui.Button("+", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 10 then binder.sleep.v = binder.sleep.v + 0.1 end
							imgui.PopItemWidth()
							imgui.SameLine()
							imgui.Text(u8"Интервал времени между проигрыванием строк")
						--	imgui.SetCursorPosX(345)
							if imgui.Button(u8"Удалить", imgui.ImVec2(120, 25)) then
								sampUnregisterChatCommand(binder.cmd.v)
								binder.text.v = ""
								binder.sleep.v = 0.5
								binder.name.v = ""
								binder.cmd.v = ""
								binder.edit = false 
								rkeys.unRegisterHotKey(binder.key)
								unRegisterHotKey(binder.key)
								binder.key = {}
								if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
									os.remove(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt")
								end
								table.remove(binder.list, binder.select_bind) 
								local f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
								f:write(encodeJson(binder.list))
								f:flush()
								f:close()
								binder.select_bind = -1 
							end
							imgui.SameLine()
							if imgui.Button(u8"Сохранить", imgui.ImVec2(120, 25)) then
								local bool = false
									if binder.name.v ~= "" then
										for i,v in ipairs(binder.list) do
											if v.name == u8:decode(binder.name.v) and i ~= binder.select_bind then bool = true end
										end
										
										if not bool then
											binder.list[binder.select_bind].name = u8:decode(binder.name.v)
										else
											imgui.OpenPopup(u8"Ошибка")
										end
									end
								
								if not bool then
									rkeys.registerHotKey(binder.key, true, onHotKeyBIND)
									binder.list[binder.select_bind].key = binder.key
									binder.list[binder.select_bind].cmd = binder.cmd.v
									local sec = string.format("%.1f", binder.sleep.v)
									binder.list[binder.select_bind].sleep = sec
									local text = u8:decode(binder.text.v)
									local cmd = u8:decode(binder.cmd.v)
									local saveJS = encodeJson(binder.list) 
									sampRegCMD()
									sampUnregisterChatCommand(unregcmd)
									local f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
									local ftx = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "w")
									f:write(saveJS)
									ftx:write(text)
									f:flush()
									ftx:flush()
									f:close()
									ftx:close()
								end
							end
							imgui.SameLine()
							if imgui.Button(u8"Тег-функции", imgui.ImVec2(127, 25)) then paramWin.v = not paramWin.v end
							imgui.SameLine()
							if imgui.Button(u8"Расширенные функции", imgui.ImVec2(165, 25)) then 
							profbWin.v = not profbWin.v
							--testfuncthe()
							end
							
							
						else
						
						imgui.Dummy(imgui.ImVec2(0, 150))
						imgui.SetCursorPosX(380)
						imgui.TextColoredRGB("Нажмите на кнопку {FF8400} \"Добавить\"")
						imgui.SameLine()
						imgui.TextColoredRGB("для создания нового бинда\n\t\t\t\t\t\t\t\t\tили выберите уже существующий.")
						end

				imgui.EndGroup()
			end
			--//////Help
			if select_menu[6] then
				imgui.SameLine()
				imgui.BeginChild("help but", imgui.ImVec2(0,0), true)
					imgui.Text(u8"Немного информации, которая может помочь Вам.")
					imgui.Separator()
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}Вкладка \"Настройки\"")
					imgui.TextWrapped(u8"\tБазовые настройки, которые требуется выставить перед началом работы, самые главные которые из них \"Основная информация\".")
					imgui.TextWrapped(u8"\tЦеновая политика актуальна для сервера Surprise, если у Вас другой сервер, пожалуйста измените значения.")
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}Вкладка \"Шпоры\"")
					imgui.TextWrapped(u8"\tМожно заполнять любого рода информацией, также можно самому создать текстовый файл в папке шпаргалок.")
					imgui.TextColoredRGB("{5BF165}Открыть папку Шпаргалок")
					if imgui.IsItemHovered() then 
						imgui.SetTooltip(u8"Кликните, чтобы открыть папку.")
					end
					if imgui.IsItemClicked(0) then
						print(shell32.ShellExecuteA(nil, 'open', dirml.."/MedicalHelper/Шпаргалки/", nil, nil, 1))
					end
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}Вкладка \"Команды\"")
					imgui.TextWrapped(u8"\tОсобенностью активацией команд является в том, что команды требующие в указании id игрока, могут быть активированы при сочетании наведнии мышки на игрока и нажатии бинд-активации. В резульате чего, команда автоматически введётся с указанным id игрока или откроется чат с введённым id.")
					imgui.TextColoredRGB("\t\tДополнительные команды, не внесённые в раздел:")
					imgui.TextColoredRGB("{FF5F29}/reload {FFFFFF}- команда для перезагрузки скрипта.")
					--imgui.TextColoredRGB("{FF5F29}/rl {FFFFFF}- независимая команда от скрипта, предназначенная для перезагрузки всей папки moonlaoder.")
					imgui.TextColoredRGB("{FF5F29}/update {FFFFFF}- команда для получения информации об обновлениях.")
					imgui.TextColoredRGB("{FF5F29}/mh-delete {FFFFFF} - удалить скрипт")
					--
					imgui.Bullet(); imgui.SameLine()
					imgui.TextColoredRGB("{FFB700}Вкладка \"Прибыль\"")
					imgui.TextWrapped(u8"\tВаша прибыль в организации за последнюю неделю.")
					--
					imgui.Separator()
					imgui.Spacing()
					imgui.TextColoredRGB("В случае возникновения проблемы с запуском скрипта попробуйте удалить файлы настроек после\n чего перезагрузить папку moonloader комбинацией {67EE7E}CTRL + R:\n\t{FF5F29}Удалить нужно папку {67EE7E}MedicalHelper{FF5F29} полностью.")
				imgui.EndChild()
			end
			--//////About
			if select_menu[9] then
				imgui.SameLine()
				imgui.BeginChild("about", imgui.ImVec2(0, 0), true)
					imgui.SetCursorPosX(280)
					imgui.Text(u8"Medical Helper by Kane")
					imgui.Spacing()
					imgui.TextWrapped(u8"\tСкрипт разработан для проекта Ariona Role Play для облегчения работы сотрудникам больниц.")
					imgui.Dummy(imgui.ImVec2(0, 10))
					imgui.Bullet()
					imgui.TextColoredRGB("Нынешний разработчик - {FFB700}Alberto Kane")
					imgui.Bullet()
					imgui.TextColoredRGB("Версия скрипта - {FFB700}".. scr.version)
					imgui.Bullet()
					--imgui.TextColoredRGB("Благодарность {32CD32}blast.hk{FFFFFF}, скриптеру {32CD32}Hatiko{FFFFFF} и скриптеру {32CD32}Cosmo{FFFFFF}. Без них не было бы этого скрипта.")
					imgui.TextColoredRGB("Благодарность {32CD32}blast.hk{FFFFFF}, скриптеру {32CD32}Hatiko{FFFFFF}, тестировщикам {32CD32}Ilya Kustov{FFFFFF} и {32CD32}Richard Andreson{FFFFFF}.")
					imgui.Bullet()
					imgui.TextColoredRGB("Скрипт не пренадлежит нынешнему разработчику. Скриптер лишь продолжает поддержку MH.")
					imgui.Bullet()
					imgui.TextColoredRGB("Распространение скрипта разрешено только на официальном сайте/канале {32CD32}Arizona RP{FFFFFF}!")
					--imgui.TextColoredRGB(" ")
					--imgui.Bullet()
					--imgui.TextColoredRGB("{FF0000}ВНИМАНИЕ!{FFFFFF} Если Вы установили данный скрипт не с официального форума {32CD32}Arizona RP{FFFFFF} \n      или не с официального канала {32CD32}Arizona RP{FFFFFF} в Discord, то срочно поменяйте пароль и \n      переустановите игру! После чего скачайте скрипт с официального форума {32CD32}Arizona RP{FFFFFF}.")
						imgui.Dummy(imgui.ImVec2(0, 20))
						imgui.SetCursorPosX(20)
						imgui.Text(fa.ICON_BUG)
						imgui.SameLine()
						imgui.TextColoredRGB("Нашли баг или ошибку, или же хотите видеть что-то новое, напиши разработчику скрипта"); imgui.SameLine(); imgui.Text(fa.ICON_ARROW_DOWN)
						imgui.SetCursorPosX(20)
						imgui.Text(fa.ICON_LINK)
						imgui.SameLine()
						imgui.TextColoredRGB("Для связи: VK: {74BAF4}vk.com/marseloy") 
							if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните ЛКМ, чтобы скопировать, или ПКМ, чтобы открыть в браузере")  end
							if imgui.IsItemClicked(0) then setClipboardText("https://vk.com/marseloy") end
							if imgui.IsItemClicked(1) then print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/marseloy', nil, nil, 1)) end
							imgui.SameLine()
							imgui.TextColoredRGB("{68E15D}(наведи){FFFFFF}  Нажав на странице {74BAF4}\"Написать сообщение\"")
						imgui.Spacing()
						imgui.SetCursorPosX(20)
						imgui.TextColored(imgui.ImColor(18, 220, 0, 200):GetVec4(), fa.ICON_MONEY)
						imgui.SameLine()
						imgui.TextColoredRGB("Желающие поддержать разработку денюшкой - ".."{68E15D}\"Открыть\"")
							if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните, чтобы открыть ссылку")  end
							if imgui.IsItemClicked(0) then print(shell32.ShellExecuteA(nil, 'open', 'https://qiwi.com/n/ALBERTOKANE', nil, nil, 1)) end
						imgui.TextColoredRGB(" ")
						imgui.TextColoredRGB(" ")
						imgui.TextColoredRGB(" ")
						imgui.TextColoredRGB(" ")	
						imgui.Dummy(imgui.ImVec2(0, 60))
						if imgui.Button(u8"Отключить", imgui.ImVec2(166, 26)) then showCursor(false); scr:unload() end
						imgui.SameLine()
						if imgui.Button(u8"Перезагрузить", imgui.ImVec2(166, 26)) then showCursor(false); scr:reload() end
						imgui.SameLine()
						if imgui.Button(u8"Проверить обновление", imgui.ImVec2(166, 26)) then funCMD.updateCheck() end
						imgui.SameLine()
						if imgui.Button(u8"Удалить скрипт", imgui.ImVec2(166, 26)) then 
							addOneOffSound(0, 0, 0, 1058)
							sampAddChatMessage("", 0xFF8FA2)
							sampAddChatMessage("", 0xFF8FA2)
							sampAddChatMessage("", 0xFF8FA2)
							sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Внимание! Подтвердите удаление командой {77DF63}/mh-delete.", 0xFF8FA2)
							mainWin.v = false
						--	sampShowDialog(1002, "{E94C4C}MedicalHelper | {8EE162}Удаление", remove, "Принял", "")
						end
				imgui.EndChild()
				

			end
			--/////Прибыль
			if select_menu[7] then
				profitmoney()
			end
			

			--///Установка клавиши
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
				if imgui.BeginPopupModal(u8"MH | Установка клавиши для активации", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
					
					imgui.Text(u8"Нажмите на клавишу или сочетание клавиш для установки активации."); imgui.Separator()
					imgui.Text(u8"Допускаются клавиши:")
					imgui.Bullet()	imgui.TextDisabled(u8"Клавиши для сочетаний - Alt, Ctrl, Shift")
					imgui.Bullet()	imgui.TextDisabled(u8"Английские буквы")
					imgui.Bullet()	imgui.TextDisabled(u8"Функциональные клавиши F1-F12")
					imgui.Bullet()	imgui.TextDisabled(u8"Цифры верхней панели")
					imgui.Bullet()	imgui.TextDisabled(u8"Боковая панель Numpad")
					imgui.Checkbox(u8"Использовать ПКМ в комбинации с клавишами", cb_RBUT)
					imgui.Separator()
					if imgui.TreeNode(u8"Для пользователей 5-кнопочной мыши") then
						imgui.Checkbox(u8"X Button 1", cb_x1)
						imgui.Checkbox(u8"X Button 2", cb_x2)
						imgui.Separator()
					imgui.TreePop();
					end
					imgui.Text(u8"Текущая клавиша(и): ");
					imgui.SameLine();
					
					if imgui.IsMouseClicked(0) then
						lua_thread.create(function()
							wait(500)
							
							setVirtualKeyDown(3, true)
							wait(0)
							setVirtualKeyDown(3, false)
						end)
					end
					
					if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then
						
						if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
							currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
							currentKey[2] = rkeys.getCurrentHotKey()
							
						end
					end
 
					imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
						if isHotKeyDefined then
							imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данный бинд уже существует!")
							--imgui.TextColored(imgui.ImColor(45, 225, 0, 200):GetVec4(), u8"Данный бинд уже существует!")
						end
						if imgui.Button(u8"Установить", imgui.ImVec2(150, 0)) then
							if select_menu[3] then
								if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
								if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
								if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
								if rkeys.isHotKeyExist(currentKey[2]) then 
									isHotKeyDefined = true
								else
									rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
									unRegisterHotKey(cmdBind[selected_cmd].key)
									cmdBind[selected_cmd].key = currentKey[2]
									rkeys.registerHotKey(currentKey[2], true, onHotKeyCMD)
									table.insert(keysList, currentKey[2])
									currentKey = {"",{}}
									lockPlayerControl(false)
									cb_RBUT.v = false
									cb_x1.v, cb_x2.v = false, false
									isHotKeyDefined = false
									imgui.CloseCurrentPopup();
										local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
										f:write(encodeJson(cmdBind))
										f:flush()
										f:close()
										editKey = false
								end
							elseif select_menu[4] then
								if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
								if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
								if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
								if rkeys.isHotKeyExist(currentKey[2]) then 
									isHotKeyDefined = true
								else	
									rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
									unRegisterHotKey(binder.list[binder.select_bind].key)
									binder.key = currentKey[2]
									currentKey = {"",{}}
									lockPlayerControl(false)
									cb_RBUT.v = false
									cb_x1.v, cb_x2.v = false, false
									isHotKeyDefined = false
									imgui.CloseCurrentPopup();
									editKey = false
								end
							end
						end
						imgui.SameLine();
						if imgui.Button(u8"Закрыть", imgui.ImVec2(150, 0)) then 
							imgui.CloseCurrentPopup(); 
							currentKey = {"",{}}
							cb_RBUT.v = false
							cb_x1.v, cb_x2.v = false, false
							lockPlayerControl(false)
							isHotKeyDefined = false
							editKey = false
						end 
						imgui.SameLine()
						if imgui.Button(u8"Очистить", imgui.ImVec2(150, 0)) then
							currentKey = {"",{}}
							cb_x1.v, cb_x2.v = false, false
							cb_RBUT.v = false
							isHotKeyDefined = false
						end
				imgui.EndPopup()
				end
				
			--///Редактор команды
				if imgui.BeginPopupModal(u8"MH | Редактирование команды", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
					imgui.SetCursorPosX(70)
					imgui.Text(u8"Введите новую команду на этот бинд, которую Вы пожелаете."); imgui.Separator()
					imgui.Text(u8"Примечания:")
					imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Разрешается заменять серверные команды.")
					imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если Вы замените серверную команду - Ваша команда станет приоритетной.")
					imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Нельзя использовать цифры и символы. Только английские буквы.")
					if select_menu[4] then
					imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Бинд на сокращение команд {e3071d}/findihouse{00ff8c} и {e3071d}/findibiz {00ff8c}карается баном!")
					end
					imgui.Text(u8"/");
					imgui.SameLine();
					imgui.PushItemWidth(520)
					imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%a]+"))
					--unregcmd = chgName.inp
						if isHotKeyDefined then
							imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данная команда уже существует!")
							--imgui.TextColored(imgui.ImColor(45, 225, 0, 200):GetVec4(), u8"Данная команда уже существует!")
						end
						if russkieBukviNahyi then
							imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Нельзя использовать русские буквы!")
							--imgui.TextColored(imgui.ImColor(224, 0, 0, 300):GetVec4(), u8"Нельзя использовать русские буквы!")
						end
						if dlinaStroki then
							imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Максимальная длина команды - 15 букв!")
						end
						
					if select_menu[3] then
						if imgui.Button(u8"Сохранить", imgui.ImVec2(174, 0)) then
							local exits = false
								if chgName.inp.v:find("%A") then
									russkieBukviNahyi = true
									isHotKeyDefined = false
									dlinaStroki = false
									exits = true
								elseif chgName.inp.v:len() > 15 then
									dlinaStroki = true
									russkieBukviNahyi = false
									isHotKeyDefined = false
									exits = true
								end
						
							for i,v in ipairs(binder.list) do
								if binder.list[i].cmd == chgName.inp.v then
									exits = true
									isHotKeyDefined = true
									russkieBukviNahyi = false
									dlinaStroki = false
								end
								if chgName.inp.v == binder.cmd.v then
									exits = true
									isHotKeyDefined = true
									russkieBukviNahyi = false
									dlinaStroki = false
								end
							end
							for i,v in ipairs(cmdBind) do
								if v.cmd == chgName.inp.v and chgName.inp.v ~= cmdBind[selected_cmd].cmd then
									exits = true
									isHotKeyDefined = true
									russkieBukviNahyi = false
									dlinaStroki = false
								end
							end
							if not exits then
								if cmdBind[selected_cmd].cmd == chgName.inp.v then
									isHotKeyDefined = false
									russkieBukviNahyi = false
									dlinaStroki = false
									imgui.CloseCurrentPopup();
								else
									isHotKeyDefined = false
									russkieBukviNahyi = false
									dlinaStroki = false
									cmdBind[selected_cmd].cmd = chgName.inp.v
									imgui.CloseCurrentPopup();
									local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
									f:write(encodeJson(cmdBind))
									f:flush()
									f:close()
									sampRegCMD()
									sampUnregisterChatCommand(unregcmd)
									editKey = false
								end
							end
						end
					end
						
					if select_menu[4] then
						if imgui.Button(u8"Применить", imgui.ImVec2(174, 0)) then
						local exits = false
							if chgName.inp.v:find("%A") then
								russkieBukviNahyi = true
								isHotKeyDefined = false
								dlinaStroki = false
								exits = true
							elseif chgName.inp.v:len() > 15 then
								dlinaStroki = true
								russkieBukviNahyi = false
								isHotKeyDefined = false
								exits = true
							end
						
						for i,v in ipairs(cmdBind) do
							if v.cmd == chgName.inp.v then
								exits = true
								isHotKeyDefined = true
								russkieBukviNahyi = false
								dlinaStroki = false
							end
						end
						for i,v in ipairs(binder.list) do
							if binder.list[i].cmd == chgName.inp.v and chgName.inp.v ~= binder.cmd.v and chgName.inp.v ~= "" then
								exits = true
								isHotKeyDefined = true
								russkieBukviNahyi = false
								dlinaStroki = false
							end
						end
							if not exits then
								if binder.cmd.v == chgName.inp.v then
									unregcmd = ""
									isHotKeyDefined = false
									russkieBukviNahyi = false
									dlinaStroki = false
									imgui.CloseCurrentPopup();
								else
									isHotKeyDefined = false
									russkieBukviNahyi = false
									dlinaStroki = false
									binder.cmd.v = chgName.inp.v
									imgui.CloseCurrentPopup();
									editKey = false
								end
							end
						end
					end
							
						imgui.SameLine();
						if imgui.Button(u8"Закрыть", imgui.ImVec2(174, 0)) then 
							imgui.CloseCurrentPopup(); 
							currentKey = {"",{}}
							cb_RBUT.v = false
							cb_x1.v, cb_x2.v = false, false
							lockPlayerControl(false)
							isHotKeyDefined = false
							russkieBukviNahyi = false
							dlinaStroki = false
							editKey = false
							unregcmd = ""
						end 
						imgui.SameLine()
						if select_menu[3] then
							if imgui.Button(u8"Вернуть стандартную", imgui.ImVec2(174, 0)) then
								chgName.inp.v = list_cmd[selected_cmd]
								isHotKeyDefined = false
								russkieBukviNahyi = false
								dlinaStroki = false
							end
						end
						if select_menu[4] then
							if imgui.Button(u8"Очистить строку", imgui.ImVec2(174, 0)) then
								chgName.inp.v = ""
								isHotKeyDefined = false
								russkieBukviNahyi = false
								dlinaStroki = false
							end
						end
				imgui.EndPopup()
				end
				
				if imgui.BeginPopupModal(u8"Ошибка", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
					imgui.Text(u8"Данное название уже существует")
					imgui.SetCursorPosX(60)
					if imgui.Button(u8"Ок", imgui.ImVec2(120, 20)) then imgui.CloseCurrentPopup() end
				imgui.EndPopup()
				end
				
				imgui.PopStyleColor(1)
			imgui.End()
			
	end

	if iconwin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", iconwin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
	
	end
	
	if actingOutWind.v then
	local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1100, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"MH | Редактирование отыгровки", actingOutWind, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}Отредактируйте отыгровку на Вашу собственную, если это требуется. ", imgui.GetMaxWidthByText(""))

	imgui.BeginChild("redactor", imgui.ImVec2(1085, 341.5), true)
		imgui.Columns(3, "acting out", true);
			imgui.SetColumnWidth(-1, 50);
			imgui.Text(u8"№ От.");
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 890);
			imgui.Text(u8"Текст отыгровки"); 
			imgui.NextColumn();
			imgui.Text(u8"Задержка после");
			imgui.NextColumn();
			imgui.Separator();
				--/////1
			local numOut = 1
			while setCmdEdit[5].text[numOut] ~= nil do
				imgui.SameLine()
				imgui.Dummy(imgui.ImVec2(0, 2))
				imgui.Text(u8("["..numOut.."]"));
				imgui.NextColumn();
				imgui.PushItemWidth(880)
				imgui.InputText(u8"##chat"..numOut, chgCmdSet[numOut])
				imgui.NextColumn(); 
				imgui.PushItemWidth(80)
				imgui.DragFloat(u8"##sleep"..numOut, chgCmd[numOut], 0.1, 1.0, 10.0, u8"%.1f сек.")
				imgui.SameLine()
					if imgui.Button("-".."##"..numOut, imgui.ImVec2(20, 20)) and chgCmd[numOut].v ~= 1.0 then chgCmd[numOut].v = chgCmd[numOut].v - 0.1 end
					imgui.SameLine()
					if imgui.Button("+".."##"..numOut, imgui.ImVec2(20, 20)) and chgCmd[numOut].v ~= 10 then chgCmd[numOut].v = chgCmd[numOut].v + 0.1 end
				imgui.PopItemWidth()
				imgui.NextColumn();
				imgui.Separator();
			numOut = numOut + 1
			end
				--/////2
				imgui.SameLine()
				imgui.Dummy(imgui.ImVec2(0, 1))
				imgui.Text(u8("["..numOut.."]"));
				imgui.SameLine()
				imgui.NextColumn();
				imgui.PushItemWidth(860)
				imgui.Text(u8("/heal [id] [Цена]"))
				imgui.NextColumn();
				imgui.PushItemWidth(80)
				imgui.Text(u8("-"))
				imgui.PopItemWidth()
				imgui.NextColumn();
				imgui.Separator();
		imgui.EndChild()
		imgui.BeginGroup()
		imgui.Dummy(imgui.ImVec2(0, 13))
		imgui.TextColoredRGB("{FF0000}[!]  {C1C1C1}Пустая строка пропускает отыгровку.")
		imgui.Dummy(imgui.ImVec2(0, 6))
		imgui.TextColoredRGB("{FF0000}[!]  {C1C1C1}Переменная {sex:понял|поняла}, вернёт 'понял', если выбран мужской пол или 'поняла', если женский.")
		imgui.Dummy(imgui.ImVec2(0, 77))
		imgui.EndGroup()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(358, 25)) then
				settingMassiveSave2()
				local f = io.open(dirml.."/MedicalHelper/Отыгровки.med", "w")
					f:write(encodeJson(setCmdEdit))
					f:flush()
					f:close()
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
				needSave = false
				local numOut = 1
				actingOutWind.v = not actingOutWind.v
			end
			imgui.SameLine();
			if imgui.Button(u8"Сбросить и сохранить", imgui.ImVec2(358, 25)) then
			local numMasGet = 1
				while numMasGet ~= 11 do
					setCmdEdit[selected_cmd].sec[numMasGet] = setCmdEditDefolt[selected_cmd].sec[numMasGet]
					setCmdEdit[selected_cmd].text[numMasGet] = setCmdEditDefolt[selected_cmd].text[numMasGet]
					numMasGet = numMasGet + 1
				end
				local f = io.open(dirml.."/MedicalHelper/Отыгровки.med", "w")
					f:write(encodeJson(setCmdEdit))
					f:flush()
					f:close()
					sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
					needSave = false
					actingOutWind.v = not actingOutWind.v
			end
			imgui.SameLine();
			if imgui.Button(u8"Закрыть", imgui.ImVec2(358, 25)) then actingOutWind.v = not actingOutWind.v end
		imgui.End()
	end
		
	if paramWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(820, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"Код-параметры для биндера", paramWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}Кликни мышкой по самому тегу, чтобы скопировать его.", imgui.GetMaxWidthByText("Кликни мышкой по самому тегу, чтобы скопировать его."))
		imgui.Dummy(imgui.ImVec2(0, 15))
		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myID}")
		imgui.SameLine()
		if imgui.IsItemHovered(0) then setClipboardText("{myID}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш id - {ACFF36}"..tostring(myid))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myNick}");  end
		imgui.TextColoredRGB("{C1C1C1} - Ваш полный ник (по анг.) - {ACFF36}"..tostring(myNick:gsub("_"," ")))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRusNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRusNick}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш ник, указанный в настройках - {ACFF36}"..tostring(u8:decode(buf_nick.v)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHP}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHP}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш уровень ХП - {ACFF36}"..tostring(getCharHealth(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myArmo}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myArmo}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш текущий уровень брони - {ACFF36}"..tostring(getCharArmour(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHosp}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHosp}") end
		imgui.TextColoredRGB("{C1C1C1} - название Вашей больницы - {ACFF36}"..tostring(u8:decode(chgName.org[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHospEn}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHospEn}") end
		imgui.TextColoredRGB("{C1C1C1} - полное название Вашей больницы на анг. - {ACFF36}"..tostring(u8:decode(list_org_en[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myTag}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myTag}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш тег  - {ACFF36}"..tostring(u8:decode(buf_teg.v)))
		
		imgui.Spacing()		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRank}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRank}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваша должность - {ACFF36}"..tostring(u8:decode(chgName.rank[num_rank.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{time}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{time}") end
		imgui.TextColoredRGB("{C1C1C1} - время в формате часы:минуты:секунды - {ACFF36}"..tostring(os.date("%X")))
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{day}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{day}") end
		imgui.TextColoredRGB("{C1C1C1} - текущий день месяца - {ACFF36}"..tostring(os.date("%d")))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{week}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{week}") end
		imgui.TextColoredRGB("{C1C1C1} - текущая неделя - {ACFF36}"..tostring(week[tonumber(os.date("%w"))+1]))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{month}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{month}") end
		imgui.TextColoredRGB("{C1C1C1} - текущий месяц - {ACFF36}"..tostring(month[tonumber(os.date("%m"))]))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{getNickByTarget}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByTarget}") end
		imgui.TextColoredRGB("{C1C1C1} - получает Ник игрока на которого последний раз целился.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{target}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{target}") end
		imgui.TextColoredRGB("{C1C1C1} - последний ID игрока, на которого целился (наведена мышь) - {ACFF36}"..tostring(targID))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{pause}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{pause}") end
		imgui.TextColoredRGB("{C1C1C1} - создание паузы между отправки строки в чат. {EC3F3F}Прописывать отдельно, т.е. с новой строки.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sleep:время}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sleep:1000}") end
		imgui.TextColoredRGB("{C1C1C1} - Задаёт свой интервал времени между строчками. \n\tПример: {sleep:2500}, где 2500 время в мс (1 сек = 1000 мс)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sex:текст1|текст2}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sex:text1|text2}") end
		imgui.TextColoredRGB("{C1C1C1} - Возвращает текст в зависимости от выбранного пола.  \n\tПример, {sex:понял|поняла}, вернёт 'понял', если выбран мужской пол или 'поняла', если женский")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{getNickByID:ид игрока}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByID:}") end
		imgui.TextColoredRGB("{C1C1C1} - Возращает ник игрока по его ID. \n\tПример, {getNickByID:25}, вернёт ник игрока под ID 25.)")
		
		imgui.End()
	end
	
	if spurBig.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1098, 790), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Редактор Шпаргалки", spurBig, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		if spur.edit then
				imgui.SetCursorPosX(350)
				imgui.Text(u8"Большое окно для редактирования / просмотра шпоргалок")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(1081, 700))
				imgui.PopStyleColor(1)
				if imgui.Button(u8"Сохранить", imgui.ImVec2(357, 25)) then
					local name = ""
					local bool = false
					if spur.name.v ~= "" then 
							name = u8:decode(spur.name.v)
							if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
								bool = true
								imgui.OpenPopup(u8"Ошибка")
							else
								os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
								spur.list[spur.select_spur] = u8:decode(spur.name.v)
							end
					else
						name = spur.list[spur.select_spur]
					end
					if not bool then
						local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
						f:write(u8:decode(spur.text.v))
						f:flush()
						f:close()
						spur.text.v = ""
						spur.name.v = ""
						spur.edit = false
					end
				end
				imgui.SameLine()
				if imgui.Button(u8"Удалить", imgui.ImVec2(357, 25)) then
					spur.text.v = ""
					table.remove(spur.list, spur.select_spur) 
					spur.select_spur = -1
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..u8:decode(spur.select_spur)..".txt") then
						os.remove(dirml.."/MedicalHelper/Шпаргалки/"..u8:decode(spur.select_spur)..".txt")
					end
					spur.name.v = ""
					spurBig.v = false
					spur.edit = false
				end
				imgui.SameLine()
				if imgui.Button(u8"Включить просмотр", imgui.ImVec2(357, 25)) then spur.edit = false end
				if imgui.Button(u8"Закрыть", imgui.ImVec2(1081, 25)) then spurBig.v = not spurBig.v end
		else
			imgui.SetCursorPosX(380)
			imgui.Text(u8"Большое окно для редактирования/просмотра шпоргалок")
			imgui.BeginChild("spur spec", imgui.ImVec2(1070, 730), true)
				if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
					for line in io.lines(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") do
						imgui.TextWrapped(u8(line))
					end
				end
			imgui.EndChild()
			if imgui.Button(u8"Включить редактирование", imgui.ImVec2(537, 25)) then 
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(537, 25)) then spurBig.v = not spurBig.v end
		end
		imgui.End()
	end

	if sobWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(880, 380), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Меню для проведения собеседования", sobWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			imgui.BeginGroup()
				imgui.PushItemWidth(140)
				imgui.InputText("##id", sobes.selID, imgui.InputTextFlags.CallbackCharFilter + imgui.InputTextFlags.EnterReturnsTrue + readID(), filter(1, "%d+"))
				imgui.PopItemWidth()
				if not imgui.IsItemActive() and sobes.selID.v == "" then
					imgui.SameLine()
					imgui.SetCursorPosX(13)
					imgui.TextDisabled(u8"Укажите id игрока") 
				end
				imgui.SameLine()
				imgui.SetCursorPosX(155)
				if imgui.Button(u8"Начать", imgui.ImVec2(60, 25)) then
					if sobes.selID.v ~= "" then
						if #sobes.logChat == 0 then
						sobes.num = sobes.num + 1
						threadS = lua_thread.create(sobesRP, sobes.num);
						table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Проверка документов...")
						else
						table.insert(sobes.logChat, "{E74E28}[Ошибка]{FFFFFF}: Проверка уже началась. Если хотите начать новую, нажмите на кнопку \"Остановить\" или \n\tдождитесь окончания проверки.")
						end
					else
						sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Укажите id игрока для начала собеседования.", 0xFF8FA2)
					end
				end
				imgui.BeginChild("pass player", imgui.ImVec2(210, 170), true)
					imgui.SetCursorPosX(30)
					imgui.Text(u8"Информация о игроке:")
					imgui.Separator()
					imgui.Bullet()
					imgui.Text(u8"Имя:")
						if sobes.player.name == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							imgui.SameLine()
							imgui.TextColoredRGB("{FFCD00}"..sobes.player.name)
						end
					imgui.Bullet()
					imgui.Text(u8"Лет в штате:")
						if sobes.player.let == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.let >= 3 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.let.."/3")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.let.."{17E11D}/3")
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Законопослушность:")
						if sobes.player.zak == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.zak >= 35 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.zak.."/35")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.zak.."{17E11D}/35")
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Имеет работу:")
						if sobes.player.work == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.work == "Без работы" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.work)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.work)
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Состоит в ЧС:")
						if sobes.player.bl == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.bl == "Не найден(а)" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.bl)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.bl)
							end
						end
					imgui.Spacing()
					imgui.Bullet()
					imgui.Text(u8"Здоровье:")
						if sobes.player.heal == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.heal == "Здоров" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.heal)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.heal)
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Наркозависимость:")
						if sobes.player.narko == 0.1 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.narko == 0 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.narko.."/0")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.narko.."{17E11D}/0")
							end
						end
				imgui.EndChild()
				if imgui.Button(u8"Внеочередной вопрос", imgui.ImVec2(210, 30)) then imgui.OpenPopup("sobQN") end
				imgui.Spacing() --if #sobes.logChat == 0 then
					if sobes.nextQ then
						if imgui.Button(u8"Дальше вопрос", imgui.ImVec2(210, 30)) then
							sobes.num = sobes.num + 1
							lua_thread.create(sobesRP, sobes.num); 
						end
					else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Следующий вопрос", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
					end
				imgui.Spacing()
				if #sobes.logChat ~= 0 and sobes.selID.v ~= "" then
					if imgui.Button(u8"Определить годность", imgui.ImVec2(210, 30)) then imgui.OpenPopup("sobEnter") end
				else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Определить годность", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
				end
				imgui.Spacing()
				if #sobes.logChat ~= 0 and sobes.selID.v ~= "" then 
					if imgui.Button(u8"Остановить / Очистить", imgui.ImVec2(210, 30)) then
						threadS:terminate()
						sobes.input.v = ""
						sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
						sobes.selID.v = ""
						sobes.logChat = {}
						sobes.nextQ = false
						sobes.num = 0
					end
				else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Остановить/Очистить", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
				end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("log chat", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(270)
				imgui.Text(u8"Локальный чат")
					if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните ПКМ для очистки") end
					if imgui.IsItemClicked(1) then sobes.logChat = {} end
				imgui.SameLine()
				imgui.SetCursorPosX(580)
				if imgui.SmallButton(u8"Помощь") then imgui.OpenPopup("helpsob") end
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
					if imgui.BeginPopup("helpsob") then
						imgui.Text(u8"\t\t\t\t\t\tНебольшая инструкция по пользованию.")
						imgui.TextColoredRGB(helpsob)
					imgui.EndPopup()
					end
				imgui.PopStyleColor(1)
				imgui.BeginChild("log chat in", imgui.ImVec2(0, 280), true)
					for i,v in ipairs(sobes.logChat) do
						imgui.TextColoredRGB(v)
					end
					imgui.SetScrollY(imgui.GetScrollMaxY())
				imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"Вы:");
				imgui.SameLine()
				imgui.PushItemWidth(515)
				imgui.InputText("##chat", sobes.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button(u8"Отправить", imgui.ImVec2(85, 21)) then sampSendChat(u8:decode(sobes.input.v)); sobes.input.v = "" end
			imgui.EndChild()
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94)) 
					if imgui.BeginPopup("sobEnter") then
						if imgui.MenuItem(u8"Принять") then lua_thread.create(sobesRP, 4) end
						if imgui.BeginMenu(u8"Отклонить") then
							if imgui.MenuItem(u8"Отпечатка в паспорте (Ник)") then lua_thread.create(sobesRP, 5) end
							if imgui.MenuItem(u8"Мало лет проживания") then lua_thread.create(sobesRP, 6) end
							if imgui.MenuItem(u8"Проблемы с законом") then lua_thread.create(sobesRP, 7) end
							if imgui.MenuItem(u8"Имеет работу") then lua_thread.create(sobesRP, 8) end
							if imgui.MenuItem(u8"Состоит в ЧС") then lua_thread.create(sobesRP, 9) end
							if imgui.MenuItem(u8"Проблемы со здоровьем") then lua_thread.create(sobesRP, 10) end
							if imgui.MenuItem(u8"Имеет наркозависимость") then lua_thread.create(sobesRP, 11) end
						imgui.EndMenu()
						end
					imgui.EndPopup()
					end
					if imgui.BeginPopup("sobQN") then
						if imgui.MenuItem(u8"Попросить документы") then 
							sampSendChat("Предъявите пожалуйста Ваш пакет документов, а именно: паспорт и мед.карту.") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Повторная просьба показать документы.")
						end
						if imgui.MenuItem(u8"Выбор больницы") then 
							sampSendChat("Почему Вы выбрали именно нашу больницу для трудоустройства?") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: .")
						end
						if imgui.MenuItem(u8"Рассказать о себе") then 
							sampSendChat("Расскажите, пожалуйста, немного о себе.") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Расскажите, пожалуйста, немного о себе.")
						end
						if imgui.MenuItem(u8"Имеет ли Discord") then 
							sampSendChat("Имеется ли у Вас спец.рация \"Discord\"?") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Имеется ли у Вас спец.рация \"Discord\"?")
						end
						if imgui.BeginMenu(u8"Вопросы на психику:") then
							if imgui.MenuItem(u8"МГ") then 
								sampSendChat("Что может означать аббревиатура 'МГ'?")
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Что может означать аббревиатура 'МГ'?")
							end
							if imgui.MenuItem(u8"ДМ") then 
								sampSendChat("Что может означать аббревиатура 'ДМ'?") 
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Что может означать аббревиатура 'ДМ'?")
							end
							if imgui.MenuItem(u8"ТК") then 
								sampSendChat("Что может означать аббревиатура 'ТК'?") 
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Что может означать аббревиатура 'ТК'?")
							end
							if imgui.MenuItem(u8"РП") then 
								sampSendChat("Как Вы думаете, что может означать аббревиатура 'РП'?")
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Как Вы думаете, что может означать аббревиатура 'РП'?.")								
							end
						imgui.EndMenu()
						end
					imgui.EndPopup()
					end
				imgui.PopStyleColor(1)
		imgui.End()
	end

	if depWin.v then
		inDepWin()
	end

	if updWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_DOWNLOAD .. u8" Проверка обновлений.", updWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			imgui.SetCursorPosX(252)
			imgui.Text(u8"Информация об обновлении")
			imgui.Dummy(imgui.ImVec2(0, 10))
			if #updinfo < 5 then
				imgui.SetCursorPos(imgui.ImVec2(242, 150))
				imgui.TextColoredRGB("{72F566}Обновлений не обнаружено")
				imgui.SetCursorPosX(212)
				imgui.TextColoredRGB("{72F566}Вы используете самую новую версию")
			else
				if newversion == scr.version then
					imgui.SetCursorPosX(120)
					imgui.TextColored(imgui.ImColor(0, 255, 0, 225):GetVec4(), fa.ICON_CHECK); imgui.SameLine()
					imgui.TextColoredRGB("Вы используете последнее обновление. Текущая версия: {72F566}"..scr.version)
					imgui.SetCursorPosX(222)
					imgui.TextColoredRGB("{F8A436}Что было добавлено в прошлый раз: ")
					imgui.Spacing()
					imgui.BeginChild("update log", imgui.ImVec2(0, 0), true)
						if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
							for line in io.lines(dirml.."/MedicalHelper/files/update.txt") do
								imgui.TextColoredRGB(line:gsub("*n*", "\n"))
							end
						end
					imgui.EndChild()
				else
					imgui.SetCursorPosX(182) 
					imgui.TextColored(imgui.ImColor(255, 200, 0, 225):GetVec4(), fa.ICON_EXCLAMATION_TRIANGLE); imgui.SameLine()
					imgui.TextColoredRGB("Вы используете устаревшую версию скрипта.")
					imgui.SetCursorPosX(212) 
					imgui.TextColoredRGB("Новая версия: {72F566}"..newversion.."{FFFFFF}. Текущая Ваша: {EE4747}"..scr.version)
					imgui.SetCursorPosX(282)
					imgui.TextColoredRGB("{F8A436}Что было добавлено:")
					imgui.Spacing()
					imgui.BeginChild("update log", imgui.ImVec2(0, 230), true)
						if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
							for line in io.lines(dirml.."/MedicalHelper/files/update.txt") do
								imgui.TextColoredRGB(line:gsub("*n*", "\n"))
							end
						end
					imgui.EndChild()
					imgui.SetCursorPosX(232)
					if imgui.Button(fa.ICON_DOWNLOAD .. u8" Установить новую версию", imgui.ImVec2(230, 30)) then funCMD.update() end
				end
			end
		--	imgui.Bullet(); imgui.SameLine()
		--	imgui.TextColoredRGB("Было изменено вывфыв ывфывфывыв ыфвфывфы ыфвфывфы ")
		imgui.End()
	end
	
	if mcEditWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(650, 420), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Редактирование отыгровки мед.карты", mcEditWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			imgui.InputTextMultiline("##mcedit", buf_mcedit, imgui.ImVec2(634, 350))
			if imgui.Button(u8"Сохранить", imgui.ImVec2(155, 25)) then
				local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
				f:write(u8:decode(buf_mcedit.v))
				f:close() 
			end
			imgui.SameLine()
			if imgui.Button(u8"Сбросить", imgui.ImVec2(155, 25)) then
				local textrp = [[
// Цены на выдачу новой мед.карты
#med7=20.000$
#med14=40.000$
#med30=60.000$
#med60=80.000$
// Цены на обновление мед.карты
#medup7=40.000$
#medup14=60.000$
#medup30=80.000$
#medup60=100.000$

{sleep:0}
Здравствуйте, Вы хотите получить медицинскую карту впервые или обновить существующую?
Предоставьте, пожалуйста, Ваш паспорт
/b /showpass {myID}
{pause}
/todo Благодорю вас!*взяв паспорт в руки и начав его изучать.
{dialog}
[name]=Выдача мед.карты
[1]=Новая мед.карта
Хорошо, я Вас {sex:понял|поняла}. Вам нужно оформить новую мед.карту.
Стоимость мед. карты зависит от её срока.
На 7 дней - #med7, на 14 дней - #med14
На 30 дней #med30, на 60 дней - #med60.
Вы согласны? Если да, то на какой срок Вам?
/b Оплата в конце, система сама предложит.

{dialog}
[name]=Срок выдачи
[1]=7 дней
#timeID=0
#money=20000
[2]=14 дней
#timeID=1
#money=40000
[3]=30 дней
#timeID=2
#money=60000
[4]=60 дей
#timeID=3
#money=80000
{dialogEnd}

Хорошо, тогда приступим к оформлению.
/me {sex:вытащил|вытащила} из нагрудного кармана шариковую ручку
/me открыл{sex:|а} шкафчик, затем достал{sex:|а} оттуда пустые бланки для мед.карты
/me разложил{sex:|а} пальцами правой руки паспорт на нужной страничке и начал{sex:|а} переписывать данные в бланк
/me открыл{sex:|а} пустую мед.карту и паспорт, затем начал{sex:|а} переписывать данные из паспорта
/do Спустя минуту данные паспорта были переписаны на бланк.

[2]=Обновление данных
Хорошо, я Вас понял{sex:|а}. Вам нужно обновить данные в мед.карте.
Стоимость мед. карты зависит от её срока.
На 7 дней - #medup7, на 14 дней - #medup14
На 30 дней #medup30, на 60 дней - #medup60.
Вы согласны? Если да, то на какой срок Вам?
/b Оплата в конце, система сама предложит.

{dialog}
[name]=Срок выдачи
[1]=7 дней
#timeID=0
#money=40000
[2]=14 дней
#timeID=1
#money=60000
[3]=30 дней
#timeID=2
#money=80000
[4]=60 дней
#timeID=3
#money=100000
{dialogEnd}

Хорошо, тогда приступим к оформлению.
/me вытащил{sex:|а} из нагрудного кармана шариковую ручку
/me открыл{sex:|а} шкафчик, затем начал{sex:|а} искать мед.карту c индификатором №#playerID
/me разложил{sex:|а} пальцами правой руки паспорт на нужной страничке и начал переписывать данные в бланк
/me открыл{sex:|а} пустую мед.карту и паспорт, затем начал переписывать данные из паспорта
/do Спустя минуту данные паспорта были переписаны на бланк.
{dialogEnd}
/me отложил{sex:|а} паспорт в сторону его хозяина и приготовил{sex:ся|ась} к продолжению занесения информации
Так, сейчас задам несколько вопросов касаемо здоровья...
Жалобы на здоровье имеются?
{pause}
Имеются ли вредные привычки, а также аллергические реакции?
{pause}
/me записал{sex:|а} все сказанное пациентом в мед.карту
{dialog}
[name]=Сост. здоровья
[1]=Полноcтью здоров(ая)
#healID=3
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Полностью здоров(а).'
[2]=Наблюдаются отклоненияются
#healID=2
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Имеются отклонения.'
[3]=Психически не здоров(ая)
#healID=1
/me сделал{sex:|а} запись напротив пункта 'Псих. Здоровье.' - 'Псих. нездоров.'
{dialogEnd}
/me взял{sex:|а} штамп {myHospEn} и проставил{sex:|а} печать в необходимых местах
/do Страница мед.карты заполнена.
Всё готово, держите свою мед. карту, не болейте.
/medcard #playerID #healID #timeID #money]]
				local f = io.open(dirml.."/MedicalHelper/rp-medcard.txt", "w")
				f:write(textrp)
				f:close()
				buf_mcedit.v = u8(textrp)
			end
			imgui.SameLine()
			if imgui.Button(u8"Тег-функции", imgui.ImVec2(155, 25)) then
				paramWin.v = not paramWin.v
			end
			imgui.SameLine()
			if imgui.Button(u8"Для продвинутых", imgui.ImVec2(155, 25)) then
				profbWin.v = not profbWin.v
			end
		imgui.End()
	end
	
	if profbWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(710, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Продвинутое пользование биндера", profbWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			local vt1 = [[
Помимо стандартного использования биндера для последовательного проигрывания строчек
текста возможно использовать больший функционал для расширения возможностей.
 
{FFCD00}1. Система переменных{FFFFFF}
	Для создание переменных используется символ решётки {ACFF36}#{FFFFFF}, после которого идёт название
переменной. Название переменной может содержать только английские символы и цифры,
иначе будет пропущено. 
	После названия переменной ставится равно {ACFF36}={FFFFFF} и далее пишется любой текст, который
необходимо присвоить этой переменной. Текст может содержать любые символы.
		Пример: {ACFF36}#price=10.000$.{FFFFFF}
	Теперь, используя переменную {ACFF36}#price{FFFFFF}, можно её вставить куда вам захочется, и она будет
автоматически заменена во время проигрывания отыгровки на значение, которое было 
указано после равно.
 
{FFCD00}2. Комментирование текста{FFFFFF}
	С помощью комментирования можно сделать для себя пометку или описание чего-либо
при этом сам комментарий не будет отображаться. Комментарий создаётся двойным слешом //,
после которого пишется любой текст.
	Пример: {ACFF36}Здравствуйте, чем Вам помочь // Приветствие{FFFFFF}
Комментарий {ACFF36}// Приветствие{FFFFFF} во время отыгровки удалится и не будет виден.
 
{FFCD00}3. Система диалогов{FFFFFF}
	С помощью диалогов можно создавать разветвления отыгровок, с помощью которых можно
реализовывать более сложные варианты их.
Структура диалога:
	{ACFF36}{dialog}{FFFFFF} 		- начало структуры диалога
	{ACFF36}[name]=Текст{FFFFFF}- имя диалога. Задаётся после равно =. Оно не должно быть особо большим
	{ACFF36}[1]=Текст{FFFFFF}		- варианты для выбора дальшейших действий, где в скобках 1 - это
клавиша активация. Можно устанавливать помимо цифр, другие значения, например, [X], [B],
[NUMPAD1], [NUMPAD2] и т.д. Список доступных клавиш можно посмотреть здесь. После равно
прописывается имя, которое будет отображаться при выборе. 
	После того, как задали имя варианта, со следующей строки пишутся уже сами отыгровки.
	{ACFF36}Текст отыгровки...
	{ACFF36}[2]=Текст{FFFFFF}	
	{ACFF36}Текст отыгровки...
	{ACFF36}{dialogEnd}{FFFFFF}		- конец структуры диалога
]]
			local vt2 = [[
									{E45050}Особенности:
1. Имена диалога и вариантов задавать не обязательно, но 
рекомендуется для визуального понимания;
2. Можно создавать диалоги внутри диалогов, создавая 
конструкции внутри вариантов;
3. Можно использовать все выше перечисленные системы 
(переменные, комментарии, теги и т.п.)
			]]
			local vt3 = [[
{FFCD00}4. Использование тегов{FFFFFF}
Список тегов можно открыть в меню редактирования отыгровки или в разделе биндера.
Теги предназначены для автоматическеской замены на значение, которые они имеют.
Имеются два вида тегов:
	1. Спростые теги - теги, которые просто заменяют себя на значение, которые они
постоянно имеют, например, {ACFF36}{myID}{FFFFFF} - возвращает Ваш текущий ID.
	2. Тег-функция - специальные теги, которые требуют дополнительных параметров.
К ним относятся:
	{ACFF36}{sleep:[время]}{FFFFFF} - Задаёт свой интервал времени между строчками. 
Время задаётся в миллисекундах. Пример: {ACFF36}{sleep:2000}{FFFFFF} - задаёт интервал в 2 сек
1 секунда = 1000 миллисекунд

	{ACFF36}{sex:текст1|текст2}{FFFFFF} - Возвращает текст в зависимости от выбранного пола.
Больше предназначено, если создаётся отыгровка для публичного использования.
Где {6AD7F0}текст1{FFFFFF} - для мужской отыгровки, {6AD7F0}текст2{FFFFFF} - для женской. Разделяется вертикальной чертой.
	Пример: {ACFF36}Я {sex:пришёл|пришла} сюда.

	{ACFF36}{getNickByID:ид игрока}{FFFFFF} - Возращает ник игрока по его ID.
Пример: На сервере игрок {6AD7F0}Nick_Name{FFFFFF} с id - 25.
{ACFF36}{getNickByID:25}{FFFFFF} вернёт - {6AD7F0}Nick Name.
			]]
			imgui.TextColoredRGB(vt1)

			imgui.BeginGroup()
				imgui.TextDisabled(u8"					Пример")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##dialogPar", helpd.exp, imgui.ImVec2(220, 180), 16384)
				imgui.PopStyleColor(1)
				imgui.TextDisabled(u8"Для копирования используйте\nCtrl + C. Вставка - Ctrl + V")
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginGroup()
				imgui.TextColoredRGB(vt2)
				if imgui.Button(u8"Список клавиш", imgui.ImVec2(150,25)) then
					imgui.OpenPopup("helpdkey")
				end
			imgui.EndGroup()
			imgui.TextColoredRGB(vt3)
			------
			if imgui.BeginPopup("helpdkey") then
				imgui.BeginChild("helpdkey", imgui.ImVec2(290,320))
					imgui.TextColoredRGB("{FFCD00}Кликните, чтобы скопировать")
					imgui.BeginGroup()
						for _,v in ipairs(helpd.key) do
							if imgui.Selectable(u8("["..v.k.."] 	-	"..v.n)) then
								setClipboardText(v.k)
							end
						end
					imgui.EndGroup()
				imgui.EndChild()
			imgui.EndPopup()
			end
		imgui.End()
	end
end

function testwin()
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
end

function inDepWin()
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(950, 430), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 1.8), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_SIGNAL .. u8" Меню рации департамента.", depWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			imgui.BeginGroup()
			if imgui.Button(fa.ICON_COG..u8" Настройки рации", imgui.ImVec2(230, 25)) then
				imgui.OpenPopup(u8"MH | Настройки рации департамента");
				chgDepSetD[1].v = setdepteg.tegtext_one
				chgDepSetD[2].v = setdepteg.tegtext_two
				chgDepSetD[3].v = setdepteg.tegtext_three
				num_dep.v = setdepteg.tegpref_one
				num_dep2.v = setdepteg.tegpref_two
				prefixDefolt = setdepteg.prefix
			end
			--///Настройки рации департамента
			if imgui.BeginPopupModal(u8"MH | Настройки рации департамента", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
				imgui.SetCursorPosX(186)
				imgui.Text(u8"Настройте вид обращения в департамент");
				imgui.Separator();
				imgui.SetCursorPosY(60)
				imgui.Text(u8"/d "); imgui.SameLine();
				imgui.SetCursorPosY(58)
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext1", chgDepSetD[1]); --// Первый текст
				imgui.SameLine();
				imgui.SetCursorPosX(35)
					if chgDepSetD[1].v == "" or chgDepSetD[1].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Текст"); --// Когда текста 1 нет
					end
				imgui.SameLine();
				imgui.SetCursorPosX(99);
				imgui.PushItemWidth(193);
					if imgui.Combo(u8"##pref1", num_dep, list_dep_pref_one) then end --// Первый префикс
				imgui.SameLine();
				imgui.SetCursorPosX(297);
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext2", chgDepSetD[2]); --// Второй текст
				imgui.SameLine();
				imgui.SetCursorPosX(303);
					if chgDepSetD[2].v == "" or chgDepSetD[2].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Текст"); --// Когда текста 2 нет
					end
				imgui.SameLine();
				imgui.SetCursorPosX(367);
				imgui.PushItemWidth(193);
					if imgui.Combo(u8"##pref2", num_dep2, list_dep_pref_two) then end --// Второй префикс
				imgui.SameLine();
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext3", chgDepSetD[3]); --// Третий текст
				imgui.SameLine();
				imgui.SetCursorPosX(570);
					if chgDepSetD[3].v == "" or chgDepSetD[3].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Текст"); --// Когда текста 3 нет
					else
						imgui.Dummy(imgui.ImVec2(0, 1))
					end
				imgui.Dummy(imgui.ImVec2(0, 1))
				imgui.Separator();
				imgui.Text(u8"Как это будет выглядеть:");
				imgui.SameLine();
				imgui.TextColoredRGB(u8"{ffe14d}/d ".. u8:decode(DepTxtEndSetting(prefix_end[2])) .. "На связь...");
				imgui.Separator();
				imgui.Dummy(imgui.ImVec2(0, 6))
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Оставьте поле пустым, чтобы не отображать текст этого поля.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Чтобы не ошибиться в настройках, загляните в правила обращения в рацию")
				imgui.SetCursorPosX(53);
				imgui.TextColoredRGB("{00ff8c}департамента на форуме Аризоны, в разделе Вашего сервера.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Будьте внимательны! Не пропустите пробел в нужных для этого местах.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Настройте префиксы согласно правилам Вашего сервера. (кнопка ниже)")
				imgui.Dummy(imgui.ImVec2(0, 6))
				imgui.Separator();
				
						if imgui.Button(u8"Настроить префиксы (теги) обращений", imgui.ImVec2(622, 0)) then 
						imgui.OpenPopup(u8"MH | Настройка префиксов (тегов)")
						chgDepSetPref.v = prefixDefolt[num_pref.v + 1]
						end 
						
						imgui.Separator();
						imgui.Dummy(imgui.ImVec2(0, 6))
						if imgui.Button(u8"Сохранить", imgui.ImVec2(308, 0)) then 
							setdepteg.tegtext_one = chgDepSetD[1].v
							setdepteg.tegtext_two = chgDepSetD[2].v
							setdepteg.tegtext_three = chgDepSetD[3].v
							setdepteg.tegpref_one = num_dep.v
							setdepteg.tegpref_two =  num_dep2.v
							local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
							f:write(encodeJson(setdepteg))
							f:flush()
							f:close()
							sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
							imgui.CloseCurrentPopup();
							lockPlayerControl(false);
						end 
						imgui.SameLine();
						if imgui.Button(u8"Закрыть", imgui.ImVec2(308, 0)) then 
							imgui.CloseCurrentPopup();
							lockPlayerControl(false)
						end 
						--// Настройка префиксов
						if imgui.BeginPopupModal(u8"MH | Настройка префиксов (тегов)", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
							
							imgui.SetCursorPosX(10)
							imgui.Text(u8"Настройте префиксы под каждую организацию согласно правилам Вашего сервера.");
							imgui.SetCursorPosX(60)
							imgui.Text(u8"Найти эти правила Вы можете на форуме Аризоны, в разделе правил");
							imgui.SetCursorPosX(170)
							imgui.Text(u8"гос. организаций Вашего сервера.");
							imgui.Separator();
							imgui.Spacing();
							imgui.PushItemWidth(230);
							prefixDefolt[num_pref.v + 1] = chgDepSetPref.v
								if imgui.Combo(u8"##tegorg", num_pref, dep.sel_all) then
								chgDepSetPref.v = prefixDefolt[num_pref.v + 1]
								end --// Rgf
							imgui.SameLine();
							imgui.PushItemWidth(120);
							imgui.InputText(u8" Тег организации", chgDepSetPref);
							imgui.Dummy(imgui.ImVec2(0, 6));
							if imgui.Button(u8"Сохранить", imgui.ImVec2(275, 0)) then 
								setdepteg.prefix = prefixDefolt
								local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
								f:write(encodeJson(setdepteg))
								f:flush()
								f:close()
								sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
								imgui.CloseCurrentPopup();
								lockPlayerControl(false);
							end 
							imgui.SameLine();
							if imgui.Button(u8"Закрыть", imgui.ImVec2(275, 0)) then 
								imgui.CloseCurrentPopup();
								lockPlayerControl(false);
							end 
						imgui.EndPopup()
						end
				imgui.EndPopup()
				end
			--// Конец настройки рации департамента
			imgui.Dummy(imgui.ImVec2(0, 15)) 
				imgui.BeginChild("dep list", imgui.ImVec2(230, 203), true)
					if ButtonDep(u8(dep.list[1]), dep.bool[1]) and dep.select_dep[2] == 0 then-- все
						dep.bool = {true, false, false, false, false, false}
						dep.select_dep[1] = 1
						select_depart = 1
						
					end
					if ButtonDep(u8(dep.list[2]), dep.bool[2]) and dep.select_dep[2] == 0 then-- чп
						dep.bool = {false, true, false, false, false, false}
						dep.select_dep[1] = 2
						select_depart = 2
						
					end
					--[[if dep.select_dep[2] < 100 then
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Собеседование(врем.откл.)", imgui.ImVec2(215, 34))
						imgui.PopStyleColor(3)
					end]]
					if ButtonDep(u8(dep.list[6]), dep.bool[6]) and dep.select_dep[2] == 0 then-- тех
						dep.bool = {false, false, false, false, false, true, false}
						dep.select_dep[1] = 6
						select_depart = 3
						
					end
					if ButtonDep(u8(dep.list[7]), dep.bool[7]) and dep.select_dep[2] == 0 then-- новости
						dep.bool = {false, false, false, false, false, false, true}
						dep.select_dep[1] = 7
						getGovFile()
						select_depart = 4
					end
				imgui.EndChild()

					if dep.select_dep[1] < 5 and dep.select_dep[1] ~= 0 and dep.select_dep[2] == 0 then
						if dep.select_dep[1] == 1 then
							imgui.Dummy(imgui.ImVec2(0, 5)) 
							if imgui.Button(u8"Подключиться тихо", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then 
										dep.select_dep[2] = i
									end
								end
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы подключитесь ко всем гос. структурам для дальнейшего обращения.\n\nВ чат департамента ничего не отправится.")
						end
						if dep.select_dep[1] == 2 then
							imgui.Dummy(imgui.ImVec2(0, 5)) 
							imgui.PushItemWidth(228);
							imgui.Combo("##orgs", num_dep3, dep.sel_all)
							imgui.Dummy(imgui.ImVec2(0, 5)) 
							if imgui.Button(u8"Подключиться впервые", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
								sampSendChat(string.format("/d %sНа связь...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[2]) .. u8"На связь...\n\nПосле чего Вы начнёте общение в локальном чате.")
							if imgui.Button(u8"Подключиться по обращению", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
								sampSendChat(string.format("/d %sНа связи...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[2]) .. u8"На связи...\n\nПосле чего Вы начнёте общение в локальном чате.")
							if imgui.Button(u8"Подключиться тихо", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы подключитесь к гос. структуре \"" .. dep.sel_all[num_dep3.v+1] .. u8"\" для дальнейшего обращения.\n\nВ чат департамента ничего не отправится.")
						
						end
					elseif dep.bool[5] then
						imgui.Dummy(imgui.ImVec2(0, 5))
						imgui.SetCursorPosX(60)
						imgui.Text(u8"Задано время:  "..dep.time[1]..":"..dep.time[2])
						imgui.Spacing()
						imgui.Spacing()
							imgui.SetCursorPosX(60)
							imgui.Text(u8"Часы\t\t   Минуты"); 
							imgui.SetCursorPosX(45)
							if imgui.SmallButton("<<") and dep.time[1] > 0 then dep.time[1] = dep.time[1] - 1 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[1]))
							imgui.SameLine()
							if imgui.SmallButton(">>") and dep.time[1] < 24 then dep.time[1] = dep.time[1] + 1 end
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							if imgui.SmallButton("<<##1") and dep.time[2] > 0 then dep.time[2] = dep.time[2] - 5 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[2]))
							imgui.SameLine()
							if imgui.SmallButton(">>##1") and dep.time[2] < 55 then dep.time[2] = dep.time[2] + 5 end
						imgui.Spacing()
						imgui.Spacing()
						if imgui.Button(u8"Объявить", imgui.ImVec2(208, 25)) then
							lua_thread.create(function()
							local inpSob = string.format("%d,%d,%s", dep.time[1], dep.time[2], u8:decode(list_org[num_org.v+1]))
								sampSendChat(string.format("/d [%s] - [Информация] Перешёл на частоту 103,9", u8:decode(list_org[num_org.v+1])))
								wait(1750)
								sampSendChat(string.format("/d [%s] - [103,9] Занимаю гос.волну новостей для проведения собеседования.", u8:decode(list_org[num_org.v+1])))
								wait(500)
								sampSendChat("/lmenu")
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1214
								sampSetCurrentDialogListItem(2)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1336
								sampSetCurrentDialogListItem(0)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(0) until sampIsDialogActive() and sampGetCurrentDialogId() == 1335
								wait(350)
								sampSetCurrentDialogEditboxText(inpSob)
								wait(350)
								sampCloseCurrentDialogWithButton(1)
								wait(1700)
								sampSendChat(string.format("/d [%s] - [Информация] Покидаю частоту 103,9.",  u8:decode(list_org[num_org.v+1]))) 
							end)
						end
					elseif  dep.bool[6] then
						imgui.Dummy(imgui.ImVec2(0, 5)) 
						if imgui.Button(u8"Объявить", imgui.ImVec2(208, 25)) then 
							sampSendChat(string.format("/d %sТех. неполадки.", u8:decode(DepTxtEnd(prefix_end[1]))))
						end
						imgui.SameLine()
						ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[1]) .. u8"Тех. неполадки.")
					elseif dep.bool[7] then
						imgui.Spacing()
						imgui.PushItemWidth(225)
						if imgui.Combo("##news", dep.newsN, dep.news) then
							brp = 0
							lua_thread.create(function()
								if doesFileExist(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
									for line in io.lines(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										if brp < 6 then
											trtxt[brp + 1].v = u8(line)
											brp = brp + 1
										end
									end
								end
							end)
						end
						imgui.PopItemWidth()
						imgui.Dummy(imgui.ImVec2(0, 2))
							
							imgui.Text(u8"Также можете сами добавить или")
							imgui.Text(u8"изменять новости.")
							imgui.SetCursorPos(imgui.ImVec2(133, 338))
							imgui.TextColoredRGB("{29EB2F}Папка")
							if imgui.IsItemHovered() then 
								imgui.SetTooltip(u8"Кликните, чтобы открыть папку.")
							end
							if imgui.IsItemClicked(0) then
								print(shell32.ShellExecuteA(nil, 'open', dirml.."/MedicalHelper/Департамент/", nil, nil, 1))
							end
						imgui.Dummy(imgui.ImVec2(0, 33))
						if imgui.Button(u8"Подать", imgui.ImVec2(208, 25)) then
							lua_thread.create(function()
								if doesFileExist(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
									--sampSendChat(string.format("/d %sЗанимаю гос.волну согласно расписанию.", u8:decode(DepTxtEnd(prefix_end[1]))))
									--wait(1000)
									for line in io.lines(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										sampSendChat(line)
										wait(1800)
									end
									--sampSendChat(string.format("/d %sОсвобождаю гос.волну.", u8:decode(DepTxtEnd(prefix_end[1]))))
								end
							end)
						end
							imgui.SameLine()
							ShowHelpMarker(u8"Отправит в чат следующее:\n\n".. trtxt[1].v.. "\n".. trtxt[2].v.. "\n".. trtxt[3].v .. "\n".. trtxt[4].v .. "\n".. trtxt[5].v)
					elseif dep.select_dep[2] < 5 and dep.select_dep[2] ~= 0 then
						imgui.Dummy(imgui.ImVec2(0, 5)) 
						imgui.PushItemWidth(225)
						if dep.select_dep[1] == 1 then --ВСЕМ
							if imgui.Button(u8"Отключиться", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
								sampSendChat(string.format("/d %sКонец связи...", u8:decode(DepTxtEnd(prefix_end[1]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от всех гос. структур. Система отправит в чат следующее:\n\n/d " .. DepTxtEnd(prefix_end[1]).. u8"Конец связи...")
							if imgui.Button(u8"Отключиться тихо", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от всех гос. структур.\n\nВ чат департамента ничего не отправится.")
						end
						if dep.select_dep[1] == 2 then --КОНКРЕТНОЕ
							if imgui.Button(u8"Отключиться", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
								sampSendChat(string.format("/d %sКонец связи...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от гос. структуры \"" .. dep.sel_all[num_dep3.v+1] .. u8"\". Система отправит в чат следующее:\n\n/d " .. DepTxtEnd(prefix_end[2]).. u8"Конец связи...")
							if imgui.Button(u8"Отключиться тихо", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от гос. структуры \"" .. dep.sel_all[num_dep3.v+1] .. u8"\"\n\nВ чат департамента ничего не отправится.")
						end
						imgui.PopItemWidth()

					else
						imgui.SetCursorPos(imgui.ImVec2(23, 288)) 
						imgui.Text(u8"Выберите волну департамента")
					end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("dep log", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(305)
				imgui.Text(u8"Локальный чат")
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните ПКМ для очистки") end
				if imgui.IsItemClicked(1) then dep.dlog = {} end
					imgui.BeginChild("dep logg", imgui.ImVec2(0, 325), true)
						for i,v in ipairs(dep.dlog) do
							imgui.TextColoredRGB(v)
						end
						imgui.SetScrollY(imgui.GetScrollMaxY())
					imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"Вы:");
				imgui.SameLine()
				imgui.PushItemWidth(550)
				imgui.InputText("##chat", dep.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if dep.select_dep[2] ~= 0 and not dep.bool[5] and not dep.bool[6] and not dep.bool[7] then
					if imgui.Button(u8"Отправить", imgui.ImVec2(80, 21.5)) then
						if dep.select_dep[2] < 3 and dep.select_dep[2] > 0 then
							if dep.bool[1] then
								sampSendChat(string.format("/d %s"..u8:decode(dep.input.v), u8:decode(DepTxtEnd(prefix_end[1]))))
							elseif dep.bool[2] then
								sampSendChat(string.format("/d %s"..u8:decode(dep.input.v), u8:decode(DepTxtEnd(prefix_end[num_dep3.v + 1]))))
							end
						end
						dep.input.v = ""
					end
				else
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.Button(u8"Отправить", imgui.ImVec2(80, 21.5))
					imgui.PopStyleColor(3)
				end
				if dep.select_dep[2] == 0 then
					imgui.SameLine()
					ShowHelpMarker(u8"Здесь будет заранее отображаться отправляемый текст.\n\nДля подключения к департаменту воспользуйтесь кнопками слева.")
				elseif dep.bool[1] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[1]) .. dep.input.v)
				elseif dep.bool[2] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[num_dep3.v + 1]) .. dep.input.v)
				elseif dep.bool[5] or dep.bool[6] or dep.bool[7] then
					imgui.SameLine()
					ShowHelpMarker(u8"Здесь будет заранее отображаться отправляемый текст.\n\nДля подключения к департаменту воспользуйтесь кнопками слева.")
				end
			
				---------------------------------------------------
			imgui.EndChild()
		imgui.End()
end

function settingMassiveSave()
	reloadScriptStyleWin = false
	if num_themeTest ~= num_theme.v then
	reloadScriptStyleWin = true
	end
	if theme_AngleTest ~= theme_Angle.v then
	styleWin()
	end
	setting.nick = u8:decode(buf_nick.v)
	setting.teg = u8:decode(buf_teg.v)
	setting.org = num_org.v
	setting.sex = num_sex.v
	setting.rank = num_rank.v
	setting.time = cb_time.v
	setting.timeTx = u8:decode(buf_time.v)
	setting.timeDo = cb_timeDo.v
	setting.rac = cb_rac.v
	setting.racTx = u8:decode(buf_rac.v)
	setting.lec = buf_lec.v
	setting.mede[1] = buf_mede[1].v
	setting.mede[2] = buf_mede[2].v
	setting.mede[3] = buf_mede[3].v
	setting.mede[4] = buf_mede[4].v
	setting.upmede[1] = buf_upmede[1].v
	setting.upmede[2] = buf_upmede[2].v
	setting.upmede[3] = buf_upmede[3].v
	setting.upmede[4] = buf_upmede[4].v
	setting.rec = buf_rec.v
	setting.narko = buf_narko.v
	setting.tatu = buf_tatu.v
	setting.ant = buf_ant.v
	setting.chat1 = cb_chat1.v
	setting.chat2 = cb_chat2.v
	setting.chat3 = cb_chat3.v
	setting.chathud = cb_hud.v
	setting.arp = arep
	setting.setver = setver
	setting.imageDis = cb_imageDis.v
	setting.htime = cb_hudTime.v
	setting.hping = hudPing
	setting.orgl = {}
	setting.rankl = {}
	setting.theme = num_theme.v
	setting.themAngle = theme_Angle.v
	theme_AngleTest = theme_Angle.v
	setting.spawn = accept_spawn.v
	setting.autolec = accept_autolec.v
end

function settingMassiveSave2()
local numMasGet = 1
	while numMasGet ~= 11 do
		setCmdEdit[selected_cmd].sec[numMasGet] = chgCmd[numMasGet].v * 1000
		setCmdEdit[selected_cmd].text[numMasGet] = chgCmdSet[numMasGet].v
		numMasGet = numMasGet + 1
	end
end

function profitmoney()
	imgui.SameLine()
	imgui.BeginChild("discord", imgui.ImVec2(0, 0), true)
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.SetCursorPosX(90)
	imgui.TextColoredRGB("Здесь находится информация о Вашей прибыли за последние семь дней.")
	imgui.SameLine()
	ShowHelpMarker(u8"Всё, что Вы заработали в рамках Вашей организации сохраняется здесь в виде статистики.\nИнформация отображается за последние 7 дней. Более ранние события удаляются.")
	imgui.SameLine()
	imgui.SetCursorPosX(596)
	if imgui.Button(fa.ICON_COG.."##priceset", imgui.ImVec2(26,21)) then
		imgui.OpenPopup(u8"MH | Редактирование прибавочной суммы")
	end
	if imgui.BeginPopupModal(u8"MH | Редактирование прибавочной суммы", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB("Отредактируйте цены мед.карты для корректного отображения заработка.")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.PushItemWidth(90)
		if imgui.InputText(u8" Новая на 7 дней", buf_mede[1], imgui.InputTextFlags.CharsDecimal) then end
		imgui.SameLine();
		imgui.SetCursorPosX(240)
		if imgui.InputText(u8" Обновление на 7 дней", buf_upmede[1], imgui.InputTextFlags.CharsDecimal) then end
		if imgui.InputText(u8" Новая на 14 дней", buf_mede[2], imgui.InputTextFlags.CharsDecimal) then end
		imgui.SameLine();
		imgui.SetCursorPosX(240)
		if imgui.InputText(u8" Обновление на 14 дней", buf_upmede[2], imgui.InputTextFlags.CharsDecimal) then end
		if imgui.InputText(u8" Новая на 30 дней", buf_mede[3], imgui.InputTextFlags.CharsDecimal) then end
		imgui.SameLine();
		imgui.SetCursorPosX(240)
		if imgui.InputText(u8" Обновление на 30 дней", buf_upmede[3], imgui.InputTextFlags.CharsDecimal) then end
		if imgui.InputText(u8" Новая на 60 дней", buf_mede[4], imgui.InputTextFlags.CharsDecimal) then end
		imgui.SameLine();
		imgui.SetCursorPosX(240)
		if imgui.InputText(u8" Обновление на 60 дней", buf_upmede[4], imgui.InputTextFlags.CharsDecimal) then end
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
		if imgui.Button(u8"Сохранить", imgui.ImVec2(243, 0)) then 
			settingMassiveSave()
		--[[	for i,v in ipairs(chgName.org) do
				setting.orgl[i] = u8:decode(v)
			end
			for i,v in ipairs(chgName.rank) do
				setting.rankl[i] = u8:decode(v)
			end]]
			local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
			f:write(encodeJson(setting))
			f:flush()
			f:close()
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.SameLine();
		if imgui.Button(u8"Закрыть", imgui.ImVec2(243, 0)) then 
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
	imgui.EndPopup()
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Separator()
	imgui.SetCursorPosX(315)
	imgui.TextColoredRGB(profit_money.date_week[1])
	imgui.Separator()
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[1]).."$")
	imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[1]).."$")
	imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[1]).."$")
	imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[1]).."$")
	imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[1]).."$")
	imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[1]).."$")
	imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[1]).."$")
	imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[1]).."$")
	imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[1]).."$")
	imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[1]).."$")
	imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[1]).."$")
	imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[1]).."$")
	imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[1] + profit_money.lec[1] + profit_money.medcard[1] + profit_money.narko[1] + profit_money.vac[1] + profit_money.ant[1] + profit_money.rec[1] + profit_money.medcam[1] + profit_money.cure[1] + profit_money.strah[1] + profit_money.tatu[1] + profit_money.premium[1]).."$")
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	if profit_money.date_week[2] ~= "" then
		imgui.Separator()
		imgui.SetCursorPosX(315)
		imgui.TextColoredRGB(profit_money.date_week[2])
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[2]).."$")
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[2]).."$")
		imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[2]).."$")
		imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[2]).."$")
		imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[2]).."$")
		imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[2]).."$")
		imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[2]).."$")
		imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[2]).."$")
		imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[2]).."$")
		imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[2]).."$")
		imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[2]).."$")
		imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[2]).."$")
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[2] + profit_money.lec[2] + profit_money.medcard[2] + profit_money.narko[2] + profit_money.vac[2] + profit_money.ant[2] + profit_money.rec[2] + profit_money.medcam[2] + profit_money.cure[2] + profit_money.strah[2] + profit_money.tatu[2] + profit_money.premium[2]).."$")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
	end
	if profit_money.date_week[3] ~= "" then
		imgui.Separator()
		imgui.SetCursorPosX(315)
		imgui.TextColoredRGB(profit_money.date_week[3])
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[3]).."$")
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[3]).."$")
		imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[3]).."$")
		imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[3]).."$")
		imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[3]).."$")
		imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[3]).."$")
		imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[3]).."$")
		imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[3]).."$")
		imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[3]).."$")
		imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[3]).."$")
		imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[3]).."$")
		imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[3]).."$")
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[3] + profit_money.lec[3] + profit_money.medcard[3] + profit_money.narko[3] + profit_money.vac[3] + profit_money.ant[3] + profit_money.rec[3] + profit_money.medcam[3] + profit_money.cure[3] + profit_money.strah[3] + profit_money.tatu[3] + profit_money.premium[3]).."$")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
	end
	if profit_money.date_week[4] ~= "" then
		imgui.Separator()
		imgui.SetCursorPosX(315)
		imgui.TextColoredRGB(profit_money.date_week[4])
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[4]).."$")
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[4]).."$")
		imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[4]).."$")
		imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[4]).."$")
		imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[4]).."$")
		imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[4]).."$")
		imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[4]).."$")
		imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[4]).."$")
		imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[4]).."$")
		imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[4]).."$")
		imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[4]).."$")
		imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[4]).."$")
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[4] + profit_money.lec[4] + profit_money.medcard[4] + profit_money.narko[4] + profit_money.vac[4] + profit_money.ant[4] + profit_money.rec[4] + profit_money.medcam[4] + profit_money.cure[4] + profit_money.strah[4] + profit_money.tatu[4] + profit_money.premium[4]).."$")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
	end
	if profit_money.date_week[5] ~= "" then
		imgui.Separator()
		imgui.SetCursorPosX(315)
		imgui.TextColoredRGB(profit_money.date_week[5])
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[5]).."$")
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[5]).."$")
		imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[5]).."$")
		imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[5]).."$")
		imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[5]).."$")
		imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[5]).."$")
		imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[5]).."$")
		imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[5]).."$")
		imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[5]).."$")
		imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[5]).."$")
		imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[5]).."$")
		imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[5]).."$")
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[5] + profit_money.lec[5] + profit_money.medcard[5] + profit_money.narko[5] + profit_money.vac[5] + profit_money.ant[5] + profit_money.rec[5] + profit_money.medcam[5] + profit_money.cure[5] + profit_money.strah[5] + profit_money.tatu[5] + profit_money.premium[5]).."$")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
	end
	if profit_money.date_week[6] ~= "" then
		imgui.Separator()
		imgui.SetCursorPosX(315)
		imgui.TextColoredRGB(profit_money.date_week[6])
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[6]).."$")
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[6]).."$")
		imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[6]).."$")
		imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[6]).."$")
		imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[6]).."$")
		imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[6]).."$")
		imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[6]).."$")
		imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[6]).."$")
		imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[6]).."$")
		imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[6]).."$")
		imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[6]).."$")
		imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[6]).."$")
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[6] + profit_money.lec[6] + profit_money.medcard[6] + profit_money.narko[6] + profit_money.vac[6] + profit_money.ant[6]+ profit_money.rec[6] + profit_money.medcam[6] + profit_money.cure[6] + profit_money.strah[6] + profit_money.tatu[6] + profit_money.premium[6]).."$")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
	end
	if profit_money.date_week[7] ~= "" then
		imgui.Separator()
		imgui.SetCursorPosX(315)
		imgui.TextColoredRGB(profit_money.date_week[7])
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[7]).."$")
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[7]).."$")
		imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[7]).."$")
		imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[7]).."$")
		imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[7]).."$")
		imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[7]).."$")
		imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[7]).."$")
		imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[7]).."$")
		imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[7]).."$")
		imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[7]).."$")
		imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[7]).."$")
		imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[7]).."$")
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..point_sum(profit_money.payday[7] + profit_money.lec[7] + profit_money.medcard[7] + profit_money.narko[7] + profit_money.vac[7] + profit_money.ant[7] + profit_money.rec[7] + profit_money.medcam[7] + profit_money.cure[7] + profit_money.strah[7] + profit_money.tatu[7] + profit_money.premium[7]).."$")
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.Separator()
	end
	profit_money.total_week = profit_money.payday[1] + profit_money.payday[2] + profit_money.payday[3] + profit_money.payday[4] + profit_money.payday[5] + profit_money.payday[6] + profit_money.payday[7] +
	profit_money.lec[1] + profit_money.lec[2] + profit_money.lec[3] + profit_money.lec[4] + profit_money.lec[5] + profit_money.lec[6] + profit_money.lec[7] +
	profit_money.medcard[1] + profit_money.medcard[2] + profit_money.medcard[3] + profit_money.medcard[4] + profit_money.medcard[5] + profit_money.medcard[6] + profit_money.medcard[7] +
	profit_money.narko[1] + profit_money.narko[2] + profit_money.narko[3] + profit_money.narko[4] + profit_money.narko[5] + profit_money.narko[6] + profit_money.narko[7] +
	profit_money.vac[1] + profit_money.vac[2] + profit_money.vac[3] + profit_money.vac[4] + profit_money.vac[5] + profit_money.vac[6] + profit_money.vac[7] +
	profit_money.ant[1] + profit_money.ant[2] + profit_money.ant[3] + profit_money.ant[4] + profit_money.ant[5] + profit_money.ant[6] + profit_money.ant[7] +
	profit_money.rec[1] + profit_money.rec[2] + profit_money.rec[3] + profit_money.rec[4] + profit_money.rec[5] + profit_money.rec[6] + profit_money.rec[7] +
	profit_money.medcam[1] + profit_money.medcam[2] + profit_money.medcam[3] + profit_money.medcam[4] + profit_money.medcam[5] + profit_money.medcam[6] + profit_money.medcam[7] +
	profit_money.cure[1] + profit_money.cure[2] + profit_money.cure[3] + profit_money.cure[4] + profit_money.cure[5] + profit_money.cure[6] + profit_money.cure[7] +
	profit_money.strah[1] + profit_money.strah[2] + profit_money.strah[3] + profit_money.strah[4] + profit_money.strah[5] + profit_money.strah[6] + profit_money.strah[7] +
	profit_money.tatu[1] + profit_money.tatu[2] + profit_money.tatu[3] + profit_money.tatu[4] + profit_money.tatu[5] + profit_money.tatu[6] + profit_money.tatu[7] +
	profit_money.premium[1] + profit_money.premium[2] + profit_money.premium[3] + profit_money.premium[4] + profit_money.premium[5] + profit_money.premium[6] + profit_money.premium[7] +
	profit_money.other[1] + profit_money.other[2] + profit_money.other[3] + profit_money.other[4] + profit_money.other[5] + profit_money.other[6] + profit_money.other[7]
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Итого за неделю: {36cf5c}"..point_sum(profit_money.total_week).."$")
	imgui.TextColoredRGB(" Итого за всё время: {36cf5c}"..point_sum(profit_money.total_all).."$")
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	if imgui.Button(u8"Сбросить статистику", imgui.ImVec2(666,23)) then 
		imgui.OpenPopup(u8"MH | Подтверждение действия")
	end
	if imgui.BeginPopupModal(u8"MH | Подтверждение действия", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB("Вы действительно хотите очистить статистику?\n          Статистика сбросится за всё время.")
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		if imgui.Button(u8"Сбросить", imgui.ImVec2(152, 0)) then 
			profit_money = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			lec = {0, 0, 0, 0, 0, 0, 0},
			medcard = {0, 0, 0, 0, 0, 0, 0},
			narko = {0, 0, 0, 0, 0, 0, 0},
			vac = {0, 0, 0, 0, 0, 0, 0},
			ant = {0, 0, 0, 0, 0, 0, 0},
			rec = {0, 0, 0, 0, 0, 0, 0},
			medcam = {0, 0, 0, 0, 0, 0, 0},
			cure = {0, 0, 0, 0, 0, 0, 0},
			strah = {0, 0, 0, 0, 0, 0, 0},
			tatu = {0, 0, 0, 0, 0, 0, 0},
			premium = {0, 0, 0, 0, 0, 0, 0},
			other = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
			date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
			date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
		}
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.SameLine();
		if imgui.Button(u8"Отмена", imgui.ImVec2(152, 0)) then 
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
	imgui.EndPopup()
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.EndChild()
end

function readID()
	if #sobes.logChat ~= 0 then
		return 16384
	else 
		return 0
	end
end

function rankFix()
	if num_rank.v == 10 then
		return u8:decode(list_rank[num_rank.v+1])
	else
		return u8:decode(list_org[num_org.v+1])
	end
end

function ButtonDep(desk, bool) -- подсветка кнопки выбранного меню
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(1)
	elseif not bool and dep.select_dep[2] == 0 then
		 retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
	elseif not bool and dep.select_dep[2] ~= 0 then
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
	retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
	imgui.PopStyleColor(3)
	end
						--[[imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Изменить команду", imgui.ImVec2(165, 23))
						imgui.PopStyleColor(3)]]
	return retBool
end

function sobesRP(id)
	if id == 1 then
		sobes.logChat[#sobes.logChat+1] = "{FFC000}Вы: {FFFFFF}Приветствие. Просьба показать документы."
		sobes.player.name = sampGetPlayerNickname(tonumber(sobes.selID.v))
		sampSendChat(string.format("Приветствую Вас на собеседование Я, %s - %s", u8:decode(buf_nick.v), u8:decode(chgName.rank[num_rank.v+1])))
		wait(1700)
		sampSendChat("Предъявите пожалуйста Ваш пакет документов, а именно: паспорт и мед.карту.")
		wait(1700)
		sampSendChat(string.format("/n Отыгрывая RP, команды: /showpass %d; /showmc %d - с использованием /me /do ", myid, myid))
		while true do
			wait(0)
			if sobes.player.zak ~= 0 and sobes.player.heal ~= "" then break end
			if sampIsDialogActive() then
				local dId = sampGetCurrentDialogId()
				if dId == 1234 then
					local dText = sampGetDialogText()
					if dText:find("Лет в штате") and dText:find("Законопослушность") then
					HideDialogInTh()
					if dText:find("Организация") then sobes.player.work = "Работает" else sobes.player.work = "Без работы" end
						if dText:match("Имя: {FFD700}(%S+)") == sobes.player.name then
							sobes.player.let = tonumber(dText:match("Лет в штате: {FFD700}(%d+)"))
							sobes.player.zak = tonumber(dText:match("Законопослушность: {FFD700}(%d+)"))
							sampSendChat("/me "..chsex("посмотрел", "посмотрела").." информацию в паспорте, после чего "..chsex("отдал","отдала").." его человеку напротив")
							if sobes.player.let >= 3 then
								if sobes.player.zak >= 35 then
									if not dText:find("{FF6200} "..list_org_BL[num_org.v+1]) then
										table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Не имеет проблем.")
										sobes.player.bl = "Не найден(а)"
										if sobes.player.narko == 0.1 then
											sampSendChat("Хорошо, теперь мед.карту.")
											wait(1700)
											sampSendChat("/n /showmc "..myid)
										end
									else
										table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Находится в ЧС вашей больницы.")
											sampSendChat("Извиняюсь, но Вы нам не подходите.")
											wait(1700)
											sampSendChat("Вы состоите в Чёрном списке "..u8:decode(chgName.org[num_org.v+1]))
										sobes.player.bl = list_org_BL[num_org.v+1]
									--	sobes.getStats = false
										return
									end
								else --player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0},
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Недостаточно законопослушности.")
										sampSendChat("Извиняюсь, но Вы нам не подходите.")
										wait(1700)
										sampSendChat("У Вас проблемы с законом.")
										wait(1700)
										sampSendChat("/n Необходимо законопослушнось 35+")
										wait(1700)
										sampSendChat("Приходите в следующий раз.")
								--	sobes.getStats = false
									return
								end
							else
								table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Мало проживает в штате.")
									sampSendChat("Извиняюсь, но Вы нам не подходите.")
									wait(1700)
									sampSendChat("Необходимо как минимум проживать 3 года в штате.")
									wait(1700)
									sampSendChat("Приходите в следующий раз.")
							--	sobes.getStats = false
								return
							end
						else
							table.insert(sobes.logChat, "{E74E28}[Ошибка]{FFFFFF}: Кто-то другой пытался показать паспорт.") 
						end 
					end
					if dText:find("Наркозависимость") then
						HideDialogInTh()
						if dText:match("Имя: (%S+)") == sobes.player.name then
							sampSendChat("/me "..chsex("посмотрел", "посмотрела").." информацию в мед.карте, после чего "..chsex("отдал","отдала").." его человеку напротив")
							sobes.player.narko = tonumber(dText:match("Наркозависимость: (%d+)"));
							if dText:find("Полностью здоровый") then
								if sobes.player.narko == 0 then
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) мед.карту. Всё в порядке.")
									sobes.player.heal = "Здоров"
									if sobes.player.zak == 0 then
											sampSendChat("Хорошо, теперь паспорт.")
											wait(1700)
											sampSendChat("/n /showpass "..myid)
									end
								else
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) мед.карту. Имеет наркозависимость.")
									sobes.player.heal = "Здоров"
									if sobes.player.zak == 0 then
										sampSendChat("Хорошо, Ваш паспорт пожалуйста.")
										wait(1700)
										sampSendChat("/n /showpass "..myid)
									end
									-- sampSendChat("Извиняюсь, но Вы имеете наркозависимость.")
									-- wait(1700)
									-- sampSendChat("Вы можете излечиться на месте или прийти в следующий раз.")
									--	sobes.getStats = false
									--	return
								end
							else 
								table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) мед.карту. Не здоров.")
								sampSendChat("Извиняюсь, но У Вас проблемы со здоровьем.")
								wait(1700)
								sampSendChat("У Вас проблемы со здоровьем. Имеются психическое растройство.")
								sobes.player.heal = "Имеются отклонения"
								--	sobes.getStats = false
								--	return
							end
						else
							table.insert(sobes.logChat, "{E74E28}[Ошибка]{FFFFFF}: Кто-то другой пытался показать мед.карту.") 
						end 
					end
				end
			end
		end
		table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Проверка документов закончена.")
		wait(1700)
		if sobes.player.work == "Без работы" then
			sampSendChat("Отлично, у Вас всё в порядке с документами.")
			sobes.nextQ = true
			return
		else
			sampSendChat("Отлично, у Вас всё в порядке с документами.")
			wait(2000)
			sampSendChat("Но Вы работаете на другой государственной работе, требуется оставить форму своему работодателю.")
			wait(2000)
			sampSendChat("/n Увольтесь из работы, в который Вы сейчас состоите")
			wait(2000)
			sampSendChat("/n Уволиться с помощью команды /out при налчии Titan VIP или попросите в рацию.")
			sobes.nextQ = true
			return
		end
	end
	if id == 2 then
		sampSendChat("Теперь я задам Вам несколько вопросов.")
		wait(1700)
		table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: С какой целью Вы решили устроиться к нам в Больницу?.")
		sampSendChat("С какой целью Вы решили устроиться к нам в Больницу?")
	end
	if id == 3 then
		table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Есть ли у Вас спец.рация \"Discord\"?.")
		sampSendChat("Есть ли у Вас спец.рация \"Discord\"?.")
	end
	if id == 4 then
	table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Принятие игрока...")
	sampSendChat("Отлично, Вы приняты к нам на работу.")
	sobes.nextQ = false
		if num_rank.v+1 <= 8 then
			wait(1700)
			sampSendChat("Подойдите, пожалуйста, к Зам.Главного врача или Главному врачу")
			table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Пригласили игрока в организацию.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.logChat = {}
			sobes.nextQ = false
			sobes.num = 0
		else
		if sampIsPlayerConnected(sobes.selID.v) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(sobes.selID.v) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {sobes.selID.v, nm, true})
			wait(1700)
			sampSendChat("Сейчас я выдам Вам ключи от шкафчика с формой и другими вещами.")
			wait(1700)
			sampSendChat("/do В кармане халата находятся ключи отшкафчиков")
			wait(1700)
			sampSendChat("/me потянувшись во внутренний карман халата, "..chsex("достал","достала").." оттуда ключ")
			wait(1700)
			sampSendChat("/me передал".. chsex("", "а") .." ключ от шкафчика №"..sobes.selID.v.." с формой Интерна человеку напротив")
			wait(1700)
			sampSendChat("/invite "..sobes.selID.v)
			wait(1700)
			sampSendChat("/r Приветствуем нового сотрудника нашей организации - "..nm..".")
			else
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
			end
			table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Пригласили игрока в организацию.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.logChat = {}
			sobes.nextQ = false
			sobes.num = 0
		end
	end
	if id == 5 then
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас отпечатка в паспорте")
		wait(1700)
		sampSendChat("/n НонРП ник или другая причина.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 6 then
		wait(1000)
		sampSendChat("Извиняюсь, но требуется проживать в штате как минимум 3 года.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 7 then --sampSendChat("")
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас проблемы с законом.")
		wait(1700)
		sampSendChat("/n Требуется минимум 35 законопослушности.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 8 then
		wait(1000)
		sampSendChat("Извиняюсь, Вы работаете на другой государственной работе.")
		wait(1700)
		sampSendChat("/n Увольтесь из работы, в который Вы сейчас состоите")
		wait(1700)
		sampSendChat("/n Уволиться с помощью команды /out при налчии Titan VIP или попросите в рацию.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 9 then
		wait(1000)
		sampSendChat("Извиняюсь, но Вы состоите в Черном Списке нашей больнице.")
		wait(1700)
		sampSendChat("/n Для вынесения из ЧС требуется оставить заявку на форуме в разделе Мин.Здрав.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 10 then
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас проблемы со здоровьем.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 11 then
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас имеется наркозависимость.")
		wait(1700)
		sampSendChat("Для лечения этого можете купить таблетку в магазине или вылечиться у нас.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
end

function HideDialogInTh(bool)
	repeat wait(0) until sampIsDialogActive()
	while sampIsDialogActive() do
		local memory = require 'memory'
		memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
		sampToggleCursor(bool)
	end
end

function ShowHelpMarker(stext)
	imgui.TextDisabled(u8"(?)")
	if imgui.IsItemHovered() then
	imgui.SetTooltip(stext)
	end
end

function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or mainWin.v and editKey then
		return false
	end
end

function onHotKeyCMD(id, keys)
	if thread:status() == "dead" and lectime == false and statusvac == false then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(cmdBind) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				if k == 1 then
					mainWin.v = not mainWin.v
				elseif k == 2 then
					sampSetChatInputEnabled(true)
					if buf_teg.v ~= "" then
						sampSetChatInputText("/r "..u8:decode(buf_teg.v)..": ")
					else
						sampSetChatInputText("/r ")
					end
				elseif k == 3 then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/rb ")
				elseif k == 4 then
					sampSendChat("/members")
				elseif k == 5 then
					if resTarg then
						funCMD.lec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[5].cmd.." ")
					end
				elseif k == 6 then --пост
					funCMD.post()
				elseif k == 7 then
					if resTarg then
						funCMD.med(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[7].cmd.." ")
					end
				elseif k == 8 then
					if resTarg then
						funCMD.narko(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[8].cmd.." ")
					end
				elseif k == 9 then
					if resTarg then
						funCMD.recep(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[9].cmd.." ")
					end
				elseif k == 10 then
					funCMD.osm()
				elseif k == 11 then -- деп
					depWin.v = not depWin.v
				elseif k == 12 then -- соб
					sobWin.v = not sobWin.v
				elseif k == 13 then 
					if resTarg then
						funCMD.tatu(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[13].cmd.." ")
					end
				elseif k == 14 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[14].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[14].cmd.." ")
					end
				elseif k == 15 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[15].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[15].cmd.." ")
					end
				elseif k == 16 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[16].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[16].cmd.." ")
					end
				elseif k == 17 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[17].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[17].cmd.." ")
					end
				elseif k == 18 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[18].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[18].cmd.." ")
					end
				elseif k == 19 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[19].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[19].cmd.." ")
					end
				elseif k == 20 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[20].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[20].cmd.." ")
					end
				elseif k == 21 then
					funCMD.time()
				elseif k == 22 then
					if resTarg then
						funCMD.expel(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[22].cmd.." ")
					end
				elseif k == 23 then
					if resTarg then
						funCMD.vac(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[23].cmd.." ")
					end
				elseif k == 24 then
					funCMD.info()
				elseif k == 25 then
					funCMD.za()
				elseif k == 26 then
					funCMD.zd()
				elseif k == 27 then
					if resTarg then
						funCMD.ant(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[27].cmd.." ")
					end	
				elseif k == 28 then
					if resTarg then
						funCMD.strah(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[28].cmd.." ")
					end
				elseif k == 29 then
					if resTarg then
						funCMD.cur(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[29].cmd.." ")
					end
				elseif k == 30 then
					funCMD.hall()
				elseif k == 31 then
					funCMD.hilka()
				elseif k == 32 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[32].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[32].cmd.." ")
					end
				end
			end
		end
	elseif not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		wait(100)
	end
	if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() and lectime and not statusvac then 
		funCMD.lec(tostring(idMesPlayer))
		wait(100)
		lectime = false;
	end
end

local function strBinderTable(dir)
	local tb = {
		vars = {},
		bind = {},
		debug = {
			file = true,
			close = {}
		},
		sleep = 1000
	}
	if doesFileExist(dir) then
		local l = {{},{},{},{},{}}
		local f1 = io.open(dir)
		local t = {}
		local ln = 0
		for line in f1:lines() do
			if line:find("^//.*$") then
				line = ""
			elseif line:find("//.*$") then
				line = line:match("(.*)//")
			end
			ln = ln + 1
			if #t > 0 then
				if line:find("%[name%]=(.*)$") then
					t[#t].name = line:match("%[name%]=(.*)$")
				elseif line:find("%[[%a%d]+%]=(.*)$") then
					local k, n = line:match("%[([%d%a]+)%]=(.*)$")
					local nk = vkeys["VK_"..k:upper()]
					if nk then
						local a = {n = n, k = nk, kn = k:upper(), t = {}}
						table.insert(t[#t].var, a)
					end
				elseif line:find("{dialogEnd}") then
					if #t > 1 then
						local a = #t[#t-1].var
						table.insert(t[#t-1].var[a].t, t[#t])
						t[#t] = nil
					elseif #t == 1 then
						table.insert(tb.bind, t[1])
						t = {}
					end
					table.remove(tb.debug.close)
				elseif line:find("{dialog}") then
					local b = {}
					b.name = ""
					b.var = {}
					table.insert(tb.debug.close, ln)
					table.insert(t, b)
				elseif #line > 0 and #t[#t].var > 0 then --not line:find("#[%d%a]+=.*$") and 
					local a = #t[#t].var
					table.insert(t[#t].var[a].t, line)
				end
			else
				if line:find("{dialog}") and #t == 0 then
					local b = {} 
					b.name = ""
					b.var = {}
					table.insert(t, b)
					table.insert(tb.debug.close, ln)
				end
				if #tb.debug.close == 0 and #line > 0 then --and not line:find("^#[%d%a]+=.*$") 
					table.insert(tb.bind, line)
				end
			end
		end
		f1:close()
		return tb
	else
		tb.debug.file = false
		return tb
	end 
end

local function playBind(tb)
	if not tb.debug.file or #tb.debug.close > 0 then
		if not tb.debug.file then
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Файл с текстом бинда не обнаружен. ", 0xFF8FA2)
		elseif #tb.debug.close > 0 then
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Диалог, начало которого является строка №"..tb.debug.close[#tb.debug.close]..", не закрыт тегом {dialogEnd}", 0xFF8FA2)
		end
		addOneOffSound(0, 0, 0, 1058)
		return false
	end
	function pairsT(t, var)
		for i, line in ipairs(t) do
			if type(line) == "table" then
				renderT(line, var)
			else
				if line:find("{pause}") then
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
						wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "Ожидание...\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
						end
					end
				elseif line:find("{sleep:%d+}") then
					btime = tonumber(line:match("{sleep:(%d+)}"))
				elseif line:find("^%#[%d%a]+=.*$") then
					local var, val = line:match("^%#([%d%a]+)=(.*)$")
					tb.vars[var] = tags(val)			
				else
					wait(i == 1 and 0 or btime or tb.sleep*1000)
					btime = nil
					local str = line
					if var then
						for k,v in pairs(var) do
							str = str:gsub("#"..k, v)
						end
					end
					sampProcessChatInput(tags(str))
				end
			end
		end
	end
	function renderT(t, var)
		local render = true
		local len = renderGetFontDrawTextLength(font, t.name)
		for i,v in ipairs(t.var) do
			local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
			if len < renderGetFontDrawTextLength(font, str) then
				len = renderGetFontDrawTextLength(font, str)
			end
		end
		repeat
			wait(0)
			if not isGamePaused() then
				renderFontDrawText(font, t.name, sx-10-len, sy-#t.var*25-30, 0xFFFFFFFF)
				for i,v in ipairs(t.var) do
					local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
					renderFontDrawText(font, str, sx-10-len, sy-#t.var*25-30+(25*i), 0xFFFFFFFF)
					if isKeyJustPressed(v.k) and not sampIsChatInputActive() and not sampIsDialogActive() then
						pairsT(v.t, var)
						render = false
					end
				end
			end
		until not render						
	end					
	pairsT(tb.bind, tb.vars)
end

function onHotKeyBIND(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(binder.list) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				thread = lua_thread.create(function()		
					local dir = dirml.."/MedicalHelper/Binder/bind-"..v.name..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = v.sleep
					playBind(tb)
					return
				end)
			end
		end
	end
end

function binderCmdStart()
	for i,v in ipairs(binder.list) do
	local factCommand = sampGetChatInputText()
	local factCommandRussia = string.format(".%s", translatizator(binder.list[i].cmd))
	local sverkaCommand = string.format("/%s", binder.list[i].cmd)
		if sverkaCommand == factCommand or factCommand == factCommandRussia then
		local numberMassive = i
		local nameMassive = binder.list[i].name
			for k, v in pairs(binder.list) do
				if thread:status() == "dead" then
					thread = lua_thread.create(function()
					local dir = dirml.."/MedicalHelper/Binder/bind-"..nameMassive..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = binder.list[i].sleep
					playBind(tb)
					return
					end)	
				end
			end
		end
	end
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	
	render_text(string)
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then max = size.x end
	end
	return max - 15
end

function getSpurFile()
	spur.list = {}
    local search, name = findFirstFile("moonloader/MedicalHelper/Шпаргалки/*.txt")
	while search do
		if not name then findClose(search) else
			table.insert(spur.list, tostring(name:gsub(".txt", "")))
			name = findNextFile(search)
			if name == nil then
				findClose(search)
				break
			end
		end
	end
end

function getGovFile()
local govls = [[
/gov [Больница ЛС] - Ув.Жители Штата, сегодня в Больнице ЛС пройдёт день открытых дверей
/gov [Больница ЛС] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница ЛС] - Ждём всех желающих в холе Больнице ЛС.
]]
local govsf = [[
/gov [Больница СФ] - Ув.Жители Штата, сегодня в Больнице СФ пройдёт день открытых дверей
/gov [Больница СФ] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница СФ] - Ждём всех желающих в холе Больнице СФ.
]]
local govlv = [[
/gov [Больница ЛВ] - Ув.Жители Штата, сегодня в Больнице ЛВ пройдёт день открытых дверей
/gov [Больница ЛВ] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница ЛВ] - Ждём всех желающих в холе Больнице ЛВ.
]]
local govjf = [[
/gov [Больница Jafferson] - Ув.Жители Штата, сегодня в Больнице Джефферсон пройдёт день открытых дверей
/gov [Больница Jafferson] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница Jafferson] - Ждём всех желающих в холе Больнице Джефферсон.
]]
lua_thread.create(function()
	if doesDirectoryExist(dirml.."/MedicalHelper/Департамент/") then
		if doesFileExist(dirml.."/MedicalHelper/Департамент/День открытых дверей.txt") or not doesFileExist(dirml.."/MedicalHelper/Департамент/День открытых дверей ЛСМЦ.txt") then
			os.remove(dirml.."/MedicalHelper/Департамент/День открытых дверей.txt")
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей ЛСМЦ.txt", "w")
			f:write(govls)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей СФМЦ.txt", "w")
			f:write(govsf)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей ЛВМЦ.txt", "w")
			f:write(govlv)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей ДЖФМЦ.txt", "w")
			f:write(govjf)
			f:flush()
			f:close()
		end
		dep.news = {}
		local search, name = findFirstFile("moonloader/MedicalHelper/Департамент/*.txt")
		while search do
			if not name then findClose(search) else
				table.insert(dep.news, u8(tostring(name:gsub(".txt", ""))))
				name = findNextFile(search)
				if name == nil then
					findClose(search)
					break
				end
			end
		end
	end
end)
	brp = 0
	lua_thread.create(function()
		if doesFileExist(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[1])..".txt") then
			for line in io.lines(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[1])..".txt") do
				if brp < 6 then
					trtxt[brp + 1].v = u8(line)
					brp = brp + 1
				end
			end
		end
	end)
end

function filter(mode, filderChar)
	local function locfil(data)
		if mode == 0 then 
			if string.char(data.EventChar):find(filderChar) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filderChar) then 
				return true
			end
		end
	end 
	
	local cbFilter = imgui.ImCallback(locfil)
	return cbFilter
end

function tags(par)
		par = par:gsub("{myID}", tostring(myid))
		par = par:gsub("{myNick}", tostring(sampGetPlayerNickname(myid):gsub("_", " ")))
		par = par:gsub("{myRusNick}", tostring(u8:decode(buf_nick.v)))
		par = par:gsub("{myHP}", tostring(getCharHealth(PLAYER_PED)))
		par = par:gsub("{myArmo}", tostring(getCharArmour(PLAYER_PED)))
		par = par:gsub("{myHosp}", tostring(u8:decode(chgName.org[num_org.v+1])))
		par = par:gsub("{myHospEn}", tostring(u8:decode(list_org_en[num_org.v+1])))
		par = par:gsub("{myTag}", tostring(u8:decode(buf_teg.v))) 
		par = par:gsub("{myRank}", tostring(u8:decode(chgName.rank[num_rank.v+1])))
		par = par:gsub("{time}", tostring(os.date("%X")))
		par = par:gsub("{day}", tostring(tonumber(os.date("%d"))))
		par = par:gsub("{week}", tostring(week[tonumber(os.date("%w"))]))
		par = par:gsub("{month}", tostring(month[tonumber(os.date("%m"))]))
		
		if targID ~= nil then par = par:gsub("{target}", targID) end
		if par:find("{getNickByID:%d+}") then
			for v in par:gmatch("{getNickByID:%d+}") do
				local id = tonumber(v:match("{getNickByID:(%d+)}"))
				if sampIsPlayerConnected(id) then
					par = par:gsub(v, tostring(sampGetPlayerNickname(id))):gsub("_", " ")
				else
					sampAddChatMessage("{FFFFFF}[{FF8FA2}MH:Ошибка{FFFFFF}]: Параметр {getNickByID:ID} не смог вернуть ник игрока. Возможно игрок не в сети.", 0xFF8FA2)
					par = par:gsub(v,"")
				end
			end
		end
		if par:find("{sex:[%w%sа-яА-Я]*|[%w%sа-яА-Я]*}") then	
			for v in par:gmatch("{sex:[%w%sа-яА-Я]*|[%w%sа-яА-Я]*}") do
				local m, w = v:match("{sex:([%w%sа-яА-Я]*)|([%w%sа-яА-Я]*)}")
				if num_sex.v == 0 then
					par = par:gsub(v, m)
				else
					par = par:gsub(v, w)
				end
			end
		end
		
		if par:find("{getNickByTarget}") then
			if targID ~= nil and targID >= 0 and targID <= 1000 and sampIsPlayerConnected(targID) then
				par = par:gsub("{getNickByTarget}", tostring(sampGetPlayerNickname(targID):gsub("_", " ")))
			else
				sampAddChatMessage("{FFFFFF}[{FF8FA2}MH:Ошибка{FFFFFF}]: Параметр {getNickByTarget} не смог вернуть ник игрока. Возможно Вы не целились на игрока, либо он не в сети.", 0xFF8FA2)
				par = par:gsub("{getNickByTarget}", tostring(""))
			end
		end
	return par
end

funCMD = {} 
function funCMD.del()
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Вы успешно удалили скрипт.", 0xFF8FA2)
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Выгрузка скрипта из игры...", 0xFF8FA2)
	os.remove(scr.path)
	scr:reload()
end
function funCMD.lec(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then 
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
		local secTime = 1
			while setCmdEdit[5].text[secTime] ~= nil and secTime ~= 11 do
				if setCmdEdit[5].text[secTime] ~= "" then
					local sendChatsText = (tags(u8:decode(setCmdEdit[5].text[secTime])))
					if sendChatsText ~= " " then
						sampSendChat(sendChatsText)
						wait(setCmdEdit[5].sec[secTime])
					end
				end
				secTime = secTime + 1
			end
			sampSendChat("/heal "..id.." "..buf_lec.v)
		end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[5].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.strah(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
			if not isCharInModel(PLAYER_PED, 416) then
				sampSendChat(string.format("Здравствуйте, меня зовут %s, Вам нужна медицинская страховка?", u8:decode(buf_nick.v)))
				wait(2000)
				sampSendChat("Предоставьте, пожалуйста, Вашу мед. карту.")
				wait(2000)
				sampSendChat("/b /showmc "..myid)
				wait(1000)
					sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
					addOneOffSound(0, 0, 0, 1058)
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
						wait(0)
						renderFontDrawText(font, "Страховка: {8ABCFA}Ответ игрока\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-40, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("/todo Благодарю Вас!*взяв мед. карту в руки и начав её изучать.")
				wait(2000)
				sampSendChat("Для оформления медицинской страховки необходимо заплатить гос. пошлину, которая зависит от срока.")
				wait(2000)
				sampSendChat("На 1 неделю - 4ОО.ООО$. На 2 недели - 8ОО.ООО$. На 3 недели - 1.2ОО.ООО$")
				wait(2000)
				sampSendChat("На какой срок оформляем?")
				wait(1000)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
					addOneOffSound(0, 0, 0, 1058)
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
						wait(0)
						renderFontDrawText(font, "Страховка: {8ABCFA}Ответ игрока\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-40, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("Хорошо, тогда приступим к оформлению.")
				wait(2000)
				sampSendChat("/me вытащил".. chsex("", "а") .." из нагрудного кармана шариковую ручку")
				wait(2000)
				sampSendChat("/me открыл".. chsex("", "а") .." шкафчик, затем достал".. chsex("", "а") .." оттуда пустые бланки")
				wait(2000)
				sampSendChat("/me разложил".. chsex("", "а") .." пальцами правой руки мед. карту на нужной страничке и начал".. chsex("", "а") .." переписывать данные в бланк")
				wait(2000)
				sampSendChat("/me взял".. chsex("", "а") .." штамп в правую руку из ящика стола и ".. chsex("нанёс", "нанесла") .." оттиск в углу бланка")
				wait(2000)
				sampSendChat("/do Печать нанесена.")
				wait(2000)
				sampSendChat("/me отложив штамп в сторону, поставил".. chsex("", "а") .." свою подпись и сегодняшнюю дату")
				wait(2000)
				sampSendChat("/do Бланк успешно заполнен.")
				wait(2000)
				sampSendChat("Всё готово, держите свою медицинскую страховку. Удачного дня!")
				wait(1000)
				sampSendChat("/givemedinsurance "..id)
			end
		end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[28].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.cur(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
			if not isCharInModel(PLAYER_PED, 416) then
				sampSendChat("Не волнуйтесь, сейчас я окажу Вам экстренную помощь!")
				wait(2000)
				sampSendChat("/me легким движением пальца прислонил".. chsex("ся", "ась") .." к шее пациента, после чего начал".. chsex("", "а") .." измерять пульс")
				wait(2000)
				sampSendChat("/do У пациента отсутствует пульс.")
				wait(2000)
				sampSendChat("/todo Нужно быстро принять меры!*посмотрев на мед. сумку")
				wait(2000)
				sampSendChat("/do Мед. сумка находится в руках.")
				wait(2000)
				sampSendChat("/me легким движением руки открыл".. chsex("", "а") .." мед. сумку, после чего достал".. chsex("", "а") .." платок")
				wait(2000)
				sampSendChat("/me аккуратно приложил".. chsex("", "а") .." платок ко рту пострадавшего, после чего сделал".. chsex("", "а") .." глубокий вдох")
				wait(2000)
				sampSendChat("/do В лёгких много воздуха.")
				wait(2000)
				sampSendChat("/me встал".. chsex("", "а") .." на колени, после чего прислонил".. chsex("ся", "ась") .." к пациенту")
				wait(2000)
				sampSendChat("/me ".. chsex("подвёл", "подвела") .." губы ко рту пострадавшего, после чего начал".. chsex("", "а") .." делать искусственное дыхание")
				wait(2000)
				sampSendChat("/me ".. chsex("отвёл", "отвела") .." губы от рта пострадавшего, после чего сделал".. chsex("", "а") .." глубокий вдох")
				wait(2000)
				sampSendChat("/me ".. chsex("подвёл", "подвела") .." губы ко рту пострадавшего, после чего начал".. chsex("", "а") .." делать искусственное дыхание")
				wait(2000)
				sampSendChat("/do Пациент очнулся.")
				wait(2000)
				sampSendChat("/cure "..id)
				wait(5000)
				sampSendChat("/todo Ну вот, другое дело!*подняв человека на ноги")
			end
		end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[29].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.ant(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return
	end
	---1758.8267822266   -2020.3171386719   1500.7852783203
	---1785.8004150391   -1995.7534179688   1500.7852783203
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
			sampSendChat("Насколько я понял".. chsex("", "а") ..", Вам нужны антибиотики.")
			wait(2000)
			sampSendChat("Стоимость одного антибиотика составляет "..buf_ant.v.."$. Вы согласны?")
			wait(2000)
			sampSendChat("Если да, то какое количество Вам необходимо?")
			wait(1000)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
				while true do
					wait(0)
					renderFontDrawText(font, "Антибиотики: {8ABCFA}Ответ о кол-ве\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-90, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
			sampSendChat("/me открыв мед.сумку, схватил".. chsex("ся", "ась") .." за пачку антибиотиков, после чего вытянул".. chsex("", "а") .." их и положил на стол")
			wait(2000)
			sampSendChat("/do Антибиотики находятся на столе.")
			wait(2000)
			sampSendChat("/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку")
			wait(1000)
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Введите количество выдаваемых антибиотиков.", 0xFF8FA2)
			sampSetChatInputEnabled(true)
			sampSetChatInputText("/antibiotik "..id.." ")
		end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[27].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.vac(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return
	end
	if id:find("%d+") then
		thread = lua_thread.create(function()
			if not isCharInModel(PLAYER_PED, 416) then
			local counVacc = 1
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите {00E600}1{FFFFFF} если ставите первую вакцину. Нажмите {00E600}2{FFFFFF} если вторую.", 0xFF8FA2)
			addOneOffSound(0, 0, 0, 1058)
			local len = renderGetFontDrawTextLength(font, "Вакцинация {8ABCFA}Вторая или первая?")
			statusvac = true
					while true do
					wait(0)
						renderFontDrawText(font, "{8ABCFA}Вакцинация вторая или первая?:\n{FFFFFF}[{67E56F}1{FFFFFF}] - Первая вакцина\n{FFFFFF}[{67E56F}2{FFFFFF}] - Вторая вакцина", sx-len-10, sy-100, 0xFFFFFFFF)					
						if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then counVacc = 1; statusvac = false; break end
						if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then counVacc = 2; statusvac = false; break end
					end
				if counVacc == 1 then counVacc = 2
				sampSendChat("И так, очень хорошо, что Вы решили вакцинироваться.")
				wait(2000)
				sampSendChat("Стоимость всего сеанса вакцинации составляет 600.000$. Вы согласны?")
				wait(2000)
				sampSendChat("Если да, то присаживайтесь на кушетку и мы приступим.")
				wait(1000)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
				addOneOffSound(0, 0, 0, 1058)
				while true do
					wait(0)
						renderFontDrawText(font, "Вакцинирование: {8ABCFA}Соглашение\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx/5*3.6, sy-60, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end	
				end
				if counVacc == 2 then
				sampSendChat("/do На столе лежит шприц и баночка с надписью ''BioNTech''.")
				wait(2000)
				sampSendChat("/me взяв баночку со шприцом, приступил".. chsex("", "а") .." к закачке в неё жидкости")
				wait(2000)
				sampSendChat("/do Жидкость в шприце.")
				wait(2000)
				sampSendChat("/me достал".. chsex("", "а") .." из под стола ватку смоченную спиртом, после чего аккуратно протёр".. chsex("", "ла") .." будущее ...")
				wait(2000)
				sampSendChat("/do ... место укола пациенту, лежащему напротив.")
				wait(2000)
				sampSendChat("/me выбросив ватку, резко воткнул".. chsex("", "а") .." в мышцу шприц и высадил".. chsex("", "а") .." всю жидкость, после чего ...")
				wait(2000)
				sampSendChat("/do ... выбросил".. chsex("", "а") .." шприц в мусорное ведро и приложил".. chsex("", "а") .." к телу пациента стерильную ватку.")
				wait(1000)
				sampSendChat("/vaccine "..id)
				end
			end
		end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[23].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.med(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	if id:find("%d+") then
		local id = id:match("(%d+)")
	thread = lua_thread.create(function()
		local dir = dirml.."/MedicalHelper/rp-medcard.txt"	
		local tb = {}
		tb = strBinderTable(dir)
		tb.sleep = 1.85
		tb.vars["playerID"] = id
		playBind(tb)		
	end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[7].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.narko(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
		if id:find("(%d+)") then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s, займусь сегодняшним сеансом лечения Вас от наркозависимости.", u8:decode(buf_nick.v)))
				wait(2000)
				sampSendChat("Стоимость сеанса составляет "..buf_narko.v.."$. Вы согласны?")
				wait(2000)
				sampSendChat("/n Оплачивать не требуется, сервер сам предложит.")
				wait(1000)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
				addOneOffSound(0, 0, 0, 1058)
				while true do
					wait(0)
					renderFontDrawText(font, "Лечение наркозав-ти: {8ABCFA}Соглашение\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx/5*3.6, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end				
				sampSendChat("Если Вы согласны, садитесь на кушетку и закатайте рукав.")
				wait(2100)
				sampSendChat("/do На столе лежит ватка, жгут и шприц с вакциной.")
				wait(2100)
				sampSendChat("/me ".. chsex("взял", "взяла") .." со стола жгут")
				wait(2100)
				sampSendChat("/me ".. chsex("затянул", "затянула") .." жгут на плече пациента")
				wait(2100)
				sampSendChat("/do Жгут сильно затянут.")
				wait(2100)
				sampSendChat("/me ".. chsex("взял", "взяла") .." ватку и ".. chsex("смочил", "смочила") .." её спиртом")
				wait(2100)
				sampSendChat("/me протёр".. chsex("","ла") .." ваткой локтевой изгиб")
				wait(2100)
				sampSendChat("/todo Не волнуйтесь, будет не больно*взяв со стола шприц с вакциной")
				wait(2100)
				sampSendChat("/me плавным движением правой руки делает укол пациенту напротив")
				wait(2000)
				sampProcessChatInput("/healbad "..id:match("(%d+)"))
				wait(2100)
				sampSendChat("/me развязал".. chsex("", "а") .." жгут и выкинул".. chsex("", "а") .." шприц в урну")
				wait(2100)
				sampSendChat("Готово! Сеанс закончен, можете быть свободны.")
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[8].cmd.." [id игрока].", 0xFF8FA2)
		end
end
function funCMD.recep(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
		if id:find("(%d+)") then
			thread = lua_thread.create(function()
				local countRec = 1
				sampSendChat("Насколько я понял".. chsex("","а") ..", Вам нужны рецепты?")
				wait(2000)
				sampSendChat("Хорошо, стоимость одного рецепта "..buf_rec.v.."$.")
				wait(2000)
				sampSendChat("Скажите сколько Вам требуется рецептов, после чего мы продолжим.")
				wait(2000)
				sampSendChat("/n Внимание! В течении минуты выдаётся максимум 5 рецептов на руки.")
				wait(500)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на цифру верхней цифровой панели равная количеству выдаваемых рецептов.", 0xFF8FA2)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Выдача рецептов: {8ABCFA}Выбор кол-ва")
					while true do
					wait(0)
						renderFontDrawText(font, "Выдача рецептов: {8ABCFA}Выбор кол-ва\n{FFFFFF}[{67E56F}1{FFFFFF}] - 1 шт.\n{FFFFFF}[{67E56F}2{FFFFFF}] - 2 шт.\n{FFFFFF}[{67E56F}3{FFFFFF}] - 3 шт.\n{FFFFFF}[{67E56F}4{FFFFFF}] - 4 шт.\n{FFFFFF}[{67E56F}5{FFFFFF}] - 5 шт.", sx-len-10, sy-150, 0xFFFFFFFF)					
						if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =1; break end
						if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =2; break end
						if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =3; break end
						if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =4; break end
						if isKeyJustPressed(VK_5) and not sampIsChatInputActive() and not sampIsDialogActive() then countRec =5; break end
					end
				wait(200)
				sampSendChat("/me достал".. chsex("", "а") .." из под стола бланк оформления лекарств, после чего начал".. chsex("", "а") .." его заполнять ")
				wait(2000)
				sampSendChat("/do Бланки успешно заполнены.")
				wait(2000)
				sampSendChat("/todo Вот, держите!*передавая рецепты человеку напротив")
				wait(1000)
				sampSendChat("/recept "..id.." "..countRec)
				countRec = 1
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[9].cmd.." [id игрока].", 0xFF8FA2)
		end
end
function funCMD.post(stat)
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	if not isCharInModel(PLAYER_PED, 416) then -- not
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Чтобы заступить на мобильный пост, Вам необходимо сначала сесть в карету.", 0xFF8FA2)
		addOneOffSound(0, 0, 0, 1058)
	else
		local bool, post, coord = postGet()
		if not bool then
			sampShowDialog(2001, ">{FFB300}Посты", "                             {55BBFF}Выберите пост\n"..table.concat(post, "\n"), "{69FF5C}Выбрать", "{FF5C5C}Отмена", 5)
			sampSetDialogClientside(false)
		elseif bool then
			if stat:find(".+") then
				sampSendChat(string.format("/r Докладывает: %s. Нахожусь на посту %s, обстановка: %s", u8:decode(buf_nick.v):gsub("%X+%s", ""), post, stat))
			else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Укажите обстановку, например, /"..cmdBind[6].cmd.." Спокойно.", 0xFF8FA2)
			end
		end
	end
end
function funCMD.tatu(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
		if id:find("(%d+)") then
			thread = lua_thread.create(function()
				sampSendChat("Добрый день, Вы по поводу сведения татуировки?")
				wait(3000)
				sampSendChat("Покажите Ваш паспорт, пожалуйста.")
				wait(1000)
					addOneOffSound(0, 0, 0, 1058)
					sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Паспорт игрока автоматически закроется, после чего продолжится диалог..", 0xFF8FA2)
					repeat wait(0) until sampIsDialogActive()
					while sampIsDialogActive() do
						local memory = require 'memory'
						memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
						sampToggleCursor(bool)
					end
				sampSendChat("/me "..chsex("принял","приняла").." с рук обратившегося паспорт")
				wait(2000)
				sampSendChat("/do Паспорт обратившегося в правой руке.")
				wait(2000)
				sampSendChat("/me ознакомившись с паспортом обратившегося, "..chsex("вернул","вернула").." его обратно")
				wait(2000)
				sampSendChat("Стоимость выведения татуировки составит "..buf_tatu.v.."$. Вы согласны?")
				wait(2000)
				sampSendChat("/n Оплачивать не требуется, сервер сам предложит")
				wait(2000)
				sampSendChat("/b Покажите татуировки с помощью команды /showtatu")
					sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
					addOneOffSound(0, 0, 0, 1058)
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
					wait(0)
						renderFontDrawText(font, "Сведение тату: {8ABCFA}Соглашение\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-75, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("Я смотрю, Вы готовы, тогда снимайте с себя рубашку, чтоб я "..chsex("вывел","вывела").." Вашу татуировку.")
				wait(2000)
				sampSendChat("/do У стены стоит инструментальный столик с подносом.")
				wait(2000)
				sampSendChat("/do Аппарат для выведения тату на подносе.")
				wait(2500)
				sampSendChat("/me "..chsex("взял","взяла").." аппарат для выведения татуировки с подноса")
				wait(2000)
				sampSendChat("/me осмотрев пациента, "..chsex("принялся","принялась").." выводить его татуировку")
				wait(2000)
				sampSendChat("/unstuff "..id.." "..buf_tatu.v)
				wait(5000)
				sampSendChat("Всё, Ваш сеанс закончен. Всего Вам хорошего!")
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[13].cmd.." [id игрока].", 0xFF8FA2)
		end	
end
function funCMD.warn(text)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
				sampSendChat("/do В левом кармане лежит телефон.")
				wait(2000)
				sampSendChat("/me достал".. chsex("", "а") .." телефон, после чего ".. chsex("зашёл", "зашла") .." в базу данных "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("изменил","изменила").." информацию о сотруднике "..nm)
				wait(2000)
				sampSendChat(string.format("/fwarn %s %s", id, reac))
				wait(2000)
				sampSendChat("/r "..nm.." получил выговор по причине: "..reac)
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[14].cmd.." [id игрока] [причина].", 0xFF8FA2)
		end
end
function funCMD.uwarn(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if id:find("(%d+)") then
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
				sampSendChat("/do В левом кармане лежит телефон.")
				wait(2000)
				sampSendChat("/me достал".. chsex("", "а") .." телефон из кармана, после чего ".. chsex("зашёл", "зашла") .." в базу данных "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("изменил","изменила").." информацию о сотруднике "..nm)
				wait(2000)
				sampSendChat("/unfwarn "..id)
				wait(2000)
				sampSendChat("/r Сотруднику "..nm.." снят выговор!")
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[15].cmd.." [id игрока].", 0xFF8FA2)
		end
end
function funCMD.inv(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if id:find("(%d+)") then
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
					sampSendChat("/do В кармане халата находятся ключи от шкафчика.")
					wait(2000)
					sampSendChat("/me потянувшись во внутренний карман халата, "..chsex("достал","достала").." оттуда ключ")
					wait(2000)
					sampSendChat("/me "..chsex("передал","передала").." ключ от шкафчика №"..id.." с формой Интерна человеку напротив")
					wait(1000)
					sampSendChat("/invite "..id)
					wait(2000)
					sampSendChat("/r Приветствуем нового сотрудника нашей организации - "..nm..".")
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[19].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.unv(text)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
				sampSendChat("/do В левом кармане находится телефон.")
				wait(2000)
				sampSendChat("/me достал".. chsex("", "а") .." телефон, после чего ".. chsex("зашёл", "зашла") .." в базу данных "..u8:decode(chgName.org[num_org.v+1]))
				wait(2000)
				sampSendChat("/me "..chsex("изменил","изменила").." информацию о сотруднике "..nm)
				wait(1700)
				sampSendChat(string.format("/uninvite %d %s", id, reac))
				wait(1200)
				sampSendChat("/r Сотрудник "..nm.." был уволен по причине: "..reac)
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[20].cmd.." [id игрока] [причина].", 0xFF8FA2)
		end
end
function funCMD.mute(text)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if text:find("(%d+)%s(%d+)%s(%X+)") then
		local id, timem, reac = text:match("(%d+)%s(%d+)%s(%X+)")
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
					sampSendChat("/do Рация весит на поясе.")
					wait(2000)		
					sampSendChat("/me снял".. chsex("", "а") .." рацию с пояса")
					wait(2000)
					sampSendChat("/me ".. chsex("зашёл", "зашла") .." в настройки локальных частот вещания рации")
					wait(2000)					
					sampSendChat("/me заглушил".. chsex("", "а") .." локальную частоту вещания сотруднику "..nm)
					wait(2000)
					sampSendChat(string.format("/fmute %d %d %s", id, timem, reac))
					wait(2000)
					sampSendChat("/r Сотруднику "..nm.." была отключена рация по причине: "..reac)
					wait(2000)		
					sampSendChat("/me повесил".. chsex("", "а") .." рацию обратно на пояс")
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[16].cmd.." [id игрока] [время в минутах] [причина].", 0xFF8FA2)
		end
end
function funCMD.umute(id)
	if thread:status() ~= "dead" and not lectime and not statusvac then 
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if id:find("(%d+)") then
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
					sampSendChat("/do Рация весит на поясе.")
					wait(2000)		
					sampSendChat("/me снял".. chsex("", "а") .." рацию с пояса")
					wait(2000)
					sampSendChat("/me ".. chsex("зашёл", "зашла") .." в настройки локальных частот вещания рации")
					wait(2000)					
					sampSendChat("/me освободил локальную частоту вещания сотруднику "..nm)
					wait(2000)
					sampSendChat("/funmute "..id)
					wait(2000)
					sampSendChat("/r Сотруднику "..nm.." снова включена рация.")
					wait(2000)		
					sampSendChat("/me повесил".. chsex("", "а") .." рацию обрано на пояс")
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[17].cmd.." [id игрока].", 0xFF8FA2)
	end
end
function funCMD.rank(text)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
		if text:find("(%d+)%s([1-9])") then
		local id, rankNum = text:match("(%d+)%s(%d)")
		local id = tonumber(id); rankNum = tonumber(rankNum);
		thread = lua_thread.create(function()
		if sampIsPlayerConnected(id) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
		nick = sampGetPlayerNickname(id) 
				local nm = trst(nick)
				emul_rpc('onSetPlayerName', {id, nm, true})
					sampSendChat("/do В кармане халата находится футляр с ключами от шкафчиков с формой.")
					wait(1500)
					sampSendChat("/me потянувшись во внутренний карман халата, достал".. chsex("", "а") .." оттуда футляр")
					wait(1500)
					sampSendChat("/me открыв футляр, достал".. chsex("", "а") .." оттуда ключ c номером "..id)
					wait(1500)
					sampSendChat("/me передал".. chsex("", "а") .." ключ от шкафчика №"..id.." с формой человеку напротив")
					wait(1500)
					sampProcessChatInput("/giverank "..id.." "..rankNum)
					wait(1500)
					sampSendChat("/r Сотрудник "..nm.." получил новую должность! Поздравляем!")
				else
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
				end
			end)
		else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[18].cmd.." [id игрока] [номер ранга].", 0xFF8FA2)
		end
end
function funCMD.osm()
	if thread:status() ~= "dead" and not lectime and not statusvac then 
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
		thread = lua_thread.create(function()
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF}, если готовы начать осмотр или {FF8FA2}Page Down{FFFFFF} для отмены.", 0xFF8FA2)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Осмотр: {8ABCFA}Ожидание ответа")
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Начать\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				sampSendChat("Здравствуйте, сейчас я проведу для Вас небольшое мед. обследование.")
				wait(2000)
				sampSendChat("Пожалуйста, предоставьте Вашу мед. карту.")
				wait(1000)
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("/me "..chsex("взял","взяла").." мед. карту из рук человека")
				wait(2000)
				sampSendChat("/do Медицинская карта и ручка с печатью в руках.")
				wait(2000)
				sampSendChat("Итак, сейчас я задам некоторые вопросы для оценки состояния здоровья.")
				wait(2500)
				sampSendChat("Давно ли Вы болели? Если да, то какими болезнями?")
				wait(1000)
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("Были ли у Вас травмы?")
				wait(1000)
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				wait(2000)
				sampSendChat("Имеются ли какие-то аллергические реакции?")
				wait(2000)
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
				end
				sampSendChat("/me "..chsex("сделал","сделала").." записи в мед. карте")
				wait(2000)
				sampSendChat("Так, откройте рот.")
				wait(2000)
				sampSendChat("/b /me открыл(а) рот")
				wait(2000)
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("/do В кармане фонарик.")
				wait(2000)
				sampSendChat("/me "..chsex("достал","достала").." фонарик из кармана, после чего включил".. chsex("","а") .." его")
				wait(2000)
				sampSendChat("/me "..chsex("осмотрел","осмотрела").." горло пациента")
				wait(2000)
				sampSendChat("Можете закрыть рот.")
				wait(3000)
				sampSendChat("/me "..chsex("проверил","проверила").." реакцию зрачков пациента на свет, посветив в глаза")
				wait(2000)
				sampSendChat("/do Зрачоки глаз обследуемого сузились.")
				wait(2000)
				sampSendChat("/me "..chsex("выключил","выключила").." фонарик и "..chsex("убрал","убрала").." его в карман")
				wait(2000)
				sampSendChat("Присядьте, пожалуйста, на корточки и коснитесь кончиком пальца до носа.")
					addOneOffSound(0, 0, 0, 1058)
					while true do
					wait(0)
						renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание действия\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-15, sy-50, 0xFFFFFFFF)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
					end
				sampSendChat("Вставайте.")
				wait(2000)
				sampSendChat("/me "..chsex("сделал","сделала").." записи в медицинской карте")
				wait(2000)
				sampSendChat("/me "..chsex("вернул","вернула").." мед. карту человеку напротив")
				sampSendChat("Спасибо, можете быть свободны.")
		end)
end
function funCMD.hall()
	local maxIdInStream = sampGetMaxPlayerId(true)
	for i = 0, maxIdInStream do
	local result, handle = sampGetCharHandleBySampPlayerId(i)
		if result and doesCharExist(handle) then
			local px, py, pz = getCharCoordinates(playerPed)
			local pxp, pyp, pzp = getCharCoordinates(handle)
			local distance = getDistanceBetweenCoords2d(px, py, pxp, pyp)
			if distance <= 4 then
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/hl "..i)
			end
		end
	end
end
function funCMD.hilka()
local id = getNearestID()
	if id then
		name = sampGetPlayerNickname(id)
		thread = lua_thread.create(function()
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Выбранный игрок: {5BF165}"..name.." ["..id.."]", 0xFF8FA2)
			local secTime = 1
			while setCmdEdit[5].text[secTime] ~= nil and secTime ~= 11 do
				if setCmdEdit[5].text[secTime] ~= "" then
					local sendChatsText = (tags(u8:decode(setCmdEdit[5].text[secTime])))
					if sendChatsText ~= " " then
						sampSendChat(sendChatsText)
						wait(setCmdEdit[5].sec[secTime])
					end
				end
				secTime = secTime + 1
			end
			sampSendChat("/heal "..id.." "..buf_lec.v)
		end)
	else
    sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Ближайший игрок не найден!", 0xFF8FA2)
	end
end
function funCMD.sob()
	sobWin.v = not sobWin.v
end
function funCMD.dep()
	if num_rank.v+1 < 5 then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
	depWin.v = not depWin.v
end
function funCMD.hme()
	local _, plId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	sampSendChat("/heal "..plid)
end
function funCMD.memb()
	sampSendChat("/members")
end
function funCMD.za()
sampSendChat("Пройдёмте за мной.")
end
function funCMD.zd()
if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	thread = lua_thread.create(function()
			if not isCharInModel(PLAYER_PED, 416) then
				sampSendChat(string.format("Здравствуйте, меня зовут %s, чем могу помочь?", u8:decode(buf_nick.v)))
			end
		end)
	end
function funCMD.time()
	lua_thread.create(function()
		sampSendChat("/time")
		wait(1500)
	--	mem.setint8(sampGetBase() + 0x119CBC, 1)
		setVirtualKeyDown(VK_F8, true)
		wait(20)
		setVirtualKeyDown(VK_F8, false)
	end)
end
function funCMD.info()
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Частые команды:", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[5].cmd.." [id игрока]{FFFFFF} - вылечить пациента", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[7].cmd.." [id игрока]{FFFFFF} - выдать мед. карту", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[9].cmd.." [id игрока]{FFFFFF} - выдать рецепт", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[8].cmd.." [id игрока]{FFFFFF} - вылечить от наркозависимости", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[13].cmd.." [id игрока]{FFFFFF} - вывести татуировку с тела", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[23].cmd.." [id игрока]{FFFFFF} - вакцинировать пациента", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[27].cmd.." [id игрока]{FFFFFF} - продать антибиотики", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[28].cmd.." [id игрока]{FFFFFF} - оформить мед. страховку", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[29].cmd.." [id игрока]{FFFFFF} - поднять человека на ноги", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[26].cmd.."{FFFFFF} - отправить приветствие в чат", 0xFF8FA2)
end
function funCMD.expel(par)
	if thread:status() ~= "dead" and not lectime and not statusvac then
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return 
	end
	if par:find("(%d+)%s([а-яА-Я%a%s]+)") then
		local id, reas = par:match("(%d+)%s([а-яА-Я%a%s]+)") 
		thread = lua_thread.create(function()
			sampSendChat("/me резким движением руки "..chsex("ухватился","ухватилась").." за воротник нарушителя")
			wait(2000)
			sampSendChat("/do Крепко держит нарушителя за воротник.")
			wait(2000)
			sampSendChat("/todo Я "..chsex("вынужден","вынуждена").." вывести вас из здания*направляясь к выходу.")
			wait(2000)
			sampSendChat("/me движением левой руки "..chsex("открыл","открыла").." входную дверь, после чего "..chsex("вытолкнул","вытолкнула").." нарушителя")
			wait(500)
			sampSendChat("/expel "..id.." "..reas)
		end)
	else
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[22].cmd.." [id игрока] [Причина].", 0xFF8FA2)
	end
end
function funCMD.shpora(number)
	if number:find("(%d+)") then
		getSpurFile()
		spur.select_spur = 0 + number
		if spur.select_spur <= #spur.list and spur.select_spur > 0 then
			local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
			spur.text.v = u8(f:read("*a"))
			f:close()
			spur.name.v = u8(spur.list[spur.select_spur])
			spurBig.v = true
		elseif spur.select_spur <= 0 then
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Порядковый счёт шпаргалок начинается с единицы.", 0xFF8FA2)
		else
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Шпаргалки под таким номером не существует.", 0xFF8FA2)
		end
	else
		sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[32].cmd.." [номер шпаргалки по счёту].", 0xFF8FA2)
	end
end
--[[function funCMD.testmh(num)
	if num:find("%d+") then
		addOneOffSound(0, 0, 0, (num+0)) --1057 
		print(num)
	end
end]]
--[[
function funCMD.openupd()
	print(shell32.ShellExecuteA(nil, 'open', "http://forum.arizona-rp.com/index.php?threads/Министерство-Здравоохранения-Официальный-скрипт-для-больниц-medical-helper.1119179/", nil, nil, 1))
end
]]

function funCMD.update()
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Производится скачивание новой версии скрипта...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper.lua"
	local url = "https://drive.google.com/u/0/uc?id=11_UChZk4OLX8C6wN9Ac3XeyCNYmSebUR&export=download"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}Ошибка при попытке скачать файл.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Произошла ошибка при скачивании обновления. Активация резервого источника...", 0xFF8FA2)
				
				updWin.v = false
				lua_thread.create(function()
					wait(500)
					funCMD.updateEr()
				end)
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("Загрузка закончена")
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Скачивание завершено, перезагрузка библиотек...", 0xFF8FA2)
			reloadScripts()
			showCursor(false) 
		end
	end)
end

function funCMD.updateEr()
local erTx =  
[[
{FFFFFF}Похоже, что-то мешает скачиванию обновлению.
Это может быть как антивирус, так и анти-стиллер, который блокирует скачивание.
Если у Вас отключен антивирус, отсутствует анти-стиллер, то видимо что-то другое
блокирует скачивание. Поэтому нужно будет скачать файл отдельно.

Пожалуйста, посетите официальную тему скрипта на форуме Arizona RP
Тему можно найти по следующему пути:
{A1DF6B}forum.arizona-rp.com -> Сервер 6 -> Гос.Струк. -> Минист.Здрав. -> Официальный скрипт для больниц{FFFFFF}
Скачайте автмоатический установочник.

Либо скачайте файл скрипта отдельно. Ссылка для скачивания уже скопирована.
	1. Откройте браузер и вставьте ссылку в адресную строку (Ctrl + V). Скачается файл.
	2. Зайдите в папку игры и откройте папку Moonloader.
	3. Удалите файл MedicalHelper.lua
	4. Переместите скаченный файл в папку Moonloader. 
	{FCB32B}5. Убедитесь, что название не содержит лишних символов, например MedicalHelper{F65050}(1){FCB32B}.luac
]]
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Производится скачивание новой версии скрипта...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper.lua"
	local url = urlupd
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}Ошибка при попытке скачать файл.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Произошла ошибка при скачивании обновления. Похоже, скачиванию что-то мешает.", 0xFF8FA2)
				sampShowDialog(2001, "{FF0000}Ошибка обновления", erTx, "Закрыть", "", 0)
				setClipboardText("https://drive.google.com/u/0/uc?id=11_UChZk4OLX8C6wN9Ac3XeyCNYmSebUR&export=download")
				updWin.v = false
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("Загрузка закончена")
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Скачивание завершено, перезагрузка библиотек...", 0xFF8FA2)
			reloadScripts()
			showCursor(false)
		end
	end)
end

--//// ПРОВЕРКА ОБНОВЛЕНИЙ
function funCMD.updateCheck()
	sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Проверка наличия обновлений...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper/files/update.med"
	local url = "https://drive.google.com/u/0/uc?id=1pxwbPIq20kF1E3fLRgo6G6p9GOwhM7CZ&export=download"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(1000)
				if doesFileExist(dirml.."/MedicalHelper/files/update.med") then
					local f = io.open(dirml.."/MedicalHelper/files/update.med", "r")
					local upd = decodeJson(f:read("*a"))
					f:close()
					if type(upd) == "table" then
						newversion = upd.version
						urlupd = upd.url
						if upd.version == scr.version then
							sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Всё отлично, Вы используете самую новую версию скрипта.", 0xFF8FA2)
						else
							sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} {4EEB40}Имеется обновление.{FFFFFF} Напиши {22E9E3}/update{FFFFFF} для получения информации.", 0xFF8FA2)
							wait(5000)
							updWin.v = true
						end
					end
				end
			end)
		end
	end)
	local dir = dirml.."/MedicalHelper/files/update.txt"
	local url = "https://drive.google.com/u/0/uc?id=1xyS96MR8GNLUwlzdNnZOcgDGWhwMYGcQ&export=download"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(1000)
				if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
				local f = io.open(dirml.."/MedicalHelper/files/update.txt", "r")
				updinfo = f:read("*a")
				f:close()
				end
			end)
		end
	end)
end

function round(num, step) --> 1) число | 2) шаг округления
  return math.ceil(num / step) * step
end

function hook.onServerMessage(mesColor, mes)
	if mes:find("Сумма к выплате: $(%d+)") then --> Зарплата
		local mesPay = mes:match("Сумма к выплате: $(.+)")
		local mesPay = mesPay:gsub("%D","")
		--local mesPay = mes:match("Сумма к выплате: $(%d+)")
		profit_money.total_all = profit_money.total_all + (mesPay + 0)
		profit_money.payday[1] = profit_money.payday[1] + (mesPay + 0)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы вылечили (.+) за ") then --> Лечение
		local mesPay = mes:match("$(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + round(mesPay / 2, 1)
		profit_money.lec[1] = profit_money.lec[1] + round(mesPay / 2, 1)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы выдали (.+) сроком") then --> Медкарта
		local mesPay = mes:match(" на (%d+)")
		if (mesPay+0) == 7 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[1] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[1] / 2, 1)
		end
		if (mesPay+0) == 14 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[2] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[2] / 2, 1)
		end
		if (mesPay+0) == 30 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[3] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[3] / 2, 1)
		end
		if (mesPay+0) == 60 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[4] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[4] / 2, 1)
		end
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы начали лечение (.+) от наркозависимости за ") then --> Нарко
		local mesPay = mes:match("(.+)$")
		local mesPay = mesPay:gsub("%D","")
	--	print(mesPay)
		profit_money.total_all = profit_money.total_all + (mesPay/2)
		profit_money.narko[1] = profit_money.narko[1] + (mesPay/2)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {ffffff}Вы сделали (.+) против коронавируса игроку (.+) за ") then --> Вакцинация 
		--local mesPay = mes:match("(%d+)%$")
		profit_money.total_all = profit_money.total_all + 240000
		profit_money.vac[1] = profit_money.vac[1] + 240000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы продали антибиотики (.+) игроку (.+) за (.+)ваша") then --> Антибиотики
		--local mesPay = mes:match("прибыль: $(%d+)")
		local mesPay = mes:match("прибыль: $(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + (mesPay + 0)
		profit_money.ant[1] = profit_money.ant[1] + (mesPay + 0)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы продали (%d+) рецептов (.+) за ") then --> Рецепты
		--local mesPay = mes:match("$(%d+)%.")
		local mesPay = mes:match("$(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + round(mesPay / 2, 1)
		profit_money.rec[1] = profit_money.rec[1] + round(mesPay / 2, 1)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find(">>>{FFFFFF} "..sampGetPlayerNickname(myid).."%[(%d+)%] доставил 100 медикаментов на склад больницы!") then --> Медикаменты
		profit_money.total_all = profit_money.total_all + 100000
		profit_money.medcam[1] = profit_money.medcam[1] + 100000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("Вы поставили на ноги игрока (.+)") then --> Cure ПРОВЕРКА НА ФОРМУ!!
		profit_money.total_all = profit_money.total_all + 300000
		profit_money.cure[1] = profit_money.cure[1] + 300000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] Вы успешно продали мед.страховку игроку (.+)") then --> Страховка
		profit_money.total_all = profit_money.total_all + 200000
		profit_money.strah[1] = profit_money.strah[1] + 200000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lek") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lechi") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lekni")
	or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)bolit") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)golova") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)fast")
	or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)vylechi") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)tabl") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)khil") then --> Автолечение
		if not ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lekts") then
			if accept_autolec.v and not sampIsChatInputActive() and not sampIsDialogActive() then 
				local mesPlayer = mes:match("(.+)говорит:")
				idMesPlayer = mesPlayer:match("%[(%d+)%]")
				_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if (idMesPlayer+1) ~= (myid+1) then
					local keysi = {49}
					rkeys.registerHotKey(keysi, true, onHotKeyCMD)
					lua_thread.create(function()
						wait(15)
						EXPORTS.sendRequest()
						wait(10)
						if myforma then
							addOneOffSound(0, 0, 0, 1058)
							sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} Нажмите {00E600}1{FFFFFF} чтобы вылечить игрока {00E600}"..mesPlayer.."{FFFFFF}. У Вас есть 5 секунд.", 0xFF8FA2)
							lectime = true
							wait(5000)
							lectime = false
						end
					end)
				end
			end
		end
	end
	if mes:find("Администратор ((%w+)_(%w+)):(.+)спавн") or mes:find("Администратор (%w+)_(%w+):(.+)Спавн") then --> Спавн транспорта
		if accept_spawn.v and not errorspawn then
			local stap = 0
			lua_thread.create(function()
				errorspawn = true
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stap = stap + 1
				until stap > 15
				wait(62000)
				errorspawn = false
			end)
		end
	end
	if cb_chat2.v then
		if mes:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or mes:find("- Основные команды сервера: /menu /help /gps /settings") or mes:find("Пригласи друга и получи бонус в размере") or mes:find("- Донат и получение дополнительных средств arizona-rp.com/donate") or mes:find("Подробнее об обновлениях сервера") or mes:find("(Личный кабинет/Донат)") or mes:find("С помощью телефона можно заказать") or mes:find("В нашем магазине ты можешь") or mes:find("их на желаемый тобой {FFFFFF}бизнес") or mes:find("Игроки со статусом {FFFFFF}VIP{6495ED} имеют большие возможности") or mes:find("можно приобрести редкие {FFFFFF}автомобили, аксессуары, воздушные") 
		or mes:find("предметы, которые выделят тебя из толпы! Наш сайт:") or mes:find("Вы можете купить складское помещение") or mes:find("Таким образом вы можете сберечь своё имущество, даже если вас забанят.") or mes:find("Этот тип недвижимости будет навсегда закреплен за вами и за него не нужно платить.") or mes:find("{ffffff}Уважаемые жители штата, открыта продажа билетов на рейс:") or mes:find("{ffffff}Подробнее: {FF6666}/help — Перелёты в город Vice City.") or mes:find("{ffffff}Внимание! На сервере Vice City действует акция Х3 PayDay.") or mes:find("%[Подсказка%] Игроки владеющие (.+) домами могут бесплатно раз в день получать") or mes:find("%[Подсказка%] Игроки владеющие (.+) домами могут получать (.+) Ларца Олигарха") then 
			return false
		end
	end
	if cb_chat3.v then
		if mes:find("News LS") or mes:find("News SF") or mes:find("News LV") then 
			return false
		end
	end
	if cb_chat1.v then
		if mes:find("Объявление:") or mes:find("Отредактировал сотрудник") then
		return false
		end
	end
	local function stringN(str, color)
		if str:len() > 72 then
			local str1 = str:sub(1, 70)
			local str2 = str:sub(71, str:len())
			return str1.."\n".."{"..color.."}"..str2
		else 
			return str
		end
	end
	if sobes.selID.v ~= "" and sobes.player.name ~= "" then
		
		if mes:find(sobes.player.name.."%[%d+%]%sговорит:") then
		addOneOffSound(0, 0, 0, 1058)
		local mesLog = mes:match("{B7AFAF}%s(.+)")
		local mesLog = stringN(mesLog, "B7AFAF")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF} говорит: {B7AFAF}"..mesLog)
		end
		
		if mes:find(sobes.player.name.."%[%d+%]%s%(%(") then
		local mesLog = mes:match("}(.+){")
		local mesLog = stringN(mesLog, "B7AFAF")
		table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF} говорит: {B7AFAF}(( "..mesLog.." ))")
		end
		if mes:find(sobes.player.name.."%[%d+%]%s[%X%w]+") and mesColor == -6684673 then
			local mesLog = mes:match("%[%d+%]%s([%X%w]+)")
			local mesLog = stringN(mesLog, "F35373")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.." {F35373}[/me]: "..mesLog)
		end
		if mes:find("%-%s%|%s%s"..sobes.player.name.."%[%d+%]") then
			local mesLog = mes:match("([%X%w]+)%s%s%-%s%|%s%s"..sobes.player.name)
			local mesLog = stringN(mesLog, "2679FF")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.." {2679FF}[/do]: "..mesLog)
		end
	end
	if mes:find("%[D%]") and not mes:find("%[D%] [%X%a]+ ".. sampGetPlayerNickname(myid) .."%[%d+%]:") then
		local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:")
		if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
			local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:%p*(.+)")
			table.insert(dep.dlog, "{7ECAFF}"..org.."{FFFFFF}"..mesD)
		end
	end
	if mes:find("%[D%] [%X%a]+ ".. sampGetPlayerNickname(myid) .."%[%d+%]:") then
		local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:")
		if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
			local mesD = mes:match("%[D%] [%X%a]+ ".. sampGetPlayerNickname(myid) .."%[%d+%]:%p*(.+)")
			table.insert(dep.dlog, "{39e81e}"..org.."{FFFFFF}"..mesD)
		end
	end
end

function hook.onDisplayGameText(st, time, text)
	if text:find("~y~%d+ ~y~"..os.date("%B").."~n~~w~%d+:%d+~n~ ~g~ Played ~w~%d+ min") then
		if cb_time.v then
			lua_thread.create(function()
			wait(100)
			sampSendChat(u8:decode(buf_time.v))
			if cb_timeDo.v then
				wait(1000)
				sampSendChat("/do Часы показывают время - "..os.date("%H:%M:%S"))
			end
			end)
		end
	end
end

function hook.onSendCommand(cmd)
	if cmd:find("/r ") then
		if cb_rac.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_rac.v))
			end)
		end
	end
	if cmd:find("/time") then
		if cb_time.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_time.v))
			end)
		end
	end
end

function hook.onSendSpawn()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
end

function hook.onSendDialogResponse(id, but, list)
	if sampGetDialogCaption() == ">{FFB300}Посты" then
		if but == 1 then
			local bool, post, coord = postGet()
			placeWaypoint(coord[list+1].x, coord[list+1].y, 20)
			sampAddChatMessage("{FF8FA2}[MedHelper]{FFFFFF} На карте была выставлена метка места назначения.", 0xFF8FA2)
			addOneOffSound(0, 0, 0, 1058)
		elseif but == 0 then
		end
	end
end

function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{53E03D}Вкл{ffffff}"
end

function getStrByState2(keyState)
	if keyState == 0 then
		return ""
	end
	return "{F55353}Caps{ffffff}"
end

function showInputHelp()
	local chat = sampIsChatInputActive()
	if chat == true then
		local cx, cy = getCursorPos()
		local in1 = sampGetInputInfoPtr()
		local in1 = getStructElement(in1, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		local posX = in2 + 15
		local posY = in3 + 45
		local _, pID = sampGetPlayerIdByCharHandle(playerPed)
		local Nname = sampGetPlayerNickname(pID)
		local score = sampGetPlayerScore(pID)
		local color = sampGetPlayerColor(pID)
		local ping = sampGetPlayerPing(pID)
		local capsState = ffi.C.GetKeyState(20)
		local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
		local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
		local localName = ffi.string(LocalInfo)
		local text = string.format(
			"%s | {%0.6x}%s [%d] {ffffff}| Пинг: {ffeeaa}%d{FFFFFF} | Капс: %s {FFFFFF}| Язык: {ffeeaa}%s{ffffff}",
			os.date("%H:%M:%S"), bit.band(color,0xffffff), Nname, pID, ping, getStrByState(capsState), string.match(localName, "([^%(]*)")
		)
		renderFontDrawText(textFont, text, posX, posY, 0xD7FFFFFF)
		if cx >= posX+280 and cx <= posX+280+80 and cy >= posY and cy <= posY+25 then
			if isKeyJustPressed(VK_RBUTTON) then hudPing = not hudPing end
		end
	end
end

function hudTimeF()
	local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
	local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
	local localName = ffi.string(LocalInfo)
	local capsState = ffi.C.GetKeyState(20)
	local function lang()
		local str = string.match(localName, "([^%(]*)")
		if str:find("Русский") then
			return "Ru"
		elseif str:find("Английский") then
			return "En"
		end
	end
	local text = string.format("%s | {ffeeaa}%s{ffffff} %s", os.date("%d ")..month[tonumber(os.date("%m"))]..os.date(" - %H:%M:%S"), lang(), getStrByState2(capsState))
	if thread:status() ~= "dead" then
		renderFontDrawText(fontPD, text, 20, sy-50, 0xFFFFFFFF)
	else
		renderFontDrawText(fontPD, text, 20, sy-25, 0xFFFFFFFF)
	end
end

function pingGraphic(posX, posY)
	
	local ping0 = posY + 150
	local time = posX - 200
	local function colorG(value)
		if value <= 70 then
			return 0xFF9EEFA9
		elseif value >= 71 and value <=89 then
			return 0xFFF8DE75
		elseif value >= 90 and value <= 99 then
			return 0xFFF88B75
		elseif value >= 100 then
			return 0xFFEB2700
		end
	end
			renderDrawBoxWithBorder(posX-200, posY, 400, 150, 0x50B5B5B5, 2, 0xF0838383)

			renderDrawLine(time, ping0-50, time+400, ping0-50, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-100, time+400, ping0-100, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-150, time+400, ping0-150, 1, 0x50FFFFFF)
			renderFontDrawText(fontPing, "Ping", posX-20,  posY-16, 0xAFFFFFFF)
			local maxPing = 0
			for i,v in ipairs(pingLog) do
				if maxPing < v then maxPing = v end
			end
	for i,v in ipairs(pingLog) do
		if maxPing <= 150 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)], time+10*i, ping0-v, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]-10, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/2, time+10*i, ping0-v/2, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/2-10, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/5, time+10*i, ping0-v/5, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/5-10, 0xAFFFFFFF)
		end
			
	end
		if maxPing <= 150 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 50, time-20,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 150, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 200, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 300, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 250, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 500, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 750, time-30,  ping0-160, 0xAFFFFFFF)
		end
end

function chsex(textMan, textWoman)
	if num_sex.v == 0 then
		return textMan
	else
		return textWoman
	end
end

function postGet(sel)
	local postname = {"Мэрия","ЖД Вокзал ЛС","Ферма","ЖД Вокзал СФ","Автошкола","Автобазар","СМИ ЛВ","Казино ЛВ","ЖД Вокзал ЛВ", "Армия ЛС", "ВМС", "Тюрьма ЛВ"}
	local coord = {{},{},{},{},{},{},{},{},{}, {}, {}, {}}
	coord[1].x, coord[1].y = 1506.41, -1284.02
	coord[2].x, coord[2].y = 1827.11, -1896.01
	coord[3].x, coord[3].y = -88.35, 112.01
	coord[4].x, coord[4].y = -1998.56, 123.25
	coord[5].x, coord[5].y = -2027.53, -56.07
	coord[6].x, coord[6].y = -2115.08, -746.49
	coord[7].x, coord[7].y = 2612.48, 1163.39
	coord[8].x, coord[8].y = 2078.78, 1001.05
	coord[9].x, coord[9].y =  2825.00, 1294.61
	coord[10].x, coord[10].y = 2727, -2503.5
	coord[11].x, coord[11].y = -1347, 462.5
	coord[12].x, coord[12].y = 223, 1813.5

	if sel ~= nil and isCharInArea2d(PLAYER_PED, coord[sel].x-50, coord[sel].y-50, coord[sel].x+50, coord[sel].y+50,false) then
		local coord = {}
		coords.x, coords.y = coord[sel].x, coord[sel].y
		return true, postname, coords
	end

		if isCharInArea2d(PLAYER_PED, 1506.41-50, -1284.02-50, 1506.41+50, -1284.02+50,false) then
			local coord = {}
			coord.x, coord.y = 1506.41, -1284.02
			return true, postname[1], coord
		end
		if isCharInArea2d(PLAYER_PED, 1827.11-50, -1896.01-50, 1827.11+50, -1896.01+50,false) then
			local coord = {}
			coord.x, coord.y = 1827.11, -1896.01
			return true, postname[2], coord
		end
		if isCharInArea2d(PLAYER_PED, -88.35-50, 112.01-50, -88.35+50, 112.01+50,false) then
			local coord = {}
			coord.x, coord.y = -88.35, 112.01
			return true, postname[3], coord
		end
		if isCharInArea2d(PLAYER_PED, -1998.56-50, 123.25-50, -1998.56+50, 123.25+50,false) then
			local coord = {}
			coord.x, coord.y = -1998.56, 123.25
			return true, postname[4], coord
		end
		if isCharInArea2d(PLAYER_PED, -2027.53-50, -56.07-50, -2027.53+50, -56.07+50,false) then
			local coord = {}
			coord.x, coord.y = -2027.53, -56.07
			return true, postname[5], coord
		end
		if isCharInArea2d(PLAYER_PED, -2115.08-50, -746.49-50, -2115.08+50, -746.49+50,false) then
			local coord = {}
			coord.x, coord.y = -2115.08, -746.49
			return true, postname[6], coord
		end
		if isCharInArea2d(PLAYER_PED, 2612.48-50, 1163.39-50, 2612.48+50, 1163.39+50, false) then 
			local coord = {}
			coord.x, coord.y = 2612.48, 1163.39
			return true, postname[7], coord
		end
		if isCharInArea2d(PLAYER_PED, 2078.78-50, 1001.05-50, 2078.78+50, 1001.05+50,false) then
			local coord = {}
			coord.x, coord.y = 2078.78, 1001.05
			return true, postname[8], coord
		end
		if isCharInArea2d(PLAYER_PED, 2825.00-50, 1294.61-50, 2825.00+50, 1294.61+50,false) then
			local coord = {}
			coord.x, coord.y = 2825.00, 1294.61
			return true, postname[9], coord
		end
	return false, postname, coord
end

local await = {
	members = false,
	next_page = {
		bool = false,
		i = 0
	}
}
local members = {}
local org = {
	name = 'Организация',
	online = 0,
	afk = 0
}
myforma = false
function hook.onShowDialog(id, style, title, but_1, but_2, text)
	if id == 2015 and await.members then 
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		myNick = sampGetPlayerNickname(myid)
		local count = 0
		await.next_page.bool = false
		org.name, org.online = title:match('{FFFFFF}(.+)%(В сети: (%d+)%)')
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('Ник') and not line:find('страница') then
    			local color = string.match(line, "^{(%x+)}")
	    		local nick, id, rank_name, rank_id, warns, afk, quests = string.match(line, '([A-z_0-9]+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+) %((%d+).+\t(%d+)')
	    		local mute = string.find(line, '| MUTED')
	    		local near = select(1, sampGetCharHandleBySampPlayerId(tonumber(id)))
	    		local uniform = (color == 'FFFFFF')

	    		members[#members + 1] = { 
					nick = tostring(nick),
					id = id,
					rank = {
						count = tonumber(rank_id),
						name = tostring(rank_name),
					},
					afk = tonumber(afk),
					warns = tonumber(warns),
					quests = tonumber(quests),
					mute = mute,
					near = near,
					uniform = uniform
				}
			end

    		if line:match('Следующая страница') then
    			await.next_page.bool = true
    			await.next_page.i = count - 2 -- (-2 т.к. невидимая строка "/n /n" + строка заголовков столбцов)
    		end
    	end

    	if await.next_page.bool then
    		sampSendDialogResponse(id, 1, await.next_page.i, _)
    		await.next_page.bool = false
    		await.next_page.i = 0
    	else
    		while #members > tonumber(org.online) do 
    			table.remove(members, 1) 
    		end
    		sampSendDialogResponse(id, 0, _, _)
    		await.members = false
    	end
		for i, member in ipairs(members) do
			if members[i].nick == myNick and members[i].uniform == true then
			myforma = true
			end
			if members[i].nick == myNick and members[i].uniform == false then
			myforma = false
			end
		end
		
		return false
	elseif await.members and id ~= 2015 then
		print('Обновление мемберса было сбито другим диалогом [ ' .. id .. ' | "' .. title .. '" ]')
		dontShowMeMembers = true
		await.members = false
		await.next_page.bool = false
    	await.next_page.i = 0
    	while #members > tonumber(org.online) do 
			table.remove(members, 1) 
		end
	elseif dontShowMeMembers and id == 2015 then
		dontShowMeMembers = false
		lua_thread.create(function(); wait(0)
			sampSendDialogResponse(id, 0, nil, nil)
		end)
		return false
	end
end

function EXPORTS.sendRequest()
	if not sampIsDialogActive() then
		await.members = true
		sampSendChat("/members")
		return true
	end
	return false
end


helpsob = [[
1. По началу работы требуется указать требуемый id игрока.
После чего нажать на кнопку "Начать". Начнётся процесс проверки.
Во время проверки не получится резко поменять игрока. Для этого
можно воспользоваться кнопкой "Остановить/Очистить", которая
сотрёт все текущие данные и можно будет прописать новый id.

Все данные с документов заносятся автоматически. В случае показа
чужих документов, они будут отклонены.
2. По окончанию проверки документов, задаются несколько вопросов.
Для продолжения действия нажимается кнопка "Дальше вопрос".
Также можете самостоятельно задать дополнительный вопрос по
нажатию на кнопку "Внеочередной вопрос".
3. После автоматических вопросов приглашается игрок.
Вы можете самостоятельно принять решение для приглашения или
отклонения игрока по нажатию на кнопку "Определить годность".
]]

otchotTx = [[
		Для этого нужно открыть страницу форума {5CE9B5}forum.arizona-rp.com{FFFFFF}, после чего чуть ниже найти 
		список игровых серверов, из которых нужно выбрать тот, на котором Вы сейчас находитесь. 
		Потом откройте раздел {5CE9B5}'Государственные структуры'{FFFFFF}, далее раздел {5CE9B5}'Мин. Здравоохранения'{FFFFFF}. 
		Перед Вами будет 3 раздела больниц, выбираете тот, в каком Вы больнице находитесь. 
		И последнее, найдите тему похожая на {5CE9B5}'Отчёты младшего состава'{FFFFFF}. Тут Вам предстоит прочесть, 
		как оформлять. После ознакомления скопируйте для удобства форму и в нижнее окно вставьте. 
		Теперь Вам нужно рассортировать Ваши скриншоты по пунктам. например имеются скриншоты 
		лечения людей и выдача мед.карт. Требуется сделать {F75647}раздельно{FFFFFF} лечения и выдача мед.карт,
		а не отправлять кучей. Дальше выберите любой один ниже представленный список сайтов, 
		куда будете заливать скриншоты.
			Как перешли на сайт, нужно {F75647}загрузить туда скриншоты, не перемешивая по назначению. 
		То есть, берёте скриншоты лечения, к примеру, и заливате на сайт. После загрузки получаете 
		ссылку. Её требуется скопировать и вставить в форму отчёта. 
			Например: {5CE9B5}Лечение - [ссылка]{FFFFFF}, и так далее. Как всё сделаете, отправляете отчёт. 
			{F75647}																	Внимание!
	Если по нажанию на кнопку, сообщение не отправляется, не спешите тыкать по много раз, 
	возможно форум лагает. Подождите немного, если не отправляется, то скопируйте свой отчёт, 
	перезагрузите страницу и вставьте. На этом всё!
]]

remove = [[
{FFFFFF}Для удаления скрипта необходимо подтвердить действие командой.

	Команда: {FBD82B}/delete accept{FFFFFF}
	
После процесса удаления скрипт выгрузится из игры.
Для восстановления скрипта необходимо будет заново произвести установку.
]]