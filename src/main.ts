import { createApp } from 'vue'
import * as VueRouter from 'vue-router'
const { createRouter, createWebHistory } = VueRouter
// Type alias for RouteRecordRaw
type RouteRecordRaw = VueRouter.RouteRecordRaw
import App from './App.vue'
import Dashboard from './components/Dashboard.vue'
import Login from './components/Login.vue'
import CustomNTP from './components/CustomNTP.vue'
import SmartHomeBeta from './components/SmartHomeBeta.vue'
import { RouteMeta } from './types/index'

const routes: RouteRecordRaw[] = [
  { 
    path: '/', 
    component: Dashboard,
    meta: { requiresAuth: false } as RouteMeta
  },
  // Gateway route is handled by Nginx, not Vue Router
  { 
    path: '/gateway', 
    beforeEnter: (to: any, from: any, next: any) => {
      // This will cause the browser to make a new request to /gateway
      // which will be handled by Nginx
      window.location.href = '/gateway';
      return false;
    },
    meta: { requiresAuth: true } as RouteMeta
  },
  { 
    path: '/login', 
    component: Login 
  },
  { 
    path: '/ntp', 
    component: CustomNTP,
    meta: { requiresAuth: true, title: 'Brick - NTP' } as RouteMeta
  },
  { 
    path: '/clock', 
    component: CustomNTP,
    meta: { requiresAuth: true } as RouteMeta
  },
  { 
    path: '/smart-home', 
    component: SmartHomeBeta,
    meta: { requiresAuth: true, permissions: ['smart:read'] } as RouteMeta
  },
  { 
    path: '/:pathMatch(.*)*', 
    redirect: '/' 
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard for authentication
router.beforeEach((to: any, from: any, next: any) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true'
  const token = localStorage.getItem('jwt_token')
  
  // Check if route requires authentication
  if (to.meta?.requiresAuth && !isAuthenticated) {
    next(`/login?redirect=${encodeURIComponent(to.fullPath)}`)
    return
  }
  
  // Check if route requires super-admin
  if (to.meta?.requiresSuperAdmin) {
    const user = localStorage.getItem('user')
    if (user) {
      try {
        const userData = JSON.parse(user)
        if (userData.role !== 'super-admin') {
          next('/')
          return
        }
      } catch (e) {
        next('/login')
        return
      }
    } else {
      next('/login')
      return
    }
  }
  
  // If user is authenticated and trying to access login page, redirect to home
  if (to.path === '/login' && isAuthenticated && token) {
    next('/')
    return
  }
  
  next()
})

// Create Vue app
const app = createApp(App)

// Use router
app.use(router)

// Mount app
app.mount('#app')