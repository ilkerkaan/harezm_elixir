# Harezm Website Project Notes

## Current Status (Updated: 2024-04-06)
✅ Initial Setup Complete:
- Phoenix project structure created
- PostgreSQL database configured and tested
- Git repository initialized
- Basic development environment set up
- TailwindCSS configured
- Basic navigation implemented
- Contact page created
- Modern homepage design

## Implementation Progress

1. **Core Website Setup** (Phase 1 - ✅ Completed)
   - Project initialization with Phoenix
   - Database setup
   - Basic layout and navigation
   - Modern UI with TailwindCSS
   - Homepage with hero section
   - Contact page with form
   - Responsive navigation

2. **Admin Panel** (Phase 1 - Current Focus)
   - Authentication with Ash Framework
   - Dashboard layout
   - Service management
   - Contact form submissions management
   - User management
   - Content management system
   - Role-based access control
   - Dynamic content management

3. **Services & Contact Integration** (Phase 1 - Next)
   - Services page with selection functionality
   - Contact form with service integration
   - Admin panel for submissions
   - Email notifications
   - Service management interface

4. **Additional Features** (Phase 2 - Future)
   - Blog system
   - E-commerce integration
   - Chat functionality
   - Analytics
   - Media uploads
   - SEO optimization
   - Rich text editor
   - Content scheduling

## Project Structure

### Domain Layer (`lib/harezm/`)
- Resources directory (`resources/`)
  - Each resource (e.g., `user.ex`, `service.ex`, `contact.ex`)
  - Resource-specific policies
- Registry (`registry.ex`)
  - Central place to register all resources
- API modules (`admin.ex`, `accounts.ex`)
  - Public interfaces for resource operations
  - Aggregates related resources

### Web Layer (`lib/harezm_web/`)
- LiveView modules (`live/`)
  - Page-specific live views
  - Reusable live components
- Components (`components/`)
  - Stateless UI components
  - Form components
- Templates (`templates/`)
  - Layout templates
  - Static page templates

## Technology Stack
- Phoenix Framework (latest stable)
- PostgreSQL 14+
- TailwindCSS 3
- LiveView
- Ash Framework (for admin panel)

## Development Guidelines

### Code Organization
1. **Phoenix Structure**
   - Context-based organization for business logic
   - LiveView .heex templates and component-based architecture
   - Telemetry instrumentation
   - No inline CSS in templates
   - No direct Ecto calls from views or LiveViews
   - No business logic in controllers

2. **Ash Framework Structure**
   - Resource-based domain modeling using AshPostgres.DataLayer
   - Policy-driven authorization and validations
   - Action-specific filters and preparations
   - Organization under `lib/harezm/resources/`
   - No embedding business logic in schema definitions
   - No bypassing Ash policies with raw Ecto queries
   - Resources pattern: `lib/harezm/resources/{resource}.ex`
   - Policies: attribute-based role access control

3. **Frontend Structure**
   - Utility-first CSS approach with Tailwind
   - Design tokens in `tailwind.config.js`
   - Shared components in `/lib/harezm_web/components`
   - LiveView JS hooks for interactivity

### Technical Implementation
1. **Core Features**
   - Oban for background jobs
   - Phoenix Presence for real-time features
   - PubSub for message broadcasting
   - Modular service design

2. **Best Practices**
   - Follow Elixir style guide
   - Write clear documentation
   - Maintain test coverage
   - Regular code reviews
   - Git commit conventions

## Development Environment
- Elixir 1.15+
- Erlang/OTP 26+
- PostgreSQL 14+
- Node.js 18+ (for asset compilation)

## Setup Instructions
```bash
# Clone repository
git clone [repository_url]
cd harezm_elixir

# Install dependencies
mix deps.get

# Setup database
mix ecto.setup

# Start server
mix phx.server
```

## Deployment Notes
- Keep all dependencies updated to latest stable versions
- Follow semantic versioning
- Document all significant changes
- Regular security updates
- Backup database regularly
- SSL configuration in production
- Environment variables management
- Database migration strategy
- Continuous deployment setup
