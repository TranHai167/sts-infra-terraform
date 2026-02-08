MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace

EXTRA_ARGS="${extra_args}"

if [ ${max_pods} -gt 0 ]; then
  EXTRA_ARGS="$EXTRA_ARGS --use-max-pods false --kubelet-extra-args '--max-pods=${max_pods}'"
fi

/etc/eks/bootstrap.sh ${cluster_name} $EXTRA_ARGS

--==BOUNDARY==--
