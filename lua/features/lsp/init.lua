local Utils = require("utils")

---@class LspServer
---@field keys? string|string[]|LazyKeysSpec[]|fun(self:LazyPlugin, keys:string[]):(string|LazyKeys)[]
---@field capabilities? table
---@field on_attach? fun(client, bufnr)

---@class LspOptions
---@field servers table<string, LspServer>
---@field capabilities? table
---@field diagnostics? boolean

---@class Lsp
---@field keymaps features.lsp.keymaps
---@field navic features.lsp.navic
---@field diagnostics features.lsp.diagnostics
local M = {}

setmetatable(M, {
  __index = function(_, k)
    local mod = require("features.lsp." .. k)
    return mod
  end,
})

---@param opts LspOptions
function M.setup(opts)
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then
    Utils.notify("Plugin `neovim/nvim-lspconfig` not installed", "ERROR")
    return
  end
  -- Diagnostics
  M.diagnostics.setup(opts.diagnostics)

  -- Keymaps
  Utils.lsp.on_attach(function(client, bufnr)
    M.keymaps(client, bufnr)
    M.navic(client, bufnr)
  end)

  local servers = opts.servers
  -- Gets a new ClientCapabilities object describing the LSP client capabilities.
  local client_capabilites = vim.lsp.protocol.make_client_capabilities()

  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    client_capabilites,
    require("cmp_nvim_lsp").default_capabilities(),
    opts.capabilities or {}
  )

  --- Setup a LSP server
  ---@param server string The name of the server
  local function setup(server)
    -- resolve server capabilities
    if servers[server] and servers[server].capabilities and type(servers[server].capabilities) == "function" then
      servers[server].capabilities = servers[server].capabilities() or {}
    end

    local server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(capabilities),
    }, servers[server] or {})

    if server_opts.on_attach then
      local function callback(client, bufnr)
        if client.name == server then
          server_opts.on_attach(client, bufnr)
        end
      end
      Utils.lsp.on_attach(callback)
    end
    lspconfig[server].setup(server_opts)
  end

  local available = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)

  local ensure_installed = {}
  for server, server_opts in pairs(servers) do
    if server_opts then
      if not vim.tbl_contains(available, server) then
        setup(server)
      else
        ensure_installed[#ensure_installed + 1] = server
      end
    end
  end

  require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
  require("mason-lspconfig").setup_handlers({ setup })
end

return M
