#
# List all "postings" of the forum datamodel in the
# database "tutorial" and allow edit operations. Furthermore, perform
# mode detailed timings and report the results.
#

set t0 [ns_time get]
set t(setup)   [ns_time diff $t0 [ns_conn start]]

::nx::mongo::db connect -db "tutorial"
set t(connect) [ns_time diff [ns_time get] $t0]

set html ""
set timings "Timings: "

namespace eval ::forum {

  set t1 [ns_time get]

  if {[Posting count] > 0} {

    set ::t(count) [ns_time diff [ns_time get] $t1]

    set t1 [ns_time get]
    set result [nx::Object new {set :postings [Posting find all -orderby ts]}]
    set ::t(findall) [ns_time diff [ns_time get] $t1]

    #
    # Use the "edit" template for @p...@
    #
    $result template set {
      <span style="display:inline-block;"><span style="font-size:20px;"> Postings</span> <span class="label label-primary">POPULAR</span> :</span> <ul><FOREACH var='p' in=':postings' type='list'><li>@p;obj;edit@<p></li>
      </FOREACH></ul>
    }

    set t1 [ns_time get]
    set ::html [$result template eval]
    set ::t(template) [ns_time diff [ns_time get] $t1]
    set ::t(total)    [ns_time diff [ns_time get] $::t0]
    
    foreach cp {setup connect count findall template total} {
      append ::timings "$cp [format %5.3f [expr {[ns_time format $::t($cp)]*1000}]]ms "
    }
    $result destroy
  }
}

set content $html

#
# Provide posting object for the modal "new" 
#
set p [forum::Posting new -title "" -author "" -body "" -ratings [list ] \
	   -ts [clock format [clock seconds] -format "%d-%b-%y %H:%M"]]
$p template set [forum::add-modal posting -action new]

set ::_id ""
ns_return 200 text/html [ns_adp_parse -file forum.adp]
$p destroy
