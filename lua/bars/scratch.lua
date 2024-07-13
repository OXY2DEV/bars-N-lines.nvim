-- Edit: Updated to fix an issue where signs were duplicated in splits
--
-- I've seen a few comments the past few days asking about how to separate signcolumn elements, such as diagnostics and gitsigns, into different fields. I was looking for how to do this myself and, in a recent thread, u/nifoc displayed how to do it in Fennel. With their guidance in that thread, I translated it to Lua. I wasn't really using it after that, though. After being asked by another user tonight how to do it, I decided to work on it and flesh it out a bit more. Mind you, this likely will have issues. This is just to get you started. 
--
-- At the top, you can replace whatever highlights to use for the various Gitsigns symbols or the symbols you want to use for diagnostics. If you already define those signs elsewhere, you could import it by requiring it, and so on.

local gitsigns_bar = '▌'

local gitsigns_hl_pool = {
	GitSignsAdd          = "DiagnosticOk",
	GitSignsChange       = "DiagnosticWarn",
	GitSignsChangedelete = "DiagnosticWarn",
	GitSignsDelete       = "DiagnosticError",
	GitSignsTopdelete    = "DiagnosticError",
	GitSignsUntracked    = "NonText",
}

local diag_signs_icons = {
	DiagnosticSignError = " ",
	DiagnosticSignWarn = " ",
	DiagnosticSignInfo = " ",
	DiagnosticSignHint = "",
	DiagnosticSignOk = " "
}

local function get_sign_name(cur_sign)
	if (cur_sign == nil) then
		return nil
	end

	cur_sign = cur_sign[1]

	if (cur_sign == nil) then
		return nil
	end

	cur_sign = cur_sign.signs

	if (cur_sign == nil) then
		return nil
	end

	cur_sign = cur_sign[1]

	if (cur_sign == nil) then
		return nil
	end

	return cur_sign["name"]
end

local function mk_hl(group, sym)
	return table.concat({ "%#", group, "#", sym, "%*" })
end

local function get_name_from_group(bufnum, lnum, group)
	local cur_sign_tbl = vim.fn.sign_getplaced(bufnum, {
		group = group,
		lnum = lnum
	})

	return get_sign_name(cur_sign_tbl)
end

_G.get_statuscol_gitsign = function(bufnr, lnum)
	local cur_sign_nm = get_name_from_group(bufnr, lnum, "gitsigns_vimfn_signs_")

	if cur_sign_nm ~= nil then
		return mk_hl(gitsigns_hl_pool[cur_sign_nm], gitsigns_bar)
	else
		return " "
	end
end

_G.get_statuscol_diag = function(bufnum, lnum)
	local cur_sign_nm = get_name_from_group(bufnum, lnum, "*")

	if cur_sign_nm ~= nil and vim.startswith(cur_sign_nm, "DiagnosticSign") then
		return mk_hl(cur_sign_nm, diag_signs_icons[cur_sign_nm])
	else
		return " "
	end
end













_G.get_statuscol = function()
	local str_table = {}

	local parts = {
		["diagnostics"] = "%{%v:lua.get_statuscol_diag(bufnr(), v:lnum)%}",
		["fold"] = "%C",
		["gitsigns"] = "%{%v:lua.get_statuscol_gitsign(bufnr(), v:lnum)%}",
		["num"] = "%{v:relnum?v:relnum:v:lnum}",
		["sep"] = "%=",
		["signcol"] = "%s",
		["space"] = " "
	}

	local order = {
		"diagnostics",
		"sep",
		"num",
		"space",
		"gitsigns",
		"fold",
		"space",
	}

	for _, val in ipairs(order) do
		table.insert(str_table, parts[val])
	end

	return table.concat(str_table)
end
