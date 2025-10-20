import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MeuAppViagens());
}

class MeuAppViagens extends StatelessWidget {
  const MeuAppViagens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore Mundo - Agência de Viagens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const PaginaPrincipal(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late AnimationController _bgController;
  late AnimationController _particleController;
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';
  bool _loading = false;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  final List<Map<String, dynamic>> _allDestinos = [
    {
      'imagem': 'assets/images/praia.png',
      'titulo': 'Praia do Espelho',
      'local': 'Trancoso, Bahia - Brasil',
      'descricao':
      'Praia de falésias coloridas, areias claras e águas cristalinas — perfeito para relaxar.',
      'likes': 95,
    },
    {
      'imagem': 'assets/images/montanha.png',
      'titulo': 'Monte Fitz Roy',
      'local': 'Patagônia - Argentina',
      'descricao':
      'Montanhas nevadas, trilhas desafiantes e vistas espetaculares para aventureiros.',
      'likes': 122,
    },
    {
      'imagem': 'assets/images/floresta.png',
      'titulo': 'Floresta Amazônica',
      'local': 'Manaus - Brasil',
      'descricao':
      'Imersão na maior floresta tropical do mundo, biodiversidade e comunhão com a natureza.',
      'likes': 211,
    },
  ];

  final List<Map<String, dynamic>> _pacotes = [
    {
      'titulo': 'Aventura Patagônia',
      'descricao': '7 dias de trilhas, montanhas e lagos cristalinos.',
      'preco': 2800.0,
      'detalhes':
      'Inclui hospedagem, guias locais, traslados e café da manhã. Nível intermediário de trekking.',
      'cor': Colors.indigo
    },
    {
      'titulo': 'Relax Praia do Espelho',
      'descricao': '5 dias em resort à beira-mar, com passeios e jantar incluso.',
      'preco': 2200.0,
      'detalhes':
      'Resort 4 estrelas, translado aeroporto-hotel, passeio de barco e jantar temático.',
      'cor': Colors.teal
    },
    {
      'titulo': 'Expedição Amazônia',
      'descricao': '8 dias de navegação e trilhas na floresta amazônica.',
      'preco': 3500.0,
      'detalhes':
      'Barco privativo, guia experiente, refeições inclusas e atividades culturais.',
      'cor': Colors.green
    },
    {
      'titulo': 'Rota Histórica Salvador',
      'descricao': '4 dias explorando patrimônio histórico e cultura.',
      'preco': 1800.0,
      'detalhes':
      'City tour, museus, show de música local e opções gastronômicas.',
      'cor': Colors.orange
    },
  ];

  List<Map<String, dynamic>> destinos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController(viewportFraction: 0.74);
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat(reverse: true);
    _particleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();

    _loadMoreDestinos(initial: true);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (destinos.isEmpty) return;
      int next = (_currentPage + 1) % destinos.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.ease);
    });
  }

  // ignore: unused_element
  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  Future<void> _loadMoreDestinos({bool initial = false}) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      destinos.addAll(_allDestinos.map((d) => Map.of(d)).toList());
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _bgController.dispose();
    _particleController.dispose();
    _autoPlayTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get destinosFiltrados {
    final query = _filtro.trim().toLowerCase();
    if (query.isEmpty) return destinos;
    return destinos
        .where((d) =>
    d['titulo'].toLowerCase().contains(query) ||
        d['local'].toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = destinosFiltrados;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Mundo 🌎 Agência de Viagens'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar destinos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filtro = v;
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Destinos'),
                  Tab(text: 'Pacotes'),
                  Tab(text: 'Contato'),
                  Tab(text: 'Sobre'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // === Destinos com ListView ===
          Stack(
            children: [
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  final v = _bgController.value;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(Colors.blue.shade300,
                              Colors.indigo.shade300, v)!,
                          Color.lerp(Colors.purple.shade300,
                              Colors.pink.shade200, v)!,
                        ],
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ParticlePainter(_particleController.value),
                    size: Size.infinite,
                  );
                },
              ),
              ListView(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                children: [
                  if (items.isEmpty)
                    const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('Nenhum destino encontrado.'),
                        ))
                  else
                    SizedBox(
                      height: 480,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: items.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                          if (index >= items.length - 2 && !_loading) {
                            _loadMoreDestinos();
                          }
                        },
                        itemBuilder: (context, index) {
                          final destino = items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildCard(destino),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          int prev = _currentPage - 1;
                          if (prev < 0) prev = items.length - 1;
                          _pageController.animateToPage(prev,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          int next = (_currentPage + 1) % items.length;
                          _pageController.animateToPage(next,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Próximo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              if (_loading)
                const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),

          // === Pacotes com ListView ===
          ListView(
            padding: const EdgeInsets.all(16),
            children: _pacotes.map((p) => _buildPacoteCardDinamico(p)).toList(),
          ),

          // === Contato com ListView ===
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Entre em Contato',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildContatoLinha(
                          Icons.email, 'Email: contato@viagensflutter.com'),
                      _buildContatoLinha(
                          Icons.phone, 'Telefone: +55 71 99999-9999'),
                      _buildContatoLinha(Icons.location_on,
                          'Endereço: Rua das Viagens, 123, Salvador - BA'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Envie uma Mensagem',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField('Seu nome'),
              const SizedBox(height: 8),
              _buildTextField('Seu email'),
              const SizedBox(height: 8),
              _buildTextField('Mensagem', maxLines: 4),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Mensagem enviada (simulada).')));
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14)),
                ),
              ),
            ],
          ),

          // === Sobre com ListView ===
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Sobre Nós',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                // ignore: prefer_const_constructors
                // ignore: prefer_const_constructors
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  // ignore: prefer_const_constructors
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                          'A Agência Viagens Flutter foi fundada em 2023 por Eliton Rodrigues e Gabriela Bruinsma, com o objetivo de oferecer experiências únicas e personalizadas em destinos nacionais e internacionais.',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 12),
                      Text(
                          'Nossa missão é proporcionar viagens seguras, bem planejadas e inesquecíveis, garantindo experiências memoráveis para todos os clientes.',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 12),
                      Text(
                          'Os fundadores possuem paixão por viagens e tecnologia. Eliton Rodrigues traz expertise em programação, inovação e soluções digitais para turismo, enquanto Gabriela Bruinsma contribui com criatividade, design e atenção aos detalhes, garantindo experiências únicas aos clientes.',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 12),
                      Text(
                          'Valores da agência: ética, excelência no atendimento, sustentabilidade e valorização da cultura local em cada destino.',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 12),
                      Text(
                          'Junte-se a nós e descubra destinos incríveis, com conforto, segurança e experiências personalizadas!',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContatoLinha(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icone, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 16))),
      ]),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildPacoteCardDinamico(Map<String, dynamic> pacote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [pacote['cor'], pacote['cor'].withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pacote['titulo'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(pacote['descricao'],
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pacote['detalhes'],
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text('Preço: R\$ ${pacote['preco'].toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.book_online),
                      label: const Text('Reservar'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> destino) {
    return GestureDetector(
      onTap: () => _showDetalhes(destino),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))
          ],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(destino['imagem'], fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // ignore: deprecated_member_use
                      Colors.black.withOpacity(0.45),
                      Colors.transparent,
                      // ignore: deprecated_member_use
                      Colors.black.withOpacity(0.45)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destino['titulo'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(destino['local'],
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(destino['likes'].toString(),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetalhes(Map<String, dynamic> destino) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(destino['titulo'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(destino['descricao']),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(
                        'https://www.google.com/maps/search/${Uri.encodeComponent(destino['local'])}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Ver no mapa'),
                )
              ],
            ),
          );
        });
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // ignore: deprecated_member_use
    final paint = Paint()..color = Colors.white.withOpacity(0.1);
    for (int i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = (i * 100 + progress * size.height * 0.5) % size.height;
      final radius = _random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
