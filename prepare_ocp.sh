COOLSTORE_NAMESPACE=${VARIABLE:-coolstore}
COOLSTORE_INFRA=${VARIABLE:-coolstore-infra}
oc import-image redhat-sso72-openshift:1.1 --from=registry.access.redhat.com/redhat-sso-7/sso72-openshift --confirm -n openshift
oc import-image redhat-openjdk18-openshift:1.4 --from=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift --confirm -n openshift

oc new-project $COOLSTORE_INFRA
if [ "$?" != "0" ];then
    echo "Detect $COOLSTORE_INFRA, abort reinstall sso. Please reinstall manually if it sso not installed corrected in $COOLSTORE_INFRA"
    exit 0
fi
oc apply -f ocp/rhsso/rhsso-app-secret.json -n $COOLSTORE_INFRA

oc policy add-role-to-user view system:serviceaccount:$COOLSTORE_INFRA:sso-service-account -n $COOLSTORE_INFRA

oc process -f ocp/rhsso/rhsso72-postgresql-persistent.yaml \
-p HTTPS_NAME=jboss -p HTTPS_PASSWORD=mykeystorepass \
-p SSO_ADMIN_USERNAME=admin -p SSO_ADMIN_PASSWORD=admin \
-p SSO_REALM=coolstore | oc apply -n $COOLSTORE_INFRA -f -

