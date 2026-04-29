# Portfolio Andressa Juliani

Portfolio estatico em HTML/CSS/JS, pronto para publicar na Vercel.

## Estrutura

- `portfolio-andressa-standalone.html`: pagina principal.
- `andressa-case-*.html`: paginas dos cases.
- `andressa-case-theme.css`: estilos compartilhados dos cases.
- `images/`: imagens usadas no portfolio.
- `vercel.json`: configura a rota `/` para abrir o portfolio principal.

## Rodar localmente

Abra `portfolio-andressa-standalone.html` no navegador ou use um servidor estatico:

```bash
npx serve .
```

## Subir no GitHub

```bash
git init
git add .
git commit -m "Initial portfolio"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/NOME-DO-REPO.git
git push -u origin main
```

## Publicar na Vercel

1. Acesse <https://vercel.com/new>.
2. Importe o repositorio do GitHub.
3. Em **Framework Preset**, escolha `Other`.
4. Deixe **Build Command** vazio.
5. Deixe **Output Directory** vazio ou como `.`.
6. Clique em **Deploy**.

A rota `/` sera redirecionada internamente para `portfolio-andressa-standalone.html`.
