# JMeter Scripts

## Requirements
* gnuplot
* bc (basic calculator)
* awk

## jmeter-runner.sh

### Usage
```
$ ./jmeter-runner.sh
Usage: jmeter-runner.sh -t test_plan [-q additional_properties_file]
        -t      Test plan (.jmx file)
        -q      Additional properties file (optional)
```

## jmeter-reporter.sh

### Usage
```
$ ./jmeter-reporter.sh
Usage: jmeter-reporter.sh -j test_result
        -j      Test result (.jtl file)
```

## jmeter-create-graphs.sh

### Usage
```
$ ./jmeter-create-graphs.sh
Usage: jmeter-create-graphs.sh -j test_result
        -j      Test result (.jtl file)

```