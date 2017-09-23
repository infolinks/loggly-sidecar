# loggly-sidecar

Sidecar container for transmitting log files to Loggly. This container
is meant to be used as a side-car container in a [Kubernetes](https://kubernetes.io)
[Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/), in order
to collect log files from its sibling containers.

## Usage

Extend this image by creating your own image:

    my-loggly-sidecar
        |
        +-- Dockerfile
        |
        +-- my-fluent.conf

Here's the `Dockerfile`:

    FROM infolinks/loggly-sidecar:v3
    MAINTAINER Arik Kfir <arik@infolinks.com>
    COPY my-fluent.conf /fluentd/etc/conf.d/

And here's the `my-fluent.conf` file collecting `Apache` access logs:

    <source>
        @type tail
        path /var/log/access_log
        pos_file /var/log/access_log.pos
        <parse>
            @type apache2
        </parse>
        tag httpd.access_log
    </source>

    <match httpd.access_log>
        @type loggly_buffered
        loggly_url https://logs-01.loggly.com/bulk/#{ENV['LOGGLY_TOKEN']}/tag/httpd.access_log,httpd
        buffer_type file
        buffer_path /var/log/access_log.buffer
        flush_interval 10s
    </match>

Note how the loggly token is not embedded in the Fluent configuration
file, but taken from the environment variable `LOGGLY_TOKEN`, which will
be provided from the Kubernetes manifest below.

Build the image using:

    docker build -t my-loggly-sidecar .

And here's an example Kubernetes deployment manifest putting it all
together:

    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
      name: my-pod
    spec:
      template:
        metadata:
          labels:
            app: my-pod
        spec:
          containers:
            - name: httpd
              image: httpd
              volumeMounts:
                - name: logs
                  mountPath: /var/log/httpd
            - name: loggly
              image: my-loggly-sidecar
              env:
                - name: LOGGLY_TOKEN
                  value: <your_loggly_token_here>
              volumeMounts:
                - name: logs
                  mountPath: /var/log/httpd
          volumes:
            - name: logs
              emptyDir: {}

## Contributions

Any contribution to the project will be appreciated! Whether it's bug
reports, feature requests, pull requests - all are welcome, as long as
you follow our [contribution guidelines for this project](CONTRIBUTING.md)
and our [code of conduct](CODE_OF_CONDUCT.md).
