# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import intellij with context %}
{%- from tplroot ~ "/files/macros.jinja" import format_kwargs with context %}

    {% if grains.kernel|lower == 'linux' %}

intellij-linuxenv-home-file-symlink:
  file.symlink:
    - name: /opt/intellij
    - target: {{ intellij.pkg.archive.name }}
    - onlyif: test -d '{{ intellij.pkg.archive.name }}'
    - force: True

        {% if intellij.linux.altpriority|int > 0 and grains.os_family not in ('Arch',) %}

intellij-linuxenv-home-alternatives-install:
  alternatives.install:
    - name: intellijhome
    - link: /opt/intellij
    - path: {{ intellij.pkg.archive.name }}
    - priority: {{ intellij.linux.altpriority }}
    - retry: {{ intellij.retry_option|json }}

intellij-linuxenv-home-alternatives-set:
  alternatives.set:
    - name: intellijhome
    - path: {{ intellij.pkg.archive.name }}
    - onchanges:
      - alternatives: intellij-linuxenv-home-alternatives-install
    - retry: {{ intellij.retry_option|json }}

intellij-linuxenv-executable-alternatives-install:
  alternatives.install:
    - name: intellij
    - link: {{ intellij.linux.symlink }}
    - path: {{ intellij.pkg.archive.name }}/{{ intellij.command }}
    - priority: {{ intellij.linux.altpriority }}
    - require:
      - alternatives: intellij-linuxenv-home-alternatives-install
      - alternatives: intellij-linuxenv-home-alternatives-set
    - retry: {{ intellij.retry_option|json }}

intellij-linuxenv-executable-alternatives-set:
  alternatives.set:
    - name: intellij
    - path: {{ intellij.pkg.archive.name }}/{{ intellij.command }}
    - onchanges:
      - alternatives: intellij-linuxenv-executable-alternatives-install
    - retry: {{ intellij.retry_option|json }}

        {%- else %}

intellij-linuxenv-alternatives-install-unapplicable:
  test.show_notification:
    - text: |
        Linux alternatives are turned off (intellij.linux.altpriority=0),
        or not applicable on {{ grains.os or grains.os_family }} OS.
        {% endif %}
    {% endif %}
