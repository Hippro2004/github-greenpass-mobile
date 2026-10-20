# คู่มือติดตั้งและตั้งค่าสำหรับนักพัฒนา

เอกสารนี้อธิบายวิธีเตรียมเครื่อง ดาวน์โหลด dependencies รัน และ build แอป GreenPass จากซอร์สโค้ด โดยขั้นตอนหลักเขียนสำหรับ Windows และ Android ซึ่งเป็นเส้นทางที่เหมาะสำหรับเริ่มพัฒนาแอปนี้

## 1. ข้อมูลโปรเจกต์

- ชื่อแพ็กเกจ Flutter: `greenpass`
- ประเภท: Flutter application (Dart)
- จุดเริ่มต้นแอป: `lib/main.dart`
- หน้าจอเริ่มต้น: หน้าเข้าสู่ระบบ
- เวอร์ชันที่ระบุใน `pubspec.yaml`: `1.0.0+1`
- ข้อกำหนด Dart ใน `pubspec.yaml`: `^3.10.7` (Dart 3.10.7 ขึ้นไป และต่ำกว่า 4.0.0)
- Android ใช้ Java/JVM target 17
- Android Gradle Plugin: `8.11.1`
- Kotlin Gradle Plugin: `2.2.20`
- Gradle Wrapper: `8.14` (wrapper จะดาวน์โหลด Gradle ให้ ไม่จำเป็นต้องติดตั้ง Gradle แยก)
- รายการแพ็กเกจและเวอร์ชันที่ล็อกไว้: `pubspec.lock`

## 2. ข้อกำหนดเบื้องต้น

### สำหรับพัฒนาและรัน Android บน Windows

1. **Windows 64-bit** ที่รองรับ Android Studio และ Flutter
2. **Git** สำหรับ clone ซอร์สโค้ด
3. **Flutter SDK stable** ที่มาพร้อม Dart ซึ่งผ่านข้อกำหนดใน `pubspec.yaml` (อย่างน้อย Dart 3.10.7)
4. **Android Studio** พร้อมติดตั้ง Android SDK, Android SDK Platform-Tools และ Android Emulator หากต้องการใช้อุปกรณ์จำลอง
5. **JDK 17** สำหรับ Android/Gradle build
6. อินเทอร์เน็ตสำหรับดาวน์โหลด Flutter packages, Android SDK components และ Gradle distribution ในการ build ครั้งแรก
7. Backend ของ GreenPass ที่เปิดใช้งานและเข้าถึงได้จากอุปกรณ์ที่จะรันแอป

ไม่จำเป็นต้องติดตั้ง Flutter packages ทีละตัวหรือ Gradle แยกเอง ให้ใช้ `flutter pub get` และ Gradle Wrapper ของโปรเจกต์

## 3. ติดตั้งเครื่องมือ

1. ติดตั้ง Git, Flutter SDK, Android Studio และ JDK 17 ตามช่องทางทางการของแต่ละเครื่องมือ
2. เพิ่มโฟลเดอร์ `bin` ของ Flutter SDK ลงใน `PATH` ของ Windows
3. เปิด PowerShell หรือ Terminal ใหม่ แล้วตรวจสอบ:

   ```powershell
   flutter --version
   dart --version
   java -version
   ```

   ตรวจให้แน่ใจว่า Dart ที่ Flutter ใช้อยู่ผ่านข้อกำหนด Dart SDK ใน `pubspec.yaml` และ Java เป็นเวอร์ชัน 17

4. ตรวจสภาพแวดล้อม Flutter และ Android:

   ```powershell
   flutter doctor -v
   ```

5. หาก `flutter doctor` แจ้งว่ายังไม่ได้ยอมรับ Android SDK licenses ให้รัน:

   ```powershell
   flutter doctor --android-licenses
   ```

6. กลับไปตรวจ `flutter doctor -v` อีกครั้ง และติดตั้งส่วนประกอบ Android SDK ที่รายงานว่ายังขาดผ่าน Android Studio > **SDK Manager**

## 4. ดาวน์โหลดซอร์สโค้ดและเตรียมโปรเจกต์

เปิด PowerShell ในโฟลเดอร์ที่ต้องการเก็บโปรเจกต์ แล้วรัน:

```powershell
git clone https://github.com/Hippro2004/github-greenpass-mobile.git
Set-Location github-greenpass-mobile
flutter pub get
```

คำสั่ง `flutter pub get` จะดาวน์โหลด dependencies ตาม `pubspec.yaml` และ `pubspec.lock` เช่น Dio, GoRouter, Geolocator, Image Picker, Secure Storage, STOMP client และ Google ML Kit Translation

ตรวจว่า Flutter มองเห็นอุปกรณ์หรือ emulator:

```powershell
flutter devices
```

หากใช้ emulator ให้เปิดอุปกรณ์จำลองผ่าน Android Studio ก่อน หรือเชื่อมต่อโทรศัพท์ Android ที่เปิด Developer options และ USB debugging แล้วอนุญาตการเชื่อมต่อบนโทรศัพท์

## 5. ตั้งค่าการเชื่อมต่อ Backend

**ขั้นตอนนี้จำเป็นสำหรับฟังก์ชันที่เรียกข้อมูลจากระบบ GreenPass** ตัวแอปไม่มี backend อยู่ใน repository นี้ และ URL ของ backend ปัจจุบันถูกกำหนดตายตัวไว้ใน:

- `lib/core/network/dio_client.dart`

ค่าปัจจุบันในซอร์สโค้ดคือ:

```text
http://192.168.1.224:8081/api/v1
```

ก่อนรันแอป ให้ตรวจสอบว่า backend ใช้ URL และพอร์ตนี้จริง หากไม่ใช่ ให้แก้ `baseUrl` ใน `DioClient` ให้ตรงกับ backend ที่จะทดสอบ ตัวอย่างรูปแบบ:

```text
http://<IP-หรือ-hostname-ของ-backend>:<พอร์ต>/api/v1
```

### วิธีเลือก host ให้ตรงกับอุปกรณ์

- **Android Emulator บนเครื่องเดียวกับ backend:** ใช้ `10.0.2.2` แทน `localhost` เพื่อให้อุปกรณ์จำลองเข้าถึงเครื่อง host ได้ เช่น `http://10.0.2.2:8081/api/v1`
- **โทรศัพท์จริง:** ใช้ IP ภายในเครือข่ายของคอมพิวเตอร์ที่รัน backend และตรวจให้แน่ใจว่าโทรศัพท์กับคอมพิวเตอร์อยู่ในเครือข่ายเดียวกัน
- **backend อยู่เครื่องอื่น:** ใช้ IP หรือ hostname ที่อุปกรณ์ Android เข้าถึงได้ ไม่ใช้ `localhost` ของโทรศัพท์
- ตรวจว่า backend รับการเชื่อมต่อจากเครือข่าย ไม่ได้ bind เฉพาะ loopback และ firewall อนุญาตพอร์ตที่ใช้ (ค่าปัจจุบันคือ `8081`)

การแจ้งเตือนใช้ STOMP over WebSocket โดยสร้าง URL จาก `baseUrl` เดียวกัน และต่อ path `/ws-greenpass/websocket` ดังนั้นเมื่อเปลี่ยน host, scheme หรือ port ของ backend ให้ตรวจสอบว่า WebSocket endpoint ของ backend สอดคล้องกันด้วย

โปรเจกต์ยังไม่มีไฟล์ `.env` หรือการตั้งค่า URL ผ่าน `--dart-define`; การเปลี่ยน backend สำหรับการพัฒนาจึงต้องแก้ค่าที่ `lib/core/network/dio_client.dart` โดยตรง

> **ข้อควรระวัง:** URL ปัจจุบันใช้ HTTP และ Android เปิด `usesCleartextTraffic="true"` ไว้ใน `android/app/src/main/AndroidManifest.xml` เพื่อรองรับการเชื่อมต่อแบบไม่เข้ารหัสขณะพัฒนา ไม่ควรใช้การตั้งค่านี้กับข้อมูลจริงหรือ production ควรเปลี่ยนเป็น HTTPS/WSS และทบทวนการตั้งค่า cleartext ก่อนเผยแพร่

## 6. รันแอปบน Android

จากโฟลเดอร์รากของโปรเจกต์:

```powershell
flutter run
```

ถ้ามีหลายอุปกรณ์ ให้ระบุ device ID ที่ได้จาก `flutter devices`:

```powershell
flutter run -d <device-id>
```

แอปจะเริ่มที่หน้าเข้าสู่ระบบ ความสามารถบางส่วนต้องใช้งาน backend ได้ และบางส่วนต้องอนุญาตสิทธิ์บนอุปกรณ์

### สิทธิ์ที่แอปใช้

- **อินเทอร์เน็ต:** เรียก REST API, รูปภาพระยะไกล และ WebSocket; ประกาศไว้ใน Android manifest
- **ตำแหน่งที่ตั้ง:** ใช้แสดงอุทยานใกล้เคียง; แอปจะขอสิทธิ์เมื่อเรียกใช้ฟังก์ชันตำแหน่ง
- **รูปภาพ:** ใช้เลือกรูปสำหรับรายงานหรือแก้ไขโปรไฟล์; iOS มีข้อความแจ้งวัตถุประสงค์การเข้าถึงคลังรูปภาพใน `Info.plist`
- **โทรศัพท์:** มีการประกาศ query สำหรับแอปที่รองรับ `tel:` ใน Android manifest

ปฏิเสธสิทธิ์ตำแหน่งหรือรูปภาพแล้วฟังก์ชันที่เกี่ยวข้องอาจใช้งานไม่ได้ แต่ไม่ใช่ขั้นตอนติดตั้ง Flutter ที่ต้องตั้งค่าสิทธิ์ล่วงหน้า

## 7. ตรวจสอบคุณภาพและรันทดสอบ

คำสั่งที่ใช้ตรวจโค้ดและรันทดสอบที่มีใน repository:

```powershell
flutter analyze
flutter test
```

การทดสอบอยู่ในโฟลเดอร์ `test/` และครอบคลุม widget, QR expiry และ park model คำสั่งเหล่านี้ไม่ทดแทนการตรวจว่า backend ทำงานหรือการทดสอบบนอุปกรณ์จริง

## 8. Build ไฟล์ Android สำหรับติดตั้ง

### APK สำหรับทดสอบหรือติดตั้งบนอุปกรณ์

```powershell
flutter build apk --release
```

เมื่อ build สำเร็จ ไฟล์โดยทั่วไปอยู่ที่:

```text
build/app/outputs/flutter-apk/app-release.apk
```

นำ APK ไปติดตั้งบนอุปกรณ์ Android ได้ โดยอาจต้องอนุญาตแหล่งที่มาของแอปบนอุปกรณ์เมื่อ sideload

### Android App Bundle

```powershell
flutter build appbundle --release
```

ไฟล์โดยทั่วไปอยู่ที่:

```text
build/app/outputs/bundle/release/app-release.aab
```

**ก่อนเผยแพร่จริง:** `android/app/build.gradle.kts` กำหนด release build ให้ใช้ debug signing config อยู่ จึงยังไม่ใช่การตั้งค่าลายเซ็นสำหรับเผยแพร่ production ต้องสร้างและตั้งค่า release keystore อย่างปลอดภัยก่อนปล่อยแอป นอกจากนี้ควรตั้ง application ID, version และ backend production ให้ถูกต้อง

## 9. แพลตฟอร์มอื่น

- **iOS:** ต้องใช้ macOS, Xcode และเครื่องมือ iOS ที่ Flutter ต้องการ การ build สำหรับ iOS ทำบน Windows ไม่ได้ โครงการมี iOS Runner และข้อความขอสิทธิ์ตำแหน่ง/รูปภาพแล้ว แต่การลงนามแอป การตั้งค่า Apple Developer และการตรวจ dependencies ของ iOS ต้องทำบน macOS
- **Web, Windows, macOS และ Linux:** มีโฟลเดอร์ platform scaffold อยู่ใน repository แต่การมี scaffold ไม่ได้ยืนยันว่า dependencies และทุกฟังก์ชันของแอปรองรับแพลตฟอร์มนั้นครบถ้วน เส้นทางที่ควรใช้เป็นหลักในคู่มือนี้คือ Android

## 10. แก้ปัญหาเบื้องต้น

| อาการ | สิ่งที่ควรตรวจ |
|---|---|
| `flutter` หรือ `dart` ไม่พบคำสั่ง | ตรวจตำแหน่ง Flutter SDK ใน `PATH` แล้วเปิด Terminal ใหม่ |
| `flutter doctor` รายงาน Android toolchain ไม่พร้อม | ติดตั้ง Android SDK components ใน Android Studio และรัน `flutter doctor --android-licenses` |
| Gradle build แจ้ง Java ไม่เข้ากัน | ตรวจ `java -version` และให้ Gradle ใช้ JDK 17 |
| `flutter pub get` ดาวน์โหลดไม่ได้ | ตรวจอินเทอร์เน็ต, proxy และการเข้าถึง pub.dev |
| แอปเปิดได้แต่เรียก API ไม่สำเร็จ | ตรวจ `baseUrl` ใน `lib/core/network/dio_client.dart`, สถานะ backend, firewall, port และ IP ที่อุปกรณ์เข้าถึงได้ |
| API ใช้ได้แต่รูปภาพที่ backend ส่ง URL กลับมาเปิดไม่ได้ | ตรวจ URL ของรูปจาก backend และการตั้งค่า host ให้สอดคล้องกับ API; แอปมีการจัดการ relative image path ใน `lib/core/network/image_helper.dart` |
| Android Emulator เชื่อมต่อ backend บนเครื่องเดียวกันไม่ได้ | ใช้ `10.0.2.2` แทน `localhost`/`127.0.0.1` ในการตั้งค่า backend สำหรับ emulator |
| ตำแหน่งหรือการเลือกรูปไม่ทำงาน | ตรวจสิทธิ์ของแอปใน Settings ของอุปกรณ์ และเปิด Location service เมื่อทดสอบตำแหน่ง |

## 11. ไฟล์สำคัญที่เกี่ยวข้อง

- `pubspec.yaml` — ข้อกำหนด Dart, Flutter dependencies และ assets
- `pubspec.lock` — เวอร์ชัน dependencies ที่ resolve ไว้
- `lib/main.dart` — จุดเริ่มต้นและหน้าจอแรก
- `lib/core/network/dio_client.dart` — REST API base URL และค่า timeout
- `lib/features/notification/services/notification_websocket_service.dart` — การเชื่อมต่อ WebSocket/STOMP
- `android/app/build.gradle.kts` — Android namespace, application ID, Java 17 และ release signing
- `android/app/src/main/AndroidManifest.xml` — Android permissions และการตั้งค่า network
- `ios/Runner/Info.plist` — ข้อความแจ้งสิทธิ์สำหรับ iOS
