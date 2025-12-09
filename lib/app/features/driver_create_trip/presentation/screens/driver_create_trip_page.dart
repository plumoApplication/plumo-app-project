import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/widgets/step_basic_info.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/widgets/step_review.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/widgets/step_waypoints.dart';

class DriverCreateTripPage extends StatelessWidget {
  const DriverCreateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injetamos o Cubit aqui para que todos os passos tenham acesso a ele
    return BlocProvider(
      create: (context) => CreateTripCubit(repository: sl()),
      child: const _DriverCreateTripView(),
    );
  }
}

class _DriverCreateTripView extends StatelessWidget {
  const _DriverCreateTripView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTripCubit, CreateTripState>(
      listener: (context, state) {
        // Sucesso
        if (state.isSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Sucesso!'),
              content: const Text(
                'Sua viagem foi publicada e já está disponível para passageiros.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Fecha Dialog
                    // Aqui poderíamos resetar o form ou navegar para "Minhas Viagens"
                    context.read<CreateTripCubit>().reset();
                    // Opcional: navegar para outra aba
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }

        // Erro Global
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getTitle(state.currentStep)),
            leading: state.currentStep != CreateTripStep.basicInfo
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        context.read<CreateTripCubit>().previousStep(),
                  )
                : null, // Esconde botão voltar no primeiro passo (ou deixa o padrão do drawer)
          ),
          body: Column(
            children: [
              // --- INDICADOR DE PROGRESSO (Stepper Simplificado) ---
              LinearProgressIndicator(
                value: _getProgress(state.currentStep),
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),

              // --- CONTEÚDO DO PASSO ATUAL ---
              Expanded(child: _buildStepContent(state.currentStep)),
            ],
          ),

          // --- BARRA INFERIOR (BOTÃO AVANÇAR) ---
          // Só mostramos o botão "Avançar" nos passos 1 e 2.
          // No passo 3, o botão é "Publicar" e fica dentro do widget StepReview.
          bottomNavigationBar: state.currentStep != CreateTripStep.review
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<CreateTripCubit>().nextStep(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('AVANÇAR'),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  String _getTitle(CreateTripStep step) {
    switch (step) {
      case CreateTripStep.basicInfo:
        return 'Criar Viagem (1/3)';
      case CreateTripStep.waypoints:
        return 'Paradas (2/3)';
      case CreateTripStep.review:
        return 'Revisão (3/3)';
    }
  }

  double _getProgress(CreateTripStep step) {
    switch (step) {
      case CreateTripStep.basicInfo:
        return 0.33;
      case CreateTripStep.waypoints:
        return 0.66;
      case CreateTripStep.review:
        return 1.0;
    }
  }

  Widget _buildStepContent(CreateTripStep step) {
    switch (step) {
      case CreateTripStep.basicInfo:
        return const StepBasicInfo();
      case CreateTripStep.waypoints:
        return const StepWaypoints();
      case CreateTripStep.review:
        return const StepReview();
    }
  }
}
