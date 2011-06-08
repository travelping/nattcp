#!/usr/bin/lua

local function printf(...) io.write(string.format(...)) end
local function errorf(...) error(string.format(...), 2) end

local function usage(r)
	printf(
[=[Runs a succession of nattcp UDP tests to determine the maximum UDP throughput.
Usage:
%s [options] server
options:
	-h		Print this help
	-D		Test downstream throughput (default)
	-U		Test upstream throughput
	-f <rate>	Rate in kbps to start with (default: 500)
	-t <rate>	Rate in kbps that will not be exceeded (default: 20000)
	-s <rate>	Rate in kbps to increase in each step (default: 50)
	-T <time>	Transmit time in seconds for each test (default: 10)
	--ssl		SSL authenticate nattcp client with cert.pem/key.pem (default)
	--no-ssl	Do not attempt to do any SSL authentication
The NATTCP environment variable specifies the nattcp binary to use (default: "nattcp").
]=], arg[0])
	os.exit(r or 1) -- unsuccessful by default
end

-- defaults
local binary = os.getenv("NATTCP") or "nattcp"
local downstream = true
local ssl_params = "--ssl"

local time = 10 -- seconds
local start_rate = 500 -- kbps
local limit_rate = 20000 -- kbps
local step_rate = 50 -- kbps

local host = arg[#arg] -- required
if #arg < 1 or host:sub(1, 1) == "-" then usage() end

-- parse command line
local i = 1
while i < #arg do
	if arg[i] == "-h" then usage(0)
	elseif arg[i] == "-D" then downstream = true
	elseif arg[i] == "-U" then downstream = false
	elseif arg[i] == "-f" then
		i = i + 1
		start_rate = tonumber(arg[i])
		if not start_rate or start_rate < 1 then usage() end
	elseif arg[i] == "-t" then
		i = i + 1
		limit_rate = tonumber(arg[i])
		if not limit_rate or limit_rate < 1 then usage() end
	elseif arg[i] == "-s" then
		i = i + 1
		step_rate = tonumber(arg[i])
		if not step_rate or step_rate < 1 then usage() end
	elseif arg[i] == "-T" then
		i = i + 1
		time = tonumber(arg[i])
		if not time or time < 1 then usage() end
	elseif arg[i] == "--ssl" then ssl_params = "--ssl"
	elseif arg[i] == "--no-ssl" then ssl_params = ""
	else
		usage()
	end
	i = i + 1
end
if start_rate > limit_rate then usage() end

local function test()
	local i = 1
	local prev_results = {rate_Mbps = 0}

	for rate = start_rate, limit_rate, step_rate do
		local cmd

		if downstream then
			cmd = string.format("%s -r -u -F -fparse -T%d -R%d %s %s", binary, time, rate, ssl_params, host)
		else
			cmd = string.format("%s -t -u -fparse -T%d -R%d %s %s", binary, time, rate, ssl_params, host)
		end

		printf("%d: executing: %s\n", i, cmd)

		local nattcp, msg = io.popen(cmd)
		if not nattcp then
			errorf("Cannot execute \"%s\": %s", binary, msg)
		end

		local out = nattcp:read("*a")
		nattcp:close()
		if not out or #out == 0 then
			errorf("Invalid results while executing \"%s\".", binary)
		end

		local results = {}
		for key, value in out:gmatch("([%w_]+)=([%d.]+)") do
			results[key] = tonumber(value)
		end
		if not results.rate_Mbps or
		   not results.data_loss then
			errorf("Invalid results while executing \"%s\": %s", binary, out)
		end

		printf("%d: rx rate = %fmbps, loss = %d%%\n", i,
		       results.rate_Mbps, results.data_loss)

		if results.rate_Mbps <= prev_results.rate_Mbps or
		   results.data_loss > 10.0 then
			printf("Receive rate does no longer increase or there are excessive drops.\n"..
			       "Best result was: %fmbps/%fkbps/%dkibits.\n",
			       prev_results.rate_Mbps,
			       prev_results.rate_Mbps*1000,
			       prev_results.rate_Mbps*1000*1000/1024)
			os.exit(0)
		end

		prev_results = results
		i = i + 1
	end
end

local status, msg = pcall(test)
if not status then
	printf("Aborted: %s\n", msg)
	os.exit(1)
end

printf("No peformance decrease detectable. Please rerun with limit > %dkbps.\n",
       limit_rate)

