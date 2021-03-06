<!--
  Copyright (c) Microsoft Corporation
  All rights reserved.

  MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
  to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-->


# PyTorch on PAI

This guide introduces how to run [PyTorch](http://pytorch.org/) workload on PAI.
The following contents show some basic PyTorch examples, other customized PyTorch code can be run similarly.


## Contents

1. [Basic environment](#basic-environment)
2. [Advanced environment](#advanced-environment)
3. [PyTorch examples](#pytorch-examples)
4. [Frequently asked questions](#faq)


## Basic environment

First of all, PAI runs all jobs in Docker container.

[Install Docker-CE](https://docs.docker.com/install/linux/docker-ce/ubuntu/) if you haven't. Register an account at public Docker registry [Docker Hub](https://hub.docker.com/) if you do not have a private Docker registry.

You can also jump to [PyTorch examples](#pytorch-examples) using [pre-built images](https://hub.docker.com/r/openpai/pai.example.pytorch/) on Docker Hub.

We need to build a PyTorch image with GPU support to run PyTorch workload on PAI, this can be done in two steps:

1. Build a base Docker image for PAI. We prepared a [base Dockerfile](../../job-tutorial/Dockerfiles/cuda8.0-cudnn6/Dockerfile.build.base) which can be built directly.

    ```bash
    $ cd ../job-tutorial/Dockerfiles/cuda8.0-cudnn6
    $ sudo docker build -f Dockerfile.build.base \
    >                   -t pai.build.base:hadoop2.7.2-cuda8.0-cudnn6-devel-ubuntu16.04 .
    $ cd -
    ```

2. Prepare PyTorch envoriment in a [Dockerfile](./Dockerfile.example.pytorch) using the base image.

    Write a PyTorch Dockerfile and save it to `Dockerfile.example.pytorch`:

    ```dockerfile
    FROM pai.build.base:hadoop2.7.2-cuda8.0-cudnn6-devel-ubuntu16.04

    # install git
    RUN apt-get -y update && apt-get -y install git

    # install PyTorch dependeces using pip
    RUN pip install torch torchvision

    # clone PyTorch examples
    RUN git clone https://github.com/pytorch/examples.git
    ```

    Build the Docker image from `Dockerfile.example.pytorch`:

    ```bash
    $ sudo docker build -f Dockerfile.example.pytorch -t pai.example.pytorch .
    ```

    Push the Docker image to a Docker registry:

    ```bash
    $ sudo docker tag pai.example.pytorch USER/pai.example.pytorch
    $ sudo docker push USER/pai.example.pytorch
    ```
    *Note: Replace USER with the Docker Hub username you registered, you will be required to login before pushing Docker image.*


## Advanced environment

You can skip this section if you do not need to prepare other dependencies.

You can customize runtime PyTorch environment in [Dockerfile.example.pytorch](./Dockerfile.example.pytorch), for example, adding other dependeces in Dockerfile:

```dockerfile
FROM pai.build.base:hadoop2.7.2-cuda8.0-cudnn6-devel-ubuntu16.04

# install other packages using apt-get
RUN apt-get -y update && apt-get -y install git PACKAGE

# install other packages using pip
RUN pip install torch torchvision PACKAGE

# clone PyTorch examples
RUN git clone https://github.com/pytorch/examples.git
```


# PyTorch examples

To run PyTorch examples in PAI, you need to prepare a job configuration file and submit it through webportal.

If you have built your image and pushed it to Docker Hub, replace our pre-built image `openpai/pai.example.pytorch` with your own.

Here're some configuration file examples:

### [mnist](https://github.com/pytorch/examples/tree/master/mnist)
```json
{
  "jobName": "pytorch-mnist",
  "image": "openpai/pai.example.pytorch",
  "taskRoles": [
    {
      "name": "main",
      "taskNumber": 1,
      "cpuNumber": 4,
      "memoryMB": 8192,
      "gpuNumber": 1,
      "command": "cd examples/mnist && python main.py"
    }
  ]
}
```

### [regression](https://github.com/pytorch/examples/tree/master/regression)
```json
{
  "jobName": "pytorch-regression",
  "image": "openpai/pai.example.pytorch",
  "taskRoles": [
    {
      "name": "main",
      "taskNumber": 1,
      "cpuNumber": 4,
      "memoryMB": 8192,
      "gpuNumber": 0,
      "command": "cd examples/regression && python main.py"
    }
  ]
}
```

For more details on how to write a job configuration file, please refer to [job tutorial](../../job-tutorial/README.md#json-config-file-for-job-submission).


## FAQ

### Speed

Since PAI runs PyTorch jobs in Docker, the trainning speed on PAI should be similar to speed on host.
