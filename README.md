# AWS Todo App

## 概要

Flask で作成した Todo Web アプリを、AWS 上に構築した個人学習プロジェクトです。  
Terraform を用いて AWS リソースを構築し、ECS Fargate 上でアプリを実行しています。

RDS PostgreSQL、S3、ALB、Route53、ACM などを利用し、Web アプリの基本的なデプロイ構成を学習しました。  
また、GitHub Actions と Amazon ECR を利用し、コンテナイメージのビルド・プッシュ・デプロイの流れも学習しています。

## 使用技術

- Python / Flask
- Docker
- AWS
  - ECS Fargate
  - ECR
  - ALB
  - RDS PostgreSQL
  - S3
  - Route53
  - ACM
  - CloudWatch Logs
- Terraform
- GitHub Actions

## 機能

- Todo の追加 / 編集 / 削除
- 完了状態の切り替え
- 画像アップロード
- S3 への画像保存
- HTTPS 対応

## アーキテクチャ

```text
User
 ↓
Route53
 ↓
ALB (HTTPS)
 ↓
ECS Fargate (Flask)
 ├─ RDS PostgreSQL
 └─ S3 (Image Upload)

GitHub Actions
 ↓
Amazon ECR
 ↓
ECS Deploy