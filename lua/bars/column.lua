local statuscolumn = {};
local utils = require("bars/utils");
local ffi = require("ffi");

ffi.cdef([[
	typedef struct {} Error;
	typedef struct {} win_T;
	
	typedef struct {
		int start;
		int level;
		int llevel;
		int lines; // This one only works on closed folds
	} foldinfo_T;

	win_T *find_window_by_handle(int Window, Error *err);
	foldinfo_T fold_info(win_T* wp, int lnum);
]]);

statuscolumn.configuration = {
	default = {
		{
			type = "fold",
			add_clicks = true
		},
		{ type = "text", text = " " },
		{
			type = "number",
			mode = "hybrid",

			right_align = true,

			virtnum = "",
			virtnum_hl = "Title",

			hl = function ()
				if vim.v.relnum == 0 then
					return "%#Title#";
				end

				return "%#LineNr#"
			end
		},
		{ type = "text", text = " " },
		{
			type = "text",
			text = "▏",
			hl = function ()
				if vim.v.relnum <= 7 then
					return "%#Glow_" .. vim.v.relnum .. "#";
				end

				return "%#Glow_7#"
			end
		}
	},

	customs = {
		{
			filetypes = {},
			buftypes = {}
		}
	}
}

statuscolumn.render_text = function (config_table)
	local _o;

	if type(config_table.hl) == "string" then
		_o = utils.set_hl(config_table.hl);
	elseif type(config_table.hl) == "function" and pcall(config_table.hl) then
		_o = utils.set_hl(config_table.hl());
	else
		_o = "";
	end

	if type(config_table.text) == "string" then
		_o = _o .. config_table.text
	elseif type(config_table.text) == "function" and pcall(config_table.text) then
		_o = _o .. config_table.text();
	end

	return _o;
end

statuscolumn.render_number = function (buffer, config_table)
	local _o = vim.v.lnum;
	local max_num_len = vim.fn.strchars(vim.api.nvim_buf_line_count(buffer))

	if config_table.mode == "hybrid" then
		_o = tostring(vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum);
	elseif config_table.mode == "relative" then
		_o = tostring(vim.v.relnum);
	else
		_o = tostring(vim.v.lnum);
	end

	if vim.v.virtnum < 0 then
		_o = (type(config_table.virtnum_hl) == "string" and utils.set_hl(config_table.virtnum_hl) or "%#Comment#") .. (utils.text_out(config_table.virtnum) or _o);
	else
		_o = utils.set_hl(utils.text_out(config_table.hl)) .. _o;
	end

	return string.rep(" ", max_num_len - utils.get_len(_o)) .. _o;
end

statuscolumn.fold_clicks = function ()
	vim.print("Hi")
end

statuscolumn.render_folds = function (window, buffer, config_table)
	local handle = ffi.C.find_window_by_handle(window, nil);

	local next_line = utils.clamp(vim.v.lnum + 1, 1, vim.api.nvim_buf_line_count(buffer));

	local foldInfo_after = ffi.C.fold_info(handle, next_line);
	local foldInfo = ffi.C.fold_info(handle, vim.v.lnum);

	local parts = vim.tbl_extend("keep", config_table.parts or {}, {
		marker_open = { "" },
		marker_close = { "" },

		middle = { "│" },
		bottom = { "╰" },

		mix = { "┝" }
	});
	local hls = vim.tbl_extend("keep", config_table.hls or {}, {
		marker_open = { "rainbow1", "rainbow2", "rainbow3", "rainbow4", "rainbow5", "rainbow6" },
		marker_close = "FoldColumn",

		middle = { "rainbow1", "rainbow2", "rainbow3", "rainbow4", "rainbow5", "rainbow6" },
		bottom = { "rainbow1", "rainbow2", "rainbow3", "rainbow4", "rainbow5", "rainbow6" },

		mix = { "rainbow1", "rainbow2", "rainbow3", "rainbow4", "rainbow5", "rainbow6" }
	});

	local _f = " ";

	if foldInfo.start == vim.v.lnum then
		if vim.fn.foldclosed(vim.v.lnum) ~= -1 then
			_f = utils.set_hl(utils.format_input(hls.marker_open, foldInfo.level)) .. utils.format_input(parts.marker_open, foldInfo.level);
		else
			_f = utils.set_hl(utils.format_input(hls.marker_close, foldInfo.level)) .. utils.format_input(parts.marker_close, foldInfo.level);
		end

		if config_table.add_clicks == true then
			_f = "%@v:lua.bars_n_lines.handle_folds@" .. _f
		end
	elseif foldInfo.start ~= foldInfo_after.start and foldInfo.level >= foldInfo_after.level then
		if (foldInfo_after.level == 0 or (next_line == foldInfo_after.start and foldInfo_after.level <= vim.o.foldlevelstart)) and foldInfo.level >= foldInfo_after.level then
			_f = utils.set_hl(utils.format_input(hls.bottom, foldInfo.level)) .. utils.format_input(parts.bottom, foldInfo.level);
		else
			_f = utils.set_hl(utils.format_input(hls.mix, foldInfo.level)) .. utils.format_input(parts.mix, foldInfo.level);
		end
	elseif foldInfo.level > 0 then
		if next_line == vim.v.lnum then
			_f = utils.set_hl(utils.format_input(hls.bottom, foldInfo.level)) .. utils.format_input(parts.bottom, foldInfo.level);
		else
			_f = utils.set_hl(utils.format_input(hls.middle, foldInfo.level)) .. utils.format_input(parts.middle, foldInfo.level);
		end
	end

	return _f;
end

statuscolumn.draw = function (window, buffer)
	local conf = utils.find_config(statuscolumn.configuration, buffer);
	local _col = "";

	for _, part in ipairs(conf) do
		if part.type == "text" then
			_col = _col .. statuscolumn.render_text(part);
		elseif part.type == "number" then
			_col = _col .. statuscolumn.render_number(buffer, part);
		elseif part.type == "fold" then
			_col = _col .. statuscolumn.render_folds(window, buffer, part);
		end
	end

	return _col;
end

return statuscolumn;
