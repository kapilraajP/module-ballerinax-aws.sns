// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/crypto;
import ballerina/http;
import ballerina/lang.array;
import ballerina/time;

# Ballerina Amazon SNS API connector provides the capability to access Amazon Simple Notification Service.
# This connector lets you to create and manage the sns topics and subscriptions.
#
# + amazonSNSClient - Connector HTTP endpoint
# + accessKeyId - Amazon API access key
# + secretAccessKey - Amazon API secret key
# + securityToken - Security token
# + region - Amazon API Region
# + amazonHost - Amazon host name
@display {label: "Amazon SNS Client", iconPath: "resources/aws.sns.svg"}
public isolated client class Client {
    final string accessKeyId;
    final string secretAccessKey;
    final string? securityToken;
    final string region;
    final string amazonHost;
    final http:Client amazonSNSClient;

    # Initializes the connector.
    #
    # + configuration - Configuration for the connector
    # + httpClientConfig - HTTP Configuration
    # + return - `http:Error` in case of failure to initialize or `null` if successfully initialized
    public isolated function init(ConnectionConfig configuration, http:ClientConfiguration httpClientConfig = {}) returns error? {
        self.accessKeyId = configuration.credentials.accessKeyId;
        self.secretAccessKey = configuration.credentials.secretAccessKey;
        self.securityToken = (configuration?.credentials?.securityToken is string) ? <string>(configuration?.credentials?.securityToken) : ();
        self.region = configuration.region;
        self.amazonHost = "sns." + self.region + ".amazonaws.com";
        string baseURL = "https://" + self.amazonHost;
        check checkCredentials(self.accessKeyId, self.secretAccessKey);
        self.amazonSNSClient = check new (baseURL, httpClientConfig);
    }

    # Create a topic.
    #
    # + name - Name of topic
    # + attributes - Topic attributes
    # + tags - Tags
    # + return - Created topic ARN on success else an `error`
    @display {label: "Create Topic"}
    isolated remote function createTopic(@display {label: "Topic Name"} string name, 
                                         @display {label: "Topic Attributes"} TopicAttributes? attributes = (), 
                                         @display {label: "Tags"} map<string>? tags = ()) 
                                         returns @tainted @display {label: "Created Topic ARN"} CreateTopicResponse|error {
        map<string> parameters = {};
        parameters = buildQueryString("CreateTopic", parameters, name);
        if (attributes is TopicAttributes) {
            parameters = setTopicAttributes(parameters, attributes);
        }
        if (tags is map<string>) {
            parameters = setTags(parameters, tags);
        }
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        CreateTopicResponse|error createdTopicResponse = xmlToCreatedTopic(response);
        if (createdTopicResponse is CreateTopicResponse) {
            return createdTopicResponse;
        } else {
            return error(createdTopicResponse.message());
        }
    }

    # Subscribe to a topic.
    #
    # + topicArn - The ARN of the topic you want to subscribe to
    # + protocol - The protocol that you want to use
    # + endpoint - The endpoint that you want to receive notifications
    # + 'returnSubscriptionArn - Sets whether the response from the subscribe request includes the subscription ARN
    # + attributes - Subscription attributes
    # + return - Created subscription ARN on success else an `error`
    @display {label: "Create Subscription"}
    isolated remote function subscribe(@display {label: "Topic ARN"} string topicArn, 
                                       @display {label: "Protocol"} Protocol protocol, 
                                       @display {label: "Endpoint For Subscription"} string? endpoint = (), 
                                       @display {label: "Subscription ARN Status"} boolean? returnSubscriptionArn = (), 
                                       @display {label: "Subscription Attributes"} SubscriptionAttribute? attributes = ()) 
                                       returns @tainted @display {label: "Subscription ARN"} SubscribeResponse|error {
        map<string> parameters = {};
        parameters = buildQueryString("Subscribe", parameters, topicArn, protocol);
        parameters = check addOptionalStringParameters(parameters, endpoint);
        if (returnSubscriptionArn is boolean) {
            parameters["ReturnSubscriptionArn"] = returnSubscriptionArn.toString();
        }
        if (attributes is SubscriptionAttribute) {
            parameters = setSubscriptionAttributes(parameters, attributes);
        }
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        SubscribeResponse|error createdSubscriptionResponse = xmlToCreatedSubscription(response);
        if (createdSubscriptionResponse is SubscribeResponse) {
            return createdSubscriptionResponse;
        } else {
            return error(createdSubscriptionResponse.message());
        }
    }

    # Publish a message in a topic.
    #
    # + message - The message content to publish
    # + topicArn - The ARN of the topic
    # + targetArn - The ARN of the target resource
    # + subject - The subject of the message
    # + phoneNumber - The phone number to send message
    # + messageStructure - The message structure
    # + messageDeduplicationId - The message dupilcation Id
    # + messageGroupId - The message group Id
    # + messageAttributes - The message attributes of type 'MessageAttribute'
    # + return - Result of message published on success else an `error`
    @display {label: "Publish Message"}
    isolated remote function publish(@display {label: "Message"} string message, 
                                     @display {label: "Topic ARN"} string? topicArn = (), 
                                     @display {label: "Target ARN"}  string? targetArn = (), 
                                     @display {label: "Message Subject"} string? subject = (), 
                                     @display {label: "Phone Number"} string? phoneNumber = (), 
                                     @display {label: "Message Structure"} string? messageStructure = (), 
                                     @display {label: "Message Duplication Id"} string? messageDeduplicationId = (), 
                                     @display {label: "Message Group Id"} string? messageGroupId = (), 
                                     @display {label: "Message Attributes"} MessageAttribute? messageAttributes = ()) 
                                     returns @tainted @display {label: "Published result"} PublishResponse|error {
        map<string> parameters = {};
        parameters["Message"] = message;
        parameters = buildQueryString("Publish", parameters, message);
        parameters = check addOptionalStringParameters(parameters, topicArn, targetArn, subject, phoneNumber, messageStructure, messageGroupId, messageDeduplicationId);
        if (messageAttributes is MessageAttribute) {
            parameters = setMessageAttributes(parameters, messageAttributes);
        }
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        PublishResponse|error publishResponse = xmlToPublishResponse(response);
        if (publishResponse is PublishResponse) {
            return publishResponse;
        } else {
            return error(publishResponse.message());
        }
    }

    # Unsubscribe to a topic.
    #
    # + subscriptionArn - The ARN of the subscription
    # + return - Result of unsubscription on success else an `error`
    @display {label: "Unsubscribe Topic"}
    isolated remote function unsubscribe(@display {label: "Subscription ARN"} string subscriptionArn) 
                                         returns @tainted @display {label: "Unsubscription Status"} UnsubscribeResponse|error {
        map<string> parameters = {};
        parameters = buildQueryString("Unsubscribe", parameters, subscriptionArn);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        UnsubscribeResponse|error unsubscribeResponse = xmlToUnsubscribeResponse(response);
        if (unsubscribeResponse is UnsubscribeResponse) {
            return unsubscribeResponse;
        } else {
            return error(unsubscribeResponse.message());
        }
    }

    # Delete a topic.
    #
    # + topicArn - The ARN of the topic
    # + return - Result of deleted topic on success else an `error`
    @display {label: "Delete Topic"}
    isolated remote function deleteTopic(@display {label: "Topic ARN"} string topicArn) 
                                         returns @tainted @display {label: "Delete Status"} DeleteTopicResponse|error {
        map<string> parameters = {};
        parameters = buildQueryString("DeleteTopic", parameters, topicArn);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        DeleteTopicResponse|error deletedResponse = xmlToDeletedTopicResponse(response);
        if (deletedResponse is DeleteTopicResponse) {
            return deletedResponse;
        } else {
            return error(deletedResponse.message());
        }
    }

    # Create a SMS sandbox phone number.
    #
    # + phoneNumber - The destination phone number to verify
    # + languageCode - The language to use for sending the OTP
    # + return - Result of SMS sandbox creation on success else an `error`
    @display {label: "Create SMS Sandbox Number"} 
    isolated remote function createSMSSandboxPhoneNumber(@display {label: "Phone Number"} string phoneNumber, 
                                                         @display {label: "Language Code"} string? languageCode = ()) 
                                                         returns @tainted @display {label: "Created Status"} error? {
        map<string> parameters = {};
        parameters = buildQueryString("CreateSMSSandboxPhoneNumber", parameters, phoneNumber);
        parameters = check addOptionalStringParameters(parameters, languageCode);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        error? createSandboxResponse = xmlToHttpResponse(response);
        if (createSandboxResponse is error) {
            return error(createSandboxResponse.message());
        } else {
            return createSandboxResponse;
        }
    }

    # Confirm a subscription.
    #
    # + token - The token to confirm subscription
    # + topicArn - The ARN of the topic
    # + authenticateOnUnsubscribe - Authenticate on unsubscription
    # + return - Result of subscription confirmation on success else an `error`
    @display {label: "Confirm Subscription"} 
    isolated remote function confirmSubscription(@display {label: "Confirmation Token"} string token, 
                                                 @display {label: "Topic ARN"} string topicArn, 
                                                 @display {label: "Unsubscription Need Authentication"} string? authenticateOnUnsubscribe = ()) 
                                                 returns @tainted @display {label: "Confirm Subscription Status"} ConfirmedSubscriptionResponse|error {
        map<string> parameters = {};
        parameters = buildQueryString("ConfirmSubscription", parameters, token, topicArn);
        parameters = check addOptionalStringParameters(parameters, authenticateOnUnsubscribe);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        xml response = check sendRequest(self.amazonSNSClient, request);
        ConfirmedSubscriptionResponse|error confirmedSubscriptionResponse = xmlToConfirmedSubscriptionResponse(response);
        if (confirmedSubscriptionResponse is ConfirmedSubscriptionResponse) {
            return confirmedSubscriptionResponse;
        } else {
            return error(confirmedSubscriptionResponse.message());
        }
    }

    # Add a topic attributes for a topic created.
    # 
    # + topicArn - Name of topic
    # + attributeName - Name of a attribute
    # + attributeValue - Value corresponding to that attribute
    # + return - Null on success else an `error`
    @display {label: "Add Topic Attribute"} 
    isolated remote function setTopicAttribute(@display {label: "Topic ARN"} string topicArn, 
                                               @display {label: "Attribute Name"} string attributeName, 
                                               @display {label: "Attribute Value"} string? attributeValue = ()) 
                                               returns @tainted @display {label: "Topic Attribute Status"} error? {
        map<string> parameters = {};
        parameters = buildQueryString("SetTopicAttributes", parameters, topicArn, attributeName);
        parameters = check addOptionalStringParameters(parameters, attributeValue);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.amazonSNSClient->post("/", request);
            xml|error response = handleResponse(httpResponse);
            if (response is xml) {
                return xmlToHttpResponse(response);
            } else {
                return response;
            }
        } else {
            return error(REQUEST_ERROR);
        }
    }

    # Get values of topic attributes for a topic.
    #
    # + topicArn - ARN of a topic
    # + return - Array of TopicAttribute on success else an `error`
    @display {label: "Get Topic Attributes"} 
    isolated remote function getTopicAttributes(@display {label: "Topic ARN"} string topicArn) 
                                                returns @tainted @display {label: "Topic Attributes"} TopicAttribute[]|error {
        map<string> parameters = {};
        parameters = buildQueryString("GetTopicAttributes", parameters, topicArn);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.amazonSNSClient->post("/", request);
            xml|error response = handleResponse(httpResponse);
            if (response is xml) {
                return xmlToTopicAttributes(response);
            } else {
                return response;
            }
        } else {
            return error(REQUEST_ERROR);
        }
    }

    # Add a SMS attributes for a SMS send.
    # 
    # + attributes - SMSAttributes record contain attribute information
    # + return - Null on success else an `error`
    @display {label: "Add SMS Attribute"} 
    isolated remote function setSMSAttributes(@display {label: "SMS Attribute To Add"} SmsAttributes attributes) 
                                              returns @tainted @display {label: "SMS Attribute Status"} error? {
        map<string> parameters = {};
        parameters = buildQueryString("SetSMSAttributes", parameters);
        parameters = setSmsAttributes(parameters, attributes);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.amazonSNSClient->post("/", request);
            xml|error response = handleResponse(httpResponse);
            if (response is xml) {
                return xmlToHttpResponse(response);
            } else {
                return response;
            }
        } else {
            return error(REQUEST_ERROR);
        }
    }

    # Get values of SMS attributes.
    #
    # + attributes - SMS attribute names
    # + return - Array of SmsAttribute on success else an `error`
    isolated remote function getSMSAttributes(string[]? attributes = ()) returns @tainted SmsAttribute[]|error {
        map<string> parameters = {};
        parameters = buildQueryString("GetSMSAttributes", parameters);
        if (attributes is string[]) {
            parameters = addSmsAttributes(parameters, attributes);
        }
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.amazonSNSClient->post("/", request);
            xml|error response = handleResponse(httpResponse);
            if (response is xml) {
                return xmlToSMSAttributes(response);
            } else {
                return response;
            }
        } else {
            return error(REQUEST_ERROR);
        }
    }

    # Add a subscription attributes for a subscription created.
    # 
    # + subscriptionArn - Name of subscription
    # + attributeName - Name of a attribute
    # + attributeValue - Value corresponding to that attribute
    # + return - Null on success else an `error`
    @display {label: "Add Subscription Attribute"} 
    isolated remote function setSubscriptionAttribute(@display {label: "Subscription ARN"} string subscriptionArn,
                                                      @display {label: "Attribute Name"} string attributeName, 
                                                      @display {label: "Attribute Value"} string? attributeValue = ()) 
                                                      returns @tainted @display {label: "Subscription Attribute Status"} error? {
        map<string> parameters = {};
        parameters[ACTION] = "SetSubscriptionAttributes";
        parameters[VERSION] = VERSION_NUMBER;
        parameters["SubscriptionArn"] = subscriptionArn;
        parameters["AttributeName"] = attributeName;
        if (attributeValue is string) {
            parameters["AttributeValue"] = attributeValue;
        }
        parameters = buildQueryString("SetSubscriptionAttributes", parameters, subscriptionArn, attributeName);
        parameters = check addOptionalStringParameters(parameters, attributeValue);        
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.amazonSNSClient->post("/", request);
            xml|error response = handleResponse(httpResponse);
            if (response is xml) {
                return xmlToHttpResponse(response);
            } else {
                return response;
            }
        } else {
            return error(REQUEST_ERROR);
        }
    }

    # Get values of subscription attributes for a subscription.
    #
    # + subscriptionArn - ARN of a subscription
    # + return - Array of SubscriptionAttribute on success else an `error`
    @display {label: "Get Subscription Attributes"} 
    isolated remote function getSubscriptionAttributes(@display {label: "Subscription ARN"} string subscriptionArn) 
                                                       returns @tainted @display {label: "Subscription Attributes"} SubscriptionAttribute[]|error {
        map<string> parameters = {};
        parameters = buildQueryString("GetSubscriptionAttributes", parameters, subscriptionArn);
        http:Request|error request = self.generateRequest(self.createPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.amazonSNSClient->post("/", request);
            xml|error response = handleResponse(httpResponse);
            if (response is xml) {
                return xmlToSubscriptionAttributes(response);
            } else {
                return response;
            }
        } else {
            return error(REQUEST_ERROR);
        }
    }

    //Create a payload.
    private isolated function createPayload(map<string> parameters) returns string {
        string payload = EMPTY_STRING;
        int parameterNumber = 1;
        foreach var [key, value] in parameters.entries() {
            if (parameterNumber > 1) {
                payload = payload + "&";
            }
            payload = payload + key + "=" + value;
            parameterNumber = parameterNumber + 1;
        }
        return payload;
    }

    //Create request with headers attached.
    private isolated function generateRequest(string payload) 
        returns http:Request|error {
        [int, decimal] & readonly currentTime = time:utcNow();
        string|error xamzDate = utcToString(currentTime, "yyyyMMdd'T'HHmmss'Z'");
        string|error dateStamp = utcToString(currentTime, "yyyyMMdd");
        if (xamzDate is string && dateStamp is string) {
            string contentType = "application/x-www-form-urlencoded";
            string requestParameters = payload;
            string canonicalQuerystring = EMPTY_STRING;
            string? availableSecurityToken = self.securityToken;
            string canonicalHeaders = EMPTY_STRING;
            string signedHeaders = EMPTY_STRING;
            //Create a canonical request for Signature Version 4
            if (availableSecurityToken is string) {
                canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + self.amazonHost + "\n" 
                + "x-amz-date:" + xamzDate + "\n" + "x-amz-security-token" + availableSecurityToken + "\n";
                signedHeaders = "content-type;host;x-amz-date;x-amz-security-token";
            } else {
                canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + self.amazonHost + "\n" 
                    + "x-amz-date:" + xamzDate + "\n";
                signedHeaders = "content-type;host;x-amz-date";
            }
            string payloadHash = array:toBase16(crypto:hashSha256(requestParameters.toBytes())).toLowerAscii();
            string canonicalRequest = "POST" + "\n" + "/" + "\n" + canonicalQuerystring + "\n" 
                + canonicalHeaders + "\n" + signedHeaders + "\n" + payloadHash;
            string algorithm = "AWS4-HMAC-SHA256";
            string credentialScope = dateStamp + "/" + self.region + "/" + "sns" 
                + "/" + "aws4_request";
            //Create a string to sign for Signature Version 4
            string stringToSign = algorithm + "\n" + xamzDate + "\n" + credentialScope + "\n" 
                + array:toBase16(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii();
            //Calculate the signature for AWS Signature Version 4
            byte[] signingKey = check self.calculateSignature(self.secretAccessKey, dateStamp, self.region, "sns");
            string signature = array:toBase16(check crypto:hmacSha256(stringToSign
                .toBytes(), signingKey)).toLowerAscii();
            //Add the signature to the HTTP request
            string authorizationHeader = algorithm + " " + "Credential=" + self.accessKeyId + "/" 
                + credentialScope + ", " + "SignedHeaders=" + signedHeaders + ", " + "Signature=" + signature;
            map<string> headers = {};
            headers["Content-Type"] = contentType;
            headers["X-Amz-Date"] = xamzDate;
            headers["Authorization"] = authorizationHeader;
            string msgBody = requestParameters;
            http:Request request = new;
            request.setTextPayload(msgBody);
            foreach var [key, value] in headers.entries() {
                request.setHeader(key, value);
            }
            return request;
        } else {
            return error GenerateRequestFailed(GENERATE_REQUEST_FAILED_MSG);
        }
    }

    //Calculate the signature for AWS Signature Version 4.
    private isolated function calculateSignature(string secretAccessKey, string datestamp, string region, string serviceName) 
                                            returns byte[]|error {
        string kSecret = secretAccessKey;
        byte[] kDate = check crypto:hmacSha256(datestamp.toBytes(), ("AWS4" + kSecret).toBytes());
        byte[] kRegion = check crypto:hmacSha256(region.toBytes(), kDate);
        byte[] kService = check crypto:hmacSha256(serviceName.toBytes(), kRegion);
        byte[] kSigning = check crypto:hmacSha256("aws4_request".toBytes(), kService);
        return kSigning;
    }
}

# Configuration provided for the client.
#
# + credentials - Credentials to authenticate client 
# + region - Region of SNS resource
public type ConnectionConfig record {
    ShortTermCredentials|LongTermCredentials credentials;
    string region = "us-east-1";
};

public type ShortTermCredentials record {
    string accessKeyId;
    string secretAccessKey;
    string securityToken;
};

public type LongTermCredentials record {
    string accessKeyId;
    string secretAccessKey;
};
