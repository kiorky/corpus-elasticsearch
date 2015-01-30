

es-sav-project-dir:
  cmd.run:
    - name: |
            if [ ! -d "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project" ];then
              mkdir -p "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project";
            fi;
            rsync -Aa --delete "/srv/projects/es/project/" "/srv/projects/es/archives/2015-01-30_18_26-06_ad5c4a8f-15fe-4bdc-90c9-8fdd58c0bb9d/project/"
    - user: root
