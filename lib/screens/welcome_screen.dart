import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _cubeController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // Cube rotation
    _cubeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(_random));
    }
  }

  @override
  void dispose() {
    _cubeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF2E3192), // Deep Purple/Blue
                  Color(0xFF1BFFFF), // Cyan accent (very subtle blend)
                  Color(0xFF000000), // Black edges
                ],
                stops: [0.0, 0.4, 1.0],
                // Creating a dark nebula feel
                 transform: GradientRotation(math.pi / 4),
              ),
            ),
          ),
          // Dark overlay to ensure text contrast
           Container(color: Colors.black.withOpacity(0.7)),

          // 2. Animated Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _particleController.value),
                child: Container(),
              );
            },
          ),

          // 3. Main Content
          Column(
            children: [
              const Spacer(flex: 2),
              // Holographic 3D Cube
              Center(
                child: AnimatedBuilder(
                  animation: _cubeController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateX(_cubeController.value * 2 * math.pi)
                        ..rotateY(_cubeController.value * 2 * math.pi)
                        ..rotateZ(_cubeController.value * 0.5 * math.pi), // Add Z rotation for complexity
                      child: const HolographicCube(),
                    );
                  },
                ),
              ),
              const Spacer(flex: 2),
              
              // Glassmorphism Card
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                         BoxShadow(
                          color: Colors.cyan.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 0,
                         )
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.purpleAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "LEAD MASTER",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Colors.white, // Color is overridden by ShaderMask
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "ELEVATE YOUR WORKFLOW",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 3,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 32),
                        HoverScaleButton(
                          onPressed: () {
                             Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const HomeScreen(),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 3D Components ---

class HolographicCube extends StatelessWidget {
  const HolographicCube({super.key});

  @override
  Widget build(BuildContext context) {
    final double size = 120;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Glow behind
          Center(
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // Faces
          _buildTransformedFace(size, 0, 0, size / 2, 0, 0, Icons.rocket_launch), // Front
          _buildTransformedFace(size, 0, 0, -size / 2, 0, math.pi, Icons.analytics), // Back
          _buildTransformedFace(size, 0, -size / 2, 0, -math.pi / 2, 0, Icons.dashboard), // Top
          _buildTransformedFace(size, 0, size / 2, 0, math.pi / 2, 0, Icons.layers), // Bottom
          _buildTransformedFace(size, -size / 2, 0, 0, 0, -math.pi / 2, Icons.pie_chart), // Left
          _buildTransformedFace(size, size / 2, 0, 0, 0, math.pi / 2, Icons.star), // Right
        ],
      ),
    );
  }

  Widget _buildTransformedFace(double size, double tx, double ty, double tz, double rx, double ry, IconData icon) {
     return Transform(
        transform: Matrix4.identity()
          ..translate(tx, ty, tz)
          ..rotateX(rx)
          ..rotateY(ry),
        alignment: Alignment.center,
        child: _buildFace(size, icon),
      );
  }

  Widget _buildFace(double size, IconData icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Very transparent
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.cyanAccent, size: 40),
      ),
    );
  }
}

// --- Particle System ---

class Particle {
  late double x;
  late double y;
  late double speed;
  late double theta;
  late double radius;
  late double opacity;

  Particle(math.Random random) {
    reset(random, true);
  }

  void reset(math.Random random, [bool fullScreen = false]) {
    x = random.nextDouble();
    y = fullScreen ? random.nextDouble() : 1.1; // Start below screen if resetting
    speed = 0.1 + random.nextDouble() * 0.2; // Slow floating
    theta = random.nextDouble() * 2 * math.pi;
    radius = 1.0 + random.nextDouble() * 3.0;
    opacity = 0.1 + random.nextDouble() * 0.4;
  }

  void update(double dt) {
    y -= speed * dt; // Float up
    x += math.sin(y * 5) * 0.002; // Wiggle
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // We use animationValue just to trigger repaints if needed, 
    // but actual loop logic usually needs a real time delta. 
    // For simplicity in this static structure, we'll just move them slightly based on time 
    // or assume the controller drives the rebuild.
    
    // In a real game loop we'd use delta time. Here we simulate movement.
    // To keep it simple and stateless-ish in paint:
    
    for (var particle in particles) {
      // Simulate update (hacky for CustomPainter without tick, but works for visual noise)
      particle.y -= 0.002;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = math.Random().nextDouble();
      }

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // Repaint every frame
  }
}

// --- Button ---

class HoverScaleButton extends StatefulWidget {
  final VoidCallback onPressed;

  const HoverScaleButton({super.key, required this.onPressed});

  @override
  State<HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<HoverScaleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [Colors.cyanAccent, Colors.purpleAccent]
                    : [Colors.cyan.shade700, Colors.purple.shade700],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  blurRadius: _isHovered ? 25 : 15,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: const Offset(0, 0), // Glowing center
                ),
              ],
            ),
            child: const Text(
              "ENTER DASHBOARD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
