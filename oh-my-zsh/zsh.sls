{% if grains['os_family'] == 'RedHat' %}
include:
  - epel
{% endif %}

zsh:
  pkg:
    - installed
    - name: zsh
    {% if grains['os_family'] == 'RedHat' %}
    - fromrepo: epel
    - require:
      - pkg: epel
    {% endif %}
