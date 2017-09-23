# loggly-sidecar

Sidecar container for transmitting log files to Loggly. This container
is meant to be used as a side-car container in a [Kubernetes](https://kubernetes.io)
[Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/), in order
to collect log files from its sibling containers.

## Usage

Here's an example Pod using this container:

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

            # this container generates log files under "/var/log/my-pod":
            - name: my-container1
              image: my/container:latest
              volumeMounts:
                - name: logs
                  mountPath: /var/log/my-pod

            # this is the sidecar:
            - name: loggly
              image: infolinks/loggly-sidecar
              env:
                - name: LOGGLY_TOKEN
                  value: <your_loggly_token_here>
              volumeMounts:
                - name: fluentd
                  mountPath: /fluentd/etc/conf.d
                  readOnly: true
                - name: logs
                  mountPath: /var/log/my-pod

          volumes:
            # shared logs volume mounted by both containers - one writes
            # logs into it, and the sidecar reads logs from it
            - name: logs
              emptyDir: {}

            # volume mounted by the sidecar - this volume should contain
            # fluentd configurations for reading the logs at /var/log/my-pod
            # usually you would want this to be populated from a configmap
            # so you could reconfigure fluentd, but you could use any
            # technique you want, as long as the fluentd "conf" files
            # are in this volume.
            # alternatively, you could create your own Docker image that
            # extends the "loggly-sidecar" image, and import your conf
            # files to "/fluentd/etc/conf.d" yourself (in such a case,
            # a volume mount is not necessary)
            - name: fluentd
              ...

## Contributions

Any contribution to the project will be appreciated! Whether it's bug
reports, feature requests, pull requests - all are welcome, as long as
you follow our [contribution guidelines for this project](CONTRIBUTING.md)
and our [code of conduct](CODE_OF_CONDUCT.md).
