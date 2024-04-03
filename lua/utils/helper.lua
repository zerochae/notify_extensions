local M = {}
local client_notifs = {}

M.spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

M.get_notif_data = function(client_id, token)
  if not client_notifs[client_id] then
    client_notifs[client_id] = {}
  end

  if not client_notifs[client_id][token] then
    client_notifs[client_id][token] = {}
  end

  return client_notifs[client_id][token]
end

M.update_spinner = function(client_id, token, notify)
  local notif_data = M.get_notif_data(client_id, token)

  if not notif_data.spinner then
    return
  end

  local new_spinner = (notif_data.spinner + 1) % #M.spinner_frames
  notif_data.spinner = new_spinner

  notif_data.notification = notify(nil, nil, {
    hide_from_history = true,
    icon = M.spinner_frames[new_spinner],
    replace = notif_data.notification.id,
  })

  vim.defer_fn(function()
    M.update_spinner(client_id, token)
  end, 100)
end

return M
