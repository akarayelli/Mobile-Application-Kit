#!/bin/sh

#  PinningScript.sh
#  MobileAppKit
#
#  Created by Alican Karayelli on 23.12.2017.
#  Copyright © 2017 MSN. All rights reserved.

openssl s_client -showcerts -connect "${1}" </dev/null 2>/dev/null|openssl x509 -outform PEM >mycertfile.pem

openssl x509 -in mycertfile.pem -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64




