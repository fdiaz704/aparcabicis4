import 'package:flutter/material.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../utils/constants.dart';
import '../../services/navigation_service.dart';
import '../../utils/platform_icons.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.helpTitle),
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: Icon(PlatformIcons.back),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.helpTabTutorial, icon: Icon(PlatformIcons.play)),
            Tab(text: context.l10n.helpTabFaq, icon: Icon(PlatformIcons.help)),
            Tab(text: context.l10n.helpTabContact, icon: Icon(PlatformIcons.phone)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTutorialTab(),
          _buildFAQTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildTutorialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildTutorialSection(
            context.l10n.helpWelcomeTitle,
            context.l10n.helpWelcomeContent,
            PlatformIcons.bike,
            AppColors.primary,
          ),

          // How to Reserve
          _buildTutorialSection(
            context.l10n.helpReserveTitle,
            context.l10n.helpReserveContent,
            Icons.list_alt,
            AppColors.info,
          ),

          // Using the App
          _buildTutorialSection(
            context.l10n.helpUsingTitle,
            context.l10n.helpUsingContent,
            Icons.apps,
            Colors.purple,
          ),

          // Active Reservation
          _buildTutorialSection(
            context.l10n.helpActiveTitle,
            context.l10n.helpActiveContent,
            Icons.access_time,
            Colors.orange,
          ),

          // Tips
          _buildTutorialSection(
            context.l10n.helpTipsTitle,
            context.l10n.helpTipsContent,
            Icons.lightbulb,
            Colors.amber,
          ),

          // Interactive Demo Button
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startInteractiveDemo,
              icon: const Icon(Icons.play_arrow),
              label: Text(context.l10n.helpStartDemo),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    final faqs = [
      {
        'question': context.l10n.helpFaq1Question,
        'answer': context.l10n.helpFaq1Answer,
      },
      {
        'question': context.l10n.helpFaq2Question,
        'answer': context.l10n.helpFaq2Answer,
      },
      {
        'question': context.l10n.helpFaq3Question,
        'answer': context.l10n.helpFaq3Answer,
      },
      {
        'question': context.l10n.helpFaq4Question,
        'answer': context.l10n.helpFaq4Answer,
      },
      {
        'question': context.l10n.helpFaq5Question,
        'answer': context.l10n.helpFaq5Answer,
      },
      {
        'question': context.l10n.helpFaq6Question,
        'answer': context.l10n.helpFaq6Answer,
      },
      {
        'question': context.l10n.helpFaq7Question,
        'answer': context.l10n.helpFaq7Answer,
      },
      {
        'question': context.l10n.helpFaq8Question,
        'answer': context.l10n.helpFaq8Answer,
      },
      {
        'question': context.l10n.helpFaq9Question,
        'answer': context.l10n.helpFaq9Answer,
      },
      {
        'question': context.l10n.helpFaq10Question,
        'answer': context.l10n.helpFaq10Answer,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ExpansionTile(
            title: Text(
              faq['question']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  faq['answer']!,
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.helpContactTitle,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Contact Methods
          _buildContactMethod(
            context.l10n.helpContactEmailTitle,
            context.l10n.helpContactEmailValue,
            context.l10n.helpContactEmailDesc,
            Icons.email,
            AppColors.primary,
          ),

          _buildContactMethod(
            context.l10n.helpContactPhoneTitle,
            context.l10n.helpContactPhoneValue,
            context.l10n.helpContactPhoneDesc,
            Icons.phone,
            Colors.red,
          ),

          _buildContactMethod(
            context.l10n.helpContactChatTitle,
            context.l10n.helpContactChatValue,
            context.l10n.helpContactChatDesc,
            Icons.chat,
            Colors.green,
          ),

          _buildContactMethod(
            context.l10n.helpContactSocialTitle,
            context.l10n.helpContactSocialValue,
            context.l10n.helpContactSocialDesc,
            Icons.share,
            Colors.blue,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Quick Actions
          Text(
            context.l10n.helpQuickActionsTitle,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.md),

          _buildQuickAction(
            context.l10n.helpReportTitle,
            context.l10n.helpReportDesc,
            Icons.report_problem,
            Colors.orange,
            _reportProblem,
          ),

          _buildQuickAction(
            context.l10n.helpSuggestTitle,
            context.l10n.helpSuggestDesc,
            Icons.lightbulb_outline,
            Colors.amber,
            _suggestImprovement,
          ),

          _buildQuickAction(
            context.l10n.helpRateTitle,
            context.l10n.helpRateDesc,
            Icons.star_rate,
            AppColors.favorite,
            _rateApp,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Office Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.helpOfficeTitle,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(context.l10n.helpOfficeName),
                  Text(context.l10n.helpOfficeStreet),
                  Text(context.l10n.helpOfficeCity),
                  const SizedBox(height: AppSpacing.sm),
                  Text(context.l10n.helpOfficeScheduleLabel),
                  Text(context.l10n.helpOfficeWeekdays),
                  Text(context.l10n.helpOfficeSaturday),
                  Text(context.l10n.helpOfficeSunday),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection(String title, String content, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              content,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod(String title, String value, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildQuickAction(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _startInteractiveDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.helpDemoTitle),
        content: Text(context.l10n.helpDemoContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.helpCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would start the interactive demo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.helpDemoInDevelopment)),
              );
            },
            child: Text(context.l10n.helpStart),
          ),
        ],
      ),
    );
  }

  void _reportProblem() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.helpReportInDevelopment)),
    );
  }

  void _suggestImprovement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.helpSuggestInDevelopment)),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.helpRateInDevelopment)),
    );
  }
}
