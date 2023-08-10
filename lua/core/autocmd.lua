local M = {}
local Log = require("core.log")

--- Load the default set of autogroups and autocommands.
function M.load_defaults()
    vim.cmd([[
if has("autocmd")
    " Have Vim jump to the last position when reopening a file
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\""
    " Disable relative line numbers in insert mode
    autocmd InsertLeave * set relativenumber
    autocmd InsertEnter * set norelativenumber
endif
]])

    local definitions = {
        {
            "BufWritePre",
            {
                group = "auto_create_dir",
                pattern = "*",
                desc = "Automatically create directory if none exists.",
                callback = function(event)
                    if event.match:match("^%w%w+://") then
                        return
                    end
                    local file = vim.loop.fs_realpath(event.match)
                        or event.match
                    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
                end,
            },
        },
        {
            "TextYankPost",
            {
                group = "_general_settings",
                pattern = "*",
                desc = "Highlight text on yank",
                callback = function()
                    require("vim.highlight").on_yank({
                        higroup = "Search",
                        timeout = 200,
                    })
                end,
            },
        },
        {
            "BufWritePost",
            {
                group = "_general_settings",
                pattern = user_config_file,
                desc = "Trigger Reload on saving " .. vim.fn.expand("%:~"),
                callback = function()
                    require("utils").Flush()
                end,
            },
        },
        {
            "FileType",
            {
                group = "_filetype_settings",
                pattern = "qf",
                command = "set nobuflisted",
            },
        },
        {
            "FileType",
            {
                group = "_filetype_settings",
                pattern = { "gitcommit", "markdown" },
                command = "setlocal wrap spell",
            },
        },
        {
            "FileType",
            {
                group = "_buffer_mappings",
                pattern = {
                    "qf",
                    "help",
                    "man",
                    "floaterm",
                    "lspinfo",
                    "lir",
                    "spectre_panel",
                    "lsp-installer",
                    "null-ls-info",
                    "dap-float",
                    "fugitive",
                    "help",
                    "man",
                    "notify",
                    "null-ls-info",
                    "qf",
                    "PlenaryTestPopup",
                    "startuptime",
                    "tsplayground",
                },
                command = "nnoremap <silent> <buffer> q :close<CR>",
            },
        },
        {
            { "BufWinEnter", "BufRead", "BufNewFile" },
            {
                group = "_format_options",
                pattern = "*",
                command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
            },
        },
        {
            "VimResized",
            {
                group = "_auto_resize",
                pattern = "*",
                command = "tabdo wincmd =",
            },
        },

        {
            "BufEnter",
            {
                pattern = "*",
                command = "set fo-=c fo-=r fo-=o",
            },
        },
        {
            { "BufRead", "BufNewFile" },
            {
                pattern = { "*.txt", "*.md", "*.tex" },
                callback = function()
                    vim.opt.spell = true
                    vim.opt.spelllang = "en,de"
                end,
            },
        },
    }

    M.define_autocmds(definitions)
end

-- local get_format_on_save_opts = function()
--     local defaults = {
--         ---@usage pattern string pattern used for the autocommand (Default: '*')
--         pattern = "*",
--         ---@usage timeout number timeout in ms for the format request (Default: 1000)
--         timeout = 1000,
--         ---@usage filter func to select client
--         filter = require("lsp.utils").format_filter,
--     }
--     -- accept a basic boolean `lsp.format_on_save=true`
--     if type(lsp.format_on_save) ~= "table" then
--         return defaults
--     end
--
--     return {
--         pattern = lsp.format_on_save.pattern or defaults.pattern,
--         timeout = lsp.format_on_save.timeout or defaults.timeout,
--     }
-- end
--
-- function M.enable_format_on_save()
--     local opts = get_format_on_save_opts()
--     vim.api.nvim_create_augroup("lsp_format_on_save", {})
--     vim.api.nvim_create_autocmd("BufWritePre", {
--         group = "lsp_format_on_save",
--         pattern = opts.pattern,
--         callback = function()
--             require("lsp.utils").format({
--                 timeout_ms = opts.timeout,
--                 filter = opts.filter,
--             })
--         end,
--     })
--     Log:debug("enabled format-on-save")
-- end
--
-- function M.disable_format_on_save()
--     M.clear_augroup("lsp_format_on_save")
--     Log:debug("disabled format-on-save")
-- end
--
-- function M.configure_format_on_save()
--     if lsp.format_on_save then
--         M.enable_format_on_save()
--     else
--         M.disable_format_on_save()
--     end
-- end
--
-- function M.toggle_format_on_save()
--     local exists, autocmds = pcall(vim.api.nvim_get_autocmds, {
--         group = "lsp_format_on_save",
--         event = "BufWritePre",
--     })
--     if not exists or #autocmds == 0 then
--         M.enable_format_on_save()
--     else
--         M.disable_format_on_save()
--     end
-- end

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
    -- defer the function in case the autocommand is still in-use
    Log:debug("request to clear autocmds  " .. name)
    vim.schedule(function()
        pcall(function()
            vim.api.nvim_clear_autocmds({ group = name })
        end)
    end)
end

--- Create autocommand groups based on the passed definitions
--- Also creates the augroup automatically if it doesn't exist
---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
    for _, entry in ipairs(definitions) do
        local event = entry[1]
        local opts = entry[2]
        if type(opts.group) == "string" and opts.group ~= "" then
            local exists, _ =
                pcall(vim.api.nvim_get_autocmds, { group = opts.group })
            if not exists then
                vim.api.nvim_create_augroup(opts.group, {})
            end
        end
        vim.api.nvim_create_autocmd(event, opts)
    end
end

return M
