# CHANGELOG

## 0.2.0 (2018/09/27)

- Add new os_type options: ubuntu-16.04, ubuntu-18.04 (#38)

## 0.1.0 (2018/09/10)

- Use usacloud config (#28)
- Use TravisCI (#29)
- Add startup script config (#31)
- Add packer filter config (#32)
- Add os_type config (#33)
- Add sakura-reinstall command (#36)
- Add enable_pw_auth config (#37)

## 0.0.9 (2018/07/13)

### General

- Git repo moved from tsahara/vagrant-sakura to sacloud/vagrant-sakura (#12)

### Core

- Update default settings (#9, #16)
- Add tags and description parameter (#11)
- Supports `SAKURACLOUD_*` environment variables (#18)

### Misc.

- Update docs (#8)
- Add detail error message (#10)
- Set User-Agent header (#13)

## 0.0.8 (2016/05/12)

- Update default disk archive.

## 0.0.7 (2015/02/19)

- Update CA certificate for secure.sakura.ad.jp.

## 0.0.6 (2014/07/14)

- Add `public_key_path` and `use_insecure_key` configuration parameters.

## 0.0.5 (2014/04/19)

- Fix Vagrant 1.5 compatibility.
- Update default disk archive.

## 0.0.4 (2013/11/06)

- Support `disk_id` configuration to reuse Disk resource.

## 0.0.3 (2013/10/22)

- Support `provision` command.

## 0.0.2 (2013/10/08)

- Add `vagrant sakura-list-id` command.
- Support `zone_id` configuration.

## 0.0.1 (2013/10/07)

- Initial release.
