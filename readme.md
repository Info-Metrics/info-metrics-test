# Foundations of Info-Metrics website

Source for [info-metrics.org](https://info-metrics.org), the companion site for *Foundations of Info-Metrics*. It is a static site built with [Foundation for Sites](https://get.foundation/sites) 6, Panini (Handlebars) templates, and a Gulp build.

## Requirements

- [Node.js](https://nodejs.org/) and [Yarn](https://classic.yarnpkg.com/) (or npm)
- [Bower](https://bower.io/) for front-end libraries: `npm install --global bower`
- [Git](https://git-scm.com/)

## Setup

```bash
yarn install
bower install
```

## Development

```bash
npm start
```

This builds the site into `dist/`, serves it at http://localhost:8000, and rebuilds when files in `src/` change.

## Project layout

- `src/pages/`: one HTML file per page; front matter sets the page `title`
- `src/layouts/default.html`: shared page shell, including per-page scripts
- `src/partials/`: header, navigation, footer
- `src/assets/`: Sass, JavaScript, images, fonts, and downloadable files (code examples, data, sample chapters)
- `config.yml`: dev server port, browser targets, and the asset and library paths used by the build

## Build and deploy

```bash
npm run build    # production build into dist/
npm run deploy   # production build, then publish dist/ to the gh-pages branch
```

The deploy copies `src/CNAME` into `dist/` so the custom domain stays set on GitHub Pages.
