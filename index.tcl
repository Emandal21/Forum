#
# Give information about the current setup
# (version numbers and paths)
#
catch {package require nsf::mongo} loaded(mongodb)
catch {package require nsf} loaded(nsf)
catch {package require nx} loaded(nx)

set content "
<pre>
Naviserver: [ns_info patchlevel]

Configuration:
pagedir:    [ns_server pagedir]
libdir:     [ns_server tcllib]

Current Script:
script:     [ns_server pagedir][ns_conn url]

Loaded Packages:
mongodb:    $loaded(mongodb)
nsf:        $loaded(nsf)
nx:         $loaded(nx)
</pre>
"

ns_return 200 text/html [ns_adp_parse -file forum.adp]
