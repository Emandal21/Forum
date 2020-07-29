# -*- Tcl -*-
########################################################################
#
#      oo-templating, an object oriented templating system based on
#      the Next Scripting Framework (NSF), developed originally for
#      courses in IS-engineering for the Master Program of Information
#      Systems at WU Vienna.
#
# Copyright (C) 2010-2018 Gustaf Neumann
#
# Vienna University of Economics and Business
# Institute of Information Systems and New Media
# A-1020, Welthandelsplatz 1
# Vienna, Austria
#
# This work is licensed under the MIT License http://www.opensource.org/licenses/MIT
#
# Copyright:
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# Usage of a template consists of two steps:
#
# 1) Compiling the template (can happen at load time, potentially in blueprint):
#    - replace pseudo variables (starting/ending with "@")
#    - localizing message keys the template (starting/ending with "#")
#    
# 2) Instantiating the template (has to happen with actual variables, per page)
#
# Furthermore, this library provides additional HTML tags, including
# tags for iterating and conditional inclusion (see details below)
#
#    <foreach>...</foreach>
#    <exists>...</exists>
#    <if>...</if>
#
#
#                                            fecit: Gustaf Neumann, December 2016
#


#ns_log notice "=== source oo-templating [info script]"
package require nsf

#
# Make sure, this file is not sourced twice, otherwise it would clean
# up the ::template namespace.
#
if {[info commands ::template::compile] ne ""} {
  return
}

namespace eval template {

  #
  # template::compile
  #
  # Compile a provided template with variables delimited with "@" signs
  # into a plain NaviServer/AOLserver .adp format. It supports
  #   - different types of variable references
  #      * @var@ filtered through a provided program (e.g. HTML sanitizer)
  #      * @var;literal@ take values as they are
  #      * @var;obj;name@ variables containing object names that
  #        should be rendereded with the provoded template name
  #      * @obj.var@ refer to a instance variable of the provied object (filtered)
  #      * @obj.var;literal@ refer to a instance variable of the provied object lterally
  #  - localization (between "#" signs)
  #
  nsf::proc compile {
    {-filter ""}
    {-localize_template _}
    {-localize_value ::lang::util::localize}
    {-formats ""}
    template
  } {
    # Escape "[", "]" and "\"
    regsub -all {(\[|\]|\\)} $template {\\\1} template

    # scalar with filter
    regsub -all {@([:a-zA-Z0-9_]+)@} $template \
        "\[compile_var -filter {$filter} -localize {$localize_value} -formats {$formats} \\1\]" template
    # scalar with literal
    regsub -all {@([:a-zA-Z0-9_]+);literal@} $template "\[compile_var \\1\]" template
    # scalar as obj with template name
    regsub -all {@([:a-zA-Z0-9_]+);obj(;([a-zA-Z_]*))?@} $template "\[compile_var_obj {\\3} \\1\]" template

    # composite accessor with filter
    regsub -all {@([:a-zA-Z0-9_]+).([:a-zA-Z0-9_]+)@} $template "\[compile_var2 -filter {$filter} -localize {$localize_value} \\1 \\2\]" template
    # composite accessor with literal
    regsub -all {@([:a-zA-Z0-9_]+).([:a-zA-Z0-9_]+);literal@} $template "\[compile_var2 \\1 \\2 \]" template
    #regsub -all {@([:a-zA-Z0-9_]+).([:a-zA-Z0-9_]+);obj(;([a-zA-Z]*))?@} $template "\[compile_var_obj \\3 \\1 \]" template

    if {$localize_template ne ""} {
      regsub -all {\#([a-zA-Z0-9_]+).([a-zA-Z0-9_]+)\#} $template "\[$localize_template \\1.\\2 \]" template
    }
    #regsub -all {{{([^<]+?)}}([&<\s]|$)} $template "\[::template::compile_include \"\\1\" \"\\2\" \]" template
    return [subst -novariable $template]
  }

  #
  # helper functions for template::compile
  #
  nsf::proc compile_var_ {
    {-filter ""}
    {-localize ""}
    {-formatfilter ""}
    value
  } {
    if {$formatfilter ne ""} {set value "\[$formatfilter $value\]"}
    if {$localize ne ""} {set value "\[$localize $value\]"}
    if {$filter   ne ""} {set value "\[$filter $value\]"}
    return "<%= $value %>"
  }

  nsf::proc compile_var_obj {
    {-filter ""}
    {-localize ""}
    template name
  } {
    #ns_log notice "compile_var_obj <$template> <$name>"
    if {$template eq ""} {set template default}
    compile_var_ -filter $filter -localize $localize "\[\${$name} template eval -name {$template}\]"
  }

  nsf::proc formatFilter {formats name} {
    if {[dict exists $formats $name]} {return [dict get $formats $name]}
    return ""
  }

  nsf::proc compile_var {{-filter ""} {-localize ""} {-formats ""} name} {
    compile_var_ -filter $filter -localize $localize -formatfilter [formatFilter $formats $name] \
        "\${$name}"
  }

  nsf::proc compile_var2 {{-filter ""} {-localize ""} {-formats ""} base name} {
    # TODO handle formats
    compile_var_ -filter $filter -localize $localize -formatfilter [formatFilter $formats $base.$name] \
        "\[get_value2 ${base} ${name}\]"
  }

  #nsf::proc compile_include {content char} {
  #  return "<%= $content %>$char"
  #}

  nsf::proc ::get_value2 {base name} {
    upvar $base x
    ns_log notice "get_value2 exists var $base exists [info exists x] base=$base, name=$name"
    if {![info exists x]} {return "NO SUCH VARIABLE $base"}
    #ns_log notice "exists var $base object <$x> [nsf::object::exists $x]"
    if {[nsf::object::exists $x]} {return [::nsf::var::set $x $name]}
    dict get $x $name
  }

  #
  # Register additional HTML tags
  #
  #  <foreach>...</foreach>
  #  <exists>...</exists>
  #  <if>...</if>
  #  <wiki:includelet>...</wiki:includelet>
  #  <wiki:link>...</wiki:link>

  ns_adp_registerscript foreach /foreach ::template::tag-foreach
  ns_adp_registerscript exists /exists ::template::tag-exists
  ns_adp_registerscript if /if ::template::tag-if

  ns_adp_registerscript wiki:includelet /wiki:includelet ::template::tag-wiki:includelet
  ns_adp_registerscript wiki:link /wiki:link ::template::tag-wiki:link

  #
  # sample usage <exists :matnr>@:matnr@</exists>
  #
  proc tag-exists {args} {
    #ns_log notice "tag-exists <$args>"
    lassign $args body set
    set __result ""
    set name [lindex [ns_set array $set] 0]
    #ns_log notice "tag-exists av_list [list info exists $name] // [uplevel [list info exists $name]]"
    if {[uplevel [list info exists $name]] && [uplevel [list info exists $name]]} {
      set __result [uplevel [list ns_adp_parse $body]]
      #set __result foo
    }
    return $__result
  }


  #
  # <foreach>
  #
  # iterate over different kind of objects
  #  - list
  #  - ordered composite
  #  - ns_set
  #  - dict (not jet implemented)
  #  - multirow (not jet implemented)

  proc tag-foreach {body set} {
    set av_list [ns_set array $set]
    array set __options {type list} ;# default
    #ns_log notice "options = [ns_set array $set]"

    array set __options [ns_set array $set]
    if {![info exists __options(var)]} {return "ERROR: no variable specified for MULTIPLE"}
    set __result ""
    switch -- $__options(type) {
      list {
        upvar $__options(in) __source
        if {[info exists __source]} {
          foreach $__options(var) $__source {append __result [ns_adp_parse $body]}
        }
      }
      ns_set {
        upvar $__options(in) __source
        for {set __i 0} {$__i < [ns_set size $__source]} {incr __i} {
          set [ns_set key $__source $__i] [ns_set value $__source $__i]
          lassign [list [ns_set key $__source $__i] [ns_set value $__source $__i]] {*}$__options(var)
          append __result [ns_adp_parse $body]
        }
      }
      ordered_composite {
        upvar $__options(in) __source
        set __result "$__options(in) [info exists __source] $__source b=$body"
        foreach $__options(var) [$__source children] {append __result [ns_adp_parse $body]}
      }
    }
    return $__result
  }

  #
  # Sample usage: <wiki:includelet>NewsItem -max 7</wiki:includelet>
  #
  proc tag-wiki:includelet {body set} {
    ns_log notice "tag-wiki:includelet <$body> $set"
    set words [split $body " "]
    set cmd [lindex $words 0]
    if {[nsf::is object $cmd] && [$cmd info object method exists includelet]} {
      return [$cmd includelet {*}[lrange $words 1 end]]
    }
    return ""
  }

  #
  # Sample usage: <wiki:link>NewsItem -max 7</wiki:link>
  #
  proc tag-wiki:link {body set} {
    #ns_log notice "tag-wiki:link <$body> $set"
    set label [ns_set get $set title $body]
    if {[string match "*://*" $body]} {
      set classInfo "class='external'"
    } elseif {[string match img:* $body]} {
      regexp {img:(.*)$} $body _ src
      set styles ""
      foreach {opt value} [ns_set get $set options] {
        if {$opt eq "-float"} {append styles "[string range $opt 1 end]: $value\;"}
      }
      if {$styles ne ""} {set styles "style='$styles'"}
      return "<img class='image' title='$label' alt='$src' src='$src' $styles/>"
      set classInfo "img"
    } else {
      set classInfo ""
    }
    return "<a $classInfo href='$body'>$label</a>"
  }

  #
  # <if ...>
  #
  # Call method and test result, variables as arguments between % signs:
  #  -  <if method-true='...'>
  #  -  <if method-false='...'>
  #
  # Variable tests (just write variable names)
  #  - <if empty=''>
  #  - <if non-empty=''>
  #  - <if true=''>
  #  - <if false=''>
  #
  # Low-level interface (write plain tcl syntax expression)
  #  - <if expr=''>
  #

  proc percent-var-translate {string} {
    regsub -all {%([a-zA-Z0-9_:]+)%} $string {$\1} string
    return $string
  }

  proc tag-if {body set} {
    set args [ns_set array $set]
    if {[dict exists $args method-true]} {
      set call [percent-var-translate [dict get $args method-true]]
      dict set args expr "\[$call\]"
    } elseif [dict exists $args method-false] {
      set call [percent-var-translate [dict get $args method-false]]
      dict set args expr "!\[$call\]"
    } elseif [dict exists $args empty] {
      dict set args expr "\${[dict get $args empty]} eq {}"
    } elseif [dict exists $args non-empty] {
      dict set args expr "\${[dict get $args non-empty]} ne {}"
    } elseif [dict exists $args true] {
      dict set args expr "\${[dict get $args true]}"
    } elseif [dict exists $args false] {
      dict set args expr "!\${[dict get $args false]}"
    }
    if {[dict exists $args expr]} {
      set expr [dict get $args expr]
      #ns_log notice "if-statement expr <$expr> dict <$args>"
      if {[uplevel [list expr $expr]]} {
        return [uplevel [list ns_adp_parse $body]]
      }
    }
  }

  nsf::proc compile_adp_file {
    {-path ""}
    {-formats ""}    
    fn
  } {
    #
    # Compile a an adp file with the adp compiler template::compile.
    #    
    if {$path eq ""} {
      set path [file join {*}[lrange [file split [ns_conn url]] 0 end-1]]
    }
    set fn [ns_url2file $path/$fn]
    set f [open $fn]; set string [read $f]; close $f
    set compiled [template::compile \
                      -localize_value "" \
                      -filter ns_quotehtml \
                      -formats $formats \
                      $string]
    #ns_log notice compiled=$compiled
    return $compiled
  }

  
  nsf::proc load_tcl_file {} {
    #
    # Load same-named tcl file
    #
    set fn [file root [ns_url2file [ns_conn url]]].tcl
    if {[file exists $fn]} {
      #ns_log notice "load_tcl_file: load '$fn'"
      uplevel [list source $fn]
    } else {
      ns_log warning "load_tcl_file: can't read file '$fn'"
    }
  }


}

########################################################################
# Interface for named forms
########################################################################

namespace eval ::oo-template {
  nx::Class create Forms {
    #
    # Registry for template code snippets (e.g. forms, dialogs, ...),
    # especially to ease dialog generation
    #

    :public method "modal get" {
      name
      {-title ""}
      {-glyphicon plus-sign}
      {-context ""}
      {-what ""}
      {-action "validate"}
      {-href ""}
      {-user ""}
    } {
      # Get a (Bootstrap) modal by name from the previously added
      # modals (added via "modal add"). The remaining attributes are
      # used to individualize the template for certain
      # occurrences). Instance data will be provided are runtime,
      # referenced via @vars@.
      #
      # The bootstrap modal needs for every rendering a unique ID for
      # linkage between the button/anchhor and the modal div. We use
      # here the (for the time being globally variable) "::_ms"
      # containing the microseconds, which is set by template
      # eval. The leading "$name" ist just used to improve human
      # trability when debugging the code.
      #
      set id "$name-@::_ms@"
      set form   [subst [set :modal-$name]]
      set button [subst {<a href="#$id" title="$title" role="button" data-toggle="modal">
        <span class="glyphicon glyphicon-$glyphicon" aria-hidden="true"></span></a>}]
      return "$button $form"
    }

    :public method "modal add" {name form} {
      set :modal-$name $form
    }

    :public method add {name form} {
      set :form-$name $form
    }
    :public method "get" {
      name
      {-title ""}
      {-context ""}
      {-what ""}
      {-href ""}
      {-action "validate"}
      {-id ""}
    } {
      if {$id eq ""} {
        set id $name
      }
      return [subst [set :form-$name]]
    }

  }
}


########################################################################
# Interface for setting/getting class or object specific templates.
########################################################################

::nsf::method::alias nx::Object ns_adp_parse ::ns_adp_parse

nx::Object public method "template set" {{-name default} {-formats ""} {-include ""} string} {
  set :__template_head($name) ""
  foreach file $include {
    if {[string match *.js $file]} {
      append :__template_head($name) [subst {<script type="text/javascript" src="$file" language="javascript"></script>}] \n
    } elseif {[string match *.css $file]} {
      append :__template_head($name) [subst {<link rel="stylesheet" href="$file" type="text/css" media="all">}] \n
    }
  }
  set :__template($name) [template::compile \
                              -localize_value "" \
                              -filter ns_quotehtml \
                              -formats $formats \
                              $string]
}

nx::Object public method "template get" {{-name "default"}} {
  if {[info exists :__template($name)]} {
    append ::__template__head [set :__template_head($name)] \n
    return [set :__template($name)]
  }
  return ""
}

nx::Object public method "template iterate" {method {-name "default"}} {
  set v [:template $method -name $name]
  if {$v ne ""} {
    #
    # we have a direct template
    #
    return $v
  }
  #
  # look for template in the class hierarchy
  #
  foreach cl [:info precedence] {
    set v [$cl template $method -name $name]
    if {$v ne ""} {break}
  }
  return $v
}

nx::Object public method "template eval" {{-name "default"} {template ""}} {
  set ::_ms [clock microseconds]
  #ns_log notice "template eval [self] [:info class] name $name template $template ms $::_ms"
  if {$template ne ""} {
    #ns_log notice "template::compile <template::compile> --> [template::compile -localize_value {} $template]"
    return [:ns_adp_parse [template::compile -localize_value "" $template]>]
  }
  set template [:template iterate get -name $name]

  set result [:ns_adp_parse -string $template]
  return $result
}

::Serializer exportMethods {
  ::nx::Object method "ns_adp_parse"
  ::nx::Object method "template eval"
  ::nx::Object method "template get"
  ::nx::Object method "template iterate"
  ::nx::Object method "template set"
}



return


########################################################################
# some test cases
########################################################################
proc f {value} {return /$value/}
::nsf::method::alias nx::Object ns_adp_parse ::ns_adp_parse
nx::Object create o {
  set :x "this is x";
  set :y 2
  #set :oc [::xowiki::Object instantiate_objects -sql {select * from acs_objects order by 1 limit 10}]
}
nx::Object create o2 {
  set :x "this is o2";
  set :y 4711
}

set c(0) {
  x = <%=$x%>
  :x = <%= [f ${:x}] %>
}
set t(1) {<% set somelist {1 a 2 b 3 c} %>
  #xowiki.title#
  x = @:x@          ... instance variable
  y = @:y;literal@ .... instance variable
  <FOREACH var='a b' in='somelist' type='list'>key = @a@, value = @b@
  </FOREACH>
}

set t(1) {<% set headers [ns_conn headers] %>
  #xowiki.title#
  x = @:x@          ... instance variable
  y = @:y;literal@ .... instance variable
  <FOREACH var='tag value' in='headers' type='ns_set'>tag = @tag@, value = @value@
  </FOREACH>
}

set t(1) {<% set o2 ::o2; set x 456; set d [dict create name gustaf sex male] %>
  #xowiki.title#
  x = @x@  local variable
  y = @:y;literal@ .... instance variable of current object
  o2.x = @o2.x@ .... attrib x of object o2
  name @d.name@ sex @d.sex@
  <FOREACH var='o' in=':oc' type='ordered_composite'>object_id = @o.object_id@ @o.title@ @o.object_type@
  </FOREACH>
}

set i(1) {
  <% set o2 ::o2; set x 456; set d [dict create name gustaf sex male] %>
  x = @x@  local variable
  y = @:y;literal@ .... instance variable of current object
  o2.x = @o2.x@ .... attrib x of object o2
  name @d.name@ sex @d.sex@
  <if expr='$x eq 456'>
  yes
  </if>
}

o template set $i(1)
ns_log notice ===eval====[o template eval]

#set compiled_template [template::compile -localize_template "" -localize_value "" $i(1)]
#ns_log notice ===compile====$compiled_template
#ns_log notice ====parse===[o ns_adp_parse $compiled_template]

#
# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
