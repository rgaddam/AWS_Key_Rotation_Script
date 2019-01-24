#!/bin/bash
### Rotate keys for each profile defined in your .aws/credentials file
### ATTENTION: This WILL delete your existing keys, so you must know what you're doing ###

MYUSER="rgaddam"
MYCRED="$HOME/.aws/credentials"
MYNEW="${MYCRED}.NEW"
MYJUMP="f-jbitops002lv.na.atxglobal.com"
REMPATH="/home/rgaddam/.aws/credentials"
COUNT=1

for PROFILE in $(egrep '^[[]' ${MYCRED} | awk -F'[][]' '{print $2}')
  do
  ### Delete old keys ###
  for MYKEY in $(aws iam list-access-keys --user-name ${MYUSER} --profile ${PROFILE} --output text | awk '{print $2}')
    do
    echo "I shall delete this key"
    aws iam delete-access-key --user-name ${MYUSER} --access-key-id ${MYKEY} --profile ${PROFILE}
  done

  ### Create a new key and store the access & secret keys in an array MYKEY ###
  echo "creating a new key"
  MYKEY=($(aws iam create-access-key --user-name ${MYUSER} --profile ${PROFILE} --output text))
  if [[ $COUNT == 1 ]]
    then
    printf "[${PROFILE}]\naws_access_key_id = ${MYKEY[1]}\naws_secret_access_key = ${MYKEY[3]}\n" > ${MYNEW}
  else
    printf "[${PROFILE}]\naws_access_key_id = ${MYKEY[1]}\naws_secret_access_key = ${MYKEY[3]}\n" >> ${MYNEW}
  fi

  ### Increment our $COUNT to append for multiple profiles ###
  ((COUNT+=1))
done

mv $MYNEW $MYCRED

### Upload our new credentials file to the AWS jumpbox as well ###
scp -o User=rgaddam@na.atxglobal.com ${MYCRED} ${MYJUMP}:${REMPATH}
