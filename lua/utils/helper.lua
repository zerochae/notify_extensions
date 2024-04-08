local M = {}
local client_notifs = {}

M.spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

M.get_notif_data = function(name)
  if not client_notifs[name] then
    client_notifs[name] = {}
  end

  return client_notifs[name]
end

M.update_spinner = function(name, notify)
  local notif_data = M.get_notif_data(name)

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
    M.update_spinner(name, notify)
  end, 100)
end

return M
