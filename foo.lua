local function OpenGithub()
  local function exec(cmd)
    -- TODO improve leading + trailing whitespace stripping
    -- TODO check cmd's status code
    return io.popen(cmd, 'r'):read('*a'):gsub('\n', '')
  end

  -- TODO check if ssh or https. will assume ssh for now.
  originURL  = exec('git remote get-url origin'):gsub("git@github.com:", "https://github.com/"):gsub("%.git", "")
  defaultBranch = exec("git remote show origin | sed -n '/HEAD branch/s/.*: //p'")
  pathInRepo = exec(string.format("git ls-files --full-name %s", vim.fn.expand('%')))
  currentLineNum = unpack(vim.api.nvim_win_get_cursor(0))
  githubURL = string.format("%s/blob/%s/%s#L%s", originURL, defaultBranch, pathInRepo, currentLineNum)
  exec(string.format('open "%s"', githubURL))
end


-- This is all we need to add to the vimrc:
-- lua << EOF
-- function openGithub()
--   local function exec(cmd)
--     -- TODO improve leading + trailing whitespace stripping
--     -- TODO check cmd's status code
--     return io.popen(cmd, 'r'):read('*a'):gsub('\n', '')
--   end
--
--   -- TODO check if ssh or https. will assume ssh for now.
--   originURL  = exec('git remote get-url origin'):gsub("git@github.com:", "https://github.com/"):gsub("%.git", "")
--   defaultBranch = exec("git remote show origin | sed -n '/HEAD branch/s/.*: //p'")
--   pathInRepo = exec(string.format("git ls-files --full-name %s", vim.fn.expand('%')))
--   currentLineNum = unpack(vim.api.nvim_win_get_cursor(0))
--   githubURL = string.format("%s/blob/%s/%s#L%s", originURL, defaultBranch, pathInRepo, currentLineNum)
--   exec(string.format('open "%s"', githubURL))
-- end
-- EOF
--
-- command OpenGithub lua openGithub()
--
