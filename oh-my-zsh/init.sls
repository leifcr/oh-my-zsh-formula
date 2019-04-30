{%- set defaults = salt['pillar.get']('oh-my-zsh') -%}

{%- if defaults is defined %}
include:
  - oh-my-zsh.zsh
{% for username, user in defaults.get('users', {}).items() %}

{%- set user_home_folder = salt['user.info'](username).home -%}
{%- set group = user.get('group', username) -%}

change_shell_{{username}}:
  module.run:
    - name: user.chshell
    - m_name: {{ username }}
    - shell: /usr/bin/zsh
    - onlyif: "test -d {{ user_home_folder }} && test $(getent passwd {{ username }} | cut -d: -f7 ) != '/usr/bin/zsh'"

clone_oh_my_zsh_repo_{{username}}:
  git.latest:
    - name: https://github.com/robbyrussell/oh-my-zsh.git
    - rev: master
    - target: "{{ user_home_folder }}/.oh-my-zsh"
    - unless: "test -d {{ user_home_folder }}/.oh-my-zsh"
    - onlyif: "test -d {{ user_home_folder }}"
    - require_in:
      - file: zshrc_{{username}}
    - require:
      - pkg: zsh

set_oh_my_zsh_folder_and_file_permissions_{{username}}:
  file.directory:
    - name: "{{ user_home_folder }}/.oh-my-zsh"
    - user: {{username}}
    - group: {{ group }}
    - file_mode: 744
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: clone_oh_my_zsh_repo_{{username}}
    - require_in:
      - file: zshrc_{{username}}
    - onlyif: "test -d {{ user_home_folder }}"

zshrc_{{username}}:
  file.managed:
    - name: "{{ user_home_folder }}/.zshrc"
    - source: salt://oh-my-zsh/files/.zshrc.jinja2
    - user: {{ username }}
    - group: {{ group }}
    - mode: '0644'
    - template: jinja
    - onlyif: "test -d {{ user_home_folder }}"
    - context:
      theme:  {{ user.get('theme', defaults.get('theme', 'robbyrussell')) }}
      disable_auto_update: {{ user.get('disable-auto-update', defaults.get('disable-auto-update', True)) }}
      disable_update_prompt:  {{ user.get('disable-update-prompt', defaults.get('disable-update-prompt', False)) }}
      disable_untracked_files_dirty:  {{ user.get('disable-untracked-files-dirty', defaults.get('disable-untracked-files-dirty', False)) }}
      plugins:  {{ user.get('plugins', defaults.get('plugins', {})) }}

{% endfor %}
{% endif %}
