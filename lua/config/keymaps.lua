-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- funni visual selection go brrrr
local function comment() -- block commenting code -- language-specific
    local s_start = vim.fn.getpos("v")[2]
    local s_end = vim.fn.getpos(".")[2]
    local js = math.abs(s_end - s_start)
    local jstring
    
    if (js == 0)
    then
        jstring = ""
    else
        jstring = tostring(js) .. "j"
    end
    
    return "<Esc>:'<<Enter>0<C-v>" .. jstring .. "I##<Esc>"
end

local function uncomment() -- uncomment
    local s_start = vim.fn.getpos("v")[2]
    local s_end = vim.fn.getpos(".")[2]
    local js = math.abs(s_end - s_start)
    local jstring
    
    if (js == 0)
    then
        jstring = ""
    else
        jstring = tostring(js) .. "j"
    end
    
    return "<Esc>:'<<Enter>0<C-v>l" .. jstring .. ":s/##/<Enter>"
end

local function bracket(str) -- auto go in to parentheses -- language-specific
    bracket_map = {
        [")"] = "(",
        ["]"] = "[",
        ["}"] = "{",
        ["\""] = "\"" -- not using this one because of python """ gets messed up but I mean you could
    }
    _line, cursorpos = unpack(vim.api.nvim_win_get_cursor(0))
    
    if (cursorpos <= 0)
    then
        return str
    end
    
    before_cursor = vim.api.nvim_get_current_line():sub(cursorpos, cursorpos)
    
    if (before_cursor ~= bracket_map[str])
    then
        return str
    else
        return str .. "<Left>"
    end
end

local function startswith(str, substr)
    if (string.sub(str, 1, string.len(substr)) == substr)
    then
        return true
    end
    
    return false
end

local function get_line(num)
    return vim.api.nvim_buf_get_lines(0, num, num + 1, true)[1]
end

local function last_import(imports) -- language-specific
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true) .. "gg", "m", false)
    -- vim.api.nvim_input("<Esc>gg")
    -- i_feedkeys("<Esc>gg")
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true) .. "gg", "i", false)
    -- fuck me I hate keypresses in keymaps in this api
    vim.cmd("stopinsert")
    found_last = false
    cur_line_num = 0
    
    while (not found_last) do -- iterate over lines
        current_line = get_line(cur_line_num)
        valid_import = false
        
        count = 0
        for _i in pairs(imports) do count = count + 1 end -- length of table imports
        
        for i = 1,count,1 -- iterate over every import (so either {"import"} or {"import", "from"} in normal usage)
        do
            if ((startswith(current_line, imports[i])) or (current_line == "")) -- is line an import/(from?)/<empty>?
            then
                valid_import = true
                break
            end
        end
        
        if (not valid_import) -- this line is invalid
        then
            found_last = true
            break
        end
        
        cur_line_num = cur_line_num + 1 -- go to next line
        
        if (cur_line_num >= vim.api.nvim_buf_line_count(0))
        then
            found_last = true
            break
        end
    end
    
    cur = get_line(cur_line_num - 1) -- cur_line_num is first invalid line
    while (cur == "") -- if last line is empty, backtrack
    do
        cur_line_num = cur_line_num - 1
        cur = get_line(cur_line_num - 1)
    end
    
    jstring = ""
    if (cur_line_num < 1)
    then
        error("No imports found to navigate to")
    elseif (cur_line_num == 1)
    then -- leave jstring empty
    else
        jstring = tostring(cur_line_num - 1) .. "j"
    end
    
    return jstring
end

local function autoimport() -- language-specific
    local status, msg = pcall(last_import, { "import" })
    
    if (not status)
    then
        if (msg:find("No imports found to navigate to", 1, true))
        then
            return "_i<Enter><Enter><Up><Up>"
        else
            error(msg .. " in last_import({ \"import\" })")
        end
    else
        importjval = msg
        if (string.len(importjval) <= 0)
        then
            return "$<Enter>a"
        else
            return importjval .. "$a<Enter>"
        end
    end 
end


leader_1 = "," -- leader key go brrrr

vim.keymap.set("n", "x", "\"_x", {remap=false, desc="Delete"}) -- the x key no longer goes to any register
vim.keymap.set("v", "x", "\"_x", {remap=false, desc="Delete"})

vim.keymap.set("n", "<C-a>", "gg_vG$", {remap=true, desc="Select All"})
vim.keymap.set("i", "<C-a>", "<Esc>gg_vG$", {remap=true, desc="Select All"})

vim.keymap.set("n", leader_1 .. "l", "mq_d0`q:delm q<Enter>", {remap=true, desc="Unindent"})
vim.keymap.set("i", leader_1 .. "l", "<Esc>mq_d0`q:delm q<Enter>a", {remap=true, desc="Unindent"})

vim.keymap.set("n", leader_1 .. "x", "$a-<Esc>v0xa<Backspace><Esc>", {remap=true, desc="Delete Line"}) -- does some stuff with leaving the cursor in the right place which is why it's better than dd
vim.keymap.set("i", leader_1 .. "x", "<Esc>$a-<Esc>v0xa<Backspace>", {remap=true, desc="Delete Line"})

vim.keymap.set("n", leader_1 .. "n", "$a<Enter><Esc>", {remap=true, desc="Create newline under"})
vim.keymap.set("i", leader_1 .. "n", "<Esc>$a<Enter>", {remap=true, desc="Create newline under"})

vim.keymap.set("n", leader_1 .. "v", "$v_x", {remap=true, desc="Clear line"})
vim.keymap.set("i", leader_1 .. "v", "<Esc>$v_xa", {remap=true, desc="Clear line"})

vim.keymap.set("n", leader_1 .. "b", "$v0y$a<Enter><Esc>p$", {remap=true, desc="Copy and Paste Line"})
vim.keymap.set("i", leader_1 .. "b", "<Esc>$v0y$a<Enter><Esc>p$a", {remap=true, desc="Copy and Paste Line"})

vim.keymap.set("n", leader_1 .. "p", "p", {remap=true, desc="Paste"})
vim.keymap.set("i", leader_1 .. "p", "-<Esc>xpa", {remap=true, desc="Paste"})

vim.keymap.set("n", leader_1 .. "j", "j_\"qy$$v0xa<Backspace><Esc>\"qp", {remap=true, desc="Move next line to end of current line"})
vim.keymap.set("i", leader_1 .. "j", "<Esc>j_\"qy$$v0xa<Backspace><Esc>\"qpa", {remap=true, desc="Move next line to end of current line"})

vim.keymap.set("n", leader_1 .. "ya", "mq<C-a>y`q:delm q<Enter>", {remap=true, desc="Yank all"})
vim.keymap.set("i", leader_1 .. "ya", "<Esc>mq<C-a>y`q:delm q<Enter>a", {remap=true, desc="Yank all"})

vim.keymap.set("n", leader_1 .. "ii", function() return "gg" .. last_import({ "import" }) .. "$" end, {remap=true, desc="Go to last import", expr=true}) -- python funni go brrrr
vim.keymap.set("i", leader_1 .. "ii", function() return "gg" .. last_import({ "import" }) .. "$a" end, {remap=true, desc="Go to last import", expr=true})
vim.keymap.set("n", leader_1 .. "if", function() return "gg" .. last_import({ "import", "from" }) .. "$" end, {remap=true, desc="Go to last import", expr=true})
vim.keymap.set("i", leader_1 .. "if", function() return "gg" .. last_import({ "import", "from" }) .. "$a" end, {remap=true, desc="Go to last import", expr=true})

vim.keymap.set("i", leader_1 .. "a", function() return "<Esc>mqv_\"qdgg" .. autoimport() .. "import <Esc>\"qp`q$:delm q<Enter>a" end, {remap=true, desc="Auto import last word", expr=true})

vim.keymap.set("i", ")", function() return bracket(")") end, {remap=true, expr=true}) -- auto go into parentheses/bracket/braces
vim.keymap.set("i", "]", function() return bracket("]") end, {remap=true, expr=true})
vim.keymap.set("i", "}", function() return bracket("}") end, {remap=true, expr=true})
-- vim.keymap.set("i", "\"", function() return bracket("\"") end, {remap=true, expr=true})
-- ^ this one screws up python """

vim.keymap.set("n", leader_1 .. "c", "_i#<Esc>", {remap=true, desc="Comment"})
vim.keymap.set("i", leader_1 .. "c", "<Esc>_i#", {remap=true, desc="Comment"})
vim.keymap.set("v", leader_1 .. "c", function() return comment() end, {remap=true, desc="Block Comment", expr=true})

vim.keymap.set("n", leader_1 .. "u", "_<C-v>:s/#//<Enter>", {remap=true, desc="Uncomment"})
vim.keymap.set("i", leader_1 .. "u", "<Esc>_<C-v>:s/#//<Enter>i", {remap=true, desc="Uncomment"})
vim.keymap.set("v", leader_1 .. "u", function() return uncomment() end, {remap=true, desc="Block Uncomment", expr=true})

vim.keymap.set("n", leader_1 .. "m", "vbx", {remap=true, desc="Delete last word"})
vim.keymap.set("i", leader_1 .. "m", "<Esc>vbxa", {remap=true, desc="Delete last word"})

vim.keymap.set("n", "<Home>", "_", {remap=true, desc="Go home, after indents"})
vim.keymap.set("i", "<Home>", "<Esc>_i", {remap=true, desc="Go home, after indents"})
vim.keymap.set("v", "<Home>", "_", {remap=true, desc="Go home, after indents"})

-- language-specific
vim.keymap.set("n", "<F5>", ":w<Enter>:exec '!start cmd /C pythonp' shellescape(@%, 1)<Enter>", {remap=true, desc="Run Python"})
vim.keymap.set("i", "<F5>", "<Esc>:w<Enter>:exec '!start cmd /C pythonp' shellescape(@%, 1)<Enter>a", {remap=true, desc="Run Python"})

vim.keymap.set("n", "<F9>", ":tabp<Enter>", {remap=true, desc="Previous Tab"})
vim.keymap.set("i", "<F9>", "<Esc>:tabp<Enter>a", {remap=true, desc="Previous Tab"})

vim.keymap.set("n", "<F10>", ":tabn<Enter>", {remap=true, desc="Next Tab"})
vim.keymap.set("i", "<F10>", "<Esc>:tabn<Enter>a", {remap=true, desc="Next Tab"})