import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/animated_card.dart';
import '../widgets/background_design.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  List<dynamic> _tasks = [];
  List<dynamic> _notes = [];
  bool _loading = true;
  
  // Study timer state
  bool _isTimerRunning = false;
  int _elapsedSeconds = 0;
  int _manualMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getAnalytics().catchError((_) => <String, dynamic>{}),
        ApiService.getTasks().catchError((_) => <dynamic>[]),
        ApiService.getNotes().catchError((_) => <dynamic>[]),
      ]);

      setState(() {
        _analytics = results[0] as Map<String, dynamic>;
        _tasks = results[1] as List<dynamic>;
        _notes = results[2] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _elapsedSeconds = 0;
    });
    
    // Update timer every second
    Future.delayed(const Duration(seconds: 1), () {
      if (_isTimerRunning && mounted) {
        setState(() {
          _elapsedSeconds++;
        });
        _updateTimer();
      }
    });
  }

  void _updateTimer() {
    if (_isTimerRunning && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isTimerRunning && mounted) {
          setState(() {
            _elapsedSeconds++;
          });
          _updateTimer();
        }
      });
    }
  }

  void _stopTimer() {
    setState(() {
      _isTimerRunning = false;
    });
  }

  Future<void> _saveTimerStudyTime() async {
    if (_elapsedSeconds < 60) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please study for at least 1 minute'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final minutes = _elapsedSeconds ~/ 60;
    await _logStudyTime(minutes);
    
    setState(() {
      _elapsedSeconds = 0;
    });
  }

  Future<void> _logManualStudyTime() async {
    if (_manualMinutes <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid study time'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    await _logStudyTime(_manualMinutes);
    
    setState(() {
      _manualMinutes = 0;
    });
  }

  Future<void> _logStudyTime(int minutes) async {
    try {
      final updatedAnalytics = await ApiService.updateStudyTime(minutes);
      setState(() {
        _analytics = updatedAnalytics;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged $minutes minutes of study time!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging study time: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _formatTimer(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final productivityScore = _analytics?['productivityScore'] ?? 0;
    final totalStudyTime = _analytics?['totalStudyTime'] ?? 0;
    final tasksCompleted = _analytics?['tasksCompleted'] ??
        _tasks.where((t) => t['status'] == 'Completed').length;
    final notesCreated = _analytics?['notesCreated'] ?? _notes.length;

    final completedTasks =
        _tasks.where((t) => t['status'] == 'Completed').length;
    final pendingTasks = _tasks.where((t) => t['status'] == 'Pending').length;
    final inProgressTasks =
        _tasks.where((t) => t['status'] == 'In Progress').length;
    final totalTasks = _tasks.length;
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

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
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Analytics',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    ),
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else ...[
                          // Key Metrics
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.025,
                            children: [
                              StatsCard(
                                title: 'Productivity Score',
                                value: '$productivityScore%',
                                icon: Icons.trending_up,
                                iconColor: AppTheme.primaryColor,
                                delay: 0,
                              ),
                              StatsCard(
                                title: 'Study Time',
                                value:
                                    '${totalStudyTime ~/ 60}h ${totalStudyTime % 60}m',
                                icon: Icons.access_time,
                                iconColor: Colors.blue,
                                delay: 100,
                              ),
                              StatsCard(
                                title: 'Tasks Completed',
                                value: '$tasksCompleted',
                                icon: Icons.check_circle,
                                iconColor: AppTheme.successColor,
                                delay: 200,
                              ),
                              StatsCard(
                                title: 'Notes Created',
                                value: '$notesCreated',
                                icon: Icons.book,
                                iconColor: Colors.purple,
                                delay: 300,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Study Time Tracker
                          AnimatedCard(
                            delay: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Track Study Time',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Timer Section
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      // Timer Display
                                      Text(
                                        _formatTimer(_elapsedSeconds),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Timer Controls
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (!_isTimerRunning)
                                            ElevatedButton.icon(
                                              onPressed: _startTimer,
                                              icon: const Icon(Icons.play_arrow),
                                              label: const Text('Start'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.successColor,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
                                                ),
                                              ),
                                            )
                                          else ...[
                                            ElevatedButton.icon(
                                              onPressed: _stopTimer,
                                              icon: const Icon(Icons.pause),
                                              label: const Text('Pause'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton.icon(
                                              onPressed: _elapsedSeconds >= 60
                                                  ? _saveTimerStudyTime
                                                  : null,
                                              icon: const Icon(Icons.save),
                                              label: const Text('Save'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryColor,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (_isTimerRunning) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          'Timer is running...',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 20),
                                // Manual Entry Section
                                const Text(
                                  'Or Log Manually',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Minutes',
                                          border: OutlineInputBorder(),
                                          hintText: 'Enter minutes',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _manualMinutes = int.tryParse(value) ?? 0;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _manualMinutes > 0
                                          ? _logManualStudyTime
                                          : null,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Log'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Quick buttons
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _QuickTimeButton(
                                      minutes: 15,
                                      onTap: () => _logStudyTime(15),
                                    ),
                                    _QuickTimeButton(
                                      minutes: 30,
                                      onTap: () => _logStudyTime(30),
                                    ),
                                    _QuickTimeButton(
                                      minutes: 60,
                                      onTap: () => _logStudyTime(60),
                                    ),
                                    _QuickTimeButton(
                                      minutes: 120,
                                      onTap: () => _logStudyTime(120),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Productivity Score Progress
                          AnimatedCard(
                            delay: 500,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Productivity Score',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Stack(
                                  children: [
                                    Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: productivityScore / 100,
                                      child: Container(
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your overall productivity is at $productivityScore%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Task Overview
                          AnimatedCard(
                            delay: 600,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Task Overview',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Completion Rate
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Completion Rate',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${completionRate.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: completionRate / 100,
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppTheme.successColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Task Stats
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _TaskStatItem(
                                      count: completedTasks,
                                      label: 'Completed',
                                      color: AppTheme.successColor,
                                    ),
                                    _TaskStatItem(
                                      count: inProgressTasks,
                                      label: 'In Progress',
                                      color: Colors.blue,
                                    ),
                                    _TaskStatItem(
                                      count: pendingTasks,
                                      label: 'Pending',
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Study Statistics
                          AnimatedCard(
                            delay: 700,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Study Statistics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _StatRow(
                                  icon: Icons.book,
                                  label: 'Total Notes',
                                  value: '${_notes.length}',
                                  color: AppTheme.primaryColor,
                                ),
                                const Divider(height: 32),
                                _StatRow(
                                  icon: Icons.track_changes,
                                  label: 'Completion Rate',
                                  value:
                                      '${completionRate.toStringAsFixed(1)}%',
                                  color: AppTheme.successColor,
                                ),
                                const Divider(height: 32),
                                _StatRow(
                                  icon: Icons.access_time,
                                  label: 'Average Study Time',
                                  value: _notes.isNotEmpty
                                      ? '${(totalStudyTime / _notes.length).toStringAsFixed(0)} min'
                                      : '0 min',
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Productivity Insights
                          AnimatedCard(
                            delay: 800,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Productivity Insights',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _InsightCard(
                                  icon: Icons.trending_up,
                                  title: 'Great Progress!',
                                  description:
                                      'You\'ve completed $completedTasks out of $totalTasks tasks. Keep up the excellent work!',
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(height: 12),
                                _InsightCard(
                                  icon: Icons.book,
                                  title: 'Study Materials',
                                  description:
                                      'You\'ve created $_notes.length notes. Keep building your knowledge base!',
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
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

class _TaskStatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _TaskStatItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  final int minutes;
  final VoidCallback onTap;

  const _QuickTimeButton({
    required this.minutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text('${minutes}m'),
    );
  }
}
