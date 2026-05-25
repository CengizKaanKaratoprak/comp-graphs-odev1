# Jaremental – 2D Platformer

## 1. Grup Üyeleri / Öğrenci Bilgileri

| Ad Soyad               | Öğrenci Numarası |
|------------------------|------------------|
| Cengiz Kaan Karatoprak | 20252009027      |
| Kemal Arıcan Girginkoç | 20252009033      |

---

## 2. Oyun Hakkında

**Oyunun Adı:** Jaremental

**Açıklama:**  
Kavanoz, büyülü elementleri içinde hapseden kavanozları kullanarak oynanan bir 2D piksel-art platformer oyunudur. Oyuncu, bulduğu kavanozları başına takarak ateş, hava ve su elementlerinin güçlerini kullanabilir; bu güçleri bölümleri geçmek, düşmanları alt etmek ve çevreyle etkileşime girmek için stratejik biçimde değerlendirmek zorundadır.

**Temel Mekanikler:**
- **Ateş Kavanozu** — Fireball fırlatarak düşmanlara uzaktan hasar verir.
- **Hava Kavanozu** — Dash ve yüksek zıplama yeteneği kazandırır.
- **Su Kavanozu** — Yerdeki bitkileri büyüterek rampa ve geçit oluşturur.

**Teknoloji / Motor / Dil:**  
- Oyun Motoru: [Godot Engine 4.x](https://godotengine.org/)  
- Programlama Dili: GDScript  
- Piksel Art: Aseprite  

---

## 3. Sprite Tasarım Süreci

### Kullanılan Program
Tüm sprite'lar **Aseprite** ile üretilmiştir. Aseprite'in piksel art odaklı katman sistemi, animasyon kolaylığı ve indexed renk paleti desteği tercih sebebi olmuştur.

### Karşılaşılan Zorluklar

**Animasyon tutarlılığı:** Her elemental kavanoz için ayrı karakter animasyonu üretmek gerekiyordu (idle, run, jump). Üç farklı kavanoz durumunda karakterin silueti ve renk paleti değiştiğinden, animasyonların birbirinden kopuk görünmemesi için her biri aynı temel sprite üzerine inşa edildi.

**Küçük çözünürlükte okunabilirlik:** 16×16 ve 32×32 boyutlarında çalışırken karakter ifadesi ve silüet netliği arasında denge kurmak zorunda kalındı. Düşman tasarımlarında (yeşil goblin karakteri) ayırt edici siluet için kontrast renk seçimi kritik bir etken oldu.

**Tileset tasarımı:** Mağara zemini, duvar ve zemin tile'larının sorunsuz birleşmesi (seamless tiling) için her tile'ın kenarları komşu tile'larla piksel düzeyinde eşleşecek şekilde çizildi.

### Tasarım Sürecinde Öğrenilenler

- **Renk sınırlaması:** Sınırlı sayıda renkle çalışmak (her sprite için 8–16 renk) görsel tutarlılığı artırdığı gibi animasyon üretimini de hızlandırıyor.
- **Indeksleme ile renk değiştirme:** Aseprite'ın indexed mod özelliği sayesinde elemental geçişlerde aynı animasyonu farklı renk paleti ile kullanmak mümkün oldu; bu da sprite sayısını önemli ölçüde düşürdü.
- **Işık kaynağı tutarlılığı:** Tüm sprite'larda ışık kaynağının sol-üstten geldiği varsayıldı. Bu kural, farklı nesneler yan yana geldiğinde görsel bütünlüğü korudu.

### Üretilen Sprite'lar

| Sprite | Çözünürlük | Açıklama |
|--------|-----------|----------|
| Ana karakter (normal) | 16×16 px | Temel idle, run, jump animasyonları |
| Ana karakter – Ateş Kavanozu | 16×32 px | Başa takılı ateş kavanozuyla animasyonlar + fireball efekti |
| Ana karakter – Hava Kavanozu | 16×32 px | Dash ve yüksek zıplama animasyonları |
| Ana karakter – Su Kavanozu | 16×32 px | Bitki büyütme aksiyon animasyonu |
| Slime düşman | 16×16 px | Idle ve saldırı animasyonu |
| Ateş topu (fireball) | 12×12 px | 4 framelık döngüsel animasyon |
| Bitki / rampa | 16×32 px | Büyüme animasyonu (4 evre) |
| Mağara tilesprites | 16×16 px | Zemin, duvar, tavan; seamless |
| Coin | 12×12 px | 6 framelik döngüsel animasyon |

---

## 4. Kullanılan Hazır Asset'ler

Bu projede hazır asset kullanılmamıştır; tüm görseller öğrenci tarafından üretilmiştir.

---

## 5. Oyunu Çalıştırma (Lokal)

### Gereksinimler
- [Godot Engine 4.x](https://godotengine.org/download) (4.2 veya üzeri önerilir)
- İşletim sistemi: Windows 10/11, macOS 12+, Linux (Ubuntu 22.04+)

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/[KULLANICI]/kavanoz-game.git
cd kavanoz-game

# 2. Godot ile aç
#    Godot'u başlat → "Import" → proje klasöründeki project.godot dosyasını seç

# 3. Oyunu çalıştır
#    Godot editöründe F5 tuşuna bas veya üstteki ▶ butonuna tıkla
```

**Not:** Godot projesi harici bağımlılık gerektirmez; `project.godot` dosyasını içe aktarmak yeterlidir.

---

## 6. Oyun Nasıl Oynanır?

### Kontroller

| Tuş / Giriş         | Eylem                              |
|---------------------|------------------------------------|
| `A` / `D`           | Sola / sağa hareket            |
| `Space`             | Zıplama                        |
| `F`                 | Kavanozu al / bırak                |
| `Shift`             | Özel elemental gücü kullan         |

### Oyunun Amacı
Her bölümde var olan elemental kavanozları bulup güçlerini doğru sırayla kullanarak bölüm sonuna ulaşmak. Düşmanları geçmek, platformlara tırmanmak ve çevre bulmacalarını çözmek için hangi elemanın ne zaman kullanılacağını kavramak esastır.

### Temel Oynanış Akışı
1. Bölüme başla — kavanozlar çevreye yerleştirilmiş hâlde bulunur.
2. `F` ile kavanozu al; başına geçer ve o elementin gücü aktif olur.
3. `Shift` ile özel gücü kullan (ateş → fireball, hava → dash, su → bitki büyüt).
4. Düşmanları ve engelleri aş; coinleri topla.
5. Bölüm çıkışına ulaş.

---

## 7. Oyun Yayın Linki

[itch.io
](https://xgestaltzerfall.itch.io/jaremental)
---

## 8. Oynanış Videosu

[Oyun Oynanış Videosu](https://www.youtube.com/watch?v=-wHxXtcOOuA)
---

## 9. Google Drive Proje Dosyaları
[Link](https://drive.google.com/drive/folders/1HMRG6hepCspo7_O-uZUQ1YWV8E6ajkDk?usp=sharing)
---
