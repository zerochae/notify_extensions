local M = {}

M.title = function(title, client_name)
  -- return client_name .. (#title > 0 and ": " .. title or "")
  return "LSP - " .. client_name
end

M.message = function(message, percentage)
  if message == nil or percentage == nil then
    return " Loading..."
  end

  return (percentage and percentage .. "%\t" or "") .. (message or "")
end

return M
