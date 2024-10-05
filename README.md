# Harpoon-to-dir
Harpoon is a neovim plugin, which facilitates blazingly fast navigation, and it is project specific, to make it more blazingly fast I made it possible to move from one dir to anotherusing harpoon.
Just add the file dirlist.lua file (from the repo) to `path/to/harpoon/lua/` in my case it is `~/.local/share/nvim/lazy/harpoon/lua`

Now you can use this funcion to toggle the quick menu
```lua
require('harpoon.dirlist').toggle_quick_list()
```
**For example **
```lua
        vim.keymap.set('n', '<leader>hh', function () require('harpoon.dirlist').toggle_quick_list() end, { desc = "Toggle Harpoon-to-dir menu" })
```

**This is my harpoon.lua config file (Lazy)**
```lua
return{
    "ThePrimeagen/harpoon",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        vim.keymap.set("n", "<leader>h", function() require("harpoon.mark").add_file() end, { desc = "Add file to harpoon" })
        vim.keymap.set("n", "<leader>H", function() require("harpoon.ui").toggle_quick_menu() end, { desc = "Toggle harpoon quick menu" })
        vim.keymap.set("n", "<leader>cm", function() require("harpoon.cmd-ui").toggle_quick_menu() end, { desc = "Toggle harpoon cmd quick menu" })

        vim.keymap.set("n", "<leader>1", function() require("harpoon.ui").nav_file(1) end, { desc = "Go to harpoon mark 1" })
        vim.keymap.set("n", "<leader>2", function() require("harpoon.ui").nav_file(2) end, { desc = "Go to harpoon mark 2" })
        vim.keymap.set("n", "<leader>3", function() require("harpoon.ui").nav_file(3) end, { desc = "Go to harpoon mark 3" })
        vim.keymap.set("n", "<leader>4", function() require("harpoon.ui").nav_file(4) end, { desc = "Go to harpoon mark 4" })
        vim.keymap.set("n", "<leader>5", function() require("harpoon.ui").nav_file(5) end, { desc = "Go to harpoon mark 5" })

        vim.keymap.set("n", "<leader>!", function() require("harpoon.mark").set_current_at(1) end, { desc = "Add file to harpoon 1" })
        vim.keymap.set("n", "<leader>@", function() require("harpoon.mark").set_current_at(2) end, { desc = "Add file to harpoon 2" })
        vim.keymap.set("n", "<leader>#", function() require("harpoon.mark").set_current_at(3) end, { desc = "Add file to harpoon 3" })
        vim.keymap.set("n", "<leader>$", function() require("harpoon.mark").set_current_at(4) end, { desc = "Add file to harpoon 4" })
        vim.keymap.set("n", "<leader>%", function() require("harpoon.mark").set_current_at(5) end, { desc = "Add file to harpoon 5" })

        vim.keymap.set('n', '<leader>hh', function () require('harpoon.dirlist').toggle_quick_list() end, { noremap = true, silent = true })

    end,
}
```
