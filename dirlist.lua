local harpoon = require("harpoon")
local popup = require("plenary.popup")
local utils = require("harpoon.utils")
local log = require("harpoon.dev").log

local M = {}

Harpoon_dirlist_win_id = nil
Harpoon_dirlist_bufh = nil

local function close_menu(force_save)
    force_save = force_save or false
    local global_config = harpoon.get_global_settings()

    if global_config.save_on_toggle or force_save then
        require("harpoon.dirlist").on_menu_save()
    end

    vim.api.nvim_win_close(Harpoon_dirlist_win_id, true)

    Harpoon_dirlist_win_id = nil
    Harpoon_dirlist_bufh = nil
end

local function create_window()
    log.trace("_create_window()")
    local config = harpoon.get_menu_config()
    local width = config.width or 60
    local height = config.height or 10
    local borderchars = config.borderchars
        or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local Harpoon_dirlist_win_id, win = popup.create(bufnr, {
        title = "Harpoon to Directories",
        highlight = "HarpoonWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:HarpoonBorder"
    )

    return {
        bufnr = bufnr,
        win_id = Harpoon_dirlist_win_id,
    }
end

local function get_menu_items()
    log.trace("_get_menu_items()")
    local lines = vim.api.nvim_buf_get_lines(Harpoon_dirlist_bufh, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        if not utils.is_white_space(line) then
            table.insert(indices, line)
        end
    end

    return indices
end

function M.toggle_quick_list()
    log.trace("toggle_quick_list()")
    if Harpoon_dirlist_win_id ~= nil and vim.api.nvim_win_is_valid(Harpoon_dirlist_win_id) then
        close_menu()
        return
    end

    local win_info = create_window()
    local contents = {}
    local global_config = harpoon.get_global_settings()

    Harpoon_dirlist_win_id = win_info.win_id
    Harpoon_dirlist_bufh = win_info.bufnr

    -- Load directory list from config
    local dir_list = global_config.dir_list or {}
    for idx, dir in ipairs(dir_list) do
        contents[idx] = dir
    end

    vim.api.nvim_win_set_option(Harpoon_dirlist_win_id, "number", true)
    vim.api.nvim_buf_set_name(Harpoon_dirlist_bufh, "harpoon-dirlist")
    vim.api.nvim_buf_set_lines(Harpoon_dirlist_bufh, 0, #contents, false, contents)
    vim.api.nvim_buf_set_option(Harpoon_dirlist_bufh, "filetype", "harpoon")
    vim.api.nvim_buf_set_option(Harpoon_dirlist_bufh, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(Harpoon_dirlist_bufh, "bufhidden", "delete")

    vim.api.nvim_buf_set_keymap(
        Harpoon_dirlist_bufh,
        "n",
        "q",
        "<Cmd>lua require('harpoon.dirlist').toggle_quick_list()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        Harpoon_dirlist_bufh,
        "n",
        "<ESC>",
        "<Cmd>lua require('harpoon.dirlist').toggle_quick_list()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        Harpoon_dirlist_bufh,
        "n",
        "<CR>",
        "<Cmd>lua require('harpoon.dirlist').select_menu_item()<CR>",
        {}
    )
    vim.cmd(
        string.format(
            "autocmd BufWriteCmd <buffer=%s> lua require('harpoon.dirlist').on_menu_save()",
            Harpoon_dirlist_bufh
        )
    )
    if global_config.save_on_change then
        vim.cmd(
            string.format(
                "autocmd TextChanged,TextChangedI <buffer=%s> lua require('harpoon.dirlist').on_menu_save()",
                Harpoon_dirlist_bufh
            )
        )
    end
    vim.cmd(
        string.format(
            "autocmd BufModifiedSet <buffer=%s> set nomodified",
            Harpoon_dirlist_bufh
        )
    )
    vim.cmd(
        "autocmd BufLeave <buffer> ++nested ++once silent lua require('harpoon.dirlist').toggle_quick_list()"
    )
end

function M.select_menu_item()
    local idx = vim.fn.line(".")
    close_menu(true)
    local dir = harpoon.get_global_settings().dir_list[idx]
    if dir then
        vim.cmd("cd " .. dir)
        print("Changed directory to: " .. dir)
    end
end

function M.on_menu_save()
    log.trace("on_menu_save()")
    local dir_list = get_menu_items()
    harpoon.get_global_settings().dir_list = dir_list
    harpoon.save()
end

return M
