-- helpers {{{

-- general {{{

local function calc_pumheight()
  local result = vim.opt.lines._value
  result = (result - result % 3) / 3
  return result
end

function Qflcmd(cmd)
  local prefix = "c"
  if vim.g.qfloc == 1 then
    prefix = "l"
  end
  return function(...)
    vim.cmd[prefix .. cmd](...)
  end
end

local function table_join(t1, t2)
  for k, v in pairs(t2) do
    table.insert(t1, k, v)
  end
end

--  }}}

--  }}}

-- settings {{{

-- general options {{{

for _, option in pairs({
  "ruler",
  "incsearch",
  "ignorecase",
  "smartcase",
  "showmatch",
  "hidden",
  "secure",
  "wrap",
  "autoindent",
  "cindent",
  "wildmenu",
  "termguicolors",
  "ttimeout",
  "splitright",
  "splitbelow",
  "autochdir",
  "undofile",
}) do vim.opt[option] = true end

for _, option in pairs({
  "shelltemp",
  "timeout",
  "autoread",
  "swapfile",
  "hlsearch",
}) do
  vim.opt[option] = false
end

vim.opt.scrolloff = 5
vim.opt.splitkeep = "screen"
vim.opt.shortmess = "atsOF"
vim.opt.mouse = "a"

vim.opt.formatoptions:remove({ "j", "t" })
vim.opt.formatoptions:append("croqlwn")

vim.opt.wildchar = string.byte("\t")
vim.opt.wildmode = "list:longest,full"
vim.opt.wildoptions = "fuzzy,tagfile" -- ??
vim.opt.complete = "w,b,s,i,d,.,k"
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.completeopt:append("fuzzy")
end

vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.pumwidth = 20
vim.opt.pumheight = calc_pumheight()
vim.opt.cmdwinheight = 25

-- }}}

-- initialization {{{

vim.g.loaded_matchit = 1

-- }}}

if vim.fn.has("win32") == 1 then -- {{{
  -- must have really
  vim.opt.shell = "powershell.exe"

  -- some nice options
  vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
  vim.opt.shellquote = ""
  vim.opt.shellpipe = "| Out-File -Encoding UTF8 %s"
  vim.opt.shellredir = "| Out-File -Encoding UTF8 %s"

  GIT_EXECUTABLE = "git.exe"

  -- }}}
else -- {{{
  GIT_EXECUTABLE = "git"
end  -- }}}

-- colors {{{

-- isn't available sometimes
local success = pcall(vim.cmd.colorscheme, "zaibatsu")
if not success then pcall(vim.cmd.colorscheme, "retrobox") end

-- vim.api.nvim_set_hl(0, "Todo", {fg="#ffcf2f", bg="#0e1224", bold=true})

-- simple yet effective
vim.api.nvim_set_hl(0, "NormalFloat", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { bold = true })

-- acceptable for now
vim.api.nvim_set_hl(0, "Pmenu", { link = "CursorColumn" })
vim.api.nvim_set_hl(0, "PmenuKind", { link = "SignColumn" })
vim.api.nvim_set_hl(0, "PmenuExtra", { link = "SignColumn" })

-- }}}

-- }}}

-- keybindings {{{

-- general {{{

-- search like a pro
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })

-- move lines in visual mode
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

-- just in case
vim.keymap.set("n", "<Space>", "<Nop>", {})
vim.keymap.set("n", ",", "<Nop>", { remap = true })
vim.keymap.set("n", ";", "<Nop>", { remap = true })

vim.g.mapleader = ","
vim.g.maplocalleader = "_"

-- Select whole buffer without plugins
vim.keymap.set("v", "aee", "gg0oG$", { noremap = true })
vim.keymap.set("v", "iee", "aee", { noremap = true })
vim.keymap.set(
  "n", "yaee ", "gg0vG$y`'", { noremap = true }
)

vim.keymap.set("n", "Q", "<Nop>", { remap = true })
vim.keymap.set("", "<C-h>", "<C-]>", { remap = true })
vim.keymap.set("s", "<BS>", "<BS>i", { noremap = true })

vim.keymap.set("n", "<Space>y", "\"+y", { noremap = true })
vim.keymap.set("n", "<Space>Y", "\"+Y", { noremap = true })
vim.keymap.set("n", "<Space>u", "\"+p", { noremap = true })
vim.keymap.set("n", "<Space>U", "\"+P", { noremap = true })

-- }}}

-- settings {{{

for key, cmd in pairs({
  h = ":<C-u>set hls!<CR>",
  w = ":<C-u>setlocal wrap!<CR>",
  W = ":<C-u>set wrap!<CR>",
}) do
  vim.keymap.set(
    "n", "<Space>q" .. key, cmd, {}
  )
end

--  }}}

-- }}}

-- common plugins {{{

-- pckr setup {{{

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system({
      GIT_EXECUTABLE,
      "clone",
      "--filter=blob:none",
      "https://github.com/lewis6991/pckr.nvim",
      pckr_path,
    })
  end
  vim.opt.rtp:prepend(pckr_path)
end
bootstrap_pckr()

PCKR = require("pckr")
PCKR_UTIL = require("pckr.util")
PCKR_CMD = require("pckr.loader.cmd")
PCKR_KEYS = require("pckr.loader.keys")

PCKR.setup({
  pack_dir = PCKR_UTIL.join_paths(
    vim.fn.stdpath("data"), "site"
  ),
  -- Limit the number of simultaneous jobs. nil means no limit
  max_jobs = nil,
  autoremove = true,
  autoinstall = true,
  git = {
    cmd = "git",
    clone_timeout = 60,
    -- Lua format string used for "aaa/bbb" style plugins
    default_url_format = "https://github.com/%s",
  },
  log = { level = "warn" },
  lockfile = {
    path = PCKR_UTIL.join_paths(
      vim.fn.stdpath("config"), "pckr", "lockfile.lua"
    ),
  },
}
)

--  }}}

local plugin_configs = { -- {{{
  "tpope/vim-tbone",
  "tpope/vim-abolish",
  "tpope/vim-eunuch",
  "wellle/targets.vim",

  {
    "justinmk/vim-sneak",   --  {{{

    config_pre = function() --  {{{
      vim.g["sneak#prompt"] = " <sneak> "
      vim.g["sneak#use_ic_scs"] = true
      vim.g["sneak#label"] = true
      vim.g["sneak#next"] = false
    end,                --  }}}

    config = function() --  {{{
      for key_in, key_out in pairs({
        ["<C-n>"] = ";",
        ["<C-p>"] = ",",
        s = "s",
        S = "S",
        f = "f",
        F = "F",
        t = "t",
        T = "T",
      }) do
        vim.keymap.set(
          "", key_in, "<Plug>Sneak_" .. key_out, { noremap = true }
        )
      end
    end --  }}}
  },    --  }}}

  {
    "tpope/vim-surround", --  {{{
    config = function()
      vim.keymap.set("x", "<Space>a", "<Plug>VSurround", {})
      vim.keymap.set("x", "<Space>A", "<Plug>VgSurround", {})
    end
  }, --  }}}

  {
    "tpope/vim-repeat", --  {{{
    config = function()
      -- because RepeatDot sometimes fails
      vim.keymap.set("n", "<Space>.", ".", { noremap = true })
    end
  }, --  }}}
}    -- }}}

--  }}}

if vim.g.vscode then
  --  {{{

  VSCODE = require("vscode")
  vim.keymap.set("x", "gc", function()
    VSCODE.call("editor.action.commentLine")
    VSCODE.call("vscode-neovim.escape", { key = "v" })
  end)
  vim.keymap.set({ "n", "x" }, "+", function()
    VSCODE.call("workbench.action.editor.nextChange")
  end)
  vim.keymap.set({ "n", "x" }, "-", function()
    VSCODE.call("workbench.action.editor.previousChange")
  end)

  -- vscode needs it like that
  vim.keymap.set({ "n", "x" }, "<Leader>gs", function()
    VSCODE.call("git.stageSelectedRanges")
  end)
  vim.keymap.set({ "n", "x" }, "<Leader>gr", function()
    VSCODE.call("git.revertSelectedRanges")
  end)
  vim.keymap.set("n", "<Leader>gn", function()
    VSCODE.call("editor.action.dirtydiff.next")
  end)
  vim.keymap.set("n", "<Leader>gp", function()
    VSCODE.call("editor.action.dirtydiff.previous")
  end)

  -- this is broken
  vim.keymap.set("x", "<Leader>gu", function()
    VSCODE.call("git.unstageSelectedRanges")
  end)
  vim.keymap.set("n", "<Leader>gu", function()
    VSCODE.call("git.unstageChange")
  end)

  vim.keymap.set("n", "<Leader>sf", function()
    VSCODE.call("workbench.action.quickOpen")
  end)
  vim.keymap.set("n", "<Leader>sc", function()
    VSCODE.call("workbench.action.showCommands")
  end)
  vim.keymap.set("n", "<Leader>ss", function()
    VSCODE.call("workbench.action.findInFiles")
  end)

  vim.keymap.set("n", "<Leader>dn", function()
    VSCODE.call("editor.action.marker.next")
  end)
  vim.keymap.set("n", "<Leader>dp", function()
    VSCODE.call("editor.action.marker.prev")
  end)
  vim.keymap.set("n", "<Leader>Dn", function()
    VSCODE.call("editor.action.marker.nextInFiles")
  end)
  vim.keymap.set("n", "<Leader>Dp", function()
    VSCODE.call("editor.action.marker.prevInFiles")
  end)

  vim.keymap.set("n", "<Leader>dd", function()
    VSCODE.call("editor.action.revealDefinition")
  end)
  vim.keymap.set("n", "<Leader>dD", function()
    VSCODE.call("editor.action.revealDeclaration")
  end)
  vim.keymap.set("n", "<Leader>dlr", function()
    VSCODE.call("editor.action.goToReferences")
  end)
  vim.keymap.set("n", "<Leader>di", function()
    VSCODE.call("editor.action.peekImplementation")
  end)

  vim.keymap.set("n", "<Leader>dr", function()
    VSCODE.call("editor.action.rename")
  end)
  vim.keymap.set("n", "<Leader>da", function()
    VSCODE.call("editor.action.quickFix")
  end)
  vim.keymap.set("n", "<Leader>dh", function()
    VSCODE.call("editor.action.showHover")
  end)
  vim.keymap.set("n", "<Leader>de", function()
    VSCODE.call("editor.action.showHover")
  end)

  PCKR.add(plugin_configs)
  return
  -- }}}
end

table_join(
  plugin_configs,
  { --  {{{
    "Rellikeht/lazy-utils",
    "ryvnf/readline.vim",

    {
      "kmonad/kmonad-vim", --  {{{
      -- why doesn't this happen automatically
      config = function()
        vim.api.nvim_create_autocmd(
          { "BufRead", "BufNewFile" }, {
            pattern = "*.kbd",
            callback = function()
              vim.o.filetype = "kbd"
            end
          }
        )
      end
    }, --  }}}

    {
      "Rellikeht/vim-extras", --  {{{
      config = function()
        vim.keymap.set("n", "<Tab>o", ":+0TabOpen<Space>", {})
        EXTRAS = require("extras")
      end
    }, --  }}}

    {
      "Rellikeht/arglist-plus", --  {{{
      config_pre = function()
      end,
      config = function()
        vim.keymap.set("n", "<Space>n", "<Plug>ANext", {})
        vim.keymap.set("n", "<Space>p", "<Plug>APrev", {})
        vim.keymap.set("n", "<Space>o", ":AEdit<Space>", {})
        vim.keymap.set("n", "<Space>O", ":AEditBuf<Space>", {})
        vim.keymap.set("n", "<Space>e", ":<C-u>AGo<Space>", {})
        vim.keymap.set("n", "<Space>E", ":<C-u>AGo!<Space>", {})
        vim.keymap.set("n", "<Space>j", ":ASelect<CR>", {})
        vim.keymap.set("n", "<Space>J", ":ASelect!<CR>", {})
        vim.keymap.set("n", "<Space>ll", "<Plug>AList", {})
        vim.keymap.set("n", "<Space>lL", "<Plug>AVertList", {})
        vim.keymap.set("n", "<Space>la", ":AAdd<Space>", {})
        vim.keymap.set("n", "<Space>la", ":AAddBuf<Space>", {})
        vim.keymap.set("n", "<Space>lr", ":AReplace<Space>", {})
        vim.keymap.set("n", "<Space>lR", ":AReplaceBuf<Space>", {})
        vim.keymap.set("n", "<Space>lm", ":AMoveCurN<CR>", {})
        vim.keymap.set("n", "<Space>lM", ":<C-u>AMoveCur<Space>", {})
        vim.keymap.set("n", "<Space>lc", "<Plug>AGlobToLoc", {})

        vim.keymap.set("n", "<Space>ld", ":<C-u>ADelN<CR>", {})
        vim.keymap.set("n", "<Space>lD", ":<C-u>ADel<CR>", {})
        vim.keymap.set("n", "<Space>lq", ":<C-u>ABufDelN<Space>", {})
        vim.keymap.set("n", "<Space>lQ", ":<C-u>ABufWipeN<Space>", {})

        vim.keymap.set("n", "<Space>lu", function()
          vim.cmd.AEdit(vim.fn.expand("<cfile>"))
        end, {})
        vim.keymap.set("n", "<Space>lU", function()
          vim.cmd.AAdd(vim.fn.expand("<cfile>"))
        end, {})
      end
    }, --  }}}

    {
      "andymass/vim-matchup", --  {{{
      config_pre = function()
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
        vim.g.matchup_surround_enabled = true
        vim.g.matchup_delim_noskips = false
        vim.g.matchup_delim_stopline = 100000
        vim.g.matchup_motion_cursor_end = true
      end,
    }, --  }}}

    {
      "tpope/vim-fugitive", --  {{{
      config = function()
        vim.keymap.set("n", "<Leader>G", ":<C-u>G<CR>", {})
        vim.keymap.set("n", "<Leader>g<Space>", ":<C-u>G<Space>", {})
      end
    }, --  }}}

    {
      "mbbill/undotree", --  {{{
      config = function()
      end
    }, --  }}}

    {
      "windwp/nvim-autopairs", -- {{{
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
    }, --  }}}

    {
      "nvim-treesitter/nvim-treesitter", --  {{{
      requires = { "Rellikeht/lazy-utils" },
      run = ":TSUpdate",
      config = function()
        require("nvim-treesitter.install").prefer_git = false
        require("lazy_utils").load_on_startup(
          function()
            require "nvim-treesitter.configs".setup({
              highlight = { enable = true },
              indent = { enable = true },
              incremental_selection = { enable = true },
              sync_install = false,
              auto_install = false,

              matchup = {
                enable = true,
                disable_virtual_text = true,
                include_match_words = true,
              },
            })
          end
        )
      end,
    }, --  }}}

    {
      "junegunn/fzf.vim", --  {{{
      requires = {
        "junegunn/fzf",
        "Rellikeht/vim-extras",
      },
      config = function()
        vim.g.fzf_layout = { down = "100%" }
        vim.g.fzf_vim = { preview_window = { "down,50%,border-none" } }
        vim.g.fzf_history_dir = vim.fn.stdpath("data") .. "/fzf-history"

        vim.g.fzf_colors = {
          fg = { "fg", "Normal" },
          bg = { "bg", "Normal" },
          hl = { "fg", "Comment" },
          ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
          ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
          ["hl+"] = { "fg", "Statement" },
          info = { "fg", "PreProc" },
          prompt = { "fg", "Conditional" },
          pointer = { "fg", "Exception" },
          marker = { "fg", "Keyword" },
          spinner = { "fg", "Label" },
          header = { "fg", "Comment" },
        }

        vim.g.fzf_action = {
          ["alt-t"] = function(files)
            vim.cmd.TabOpen("+0")
            vim.fn["aplus#define"](EXTRAS.map(vim.fn.fnameescape, files))
            vim.fn["aplus#select"](0)
          end,
          ["alt-T"] = function(files)
            for _, file in pairs(EXTRAS.map(vim.fn.fnameescape, files)) do
              vim.cmd.tabedit(file)
            end
          end,
          ["alt-v"] = function(files)
            vim.cmd.view(EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-l"] = function(files)
            vim.fn["aplus#define"](EXTRAS.map(vim.fn.fnameescape, files))
            vim.fn["aplus#select"](0)
          end,
          ["alt-L"] = function(files)
            vim.fn["aplus#define"](EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-e"] = function(files)
            vim.fn["aplus#edit"]("$", 0, EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-E"] = function(files)
            vim.fn["aplus#edit"]("", 0, EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-a"] = function(files)
            vim.fn["aplus#add"]("$", EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-A"] = function(files)
            vim.fn["aplus#add"]("", EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-b"] = function(files)
            vim.cmd.BAdd(EXTRAS.map(vim.fn.fnameescape, files))
          end,
        }

        vim.keymap.set("n", "<Leader>sc", ":<C-u>Files<Space>")
        vim.keymap.set("n", "<Leader>sb", ":<C-u>Buffers<CR>")
        vim.keymap.set("n", "<Leader>sl", ":<C-u>BLines<CR>")
        vim.keymap.set("n", "<Leader>sL", ":<C-u>Lines<CR>")
        vim.keymap.set("n", "<Leader>s?", ":<C-u>HelpTags<CR>")

        -- TODO project roots

        -- because those are nice and this config should be as
        -- self contained as it is possible
        vim.env.FZF_DEFAULT_OPTS = [[
--border=none
--bind 'alt-k:preview-up,alt-j:preview-down'
--bind 'ctrl-k:kill-line,ctrl-j:ignore'
--bind 'ctrl-s:change-preview-window(hidden|)'
--bind 'alt-K:preview-half-page-up,alt-J:preview-half-page-down'
--bind 'alt-U:half-page-up,alt-D:half-page-down'
--bind 'ctrl-c:cancel,ctrl-g:clear-selection'
--bind 'alt-p:prev-history,alt-n:next-history'
--bind 'alt-P:prev-selected,alt-N:next-selected'
--bind 'ctrl-p:up,ctrl-n:down'
--bind 'ctrl-t:toggle'
]]
      end
    }, --  }}}

    {
      "Rellikeht/fzf-vim-additional", --  {{{
      requires = {
        "junegunn/fzf",
        "junegunn/fzf.vim"
      },
      config = function()
        vim.keymap.set("n", "<Leader>sg", ":<C-u>Dgrep<Space>")
        vim.keymap.set("n", "<Leader>sG", ":<C-u>Digrep<Space>")
        vim.keymap.set("n", "<Leader>sr", ":<C-u>Drg<Space>")
        vim.keymap.set("n", "<Leader>sR", ":<C-u>Dru<Space>")
        vim.keymap.set("n", "<Leader>sa", ":<C-u>Dag<Space>")
        vim.keymap.set("n", "<Leader>sA", ":<C-u>Dau<Space>")
      end
    } --  }}}

  }
) --  }}}

PCKR.add(plugin_configs)

-- settings {{{

vim.cmd.filetype("on")
vim.cmd.filetype("plugin", "on")
vim.cmd.filetype("indent", "on")
vim.cmd.syntax("on")

-- filetypes {{{

vim.g.markdown_minlines = 500

vim.api.nvim_create_autocmd(
  { "BufRead", "BufNewFile" },
  { pattern = "*.md", command = "set syntax=markdown" }
)

--  }}}

--  }}}

-- keybindings {{{

-- tabs {{{

vim.keymap.set(
  "n", "<C-w><C-h>",
  ":<C-u>exe 'tab tag '.expand('<cword>')<CR>", {}
)

vim.keymap.set("n", "<Tab>", "<Nop>", { noremap = true })
vim.keymap.set("n", "<C-j>", "<Tab>", { noremap = true })
vim.keymap.set(
  "n", "<Tab><Tab>", ":<C-u>tab<Space>", {}
)
vim.keymap.set(
  "n", "<Tab><S-Tab>", ":<C-u>-tab<Space>", {}
)
vim.keymap.set(
  "n", "<Tab>h", ":<C-u>tab help<Space>", {}
)
vim.keymap.set(
  "n", "<Tab>H", ":<C-u>-tab help<Space>", {}
)

-- }}}

-- info {{{

for key, cmd in pairs({
  m = ":<C-u>marks<CR>",
  b = ":<C-u>ls<CR>",
}) do
  vim.keymap.set(
    "n", "<Space>i" .. key, cmd, {}
  )
end

--  }}}

--  }}}

-- other settings {{{

vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.textwidth = 72

vim.opt.shellxquote = ""
vim.opt.maxmempattern = 2000000
vim.opt.fileencoding = "utf8"
vim.opt.ttimeoutlen = 100
vim.opt.updatetime = 2000

vim.opt.conceallevel = 2
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = " {{{, }}}"
vim.opt.foldlevel = 0
vim.opt.showbreak = "\\> "
vim.opt.wrapmargin = 1

vim.opt.undolevels = 10000
vim.opt.history = 10000

for _, option in pairs({
  "number",
  "relativenumber",
  "cursorline",
  "expandtab",
  "smarttab",
}) do vim.opt[option] = true end

vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { remap = true })
vim.keymap.set("t", "<C-q><C-w>", "<C-w>", { noremap = true })
vim.keymap.set("t", "<C-q><C-q>", "<C-q>", { noremap = true })
vim.keymap.set(
  "t", "<C-q><C-n>", "<C-\\><C-n>", { noremap = true }
)
vim.keymap.set(
  "t", "<C-q><C-o>", "<C-\\><C-o>", { noremap = true }
)

vim.cmd [[
" Those helped
hi Added
            \ ctermbg=DarkGreen guibg=#0d5826
            \ ctermfg=NONE guifg=NONE
hi Removed
            \ ctermbg=DarkRed guibg=#800620
            \ ctermfg=NONE guifg=NONE

" TODO fix coloring in diff split
" those don't work
"hi DiffText
"            \ ctermbg=Gray guibg=#566670
"            \ ctermfg=NONE guifg=NONE
hi Changed
            \ ctermbg=DarkBlue guibg=#0f1a7f
            \ ctermfg=NONE guifg=NONE
]]

vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = "netrw",
    callback = function()
      vim.keymap.set("n", "<Space>lu", function()
        vim.cmd.AEdit(vim.g["extras#get_netrw_fp"]())
      end, { buffer = true, silent = true })
      vim.keymap.set("n", "<Space>lU", function()
        vim.cmd.AAdd(vim.g["extras#get_netrw_fp"]())
      end, { buffer = true, silent = true })
    end
  }
)

-- }}}

-- filetypes {{{

-- ugly but handy
vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = { --  {{{
      "python",
      "lua",
      "vim",
      "zig",
      "markdown",
      "ocaml",
      "elixir",
      "haskell",
      "kbd",
    }, --  }}}
    callback = function()
      vim.bo.softtabstop = 2
      vim.bo.shiftwidth = 2
    end
  }
)

--  }}}

-- quickfix {{{

vim.g.qfloc = 1

vim.keymap.set("n", ";t", function()
  vim.g.qfloc = (vim.g.qfloc + 1) % 2
  if vim.g.qfloc == 1 then
    vim.cmd.echo("\"Using location list (local)\"")
  else
    vim.cmd.echo("\"Using quickfix list (global)\"")
  end
end, { noremap = true })

for key, map in pairs({
  [";n"] = vim.g["extras#count_on_function"](Qflcmd("next")),
  [";p"] = vim.g["extras#count_on_function"](Qflcmd("previous")),
  [";0"] = Qflcmd("first"),
  [";$"] = Qflcmd("last"),
  [";l"] = Qflcmd("history"),
  [";w"] = function()
    local height = vim.v.count
    if height == 0 then height = 10 end
    Qflcmd("open")({ count = height })
  end,
}) do
  vim.keymap.set("n", key, map, { noremap = true, silent = true })
end

vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = "qf",
    callback = function()
      vim.keymap.set(
        { "n", "v" }, "q", ":q<CR>", { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", "<", Qflcmd("older"), { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", ">", Qflcmd("newer"), { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", "J", "j<CR>", { noremap = true, buffer = true, silent = true }
      )
      vim.keymap.set(
        "n", "K", "k<CR>", { noremap = true, buffer = true, silent = true }
      )

      vim.keymap.set(
        "n", "<CR>", "<CR>zv", {
          noremap = true, buffer = true, silent = true,
        }
      )
      vim.keymap.set(
        "n", "<C-h>", function()
          local qpos = vim.fn.getcurpos()
          vim.cmd.execute("\"normal \\<CR>\"")
          Qflcmd("open")()
          vim.fn.setpos(".", qpos)
        end, {
          buffer = true,
        }
      )
      vim.keymap.set(
        "n", "<BS>", function()
          vim.cmd.execute("\"normal \\<CR>\"")
          Qflcmd("close")()
        end, {
          buffer = true, silent = true,
        }
      )
    end
  }
)

--  }}}

if vim.g.neovide then
  -- {{{

  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_cursor_hack = false
  vim.g.neovide_scale_factor = 0.95

  vim.keymap.set("n", "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { noremap = true })
  vim.keymap.set("n", "<C-w>u", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { noremap = true })

  -- }}}
elseif vim.fn.has("gui_running") == 1 then
  -- {{{
  -- }}}
else
  -- {{{
end -- }}}

-- additional {{{

pcall(require, "local")

-- Special Code command as part of config
vim.api.nvim_create_user_command(
  "Code", function()
    require("code")
  end, { nargs = 0 }
)

-- For easier sourcing of additional stuff
vim.api.nvim_create_user_command(
  "SoAdd", function(opts)
    require(opts.fargs[1])
  end, { nargs = 1 }
)

--  }}}
