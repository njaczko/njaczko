-- originURL = osExecute('git remote get-url origin')
-- local function osExecute(cmd)
--     local fileHandle     = assert(io.popen(cmd, 'r'))
--     local commandOutput  = assert(fileHandle:read('*a'))
--     -- local returnTable    = {fileHandle:close()}
--     -- return commandOutput,returnTable[3]            -- rc[3] contains returnCode
--     return commandOutput
-- end
cmd = 'git remote get-url origin'
-- this works, but commented out for testing
-- originURL  = io.popen(cmd, 'r'):read('*a')
originURL = 'git@github.com:njaczko/coins.git'
-- TODO check if ssh or https. will assume ssh for now.
-- TODO check command failed
originURL = originURL:gsub("git@github.com:", "https://github.com/")
originURL = originURL:gsub("%.git", "")
-- this works, but commented out for testing
-- os.execute('open "" "' .. originURL .. '"')
print(originURL)
