# app_template.rb
#
# A Rails 7 template that installs:
#  - Devise for authentication
#  - Vite for asset bundling
#  - React
#  - TailwindCSS (using tailwindcss-rails)
#  - turbo-mount for embedding React in Rails views

# -----------------------------------------------------------------------------
# 1. Add needed gems to the Gemfile
# -----------------------------------------------------------------------------
gem 'devise', '~> 4.9'
gem 'vite_rails', '~> 3.0'
gem 'turbo-mount', '~> 0.4.1'
gem 'tailwindcss-rails', '~> 3.0'

# -----------------------------------------------------------------------------
# 2. AFTER BUNDLE:
#    - run installers
#    - generate Devise configs and model
#    - install Vite + React
#    - install Tailwind
#    - install turbo-mount
# -----------------------------------------------------------------------------
after_bundle do
  say "=== Running post-bundle setup ===", :green

  # 2.1 Setup the database
  rails_command "db:create"
  rails_command "db:migrate"

  # 2.2 Devise install + generate user model
  generate "devise:install"
  generate "devise", "User"

  # This is optional if you want to auto-run migrations for Devise
  rails_command "db:migrate"

  # 2.3 Install Vite and React
  say "=== Installing Vite and React ===", :green
  run "bundle exec vite install"
  
  # Add @vitejs/plugin-react
  run "npm install react react-dom @vitejs/plugin-react @types/react @types/react-dom " 
  run "npm install -D @vitejs/plugin-react"
  run "npm install tailwind autoprefixer shadcn@latest tailwindcss-animate @tailwindcss/typography @tailwindcss/container-queries @tailwindcss/forms turbo-mount stimulus-vite-helpers clsx tailwind-merge @hotwired/turbo-rails vite-plugin-ruby postcss"
  run "npx tailwindcss init -p"

  remove_file "tailwind.config.js" 
  create_file "tailwind.config.js", <<~JS 
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  darkMode: ['class'],
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,jsx,ts,tsx}',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          'Inter var',
          ...defaultTheme.fontFamily.sans
        ]
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)'
      },
      colors: {
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))'
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))'
        },
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))'
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))'
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))'
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))'
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))'
        },
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        chart: {
          '1': 'hsl(var(--chart-1))',
          '2': 'hsl(var(--chart-2))',
          '3': 'hsl(var(--chart-3))',
          '4': 'hsl(var(--chart-4))',
          '5': 'hsl(var(--chart-5))'
        }
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require("tailwindcss-animate")
  ]
}
  JS


  remove_file "vite.config.js" 
  create_file "vite.config.js", <<~JS
import path from 'path'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [
    react(),
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./app/javascript"),
    },
  },
})

  JS

  create_file "tsconfig.json", <<~JS 
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./app/javascript/*"]
    }
  }
}
  JS
  create_file "tsconfig.app.json", <<~JS 

  {
  "compilerOptions": {
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.app.tsbuildinfo",
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true,
    "compilerOptions": {
      "baseUrl": ".",
      "paths": {
        "@/*": ["./app/javascript/*"]
      }
    }
  },
    "compilerOptions": {
      "baseUrl": ".",
      "paths": {
        "@/*": ["./app/javascript/*"]
      }
    },
  "include": ["app/javascript/**/*"] 
}

  JS
  create_file "tsconfig.node.json", <<~JS 
  {
  "compilerOptions": {
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.node.tsbuildinfo",
    "target": "ES2022",
    "lib": ["ES2023"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true
  },
  "include": ["vite.config.ts"]
}
  JS

  # Add react() to the plugins array
  inject_into_file "vite.config.js", after: "plugins: [" do
    <<~JS
      \n    react(),
    JS
  end

  # 2.4 Install Tailwind (using tailwindcss-rails gem)
  say "=== Installing TailwindCSS ===", :green
  rails_command "tailwindcss:install"

  # (Optional) If using Vite for CSS, you may want to move tailwind import
  # to app/javascript/stylesheets/tailwind.css or similar. For example:
  remove_file "app/assets/stylesheets/application.tailwind.css", force: true
  remove_file "app/javascript/application.js"
  remove_file "app/javascript/controllers/index.js"
  create_file "app/javascript/controllers/index.js", <<~JS 
import { application } from "./application"
import { registerControllers } from "stimulus-vite-helpers";

const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
registerControllers(application, controllers);
  JS

  run "mkdir -p app/javascript/stylesheets"
  create_file "app/javascript/stylesheets/tailwind.css", <<~CSS
    @import "tailwindcss/base";
    @import "tailwindcss/components";
    @import "tailwindcss/utilities";
  CSS

  create_file "app/javascript/entrypoints/application.css", <<~CSS 
@tailwind base;
@tailwind components;
@tailwind utilities;

/* ... */

@layer base {
  :root {

    --background: 0 0% 100%;

    --foreground: 0 0% 3.9%;

    --card: 0 0% 100%;

    --card-foreground: 0 0% 3.9%;

    --popover: 0 0% 100%;

    --popover-foreground: 0 0% 3.9%;

    --primary: 0 0% 9%;

    --primary-foreground: 0 0% 98%;

    --secondary: 0 0% 96.1%;

    --secondary-foreground: 0 0% 9%;

    --muted: 0 0% 96.1%;

    --muted-foreground: 0 0% 45.1%;

    --accent: 0 0% 96.1%;

    --accent-foreground: 0 0% 9%;

    --destructive: 0 84.2% 60.2%;

    --destructive-foreground: 0 0% 98%;

    --border: 0 0% 89.8%;

    --input: 0 0% 89.8%;

    --ring: 0 0% 3.9%;

    --chart-1: 12 76% 61%;

    --chart-2: 173 58% 39%;

    --chart-3: 197 37% 24%;

    --chart-4: 43 74% 66%;

    --chart-5: 27 87% 67%;

    --radius: 0.5rem
  }
  .dark {

    --background: 0 0% 3.9%;

    --foreground: 0 0% 98%;

    --card: 0 0% 3.9%;

    --card-foreground: 0 0% 98%;

    --popover: 0 0% 3.9%;

    --popover-foreground: 0 0% 98%;

    --primary: 0 0% 98%;

    --primary-foreground: 0 0% 9%;

    --secondary: 0 0% 14.9%;

    --secondary-foreground: 0 0% 98%;

    --muted: 0 0% 14.9%;

    --muted-foreground: 0 0% 63.9%;

    --accent: 0 0% 14.9%;

    --accent-foreground: 0 0% 98%;

    --destructive: 0 62.8% 30.6%;

    --destructive-foreground: 0 0% 98%;

    --border: 0 0% 14.9%;

    --input: 0 0% 14.9%;

    --ring: 0 0% 83.1%;

    --chart-1: 220 70% 50%;

    --chart-2: 160 60% 45%;

    --chart-3: 30 80% 55%;

    --chart-4: 280 65% 60%;

    --chart-5: 340 75% 55%
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}


  CSS
  remove_file "app/javascript/entrypoints/application.js"
  create_file "app/javascript/entrypoints/application.js", <<~JS
import "@hotwired/turbo-rails"
import "../controllers"
import "./turbo-mount"
import "./application.css"

console.log("Hello from application.js")
  JS


  # 2.5 Install turbo-mount
  say "=== Installing turbo-mount ===", :green
  generate "turbo_mount:install"

  remove_file "app/javascript/turbo-mount.js"
  create_file "app/javascript/entrypoints/turbo-mount.js", <<~JS

import { TurboMount } from "turbo-mount";
import { registerComponent } from "turbo-mount/react";
import { Hello } from "@/components/Hello";
const turboMount = new TurboMount(); // or new TurboMount({ application })

registerComponent(turboMount, "Hello", Hello);

  JS

  run "mkdir -p app/javascript/components"
  create_file "app/javascript/components/Hello.tsx", <<~TSX
    import React from 'react';

    export function Hello(props) {
      return (
        <div className="p-4 bg-green-50 border rounded">
          <h1 className="text-xl font-bold">Hello {props.name}!</h1>
          <p>This is a turbo-mounted React component.</p>
        </div>
      );
    }
  TSX

  generate :controller, "home", "index", "--skip-routes", "--no-helper", "--no-assets"

  route "root to: 'home#index'"

  remove_file "app/views/home/index.html.erb", force: true
  create_file "app/views/home/index.html.erb", <<~ERB
    <h2>Welcome to the Home#index page!</h2>
    <%= turbo_mount('Hello', props: { name: 'Rails Developer' }) %>
  ERB

  insert_into_file "app/views/layouts/application.html.erb",
                   after: "<%= csrf_meta_tags %>\n" do
    <<~ERB
      <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
      <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
      <%= javascript_importmap_tags %>
      <%= vite_client_tag %>
      <%= vite_javascript_tag 'application' %>


    ERB
  end

  run "npx shadcn@latest init"
  say "=== Setup Complete ===", :green
  say "Now you can run the server with: bin/rails server", :yellow
  say "Visit http://localhost:3000 to see the example turbo-mounted React component.", :yellow
end

