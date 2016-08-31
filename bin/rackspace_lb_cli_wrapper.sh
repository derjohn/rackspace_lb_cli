#/bin/sh
# Use this wrapper to run the rackspace_lb_cli from shell without installing it as gem.

BASEPATH="$(dirname $0)/.."
ruby -I$BASEPATH -I$BASEPATH/lib $BASEPATH/bin/rackspace_lb_cli $*
