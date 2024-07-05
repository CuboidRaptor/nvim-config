// %~dp0alacritty.exe --title nvim -e "nvim %*"
#include <stdlib.h>
#include <iostream>

#include <filesystem>
#ifdef _WIN32
    #include <windows.h>
#elif
    #include <unistd.h>
#endif

// from Fedor on StackOverflow
std::filesystem::path GetExeDirectory()
{
#ifdef _WIN32
    // Windows specific
    wchar_t szPath[MAX_PATH];
    GetModuleFileNameW( NULL, szPath, MAX_PATH );
#else
    // Linux specific
    char szPath[PATH_MAX];
    ssize_t count = readlink( "/proc/self/exe", szPath, PATH_MAX );
    if( count < 0 || count >= PATH_MAX )
        return {}; // some error
    szPath[count] = '\0';
#endif
    return std::filesystem::path{ szPath }.parent_path() / ""; // to finish the folder path with (back)slash
}

int main(int argc, char *argv[]) {
    std::string arguments;
    if (argc > 1)
    {
        for (int i = 1; i < argc; i++)
        {
            arguments += argv[i];
        }
    }
    else
    {
        arguments = "";
    }
    
    std::string start = "start ";
    std::string current_script_dir = GetExeDirectory().string();
    std::string command = "alacritty --title \"NeoVim - Powered by Alacritty\"";
    std::string config_command = " --config-file \"";
    config_command += current_script_dir + "alacritty-config/alacritty.toml\"";
    std::string nvim_command = std::string(" -e \"nvim ") + arguments + "\"";
    
    std::string output = start + current_script_dir + command + config_command + nvim_command;
    
    std::cout << output;
    system(output.c_str());
    return 0;
}