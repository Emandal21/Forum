#
# List all "postings" of the Business Informer datamodel in the
# database tutorial.
#

set t0 [ns_time get]

::nx::mongo::db connect -db "tutorial"

set html ""
set timings "Timings: "

namespace eval ::forum {

  #
  # Check, if we have some postings:
  #
  if {[Posting count] > 0} {
    #
    # Build result object containing the instance variable :postings,
    # which is a list of objects
    #
    set result [nx::Object new {
      set :postings [Posting find all -orderby ts]
    }]
    # 
    # Set template for result, iterating over the postings with FOREACH
    #
    $result template set {
      <span style="display:inline-block;"><span style="font-size:20px;"> Postings</span> <span class="label label-primary">POPULAR</span> :</span> <ul><FOREACH var='p' in=':postings' type='list'><li>@p;obj@<p></li>
      </FOREACH></ul>
    }
    
    #
    # Obtain the rendered HTML output
    #
    set ::html [$result template eval]

    set total [ns_time diff [ns_time get] $::t0]
    append ::timings "[format %5.3f [expr {[ns_time format $total]*1000}]]ms "
    $result destroy
  }
}

set content $html

set ::_id ""
ns_return 200 text/html [ns_adp_parse -file forum.adp]

