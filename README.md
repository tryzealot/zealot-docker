# Zealot Docker 镜像仓库

## 依赖

- Docker 20.10.0+
- Docker Compose 1.28.0+

## 部署

```sh
[sudo] ./deploy
```

简单的来说直接执行 `./deploy` 一键生成脚本，之后检查下 `.env` 文件无误后再执行 `docker-compose up -d` 就大功告成了！

## 升级

```sh
[sudo] ./upgrade
```

## 备份

```sh
[sudo] ./backup
```

更为详细的说明请移步[部署文档](https://zealot.ews.im/#/deployment)。
