export default {
  data() {
    return {
      user: null,
      isAuthenticated: false
    }
  },
  
  computed: {
    // Check if user is authenticated
    isAuthenticatedComputed() {
      return this.isAuthenticated
    },
    
    // Get current user info
    userComputed() {
      return this.user
    },
    
    // Check if user is super admin
    isSuperAdmin() {
      return this.userComputed && this.userComputed.role === 'x-superadmin'
    }
  },
  
  methods: {
    // Login method
    async login(username, password) {
      try {
        // 使用配置文件中的登录URL
        const loginUrl = window.BRICK_CONFIG.features?.login?.url || '/login'
        const response = await fetch(loginUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ username, password })
        })

        if (response.ok) {
          const data = await response.json()
          
          // Save token and user info
          localStorage.setItem('jwt_token', data.token)
          localStorage.setItem('isAuthenticated', 'true')
          
          // Decode JWT to get user info
          try {
            const tokenParts = data.token.split('.')
            if (tokenParts.length === 3) {
              // Handle base64 decoding properly
              const base64 = tokenParts[1].replace(/-/g, '+').replace(/_/g, '/')
              const payload = JSON.parse(atob(base64))
              localStorage.setItem('user', JSON.stringify({
                username: payload.username || payload.email || 'User',
                role: payload.role,
                permissions: payload.permissions || [],
                first_name: payload.first_name || '',
                last_name: payload.last_name || '',
                email: payload.email || ''
              }))
            }
          } catch (e) {
            console.warn('Failed to decode JWT payload:', e)
          }
          
          // Update reactive data
          this.isAuthenticated = true
          // Use the dedicated method to update user data
          this.updateUserFromLocalStorage()
          
          return true
        } else {
          console.error('Login failed:', response.status)
          return false
        }
      } catch (err) {
        console.error('Login error:', err)
        return false
      }
    },
    
    // Logout method
    logout() {
      // Clear authentication data
      localStorage.removeItem('jwt_token')
      localStorage.removeItem('isAuthenticated')
      localStorage.removeItem('user')
      
      // Update reactive data
      this.isAuthenticated = false
      this.user = null
      
      // Force component to re-render
      this.$forceUpdate()
      
      // Force redirect to home page
      try {
        this.$router.push('/')
      } catch (error) {
        console.error('Router push failed:', error)
        // Fallback redirect if router is unavailable
        window.location.href = '/'}
    },
    
    // Check if user has specific permission
    hasPermission(permission) {
      if (!this.userComputed || !this.userComputed.permissions) {
        return false
      }
      return this.userComputed.permissions.includes(permission)
    },
    
    // Get auth headers for API requests
    getAuthHeaders() {
      const token = localStorage.getItem('jwt_token')
      if (token) {
        return {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
      return {
        'Content-Type': 'application/json'
      }
    },

    // Update user data from localStorage
    updateUserFromLocalStorage() {
      const userStr = localStorage.getItem('user')
      if (userStr) {
        try {
          this.user = JSON.parse(userStr)
        } catch (e) {
          console.warn('Failed to parse user data:', e)
          this.user = null
        }
      } else {
        this.user = null
      }
    }
  },

  mounted() {
    // Update reactive data from localStorage
    this.isAuthenticated = localStorage.getItem('isAuthenticated') === 'true'
    this.updateUserFromLocalStorage()
  },

  // Watch for changes in localStorage
  watch: {
    isAuthenticatedComputed(newVal) {
      if (newVal) {
        this.updateUserFromLocalStorage()
      } else {
        this.user = null
      }
    }
  }
}