terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

# --- VARIABLES ---

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "mattermost_url" {
  type        = string
  description = "The Mattermost Incoming Webhook URL."
}

variable "mattermost_message" {
  type        = string
  description = "The message to send to Mattermost."
  default     = "👨‍💻 `$COMMAND` completed in $DURATION"
}

# --- RESOURCES ---

resource "coder_script" "install_mattermostme" {
  agent_id     = var.agent_id
  display_name = "install_mattermostme"
  run_on_start = true
  script = <<OUTER
#!/usr/bin/env bash
set -e

CODER_DIR=$(dirname $(which coder))
cat > $CODER_DIR/mattermostme <<INNER
${replace(templatefile("${path.module}/mattermost.sh", {
  MATTERMOST_URL : var.mattermost_url,
  MATTERMOST_MESSAGE : replace(var.mattermost_message, "`", "\\`"),
}), "$", "\\$")}
INNER

chmod +x $CODER_DIR/mattermostme
OUTER
}

resource "coder_app" "mattermost" {
  agent_id     = var.agent_id
  slug         = "mattermost"
  display_name = "Mattermost"
  url          = var.mattermost_url
  # Updated path based on your prompt's icon URL
  icon         = "https://raw.githubusercontent.com/nvroot/registry/main/.icons/mattermost.svg"
  external     = true
}