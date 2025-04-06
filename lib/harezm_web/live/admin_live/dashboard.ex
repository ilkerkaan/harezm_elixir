defmodule HarezmWeb.AdminLive.Dashboard do
  use HarezmWeb, :live_view
  use HarezmWeb, :html

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Harezm.PubSub, "admin")
    end

    {:ok,
     assign(socket,
       page_title: "Admin Dashboard",
       current_user: socket.assigns.current_user
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-full">
      <header class="bg-white shadow">
        <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
          <h1 class="text-3xl font-bold tracking-tight text-gray-900">Admin Dashboard</h1>
        </div>
      </header>
      
      <main>
        <div class="mx-auto max-w-7xl py-6 sm:px-6 lg:px-8">
          <div class="px-4 py-6 sm:px-0">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
              <!-- Users Card -->
              <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                  <div class="flex items-center">
                    <div class="flex-shrink-0">
                      <svg
                        class="h-6 w-6 text-gray-400"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                        />
                      </svg>
                    </div>
                    
                    <div class="ml-5 w-0 flex-1">
                      <dl>
                        <dt class="text-sm font-medium text-gray-500 truncate">Users</dt>
                        
                        <dd class="flex items-baseline">
                          <div class="text-2xl font-semibold text-gray-900">0</div>
                        </dd>
                      </dl>
                    </div>
                  </div>
                </div>
                
                <div class="bg-gray-50 px-5 py-3">
                  <div class="text-sm">
                    <a href="#" class="font-medium text-indigo-700 hover:text-indigo-900">
                      View all users →
                    </a>
                  </div>
                </div>
              </div>
              
    <!-- Contact Messages Card -->
              <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                  <div class="flex items-center">
                    <div class="flex-shrink-0">
                      <svg
                        class="h-6 w-6 text-gray-400"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                        />
                      </svg>
                    </div>
                    
                    <div class="ml-5 w-0 flex-1">
                      <dl>
                        <dt class="text-sm font-medium text-gray-500 truncate">Contact Messages</dt>
                        
                        <dd class="flex items-baseline">
                          <div class="text-2xl font-semibold text-gray-900">0</div>
                        </dd>
                      </dl>
                    </div>
                  </div>
                </div>
                
                <div class="bg-gray-50 px-5 py-3">
                  <div class="text-sm">
                    <a href="#" class="font-medium text-indigo-700 hover:text-indigo-900">
                      View all messages →
                    </a>
                  </div>
                </div>
              </div>
              
    <!-- Services Card -->
              <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                  <div class="flex items-center">
                    <div class="flex-shrink-0">
                      <svg
                        class="h-6 w-6 text-gray-400"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                        />
                      </svg>
                    </div>
                    
                    <div class="ml-5 w-0 flex-1">
                      <dl>
                        <dt class="text-sm font-medium text-gray-500 truncate">Services</dt>
                        
                        <dd class="flex items-baseline">
                          <div class="text-2xl font-semibold text-gray-900">0</div>
                        </dd>
                      </dl>
                    </div>
                  </div>
                </div>
                
                <div class="bg-gray-50 px-5 py-3">
                  <div class="text-sm">
                    <a href="#" class="font-medium text-indigo-700 hover:text-indigo-900">
                      Manage services →
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
    """
  end
end
