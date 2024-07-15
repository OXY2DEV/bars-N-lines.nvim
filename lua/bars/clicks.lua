local clicks = {};

clicks.handle_folds = function ()
	local Y = vim.api.nvim_win_get_cursor(0)[1];

	if vim.fn.foldclosed(Y) ~= -1 then
		vim.cmd("foldopen");
	else
		vim.cmd("foldclose");
	end
end

clicks.switch_display_mode = function ()
	if _G.bars_display_mode < 5 then
		_G.bars_display_mode = _G.bars_display_mode + 1;
	else
		_G.bars_display_mode = 1;
	end

	vim.cmd("redraws");
	vim.cmd("Beacon");
end

return clicks;
