#!/bin/bash
set -eu

#echo "Note - pre-requisite for this task to work:"
#kecho "- Your PKS API endpoint [$PKS_API_DOMAIN] should be routable and accessible from the Concourse worker(s) network."
#echo "- See PKS tile documentation for configuration details for vSphere [https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-vsphere.ht#loadbalancer-pks-api] and GCP [https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-gcp.html#loadbalancer-pks-api]"

echo "Retrieving PKS tile properties from Ops Manager [https://$OPSMAN_HOST]..."
# get PKS UAA admin credentails from OpsMgr
PRODUCTS=$(om-linux --target "https://${OPSMAN_HOST}" --client-id "${OPSMAN_CLIENT_ID}" --client-secret "${OPSMAN_CLIENT_SECRET}" --skip-ssl-validation curl -p /api/v0/staged/products)
PKS_GUID=$(echo "$PRODUCTS" | jq -r '.[] | .guid' | grep ${PRODUCT_NAME}- )


  cwd=$(pwd)
  stemcell=$(find ${cwd}/stemcell/*.tgz) 

version=`echo $stemcell | cut -d - -f 4`

if [ -z ${stemcell} ]; then
    echo "stemcell not found."
    exit 1
  fi


echo "'{
  "\"products"\": [
  {
  "\"guid"\":"\"${PKS_GUID}"\",
  "\"staged_stemcell_version"\": "\"${version}"\"
  }
  ]
  }'" > /tmp/file1.out


cat /tmp/file1.out
d=`echo "'{
  "\"products"\": [
  {
  "\"guid"\":"\"${PKS_GUID}"\",
  "\"staged_stemcell_version"\": "\"${version}"\"
  }
  ]
  }'"`
a="om-linux -t https://${OPSMAN_HOST} -c ${OPSMAN_CLIENT_ID} -s ${OPSMAN_CLIENT_SECRET} -k curl --path /api/v0/stemcell_assignments -x PATCH -d $d"

echo $a > file.out
chmod 755 file.out
./file.out

