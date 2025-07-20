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
      return localStorage.getItem('isAuthenticated') === 'true' && 
             localStorage.getItem('jwt_token') !== null
    },
    
    // Get current user info
    userComputed() {
      const userStr = localStorage.getItem('user')
      if (userStr) {
        try {
          return JSON.parse(userStr)
        } catch (e) {
          console.warn('Failed to parse user data:', e)
          return null
        }
      }
      return null
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
        const response = await fetch('/api/auth/login', {
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
              const payload = JSON.parse(atob(tokenParts[1]))
              localStorage.setItem('user', JSON.stringify({
                username: payload.username,
                role: payload.role,
                permissions: payload.permissions || []
              }))
            }
          } catch (e) {
            console.warn('Failed to decode JWT payload:', e)
          }
          
          // Update reactive data
          this.isAuthenticated = true
          this.user = JSON.parse(localStorage.getItem('user'))
          
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
      localStorage.removeItem('jwt_token')
      localStorage.removeItem('isAuthenticated')
      localStorage.removeItem('user')
      
      // Update reactive data
      this.isAuthenticated = false
      this.user = null
      
      this.$router.push('/login')
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
    }
  },
  
  mounted() {
    // Update reactive data from localStorage
    this.isAuthenticated = localStorage.getItem('isAuthenticated') === 'true'
    const userStr = localStorage.getItem('user')
    if (userStr) {
      try {
        this.user = JSON.parse(userStr)
      } catch (e) {
        console.warn('Failed to parse user data:', e)
      }
    }
  }
} 