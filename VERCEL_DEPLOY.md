# Vercel Deployment Guide

Este projeto está configurado para deploy automático na Vercel.

## Configuração Inicial

### 1. Criar conta na Vercel
- Acesse [vercel.com](https://vercel.com)
- Faça login com sua conta GitHub

### 2. Criar novo projeto na Vercel
- Clique em "Add New Project"
- Importe o repositório `flutter_estadios`
- **NÃO clique em Deploy ainda**

### 3. Obter tokens necessários

#### VERCEL_TOKEN
1. Vá em Settings → Tokens
2. Crie um novo token
3. Copie o token gerado

#### VERCEL_ORG_ID e VERCEL_PROJECT_ID
1. No terminal, instale Vercel CLI: `npm i -g vercel`
2. Execute: `vercel link`
3. Siga as instruções para conectar ao projeto
4. Os IDs estarão em `.vercel/project.json`

### 4. Configurar Secrets no GitHub
1. Vá em Settings → Secrets and variables → Actions
2. Adicione os seguintes secrets:
   - `VERCEL_TOKEN`: Token criado no passo 3
   - `VERCEL_ORG_ID`: ID da organização
   - `VERCEL_PROJECT_ID`: ID do projeto

### 5. Deploy Manual (Opcional)
```bash
# Build local
flutter build web --release

# Deploy via CLI
cd build/web
vercel --prod
```

## Deploy Automático

Após configurar os secrets, cada push para a branch `main` irá:
1. Fazer build do Flutter Web
2. Deploy automático na Vercel
3. URL de produção será atualizada

## URLs

- **Produção**: Será fornecida pela Vercel após primeiro deploy
- **Preview**: Cada PR terá uma URL de preview automática

## Troubleshooting

### Build falha na Vercel
- Verifique se o Flutter SDK está disponível no ambiente
- Considere usar Docker ou build local + deploy

### Rotas não funcionam
- Verifique se `vercel.json` está configurado corretamente
- As rotas SPA devem redirecionar para `index.html`

### Performance
- Use `--web-renderer canvaskit` para melhor performance
- Configure cache headers no `vercel.json`
