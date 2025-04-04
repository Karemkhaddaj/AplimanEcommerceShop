import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'users_screen.dart';
import 'items_screen.dart';
import 'invoice_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF1E1E2C),
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<GlobalKey> _buttonKeys = List.generate(3, (_) => GlobalKey());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(15, (index) => _buildBackgroundParticle(index, screenSize)),

            // Main content
            Column(
              children: [
                _buildAnimatedAppBar(),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingIndicator()
                      : _buildMainContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.0, 0.4, curve: Curves.easeOutQuart),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize,
                    color: Colors.purpleAccent,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Ecommerce Dashboard',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
              strokeWidth: 6,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading Dashboard...',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedButton(
            key: _buttonKeys[0],
            icon: Icons.person,
            label: 'View Users',
            color: Colors.blue,
            delay: 0.1,
            onTap: () => _navigateWithAnimation(UsersScreen()),
          ),
          _buildAnimatedButton(
            key: _buttonKeys[1],
            icon: Icons.shopping_cart,
            label: 'View Items',
            color: Colors.pinkAccent,
            delay: 0.2,
            onTap: () => _navigateWithAnimation(ItemsScreen()),
          ),
          _buildAnimatedButton(
            key: _buttonKeys[2],
            icon: Icons.receipt_long,
            label: 'View Invoices',
            color: Colors.greenAccent,
            delay: 0.3,
            onTap: () => _navigateWithAnimation(InvoiceScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required GlobalKey key,
    required IconData icon,
    required String label,
    required Color color,
    required double delay,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.3 + delay, 0.7 + delay, curve: Curves.elasticOut),
          ),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: _buildHoverButton(key, icon, label, color, onTap),
        );
      },
    );
  }

  Widget _buildHoverButton(
      GlobalKey key,
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return MouseRegion(
      onEnter: (_) => _animateButtonHover(key, true),
      onExit: (_) => _animateButtonHover(key, false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Container(
          key: key,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 35),
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            icon: Icon(icon, color: Colors.white, size: 26),
            label: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  void _animateButtonHover(GlobalKey key, bool isHovering) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final button = key.currentContext?.findAncestorWidgetOfExactType<Container>();
      if (button != null) {
        setState(() {
        });
      }
    }
  }

  void _navigateWithAnimation(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildBackgroundParticle(int index, Size screenSize) {
    final random = math.Random(index);

    final size = random.nextDouble() * 10 + 5;
    final color = [
      Colors.blue.withOpacity(0.2),
      Colors.purple.withOpacity(0.2),
      Colors.pink.withOpacity(0.2),
      Colors.green.withOpacity(0.2),
    ][random.nextInt(4)];

    final initialPosition = Offset(
      random.nextDouble() * screenSize.width,
      random.nextDouble() * screenSize.height,
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Create a pseudo-random movement pattern
        final time = _animationController.value;
        final dx = initialPosition.dx + 20 * math.sin(time * 2 * math.pi + index);
        final dy = initialPosition.dy + 20 * math.cos(time * 2 * math.pi + index);

        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: 0.3 + 0.7 * _animationController.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: index % 2 == 0 ? null : BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}