local M = {}
local notify = vim.notify
local lsp_loader = require "lsp_loader"
local plugin_updator = require "plugin_updator"
local notify_extensions = {}

local default_config = {
  lsp_loader = {
    enable = true,
  },
  plugin_updator = {
    enable = true,
  },
}

local init = function()
  for _, extension in pairs(notify_extensions) do
    extension()
  end
end

M.setup = function(config)
  local lsp_loader_enable = config.lsp_loader.enable or default_config.lsp_loader.enable
  local plugin_updator_enable = config.plugin_updator.enable or default_config.plugin_updator.enable

  if lsp_loader_enable then
    table.insert(notify_extensions, lsp_loader(notify))
  end

  if plugin_updator_enable then
    table.insert(notify_extensions, plugin_updator(notify))
  end

  init()
end

return M
