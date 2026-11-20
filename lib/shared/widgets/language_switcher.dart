import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';

class LanguageOption {
  final String code;
  final String flag;
  final String name;
  final String nativeName;
  final bool isRtl;

  const LanguageOption({
    required this.code,
    required this.flag,
    required this.name,
    required this.nativeName,
    this.isRtl = false,
  });
}

const List<LanguageOption> supportedLanguages = [
  LanguageOption(
    code: 'en',
    flag: '🇬🇧',
    name: 'English',
    nativeName: 'English (US/UK)',
    isRtl: false,
  ),
  LanguageOption(
    code: 'hi',
    flag: '🇮🇳',
    name: 'Hindi',
    nativeName: 'हिन्दी (Hindi)',
    isRtl: false,
  ),
  LanguageOption(
    code: 'ar',
    flag: '🇦🇪',
    name: 'Arabic',
    nativeName: 'العربية (Arabic - RTL)',
    isRtl: true,
  ),
];

class LanguageSwitcher extends ConsumerWidget {
  final bool isCompact;

  const LanguageSwitcher({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentCode = currentLocale.languageCode;

    return PopupMenuButton<String>(
      tooltip: context.l10n.switchLanguage,
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      onSelected: (code) {
        ref.read(localeNotifierProvider.notifier).setLanguageCode(code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.languageChanged),
            backgroundColor: AppColors.paid,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      itemBuilder: (context) => [
        for (final lang in supportedLanguages)
          PopupMenuItem<String>(
            value: lang.code,
            child: Row(
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: lang.code == currentCode
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: lang.code == currentCode
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (lang.code == currentCode)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
              ],
            ),
          ),
      ],
      child: Builder(
        builder: (context) {
          final isMobile = MediaQuery.of(context).size.width < 768;
          return Container(
            height: 32,
            padding: EdgeInsetsDirectional.symmetric(horizontal: isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 15,
                  color: Color(0xFF475569),
                ),
                const SizedBox(width: 4),
                Text(
                  currentCode.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Horizontal segmented toggle bar for Drawer & Sidebar
  static Widget drawerToggle() {
    return const _DrawerLanguageToggle();
  }

  /// Full interactive card for Settings Screen
  static Widget settingsCard() {
    return const _SettingsLanguageCard();
  }
}

class _DrawerLanguageToggle extends ConsumerWidget {
  const _DrawerLanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final activeCode = currentLocale.languageCode;

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.sidebarDivider),
      ),
      child: Row(
        children: [
          for (final lang in supportedLanguages) ...[
            Expanded(
              child: InkWell(
                onTap: () {
                  if (activeCode != lang.code) {
                    ref.read(localeNotifierProvider.notifier).setLanguageCode(lang.code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.languageChanged),
                        backgroundColor: AppColors.paid,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: activeCode == lang.code
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      lang.code == 'en'
                          ? 'EN'
                          : (lang.code == 'hi' ? 'हिन्दी' : 'العربية'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: activeCode == lang.code
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: activeCode == lang.code
                            ? Colors.white
                            : AppColors.sidebarText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsLanguageCard extends ConsumerWidget {
  const _SettingsLanguageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final activeCode = currentLocale.languageCode;

    return Container(
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.selectLanguage,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.systemSettings,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.sidebarGroupLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final lang in supportedLanguages) ...[
                InkWell(
                  onTap: () {
                    ref.read(localeNotifierProvider.notifier).setLanguageCode(lang.code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.languageChanged),
                        backgroundColor: AppColors.paid,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: activeCode == lang.code
                          ? AppColors.primarySurface
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: activeCode == lang.code
                            ? const Color(0xFF2563EB)
                            : AppColors.border,
                        width: activeCode == lang.code ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: activeCode == lang.code
                                      ? AppColors.primaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.isRtl
                                    ? 'Right-to-Left Layout (RTL)'
                                    : 'Left-to-Right Layout (LTR)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.sidebarGroupLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activeCode == lang.code
                                  ? const Color(0xFF2563EB)
                                  : AppColors.textMuted,
                              width: activeCode == lang.code ? 6.5 : 2,
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
