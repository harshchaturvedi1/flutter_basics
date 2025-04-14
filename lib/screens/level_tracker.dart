// Import necessary Flutter material package for UI components
import 'package:flutter/material.dart';
// Import math library for mathematical calculations, aliased as math
import 'dart:math' as math;

// Main screen widget for level tracking functionality
class LevelTrackerScreen extends StatefulWidget {
  const LevelTrackerScreen({super.key});

  @override
  State<LevelTrackerScreen> createState() => _LevelTrackerScreenState();
}

// State class for LevelTrackerScreen that includes animation capabilities
class _LevelTrackerScreenState extends State<LevelTrackerScreen> with SingleTickerProviderStateMixin {
  // Current level of the user
  int _currentLevel = 5;
  // Minimum possible level
  final int _minLevel = 1;
  // Maximum possible level
  final int _maxLevel = 20;
  
  // Vertical spacing between each level marker
  final double _levelSpacing = 90.0;
  
  // Duration for smooth animations between level changes
  final Duration _animationDuration = const Duration(milliseconds: 1000);
  
  // Controller for managing scrolling behavior
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    // Initialize scroll controller
    _scrollController = ScrollController();
    // Ensure widget is built before scrolling to initial position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel(animate: false);
    });
  }
  
  @override
  void dispose() {
    // Clean up scroll controller when widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

  // Increment level if not at maximum
  void _incrementLevel() {
    if (_currentLevel < _maxLevel) {
      setState(() {
        _currentLevel++;
      });
      
      // Scroll to show new level
      _scrollToCurrentLevel();
    }
  }

  // Decrement level if not at minimum
  void _decrementLevel() {
    if (_currentLevel > _minLevel) {
      setState(() {
        _currentLevel--;
      });
      
      // Scroll to show new level
      _scrollToCurrentLevel();
    }
  }
  
  // Handle scrolling to center the current level
  void _scrollToCurrentLevel({bool animate = true}) {
    // Calculate absolute scroll position
    final double scrollTarget = (_currentLevel - _minLevel) * _levelSpacing;
    
    // Adjust for screen height to center the level
    final double screenHeight = MediaQuery.of(context).size.height;
    final double targetPosition = math.max(0.0, scrollTarget - screenHeight / 2 + _levelSpacing / 2);
    
    // Perform scroll with or without animation
    if (animate) {
      _scrollController.animateTo(
        targetPosition,
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(targetPosition);
    }
  }

  // Determine color based on level number
  Color _getLevelColor(int level) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];
    
    return colors[(level - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add gradient background
      backgroundColor: Colors.transparent, // Make scaffold transparent
      extendBodyBehindAppBar: true, // Allow background to extend behind AppBar
      appBar: AppBar(
        // empty title of page
        title: const Text(''),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove AppBar shadow
      ),
      // Add container with gradient decoration
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main path with level indicators
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCurvedPath(),
            ),
            
            // Control buttons at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Container(
                // Add subtle glass effect to buttons container
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrement button
                    ElevatedButton(
                      onPressed: _currentLevel > _minLevel ? _decrementLevel : null,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.red.shade100,
                        elevation: 8, // Add shadow
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 30,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Increment button
                    ElevatedButton(
                      onPressed: _currentLevel < _maxLevel ? _incrementLevel : null,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.green.shade100,
                        elevation: 8, // Add shadow
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the main curved path with level markers
  Widget _buildCurvedPath() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate total height needed for all levels
        final double totalHeight = (_maxLevel - _minLevel + 1) * _levelSpacing;
        
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: totalHeight,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                // Draw the curved path
                CustomPaint(
                  size: Size(constraints.maxWidth, totalHeight),
                  painter: CurvedPathPainter(
                    levelCount: _maxLevel - _minLevel + 1, 
                    levelSpacing: _levelSpacing,
                    currentLevel: _currentLevel - _minLevel,
                    pathColor: Colors.grey.shade300,
                    accentColor: _getLevelColor(_currentLevel),
                  ),
                ),
                
                // Place level markers
                for (int i = _minLevel; i <= _maxLevel; i++)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: (i - _minLevel) * _levelSpacing,
                    child: _buildLevelMarker(i),
                  ),
                
                // Animated user icon
                AnimatedPositioned(
                  duration: _animationDuration,
                  curve: Curves.easeInOut,
                  left: MediaQuery.of(context).size.width / 2 + 
                        MediaQuery.of(context).size.width * 0.35 * 
                        math.cos((_currentLevel - _minLevel) * _levelSpacing * math.pi / 180) - 24 +
                        (_currentLevel % 2 == 0 ? 20 : 0),
                  top: (_currentLevel - _minLevel) * _levelSpacing + 0,
                  child: _buildUserIcon(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build individual level marker
  Widget _buildLevelMarker(int level) {
    final isCurrentLevel = level == _currentLevel;
    // Calculate x position on the curve
    final double amplitude = MediaQuery.of(context).size.width * 0.35;
    final double y = (level - _minLevel) * _levelSpacing;
    final double xOffset = MediaQuery.of(context).size.width / 2 + 
                          amplitude * math.cos(y * math.pi / 180);
    
    return Stack(
      children: [
        // Level marker circle and number
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentLevel ? _getLevelColor(level) : Colors.grey.shade200,
                border: Border.all(
                  color: isCurrentLevel ? _getLevelColor(level) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: TextStyle(
                    color: isCurrentLevel ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Connecting line for current level
        if (isCurrentLevel)
          Positioned(
            left: xOffset < MediaQuery.of(context).size.width / 2 
                ? xOffset + 40 
                : xOffset - 70,
            top: 19,
            child: Container(
              height: 2,
              width: 30,
              color: _getLevelColor(level),
            ),
          ),
      ],
    );
  }

  // Build user avatar icon
  Widget _buildUserIcon() {
    return AnimatedContainer(
      duration: _animationDuration,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: _getLevelColor(_currentLevel),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getLevelColor(_currentLevel).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 28,
          color: _getLevelColor(_currentLevel),
        ),
      ),
    );
  }
}

// Custom painter for drawing the curved path
class CurvedPathPainter extends CustomPainter {
  // Total number of levels
  final int levelCount;
  // Spacing between levels
  final double levelSpacing;
  // Current level position
  final int currentLevel;
  // Color for inactive path
  final Color pathColor;
  // Color for active path section
  final Color accentColor;

  CurvedPathPainter({
    required this.levelCount,
    required this.levelSpacing,
    required this.currentLevel,
    required this.pathColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for main path
    final Paint pathPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
      
    // Paint for highlighted section
    final Paint accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    final path = Path();
    
    // Calculate full path height
    final double totalHeight = levelCount * levelSpacing;
    
    // Configure snake pattern parameters
    final double amplitude = size.width * 0.35;
    const double frequency = math.pi / 180;
    
    // Position path at first level
    final double startX = size.width / 2 + amplitude * math.cos(0);
    path.moveTo(startX, 0);
    
    // Draw snake pattern path
    for (int i = 0; i <= totalHeight; i++) {
      final double y = i.toDouble();
      final double x = size.width / 2 + amplitude * math.cos(y * frequency);
      path.lineTo(x, y);
    }
    
    // Draw background path
    canvas.drawPath(path, pathPaint);
    
    // Draw highlighted section for current level
    if (currentLevel > 0) {
      final accentPath = Path();
      final double startY = (currentLevel - 1) * levelSpacing;
      final double startX = size.width / 2 + amplitude * math.cos(startY * frequency);
      accentPath.moveTo(startX, startY);
      
      // Draw accent section
      for (int i = 0; i <= levelSpacing; i++) {
        final double y = startY + i;
        if (y > totalHeight) break;
        final double x = size.width / 2 + amplitude * math.cos(y * frequency);
        accentPath.lineTo(x, y);
      }
      
      canvas.drawPath(accentPath, accentPaint);
    }
  }

  @override
  bool shouldRepaint(CurvedPathPainter oldDelegate) => 
    oldDelegate.currentLevel != currentLevel ||
    oldDelegate.pathColor != pathColor ||
    oldDelegate.accentColor != accentColor;
}