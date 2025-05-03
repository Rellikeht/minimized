-- helpers {{{

ALL_MODES = {"t", "n", "v", "o", "i"}

--  }}}

-- settings {{{

-- general options {{{

for _, option in pairs({
    "expandtab",
    "number",
    "relativenumber",
    "ruler",
    "hlsearch",
    "incsearch",
    "ignorecase",
    "smartcase",
    "showmatch",
    "cursorline",
    "hidden",
    "secure",
    "wrap", -- TODO ??
    "autoindent",
    "cindent",
    "smarttab",
    "wildmenu",
    "termguicolors",
    "ttimeout",
    "splitright",
    "splitbelow",
    "autochdir",
}) do
    vim.opt[option] = true
end

for _, option in pairs({
    "shelltemp",
    "timeout",
    "autoread",
}) do
    vim.opt[option] = false
end

vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.shellxquote = ""
vim.opt.maxmempattern = 2000000
vim.opt.fileencoding = "utf8"
vim.opt.ttimeoutlen = 100
vim.opt.updatetime = 2000

vim.opt.foldmethod = "marker"
vim.opt.foldmarker = " {{{, }}}"
vim.opt.foldlevel = 0
vim.opt.showbreak = "\\> "
vim.opt.wrapmargin = 1

vim.opt.mouse = "a"
vim.opt.scrolloff = 5
vim.opt.splitkeep = "screen"
vim.opt.shortmess = "atsOF"

vim.opt.undolevels = 10000
vim.opt.history = 10000

vim.opt.formatoptions:remove({"j", "t"})
vim.opt.formatoptions:append("croqlwn")

vim.opt.wildchar = string.byte("\t")
vim.opt.wildmode = "list:longest,full"
vim.opt.wildoptions = "fuzzy,tagfile,pum"
vim.opt.complete = "w,b,s,i,d,t,.,k"
vim.opt.completeopt = "menu,menuone,noselect,noinsert,preview"

vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.pumwidth = 30
-- vim.opt.pumheight = 0
vim.opt.cmdwinheight = 25

-- }}}

-- initialization {{{

vim.cmd.filetype("on")
vim.cmd.syntax("on")
vim.cmd.filetype("plugin", "on")
vim.cmd.filetype("indent", "on")
vim.cmd.runtime("ftplugin/man.vim")
vim.g.loaded_matchit = 1

-- }}}

if vim.fn.has("win32") == 1 then-- {{{

    -- must have really
    vim.opt.shell = "powershell.exe"

    -- some nice options
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    vim.opt.shellquote = ""
    vim.opt.shellpipe = "| Out-File -Encoding UTF8 %s"
    vim.opt.shellredir = "| Out-File -Encoding UTF8 %s"

    local git_executable = "git.exe"

    -- }}}
else -- {{{
    -- no idea what to put here
    -- vim.opt.shell = "bash"
    local git_executable = "git"

end -- }}}

if vim.g.neovide then -- {{{

end -- }}}

-- colors {{{

vim.cmd.colorscheme("zaibatsu") --elflord

-- diff is weird without that
vim.cmd[[
hi CursorLine ctermbg=237 guibg=#4a4a4a cterm=none gui=none
hi CursorLineNr ctermbg=237 guibg=#404040 cterm=none gui=none

hi DiffAdd
            \ ctermbg=DarkGreen guibg=#0d5826
            \ ctermfg=NONE guifg=NONE
hi DiffText
            \ ctermbg=Gray guibg=#566670
            \ ctermfg=NONE guifg=NONE
hi DiffChange
            \ ctermbg=DarkBlue guibg=#0f1a7f
            \ ctermfg=NONE guifg=NONE
hi DiffDelete
            \ ctermbg=DarkRed guibg=#800620
            \ ctermfg=NONE guifg=NONE
]]

-- }}}

-- }}}

-- keybindings {{{

-- general {{{

vim.api.nvim_set_keymap("n", ",", "<Nop>", {})
vim.api.nvim_set_keymap("n", ";", "<Nop>", {})
vim.g.mapleader = ","
-- TODO which key
vim.g.maplocalleader = "\\"

-- Select whole buffer without plugins
vim.api.nvim_set_keymap("v", "aee", "gg0oG$", {noremap=true})
vim.api.nvim_set_keymap("v", "iee", "aee", {noremap=true})
vim.api.nvim_set_keymap("n", "yaee ", "gg0vG$y`'", {noremap=true})

vim.api.nvim_set_keymap('', '<C-h>', '<C-]>', {})
vim.api.nvim_set_keymap(
    "n",
    "<C-w><C-h>",
    ":<C-u>exe 'tab tag '.expand('<cword>')<CR>",
    {noremap=true}
)
vim.api.nvim_set_keymap("n", "<C-w>gf", ":<C-u>tabedit <cfile><CR>", {})
vim.api.nvim_set_keymap("s", "<BS>", "<BS>i", {noremap=true})

-- TODO copying

-- }}}

-- terminal {{{

vim.api.nvim_set_keymap("t", "<C-_>", "<C-\\>", {noremap=true})
vim.api.nvim_set_keymap("t", "<C-\\>n", "<C-\\><C-n>", {noremap=true})
vim.api.nvim_set_keymap("t", "<C-\\>o", "<C-\\><C-o>", {noremap=true})

for key_in, key_out in pairs({
    ["h"] = "<C-w>h",
    ["j"] = "<C-w>j",
    ["k"] = "<C-w>k",
    ["l"] = "<C-w>l",
    ["gt"] = "gt",
    ["gT"] = "gT",
}) do
    vim.api.nvim_set_keymap(
        "t",
        "<C-\\>"..key_in,
        "<C-\\><C-n>"..key_out.."<Esc>",
        {noremap=true}
    )
end

-- TODO is it better to have vim slime or some manual copying

-- }}}

-- tabs {{{

vim.api.nvim_set_keymap("n", "<Tab>", "<Nop>", {noremap=true})
vim.api.nvim_set_keymap("n", "<C-j>", "<Tab>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Tab><Tab>", ":<C-u>tab<Space>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Tab><S-Tab>", ":<C-u>-tab<Space>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Tab>h", ":<C-u>tab help<Space>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Tab>H", ":<C-u>-tab help<Space>", {noremap=true})

-- }}}

-- }}}

-- plugins {{{

-- pre setup {{{

-- sneak & quickscope {{{

vim.g["sneak#prompt"] = " <sneak> "
vim.g["sneak#use_ic_scs"] = true
vim.g["sneak#label"] = true
vim.g["sneak#next"] = false

--  }}}

--  }}}

-- pckr setup {{{

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system({
      git_executable,
      "clone",
      "--filter=blob:none",
      "https://github.com/lewis6991/pckr.nvim",
      pckr_path
    })
  end
  vim.opt.rtp:prepend(pckr_path)
end
bootstrap_pckr()

local pckr = require("pckr")
local pckr_util = require("pckr.util")
local pckr_cmd = require("pckr.loader.cmd")
local pckr_keys = require("pckr.loader.keys")

pckr.setup({
    pack_dir = pckr_util.join_paths(vim.fn.stdpath("data"), "site"),
    -- Limit the number of simultaneous jobs. nil means no limit
    max_jobs = nil,
    autoremove = true,
    autoinstall = true,
    git = {
        cmd = "git",
        clone_timeout = 60,
        -- Lua format string used for "aaa/bbb" style plugins
        default_url_format = "https://github.com/%s"
    },
    log = { level = "warn" },
    lockfile = {
        path = pckr_util.join_paths(vim.fn.stdpath("config"), "pckr", "lockfile.lua")
    }
})

--  }}}

pckr.add({ -- {{{
    "mbbill/undotree",
    "justinmk/vim-sneak",
    "unblevable/quick-scope",
    "tpope/vim-surround",
    "tpope/vim-tbone",
    "tpope/vim-abolish",
    "tpope/vim-endwise",
    "tpope/vim-fugitive",
    "ryvnf/readline.vim",
    "andymass/vim-matchup",

    { 'nvim-treesitter/nvim-treesitter', --  {{{
        run = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                },

                matchup = { enable = true },
            }
        end
    },--  }}}

    { "RRethy/nvim-treesitter-endwise", --  {{{
        require = { "nvim-treesitter/nvim-treesitter" },
    }, --  }}}

    { "windwp/nvim-autopairs", -- {{{
        config = function()
            require("nvim-autopairs").setup({
                disable_filetype = {
                    "markdown",
                    "text",
                    "fzf",
                    "fugitive",
                },
                disable_in_macro = true,
                disable_in_visualblock = false,
                disable_in_replace_mode = true,
            })
        end,
    },--  }}}

    -- rainbow ?
}) -- }}}

-- post setup {{{
-- TODO

-- sneak & quickscope {{{

for key_in, key_out in pairs({
    ["<C-n>"] = ";",
    ["<C-p>"] = ",",
    ["s"] = "s",
    ["S"] = "S",
    ["f"] = "f",
    ["F"] = "F",
    ["t"] = "t",
    ["T"] = "T",
}) do
    vim.api.nvim_set_keymap("", key_in, "<Plug>Sneak_"..key_out, {noremap=true})
end

--  }}}

-- undotree {{{

-- }}}

-- }}}

-- }}}

-- plugin settings {{{

-- todo in function slime config for nvim terminal
-- and tmux, selection inside if below

--  }}}

if vim.g.neovide then -- {{{

    -- settings {{{

    vim.g.neovide_refresh_rate_idle = 5
    vim.g.neovide_cursor_hack = false
    vim.g.neovide_scale_factor = 0.95

    --  }}}

    -- keybindings {{{

    -- for uniform experience
    for _, mode in pairs(ALL_MODES) do
        vim.api.nvim_set_keymap(mode, "<C-/>", "<C-_>", {noremap=true})
    end

    --  }}}

    -- }}}
else -- {{{

    -- keybindings {{{

    --  }}}

end -- }}}
