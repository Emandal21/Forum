#
# Show the status of the mongo db classes for debugging purposes
#
::nx::mongo::db connect -db "tutorial"

set content "
<pre>
Current Script:
script:     [ns_server pagedir][ns_conn url]

[forum::classes]
</pre>
"

ns_return 200 text/html [ns_adp_parse -file forum.adp]
