import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/app_branding.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/currencies.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 4;

  final _pageController = PageController();
  final _nameController = TextEditingController();

  int _pageIndex = 0;
  String _currencySymbol = CurrencyOptions.defaultSymbol;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _pageIndex == _pageCount - 1;

  Future<void> _goToPage(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onNext() {
    if (_isLastPage) {
      _complete();
      return;
    }
    _goToPage(_pageIndex + 1);
  }

  void _onSkip() => _goToPage(_pageCount - 1);

  Future<void> _complete() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    context.read<SettingsBloc>().add(
          CompleteOnboarding(
            userName: _nameController.text.trim(),
            currencySymbol: _currencySymbol,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final theme = Theme.of(context);

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsLoaded || current is SettingsError,
      listener: (context, state) {
        if (state is SettingsError) {
          setState(() => _isSubmitting = false);
          MHelperFunctions.showSnackBar(
            context: context,
            title: 'Could not finish setup',
            message: state.message,
            bgColor: Colors.red,
            icon: Icons.error_outline,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MSizes.md,
                  MSizes.sm,
                  MSizes.md,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      AppBranding.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: MColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (!_isLastPage)
                      TextButton(
                        onPressed: _onSkip,
                        child: const Text('Skip'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  children: [
                    const _IntroPage(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      title: 'Welcome to Finora',
                      subtitle:
                          'Track income and expenses privately on your device — no account, no cloud.',
                    ),
                    const _IntroPage(
                      icon: CupertinoIcons.list_bullet,
                      title: 'Stay organized',
                      subtitle:
                          'Add notes and photos, filter by category or date, and find any transaction fast.',
                    ),
                    const _IntroPage(
                      icon: CupertinoIcons.graph_square_fill,
                      title: 'Budgets & insights',
                      subtitle:
                          'Set monthly limits and see where your money goes with clear charts.',
                    ),
                    _SetupPage(
                      nameController: _nameController,
                      currencySymbol: _currencySymbol,
                      onCurrencySelected: (symbol) {
                        setState(() => _currencySymbol = symbol);
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MSizes.lg,
                  MSizes.sm,
                  MSizes.lg,
                  MSizes.lg,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pageCount, (index) {
                        final selected = index == _pageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 8,
                          width: selected ? 22 : 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? MColors.primary
                                : (isDark
                                    ? MColors.outline.withValues(alpha: 0.35)
                                    : MColors.outline.withValues(alpha: 0.55)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: MSizes.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: MColors.boxGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLastPage ? 'Get started' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: MColors.boxGradient,
              boxShadow: [
                BoxShadow(
                  color: MColors.primary.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 48, color: Colors.white),
          ),
          const SizedBox(height: MSizes.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: MSizes.md),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupPage extends StatelessWidget {
  const _SetupPage({
    required this.nameController,
    required this.currencySymbol,
    required this.onCurrencySelected,
    required this.isDark,
  });

  final TextEditingController nameController;
  final String currencySymbol;
  final ValueChanged<String> onCurrencySelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        MSizes.lg,
        MSizes.md,
        MSizes.lg,
        MSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make it yours',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: MSizes.sm),
          Text(
            'Choose how we greet you and which currency to show. You can change these anytime in Settings.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: MSizes.xl),
          MTextFormField(
            controller: nameController,
            label: 'Your name',
            hintText: 'Optional',
            prefixIcon: CupertinoIcons.person,
          ),
          const SizedBox(height: MSizes.lg),
          Text(
            'Currency',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: MSizes.formLabelSize,
            ),
          ),
          const SizedBox(height: MSizes.sm),
          Wrap(
            spacing: MSizes.sm,
            runSpacing: MSizes.sm,
            children: CurrencyOptions.symbols.map((symbol) {
              final selected = currencySymbol == symbol;
              return ChoiceChip(
                label: Text(
                  symbol,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                selected: selected,
                onSelected: (_) => onCurrencySelected(symbol),
                selectedColor: MColors.primary.withValues(alpha: 0.2),
                side: BorderSide(
                  color: selected
                      ? MColors.primary
                      : MColors.outline.withValues(alpha: isDark ? 0.35 : 0.5),
                ),
                backgroundColor: isDark ? MColors.dark : MColors.light,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
