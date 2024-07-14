local clicks = {};

clicks.handle_folds = function ()
	local Y = vim.api.nvim_win_get_cursor(0)[1];

	-- if vim.fn.foldclosed(Y) ~= -1 then
	-- 	vim.cmd("foldopen");
	-- else
	-- 	vim.cmd("foldclose");
	-- end
end

return clicks;
