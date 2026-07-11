import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';

class MHomeAppbar extends StatelessWidget {
  const MHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final displayName = state is SettingsLoaded
            ? state.settings.displayName
            : 'there';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MSizes.sm,
            vertical: MSizes.sm,
          ),
          decoration: BoxDecoration(
            color: isDark ? MColors.cardDark : MColors.cardLight,
            borderRadius: BorderRadius.circular(MSizes.borderRadiusXl),
            border: isDark
                ? null
                : Border.all(color: MColors.outline.withValues(alpha: 0.35)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MColors.primary.withValues(alpha: 0.15),
                ),
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: MColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: MSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
