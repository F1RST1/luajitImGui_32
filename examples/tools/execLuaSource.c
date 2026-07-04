/* Just simple launcher for ../bin/luajitw.exe to hide console window.
 *
 * This program executes
 *
 *  ../bin/luajitw.exe "thisProgramName.lua"
 *
 *  if thisProgramName[.exe] is renamed to glfw_opengl3[.exe] then,
 *  glfw_opengl3.exe just executes [ ../bin/luajitw.exe "glfw_opengl3.lua" ].
 *
 * 2026-07: by dinau
 * 2024-10: by dinau
 */

#include <windows.h>
#include <stdio.h>
#include <string.h>

#define ERROR_MSG(msg) fprintf(stderr, "Error: %s  [%s:%d]\n", msg, __FILE__, __LINE__)

const char* sLuajitwExe = "..\\..\\bin\\luajitw.exe";

int main(int argc,char** argv){
  const int MAX_STR = 2048;
  char sFname[MAX_STR];
  char sLuaNameEx[MAX_STR];
  GetModuleFileName(NULL, sFname, sizeof(sFname));
  printf("Exe = %s\n",sFname);

  char* dot = strrchr(sFname, '.');
  if (dot){
    dot[0] = '\0';
    strcat_s(sFname, MAX_STR, ".lua");
    sprintf_s(sLuaNameEx, MAX_STR, "\"%s\"", sFname);   // Guard string with ""

    printf("LuaName = %s\n", sFname);
    printf("LuaNameEx = %s\n", sLuaNameEx);

    HINSTANCE ret = ShellExecute(NULL, NULL, sLuajitwExe, sLuaNameEx, NULL, SW_NORMAL);
    if ((INT_PTR)ret > 32){
      return 0; // OK return
    }
    ERROR_MSG("ShellExecute() failed");
  }

  ERROR_MSG("failed");
  return 1; // Error return
}
