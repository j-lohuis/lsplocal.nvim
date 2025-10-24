-- Lightweight helper to let lsp/<name>.lua return maybe_load_local(name, default_tbl)
local M = {}

-- Read and decode a JSON file. Returns table or nil.
local function read_json_file(path)
  if type(path) ~= "string" or path == "" then return nil end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines then return nil end
  local content = table.concat(lines, "\n")
  local ok2, decoded = pcall(vim.json.decode, content)
  if not ok2 then return nil end
  return decoded
end

-- Find nearest .nvim/<name>.json upward from 'start'. If start omitted uses buffer dir or cwd.
-- Returns the absolute path or nil.
local function find_project_json(name, start)
  if type(name) ~= "string" or name == "" then return nil end
  start = start or (vim.api.nvim_buf_get_name(0) ~= "" and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h") or vim.loop.cwd())
  local filename = ".nvim/" .. name .. ".json"
  local found = vim.fs.find({ filename }, { path = start, upward = true })
  return (found and found[1]) or nil
end

-- Deep-merge project table into default. Project wins.
local function merge_config(default_tbl, project_tbl)
  if type(default_tbl) ~= "table" then return default_tbl end
  if type(project_tbl) ~= "table" then return default_tbl end
  return vim.tbl_deep_extend("force", {}, default_tbl, project_tbl)
end

--- maybe_load_local(name, default_tbl[, opts])
-- name: 'rust_analyzer', 'pyright', etc.
-- default_tbl: the default config table you want returned if no project override
-- opts (optional): { start = <path> } - override start search dir
-- Returns: merged table (project overrides applied) or default_tbl
function M.maybe_load_local(name, default_tbl, opts)
  opts = opts or {}
  local json_path = find_project_json(name, opts.start)
  if not json_path then return default_tbl end
  local project_tbl = read_json_file(json_path)
  if type(project_tbl) ~= "table" then return default_tbl end
  return merge_config(default_tbl, project_tbl)
end

return M
