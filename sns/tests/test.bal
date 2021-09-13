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

import ballerina/test;

configurable string testTopic = os:getEnv("TOPIC_NAME");
configurable string accessKeyIdId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

string topicArn = "";
string subscriptionArn = "";

LongTermCredentials longTermCredentials = {
    accessKeyId: accessKeyIdId,
    secretAccessKey: secretAccessKey
};

ConnectionConfig config = {
    credentials:longTermCredentials,
    region: region
};

Client amazonSNSClient = check new(config);

@test:Config{}
function testCreateTopic() {
    TopicAttribute attributes = {
        displayName : "Test"
    };
    CreateTopicResponse|error response = amazonSNSClient->createTopic(testTopic, attributes);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        topicArn = response.createTopicResult.topicArn;
    }
}

@test:Config{}
function testGetSMSAttributes() {
    SmsAttribute[]|error response = amazonSNSClient->getSMSAttributes();
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{}
function testGetTopicAttributes() {
    TopicAttribute[]|error response = amazonSNSClient->getTopicAttributes("arn:aws:sns:ap-southeast-1:304758769516:testTopic");
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{}
function testCreateSMSSandboxPhoneNumber() {
    json|error response = amazonSNSClient->createSMSSandboxPhoneNumber("+94776718102", "en-US");
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        topicArn = response.toString();
    }
}

@test:Config{dependsOn: [testCreateTopic]}
function testSubscribe() {
    SubscribeResponse|error response = amazonSNSClient->subscribe(topicArn, EMAIL, "kapilraaj1995@gmail.com");
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        subscriptionArn = response.subscribeResult.subscriptionArn;
    }
}

@test:Config{}
function testPublish() {
    json|error response = amazonSNSClient->publish("Notification Message", "arn:aws:sns:ap-southeast-1:304758769516:testTopic");
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testPublish]}
function testUnsubscribe() {
    json|error response = amazonSNSClient->unsubscribe(subscriptionArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testUnsubscribe]}
function testDeleteTopic() {
    json|error response = amazonSNSClient->deleteTopic(topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{}
function testGetSubscriptionAttributes() {
    SubscriptionAttribute[]|error response = amazonSNSClient->getSubscriptionAttributes("arn:aws:sns:ap-south-1:304758769516:test2.fifo");
    if (response is error) {
        test:assertFail(response.toString());
    }
}