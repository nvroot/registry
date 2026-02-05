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

# Also add the icon so it shows in the dashboard
resource "coder_app" "mattermost" {
  agent_id     = var.agent_id
  slug         = "mattermost"
  display_name = "Mattermost"
  url          = var.mattermost_url
  icon         = "https://raw.githubusercontent.com/nvroot/registry/main/.icons/mattermost.svg"
  external     = true
}