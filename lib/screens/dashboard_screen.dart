import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/animated_card.dart';
import '../widgets/background_design.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {
    'totalNotes': 0,
    'totalTasks': 0,
    'completedTasks': 0,
    'productivityScore': 0,
    'totalStudyTime': 0,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getAnalytics().catchError((_) => <String, dynamic>{}),
        ApiService.getTasks().catchError((_) => <dynamic>[]),
        ApiService.getNotes().catchError((_) => <dynamic>[]),
      ]);

      final analytics = results[0] as Map<String, dynamic>;
      final tasks = results[1] as List<dynamic>;
      final notes = results[2] as List<dynamic>;

      setState(() {
        _stats = {
          'totalNotes': notes.length,
          'totalTasks': tasks.length,
          'completedTasks':
              tasks.where((t) => t['status'] == 'Completed').length,
          'productivityScore': analytics['productivityScore'] ?? 0,
          'totalStudyTime': analytics['totalStudyTime'] ?? 0,
        };
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?['name'] ?? 'Student';

    return Scaffold(
      body: BackgroundDesign(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 100,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: const FlexibleSpaceBar(
                      title: Text(
                        'Dashboard',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: false,
                      titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        onPressed: () async {
                          await auth.logout();
                          if (mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        },
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Welcome Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.waving_hand,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Here's an overview of your study progress",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(
                            begin: -0.1,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic),
                        const SizedBox(height: 24),
                        // Stats Grid
                        if (_loading)
                          SizedBox(
                            height: 200,
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                              children: List.generate(
                                  4,
                                  (index) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )),
                            ),
                          )
                        else
                          SizedBox(
                            height: 328,
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                              children: [
                                StatsCard(
                                  title: 'Total Notes',
                                  value: '${_stats['totalNotes']}',
                                  icon: Icons.book_outlined,
                                  iconColor: Colors.blue,
                                  delay: 100,
                                ),
                                StatsCard(
                                  title: 'Total Tasks',
                                  value: '${_stats['totalTasks']}',
                                  icon: Icons.task_alt,
                                  iconColor: Colors.green,
                                  delay: 200,
                                ),
                                StatsCard(
                                  title: 'Completed',
                                  value: '${_stats['completedTasks']}',
                                  icon: Icons.check_circle_outline,
                                  iconColor: Colors.purple,
                                  delay: 300,
                                ),
                                StatsCard(
                                  title: 'Productivity ',
                                  value: '${_stats['productivityScore']}%',
                                  icon: Icons.trending_up,
                                  iconColor: Colors.orange,
                                  delay: 400,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 19),
                        // Quick Actions
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 320,
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: [
                              _ActionCard(
                                title: 'Create Note',
                                icon: Icons.note_add_rounded,
                                color: Colors.blue,
                                route: '/notes',
                                delay: 600,
                              ),
                              _ActionCard(
                                title: 'Add Task',
                                icon: Icons.add_task_rounded,
                                color: Colors.green,
                                route: '/tasks',
                                delay: 700,
                              ),
                              _ActionCard(
                                title: 'AI Assistant',
                                icon: Icons.smart_toy_rounded,
                                color: Colors.purple,
                                route: '/ai',
                                delay: 800,
                              ),
                              _ActionCard(
                                title: 'Analytics',
                                icon: Icons.analytics_rounded,
                                color: Colors.orange,
                                route: '/analytics',
                                delay: 900,
                              ),
                            ],
                          ),
                        ),
                        if (_stats['totalStudyTime'] > 0) ...[
                          const SizedBox(height: 24),
                          AnimatedCard(
                            delay: 1000,
                            color: Colors.white,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Study Time',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(_stats['totalStudyTime'] as int) ~/ 60}h ${(_stats['totalStudyTime'] as int) % 60}m',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;

  final IconData icon;
  final Color color;
  final String route;
  final int delay;
  final Color? backgroundColor;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.backgroundColor,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      delay: delay,
      padding: const EdgeInsets.all(20),
      color: backgroundColor ?? Colors.white,
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
