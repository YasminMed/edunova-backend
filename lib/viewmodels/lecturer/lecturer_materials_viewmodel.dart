import 'package:flutter/material.dart';
import '../../core/viewmodels/base_view_model.dart';

class LecturerMaterialsViewModel extends BaseViewModel {
  List<Map<String, dynamic>> _subjects = [];

  List<Map<String, dynamic>> get subjects => _subjects;

  LecturerMaterialsViewModel() {
    _loadSubjects();
  }

  void _loadSubjects() {
    // Simulate loading data
    _subjects = [
      {
        'name': 'Mathematics',
        'code': 'MATH101',
        'students': 120,
        'materials': 15,
        'image':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&auto=format&fit=crop&q=60',
        'color': Colors.blue,
      },
      {
        'name': 'Physics',
        'code': 'PHYS204',
        'students': 85,
        'materials': 12,
        'image':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?w=800&auto=format&fit=crop&q=60',
        'color': Colors.orange,
      },
      {
        'name': 'Programming',
        'code': 'CS102',
        'students': 150,
        'materials': 25,
        'image':
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&auto=format&fit=crop&q=60',
        'color': Colors.purple,
      },
      {
        'name': 'Database Systems',
        'code': 'CS301',
        'students': 95,
        'materials': 18,
        'image':
            'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800&auto=format&fit=crop&q=60',
        'color': Colors.teal,
      },
    ];
    notifyListeners();
  }

  void addNewCourse(String name, String code) {
    _subjects.add({
      'name': name,
      'code': code.toUpperCase(),
      'students': 0,
      'materials': 0,
      'image': null,
      'color': Colors.teal,
    });
    notifyListeners();
  }
}
