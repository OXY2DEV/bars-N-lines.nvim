local tabline = {};
local devicons = require("nvim-web-devicons");
local utils = require("bars/utils");

tabline.bufs = {};
_G.__tabline_click_handlers = {}

tabline.configuration = {
	parts = {
		{
			type = "bufs",
			max_cols = vim.o.columns - 25,

			active = {
				corner_left = "", corner_left_hl = "tabline_buf_active",
				corner_right = "", corner_right_hl = "tabline_buf_active",

				padding_left = " ", padding_left_hl = "tabline_buf_active_alt",
				padding_right = " ",
			},
			inactive = {
				corner_left = "", corner_left_hl = "tabline_buf_inactive",
				corner_right = "", corner_right_hl = "tabline_buf_inactive",

				padding_left = " ", padding_left_hl = "tabline_buf_inactive_alt",
				padding_right = " ",
			}
		},
		{ type = "raw", text = "%=" },
		{
			type = "tabs",
			max_cols = 25,

			active = {
				corner_left = "", corner_left_hl = "tabline_tab_active",
				corner_right = "", corner_right_hl = "tabline_tab_active",

				padding_left = " ", padding_left_hl = "tabline_tab_active_alt",
				padding_right = " ",
			},
			inactive = {
				corner_left = "", corner_left_hl = "tabline_tab_inactive",
				corner_right = "", corner_right_hl = "tabline_tab_inactive",

				padding_left = " ", padding_left_hl = "tabline_tab_inactive_alt",
				padding_right = " ",
			}
		}
	},

	max_entries = 5,
	skip_buftypes = { "nofile" },
	skip_filetypes = { "noice" },
}

tabline.sort_bufs = function (bufs, max)
	local sorted = {};

	for _, buf in ipairs(bufs) do
		if  #bufs >= (max or 5) and vim.api.nvim_get_current_buf() == buf then
			table.insert(sorted, 1, {
				bufnr = buf,
				is_active = true,
				bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t"),
			});
		elseif vim.api.nvim_get_current_buf() == buf then
			table.insert(sorted, {
				bufnr = buf,
				is_active = true,
				bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t"),
			});
		elseif vim.api.nvim_buf_is_valid(buf) then
			table.insert(sorted, {
				bufnr = buf,
				is_active = false,
				bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
			});
		end
	end

	return sorted;
end

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	callback = function (event)
		if vim.api.nvim_buf_is_valid(event.buf) and not vim.list_contains(tabline.bufs, event.buf) then
			if vim.list_contains(tabline.configuration.skip_filetypes, vim.bo[event.buf].filetype) then
				return
			end

			if vim.list_contains(tabline.configuration.skip_buftypes, vim.bo[event.buf].buftype) then
				return
			end

			table.insert(tabline.bufs, event.buf);

			_G.__tabline_click_handlers["buf_" .. event.buf] = function ()
				utils.switch_to_buf(event.buf)
			end
		end
	end
})

tabline.render_bufs = function (config_table)
	local sorted_bufs = tabline.sort_bufs(tabline.bufs, config_table.max_entries)
	local _t = {};

	for _, buf	in ipairs(sorted_bufs) do
		local icon, _ = devicons.get_icon(buf.bufname);

		if buf.is_active == true then
			table.insert(_t, vim.tbl_extend("force", config_table.active or {}, {
				icon = icon,
				text = " " .. buf.bufname,

				before = "%@v:lua.__tabline_click_handlers.buf_" .. buf.bufnr .. "@",
				after = "%X"
			}))
		else
			table.insert(_t, vim.tbl_extend("force", config_table.inactive or {}, {
				icon = icon,
				text = " " .. buf.bufname,

				before = "%@v:lua.__tabline_click_handlers.buf_" .. buf.bufnr .. "@",
				after = "%X"
			}))
		end
	end

	return utils.create_truncated_segmants(_t, config_table.max_cols or 60)
end

tabline.render_tabs = function (config_table)
	local tabs = vim.api.nvim_list_tabpages();
	local _t = {};

	for label, tab in ipairs(tabs) do
		if tab == vim.api.nvim_get_current_tabpage() then
			table.insert(_t, vim.tbl_extend("force", config_table.active or {}, {
				before = "%" .. label .. "T",
				text = tostring(tab),
				after = "%X"
			}));
		else
			table.insert(_t, vim.tbl_extend("force", config_table.inactive or {}, {
				before = "%" .. label .. "T",
				text = tostring(tab),
				after = "%X"
			}));
		end
	end

	return utils.create_truncated_segmants(_t, config_table.max_cols or 60)
end

tabline.draw = function ()
	local _o = "";

	for _, part in ipairs(tabline.configuration.parts) do
		if part.type == "bufs" then
			_o = _o .. tabline.render_bufs(part);
		elseif part.type == "tabs" then
			_o = _o .. tabline.render_tabs(part);
		elseif part.type == "raw" then
			_o = _o .. (part.text or "");
		end
	end

	return _o;
end

tabline.init = function ()
	vim.o.tabline = "%!v:lua.require('bars/tabs').draw()";
end

tabline.disable = function ()
	vim.g.tabline = "";
end

return tabline;
