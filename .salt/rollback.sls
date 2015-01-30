


es-rollback-faileproject-dir:
  cmd.run:
    - name: |
            if [ -d "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project" ];then
              rsync -Aa --delete "/srv/projects/es/project/" "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project.failed/"
            fi;
    - user: es-user

es-rollback-project-dir:
  cmd.run:
    - name: |
            if [ -d "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project" ];then
              rsync -Aa --delete "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project/" "/srv/projects/es/project/"
            fi;
    - user: es-user
    - require:
      - cmd:  es-rollback-faileproject-dir
