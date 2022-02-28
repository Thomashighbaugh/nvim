local M = {}

function M.on_attach(client, bufnr)
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	-- Enable completion triggered by <c-x><c-o>
	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	local formatting_servers = { "efm", "eslint" }
	if vim.tbl_contains(formatting_servers, client.name) then
		client.resolved_capabilities.document_formatting = true
		client.resolved_capabilities.document_range_formatting = true
	else
		client.resolved_capabilities.document_formatting = false
		client.resolved_capabilities.document_range_formatting = false
	end

	require("lsp.mappings")

	require("lsp_signature").on_attach({
		bind = true, -- This is mandatory, otherwise border config won't get registered.
		handler_opts = {
			border = "single",
		},
	}, bufnr)

	-- for some reason, highlights have to happen here
	require("plugins.theme.highlights").init()
end

M.flags = {
	debounce_text_changes = 150,
}

M.capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

M.root_dir = function(fname)
	local util = require("lspconfig").util
	return util.root_pattern(".git")(fname)
		or util.root_pattern("tsconfig.base.json")(fname)
		or util.root_pattern("package.json")(fname)
		or util.root_pattern(".eslintrc.js")(fname)
		or util.root_pattern("tsconfig.json")(fname)
end

return M
