# StashKit

Objective-C Wrapper for Atlassian Stash REST API.

## Installation instructions

The easiest way is probably to use cocoapods.

## Getting started

```objectivec
NSURL *endpoint = [NSURL URLWithString: @"http://stash.oa"];
STKClient *client = [[STKClient alloc] initWithUsername: @"hal.jordan" 
											   password: @"b3w4r3" 
											    baseUrl: endpoint];
```

## Supported methods

* List projects


* Create project
* Create repository

