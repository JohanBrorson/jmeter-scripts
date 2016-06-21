# JMeter Scripts

## Requirements
* gnuplot
* bc (basic calculator)
* awk

## jmeter-runner.sh

jmeter-runner.sh requires that a _JMETER\_HOME_ variable is defined with the path to the JMeter installation direcory.

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

### Invalid number
If you get an error from printf that say _invalid number_, you might need to set the LC_NUMERIC variable, e.g.

```bash
$ LC_NUMERIC="en_US.UTF-8" ./jmeter-reporter.sh -j my-results-file.jtl
```

## jmeter-create-graphs.sh

### Usage
```
$ ./jmeter-create-graphs.sh
Usage: jmeter-create-graphs.sh -j test_result
        -j      Test result (.jtl file)

```
