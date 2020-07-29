#
# Insert an intial posting into the "tutorial" database, in case it
# does not exist.
#
::nx::mongo::db connect -db "tutorial"
nx::mongo::db drop collection postings

namespace eval forum {
    set p [Posting new \
	       -ratings [list ] \
	       -title "Too Big to Fail" \
	       -author "John S." \
	       -body "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." \
	       -ts "05-Nov-09 10:33" \
	       -tags {finance economy} \
	       -comments [list \
			      [Comment new -author "Walter White" -comment "Great Article!" -voting 0] \
			      [Comment new -author "Joe Smith" -comment "But how fast is it?" -voting 0 \
				   -replies [list [Comment new -author "Jane Smith" -comment "scalable?" -voting 0]]] \
			     ]]
    #
    # We save the posting.  During this operation also the embedded
    # objects (the comments and replies) are saved together with the
    # posting in a compound document.
    #
    $p save
    
    # Destroy the nx object. This cleanup could be done automatically.
    $p destroy
}

ns_returnredirect list.tcl
