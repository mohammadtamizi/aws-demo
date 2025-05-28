# AWS Presentation Landing Page

An Apple-inspired landing page for AWS presentations featuring a minimalist design with QR code, presentation download, and LinkedIn connection.

## Features

- 🎨 Apple-inspired minimalist design
- 📱 Fully responsive layout
- 🔄 QR code that updates dynamically based on the current URL
- 📥 Presentation download button
- 🔗 LinkedIn connection link
- 🔒 Authentication with Clerk
- 🚀 Backend powered by Convex

## Tech Stack

- [Next.js](https://nextjs.org/) - React framework
- [TypeScript](https://www.typescriptlang.org/) - Type-safe JavaScript
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS framework
- [Shadcn UI](https://ui.shadcn.com/) - UI component library
- [Convex](https://www.convex.dev/) - Backend development platform
- [Clerk](https://clerk.dev/) - Authentication and user management
- [Lucide React](https://lucide.dev/) - Icons

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd aws-demo
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   - Create a `.env.local` file based on `.env.example`
   - Configure your Clerk and Convex credentials

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Deployment

This project can be deployed on platforms like Vercel, Netlify, or using custom hosting. See [Convex Docs](https://docs.convex.dev/production/hosting/) for more details on deployment options.

## License

[MIT](LICENSE)
