#!/bin/bash

echo "Checking push commits for JIRA tickets"

# GITHUB_REPOSITORY is in the form <owner>/<repo_name>
REPO=(${GITHUB_REPOSITORY//\// })

echo "Curling Github via GraphQL API"
curl -s -X POST -H 'Accept: application/json' -H 'Authorization: token '${GITHUB_TOKEN}'' \
    ${GITHUB_GRAPHQL_URL}  -d '
    {
        "query": "query { repository(owner: \"'${REPO[0]}'\", name: \"'${REPO[1]}'\"){ object(expression: \"'${GITHUB_SHA}'\") {... on Commit { message associatedPullRequests(last: 1) { edges { node { title commits(first: 100) { edges {node { commit { message }}}}}}}}}}}"
    }' > out.json
#cat out.json

echo "Get all JIRA tickets in PR..."
grep -Eo '(CORE|CLINICAL|CUSTOMER|MOBILE|AUTOMATION)-[0-9]{2,4}' out.json | uniq > tickets.txt
echo "Tickets being merged:"
cat tickets.txt
echo ""

LABEL_TEXT='MERGED_TO_DEV'
if [[ ${GITHUB_REF} == 'refs/heads/canary' ]]; then
    LABEL_TEXT='MERGED_TO_CANARY'
fi
echo "Using label: ${LABEL_TEXT} because of commit to ${GITHUB_REF}"

while read tic; do
    curl -s -X PUT -u ${JIRA_USER_EMAIL}:${JIRA_API_TOKEN} \
    -H "Content-Type: application/json" \
    ${JIRA_BASE_URL}/rest/api/2/issue/$tic -d '
    {
        "update" : {
            "labels": [ {"add": "'${LABEL_TEXT}'"} ]
        }
    }'
    echo "Updated labels for $tic"
done < tickets.txt
