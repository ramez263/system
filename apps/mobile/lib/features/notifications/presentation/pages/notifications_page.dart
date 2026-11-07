import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_preferences.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTab = 0; // 0: Announcements, 1: Preferences
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<NotificationCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, theme, isArabic);
    }

    return Scaffold(
      appBar: ModernAppBar(
        title: isArabic ? 'مركز الإشعارات' : 'Notification Center',
        subtitle: isArabic ? 'التنبيهات المباشرة وإعدادات القنوات' : 'Real-time alerts & channel preferences',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () => context.read<NotificationCubit>().loadNotifications(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (state is NotificationLoaded) {
            final prefs = state.preferences;
            final announcements = state.announcements;

            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
              child: Column(
                children: [
                  // Modern Segmented Tab Switcher
                  _buildSegmentedTabs(
                    context: context,
                    theme: theme,
                    isArabic: isArabic,
                    announcementCount: announcements.length,
                  ),

                  // Tab Contents
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _selectedTab == 0
                          ? _buildAnnouncementsTab(
                              context: context,
                              theme: theme,
                              isArabic: isArabic,
                              announcements: announcements,
                            )
                          : _buildPreferencesTab(
                              context: context,
                              theme: theme,
                              isArabic: isArabic,
                              prefs: prefs,
                              permissionGranted: state.permissionGranted,
                            ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Modern Segmented Pill Tabs
  Widget _buildSegmentedTabs({
    required BuildContext context,
    required ThemeData theme,
    required bool isArabic,
    required int announcementCount,
  }) {
    final seedColor = theme.colorScheme.primary;
    final activeGradient = (seedColor == AppColors.primaryBlue || seedColor == const Color(0xFF1864ab))
        ? AppColors.appBarGradient
        : AppColors.getThemeGradient(seedColor);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabPill(
              title: isArabic ? 'التنبيهات والأخبار' : 'Alerts & Feed',
              icon: Icons.notifications_active_rounded,
              isSelected: _selectedTab == 0,
              badgeCount: announcementCount,
              activeGradient: activeGradient,
              theme: theme,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabPill(
              title: isArabic ? 'إعدادات القنوات' : 'Preferences',
              icon: Icons.tune_rounded,
              isSelected: _selectedTab == 1,
              badgeCount: 0,
              activeGradient: activeGradient,
              theme: theme,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required int badgeCount,
    required Gradient activeGradient,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? activeGradient : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.appBarGradientStart.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Tab 0: Announcements Feed
  Widget _buildAnnouncementsTab({
    required BuildContext context,
    required ThemeData theme,
    required bool isArabic,
    required List<AnnouncementEntity> announcements,
  }) {
    final filtered = _selectedCategory == 'all'
        ? announcements
        : announcements.where((a) => a.category.toLowerCase() == _selectedCategory).toList();

    return ListView(
      key: const ValueKey('announcements_tab'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Horizontal Filter Chips
        _buildFilterChips(theme, isArabic),
        const SizedBox(height: 14),

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: RamezEmptyState(
              icon: Icons.notifications_none_rounded,
              title: isArabic ? 'لا توجد تنبيهات في هذا القسم' : 'No Alerts in this Category',
              description: isArabic
                  ? 'أنت على اطلاع دائم بجميع تحديثات نفق VPN وحالة الخوادم.'
                  : 'You are completely caught up! Live system alerts will appear here.',
              actionLabel: isArabic ? 'عرض كل الإعلانات' : 'Show All Alerts',
              onAction: () => setState(() => _selectedCategory = 'all'),
            ),
          )
        else
          ...filtered.map((item) => _buildAnnouncementCard(context, theme, isArabic, item)),
      ],
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isArabic) {
    final categories = [
      {'key': 'all', 'label': isArabic ? 'الكل' : 'All'},
      {'key': 'updates', 'label': isArabic ? 'التحديثات' : 'Updates'},
      {'key': 'security_alerts', 'label': isArabic ? 'الأمان' : 'Security'},
      {'key': 'promotions', 'label': isArabic ? 'العروض' : 'Offers'},
      {'key': 'server_failure', 'label': isArabic ? 'الصيانة' : 'Maintenance'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['key'];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _selectedCategory = cat['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.16)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
    AnnouncementEntity item,
  ) {
    final styleInfo = _getCategoryStyle(item.category, item.icon);

    return RamezGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vibrant Squircle Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: styleInfo.gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: styleInfo.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    styleInfo.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Header Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: styleInfo.primaryColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            styleInfo.getCategoryLabel(isArabic).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: styleInfo.primaryColor,
                            ),
                          ),
                        ),

                        // Timestamp chip
                        if (item.time.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.time,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Announcement Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Body Description
          Text(
            item.body,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // Optional Action Button (e.g. VIP Upgrade / Plan View)
          if (item.actionUrl != null && item.actionUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (item.actionUrl == '/plans') {
                    context.push('/plans');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: styleInfo.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: styleInfo.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isArabic ? 'استكشف الآن' : 'Explore Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: styleInfo.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                        size: 14,
                        color: styleInfo.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Tab 1: Preferences & Channels
  Widget _buildPreferencesTab({
    required BuildContext context,
    required ThemeData theme,
    required bool isArabic,
    required NotificationPreferences prefs,
    required bool permissionGranted,
  }) {
    return ListView(
      key: const ValueKey('preferences_tab'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Permission Status Banner if disabled
        if (!permissionGranted) ...[
          _buildPermissionBanner(context, theme, isArabic),
          const SizedBox(height: 16),
        ],

        // Section 1: VPN & Connection Telemetry
        _buildSectionHeader(
          title: isArabic ? 'نفق VPN والاتصال المباشر' : 'VPN & Connection Telemetry',
          icon: Icons.cell_tower_rounded,
          theme: theme,
        ),
        const SizedBox(height: 10),
        RamezGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _buildModernSwitchTile(
                title: isArabic ? 'تنبيه الاتصال الناجح' : 'Connection Established',
                subtitle: isArabic ? 'إشعار فوري عند اكتمال تشفير نفق VPN' : 'Instant alert when secure VPN tunnel connects',
                icon: Icons.link_rounded,
                iconColor: const Color(0xFF10B981),
                value: prefs.notifyConnection,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyConnection: v),
              ),
              _buildDivider(theme),
              _buildModernSwitchTile(
                title: isArabic ? 'تنبيه انقطاع الاتصال' : 'Disconnection Alert',
                subtitle: isArabic ? 'تنبيه فوري إذا انقطع النفق أو تم فصله' : 'Notify immediately if tunnel drops or disconnects',
                icon: Icons.link_off_rounded,
                iconColor: const Color(0xFFF97316),
                value: prefs.notifyDisconnection,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyDisconnection: v),
              ),
              _buildDivider(theme),
              _buildModernSwitchTile(
                title: isArabic ? 'فشل الخوادم والصيانة' : 'Server Degradation & Maintenance',
                subtitle: isArabic ? 'تنبيهات حالة العقد وتراجع السرعة والصيانة' : 'Node health, maintenance windows & route failover',
                icon: Icons.dns_rounded,
                iconColor: const Color(0xFF0284C7),
                value: prefs.notifyServerFailure,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyServerFailure: v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Section 2: Security & Subscription
        _buildSectionHeader(
          title: isArabic ? 'الأمان والحماية والاشتراكات' : 'Security & Subscriptions',
          icon: Icons.shield_rounded,
          theme: theme,
        ),
        const SizedBox(height: 10),
        RamezGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _buildModernSwitchTile(
                title: isArabic ? 'تنبيهات الأمان ومنع التسرب' : 'Security & Leak Protection',
                subtitle: isArabic ? 'فحص تلقائي لتسرب DNS والشبكات غير الآمنة' : 'Warnings if DNS leaks or unencrypted Wi-Fi detected',
                icon: Icons.security_rounded,
                iconColor: const Color(0xFFE11D48),
                value: prefs.notifySecurityAlerts,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifySecurityAlerts: v),
              ),
              _buildDivider(theme),
              _buildModernSwitchTile(
                title: isArabic ? 'انتهاء الاشتراك وتجاوز الحصة' : 'Subscription & Quota Alerts',
                subtitle: isArabic ? 'تذكير قبل انتهاء باقة VIP أو اقتراب حد البيانات' : 'Reminders before VIP renewal or bandwidth limits',
                icon: Icons.workspace_premium_rounded,
                iconColor: const Color(0xFF8B5CF6),
                value: prefs.notifySubscriptionExpiry,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifySubscriptionExpiry: v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Section 3: App Releases & News
        _buildSectionHeader(
          title: isArabic ? 'التحديثات والعروض الترويجية' : 'Updates & Special Offers',
          icon: Icons.campaign_rounded,
          theme: theme,
        ),
        const SizedBox(height: 10),
        RamezGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _buildModernSwitchTile(
                title: isArabic ? 'تحديثات التطبيق والميزات' : 'App Releases & Protocols',
                subtitle: isArabic ? 'إشعار عند توفر إصدار جديد أو بروتوكولات جديدة' : 'Get notified on new app versions and tunnel engines',
                icon: Icons.system_update_rounded,
                iconColor: const Color(0xFF3B82F6),
                value: prefs.notifyUpdates,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyUpdates: v),
              ),
              _buildDivider(theme),
              _buildModernSwitchTile(
                title: isArabic ? 'العروض الترويجية والخصومات' : 'Promotions & Discounts',
                subtitle: isArabic ? 'أكواد القسائم المجانية وهدايا باقات VIP' : 'Voucher gifts, seasonal promos and VIP discounts',
                icon: Icons.card_giftcard_rounded,
                iconColor: const Color(0xFFEC4899),
                value: prefs.notifyPromotions,
                theme: theme,
                onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyPromotions: v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_off_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'إشعارات النظام معطلة' : 'System Notifications Disabled',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic
                      ? 'يرجى تفعيل صلاحية الإشعارات لمتابعة حالة نفق VPN والتنبيهات الأمنية.'
                      : 'Enable notification permission to track VPN drops and security alerts.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          RamezButton(
            label: isArabic ? 'تفعيل' : 'Enable',
            height: 38,
            width: 80,
            onPressed: () => context.read<NotificationCubit>().grantPermission(true),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ThemeData theme,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Squircle Category Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Adaptive Switch
            Switch.adaptive(
              value: value,
              activeTrackColor: theme.colorScheme.primary,
              activeThumbColor: Colors.white,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }

  _CategoryStyle _getCategoryStyle(String category, String iconName) {
    switch (category.toLowerCase()) {
      case 'security_alerts':
      case 'security':
        return const _CategoryStyle(
          primaryColor: Color(0xFFE11D48),
          gradient: LinearGradient(
            colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.shield_rounded,
          arLabel: 'أمان وتشفير',
          enLabel: 'Security',
        );

      case 'promotions':
      case 'offers':
        return const _CategoryStyle(
          primaryColor: Color(0xFF10B981),
          gradient: LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.card_giftcard_rounded,
          arLabel: 'عرض خاص',
          enLabel: 'Promotion',
        );

      case 'server_failure':
      case 'maintenance':
        return const _CategoryStyle(
          primaryColor: Color(0xFFF59E0B),
          gradient: LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.dns_rounded,
          arLabel: 'صيانة الخوادم',
          enLabel: 'Maintenance',
        );

      case 'updates':
      default:
        return const _CategoryStyle(
          primaryColor: Color(0xFF0284C7),
          gradient: LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.cloud_sync_rounded,
          arLabel: 'تحديث النظام',
          enLabel: 'System Update',
        );
    }
  }

  // Fallback for standalone/mock renders
  Widget _buildStaticFallback(BuildContext context, ThemeData theme, bool isArabic) {
    final mockAnnouncements = [
      const AnnouncementEntity(
        id: 1,
        title: 'Amsterdam Ultra-01 High-Speed Node Live',
        body: 'Amsterdam Ultra 01 is now online with 1 Gbps unthrottled port capacity and low latency routing.',
        category: 'updates',
        icon: 'dns',
        time: '1h ago',
      ),
      const AnnouncementEntity(
        id: 2,
        title: 'Hardware Identity Protection Verified',
        body: 'Hardware UUID authentication active. No email, passwords, or personal credentials stored on servers.',
        category: 'security_alerts',
        icon: 'security',
        time: '3h ago',
      ),
      const AnnouncementEntity(
        id: 3,
        title: 'VIP 50% Annual Discount Available',
        body: 'Upgrade to Pro Annual today to lock in 50% off lifetime renewals and get unlimited VIP nodes.',
        category: 'promotions',
        icon: 'card_giftcard',
        actionUrl: '/plans',
        time: '1d ago',
      ),
    ];

    return Scaffold(
      appBar: ModernAppBar(
        title: isArabic ? 'مركز الإشعارات' : 'Notification Center',
        subtitle: isArabic ? 'التنبيهات المباشرة وإعدادات القنوات' : 'Real-time alerts & channel preferences',
      ),
      body: Column(
        children: [
          _buildSegmentedTabs(
            context: context,
            theme: theme,
            isArabic: isArabic,
            announcementCount: mockAnnouncements.length,
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildAnnouncementsTab(
                    context: context,
                    theme: theme,
                    isArabic: isArabic,
                    announcements: mockAnnouncements,
                  )
                : _buildPreferencesTab(
                    context: context,
                    theme: theme,
                    isArabic: isArabic,
                    prefs: const NotificationPreferences(),
                    permissionGranted: true,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStyle {
  final Color primaryColor;
  final Gradient gradient;
  final IconData icon;
  final String arLabel;
  final String enLabel;

  const _CategoryStyle({
    required this.primaryColor,
    required this.gradient,
    required this.icon,
    required this.arLabel,
    required this.enLabel,
  });

  String getCategoryLabel(bool isArabic) => isArabic ? arLabel : enLabel;
}
