<template>
  <div class="smart-home-container">
    <div v-if="!hasPermission('x/smart:read')" class="no-permission">
      <h3>无权限访问</h3>
      <p>您没有权限查看智能家庭页面，请联系管理员获取权限。</p>
    </div>
    <div v-else>
      <header class="smart-home-header">
        <h1>智能家庭管理 <span class="beta-badge">Beta</span></h1>
      <p>管理您的智能家居设备和场景</p>
    </header>

    <div class="dashboard-layout">
      <!-- 左侧房间导航 -->
      <aside class="room-navigation">
        <h2>房间</h2>
        <ul class="room-list">
          <li v-for="room in rooms" :key="room.id" :class="{ 'active': selectedRoom === room.id }" @click="selectRoom(room.id)">
            <span class="room-icon">{{ room.icon }}</span>
            <span class="room-name">{{ room.name }}</span>
          </li>
        </ul>
      </aside>

      <!-- 主内容区域 -->
      <main class="main-content">
        <div v-if="selectedRoomInfo" class="room-header">
          <h2>{{ selectedRoomInfo.name }}</h2>
          <div class="room-stats">
            <div class="stat-item">
              <span class="stat-value">{{ selectedRoomInfo.temperature }}°C</span>
              <span class="stat-label">温度</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ selectedRoomInfo.humidity }}%</span>
              <span class="stat-label">湿度</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ selectedRoomInfo.lightLevel }}%</span>
              <span class="stat-label">亮度</span>
            </div>
          </div>
        </div>

        <div class="devices-container">
          <h3>设备</h3>
          <div v-if="selectedRoomDevices.length > 0" class="devices-grid">
            <div v-for="device in selectedRoomDevices" :key="device.id" class="device-card">
              <div class="device-icon">{{ device.icon }}</div>
              <div class="device-info">
                <h4>{{ device.name }}</h4>
                <p class="device-status">{{ device.status ? '开启' : '关闭' }}</p>
              </div>
              <label class="toggle-switch">
                <input type="checkbox" v-model="device.status" @change="toggleDevice(device.id)">
                <span class="slider"></span>
              </label>
            </div>
          </div>
          <p v-else class="no-devices">此房间暂无设备</p>
        </div>

        <!-- 扫地机器人控制区域 -->
        <div class="cleaners-container">
          <h3>扫地机器人</h3>
          <div class="cleaners-grid">
            <div v-for="cleaner in cleaners" :key="cleaner.id" class="cleaner-card">
              <div class="cleaner-icon">{{ cleaner.icon }}</div>
              <div class="cleaner-info">
                <h4>{{ cleaner.name }}</h4>
                <p class="cleaner-status">{{ cleaner.status }}</p>
                <p class="cleaner-battery">电池: {{ cleaner.battery }}%</p>
              </div>
              <div class="cleaner-actions">
                <button @click="startCleaning(cleaner.id, selectedRoom)" :disabled="cleaner.status === '清扫中'">开始清扫</button>
                <button @click="stopCleaning(cleaner.id)" :disabled="cleaner.status !== '清扫中'">停止</button>
              </div>
            </div>
          </div>
        </div>
      </main>
  </div>
</div>
    </div>
</template>

<script>
import { ref, computed } from 'vue'
import authMixin from '../mixins/auth.js'

export default {
  name: 'SmartHomeBeta',
  mixins: [authMixin],
  setup() {
    // 房间数据
    const rooms = [
      { id: 'master-bedroom', name: '主卧', icon: '🛏️' },
      { id: 'second-bedroom', name: '次卧', icon: '🛌' },
      { id: 'guest-bedroom', name: '客卧', icon: '🏠' },
      { id: 'living-room', name: '客厅', icon: '🛋️' },
      { id: 'dining-room', name: '餐厅', icon: '🍽️' },
      { id: 'kitchen', name: '厨房', icon: '🍳' },
      { id: 'balcony', name: '阳台', icon: '🌞' },
      { id: 'bathroom', name: '卫生间', icon: '🚿' }
    ]

    // 选中的房间
    const selectedRoom = ref('living-room')

    // 房间信息（温度、湿度、亮度）
    const roomInfos = {
      'master-bedroom': { temperature: 24, humidity: 45, lightLevel: 30 },
      'second-bedroom': { temperature: 23, humidity: 42, lightLevel: 20 },
      'guest-bedroom': { temperature: 22, humidity: 40, lightLevel: 10 },
      'living-room': { temperature: 25, humidity: 48, lightLevel: 70 },
      'dining-room': { temperature: 26, humidity: 50, lightLevel: 60 },
      'kitchen': { temperature: 27, humidity: 55, lightLevel: 80 },
      'balcony': { temperature: 28, humidity: 60, lightLevel: 100 },
      'bathroom': { temperature: 26, humidity: 70, lightLevel: 50 }
    }

    // 房间设备数据
    const roomDevices = {
      'master-bedroom': [
        { id: 'ac-master', name: '空调', icon: '❄️', status: true },
        { id: 'light-master', name: '主灯', icon: '💡', status: false },
        { id: 'lamp-master', name: '台灯', icon: '🕯️', status: false }
      ],
      'second-bedroom': [
        { id: 'ac-second', name: '空调', icon: '❄️', status: false },
        { id: 'light-second', name: '主灯', icon: '💡', status: false }
      ],
      'guest-bedroom': [
        { id: 'ac-guest', name: '空调', icon: '❄️', status: false },
        { id: 'light-guest', name: '主灯', icon: '💡', status: false }
      ],
      'living-room': [
        { id: 'ac-living', name: '空调', icon: '❄️', status: true },
        { id: 'light-living', name: '主灯', icon: '💡', status: true },
        { id: 'tv-living', name: '电视', icon: '📺', status: false },
        { id: 'speaker-living', name: '音响', icon: '🔊', status: false }
      ],
      'dining-room': [
        { id: 'light-dining', name: '吊灯', icon: '💡', status: true },
        { id: 'fan-dining', name: '风扇', icon: '💨', status: false }
      ],
      'kitchen': [
        { id: 'light-kitchen', name: '吸顶灯', icon: '💡', status: true },
        { id: 'vent-kitchen', name: '抽油烟机', icon: '🌬️', status: false }
      ],
      'balcony': [
        { id: 'light-balcony', name: '阳台灯', icon: '💡', status: false },
        { id: 'clothesline', name: '晾衣架', icon: '🧺', status: false }
      ],
      'bathroom': [
        { id: 'light-bathroom', name: '浴室灯', icon: '💡', status: true },
        { id: 'heater-bathroom', name: '浴霸', icon: '🔥', status: false },
        { id: 'vent-bathroom', name: '换气扇', icon: '🌬️', status: true }
      ]
    }

    // 扫地机器人数据
    const cleaners = ref([
      { id: 'cleaner-1', name: '扫地机器人1', icon: '🤖', status: '待机中', battery: 85 },
      { id: 'cleaner-2', name: '扫地机器人2', icon: '🤖', status: '充电中', battery: 30 }
    ])

    // 选择房间
    const selectRoom = (roomId) => {
      selectedRoom.value = roomId
    }

    // 切换设备状态
    const toggleDevice = (deviceId) => {
      const device = roomDevices[selectedRoom.value].find(d => d.id === deviceId)
      if (device) {
        device.status = !device.status
        console.log(`设备 ${device.name} 已${device.status ? '开启' : '关闭'}`)
      }
    }

    // 开始清扫
    const startCleaning = (cleanerId, roomId) => {
      const cleaner = cleaners.value.find(c => c.id === cleanerId)
      if (cleaner && cleaner.status !== '清扫中') {
        cleaner.status = '清扫中'
        const room = rooms.find(r => r.id === roomId)
        console.log(`${cleaner.name} 开始清扫 ${room.name}`)
      }
    }

    // 停止清扫
    const stopCleaning = (cleanerId) => {
      const cleaner = cleaners.value.find(c => c.id === cleanerId)
      if (cleaner && cleaner.status === '清扫中') {
        cleaner.status = '待机中'
        console.log(`${cleaner.name} 已停止清扫`)
      }
    }

    // 计算属性：选中的房间信息
    const selectedRoomInfo = computed(() => {
      const room = rooms.find(r => r.id === selectedRoom.value)
      if (room) {
        return {
          ...room,
          ...roomInfos[selectedRoom.value]
        }
      }
      return null
    })

    // 计算属性：选中房间的设备
    const selectedRoomDevices = computed(() => {
      return roomDevices[selectedRoom.value] || []
    })

    return {
      rooms,
      selectedRoom,
      cleaners,
      selectRoom,
      toggleDevice,
      startCleaning,
      stopCleaning,
      selectedRoomInfo,
      selectedRoomDevices
    }
  }
}
</script>

<style scoped>
@import '../styles/smart-home.css';
.smart-home-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.smart-home-header {
  margin-bottom: 30px;
  text-align: center;
}

.beta-badge {
  background-color: #FF9800;
  color: white;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 12px;
  margin-left: 10px;
}

.dashboard-layout {
  display: flex;
  gap: 20px;
}

.room-navigation {
  width: 250px;
  background-color: white;
  border-radius: var(--border-radius);
  padding: 20px;
  box-shadow: var(--shadow);
}

.room-list {
  list-style: none;
  padding: 0;
}

.room-list li {
  display: flex;
  align-items: center;
  padding: 10px 15px;
  border-radius: 8px;
  margin-bottom: 8px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.room-list li:hover {
  background-color: #f0f0f0;
}

.room-list li.active {
  background-color: rgba(76, 175, 80, 0.1);
  color: var(--primary-green);
}

.room-icon {
  font-size: 20px;
  margin-right: 10px;
  width: 24px;
  text-align: center;
}

.main-content {
  flex: 1;
  background-color: white;
  border-radius: var(--border-radius);
  padding: 20px;
  box-shadow: var(--shadow);
}

.room-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.room-stats {
  display: flex;
  gap: 20px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 20px;
  font-weight: bold;
  color: var(--primary-green);
}

.stat-label {
  font-size: 12px;
  color: #666;
}

.devices-container,
.cleaners-container {
  margin-bottom: 30px;
}

.devices-grid,
.cleaners-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 15px;
}

.device-card,
.cleaner-card {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 15px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.device-icon,
.cleaner-icon {
  font-size: 24px;
  margin-right: 15px;
}

.device-info,
.cleaner-info {
  flex: 1;
}

.device-info h4,
.cleaner-info h4 {
  margin: 0 0 5px 0;
}

.device-status,
.cleaner-status,
.cleaner-battery {
  font-size: 12px;
  color: #666;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 24px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
  border-radius: 24px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: var(--primary-green);
}

input:checked + .slider:before {
  transform: translateX(26px);
}

.cleaner-actions {
  display: flex;
  gap: 8px;
}

.cleaner-actions button {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  background-color: var(--primary-green);
  color: white;
  transition: background-color 0.2s;
}

.cleaner-actions button:hover {
  background-color: var(--dark-green);
}

.cleaner-actions button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.no-devices {
  text-align: center;
  color: #666;
  padding: 20px;
}
</style>