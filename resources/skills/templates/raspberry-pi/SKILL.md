# Raspberry Pi Development

<!-- category: template -->

## Overview

Patterns and best practices for Raspberry Pi projects — GPIO programming, sensor integration, touchscreen UIs, peripheral communication, and embedded deployment.
[FILL: What this Pi project does — kiosk, IoT sensor hub, home automation, robotics, etc.]

## Hardware Configuration

- Board: [FILL: Pi 5 / Pi 4B / Pi Zero 2 W / Pi Pico / Compute Module]
- OS: [FILL: Raspberry Pi OS (Bookworm) / Ubuntu / DietPi / custom]
- Display: [FILL: Official 7" touchscreen / HDMI / DSI / headless]
- Power: [FILL: Official PSU / PoE HAT / battery / USB-C PD]
- Storage: [FILL: microSD / USB SSD / NVMe (Pi 5 via HAT)]
- Network: [FILL: WiFi / Ethernet / cellular modem]
- [FILL: Additional HATs, shields, or breakout boards]

## GPIO Programming

### Pin numbering schemes
- **BCM (Broadcom)**: GPIO numbers as labeled on the SoC — use this (standard)
- **BOARD**: Physical pin position on the header (1-40) — avoid, less portable
- Always reference the pinout: `pinout` command on Pi, or https://pinout.xyz

### Python GPIO libraries (choose one)
| Library | Best For | Pi 5 Support | Notes |
|---------|----------|-------------|-------|
| **gpiozero** | Most projects | Yes (lgpio backend) | High-level, Pythonic, built-in device classes |
| **lgpio / rgpio** | Pi 5 native | Yes (default) | Low-level, replaces deprecated RPi.GPIO on Pi 5 |
| **RPi.GPIO** | Legacy Pi 0-4 only | No (broken on Pi 5) | Deprecated — migrate to gpiozero or lgpio |
| **pigpio** | Precise timing, PWM | Partial | Daemon-based, microsecond accuracy, remote GPIO |
| **libgpiod** | Linux-standard, any SBC | Yes | Kernel-level, language-agnostic, future-proof |

- **Default recommendation**: gpiozero for application logic, lgpio for low-level access
- [FILL: GPIO library used in this project]

### gpiozero basics
```python
from gpiozero import LED, Button, MotionSensor, DistanceSensor, Servo
from signal import pause

# Output
led = LED(17)
led.on()
led.blink(on_time=0.5, off_time=0.5)

# Input with callback
button = Button(4, bounce_time=0.05)
button.when_pressed = lambda: print("pressed")
button.when_released = lambda: print("released")

# Keep script running
pause()
```

### GPIO best practices
- Always clean up on exit: gpiozero handles this automatically; raw lgpio needs `lgpio.gpiochip_close()`
- Use pull-up/pull-down resistors (internal or external) on input pins to avoid floating state
- Debounce buttons: `bounce_time=0.05` in gpiozero, or hardware RC filter
- Never source more than 16mA per GPIO pin (50mA total across all pins) — use transistors/MOSFETs for motors, relays, LED strips
- Protect inputs with voltage dividers or level shifters for 5V sensors on 3.3V GPIO

## Sensor Integration

### Communication protocols
| Protocol | Pins | Speed | Use Case | Python Library |
|----------|------|-------|----------|----------------|
| **I2C** | SDA (GPIO2), SCL (GPIO3) | 100-400 kHz | Temperature, IMU, OLED, ADC | `smbus2`, `adafruit-circuitpython-*` |
| **SPI** | MOSI/MISO/SCLK/CE0/CE1 | 1-50 MHz | ADC, TFT displays, SD cards | `spidev`, `adafruit-circuitpython-*` |
| **1-Wire** | GPIO4 (default) | Low | DS18B20 temperature | `w1thermsensor` |
| **UART** | TX (GPIO14), RX (GPIO15) | 9600-115200 baud | GPS, fingerprint, serial devices | `pyserial` |
| **ADC** (external) | I2C or SPI | Varies | Analog sensors (Pi has no built-in ADC) | `adafruit-circuitpython-ads1x15` |

### Enable interfaces
```bash
sudo raspi-config nonint do_i2c 0    # Enable I2C
sudo raspi-config nonint do_spi 0    # Enable SPI
sudo raspi-config nonint do_serial_hw 0  # Enable UART
# Or: edit /boot/firmware/config.txt and add dtparam=i2c_arm=on, dtparam=spi=on
```

### Common sensors

#### Temperature & humidity
```python
# DHT22 (digital, GPIO)
import adafruit_dht
import board
dht = adafruit_dht.DHT22(board.D4)
print(f"Temp: {dht.temperature}°C  Humidity: {dht.humidity}%")

# BME280 (I2C — temperature, humidity, pressure)
import adafruit_bme280.advanced as adafruit_bme280
import busio
i2c = busio.I2C(board.SCL, board.SDA)
bme = adafruit_bme280.Adafruit_BME280_I2C(i2c, address=0x76)
print(f"Temp: {bme.temperature}°C  Pressure: {bme.pressure} hPa")

# DS18B20 (1-Wire — waterproof, multiple on same bus)
from w1thermsensor import W1ThermSensor
for sensor in W1ThermSensor.get_available_sensors():
    print(f"{sensor.id}: {sensor.get_temperature():.1f}°C")
```

#### Motion & distance
```python
# PIR motion sensor (digital output)
from gpiozero import MotionSensor
pir = MotionSensor(4)
pir.when_motion = lambda: print("Motion detected")

# HC-SR04 ultrasonic distance
from gpiozero import DistanceSensor
us = DistanceSensor(echo=24, trigger=23, max_distance=4)
print(f"Distance: {us.distance * 100:.1f} cm")

# VL53L0X time-of-flight (I2C — more precise, 2m range)
import adafruit_vl53l0x
tof = adafruit_vl53l0x.VL53L0X(i2c)
print(f"Distance: {tof.range} mm")
```

#### Light & color
```python
# BH1750 ambient light (I2C)
import adafruit_bh1750
light = adafruit_bh1750.BH1750(i2c)
print(f"Light: {light.lux:.1f} lux")

# TCS34725 RGB color sensor (I2C)
import adafruit_tcs34725
color_sensor = adafruit_tcs34725.TCS34725(i2c)
r, g, b = color_sensor.color_rgb_bytes
print(f"RGB: ({r}, {g}, {b})  Color temp: {color_sensor.color_temperature}K")
```

#### IMU / accelerometer / gyroscope
```python
# MPU6050 6-axis IMU (I2C)
import adafruit_mpu6050
mpu = adafruit_mpu6050.MPU6050(i2c)
ax, ay, az = mpu.acceleration   # m/s²
gx, gy, gz = mpu.gyro           # deg/s
print(f"Accel: ({ax:.2f}, {ay:.2f}, {az:.2f})  Gyro: ({gx:.1f}, {gy:.1f}, {gz:.1f})")
```

#### Analog sensors (via external ADC)
```python
# ADS1115 16-bit ADC (I2C) — for soil moisture, potentiometers, analog sensors
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
ads = ADS.ADS1115(i2c)
chan = AnalogIn(ads, ADS.P0)
print(f"Voltage: {chan.voltage:.3f}V  Raw: {chan.value}")
```

- [FILL: Which sensors are used in this project and on which pins/bus]

### Sensor best practices
- Poll sensors at appropriate intervals (DHT22: min 2s, BME280: configurable, distance: 60ms+)
- Handle sensor read failures gracefully — `try/except` with retry logic
- Calibrate sensors for your environment — factory defaults are approximations
- Use I2C scan to verify wiring: `i2cdetect -y 1`
- Power noisy sensors from a separate rail or add decoupling capacitors (100nF + 10µF)

## Touchscreen UI

### Framework options
| Framework | Best For | Language | Touch Support |
|-----------|----------|----------|---------------|
| **Kivy** | Full touch apps, multitouch, kiosk | Python | Native multitouch, gestures |
| **PyQt6 / PySide6** | Desktop-style apps, complex UIs | Python | Touch events, virtual keyboard |
| **Pygame** | Simple games, custom rendering | Python | Basic touch (single point) |
| **Tkinter** | Quick prototypes | Python | Basic click events |
| **Electron / Chromium kiosk** | Web-based kiosk UI | HTML/JS | Full touch, familiar web tech |
| **LVGL (via MicroPython)** | Embedded, low-resource | C / MicroPython | Optimized for small displays |
| **Flutter** | Cross-platform, beautiful UIs | Dart | Native touch, material design |

- [FILL: UI framework and display used in this project]

### Kivy touchscreen app
```python
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.clock import Clock
import adafruit_dht, board

class SensorDashboard(BoxLayout):
    def __init__(self, **kwargs):
        super().__init__(orientation='vertical', **kwargs)
        self.temp_label = Label(text='--°C', font_size='48sp')
        self.add_widget(self.temp_label)
        self.add_widget(Button(text='Refresh', on_press=self.update, font_size='24sp'))
        self.dht = adafruit_dht.DHT22(board.D4)
        Clock.schedule_interval(lambda dt: self.update(), 5)

    def update(self, *args):
        try:
            self.temp_label.text = f'{self.dht.temperature:.1f}°C'
        except RuntimeError:
            pass  # DHT22 occasionally fails — retry next interval

class DashboardApp(App):
    def build(self):
        return SensorDashboard()

if __name__ == '__main__':
    DashboardApp().run()
```

### Touchscreen configuration
```bash
# Official 7" touchscreen — usually auto-detected
# Rotate display (in /boot/firmware/config.txt):
display_lcd_rotate=2   # 180° rotation

# Calibrate touch (if misaligned):
sudo apt install xinput-calibrator
DISPLAY=:0 xinput_calibrator

# Hide mouse cursor for kiosk:
# In /etc/lightdm/lightdm.conf under [Seat:*]:
xserver-command=X -nocursor

# Virtual keyboard (for text input on touchscreen):
sudo apt install onboard  # or squeekboard for Wayland
```

### Touch interaction patterns
- **Touch targets**: Minimum 48x48 px (larger than desktop — fingers are imprecise)
- **Swipe gestures**: Use for navigation between screens, not for primary actions
- **Long press**: Alternative to right-click — for context menus, delete confirmation
- **Pinch-to-zoom**: Only if framework supports multitouch (Kivy, web, Flutter)
- **Visual feedback**: Immediate color/animation change on touch — latency is noticeable on Pi
- **Auto-dimming**: Blank/dim display after inactivity to prevent OLED burn-in and save power

## Camera Integration

```python
# Picamera2 (Pi Camera Module v2/v3, libcamera-based)
from picamera2 import Picamera2
import cv2

cam = Picamera2()
cam.configure(cam.create_preview_configuration(main={"size": (640, 480)}))
cam.start()

frame = cam.capture_array()  # numpy array — ready for OpenCV
gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

# Continuous capture loop
while True:
    frame = cam.capture_array()
    # Process frame...
```

- Use Picamera2 (not legacy `picamera`) — required for Bookworm / libcamera stack
- For USB webcams: use OpenCV `cv2.VideoCapture(0)` directly
- Pi Camera v3: autofocus, HDR, 12MP — configure via `cam.set_controls({"AfMode": 2})`
- [FILL: Camera module and resolution used in this project]

## Motor & Actuator Control

```python
# Servo (hardware PWM on GPIO12, GPIO13, GPIO18, GPIO19)
from gpiozero import Servo
servo = Servo(18)
servo.min()     # -90°
servo.mid()     # 0°
servo.max()     # +90°
servo.value = 0.5  # arbitrary position

# DC motor via H-bridge (L298N, DRV8833, TB6612FNG)
from gpiozero import Motor
motor = Motor(forward=24, backward=25, enable=12)
motor.forward(speed=0.7)  # 0-1 speed via PWM
motor.reverse()
motor.stop()

# Stepper motor (via A4988, DRV8825, or ULN2003)
# Use RPi.GPIO or dedicated library for step/dir pulse control
```

- Never drive motors directly from GPIO — always use a driver board (H-bridge, motor HAT)
- Separate motor power supply from Pi power (noise and brownouts crash the Pi)
- Add flyback diodes across motor/relay coils to protect against back-EMF

## Networking & Communication

### MQTT (IoT messaging)
```python
import paho.mqtt.client as mqtt

client = mqtt.Client()
client.connect("broker.local", 1883)
client.publish("sensors/temperature", "22.5")
client.subscribe("actuators/led")
client.on_message = lambda c, u, msg: print(f"{msg.topic}: {msg.payload.decode()}")
client.loop_forever()
```

### Bluetooth
```python
# BLE scanning and communication
from bleak import BleakScanner, BleakClient

async def scan():
    devices = await BleakScanner.discover()
    for d in devices:
        print(f"{d.name}: {d.address}")
```

### Web dashboard
- **Flask / FastAPI**: Lightweight HTTP server exposing sensor data as JSON API
- **WebSocket**: Real-time sensor streaming to browser dashboard
- **mDNS**: Access Pi via `hostname.local` — enable with `avahi-daemon`
- [FILL: Network communication protocols used in this project]

## System & Deployment

### Auto-start on boot
```bash
# systemd service (recommended)
sudo tee /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Pi Application
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/app/main.py
WorkingDirectory=/home/pi/app
User=pi
Restart=on-failure
RestartSec=5
Environment=DISPLAY=:0

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable myapp
sudo systemctl start myapp
```

### Kiosk mode (fullscreen app on boot)
```bash
# Chromium kiosk (for web UIs):
# In ~/.config/autostart/kiosk.desktop:
[Desktop Entry]
Type=Application
Exec=chromium-browser --kiosk --noerrdialogs --disable-infobars http://localhost:5000
```

### Reliability
- Use read-only root filesystem (`overlayfs`) to prevent SD card corruption on power loss
- Watchdog timer: enable hardware watchdog to auto-reboot on hang (`dtparam=watchdog=on`)
- Log rotation: configure `journald` or `logrotate` to prevent disk fill
- Remote access: SSH + Tailscale/WireGuard for secure remote management
- Backups: image the SD card periodically with `dd` or `rpi-imager`
- [FILL: Deployment environment — indoor/outdoor, power reliability, network reliability]

## Key Constraints

- GPIO voltage is **3.3V** — 5V will damage pins. Use level shifters for 5V peripherals
- SD cards wear out — minimize writes; use `tmpfs` for temp data, SSD for heavy I/O
- Thermal throttling at 80°C+ — add heatsink/fan for sustained workloads (Pi 5 especially)
- WiFi and Bluetooth share the same chip — heavy BT traffic degrades WiFi performance
- [FILL: Power budget, enclosure, environmental constraints for this project]

## Where to Look

- Raspberry Pi docs: https://www.raspberrypi.com/documentation/
- Pinout reference: https://pinout.xyz
- gpiozero: https://gpiozero.readthedocs.io/
- Adafruit CircuitPython: https://learn.adafruit.com/
- Picamera2: https://datasheets.raspberrypi.com/camera/picamera2-manual.pdf
- Kivy: https://kivy.org/doc/stable/
- [FILL: Project-specific hardware datasheets and resources]

## Common Pitfalls

- Using RPi.GPIO on Pi 5 — it's broken; use gpiozero (lgpio backend) or lgpio directly
- Forgetting to enable I2C/SPI in raspi-config — sensors appear disconnected
- Powering servos/motors from GPIO — causes brownouts and crashes; use external power
- SD card corruption from power cuts — use overlayfs or proper shutdown procedures
- Touchscreen coordinates inverted after rotation — recalibrate with `xinput_calibrator`
- DHT sensors failing intermittently — this is normal; retry with backoff, not error
- I2C address conflicts when using multiple sensors — check with `i2cdetect`, use multiplexer (TCA9548A)
- [FILL: Project-specific gotchas encountered]
