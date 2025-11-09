import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/background_design.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Chat
  final _chatController = TextEditingController();
  final _chatScrollController = ScrollController();
  List<Map<String, String>> _chatHistory = [];
  bool _chatLoading = false;

  // Summarize
  final _summarizeController = TextEditingController();
  String _summary = '';
  bool _summarizeLoading = false;

  // Quiz
  final _quizController = TextEditingController();
  List<dynamic>? _quiz;
  Map<int, String> _selectedAnswers = {};
  bool _showResults = false;
  bool _quizLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _summarizeController.dispose();
    _quizController.dispose();
    super.dispose();
  }

  Future<void> _sendChat() async {
    if (_chatController.text.trim().isEmpty) return;

    final message = _chatController.text.trim();
    _chatController.clear();
    setState(() {
      _chatHistory.add({'role': 'user', 'content': message});
      _chatLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await ApiService.aiChat(message);
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': response['reply'] ?? 'No response',
        });
        _chatLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': 'Error: ${e.toString()}',
        });
        _chatLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _summarize() async {
    if (_summarizeController.text.trim().isEmpty) return;

    setState(() {
      _summarizeLoading = true;
      _summary = '';
    });

    try {
      final response =
          await ApiService.summarize(_summarizeController.text.trim());
      setState(() {
        _summary = response['summary'] ?? 'No summary available';
        _summarizeLoading = false;
      });
    } catch (e) {
      setState(() {
        _summary = 'Error: ${e.toString()}';
        _summarizeLoading = false;
      });
    }
  }

  Future<void> _generateQuiz() async {
    if (_quizController.text.trim().isEmpty) return;

    setState(() {
      _quizLoading = true;
      _quiz = null;
      _selectedAnswers = {};
      _showResults = false;
    });

    try {
      final response = await ApiService.quiz(_quizController.text.trim());
      dynamic quizData = response['quiz'];

      // Parse if string
      if (quizData is String) {
        try {
          quizData =
              quizData.replaceAll('```json', '').replaceAll('```', '').trim();
          final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(quizData);
          if (jsonMatch != null) {
            quizData = jsonMatch.group(0);
          }
          quizData = response['quiz']; // Use original for now
        } catch (e) {
          // Keep as is
        }
      }

      if (quizData is List) {
        setState(() {
          _quiz = quizData;
          _quizLoading = false;
        });
      } else {
        throw Exception('Invalid quiz format');
      }
    } catch (e) {
      setState(() {
        _quiz = null;
        _quizLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quiz: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _selectAnswer(int questionIndex, String answer) {
    setState(() {
      _selectedAnswers[questionIndex] = answer;
    });
  }

  void _checkAnswers() {
    setState(() {
      _showResults = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      _quiz = null;
      _quizController.clear();
      _selectedAnswers = {};
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDesign(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'AI Assistant',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 20),
                            SizedBox(width: 6),
                            Text('Chat'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.summarize, size: 20),
                            SizedBox(width: 6),
                            Text('Summarize'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, size: 20),
                            SizedBox(width: 6),
                            Text('Quiz'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChatTab(),
                      _buildSummarizeTab(),
                      _buildQuizTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: _chatHistory.isEmpty && !_chatLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_rounded,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start a conversation',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _chatHistory.length + (_chatLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _chatHistory.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final message = _chatHistory[index];
                    final isUser = message['role'] == 'user';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.smart_toy_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                          if (!isUser) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message['content'] ?? '',
                                style: TextStyle(
                                  color: isUser
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 8),
                          if (isUser)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 300))
                          .slideX(
                              begin: isUser ? 0.2 : -0.2,
                              end: 0,
                              duration: const Duration(milliseconds: 300)),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendChat(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _chatLoading ? null : _sendChat,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarizeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _summarizeController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste your text here...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _summarizeLoading ? null : _summarize,
            child: _summarizeLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Summarize'),
          ),
          if (_summary.isNotEmpty) ...[
            const SizedBox(height: 24),
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _summary,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    if (_quiz == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _quizController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Paste your study material here...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _quizLoading ? null : _generateQuiz,
              child: _quizLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Generate Quiz'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _resetQuiz,
                child: const Text('New Quiz'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(_quiz!.length, (index) {
            final question = _quiz![index];
            final questionText =
                question['q'] ?? question['question'] ?? 'Question';
            final options = (question['options'] as List?) ?? [];
            final correctAnswer = question['answer'] ?? '';
            final selectedAnswer = _selectedAnswers[index];

            return AnimatedCard(
              delay: index * 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. $questionText',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...options.map((option) {
                    final isSelected = selectedAnswer == option;
                    final showAnswer = _showResults && option == correctAnswer;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: _showResults
                            ? null
                            : () => _selectAnswer(index, option),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: showAnswer
                                ? AppTheme.successColor.withOpacity(0.1)
                                : isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.grey.shade100,
                            border: Border.all(
                              color: showAnswer
                                  ? AppTheme.successColor
                                  : isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade300,
                              width: showAnswer || isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(option)),
                              if (_showResults && option == correctAnswer)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.successColor,
                                ),
                              if (_showResults &&
                                  isSelected &&
                                  option != correctAnswer)
                                const Icon(
                                  Icons.cancel,
                                  color: AppTheme.errorColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_showResults && question['explanation'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Explanation: ${question['explanation']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (!_showResults) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswers,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Check Answers'),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
