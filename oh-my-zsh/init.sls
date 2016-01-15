include: 
  - oh-my-zsh.zsh
{{ for username, user in pillar['oh-my-zsh']['users'] }}
change_shell_{{user.username}}:
  module.run:
    - name: user.chshell
    - m_name: {{ user.username }}
    - shell: /usr/bin/zsh

clone_oh_my_zsh_repo_{{user.username}}:
  git.latest:
    - name: https://github.com/robbyrussell/oh-my-zsh.git:
    - rev: master
    - target: "{{ pillar['oh-my-zsh']['home'] }}/{{user.username}}/.oh-my-zsh"
    - unless: "test -d {{ pillar['oh-my-zsh']['home'] }}/{{user.username}}/.oh-my-zsh"

.zshrc_{{user.username}}:
  file.managed:
    - name: "{{ pillar['oh-my-zsh']['home'] }}/{{user.username}}/.zshrc"
    - source: salt://oh-my-zsh/files/.zshrc
    - user: {{ user.username }}
    - group: {{ user.group }}
    - mode: '0644'
    - template: jinja

{{ endfor }}

