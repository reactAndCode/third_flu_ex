import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../models/body_measurement.dart';
import '../providers/auth_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/chat_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/chat_list_screen.dart';
import '../services/supabase_service.dart';
import '../widgets/workout_list_item.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  int _currentIndex = 0; // 홈을 기본 탭으로 설정
  final TextEditingController _searchController = TextEditingController();

  // 운동 관련 명언 20개
  static const List<String> _motivationalQuotes = [
    '세트수를 조금씩 늘려봅시다',
    '오늘의 고통은 내일의 힘입니다',
    '포기하지 마세요, 시작이 반입니다',
    '꾸준함이 가장 큰 재능입니다',
    '한 번 더! 당신은 할 수 있습니다',
    '땀은 거짓말을 하지 않습니다',
    '강한 몸은 강한 정신에서 나옵니다',
    '변화는 당신이 만듭니다',
    '매일매일이 새로운 도전입니다',
    '당신의 한계는 당신이 정합니다',
    '오늘 하루도 최선을 다했습니다',
    '작은 진보도 진보입니다',
    '근육은 체육관에서 만들어집니다',
    '운동은 최고의 투자입니다',
    '더 나은 나를 위한 한 걸음',
    '노력은 배신하지 않습니다',
    '건강한 몸, 행복한 인생',
    '지금 이 순간에 집중하세요',
    '불가능은 없습니다',
    '당신은 이미 충분히 강합니다',
  ];

  final List<String> _exerciseTypes = [
    '전체',
    '가슴',
    '등',
    '하체',
    '어깨',
    '팔',
    '복근',
    '코어',
    '유산소'
  ];
  String _selectedType = '전체';

  // 상태 변수
  Map<String, dynamic>? _monthlyStats;
  List<Workout> _filteredWorkouts = [];
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingStats = true;
    });

    final provider = context.read<WorkoutProvider>();
    final stats = await provider.getMonthlyStats();
    final workouts = await provider.getMonthlyWorkouts();

    setState(() {
      _monthlyStats = stats;
      _filteredWorkouts = workouts;
      _isLoadingStats = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 운동 시간 계산 (8, 9, 10분 중 랜덤)
  int _getWorkoutMinutes(Workout workout) {
    return [8, 9, 10][workout.hashCode % 3];
  }

  // 칼로리 계산 (95, 100, 105 중 랜덤)
  int _getWorkoutCalories(Workout workout) {
    return [95, 100, 105][workout.hashCode % 3];
  }

  // 랜덤 명언
  String _getRandomQuote() {
    final random = Random();
    return _motivationalQuotes[random.nextInt(_motivationalQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('로그아웃 하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().signOut();
                  }
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final email = authProvider.user?.email ?? '';
              final displayText = email.length > 5 ? email.substring(0, 5) : email;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton:
          _currentIndex == 1 ? _buildFloatingActionButton() : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return '홈';
      case 1:
        return '운동';
      case 2:
        return '대시보드';
      case 3:
        return '채팅';
      case 4:
        return 'My';
      default:
        return '홈';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildWorkoutContent();
      case 2:
        return _buildDashboardContent();
      case 3:
        return _buildChatContent();
      case 4:
        return _buildMyContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildMonthlyStats(),
            _buildExerciseFilter(),
            _buildSearchBar(),
            _buildRecentWorkouts(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutContent() {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildWorkoutHeader(provider),
            _buildDateNavigation(provider),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.workouts.isEmpty
                      ? const Center(
                          child: Text(
                            '운동 기록이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : _buildWorkoutList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutHeader(WorkoutProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, size: 24),
              SizedBox(width: 8),
              Text(
                '나의 운동 내역',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '오늘 운동은 내일 그리고 내년 근육 상실 예방!!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation(WorkoutProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.previousDay,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(provider.selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '(${provider.workouts.length}개)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.nextDay,
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일 $weekday';
  }

  Widget _buildWorkoutList(WorkoutProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.workouts.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return WorkoutListItem(
            workout: provider.workouts[index],
            onDelete: () =>
                _deleteWorkout(context, provider.workouts[index].id!),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    return const DashboardScreen();
  }

  Widget _buildChatContent() {
    return const ChatListScreen();
  }

  Widget _buildMyContent() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildBodyMeasurementCard(),
              const SizedBox(height: 16),
              _buildRecentMeasurements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyMeasurementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_weight_outlined,
                color: Color(0xFF00E676),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                '체중 기록하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '오늘의 체중과 키를 기록해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddMeasurementDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '체중 기록 추가',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMeasurements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 기록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<BodyMeasurement>>(
            future: SupabaseService().getBodyMeasurements(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      '아직 기록이 없습니다\n위에서 체중을 추가해보세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              final measurements = snapshot.data!.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: measurements.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  final dateStr = DateFormat('yyyy년 MM월 dd일', 'ko_KR')
                      .format(measurement.measurementDate);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.monitor_weight,
                        color: Color(0xFF00E676),
                      ),
                    ),
                    title: Text(
                      '$dateStr',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '체중: ${measurement.weight}kg'
                      '${measurement.height != null ? ' · 키: ${measurement.height}cm' : ''}'
                      '${measurement.bmi != null ? ' · BMI: ${measurement.bmi!.toStringAsFixed(1)}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _deleteMeasurement(context, measurement),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMeasurementDialog(BuildContext context) async {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('체중 기록 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '체중 (kg) *',
                    hintText: '예: 70.5',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '키 (cm)',
                    hintText: '예: 175',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: '메모',
                    hintText: '운동 후 측정, 아침 공복 등',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '측정 날짜',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(selectedDate),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('체중을 입력해주세요')),
                  );
                  return;
                }

                try {
                  final weight = double.parse(weightController.text);
                  final height = heightController.text.isNotEmpty
                      ? double.parse(heightController.text)
                      : null;
                  final bmi = BodyMeasurement.calculateBMI(weight, height);

                  final measurement = BodyMeasurement(
                    userId: SupabaseService().currentUser?.id,
                    measurementDate: selectedDate,
                    weight: weight,
                    height: height,
                    bmi: bmi,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );

                  await SupabaseService().insertBodyMeasurement(measurement);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('체중 기록이 추가되었습니다')),
                    );
                    setState(() {}); // Refresh the UI
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMeasurement(BuildContext context, BodyMeasurement measurement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 체중 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService().deleteBodyMeasurement(measurement.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기록이 삭제되었습니다')),
          );
          setState(() {}); // Refresh the UI
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '운동명을 검색해보세요',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {
              // 필터 다이얼로그 표시
              _showFilterDialog();
            },
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          _filterWorkouts(value);
        },
      ),
    );
  }

  void _filterWorkouts(String query) async {
    final provider = context.read<WorkoutProvider>();
    final allWorkouts = await provider.getMonthlyWorkouts();

    setState(() {
      if (query.isEmpty && _selectedType == '전체') {
        _filteredWorkouts = allWorkouts;
      } else {
        _filteredWorkouts = allWorkouts.where((workout) {
          final matchesSearch = query.isEmpty ||
              workout.name.toLowerCase().contains(query.toLowerCase());
          final matchesType = _selectedType == '전체' ||
              workout.bodyPart.trim() == _selectedType;
          return matchesSearch && matchesType;
        }).toList();
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 부위 필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _exerciseTypes.map((type) {
            return RadioListTile<String>(
              title: Text(type),
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                Navigator.pop(context);
                _filterWorkouts(_searchController.text);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    if (_monthlyStats == null) {
      return const SizedBox.shrink();
    }

    final workoutCount = _monthlyStats!['workoutCount'] ?? 0;
    final totalMinutes = _monthlyStats!['totalMinutes'] ?? 0;
    final totalCalories = _monthlyStats!['totalCalories'] ?? 0;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final List<Map<String, dynamic>> statsData = [
      {
        'title': '이번달 운동 횟수',
        'value': '$workoutCount회',
        'icon': Icons.fitness_center,
        'color': Colors.blue
      },
      {
        'title': '총 운동 시간',
        'value': hours > 0 ? '$hours시간 $minutes분' : '$minutes분',
        'icon': Icons.timer,
        'color': Colors.green
      },
      {
        'title': '소모 칼로리',
        'value': '${NumberFormat('#,###').format(totalCalories)}kcal',
        'icon': Icons.local_fire_department,
        'color': Colors.orange
      },
      {
        'title': 'assistant 한마디',
        'value': _getRandomQuote(),
        'icon': Icons.star,
        'color': Colors.purple
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '이번달 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: statsData.length,
            itemBuilder: (context, index) {
              final stat = statsData[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(stat['icon'], color: stat['color'], size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stat['value'],
                            style: TextStyle(
                              fontSize: index == 3 ? 14 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (index < 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: stat['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+12%',
                              style: TextStyle(
                                color: stat['color'],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stat['title'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '운동 부위',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _exerciseTypes.length,
              itemBuilder: (context, index) {
                final type = _exerciseTypes[index];
                final isSelected = type == _selectedType;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                      _filterWorkouts(_searchController.text);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF00E676),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF00E676)
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    if (_filteredWorkouts.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '운동 기록이 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 운동',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '총 ${_filteredWorkouts.length}개',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredWorkouts.length,
            itemBuilder: (context, index) {
              final workout = _filteredWorkouts[index];
              final minutes = _getWorkoutMinutes(workout);
              final calories = _getWorkoutCalories(workout);
              final dateStr = DateFormat('MM/dd').format(workout.date);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFF00E676),
                      size: 28,
                    ),
                  ),
                  title: Text(
                    workout.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$dateStr · ${workout.reps}회 · ${workout.sets}세트 · $minutes분 · ${calories}kcal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // 운동 상세 화면으로 이동
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1D0F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: '운동'),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: '대시보드'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: '채팅'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'My'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddWorkoutDialog(context),
      backgroundColor: Colors.black,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        '한개',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _showAddWorkoutDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final bodyPartController = TextEditingController(text: '하체');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '운동명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '중량',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                decoration: const InputDecoration(
                  labelText: '횟수',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: '세트',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyPartController,
                decoration: const InputDecoration(
                  labelText: '운동 부위',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final provider = context.read<WorkoutProvider>();
              final authProvider = context.read<AuthProvider>();

              try {
                // Supabase에 운동 데이터 저장
                final workout = Workout(
                  userId: authProvider.user?.id,
                  name: nameController.text,
                  weight: weightController.text,
                  reps: repsController.text,
                  sets: setsController.text,
                  bodyPart: bodyPartController.text,
                  date: DateTime.now(),
                );

                await provider.addWorkout(workout);

                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData(); // 데이터 새로고침
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('운동이 추가되었습니다'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('운동 추가 실패: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkout(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 운동 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<WorkoutProvider>().deleteMockWorkout(id);
    }
  }

  // 프로필 카드
  Widget _buildProfileCard() {
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: chatProvider.getUserProfile(currentUserId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final nickname = profile?.nickname ?? authProvider.user?.email?.split('@')[0] ?? '사용자';
        final avatarUrl = profile?.avatarUrl;
        final statusMessage = profile?.statusMessage;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // 아바타
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue[300],
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? Text(
                            nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),

                  // 프로필 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (statusMessage != null && statusMessage.isNotEmpty)
                          Text(
                            statusMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            '상태 메시지를 입력해보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 프로필 편집 버튼
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  '프로필 편집',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 프로필 편집 다이얼로그
  Future<void> _showEditProfileDialog(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?.id;

    if (currentUserId == null) return;

    // 현재 프로필 가져오기
    final currentProfile = await chatProvider.getUserProfile(currentUserId);

    final nicknameController = TextEditingController(
      text: currentProfile?.nickname ?? authProvider.user?.email?.split('@')[0] ?? '',
    );
    final avatarUrlController = TextEditingController(
      text: currentProfile?.avatarUrl ?? '',
    );
    final statusMessageController = TextEditingController(
      text: currentProfile?.statusMessage ?? '',
    );

    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임 *',
                  hintText: '닉네임을 입력하세요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avatarUrlController,
                decoration: const InputDecoration(
                  labelText: '아바타 이미지 URL',
                  hintText: 'https://example.com/avatar.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: statusMessageController,
                decoration: const InputDecoration(
                  labelText: '상태 메시지',
                  hintText: '나를 표현하는 한마디',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                '* 닉네임은 채팅에서 표시됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nicknameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('닉네임을 입력해주세요')),
                );
                return;
              }

              try {
                await chatProvider.upsertUserProfile(
                  userId: currentUserId,
                  nickname: nicknameController.text.trim(),
                  avatarUrl: avatarUrlController.text.trim().isEmpty
                      ? null
                      : avatarUrlController.text.trim(),
                  statusMessage: statusMessageController.text.trim().isEmpty
                      ? null
                      : statusMessageController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필이 업데이트되었습니다')),
                  );
                  setState(() {}); // Refresh the UI
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류가 발생했습니다: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
