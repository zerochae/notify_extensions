local M = {}

local present, notify = pcall(require, "notify")

if not present then
  return
end

local lsp_loader = require "lsp_loader"
local plugin_updator = require "plugin_updator"

local default_config = {
  lsp_loader = {
    enable = true,
    ignore = {},
  },
  plugin_updator = {
    enable = true,
  },
}

M.setup = function(config)
  local notify_extensions = {}
  local lsp_loader_enable = config.lsp_loader.enable or default_config.lsp_loader.enable
  local plugin_updator_enable = config.plugin_updator.enable or default_config.plugin_updator.enable
  local ignore_lsp = config.lsp_loader.igrnoe or default_config.lsp_loader.ignore
  local init = function(extensions)
    for _, extension in pairs(extensions) do
      extension()
    end
  end

  if lsp_loader_enable then
    notify_extensions.lsp_loader = lsp_loader(notify, ignore_lsp)
  end

  if plugin_updator_enable then
    notify_extensions.plugin_updator = plugin_updator(notify)
  end

  init(notify_extensions)
end

return M
