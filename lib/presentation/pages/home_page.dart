import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:client_app/core/theme/app_colors.dart';
import 'package:client_app/core/theme/app_text_styles.dart';
import 'package:client_app/presentation/blocs/creature/creature_bloc.dart';
import 'package:client_app/presentation/blocs/creature/creature_event.dart';
import 'package:client_app/presentation/blocs/creature/creature_state.dart';
import 'package:client_app/presentation/blocs/habit/habit_bloc.dart';
import 'package:client_app/presentation/blocs/habit/habit_event.dart';
import 'package:client_app/presentation/blocs/habit/habit_state.dart';
import 'package:client_app/presentation/widgets/vignette_overlay.dart';
import 'package:client_app/presentation/widgets/neon_button.dart';
import 'package:client_app/presentation/widgets/biometric_bar.dart';
import 'package:client_app/presentation/widgets/injection_panel.dart';
import 'package:client_app/presentation/services/unity_bridge_service.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Home Page - XenoMirror OS Main Screen
///
/// Layer Structure (Stack):
/// 1. Layer 0: UnityWidget (full screen, creature background)
/// 2. Layer 1: VignetteOverlay (radial gradient darkening edges)
/// 3. Layer 2: HUD (Top Bar + Bottom Deck)
///
/// Design Philosophy: "The Containment Unit"
/// - Unity renders organic creature
/// - Flutter overlays sharp neon UI (the "glass" of containment)
/// - Center viewport stays EMPTY (creature spotlight)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UnityWidgetController? _unityController;
  UnityBridgeService? _bridgeService;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<CreatureBloc>().add(const LoadCreature());
    context.read<HabitBloc>().add(const LoadTodayHabits());
  }

  void _onUnityCreated(UnityWidgetController controller) {
    setState(() {
      _unityController = controller;
      _bridgeService = UnityBridgeService(controller: controller);
    });

    // Sync initial creature state to Unity
    final creatureState = context.read<CreatureBloc>().state;
    if (creatureState is CreatureLoaded) {
      _bridgeService?.sendTierSync(creatureState.creature);
      _bridgeService?.sendStateUpdate(creatureState.creature);
    }
  }

  Future<void> _handleProtocolButtonPress(HabitType habitType) async {
    // Show injection panel for activity selection
    final result = await InjectionPanel.show(
      context,
      habitType: habitType,
    );

    if (result == null) return; // User canceled

    final activity = result['activity'] as String;
    final xpEarned = result['xpEarned'] as int;

    // Log habit via HabitBloc
    if (mounted) {
      context.read<HabitBloc>().add(LogHabit(
            habitType: habitType,
            activity: activity,
            xpEarned: xpEarned,
            validationMethod: ValidationMethod.manual,
          ));

      // Add XP to creature via CreatureBloc
      context.read<CreatureBloc>().add(AddXP(
            habitType: habitType,
            xpAmount: xpEarned,
          ));

      // Send reaction to Unity
      _bridgeService?.sendReaction(habitType);
    }
  }

  void _showSystemLog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.systemLog,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: BlocListener<CreatureBloc, CreatureBlocState>(
        listener: (context, state) {
          if (state is CreatureEvolved) {
            // Show evolution toast
            _showSystemLog(state.evolutionMessage);

            // Send evolution message to Unity
            _bridgeService?.sendEvolution(
              state.evolvedBodyPart,
              state.newTier,
            );

            // Update Unity state
            _bridgeService?.sendStateUpdate(state.creature);
          } else if (state is CreatureLoaded) {
            // Sync creature state to Unity
            _bridgeService?.sendStateUpdate(state.creature);
          }
        },
        child: BlocListener<HabitBloc, HabitBlocState>(
          listener: (context, state) {
            if (state is HabitLogged) {
              // Show XP gain toast
              _showSystemLog(state.successMessage);
            }
          },
          child: Stack(
            children: [
              // Layer 0: Unity Widget (creature background)
              UnityWidget(
                onUnityCreated: _onUnityCreated,
                useAndroidViewSurface: true,
                borderRadius: BorderRadius.zero,
              ),

              // Layer 1: Vignette Overlay
              const VignetteOverlay(intensity: 0.7),

              // Layer 2: HUD (Top Bar + Bottom Deck)
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar: Biometric Status
                    _buildTopBar(),

                    // Center: EMPTY (creature viewport)
                    const Spacer(),

                    // Bottom Deck: Protocol Buttons
                    _buildBottomDeck(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return BlocBuilder<CreatureBloc, CreatureBlocState>(
      builder: (context, state) {
        if (state is! CreatureLoaded && state is! CreatureEvolved) {
          return const SizedBox.shrink(); // Hide while loading
        }

        final creature = state is CreatureLoaded
            ? state.creature
            : (state as CreatureEvolved).creature;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassOverlay,
            border: Border(
              bottom: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BIOMETRIC STATUS',
                    style: AppTextStyles.headerMedium,
                  ),
                  BlocBuilder<HabitBloc, HabitBlocState>(
                    builder: (context, habitState) {
                      if (habitState is! HabitLoaded) {
                        return const SizedBox.shrink();
                      }

                      return Text(
                        'STREAK: ${habitState.currentStreak} DAYS',
                        style: AppTextStyles.dataSmall.copyWith(
                          color: habitState.currentStreak > 0
                              ? AppColors.vitality
                              : AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Biometric Bars
              BiometricBar(
                label: 'VITALITY',
                habitType: HabitType.vitality,
                currentXP: creature.xpVitality,
                tier: creature.legsTier,
                progress: creature.vitalityProgress,
              ),
              const SizedBox(height: 12),
              BiometricBar(
                label: 'MIND',
                habitType: HabitType.mind,
                currentXP: creature.xpMind,
                tier: creature.headTier,
                progress: creature.mindProgress,
              ),
              const SizedBox(height: 12),
              BiometricBar(
                label: 'SOUL',
                habitType: HabitType.soul,
                currentXP: creature.xpSoul,
                tier: creature.armsTier,
                progress: creature.soulProgress,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomDeck() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassOverlay,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'PROTOCOL ACTIONS',
            style: AppTextStyles.headerMedium,
          ),
          const SizedBox(height: 16),

          // Protocol Buttons (3 buttons)
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  label: 'VITALITY',
                  habitType: HabitType.vitality,
                  onPressed: () =>
                      _handleProtocolButtonPress(HabitType.vitality),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  label: 'MIND',
                  habitType: HabitType.mind,
                  onPressed: () => _handleProtocolButtonPress(HabitType.mind),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  label: 'SOUL',
                  habitType: HabitType.soul,
                  onPressed: () => _handleProtocolButtonPress(HabitType.soul),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
