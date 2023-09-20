import type { Config } from 'tailwindcss'

export default {
  content: ['./app/**/*.{js,jsx,ts,tsx}'],
  theme: {
    spacing: {
      '0': '0',
      '1': '4px',
      '2': '8px',
      '3': '12px',
      '4': '16px',
      '5': '24px',
      '6': '32px',
      '7': '48px',
      '8': '64px',
      '9': '96px',
      DEFAULT: '12px',
    },
    borderRadius: ({ theme }) => ({
      ...theme('spacing'),
      DEFAULT: '0',
    }),
    fontSize: {
      xs: '12px',
      sm: '14px',
      base: '16px',
      lg: '18px',
      xl: '20px',
      '2xl': '24px',
      '3xl': '30px',
      '4xl': '36px',
      '5xl': '48px',
      DEFAULT: '16px',
    },
    colors: {
      primary: {
        900: '#000810',
        800: '#00262A',
        700: '#00434A',
        600: '#005F6B',
        500: '#007B8F',
        400: '#3EAFCA',
        300: '#76C7DB',
        200: '#AEDFEC',
        100: '#E6F8FB',
        DEFAULT: '#007B8F'
      },
      gray: {
        900: '#1C1C1E',
        800: '#2D2D30',
        700: '#4C4C4F',
        600: '#6D6D70',
        500: '#8E8E91',
        400: '#AFAFB2',
        300: '#D0D0D2',
        200: '#EAEAEC',
        100: '#F7F7F9',
        DEFAULT: '#8E8E91'
      },
    },
  },
  plugins: [],
} satisfies Config
