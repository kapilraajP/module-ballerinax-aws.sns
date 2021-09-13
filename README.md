# Ballerina Amazon SNS Connector

[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.sns.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.sns)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.sns.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon SNS](https://aws.amazon.com/sns/) is a message notification service developed by Amazon.

This connector provides operations for connecting and interacting with Amazon SNS endpoints over the network. 

- [`aws.sns`](sns/Module.md)

## Building from the source
### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory in which you installed JDK.

2. Download and install [Ballerina Swan Lake Beta3](https://ballerina.io/). 

### Building the source
Execute the following commands to build from the source:

* To build the package:
    ```    
    bal build -c ./sns
    ```
* To build the package without tests:
    ```
    bal build -c --skip-tests ./sns
    ```
## Contributing to Ballerina
As an open source project, Ballerina welcomes contributions from the community. 

For more information, see the [Contribution Guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links
* Discuss about code changes of the Ballerina project via [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
