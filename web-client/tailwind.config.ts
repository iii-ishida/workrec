import type { Config } from 'tailwindcss'

export default {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  theme: {
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
    },
    colors: {
      primary: {
        900: '#000F3D',
        800: '#081B54',
        700: '#203679',
        600: '#193894',
        500: '#3858B7',
        400: '#7F96E1',
        300: '#C3D0F9',
        200: '#E1E8FE',
        100: '#F5F7FF',
        DEFAULT: '#3858B7',
      },
      gray: {
        900: '#1C1C1E',
        800: '#3A3A3C',
        700: '#48484A',
        600: '#636366',
        500: '#8E8E93',
        400: '#AEAEB2',
        300: '#CFCFD3',
        200: '#F4F4F6',
        100: '#F9F9FB',
        DEFAULT: '#8E8E93',
      }
    },
  },
  plugins: [],
} satisfies Config
