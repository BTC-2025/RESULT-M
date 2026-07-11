/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        darkBg: "#0B0F19",
        panelBg: "rgba(17, 24, 39, 0.7)",
        accentPurple: "#8B5CF6",
        accentViolet: "#6D28D9",
        accentIndigo: "#4F46E5",
        accentRose: "#F43F5E",
        textPrimary: "#F3F4F6",
        textSecondary: "#9CA3AF",
        borderDark: "rgba(31, 41, 55, 0.6)",
      },
      backdropBlur: {
        xs: "2px",
      },
      fontFamily: {
        sans: ["var(--font-sans)", "Inter", "sans-serif"],
      },
      boxShadow: {
        glass: "0 8px 32px 0 rgba(0, 0, 0, 0.37)",
        glow: "0 0 15px rgba(139, 92, 246, 0.15)",
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
      }
    },
  },
  plugins: [],
};
