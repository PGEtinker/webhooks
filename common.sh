if [ -f ".env" ]; then
    source .env
fi

log() {
    echo "$(date +"%Y-%m-%d_%H:%M:%S"): $@"
}

proxmox_ssh()
{
    ssh -p "$PROXMOX_SSH_PORT" "$PROXMOX_SSH_USER@$PROXMOX_SSH_HOST" "$@"
}

npm_get_token() {

    local payload=$(jq -n \
        --arg npmUser "$NPM_USER" \
        --arg npmPassword "$NPM_PASSWORD" \
        '{
            identity: $npmUser,
            secret: $npmPassword
        }')

    local tokenResponse=$(curl -s -X POST "$NPM_URL/api/tokens" \
        -H "Content-Type: application/json" \
        --data "$payload")

    # Check if token was received
    local token=$(echo "$tokenResponse" | jq -r '.token')
    if [ -z "$token" ] || [ "$token" == "null" ]; then
        return 1
    fi
    
    echo "$token"
    return 0
}

npm_update_host() {
    
    local domainName="$1"
    
    local forwardScheme="$2"
    local forwardHost="$3"
    local forwardPort="$4"
    
    local token="$(npm_get_token)"
    if [ -z "$token" ]; then
        log "Failed to get auth token."
        return 1
    fi

    # local proxyHostID=$(curl -s "$NPM_URL/api/nginx/proxy-hosts?expand=owner,access_list,certificate" \
    local proxyHostID=$(curl -s "$NPM_URL/api/nginx/proxy-hosts" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $token" | jq --arg domainName "$domainName" '.[] | select(.domain_names[0] == $domainName) | .id')
    if [ -z "$proxyHostID" ] || [ "$proxyHostID" == "null" ]; then
        log "Error: couldn't get proxy host id for domain: $domainName"
        return 1
    fi
    
    local payload=$(jq -n \
        --arg forwardScheme "$forwardScheme" \
        --arg forwardHost "$forwardHost" \
        --arg forwardPort "$forwardPort" \
        '{
            forward_scheme: $forwardScheme,
            forward_host: $forwardHost,
            forward_port: $forwardPort
        }')
    
    # Send the PUT request to update the proxy host
    local updateResponse=$(curl -s -X PUT "$NPM_URL/api/nginx/proxy-hosts/$proxyHostID" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        --data "$payload")
    
    if [ "$(echo "$updateResponse" | jq -r '.error')" != "null" ]; then
        log "Error: couldn't update proxy host $proxyHostID with $forwardScheme://$forwardHost:$forwardPort"
        return 1
    fi
    
    return 0
}
