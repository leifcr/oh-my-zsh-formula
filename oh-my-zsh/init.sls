{%- set oh_my_zsh = salt['pillar.get']('oh-my-zsh') -%}
{%- if oh_my_zsh is defined %}
include:
  - oh-my-zsh.zsh
{% for username, user in salt['pillar.get']('oh-my-zsh:users', {}).items() %}
{%- set user_home_folder = oh_my_zsh.get('home', '/home') + '/' + user['username'] -%}
change_shell_{{user.username}}:
  module.run:
    - name: user.chshell
    - m_name: {{ user.username }}
    - shell: /usr/bin/zsh
    - unless: "test $(getent passwd {{ user.username }} | cut -d: -f7 ) = '/usr/bin/zsh'"
    - onlyif: "test -d {{ user_home_folder }}"

clone_oh_my_zsh_repo_{{user.username}}:
  git.latest:
    - name: https://github.com/robbyrussell/oh-my-zsh.git
    - rev: master
    - target: "{{ oh_my_zsh['home'] }}/{{user.username}}/.oh-my-zsh"
    - unless: "test -d {{ user_home_folder }}/.oh-my-zsh"
    - onlyif: "test -d {{ user_home_folder }}"
    - require_in:
      - file: zshrc_{{user.username}}
    - require:
      - pkg: zsh

zshrc_{{user.username}}:
  file.managed:
    - name: "{{ oh_my_zsh['home'] }}/{{user.username}}/.zshrc"
    - source: salt://oh-my-zsh/files/.zshrc.jinja2
    - user: {{ user.username }}
    - group: {{ user.group }}
    - mode: '0644'
    - template: jinja
    - onlyif: "test -d {{ user_home_folder }}"

{% endfor %}
{% endif %}
