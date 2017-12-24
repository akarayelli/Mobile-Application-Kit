#!/bin/sh

#  CertDownloadScript.sh
#  MobileAppKit
#
#  Created by Alican Karayelli on 23.12.2017.
#  Copyright © 2017 MSN. All rights reserved.

cd "$2"

#sudo openssl s_client -showcerts -connect "$1" < / openssl x509 -outform DER > certificate.cer

openssl s_client -showcerts -connect "$1" </dev/null 2>/dev/null|openssl x509 -outform PEM >mycertfile.pem
openssl x509 -in mycertfile.pem -outform der -out certificate.cer



