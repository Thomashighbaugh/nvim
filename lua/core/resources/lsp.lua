return {
  {
    "neovim/nvim-lspconfig",
    branch = "master",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        html = {},
        lua_ls = {
          settings = {
            Lua = {
              hint = { enable = true },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              misc = {
                parameters = {
                  "--log-level=trace",
                },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      ---@type table<string, fun(client, buffer)>
      attach_handlers = {},
      capabilities = {
        textDocument = {
          foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
        },
      },
    },
    config = function(_, opts)
      local Util = require("util")
      -- special attach lsp
      Util.on_attach(function(client, buffer)
        require("config.lsp.navic").attach(client, buffer)
        require("config.lsp.keymaps").attach(client, buffer)
        require("config.lsp.gitsigns").attach(client, buffer)
      end)

      -- diagnostics
      vim.diagnostic.config(require("config.lsp.diagnostics")["on"])

      local servers = opts.servers
      local ext_capabilites = vim.lsp.protocol.make_client_capabilities()

      -- inlay hints
      local inlay_hint = vim.lsp.buf.inlayhints or vim.lsp.inlayhints
      if vim.fn.has("nvim-0.10.0") and inlay_hint then
        Util.on_attach(function(client, buffer)
          if client.supports_method("textDocument/inlayHint") then
            inlay_hint(buffer, true)
          end
        end)
      end

      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        ext_capabilites,
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.attach_handlers[server] then
          local callback = function(client, buffer)
            if client.name == server then
              opts.attach_handlers[server](client, buffer)
            end
          end
          Util.on_attach(callback)
        end
        require("lspconfig")[server].setup(server_opts)
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
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- formatters
  {
    "jose-elias-alvarez/null-ls.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    lazy = true,
    dependencies = { "mason.nvim" },
    root_has_file = function(files)
      return function(utils)
        return utils.root_has_file(files)
      end
    end,
    opts = function(plugin)
      local root_has_file = plugin.root_has_file
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local completion = null_ls.builtins.completion
      local diagnostics = null_ls.builtins.diagnostics
      local code_actions = null_ls.builtins.code_actions
      local stylua_root_files = { "stylua.toml", ".stylua.toml" }
      local modifier = {
        stylua_formatting = {
          condition = root_has_file(stylua_root_files),
        },
      }
      return {
        debug = false,
        -- You can then register sources by passing a sources list into your setup function:
        -- using `with()`, which modifies a subset of the source's default options
        sources = {
          formatting.stylua.with(modifier.stylua_formatting),
          formatting.markdownlint,
          formatting.beautysh.with({ extra_args = { "--indent-size", "2" } }),
          formatting.prettierd.with({
            extra_args = { "--single-quote", "false" },
            filetypes = { "html", "json", "yaml", "markdown" },
          }),

          completion.luasnip,
          completion.tags,
          formatting.rubyfmt,
          formatting.rustfmt,
          formatting.rustywind,
          formatting.yamlfix,
          diagnostics.actionlint,
          diagnostics.statix,
          diagnostics.trail_space,
          diagnostics.deadnix,
          diagnostics.statix,
          diagnostics.todo_comments,
          diagnostics.tsc,
          diagnostics.zsh,
          formatting.terraform_fmt,
          formatting.black,
          formatting.cbfmt,
          formatting.goimports,
          formatting.gofumpt,
          formatting.latexindent.with({
            extra_args = { "-g", "/dev/null" }, -- https://github.com/cmhughes/latexindent.pl/releases/tag/V3.9.3
          }),
          code_actions.shellcheck,
          code_actions.refactoring.with({
            filetypes = { "go", "javascript", "lua", "python", "typescript" },
          }),
          code_actions.statix,
          code_actions.ts_node_action,
          formatting.alejandra,
          formatting.fixjson,
          formatting.markdownlint,
          formatting.markdown_toc,
          formatting.trim_newlines,
          formatting.trim_whitespace,
          code_actions.gitsigns,
          formatting.shfmt,
        },
      }
    end,
    config = function(_, opts)
      local null_ls = require("null-ls")
      null_ls.setup(opts)
    end,
  },
}
