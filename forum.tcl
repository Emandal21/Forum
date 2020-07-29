package require nx::mongo

#
# Make sure to load oo-templating before this file.
#
if {[info command ::compile_template] eq ""} {source [file dirname [info script]]/oo-templating.tcl}

######################################################################
# Create the application classes based on the "Business Insider" data
# model. See e.g.
# http://www.slideshare.net/mongodb/nosql-the-shift-to-a-nonrelational-world
#
# The classes are kept in the namespace "forum" for better locality.  The
# created classes have a "forum::" prefix; they can be either adressed by
# their fully qualified names or inside a "namespace eval ::forum {...}"
# statement.
#
# This file contains as well the navigation structures for the "forum"
# application and the necessary templates for viewing with and without
# edit-controls.

::nx::mongo::db connect -db "tutorial"
#nx::mongo::db drop collection postings
#? {::nx::mongo::db collection tutorial.persons} "mongoc_collection_t:0"


namespace eval forum {
  #
  # The instances of the class "Comment" are embedded in a posting
  # (property "comments") as well as in an comment itself (property
  # "replies"). All comments are in this example multivalued and
  # incremental (i.e. one can use slot methods "... add ...").
  #

  nx::mongo::Class create User {
    :property name:reqired
    :property password:required

    :public method getPassword {} {
	return :password
    }
  }

  nx::mongo::Class create Comment {
    :property author:required
    :property comment:required 
    :property {voting:integer 0} ;# votings
    :property -incremental replies:embedded,type=::forum::Comment,0..n

    :public method increaseVoting {} {
	set :voting [expr {${:voting} + 1}]
    }

    :public method decreaseVoting {} {
	set :voting [expr {${:voting} - 1}]
    }
  }
    
  nx::mongo::Class create Posting {
    :index tags
    :property title:required
    :property author:required
    :property body:required
    :property ts:required
    :property -incremental comments:embedded,type=::forum::Comment,0..n
    :property -incremental {tags:0..n ""}
    :property -incremental {ratings:integer,0..n} ;# list of all ratings
    :property {rating:integer} ;# average rating
    
    #
    # setting new title
    #

    :public method setTitle {t} {
	set :title $t
    }

    :public method setBody {b} {
	set :body $b
    }

    :method init {} {
	set n 0
        set result 0
	foreach r ${:ratings} {
	  incr n
	  set result [expr { $result + $r}]
	}
	if {$n == 0} { 
	    set :rating 0 
	} else { 
	    set :rating [expr {$result / $n}]
	}
    }
    
    #
    # When we add rating to :ratings this method will compute average rating and
    # set :rating variable to that value
    #
    :public method setAvgRating {} {
	set n 0
        set result 0
	foreach r ${:ratings} {
	  incr n
	  set result [expr { $result + $r}]
	}
	if {$n == 0} { 
	    set :rating 0 
	} else { 
	    set :rating [expr {$result / $n}]
	}
     }
    
     
  }

  #
  # Helper procs for introspection/debugging
  #

  proc classes {} {
    set classInfo "MongoDB Classes:\n"
    foreach cl [lsort [nx::mongo::Class info instances]] {
      append classInfo [subst {
	class $cl
	  variables:       [$cl pretty_variables]
	instances in db: [$cl count]
	}]
    }
    return $classInfo
  }

  #
  # Interface for adding modal dialogs
  # (based on oo-template forms)
  #
  nsf::proc add-modal {
      what
      {-context ""}
      {-glyphicon plus-sign}
      {-action "add"}
      {-title ""}
      {-user ""}	
  } {
      if {$title eq ""} {
	  set title "$action $what"
      }
      append HTML \
	  [forms modal get $what \
	  -title $title \
	  -glyphicon $glyphicon \
	  -context $context \
	  -what $what \
	  -user $user \
	  -action $action \
	  -href actions.tcl
	  ] \n
      return $HTML
  }

  nsf::proc readmodal {name} {
      set fn [ns_info home]/modules/$name
      set F [open $fn]; set content [read $F]; close $F
      return $content
  }

  #
  # Create an instance of the oo-templating Forms manager
  # named "forms"
  #
  ::oo-template::Forms create forms

  #
  # Create modal forms named "tag", "comment", ...
  #
  forms modal add tag     [readmodal forum/modal-tag.adp]
  forms modal add comment [readmodal forum/modal-comment.adp]
  forms modal add reply   [readmodal forum/modal-reply.adp]
  forms modal add posting [readmodal forum/modal-posting.adp]
  forms modal add user    [readmodal forum/modal-user.adp]
  forms modal add newTitle   [readmodal forum/modal-title.adp]

  #
  # Proc for voting
  #
  proc add-vote {what {context ""}} {
    #puts stderr "add-field $what $context"
    if {$what == "upvote"} {
        return [subst {<a title="add $what" 
          href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span></a>}]
   } else {
        return [subst {<a title="add $what" 
          href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-thumbs-down" aria-hidden="true"></span></a>}]
   }
  }
 
  #
  # Procs for rating
  #
  proc add-rate1 {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what" 
      href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>}]
  }

  proc add-rate2 {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what" 
      href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>}]
  }

  proc add-rate3 {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what" 
      href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>}]
  }

  proc add-rate4 {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what" 
      href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>}]
  }

  proc add-rate5 {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what" 
      href='actions.tcl?__what=$what&__id=@::_id@&__context=$context'><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>}]
  }

  #
  # default templates
  #

  ns_log notice [Posting template set {
    @:ts@: <span  style="font-size: 18px;"><b>@:author@</b> posts: <em>@:title@</em> (Rating: <b>@:rating@</b>)<br></span>
    @:body@
    <ul><FOREACH var='c' in=':comments' type='list'><li>@c;obj@</li>
    </FOREACH></ul>
    <b style="color:red;">TAGS: @:tags@</b><br>
  }]

  Comment template set {
    <b>@:author@</b> comments: <em>'@:comment@'</em> (Votes: <b>@:voting@</b>)
    <ul><FOREACH var='r' in=':replies' type='list'><li>reply: @r;obj@</li></FOREACH></ul>
  }

  #
  # edit templates
  #    
  Posting template set -name edit [subst {
    <% set ::_id \[set :_id\] %>
   [add-modal newTitle -glyphicon pencil] @:ts@: <span  style="font-size: 18px;"><b>@:author@</b> posts: <em>@:title@</em> [add-rate1 rate1] [add-rate2 rate2] [add-rate3 rate3] [add-rate4 rate4] [add-rate5 rate5] (<b>@:rating@</b>) [add-modal comment -glyphicon comment]<br></span>
    @:body@
    <ul><FOREACH var='c' in=':comments' type='list'><li>@c;obj;edit@</li>
    </FOREACH></ul>
    <b style="color:red;">TAGS: @:tags@</b>[add-modal tag -glyphicon tags]<br>
  }]

  Comment template set -name edit [subst {
    <b>@:author@</b> comments: <em>'@:comment@'</em> (<b>@:voting@</b>) [add-vote upvote @:author@-@:comment@] [add-vote downvote @:author@-@:comment@]
    [add-modal reply -glyphicon share -context @:author@-@:comment@]
    <ul><FOREACH var='r' in=':replies' type='list'><li>reply: @r;obj;edit@</li></FOREACH></ul>
  }]

 
}
