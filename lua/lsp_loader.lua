return function(notify)
  local format = require "utils.format"
  local helper = require "utils.helper"
  local METHOD = "info"

  local do_begin = function(value, name, notif_data, client_id, result)
    local message = format.message(value.message, value.percentage)
    local options = {
      title = format.title(value.title, name),
      icon = helper.spinner_frames[1],
      timeout = false,
      hide_from_history = false,
    }
    notif_data.notification = notify(message, METHOD, options)
    notif_data.spinner = 1
    helper.update_spinner(client_id, result.token, notify)
  end

  local do_report = function(value, notif_data)
    local message = format.message(value.message, value.percentage)
    local options = {
      replace = notif_data.notification.id,
      hide_from_history = false,
    }
    notif_data.notification = notify(message, METHOD, options)
  end

  local do_end = function(value, notif_data, name)
    local message = value.message and format.message(value.message) or " " .. name
    local options = {
      title = " Language Server Protocol",
      icon = "",
      replace = notif_data.notification.id,
      timeout = 3000,
    }
    notif_data.notification = notify(message, METHOD, options)
    notif_data.spinner = nil
  end

  local set_lsp_progress = function(result, ctx)
    local value = result.value

    if not value.kind then
      return
    end

    local client_id = ctx.client_id
    local name = vim.lsp.get_client_by_id(client_id).name

    if name == "null-ls" then
      return
    end

    local notif_data = helper.get_notif_data(client_id, result.token)

    if value.kind == "begin" then
      do_begin(value, name, notif_data, client_id, result)
    elseif value.kind == "report" and notif_data then
      do_report(value, notif_data)
    elseif value.kind == "end" and notif_data then
      do_end(value, notif_data, name)
    end
  end

  vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    set_lsp_progress(result, ctx)
  end
end
