local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

local M = {}

M.decorator = {}

local postfix_trig = function(match)
  return string.format("(%s)", match)
end

local latex_command_overrides

local postfix_node = f(function(_, snip)
  local capture = snip.captures[1] or ""
  local override = latex_command_overrides[capture]
  if not override then
    override = latex_command_overrides[capture:lower()]
  end
  local command = override or capture
  return string.format("\\%s ", command)
end, {})

latex_command_overrides = {
  aa = "alpha",
  AA = "Alpha",
  bb = "beta",
  BB = "Beta",
  gg = "gamma",
  GG = "Gamma",
  dd = "delta",
  DD = "Delta",
  ee = "epsilon",
  EE = "Epsilon",
  hh = "eta",
  HH = "Eta",
  tt = "theta",
  TT = "Theta",
  ii = "iota",
  II = "Iota",
  kk = "kappa",
  KK = "Kappa",
  ll = "lambda",
  LL = "Lambda",
  mm = "mu",
  MM = "Mu",
  nn = "nu",
  NN = "Nu",
  ww = "omega",
  WW = "Omega",
  ph = "phi",
  PH = "Phi",
  ff = "phi",
  FF = "Phi",
  pp = "pi",
  PP = "Pi",
  ps = "psi",
  PS = "Psi",
  rr = "rho",
  RR = "Rho",
  ss = "sigma",
  SS = "Sigma",
  ta = "tau",
  TA = "Tau",
  cc = "chi",
  CC = "Chi",
  zz = "zeta",
  ZZ = "Zeta",
  ve = "varepsilon",
  vf = "varphi",
  vr = "varrho",
  vt = "vartheta",
}
local vargreek_triggers = { "ve", "vf", "vr", "vt" }
local greek_triggers =
  { "aa", "bb", "gg", "dd", "ee", "hh", "ta", "ii", "kk", "ll", "mm", "nn", "ww", "ph", "ff", "ps", "rr", "ss", "tt", "cc", "zz" }

M.latex_command_overrides = latex_command_overrides

local to_case_insensitive_pattern = function(str)
  local pattern = {}
  for i = 1, #str do
    local c = str:sub(i, i)
    local lower = c:lower()
    local upper = c:upper()
    if lower ~= upper then
      pattern[#pattern + 1] = string.format("[%s%s]", lower, upper)
    else
      pattern[#pattern + 1] = c
    end
  end
  return table.concat(pattern)
end

local case_insensitive_postfix_trig = function(match)
  return postfix_trig(to_case_insensitive_pattern(match))
end

local build_snippet = function(trig, node, match, priority, name)
  return s({
    name = name and name(match) or match,
    trig = trig(match),
    priority = priority,
  }, vim.deepcopy(node))
end

local build_with_priority = function(trig, node, priority, name)
  return function(match)
    return build_snippet(trig, node, match, priority, name)
  end
end

local vargreek_postfix_completions = function()
  local build =
    build_with_priority(case_insensitive_postfix_trig, postfix_node, 200, function(match)
      return latex_command_overrides[match]
    end)
  return vim.tbl_map(build, vargreek_triggers)
end

local greek_postfix_completions = function()
  local build =
    build_with_priority(case_insensitive_postfix_trig, postfix_node, 200, function(match)
      return latex_command_overrides[match]
    end)
  return vim.tbl_map(build, greek_triggers)
end

local postfix_completions = function()
  local re = "sin|cos|tan|csc|sec|cot|ln|log|exp|star|perp|int"

  local build = build_with_priority(postfix_trig, postfix_node)
  return vim.tbl_map(build, vim.split(re, "|"))
end

local snippets = {}

function M.retrieve(is_math)
  local utils = require("luasnip-latex-snippets.util.utils")
  local pipe = utils.pipe
  local no_backslash = utils.no_backslash

  M.decorator = {
    wordTrig = true,
    trigEngine = "pattern",
    condition = pipe({ is_math, no_backslash }),
  }

  s = ls.extend_decorator.apply(ls.snippet, M.decorator) --[[@as function]]

  vim.list_extend(snippets, vargreek_postfix_completions())
  vim.list_extend(snippets, greek_postfix_completions())
  vim.list_extend(snippets, postfix_completions())
  vim.list_extend(snippets, { build_snippet(postfix_trig, postfix_node, "q?quad", 200) })

  return snippets
end

return M
