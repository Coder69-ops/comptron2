import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Project, Center;
import '../../../../core/models/project.dart';
import '../../../../core/services/mongodb_service.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';

class SubmitProjectScreen extends StatefulWidget {
  const SubmitProjectScreen({super.key});

  @override
  State<SubmitProjectScreen> createState() => _SubmitProjectScreenState();
}

class _SubmitProjectScreenState extends State<SubmitProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _liveUrlController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _authorEmailController = TextEditingController();

  final List<String> _selectedTags = [];
  final List<String> _screenshotUrls = [''];
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'Web Development',
    'Mobile App',
    'AI/ML',
    'IoT',
    'Data Science',
    'Game Development',
    'Hardware',
    'Design',
    'Research',
    'Open Source',
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'Java',
    'JavaScript',
    'TypeScript',
    'C++',
    'C#',
    'Swift',
    'Kotlin',
    'Go',
    'Rust',
    'PHP',
    'Ruby',
    'Vue.js',
    'Angular',
    'Backend',
    'Frontend',
    'Full Stack',
    'Database',
    'API',
    'Cloud',
    'DevOps',
    'Blockchain',
    'Machine Learning',
    'Computer Vision',
    'Natural Language Processing',
    'Cybersecurity',
    'E-commerce',
    'Social Media',
    'Education',
    'Health',
    'Finance',
    'Gaming',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _githubUrlController.dispose();
    _liveUrlController.dispose();
    _authorNameController.dispose();
    _authorEmailController.dispose();
    super.dispose();
  }

  void _addScreenshotField() {
    setState(() {
      _screenshotUrls.add('');
    });
  }

  void _removeScreenshotField(int index) {
    setState(() {
      if (_screenshotUrls.length > 1) {
        _screenshotUrls.removeAt(index);
      }
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one tag'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final mongoService = await MongoDBService.getInstance();

      final screenshots = _screenshotUrls
          .where((url) => url.trim().isNotEmpty)
          .toList();

      final project = Project(
        id: ObjectId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        githubUrl: _githubUrlController.text.trim(),
        liveUrl: _liveUrlController.text.trim(),
        screenshots: screenshots,
        tags: _selectedTags,
        authorName: _authorNameController.text.trim(),
        authorEmail: _authorEmailController.text.trim(),
        authorId:
            ObjectId(), // TODO: Replace with actual user ID from authentication
        status: ProjectStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mongoService.createProject(project);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Project submitted successfully! It will be reviewed by admins.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Project'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitProject,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Project Title *',
                        hintText: 'Enter your project title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a project title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Project Description *',
                        hintText:
                            'Describe your project, what it does, and what makes it special',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a project description';
                        }
                        if (value.trim().length < 50) {
                          return 'Description must be at least 50 characters long';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Author Information
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name *',
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Your Email *',
                        hintText: 'Enter your email address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Media
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Main Image URL',
                        hintText: 'Enter URL of your project\'s main image',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Screenshots',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._screenshotUrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.value,
                                decoration: InputDecoration(
                                  labelText: 'Screenshot ${index + 1} URL',
                                  hintText: 'Enter screenshot URL',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _screenshotUrls[index] = value;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_screenshotUrls.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeScreenshotField(index),
                                color: Colors.red,
                              ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addScreenshotField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Screenshot'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Links
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Links',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _githubUrlController,
                      decoration: const InputDecoration(
                        labelText: 'GitHub Repository URL',
                        hintText: 'https://github.com/username/repository',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _liveUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Live Demo URL',
                        hintText: 'https://your-project-demo.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.launch),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technologies & Tags *',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select tags that describe your project (${_selectedTags.length} selected)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) => _toggleTag(tag),
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Submit Project for Review',
              onPressed: _isSubmitting ? null : _submitProject,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
            Text(
              'Your project will be reviewed by administrators before being published in the showcase.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
