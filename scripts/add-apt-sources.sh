#!/usr/bin/env bash
set -eu
awk -v target_components="main contrib non-free" '
{ source_found = 0; }
(/^ *deb(-src)? +(\[( +[^=]+=[^ ]+)+ +\] +)?[^ [][^ ]* +[^ ]+( +[^ ]+)* *(#.*)?$/) {
  source_found = 1;
  i = 1;
  type = $1; ++i;
  options = "";
  if($i == "[") {
    options = $i " "; ++i;
    while($i != "]") {
      options = options $i " "; ++i;
    }
    options = options $i " "; ++i;
  }
  uri = $i; ++i;
  suite = $i; ++i;
  components = "";
  while(1) {
    components = components $i; ++i;
    if(i <= NF && $i !~ /^#/) {
      components = components " "
    } else {
      break;
    }
  }
  if(suite ~ /-backports$/) {
    backports_found = 1;
  }
  if(!backports_found && !backports_line && suite !~ /-/) {
    # Assume the first source w/ no dash in the suite is distribution name
    backports_suite = suite "-backports"
    backports_comment = "# "backports_suite
    backports_line = options uri " " backports_suite " " target_components
  }
  needs_components = components == "main";
}
(!source_found || !needs_components) {
  print; next;
}
{
  components_start = match($0, / main( *#.*)?$/);
  comment_start = match($0, /#.*$/);
  line = substr($0, 1, components_start - 1) " " target_components
  if(comment_start) {
    line = line " " substr($0, comment_start)
  }
  print line;
}
END {
  if(!backports_found && backports_line) {
    print "\n"backports_comment;
    print "deb " backports_line;
    print "deb-src " backports_line;
  }
}
' /etc/apt/sources.list > sources.list
