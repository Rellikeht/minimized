-- helpers {{{

-- general {{{

H = {
  table_join = function(t1, t2)
    for k, v in pairs(t2) do
      table.insert(t1, k, v)
    end
  end,

  lazy_ts_ensure_installed = function(name, filetypes)
    if filetypes == nil then filetypes = name end
    LAZY_UTILS.load_on_filetypes(
      filetypes, function()
        -- TODO make this fail silently when network not available
        vim.cmd.TSUpdate(name)
      end
    )
  end,

  calc_pumheight = function()
    local result = vim.opt.lines._value
    result = (result - result % 3) / 3
    return result
  end,

  qlcmd = function(cmd)
    local prefix = "c"
    if vim.g.qfloc == 1 then
      prefix = "l"
    end
    return function(...)
      vim.cmd[prefix .. cmd](...)
    end
  end,

  wrap_qfloc = function(cmd)
    return function(...)
      cmd(..., { loclist = vim.g.qfloc })
    end
  end,
}

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
vim.opt.pumheight = H.calc_pumheight()
vim.opt.cmdwinheight = 25
vim.opt.redrawtime = 5000

--  }}}

-- initialization {{{

vim.g.loaded_matchit = 1

--  }}}

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

  --  }}}
else -- {{{
  GIT_EXECUTABLE = "git"
end  --  }}}

-- colors {{{

-- isn't available sometimes
local success = pcall(vim.cmd.colorscheme, "zaibatsu")
if not success then pcall(vim.cmd.colorscheme, "retrobox") end

-- simple yet effective
vim.api.nvim_set_hl(0, "NormalFloat", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { bold = true })

-- acceptable for now
vim.api.nvim_set_hl(0, "Pmenu", { link = "CursorColumn" })
vim.api.nvim_set_hl(0, "PmenuKind", { link = "SignColumn" })
vim.api.nvim_set_hl(0, "PmenuExtra", { link = "SignColumn" })

--  }}}

--  }}}

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

--  }}}

-- settings {{{

for key, cmd in pairs({
  h = ":<C-u>set hls!<CR>",
  c = ":<C-u>set ignorecase!<CR>",
}) do
  vim.keymap.set(
    "n", "<Space>q" .. key, cmd, {}
  )
end

--  }}}

--  }}}

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

  {
    "Rellikeht/vim-extras", --  {{{
    config = function()
      if vim.g.vscode then
        return
      end
      vim.keymap.set("n", "<Tab>o", ":+0TabOpen<Space>", {})
      EXTRAS = require("extras")
    end
  }, --  }}}
}    --  }}}

--  }}}

if vim.g.vscode then
  --  {{{

  VSCODE = require("vscode")
  -- TODO make 'autochdir' work with vscode

  -- action binds {{{

  function VSCodeMap(name)
    return function()
      VSCODE.call(name)
    end
  end

  vim.keymap.set({ "n", "x" }, "+", VSCodeMap("workbench.action.editor.nextChange"))
  vim.keymap.set({ "n", "x" }, "-", VSCodeMap("workbench.action.editor.previousChange"))

  for key, cmd in pairs({
    gu = "git.unstageChange",
    gn = "editor.action.dirtydiff.next",
    gp = "editor.action.dirtydiff.previous",

    sc = "workbench.action.showCommands",
    sf = "workbench.action.quickOpen",

    dn = "editor.action.marker.next",
    dp = "editor.action.marker.prev",
    Dn = "editor.action.marker.nextInFiles",
    Dp = "editor.action.marker.prevInFiles",

    dd = "editor.action.revealDefinition",
    dD = "editor.action.revealDeclaration",
    dlr = "editor.action.goToReferences",
    di = "editor.action.peekImplementation",

    dr = "editor.action.rename",
    da = "editor.action.quickFix",
    dh = "editor.action.showHover",
    de = "editor.action.showHover",
  }) do
    vim.keymap.set("n", "<Leader>" .. key, VSCodeMap(cmd))
  end

  for key, cmd in pairs({
    -- vscode needs it like that
    gs = "git.stageSelectedRanges",
    gr = "git.revertSelectedRanges",

    ss = "workbench.action.findInFiles",

    -- TODO vertical scrolling and positioning
  }) do
    vim.keymap.set({ "n", "x" }, "<Leader>" .. key, VSCodeMap(cmd))
  end

  vim.keymap.set("x", "gc", function()
    VSCODE.call("editor.action.commentLine")
    VSCODE.call("vscode-neovim.escape", { key = "v" })
  end)

  -- this is broken
  vim.keymap.set(
    "x", "<Leader>gu",
    VSCodeMap("git.unstageSelectedRanges")
  )

  --  }}}

  -- settings and backup bindings {{{

  vim.opt.redrawtime = 0

  -- settings
  for key, cmd in pairs({
    -- TODO make this more like nvim counterparts
    w = VSCodeMap("editor.action.toggleWordWrap"),
    W = VSCodeMap("editor.action.toggleWordWrap"),
    -- loosely similar to nvim counterpart
    s = VSCodeMap("workbench.action.toggleStatusbarVisibility"),
  }) do
    vim.keymap.set("n", "<Space>q" .. key, cmd, { noremap = true })
  end

  -- some original bindings get overwritten by vscode extension and
  -- they are too good to just let go
  for _, key in pairs({
    "gq",
    "=",
  }) do
    vim.keymap.set({ "n", "x" }, "<Leader>v" .. key, key, { noremap = true })
  end

  --  }}}

  -- other stuff {{{

  -- for testing and quick additions
  -- no idea how good it really will be
  vim.api.nvim_create_user_command(
    "ReloadNvimConfig", function()
      vim.cmd({
        cmd = "source",
        args = { vim.fn.stdpath("config") .. "/init.lua" },
        -- TODO silent
      })
    end, {}
  )

  PCKR.add(plugin_configs)

  --  }}}

  return
  --  }}}
end

H.table_join(
  plugin_configs,
  { --  {{{
    "ryvnf/readline.vim",

    {
      "Rellikeht/lazy-utils", --  {{{
      config = function()
        LAZY_UTILS = require("lazy_utils")
      end
    }, --  }}}

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
        -- this makes things little faster and isn't that useful
        vim.g.matchup_matchparen_enabled = false
        -- not really needed, but nice when matchparen gets enabled
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
        TSINSTALL = require("nvim-treesitter.install")
        TSINSTALL.prefer_git = false
        LAZY_UTILS.load_on_startup(
          function()
            require "nvim-treesitter.configs".setup({
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
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

        -- TODO fzf preview position switch
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

-- other settings {{{

vim.cmd.filetype("on")
vim.cmd.filetype("plugin", "on")
vim.cmd.filetype("indent", "on")
vim.cmd.syntax("on")

vim.opt.autochdir = true

-- filetypes {{{

vim.g.markdown_minlines = 500

vim.api.nvim_create_autocmd(
  { "BufRead", "BufNewFile" },
  { pattern = "*.md", command = "set syntax=markdown" }
)

--  }}}

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
vim.opt.concealcursor = ""
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = " {{{, }}}"
vim.opt.foldlevel = 0
vim.opt.showbreak = "> "
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

--  }}}

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

-- other {{{

for key, cmd in pairs({
  w = ":<C-u>setlocal wrap!<CR>",
  W = ":<C-u>set wrap!<CR>",
  s = ":<C-u>SetOptionCount laststatus<CR>",
}) do
  vim.keymap.set("n", "<Space>q" .. key, cmd, { noremap = true })
end

--  }}}

--  }}}

-- filetypes {{{

-- ugly but handy
-- TODO does this work
vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = { --  {{{
      "python",
      "nix",
      "lua",
      "vim",
      "zig",
      "nim",
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
  [";n"] = vim.g["extras#count_on_function"](H.qlcmd("next")),
  [";p"] = vim.g["extras#count_on_function"](H.qlcmd("previous")),
  [";0"] = H.qlcmd("first"),
  [";$"] = H.qlcmd("last"),
  [";l"] = H.qlcmd("history"),
  [";w"] = function()
    local height = vim.v.count
    if height == 0 then height = 10 end
    H.qlcmd("open")({ count = height })
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
        "n", "<", H.qlcmd("older"), { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", ">", H.qlcmd("newer"), { noremap = true, buffer = true }
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
          H.qlcmd("open")()
          vim.fn.setpos(".", qpos)
        end, {
          buffer = true,
        }
      )
      vim.keymap.set(
        "n", "<BS>", function()
          vim.cmd.execute("\"normal \\<CR>\"")
          H.qlcmd("close")()
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

  --  }}}
elseif vim.fn.has("gui_running") == 1 then
  -- {{{
  --  }}}
else
  -- {{{
end --  }}}

function CODE()
  if CODE_LOADED ~= nil then return end

  PCKR.add({ -- {{{

    {
      "jpalardy/vim-slime",   --  {{{

      config_pre = function() --  {{{
        vim.g.slime_paste_file = vim.fn.tempname()
        vim.g.slime_dont_ask_default = true
        vim.g.slime_bracketed_paste = true
        vim.g.slime_no_mappings = true
      end,                --  }}}

      config = function() --  {{{
        vim.keymap.set(
          "n", "gs:", ":<C-u>SlimeConfigAll<CR>", { noremap = true }
        )
        vim.keymap.set(
          "n", "gss", "<Plug>SlimeLineSend", { noremap = true }
        )
        vim.keymap.set(
          "n", "gs", "<Plug>SlimeMotionSend", { noremap = true }
        )
        vim.keymap.set(
          "n", "gsi", "<Plug>SlimeParagraphSend", { noremap = true }
        )
        vim.keymap.set(
          "x", "gsi", "<Plug>SlimeRegionSend", { noremap = true }
        )
        vim.keymap.set("n", "gs;", ":SlimeSend<CR>", { noremap = true })
        vim.keymap.set("x", "gs;", ":SlimeSend<CR>", { noremap = true })

        vim.api.nvim_create_user_command(
          "SlimeConfigAll", function(_)
            vim.cmd.SlimeConfig()
            vim.g.slime_default_config = vim.b.slime_config
          end, { nargs = 0 }
        )

        function Slime_setup_tmux()
          local function slime_tmux_uniform_config()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              local has, _ = pcall(
                vim.api.nvim_buf_get_var, bufnr, "slime_config"
              )
              if has then
                vim.api.nvim_buf_set_var(
                  bufnr, "slime_config", vim.g.slime_default_config
                )
              end
            end
          end

          vim.api.nvim_create_user_command(
            "SlimeTmuxPane", function(opts)
              vim.g.slime_default_config = {
                socket_name = vim.g.slime_default_config.socket_name,
                target_pane = opts.fargs[1],
              }
              slime_tmux_uniform_config()
            end, { nargs = 1 }
          )
          vim.api.nvim_create_user_command(
            "SlimeTmuxSocket", function(opts)
              vim.g.slime_default_config = {
                socket_name = opts.fargs[1],
                target_pane = vim.g.slime_default_config.target_pane,
              }
              slime_tmux_uniform_config()
            end, { nargs = 1 }
          )

          vim.g.slime_target = "tmux"
          vim.g.slime_default_config = {
            socket_name = vim.fn.get(vim.fn.split(vim.env.TMUX, ","), 0),
            target_pane = "{top-right}",
          }
        end

        function Slime_setup_nvim()
          vim.g.slime_target = "neovim"
          vim.g.slime_suggest_default = false
          vim.g.slime_menu_config = false
          vim.g.slime_input_pid = false

          -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/targets/neovim.md
          vim.g.slime_get_jobid = function()
            -- iterate over all buffers to find the first terminal with a valid job
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ==
                  "terminal" then
                local chan = vim.api.nvim_get_option_value(
                  "channel", { buf = bufnr }
                )
                if chan and chan > 0 then return chan end
              end
            end
            return nil
          end

          pcall(vim.api.nvim_del_user_command, "SlimeTmuxPane")
          pcall(vim.api.nvim_del_user_command, "SlimeTmuxSocket")
        end

        -- There may be repl running in tmux that
        -- should be reused so this is global even with
        -- gui running
        if vim.env.TMUX then
          Slime_setup_tmux()
        else
          Slime_setup_nvim()
        end
      end --  }}}
    },    --  }}}

    {
      "mhinz/vim-signify", --  {{{
      config = function()
        vim.keymap.set("n", "+", "<Plug>(signify-next-hunk)", { noremap = true })
        vim.keymap.set("n", "-", "<Plug>(signify-prev-hunk)", { noremap = true })
        vim.keymap.set("n", "<Leader>gt", vim.cmd.SignifyToggle, { noremap = true })
        vim.keymap.set("n", "<Leader>gs", vim.cmd.SignifyHunkDiff, { noremap = true })
        vim.keymap.set("n", "<Leader>gS", vim.cmd.SignifyDiff, { noremap = true })
        vim.keymap.set("n", "<Leader>gu", vim.cmd.SignifyHunkUndo, { noremap = true })
        vim.keymap.set("n", "<Leader>gR", vim.cmd.SignifyRefresh, { noremap = true })
        vim.keymap.set("n", "<Leader>gh", vim.cmd.SignifyToggleHighlight, { noremap = true })

        vim.api.nvim_create_autocmd(
          "User", {
            pattern = "SignifyHunk",
            callback = function()
              local h = vim.fn["sy#util#get_hunk_stats"]()
              if vim.fn.empty(h) == 0 then
                print("[Hunk " .. h.current_hunk .. "/" .. h.total_hunks .. "]")
              end
            end
          }
        )
      end
    }, --  }}}

    {
      "norcalli/nvim-colorizer.lua", --  {{{
      config = function()
        local color_css_conf = {
          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css = true,
          -- Enable all CSS *functions*: rgb_fn, hsl_fn
          css_fn = true,
        }
        local color_vim_conf = { names = true }

        require("colorizer").setup({ --  {{{
          "*",
          html = color_css_conf,
          css = color_css_conf,
          js = color_css_conf,
          ts = color_css_conf,
          vim = color_vim_conf,
          lua = color_vim_conf,
        }, {
          -- #RGB hex codes
          RGB = true,
          -- #RRGGBB hex codes
          RRGGBB = true,
          -- "Name" codes like Blue
          names = false,
          -- #RRGGBBAA hex codes
          RRGGBBAA = true,
          -- CSS rgb() and rgba() functions
          rgb_fn = true,
          -- CSS hsl() and hsla() functions
          hsl_fn = true,
          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css = false,
          -- Enable all CSS *functions*: rgb_fn, hsl_fn
          css_fn = false,
          -- Set the display mode.
          -- Available modes: foreground, background
          mode = "background",
        }) --  }}}
      end,
    },     --  }}}

    {
      "neovim/nvim-lspconfig", --  {{{
      config = function()
        if vim.fn.has("nvim-0.10") == 0 then return end
        if vim.fn.has("nvim-0.11") == 1 then -- {{{
          -- for backwards compatibility
          function NvimDiagPrev()
            vim.diagnostic.jump({ count = -1, float = true })
          end

          function NvimDiagNext()
            vim.diagnostic.jump({ count = 1, float = true })
          end
        else
          function NvimDiagNext()
            ---@diagnostic disable-next-line: deprecated
            vim.diagnostic.goto_next()
          end

          function NvimDiagPrev()
            ---@diagnostic disable-next-line: deprecated
            vim.diagnostic.goto_prev()
          end
        end --  }}}

        local lspconfig = require("lspconfig")
        lspconfig.util.default_config = vim.tbl_extend(
          "force", lspconfig.util.default_config,
          { message_level = nil }
        )

        -- commands {{{

        vim.keymap
            .set("n", "<Leader>dqi", ":<C-u>LspInfo<CR>", {})
        vim.keymap
            .set("n", "<Leader>dql", ":<C-u>LspLog<CR>", {})
        vim.keymap.set(
          "n", "<Leader>dqr", ":<C-u>LspRestart<CR>", {}
        )
        vim.keymap.set(
          "n", "<Leader>de", vim.diagnostic.open_float,
          { desc = "show diagnostics under cursor" }
        )

        vim.keymap.set(
          "n", "<Leader>dp", vim.g["extras#count_on_function"](
            NvimDiagPrev, {
              severity = {
                vim.diagnostic.severity.ERROR,
                vim.diagnostic.severity.WARN,
              },
            }
          ), { desc = "[N] prev error or warning" }
        )
        vim.keymap.set(
          "n", "<Leader>dn", vim.g["extras#count_on_function"](
            NvimDiagNext, {
              severity = {
                vim.diagnostic.severity.ERROR,
                vim.diagnostic.severity.WARN,
              },
            }
          ), { desc = "[N] next error or warning" }
        )

        vim.keymap.set(
          "n", "<Leader>dP", vim.g["extras#count_on_function"](
            NvimDiagPrev,
            { severity = { vim.diagnostic.severity.ERROR } }
          ), { desc = "[N] prev error" }
        )
        vim.keymap.set(
          "n", "<Leader>dN", vim.g["extras#count_on_function"](
            NvimDiagNext,
            { severity = { vim.diagnostic.severity.ERROR } }
          ), { desc = "[N] next error" }
        )

        vim.keymap.set(
          "n", "<Leader>dk", vim.g["extras#count_on_function"](
            NvimDiagPrev, {
              severity = {
                vim.diagnostic.severity.INFO,
                vim.diagnostic.severity.HINT,
              },
            }
          ), { desc = "[N] prev hint/info" }
        )
        vim.keymap.set(
          "n", "<Leader>dj", vim.g["extras#count_on_function"](
            NvimDiagNext, {
              severity = {
                vim.diagnostic.severity.INFO,
                vim.diagnostic.severity.HINT,
              },
            }
          ), { desc = "[N] next hint/info" }
        )

        vim.keymap.set(
          "n", "<Leader>dll", function(_)
            if vim.g.qfloc == 1 then
              vim.diagnostic.setloclist({ open = true })
            else
              vim.diagnostic.setqflist({ open = true })
            end
          end, {
            noremap = true,
            desc = "populate quickfix/loclist with diagnostics",
          }
        )

        --  }}}

        vim.api.nvim_create_autocmd( -- {{{
          "LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(args)
              -- helpers {{{

              local bufnr = args.buf
              local client = vim.lsp.get_client_by_id(
                args.data.client_id
              )

              --  }}}

              -- insert mode {{{

              if client and
                  client.server_capabilities.completionProvider then
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
              end
              if client and
                  client.server_capabilities.definitionProvider then
                vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
              end

              --  }}}

              -- navigation {{{

              vim.keymap.set(
                "n", "<Leader>dd", H.wrap_qfloc(vim.lsp.buf.definition),
                { desc = "go to definition", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dD", H.wrap_qfloc(vim.lsp.buf.declaration),
                { desc = "go to declaration", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>di", H.wrap_qfloc(vim.lsp.buf.implementation)
                , { desc = "go to implementation", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dt", H.wrap_qfloc(vim.lsp.buf.type_definition)
                ,
                { desc = "go to type definition", buffer = bufnr }
              )

              --  }}}

              -- info {{{

              vim.keymap.set(
                "n", "<Leader>ds", vim.lsp.buf.signature_help,
                { desc = "signature help", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dh", vim.lsp.buf.hover, {
                  desc = "display hover information about the symbol under the cursor",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>dlr", H.wrap_qfloc(vim.lsp.buf.references), {
                  desc = "populate quickfix list with references",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>dls", H.wrap_qfloc(vim.lsp.buf.document_symbol), {
                  desc = "populate quickfix/loclist with symbols in current file",
                  buffer = bufnr,
                }
              )

              --  }}}

              -- actions {{{

              vim.keymap.set(
                "n", "<Leader>dr", vim.lsp.buf.rename, {
                  desc = "rename symbol under cursor",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                { "n", "x" }, "<Leader>df", function()
                  vim.lsp.buf.format({ async = false })
                  vim.cmd.norm("zv")
                end, {
                  desc = "format buffer using lsp",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>da", vim.lsp.buf.code_action,
                { desc = "execute code action", buffer = bufnr }
              )

              --  }}}

              LSP_CONFIG_CALLBACK(bufnr)
            end,
          }
        ) --  }}}
      end,
    },    --  }}}

    {
      "Rellikeht/nvim-lsp-config", --  {{{
      requires = {
        "neovim/nvim-lspconfig",
        "Rellikeht/lazy-utils",
        "mfussenegger/nvim-jdtls",
        "p00f/clangd_extensions.nvim",
      },
      config = function()
        LSP_CONFIG_CALLBACK = function(bufnr)
          local lsp_config = require("nvim_lsp_config")
          lsp_config.wrap_float()
          vim.keymap.set(
            "n", "<Leader>dH",
            function()
              lsp_config.buf_hover_preview({}, bufnr)
            end, {
              desc = "display information about the symbol under the cursor in preview window",
              buffer = bufnr,
            }
          )
          vim.keymap.set(
            "i", "<C-_>",
            function()
              lsp_config.insert_hover({
                relative = "cursor",
                anchor_bias = "above",
                focusable = false,
                zindex = 1000,
              }, bufnr)
            end,
            {
              desc = "display hover information about the symbol under the cursor",
              buffer = bufnr,
            }
          )
        end
      end,
    }, --  }}}

    {
      "HiPhish/info.vim", --  {{{
      config = function()
        vim.api.nvim_create_autocmd(
          "FileType", {
            pattern = "info",
            callback = function()
              vim.keymap.set("n", "<Leader>n", "<Plug>(InfoNext)", { noremap = true })
              vim.keymap.set("n", "<Leader>p", "<Plug>(InfoPrev)", { noremap = true })
              vim.keymap.set("n", "<Leader>u", "<Plug>(InfoPrev)", { noremap = true })
              vim.keymap.set("n", "<Leader>m", "<Plug>(InfoMenu)", { noremap = true })
              vim.keymap.set("n", "<Leader>o", "<Plug>(InfoGoto)", { noremap = true })
            end,
          }
        )
      end
    }, --  }}}

    -- TODO rainbow ?
    -- TODO formatters (neoformat)
    -- TODO snippets
  }
  ) --  }}}

  -- post setup {{{

  -- treesitter {{{

  do
    -- This is because FileType is not triggered on first file sometimes
    -- TODO this seems wrong and takes long time on big files
    LAZY_UTILS.load_on_startup(function()
      vim.cmd.filetype("detect")
    end)
  end

  for key, name in pairs({
    ["*"] = "comment",
    [{ "sh", "bash", "zsh" }] = "bash",
    "python",
    "powershell",
    "go",
    "rust",
    "cpp",
    "c",
    "html",
    "css",
    "java",
    "elixir",
    "julia",
    "ocaml",
    "haskell",
    "typst",
    "latex",
  }
  ) do
    local filetypes = nil
    if type(key) == "string" or type(key) == "table" then
      filetypes = key
    end
    H.lazy_ts_ensure_installed(name, filetypes)
  end

  --  }}}

  --  }}}

  if vim.fn.has("win32") == 1 then -- {{{
    TSINSTALL.compilers = { "zig", "cl", "cc", "gcc", "clang" }

    --  }}}
  else -- {{{
  end  --  }}}

  CODE_LOADED = true
end

-- additional {{{

pcall(require, "local")

-- Special Code command as part of config
vim.api.nvim_create_user_command("Code", CODE, { nargs = 0 })

vim.api.nvim_create_user_command(
  "RSource", function(opts)
    require(opts.fargs[1])
  end, { nargs = 1 }
)

--  }}}
