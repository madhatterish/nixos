#!/usr/bin/env bash
# Kubernetes Context Switcher with fuzzel
# Switch between kubectl contexts and optionally change namespace

# Get all available contexts
CONTEXTS=$(kubectl config get-contexts -o name 2>/dev/null)

# Check if kubectl is available and contexts exist
if [ -z "$CONTEXTS" ]; then
    notify-send "K8s Context Switcher" "No kubectl contexts found"
    exit 1
fi

# Get current context
CURRENT=$(kubectl config current-context 2>/dev/null)

# Format contexts with current one marked
FORMATTED_CONTEXTS=""
while IFS= read -r context; do
    if [ "$context" = "$CURRENT" ]; then
        FORMATTED_CONTEXTS+="* $context"$'\n'
    else
        FORMATTED_CONTEXTS+="  $context"$'\n'
    fi
done <<< "$CONTEXTS"

# Use fuzzel to select a context
SELECTED=$(echo "$FORMATTED_CONTEXTS" | fuzzel --dmenu --prompt "K8s Context: ")

# Exit if no selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Remove the marker if present
SELECTED=$(echo "$SELECTED" | sed 's/^[* ] *//')

# Switch context
if kubectl config use-context "$SELECTED" 2>/dev/null; then
    notify-send "K8s Context Switched" "Now using: $SELECTED"

    # Optionally ask to change namespace
    NAMESPACES=$(kubectl get namespaces -o name 2>/dev/null | sed 's|namespace/||')
    if [ -n "$NAMESPACES" ]; then
        NAMESPACE=$(echo "$NAMESPACES" | fuzzel --dmenu --prompt "Namespace (ESC for default): ")
        if [ -n "$NAMESPACE" ]; then
            kubectl config set-context --current --namespace="$NAMESPACE"
            notify-send "K8s Namespace Set" "Namespace: $NAMESPACE"
        fi
    fi
else
    notify-send "K8s Context Switch Failed" "Could not switch to: $SELECTED"
    exit 1
fi
