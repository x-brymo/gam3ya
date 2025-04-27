// screens/gam3ya/create_gam3ya_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/gam3ya_provider.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';

import 'package:gam3ya/src/widgets/animations/slide_animation.dart';
import 'package:gam3ya/src/widgets/common/custom_button.dart';
import 'package:gam3ya/src/widgets/common/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/auth_provider.dart';
import '../../models/enum_models.dart';

class CreateGam3yaScreen extends ConsumerStatefulWidget {
  const CreateGam3yaScreen({super.key});

  @override
  ConsumerState<CreateGam3yaScreen> createState() => _CreateGam3yaScreenState();
}

class _CreateGam3yaScreenState extends ConsumerState<CreateGam3yaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _totalMembersController = TextEditingController();
  final _purposeController = TextEditingController();
  final _minReputationController = TextEditingController();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  Gam3yaDuration _duration = Gam3yaDuration.monthly;
  Gam3yaSize _size = Gam3yaSize.medium;
  Gam3yaAccess _access = Gam3yaAccess.public;
  double _safetyFundPercentage = 5.0;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _minReputationController.text = '80'; // Default reputation requirement
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _totalMembersController.dispose();
    _purposeController.dispose();
    _minReputationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final currentUser = ref.read(currentUserProvider);

      // Automatic size detection based on amount
      final amount = double.parse(_amountController.text);
      if (amount < 1000) {
        _size = Gam3yaSize.small;
      } else if (amount > 10000) {
        _size = Gam3yaSize.large;
      } else {
        _size = Gam3yaSize.medium;
      }
      
      // Create new Gam3ya object
      final newGam3ya = Gam3ya(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        amount: amount,
        totalMembers: int.parse(_totalMembersController.text),
        creatorId: currentUser.id,
        startDate: _startDate,
        status: Gam3yaStatus.pending, // Needs admin approval
        duration: _duration,
        size: _size,
        access: _access,
        purpose: _purposeController.text,
        safetyFundPercentage: _safetyFundPercentage,
        minRequiredReputation: int.parse(_minReputationController.text),
      );
      
      // Save the Gam3ya
      await ref.read(gam3yasNotifierProvider.notifier).addGam3ya(newGam3ya);
      
      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your Gam3ya request has been submitted for approval'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Gam3ya: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Gam3ya'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    SlideAnimation(
                      duration: const Duration(milliseconds: 500),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Basic Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _nameController,
                                labelText: 'Gam3ya Name',
                                hintText: 'Enter a descriptive name',
                                prefixIcon: Icons.group,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _descriptionController,
                                labelText: 'Description',
                                hintText: 'Describe the purpose and terms',
                                prefixIcon: Icons.description,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Financial Details Section
                    SlideAnimation(
                      duration: const Duration(milliseconds: 600),
                      //beginOffset: const Offset(0.0, 0.2),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Financial Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _amountController,
                                labelText: 'Total Amount',
                                hintText: 'Total amount of the Gam3ya',
                                prefixIcon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _totalMembersController,
                                labelText: 'Number of Members',
                                hintText: 'How many members can join',
                                prefixIcon: Icons.people,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter number of members';
                                  }
                                  if (int.tryParse(value) == null || int.parse(value) < 2) {
                                    return 'At least 2 members are required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Safety Fund Percentage Slider
                              Row(
                                children: [
                                  const Icon(
                                    Icons.security,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Safety Fund: ${_safetyFundPercentage.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Slider(
                                          value: _safetyFundPercentage,
                                          min: 0,
                                          max: 10,
                                          divisions: 20,
                                          label: '${_safetyFundPercentage.toStringAsFixed(1)}%',
                                          onChanged: (value) {
                                            setState(() {
                                              _safetyFundPercentage = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Terms and Settings Section
                    SlideAnimation(
                      duration: const Duration(milliseconds: 700),
                      //beginOffset: const Offset(0.0, 0.3),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Terms & Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Start Date
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('yyyy-MM-dd').format(_startDate),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Duration Dropdown
                              InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Duration',
                                  prefixIcon: const Icon(Icons.timelapse),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Gam3yaDuration>(
                                    value: _duration,
                                    isExpanded: true,
                                    items: Gam3yaDuration.values.map((duration) {
                                      return DropdownMenuItem<Gam3yaDuration>(
                                        value: duration,
                                        child: Text(duration.toString().split('.').last),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _duration = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Access Type Dropdown
                              InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Access Type',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Gam3yaAccess>(
                                    value: _access,
                                    isExpanded: true,
                                    items: Gam3yaAccess.values.map((access) {
                                      return DropdownMenuItem<Gam3yaAccess>(
                                        value: access,
                                        child: Text(access.toString().split('.').last),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _access = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              CustomTextField(
                                controller: _purposeController,
                                labelText: 'Purpose',
                                hintText: 'Friends, Colleagues, Family...',
                                prefixIcon: Icons.category,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              CustomTextField(
                                controller: _minReputationController,
                                labelText: 'Minimum Reputation Score',
                                hintText: 'Minimum required score to join',
                                prefixIcon: Icons.stars,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a minimum score';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SlideAnimation(
                      duration: const Duration(milliseconds: 800),
                     // beginOffset: const Offset(0.0, 0.4),
                      child: CustomButton(
                        text: 'Submit for Approval',
                        onPressed: _submitForm,
                        isLoading: _isLoading,
                        icon: Icons.send,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Note
                    SlideAnimation(
                      duration: const Duration(milliseconds: 850),
                      //beginOffset: const Offset(0.0, 0.5),
                      child: const Text(
                        'Note: New Gam3yas require admin approval before becoming active.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}