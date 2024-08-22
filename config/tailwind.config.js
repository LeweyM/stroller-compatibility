const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  safelist: [
      'focus:outline-none',
      'shadow-none',
      'focus:shadow-none',
      'h-52',
      'object-scale-down',
      'text-purple-800',
      'bg-purple-800',
  ],
  theme: {
    extend: {
      height: theme => ({
        '112': '28rem',
        '120': '30rem',
      }),
      minHeight: theme => ({
        '80': '20rem',
      }),
      colors: {
        palette: {
          lighter: '#F5F3FF',
          light: '#DDD6FE',
          primary: '#5B21B6',
          dark: '#4C1D95',
        },
      },
      fontFamily: {
        sans: ["JosefinSans"],
      }
    },
  },
  plugins: [
    require('tailwindcss-tables')(),
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
