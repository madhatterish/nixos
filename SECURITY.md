# Security Guidelines for NixOS Configuration

## Repository Visibility

✅ **This repository MUST be PRIVATE** because it contains:
- Server inventory with hostnames and IPs
- Network topology and infrastructure details
- Location and rack information
- System architecture details

## What's Safe to Commit

✅ **Safe to commit:**
- NixOS configuration files
- Ansible inventory with hostnames/IPs (in private repo only)
- Tmux, shell, and application configs
- Scripts (without hardcoded credentials)

## What to NEVER Commit

❌ **NEVER commit:**
- Passwords or passphrases
- SSH private keys (*.pem, *.key, id_rsa, etc.)
- API tokens or access keys
- Database credentials
- TLS/SSL private keys
- Vault passwords
- .env files with secrets

## Using Ansible Vault for Secrets

For sensitive data in Ansible, use Ansible Vault:

```bash
# Create encrypted file
ansible-vault create ansible/secrets.yml

# Edit encrypted file
ansible-vault edit ansible/secrets.yml

# Encrypt existing file
ansible-vault encrypt ansible/group_vars/all/vault.yml

# Encrypt a single variable
ansible-vault encrypt_string 'my_secret' --name 'db_password'
```

### Example vault usage:

```yaml
# ansible/group_vars/all/vault.yml (encrypted with ansible-vault)
vault_db_password: supersecret123
vault_api_key: abc123xyz

# ansible/group_vars/all/vars.yml (plain text, references vault)
db_password: "{{ vault_db_password }}"
api_key: "{{ vault_api_key }}"
```

## SSH Key Management

Store SSH keys securely:

```bash
# SSH keys belong in ~/.ssh/, NOT in git
~/.ssh/id_ed25519       # Private key (NEVER commit)
~/.ssh/id_ed25519.pub   # Public key (safe to share)

# Use ssh-agent for key management
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
```

## Git Security Checklist

Before pushing to GitHub:

- [ ] Repository is set to PRIVATE
- [ ] .gitignore is properly configured
- [ ] No secrets in commit history
- [ ] Ansible vault is used for sensitive vars
- [ ] SSH keys are not in the repo
- [ ] No API tokens or passwords in configs

## If You Accidentally Commit a Secret

1. **Immediately rotate the credential** (change password, regenerate key)
2. **Remove from git history:**
   ```bash
   # Use git filter-branch or BFG Repo-Cleaner
   bfg --delete-files secret-file.key
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   ```
3. **Force push (only if safe):**
   ```bash
   git push --force
   ```

## Additional Security Tools

Consider using for extra protection:
- **sops-nix** - Encrypted secrets in Nix configs
- **agenix** - Age-encrypted secrets for NixOS
- **git-secrets** - Prevents committing secrets
- **gitleaks** - Scan for secrets in git history

## Remember

🔒 Private repos are private, but not foolproof:
- GitHub employees can access
- Compromised accounts can expose data
- Never treat private repos as secure vaults
- Use proper secret management tools
