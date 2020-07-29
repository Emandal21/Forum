::nx::mongo::db connect -db "tutorial"

#
# All edit operations from the forum are implemented via
# this file.  Since we want to add content to arbitrary positions in
# the posting tree, we have to pass a "context" that points to the
# right entry, to the edit-operation and we have to evaluate this when
# the form is submitted. 
#
# The submitted form is distinguished from the prompt (here the empty
# form, but it can/should be extended to provide the default values)
# via the hidden form field "__action", which is set to
# e.g. "validate". For now, we perform no validation here.

namespace eval ::forum {

    set ::style {
	<style> .label {
	    float: left;
	    text-align: right;
	    display: block;
	    width: 7em;
	}</style>
    }


    #
    # Return a simple edit form built from the provided arguments. 
    #
    proc posting-form {id what fields {context ""}} {
	if {$id eq ""} {ns_returnerror 400 "id missing"}
	set p [Posting find first -cond [list _id = $id]]
	foreach {label field size} $fields {
	    append entries "<span class='label'>$label:</span> <input type='text' name='$field' size='$size' required> <br>\n"
	}
	ns_return 200 text/html [subst {
	    $::style
	    <form method='post' action='new.tcl'>
	    Adding $what to posting: <em>[$p cget -title]</em><br>
	    <input type='hidden' name='__id' value='$id'>
	    <input type='hidden' name='__what' value='$what'>
	    <input type='hidden' name='__action' value='validate'>
	    <input type='hidden' name='__context' value='$context'>
	    $entries
	    <input type='submit'>
	    </form>
	}]
    }

    #
    # Locate the context with the posting structure and retrun the
    # corresponding object.
    #
    proc find-context {objs ctx} {
	foreach obj $objs {
	    set ctx0 "[nsf::var::set $obj author]-[nsf::var::set $obj comment]"
	    if {$ctx0 eq $ctx} {return $obj}
	    if {[nsf::var::exists $obj replies]} {
		set r0 [find-context [nsf::var::set $obj replies] $ctx]
		if {$r0 ne ""} {return $r0}
	    }
	}
	return ""
    }

    set id     [ns_queryget __id]
    set what   [ns_queryget __what "posting"]
    set action [ns_queryget __action]
    set user   [ns_queryget user]

    switch $what {

	posting {
	    set p [Posting new \
		       -title [ns_queryget title] \
		       -author $user \
		       -body [ns_queryget body] \
		       -ratings [list ] \
		       -ts [clock format [clock seconds] -format "%d-%b-%y %H:%M"]]
	    $p save
	    ns_returnredirect edit.tcl
	}

	tag {
	    set p [Posting find first -cond [list _id = $id]]
	    $p tags add [ns_queryget tag] end
	    $p save
	    ns_returnredirect edit.tcl
	}

	comment {
	    set p [Posting find first -cond [list _id = $id]]
	    $p comments add [Comment new \
				 -author [ns_queryget author] \
				 -comment [ns_queryget comment]] end
	    $p save
	    ns_returnredirect edit.tcl
	}

	reply {
	    set p [Posting find first -cond [list _id = $id]]
	    set reply [Comment new \
			   -author [ns_queryget author] \
			   -comment [ns_queryget reply]]
	    set obj [find-context [$p cget -comments] [ns_queryget __context]]
	    if {$obj ne ""} {
		ns_log notice "!!! adding reply to $obj of $p"
		$obj replies add $reply end
		$p save
	    } else {
		ns_log error "!!! could not find referenced context for object: $id"		
	    }
	    ns_returnredirect edit.tcl
	}

	#
	# Upvoting
	#
	upvote {
	    set p [Posting find first -cond [list _id = $id]]
	    set obj [find-context [$p cget -comments] [ns_queryget __context]]
	    if {$obj ne ""} {
		ns_log notice "!!! upvoting $obj of $p"
	        $obj increaseVoting
	        $p save
	    } else {
		ns_log error "!!! could not find referenced context for object: $id"		
	    }
	    ns_returnredirect edit.tcl
	}

	#
	# Downvoting
	#
	downvote {
	    set p [Posting find first -cond [list _id = $id]]
	    set obj [find-context [$p cget -comments] [ns_queryget __context]]
	    if {$obj ne ""} {
		ns_log notice "!!! downvoting $obj of $p"
	        $obj decreaseVoting
	        $p save
	    } else {
		ns_log error "!!! could not find referenced context for object: $id"		
	    }
	    ns_returnredirect edit.tcl
	}

	#
	# Rating
	#
	rate1 {
	    set p [Posting find first -cond [list _id = $id]]
	    $p ratings add 1 end
	    $p setAvgRating
	    $p save
	    ns_returnredirect edit.tcl
	}

	rate2 {
	    set p [Posting find first -cond [list _id = $id]]
	    $p ratings add 2 end
	    $p setAvgRating
	    $p save
	    ns_returnredirect edit.tcl
	}

	rate3 {
	    set p [Posting find first -cond [list _id = $id]]
	    $p ratings add 3 end
	    $p setAvgRating
	    $p save
	    ns_returnredirect edit.tcl
	}

	rate4 {
	    set p [Posting find first -cond [list _id = $id]]
	    $p ratings add 4 end
	    $p setAvgRating
	    $p save
	    ns_returnredirect edit.tcl
	}

	rate5 {
	    set p [Posting find first -cond [list _id = $id]]
	    $p ratings add 5 end
	    $p setAvgRating
	    $p save
	    ns_returnredirect edit.tcl
	}

	#
	# Editing post title and content
	#
	newTitle {
	    set p [Posting find first -cond [list _id = $id]]
	    $p setTitle [ns_queryget newTitle]
	    $p setBody [ns_queryget newBody]
	    $p save
	    ns_returnredirect edit.tcl
	}

        logIn {
            ns_setcookie user $user

            ns_returnredirect edit.tcl
        }

        logOut {
           ns_deletecookie user
           ns_returnredirect list.tcl
        }
    }
}

