# ☀️ Modern Flutter Weather App

Ứng dụng dự báo thời tiết hiện đại, mượt mà được xây dựng bằng **Flutter**, tích hợp dữ liệu từ **Open-Meteo API**.

🔗 **Live Demo:** [https://knguyen1411b.github.io/weather-app-flutter/](https://knguyen1411b.github.io/weather-app-flutter/)

---

## ✨ Tính năng nổi bật

- 🎨 **Giao diện Glassmorphism cao cấp**: Hiệu ứng kính mờ frosted glass tinh tế, hỗ trợ Dark Theme hiện đại.
- 🌌 **Nền thời tiết động (Living Weather Background)**: Tự động thay đổi nền trời và hiệu ứng hạt (mưa rơi, tuyết bay, sao đêm lấp lánh, nắng rạng rỡ) theo thời gian thực và điều kiện thời tiết.
- 🕒 **Dự báo 24 giờ tới (Hourly Forecast)**: Xem chi tiết nhiệt độ từng giờ và xác suất có mưa (%).
- 📅 **Dự báo 7 ngày (7-Day Forecast)**: Thanh phổ nhiệt min/max tương quan tuần trực quan.
- 🍃 **Chất lượng không khí (AQI & PM2.5/PM10)**: Đo lường chất lượng không khí kèm khuyến cáo sức khỏe.
- 🌅 **Quỹ đạo Mặt trời**: Mô phỏng vòng cung bình minh và hoàng hôn theo thời gian thực.
- 📊 **Lưới chỉ số chuyên sâu**: Chỉ số UV, Tốc độ gió kèm La bàn 360°, Độ ẩm, Điểm sương, Áp suất khí quyển, Tầm nhìn xa và Lượng mưa.
- 🔍 **Tìm kiếm thành phố thông minh**: Hỗ trợ tìm kiếm nhanh, hiển thị cờ quốc gia, tỉnh/thành phố và các địa điểm phổ biến.
- ⭐ **Quản lý danh sách yêu thích**: Lưu trữ thành phố yêu thích vào bộ nhớ máy, chuyển đổi đơn vị °C / °F.
- 🔄 **Pull-to-Refresh**: Vuốt để làm mới dữ liệu thời tiết tức thì.

---

## 🚀 Cài đặt & Chạy ứng dụng

### Yêu cầu
- Flutter SDK (>= 3.13.0)
- Dart SDK

### Chạy trên máy
```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Chạy ứng dụng trên thiết bị / trình duyệt
flutter run
```

### Build bản Web Release
```bash
flutter build web --release
```

---

## 🛠️ Công nghệ sử dụng
- **Framework**: Flutter (Dart)
- **Design System**: Glassmorphism, Google Fonts (Outfit & Poppins)
- **API**: [Open-Meteo Weather API](https://open-meteo.com/) (Free, No API key required)
- **State & Storage**: SharedPreferences, Stateful Widgets
- **CI/CD**: GitHub Actions & GitHub Pages
