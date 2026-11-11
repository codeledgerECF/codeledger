# CodeLedger portable CLI

Use Node.js 20 or newer and Git. The CLI returns literal matches from committed
source, tests and docs in the selected worktree. Each match includes the Git
revision, relative path, line number and matching text.

For the ZIP, verify its SHA-256 against SHA256SUMS.txt before extracting it.
Run the following in a Git worktree with a committed HEAD.

    node /path/to/codeledger-open.cjs activate --task "Find the HTTP 429 fallback" --query "Retry-After"

For an npm installation, use the codeledger command in place of node and the CJS path.
Install one package. Both npm names provide the same commands.

For MCP, configure Claude Code or Codex to run codeledger with arguments
mcp start --repo /absolute/path/to/worktree. For a ZIP installation, configure
node as the command and put the absolute CJS path before those arguments.
The get_activation_payload tool takes task and query. Authorize the host to
receive excerpts from that worktree before configuring the server.

Use the host's regular discovery for uncommitted changes. The portable CLI's
scope is read-only committed context and local stdio MCP.

Download the portable ZIP and SHA-256 checksums from the GitHub release for this version.
