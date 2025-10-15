import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/project.dart';
import '../../../../core/widgets/custom_card.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                project.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: project.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: project.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Author and Date
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            project.authorName.isNotEmpty
                                ? project.authorName[0].toUpperCase()
                                : '?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.authorName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Submitted on ${_formatDate(project.createdAt)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Technologies/Tags
                if (project.tags.isNotEmpty) ...[
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Technologies',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: project.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Links
                if (project.githubUrl.isNotEmpty || project.liveUrl.isNotEmpty) ...[
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Links',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (project.githubUrl.isNotEmpty) ...[
                            ListTile(
                              leading: const Icon(Icons.code),
                              title: const Text('View Source Code'),
                              subtitle: const Text('GitHub Repository'),
                              trailing: const Icon(Icons.open_in_new),
                              onTap: () => _launchUrl(project.githubUrl),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                          if (project.liveUrl.isNotEmpty) ...[
                            ListTile(
                              leading: const Icon(Icons.launch),
                              title: const Text('Live Demo'),
                              subtitle: const Text('Try it out'),
                              trailing: const Icon(Icons.open_in_new),
                              onTap: () => _launchUrl(project.liveUrl),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Gallery/Screenshots
                if (project.screenshots.isNotEmpty) ...[
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Screenshots',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: project.screenshots.length,
                              itemBuilder: (context, index) {
                                final screenshot = project.screenshots[index];
                                return Container(
                                  width: 300,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: screenshot,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Theme.of(context).colorScheme.surfaceContainer,
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Theme.of(context).colorScheme.surfaceContainer,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Status (for debugging/admin view)
                if (project.status != ProjectStatus.approved) ...[
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            project.status == ProjectStatus.pending
                                ? Icons.pending
                                : Icons.close,
                            color: project.status == ProjectStatus.pending
                                ? Colors.orange
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status: ${project.status.name.toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: project.status == ProjectStatus.pending
                                  ? Colors.orange
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}