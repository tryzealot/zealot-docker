# Zealot Docker 镜像仓库

## 依赖 Requirements

- Docker 20.10.0+
- Docker Compose 2.0.1+

## 部署 Deploy

```sh
[sudo] ./deploy
```

简单的来说直接执行 `./deploy` 一键生成脚本，之后检查下 `.env` 文件无误后再执行 `docker-compose up -d` 就大功告成了！

you just need to run the ./deploy script to automatically generate it, then check the .env file for any errors before executing docker-compose up -d to complete the process!

## 升级 Upgrade

```sh
[sudo] ./deploy
```

## 备份 Backup

```sh
[sudo] ./backup
```

更为详细的说明请移步[部署文档](https://zealot.ews.im/zh-Hans/docs/self-hosted/deployment/docker)。

For more detailed instructions, please refer to the [Deployment Documentation](https://zealot.ews.im/zh-Hans/docs/self-hosted/deployment/docker).
