import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WeatherApp());
}

// 2. Widget root aplikasi (StatelessWidget)
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. MaterialApp: Mengatur tema dan halaman utama
    return MaterialApp(
      title: 'Aplikasi Cuaca',
      theme: ThemeData.dark(), // Menggunakan tema gelap
      debugShowCheckedModeBanner: false, // Menghilangkan banner "DEBUG"
      home: const WeatherHomePage(), // Halaman yang pertama kali dimuat
    );
  }
}

// 4. Widget untuk halaman utama (StatelessWidget)
class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  DatabaseReference get _cucacaRef {
    return FirebaseDatabase.instance.ref("sensor");
  }

  @override
  Widget build(BuildContext context) {
    // 5. Scaffold: Menyediakan kerangka halaman
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _cucacaRef.onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Terjadi kesalahan saat memuat data.'),
              );
            }

            // DEBUG: log snapshot ke console
            debugPrint('RTDB raw snapshot: ${snapshot.data?.snapshot.value}');

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tidak ada data tersedia.'),
                    const SizedBox(height: 8),
                    Text(
                      'snapshot.value: ${snapshot.data?.snapshot.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'runtimeType: ${snapshot.data?.snapshot.value.runtimeType}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Cast aman dari Map<dynamic, dynamic> ke Map<String, dynamic>
            final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final data = Map<String, dynamic>.from(raw);

            // Baca dengan fallback untuk nama kunci yang berbeda
            final suhu = data['suhu'] ?? 0;
            final kelembapan = data['kelembaban'] ?? 0;
            final statusCahaya = data['statusCahaya'] ?? "N/A";
            final statusHujan =  data['statusHujan'] ?? "N/A";

            return Padding(
              // Memberi padding di sekeliling body
              padding: const EdgeInsets.all(16.0),

              // 6. Column: Widget utama untuk menyusun elemen ke bawah
              child: Column(
                // Mengatur perataan sumbu utama (vertikal)
                mainAxisAlignment:
                    MainAxisAlignment.center, // Pusatkan di tengah layar
                // Mengatur perataan sumbu silang (horizontal)
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Regangkan elemen selebar layar
                // Daftar widget anak yang akan disusun oleh Column
                children: [
                  // === Area Header ===
                  const Text(
                    'Solo',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Jumat, 31 Oktober 2025',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  // Widget untuk memberi jarak vertikal
                  const SizedBox(height: 30),

                  // === Area Konten Utama ===
                  Image.asset(
                    'images/cloud.png', // Pastikan file ini ada
                    height: 200,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    '$suhu°C',
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w100),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // === Area Info Tambahan ===
                  // 7. Row: Untuk menyusun info ke samping
                  Row(
                    // Bagi ruang kosong secara merata di antara anak-anaknya
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Info Kelembapan (disusun dengan Column kecil)
                      Column(
                        children: [
                          const Icon (Icons.opacity, size: 30), // Ikon
                          const Text('Kelembapan'), // Label
                          Text(
                            '$kelembapan%',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ), // Nilai
                        ],
                      ),

                      // Info Intensitas Cahaya (disusun dengan Column kecil)
                      Column(
                        children: [
                          const Icon(Icons.sunny, size: 30), // Ikon
                          const Text('Cahaya'), // Label
                          Text(
                            '$statusCahaya',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ), // Nilai
                        ],
                      ),

                      Column(
                        children: [
                          const Icon(Icons.water, size: 30), // Ikon
                          const Text('Hujan'), // Label
                          Text(
                            '$statusHujan',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ), // Nilai
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
