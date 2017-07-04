# Hyper.sh fluent plugin

Fluent input plugin for collecting hyper.sh service logs. Assumes you have the hyper CLI command installed and configured on the system that is running fluentd.

Options:

* service: name of the service for which you want to capture logs

```
<source>
  @type hypersh
  service php
</source>

<match hypersh.**>
  @type stdout
  @id stdout_output2
</match>
```
