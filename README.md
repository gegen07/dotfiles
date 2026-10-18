# dotfiles

Masterless Salt states for a Debian-family workstation. Run the commands below from any directory; the script finds its own location.

```bash
./bootstrap.sh
```

That installs Salt 3008 if it is missing, then applies every role.

```bash
./bootstrap.sh core dev    # selected roles
./bootstrap.sh git         # one state
./bootstrap.sh fonts       # Fira Code 6.2 and Meslo Nerd Font 3.5.1
```

Roles:

- `core` links git, zsh, and vim
- `dev` installs compilers, Docker, Go, Python, micromamba, Rust, and VS Code
- `desktop` installs Chrome, Discord, Spotify, OpenVPN, and a JDK

`~/.zshrc.local` holds machine-specific setup such as conda, nvm, the Cloud SDK, and pixi. Salt copies `states/base/zsh/config/rc.local.example` there only when the file is missing. Micromamba is installed to `~/.local/bin` and initialized from `~/.zshrc`.

Google Chrome's apt repository publishes amd64 packages. Neovim is installed from the pinned GitHub release under `/usr/local/bin/nvim`.
