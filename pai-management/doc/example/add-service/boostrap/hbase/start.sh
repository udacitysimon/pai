#!/bin/bash

# Copyright (c) Microsoft Corporation
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# You could modify this script, and start your service in your own way.
# Now the service management of pai is kubernetes, but in this script, you still can running service on other platform


pushd $(dirname "$0") > /dev/null


# Step1: Lable the node.
chmod u+x node-label.sh

./node-label.sh

# Step2: Create the configmap.
chmod u+x configmap-create.sh

./configmap-create.sh

# Hadoop name node
kubectl create -f hbase-master.yaml

# A tool to check whether a node was labeled with hbasemaster="true"
PYTHONPATH="../.." python -m  k8sPaiLibrary.monitorTool.check_node_label_exist -k hbasemaster -v "true"
ret=$?

if [ $ret -ne 0 ]; then
    echo "No hadoop-name-node Pod in your cluster"
else
    # A tool to wait all pod which as label app=hbase-master to be ready.
    PYTHONPATH="../.." python -m  k8sPaiLibrary.monitorTool.check_pod_ready_status -w -k app -v hbase-master
fi


popd > /dev/null