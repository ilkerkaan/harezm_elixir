# Harezm Website Project Notes

## Implementation Order

1. **Core Website Setup** (Phase 1 - Immediate)
   - Project initialization with Phoenix and Ash
   - Database setup
   - Basic layout and navigation
   - Pure Elixir UI with Surface UI

2. **Services & Contact Integration** (Phase 1 - Immediate)
   - Services page with selection functionality
   - Contact form with service integration
   - Admin panel for submissions
   - Email notifications
   Implementation details in "Service Selection & Contact Form Integration" section

3. **Admin Panel** (Phase 1 - Immediate)
   - Authentication
   - Dashboard
   - Service management
   - Contact form submissions management
   - User management

4. **Additional Features** (Phase 2)
   - Blog system
   - E-commerce integration
   - Chat functionality
   - Analytics

## Implementation Guidelines

### Project Structure
1. **Domain Layer** (`lib/harezm/`)
   - Resources directory (`resources/`)
     - Each resource (e.g., `user.ex`, `post.ex`)
     - Resource-specific policies
   - Registry (`registry.ex`)
     - Central place to register all resources
   - API modules (`blog.ex`, `accounts.ex`)
     - Public interfaces for resource operations
     - Aggregates related resources

2. **Web Layer** (`lib/harezm_web/`)
   - LiveView modules (`live/`)
     - Page-specific live views
     - Reusable live components
   - Components (`components/`)
     - Stateless UI components
     - Form components
   - Templates (`templates/`)
     - Layout templates
     - Static page templates

### Code Organization
1. **Phoenix Structure**
   - Context-based organization for business logic
   - LiveView .heex templates and component-based architecture
   - Telemetry instrumentation
   - Surface component library patterns
   - No inline CSS in templates
   - No direct Ecto calls from views or LiveViews
   - No business logic in controllers

2. **Ash Framework Structure**
   - Resource-based domain modeling using AshPostgres.DataLayer
   - Policy-driven authorization and validations
   - Action-specific filters and preparations
   - Organization under `lib/harez/resources/`
   - No embedding business logic in schema definitions
   - No bypassing Ash policies with raw Ecto queries
   - Resources pattern: `lib/harez/resources/{resource}.ex`
   - Policies: attribute-based role access control

3. **Frontend Structure**
   - Utility-first CSS approach with Tailwind
   - Design tokens in `tailwind.config.js`
   - Shared components in `/lib/harez_web/components`
   - LiveView JS hooks for interactivity

### Resource Implementation Pattern
1. **Resource Definition**
   ```elixir
   defmodule Harezm.Resources.Post do
     use Ash.Resource,
       data_layer: AshPostgres.DataLayer,
       authorizers: [Ash.Policy.Authorizer]

     postgres do
       table "posts"
       repo Harezm.Repo
     end

     attributes do
       uuid_primary_key :id
       attribute :title, :string
       attribute :content, :string
       timestamps()
     end

     relationships do
       belongs_to :author, Harezm.Resources.User
       has_many :comments, Harezm.Resources.Comment
     end

     actions do
       defaults [:create, :read, :update, :destroy]
     end

     policies do
       bypass :read
       policy action_type(:create) do
         authorize_if actor_present()
       end
     end
   end
   ```

2. **API Module Pattern**
   ```elixir
   defmodule Harezm.Blog do
     use Ash.Api

     resources do
       resource Harezm.Resources.Post
       resource Harezm.Resources.Comment
     end
   end
   ```

3. **LiveView Integration**
   ```elixir
   defmodule HarezmWeb.BlogLive.Index do
     use HarezmWeb, :live_view
     use Harezm.Blog

     def mount(_params, _session, socket) do
       posts = Harezm.Blog.read!(Harezm.Resources.Post)
       {:ok, assign(socket, posts: posts)}
     end

     def handle_event("create_post", %{"post" => post_params}, socket) do
       case Harezm.Blog.create(Harezm.Resources.Post, post_params) do
         {:ok, post} ->
           {:noreply, update(socket, :posts, &[post | &1])}
         {:error, error} ->
           {:noreply, put_flash(socket, :error, error)}
       end
     end
   end
   ```

### Technical Implementation
1. **Core Features**
   - Oban for background jobs
   - Phoenix Presence for real-time features
   - PubSub for message broadcasting
   - Modular service design

2. **E-commerce Features** (Future)
   - Ash product catalog resources
   - LiveView cart state management
   - Payment service abstractions

3. **Chat Features** (Future)
   - Phoenix Presence tracking
   - PubSub message broadcasting
   - LiveView JS hooks

## Feature Requirements

### Service Selection & Contact Form Integration (Current Priority)

1. **Services Page Features**
   - Display service cards in a grid layout
   - Each service should have:
     - Title
     - Description
     - Icon
     - Feature list
     - Selection mechanism (radio button/checkbox)
   - Services to include:
     - E-Transformation Products
     - Financial Compliance
     - SAP Banking Solutions
     - Consulting & Project Management
     - SAP FICO Implementation
     - SAP Integration Services
     - SAP Migration & Upgrade
     - SAP Real Estate
     - SAP Analytics
     - SAP Support Services

2. **Service Selection Implementation**
   ```elixir
   defmodule Harezm.Resources.Service do
     use Ash.Resource,
       data_layer: AshPostgres.DataLayer

     attributes do
       uuid_primary_key :id
       attribute :title, :string
       attribute :description, :string
       attribute :icon_name, :string
       attribute :features, {:array, :string}
       timestamps()
     end

     actions do
       defaults [:create, :read, :update, :destroy]
     end
   end
   ```

3. **Contact Form Integration**
   ```elixir
   defmodule Harezm.Resources.ContactForm do
     use Ash.Resource,
       data_layer: AshPostgres.DataLayer

     attributes do
       uuid_primary_key :id
       attribute :first_name, :string
       attribute :last_name, :string
       attribute :email, :string
       attribute :subject, :string
       attribute :message, :string
       attribute :selected_services, {:array, :string}
       timestamps()
     end

     relationships do
       has_many :selected_services, Harezm.Resources.Service,
         through: :selected_services_bridge
     end

     actions do
       defaults [:create, :read, :update, :destroy]
       
       create :submit do
         accept [:first_name, :last_name, :email, :subject, :message, :selected_services]
         argument :selected_service_ids, {:array, :uuid}
         
         change manage_relationship(:selected_services, :selected_service_ids)
         change set_context(:status, "new")
         
         # Add email notification after submission
         after_action :notify_admin
       end
     end

     calculations do
       calculate :full_name, :string, expr(first_name <> " " <> last_name)
     end
   end
   ```

4. **LiveView Implementation**
   ```elixir
   defmodule HarezmWeb.ServiceSelectionLive do
     use HarezmWeb, :live_view
     use Harezm.Services

     def mount(_params, _session, socket) do
       services = Harezm.Services.read!(Harezm.Resources.Service)
       {:ok, assign(socket, services: services, selected_services: [])}
     end

     def handle_event("toggle_service", %{"service_id" => service_id}, socket) do
       selected = socket.assigns.selected_services
       new_selected = if service_id in selected,
         do: List.delete(selected, service_id),
         else: [service_id | selected]
       
       {:noreply, assign(socket, selected_services: new_selected)}
     end

     def handle_event("proceed_to_contact", _params, socket) do
       {:noreply, push_redirect(socket, 
         to: Routes.live_path(socket, HarezmWeb.ContactLive, 
           services: socket.assigns.selected_services))}
     end
   end
   ```

5. **UI Components**
   - Service Card Component
   - Service Selection Radio/Checkbox
   - Contact Form with Pre-filled Services
   - Form Validation
   - Success/Error Notifications

6. **Data Flow**
   a. User visits Services page
   b. Selects desired services
   c. Clicks "Contact Us" button
   d. Redirected to Contact form
   e. Selected services pre-populated in message
   f. Form submission creates ContactForm record
   g. Admin notification sent
   h. User receives confirmation

7. **Admin Features**
   - View all contact form submissions
   - Filter by selected services
   - Export submissions to CSV
   - Mark submissions as processed
   - Reply to submissions

This functionality will be implemented after the basic admin panel and website are working. The implementation will follow our established patterns using Ash Resources, LiveView, and proper separation of concerns.

## Deployment Research (Last Updated: [Current Date])

### Platform Comparison

#### Render
- **Database**: Managed PostgreSQL
  - No local database needed for production
  - Provides `DATABASE_URL` in production
  - SSL connection required
  - Free tier available
- **Deployment**:
  - Supports Docker-based deployments
  - Automated database migrations possible
  - Continuous deployment from GitHub
  - Environment variables management included

#### Gigalixir
- **Database**: Managed PostgreSQL
  - Free tier includes 1 PostgreSQL database
  - Limited to 10,000 rows in free tier
  - No credit card required for free tier
  - SSL connection required
- **Deployment**:
  - Native Elixir deployment (no Docker required)
  - Built specifically for Elixir/Phoenix apps
  - Supports hot upgrades
  - Free tier includes 1 app instance

### Development Database Decision
We will maintain both local and production databases:

1. **Local Development Database**
   - PostgreSQL running locally
   - Faster development iterations
   - Offline development capability
   - Separate dev/test databases
   - No production data exposure risk

2. **Production Database**
   - Managed by the chosen platform
   - SSL enabled
   - Proper connection pool configuration
   - Regular backups

### Database Configuration Structure

```elixir
# config/dev.exs
config :harezm, Harezm.Repo,
  username: "postgres",
  password: "postgres",
  database: "harezm_dev",
  hostname: "localhost"

# config/test.exs
config :harezm, Harezm.Repo,
  username: "postgres",
  password: "postgres",
  database: "harezm_test",
  hostname: "localhost"

# config/runtime.exs (for production)
config :harezm, Harezm.Repo,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
```

### Required Environment Variables
- `DATABASE_URL`: Provided by platform
- `POOL_SIZE`: Default 10, adjustable
- `SECRET_KEY_BASE`: For Phoenix
- `PHX_HOST`: Production host

### Common Issues & Solutions
1. **Database Connection Failures**
   - Verify DATABASE_URL and socket_options [:inet6]
   - Check SSL settings
   - Verify connection pool size

2. **Ash Policy Violations**
   - Check action authorizations
   - Verify actor context
   - Review policy definitions

3. **LiveView Issues**
   - Review channel config
   - Check heartbeat settings
   - Verify socket state

### Deployment Best Practices
1. **Database**
   - Run migrations on primary instance only
   - Enable release-time configuration
   - Monitor connection pool sizing

2. **Security**
   - Ash policy scoping in all actions
   - CSRF protection in endpoints
   - HTTPS enforcement in production
   - Row-Level Security policies
   - Credo/Sobelow static analysis
   - No hardcoded credentials
   - No raw SQL authentication bypass

## Project Setup Checklist

### Prerequisites
- [x] Elixir 1.18.3+
- [x] PostgreSQL
- [ ] Git

### Initial Setup
- [ ] Phoenix project creation
- [ ] Database configuration
- [ ] Ash Framework integration
- [ ] Surface UI setup
- [ ] Basic CSS structure

### Development Environment
- [ ] Local PostgreSQL setup
- [ ] Development environment variables
- [ ] Git repository initialization
- [ ] Development tools configuration (formatter, credo, etc.)

### Deployment Setup
- [ ] Platform selection (Render vs Gigalixir)
- [ ] Production environment configuration
- [ ] Database migration strategy
- [ ] Continuous deployment setup
- [ ] SSL configuration

## References
- [Ash Framework Documentation](https://hexdocs.pm/ash/readme.html)
- [Phoenix Framework Guides](https://hexdocs.pm/phoenix/overview.html)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Render Deployment Docs](https://render.com/docs/deploy-phoenix)
- [Gigalixir Documentation](https://www.gigalixir.com/docs/)

### Frontend Architecture (Updated)

1. **UI Framework**: Surface UI
   - Pure Elixir components with strong typing
   - Perfect LiveView integration
   - Component-based architecture
   - Declarative templating with ~F sigil
   - Built-in slot system
   - Prop validation

2. **CSS Strategy**: Tailwind CSS
   ```js
   // tailwind.config.js
   module.exports = {
     content: [
       "./js/**/*.js",
       "../lib/*_web/**/*.*ex"
     ],
     theme: {
       extend: {
         colors: {
           primary: {
             50: '#f0f9ff',
             100: '#e0f2fe',
             500: '#0ea5e9',
             600: '#0284c7',
             700: '#0369a1',
           },
           secondary: {
             50: '#f8fafc',
             100: '#f1f5f9',
             500: '#64748b',
             600: '#475569',
             700: '#334155',
           }
         },
         keyframes: {
           'fade-in-up': {
             '0%': {
               opacity: '0',
               transform: 'translateY(10px)'
             },
             '100%': {
               opacity: '1',
               transform: 'translateY(0)'
             }
           },
           'fade-out-down': {
             '0%': {
               opacity: '1',
               transform: 'translateY(0)'
             },
             '100%': {
               opacity: '0',
               transform: 'translateY(10px)'
             }
           }
         },
         animation: {
           'fade-in-up': 'fade-in-up 0.3s ease-out',
           'fade-out-down': 'fade-out-down 0.3s ease-out'
         }
       }
     },
     plugins: []
   }
   ```

3. **Core Components**
   ```elixir
   defmodule HarezmWeb.Components.Core.Button do
     use Surface.Component
     
     prop label, :string, required: true
     prop variant, :string, default: "primary"
     prop size, :string, default: "md"
     prop class, :css_class, default: []
     prop disabled, :boolean, default: false
     prop click, :event, default: nil
     
     def render(assigns) do
       ~F"""
       <button 
         class={{
           "rounded-lg font-medium transition-colors",
           "bg-primary-600 text-white hover:bg-primary-700": @variant == "primary",
           "bg-secondary-100 text-secondary-700 hover:bg-secondary-200": @variant == "secondary",
           "bg-red-600 text-white hover:bg-red-700": @variant == "danger",
           "px-3 py-1.5 text-sm": @size == "sm",
           "px-4 py-2": @size == "md",
           "px-6 py-3 text-lg": @size == "lg",
           "opacity-50 cursor-not-allowed": @disabled,
           @class
         }}
         :on-click={@click}
         disabled={@disabled}
       >
         {@label}
       </button>
       """
     end
   end

   defmodule HarezmWeb.Components.ServiceCard do
     use Surface.Component
     alias HarezmWeb.Components.Core.Button
     
     prop title, :string, required: true
     prop description, :string, required: true
     prop icon, :string, required: true
     prop features, :list, default: []
     prop selected, :boolean, default: false
     prop on_select, :event, required: true
     
     def render(assigns) do
       ~F"""
       <div class={{
         "bg-white rounded-xl shadow-sm p-6 transition duration-200",
         "border-2 border-primary-500": @selected,
         "hover:shadow-md": !@selected
       }}>
         <div class="flex items-center justify-between mb-4">
           <h3 class="text-xl font-semibold text-gray-900">{@title}</h3>
           <div class="text-primary-500">
             <#Icon name={@icon} class="w-6 h-6" />
           </div>
         </div>
         
         <p class="text-gray-600 mb-4">{@description}</p>
         
         <ul class="space-y-2 mb-6">
           {#for feature <- @features}
             <li class="flex items-center text-gray-700">
               <#Icon name="check" class="w-4 h-4 text-green-500 mr-2" />
               {feature}
             </li>
           {/for}
         </ul>
         
         <div class="flex items-center justify-between">
           <div class="flex items-center">
             <input
               type="checkbox"
               checked={@selected}
               class="w-4 h-4 text-primary-600 rounded border-gray-300 focus:ring-primary-500"
               :on-click={@on_select}
             />
             <span class="ml-2 text-sm text-gray-600">
               {#if @selected}
                 Selected
               {#else}
                 Select this service
               {/if}
             </span>
           </div>
           
           <Button
             label="Learn More"
             variant="secondary"
             size="sm"
           />
         </div>
       </div>
       """
     end
   end
   ```

4. **LiveView Integration**
   ```elixir
   defmodule HarezmWeb.ServiceLive do
     use Surface.LiveView
     alias HarezmWeb.Components.{ServiceCard, Core.Toast}
     
     data services, :list, default: []
     data selected_services, :list, default: []
     data page_title, :string, default: "Our Services"
     data toast, :map, default: nil
     
     def mount(_params, _session, socket) do
       services = Harezm.Services.list_services()
       {:ok, assign(socket, services: services)}
     end
     
     def handle_event("select_service", %{"id" => id}, socket) do
       selected = socket.assigns.selected_services
       new_selected = toggle_selection(selected, id)
       
       socket = socket
         |> assign(selected_services: new_selected)
         |> show_toast("Service selection updated", "success")
       
       {:noreply, socket}
     end
     
     def handle_event("hide_toast", _, socket) do
       {:noreply, assign(socket, toast: nil)}
     end
     
     def render(assigns) do
       ~F"""
       <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
         <h1 class="text-3xl font-bold text-gray-900 mb-8">{@page_title}</h1>
         
         <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
           {#for service <- @services}
             <ServiceCard
               title={service.title}
               description={service.description}
               icon={service.icon}
               features={service.features}
               selected={service.id in @selected_services}
               on_select="select_service"
             />
           {/for}
         </div>

         {#if @toast}
           <Toast
             message={@toast.message}
             type={@toast.type}
             show={true}
             on_close="hide_toast"
           />
         {/if}
       </div>
       """
     end
     
     defp toggle_selection(selected, id) do
       if id in selected, do: List.delete(selected, id), else: [id | selected]
     end
     
     defp show_toast(socket, message, type) do
       assign(socket, toast: %{message: message, type: type})
     end
   end
   ```

5. **Hook Registration**
   ```elixir
   # lib/harezm_web/components/app.js
   import Toast from "./hooks/toast"

   let Hooks = {
     Toast
   }

   let liveSocket = new LiveSocket("/live", Socket, {
     params: {_csrf_token: csrfToken},
     hooks: Hooks
   })
   ```

This implementation provides:
- Smooth fade animations using Tailwind
- Four toast types (success, error, info, warning)
- Automatic dismissal with animation
- Manual close button
- Proper cleanup on removal
- Responsive positioning
- Accessible color schemes

The toast system can be used throughout the application by calling `show_toast/3` in any LiveView. 