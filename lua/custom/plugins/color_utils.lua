local M = {}

-- Function to lighten an RGB color by a percentage
-- @param hex: string (e.g., "#1f2335")
-- @param percent: number (e.g., 0.05 for 5% lighter)
function M.lighten(hex, percent)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  r = math.min(255, r + math.floor(255 * percent))
  g = math.min(255, g + math.floor(255 * percent))
  b = math.min(255, b + math.floor(255 * percent))

  -- Format back to hex string
  return string.format("#%02x%02x%02x", r, g, b)
end

return M
