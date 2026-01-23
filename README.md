# zsh-t3-shortcuts

Zsh shortcuts for working with **TYPO3 projects**.
Provides fast navigation commands to jump around TYPO3 project directories.

## Features

- `up N` → go up *N* directories
- `t3pr` → jump to TYPO3 project root (directory containing `vendor/`)
- `t3sp` → jump to `packages/site-package`

---


## Installation

### Install with Zinit
```zsh
zinit light murat-yasar/zsh-t3-shortcuts
```

### Restart your shell or run
```zsh
zinit reload
```

### Install with Oh-My-Zsh
```zsh
git clone https://github.com/murat-yasar/zsh-t3-shortcuts \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-t3-shortcuts
```

### Add the plugin to .zshrc
```zsh
plugins=(plugin1 plugin2 ... zsh-t3-shortcuts)
```

### Reload
```zsh
source ~/.zshrc
```

##  Commands

### up <number>
> Go up N directories.
```zsh
up 3
```

### t3pr
> Jump to TYPO3 project root.
```zsh
t3pr
```

### t3sp
> Jump to packages/site-package
```zsh
t3sp
```


## Requirements

- Zsh

- TYPO3 (v12 and higher) project structure