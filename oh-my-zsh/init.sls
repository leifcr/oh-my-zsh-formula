{%- set oh_my_zsh = salt['pillar.get']('oh-my-zsh') -%}
{%- if oh_my_zsh is defined %}
include:
  - oh-my-zsh.zsh
{% for username, user in salt['pillar.get']('oh-my-zsh:users', {}).items() %}
{%- set user_home_folder = salt['user.info'](user.username).home -%}
change_shell_{{user.username}}:
  module.run:
    - name: user.chshell
    - m_name: {{ user.username }}
    - shell: /usr/bin/zsh
    - onlyif: "test -d {{ user_home_folder }} && test $(getent passwd {{ user.username }} | cut -d: -f7 ) != '/usr/bin/zsh'"

clone_oh_my_zsh_repo_{{user.username}}:
  git.latest:
    - name: https://github.com/robbyrussell/oh-my-zsh.git
    - rev: master
    - target: "{{ user_home_folder }}/.oh-my-zsh"
    - unless: "test -d {{ user_home_folder }}/.oh-my-zsh"
    - onlyif: "test -d {{ user_home_folder }}"
    - require_in:
      - file: zshrc_{{user.username}}
    - require:
      - pkg: zsh

set_oh_my_zsh_folder_and_file_permissions_{{user.username}}:
  file.directory:
    - name: "{{ user_home_folder }}/.oh-my-zsh"
    - user: {{user.username}}
    - group: {{user.group}}
    - file_mode: 744
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: clone_oh_my_zsh_repo_{{user.username}}
    - require_in:
      - file: zshrc_{{user.username}}
    - onlyif: "test -d {{ user_home_folder }}"

zshrc_{{user.username}}:
  file.managed:
    - name: "{{ user_home_folder }}/.zshrc"
    - source: salt://oh-my-zsh/files/.zshrc.jinja2
    - user: {{ user.username }}
    - group: {{ user.group }}
    - mode: '0644'
    - template: jinja
    - onlyif: "test -d {{ user_home_folder }}"
    - context:
      theme: {{ user.theme }}
      disable-auto-update: {{ user['disable-auto-update'] }} 
      disable-update-prompt: {{ user['disable-update-prompt'] }}
      disable-untracked-files-dirty: {{ user.plugins }}
      plugins: {{ user.plugins }}


{% endfor %}
{% endif %}
