---
display_name: Mattermost Me
description: Send a Mattermost message when a command finishes inside a workspace!
icon: ../../../../.icons/mattermost.svg
verified: true
tags: [helper, mattermost]
---

# Mattermost Me

Add the `mattermostme` command to your workspace that DMs you on Mattermost when your command finishes running.

```tf
module "mattermostme" {
  count            = data.coder_workspace.me.start_count
  source           = "registry.coder.com/coder/mattermostme/coder"
  version          = "1.0.33"
  agent_id         = coder_agent.example.id
  auth_provider_id = "mattermost"
}
```

```bash
mattermostme npm run long-build
```

## Setup

1. Navigate to [Create a Mattermost App](https://api.mattermost.com/apps?new_app=1) and select "From an app manifest". Select a workspace and paste in the following manifest, adjusting the redirect URL to your Coder deployment:

   ```json
   {
     "display_information": {
       "name": "Command Notify",
       "description": "Notify developers when commands finish running inside Coder!",
       "background_color": "#1b1b1c"
     },
     "features": {
       "bot_user": {
         "display_name": "Command Notify"
       }
     },
     "oauth_config": {
       "redirect_urls": [
         "https://<your coder deployment>/external-auth/mattermost/callback"
       ],
       "scopes": {
         "bot": ["chat:write"]
       }
     }
   }
   ```

2. In the "Basic Information" tab on the left after creating your app, scroll down to the "App Credentials" section. Set the following environment variables in your Coder deployment:

   ```env
   CODER_EXTERNAL_AUTH_1_TYPE=mattermost
   CODER_EXTERNAL_AUTH_1_SCOPES="chat:write"
   CODER_EXTERNAL_AUTH_1_DISPLAY_NAME="Mattermost Me"
   CODER_EXTERNAL_AUTH_1_CLIENT_ID="<your client id>
   CODER_EXTERNAL_AUTH_1_CLIENT_SECRET="<your client secret>"
   ```

3. Restart your Coder deployment. Any Template can now import the Mattermost Me module, and `mattermostme` will be available on the `$PATH`:

## Examples

### Custom Mattermost Message

- `$COMMAND` is replaced with the command the user executed.
- `$DURATION` is replaced with a human-readable duration the command took to execute.

```tf
module "mattermostme" {
  count            = data.coder_workspace.me.start_count
  source           = "registry.coder.com/coder/mattermostme/coder"
  version          = "1.0.33"
  agent_id         = coder_agent.example.id
  auth_provider_id = "mattermost"
  mattermost_message    = <<EOF
👋 Hey there from Coder! $COMMAND took $DURATION to execute!
EOF
}
```
