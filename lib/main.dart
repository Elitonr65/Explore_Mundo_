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

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(Map<String, dynamic> destino) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(destino['titulo'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(destino['local'], style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          Icon(Icons.star, color: Colors.red[500]),
          const SizedBox(width: 4),
          Text(destino['likes'].toString()),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    final color = Colors.blue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(color, Icons.call, 'CALL'),
        _buildButtonColumn(color, Icons.near_me, 'ROUTE'),
        _buildButtonColumn(color, Icons.share, 'SHARE'),
      ],
    );
  }

  Widget _buildTextSection(Map<String, dynamic> destino) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        destino['descricao'],
        softWrap: true,
      ),
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final destino = items[index];
              return Column(
                children: [
                  Image.asset(destino['imagem'], width: double.infinity, height: 240, fit: BoxFit.cover),
                  _buildTitleSection(destino),
                  _buildButtonSection(),
                  _buildTextSection(destino),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
          // Pacotes
          ListView(
            padding: const EdgeInsets.all(16),
            children: _pacotes.map((p) => _buildPacoteCardDinamico(p)).toList(),
          ),
          // Contato
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Entre em Contato',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildContatoLinha(Icons.email, 'Email: contato@viagensflutter.com'),
                      _buildContatoLinha(Icons.phone, 'Telefone: +55 71 99999-9999'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                ),
              ),
            ],
          ),
          // Sobre
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Sobre Nós',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                  Text(pacote['detalhes'], style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text('Preço: R\$ ${pacote['preco'].toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.book_online),
                      label: const Text('Reservar'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
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
}
