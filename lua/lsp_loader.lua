return function(notify)
  local METHOD = "info"
  local client_notifs = {}
  local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

  local function get_notif_data(client_id, token)
    if not client_notifs[client_id] then
      client_notifs[client_id] = {}
    end

    if not client_notifs[client_id][token] then
      client_notifs[client_id][token] = {}
    end

    return client_notifs[client_id][token]
  end

  local function update_spinner(client_id, token)
    local notif_data = get_notif_data(client_id, token)

    if not notif_data.spinner then
      return
    end

    local new_spinner = (notif_data.spinner + 1) % #spinner_frames
    notif_data.spinner = new_spinner

    notif_data.notification = notify(nil, nil, {
      hide_from_history = true,
      icon = spinner_frames[new_spinner],
      replace = notif_data.notification,
    })

    vim.defer_fn(function()
      update_spinner(client_id, token)
    end, 100)
  end

  local function format_title(title, client_name)
    return client_name .. (#title > 0 and ": " .. title or "")
    -- return "LSP - " .. client_name
  end

  local function format_message(message, percentage)
    if message == nil or percentage == nil then
      return " Loading..."
    end

    return (percentage and percentage .. "%\t" or "") .. (message or "")
  end

  vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    local client_id = ctx.client_id
    local val = result.value
    local get_client_by_id = vim.lsp.get_client_by_id(client_id)
    local name = get_client_by_id.name

    if name == "null-ls" then
      return
    end

    if not val.kind then
      return
    end

    local notif_data = get_notif_data(client_id, result.token)

    if val.kind == "begin" then
      local message = format_message(val.message, val.percentage)
      local options = {
        title = format_title(val.title, name),
        icon = spinner_frames[1],
        timeout = false,
        hide_from_history = false,
      }
      notif_data.notification = notify(message, METHOD, options)
      notif_data.spinner = 1
      update_spinner(client_id, result.token)
    elseif val.kind == "report" and notif_data then
      local message = format_message(val.message, val.percentage)
      local options = {
        replace = notif_data.notification,
        hide_from_history = false,
      }
      notif_data.notification = notify(message, METHOD, options)
    elseif val.kind == "end" and notif_data then
      local message = val.message and format_message(val.message) or " " .. name
      local options = {
        title = " Language Server Protocol",
        icon = "",
        replace = notif_data.notification,
        timeout = 3000,
      }
      notif_data.notification = notify(message, METHOD, options)
      notif_data.spinner = nil
    end
  end
end
