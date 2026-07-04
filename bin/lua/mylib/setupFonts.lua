local ffi   = require "ffi"
local utils = require"mylib.utils"
local IFA   = require"mylib.fonticon.IconsFontAwesome6"

-------------
--- point2px
-------------
function point2px(point) -- ## Convert point to pixel
  return ((point * 96) / 72)
end

local config -- Define as global
---------------
--- setupFonts
---------------
function setupFonts(ig)
  config = ig.ImFontConfig()
  local pio = ig.GetIO()
  local fontsAtlas = pio.Fonts
  local sActiveFontTitle = ""
  local fontTbl = {
                   {fontName="meiryo.ttc",  point=14.5, fontNo=0, title="メイリオ"}     -- Windows7, 8
                  ,{fontName="YuGothM.ttc", point=11.5, fontNo=0, title="ゆうゴシック"} -- Windows10, 11
                  ,{fontName="Msyh.ttc",    point=11.5, fontNo=0, title="Microsoft YaHei UI"} -- China
                  ,{fontName="Msyjh.ttc",   point=11.5, fontNo=0, title="Microsoft JhengHei UI"} -- Taiwan, Hongkong
                  ,{fontName="segoeuil.ttf",point=14.0, fontNo=0, title="Seoge UI"}     -- English region standard font
                  }
  local theFONT = nil
  local sActiveFontName = ""
  for _, fInfo in ipairs(fontTbl) do
    sActiveFontName = os.getenv("windir") .. "/fonts/" .. fInfo.fontName
    if utils.fileExists(sActiveFontName) then
      config.FontNo = fInfo.fontNo
      theFONT = fontsAtlas:AddFontFromFileTTF(sActiveFontName ,point2px(fInfo.point) ,nil ,nil)
      if (theFONT ~= nil) then
        pio.FontDefault = theFONT -- OK, set as first font
        sActiveFontTitle = fInfo.title
        break
      end
    end
  end -- end for
  if (theFONT == nil) then
    print("Error!: First font loading error", sActiveFontName)
  end

  -- Add Icon font
  local ranges_icon_fonts = ffi.new("unsigned int[3]",IFA.ICON_MIN_FA,  IFA.ICON_MAX_FA, 0)
  local path = require"anima.path"
  local iconFontPath = path.chain(path.animapath() ,"..","mylib","fonticon","fa6" ,"fa-solid-900.ttf")
  if utils.fileExists(iconFontPath) then
    config.MergeMode = true
    fontsAtlas:AddFontFromFileTTF(iconFontPath ,point2px(11) ,config ,nil)
    print("Loaded Icon font: ", iconFontPath)
  else
    print("Error!: Can't find Icon fonts: " , iconFontPath)
  end

  return true, sActiveFontName, sActiveFontTitle
end
