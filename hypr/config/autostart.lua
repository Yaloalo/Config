hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c blackhole -n -d")
    hl.exec_cmd("hypridle")

    -- Local activity tracking, kept from the existing setup.
    hl.exec_cmd("/home/yaloalo/git/activewatcher/.venv/bin/activewatcher server --host 127.0.0.1 --port 8712")
    hl.exec_cmd("/home/yaloalo/git/activewatcher/.venv/bin/activewatcher watch hyprland --server-url http://127.0.0.1:8712")
    hl.exec_cmd("/home/yaloalo/git/activewatcher/.venv/bin/activewatcher watch idle --server-url http://127.0.0.1:8712 --threshold-seconds 120")
    hl.exec_cmd("/home/yaloalo/git/activewatcher/.venv/bin/activewatcher watch system --server-url http://127.0.0.1:8712 --poll-seconds 5.0")
    hl.exec_cmd("/home/yaloalo/git/activewatcher/.venv/bin/activewatcher watch battery --server-url http://127.0.0.1:8712 --poll-seconds 15.0")
end)
