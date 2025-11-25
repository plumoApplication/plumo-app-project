import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:plumo/app/features/reviews/presentation/cubit/reviews_state.dart';

class RateTripModal extends StatefulWidget {
  final BookingEntity booking;

  const RateTripModal({super.key, required this.booking});

  @override
  State<RateTripModal> createState() => _RateTripModalState();
}

class _RateTripModalState extends State<RateTripModal> {
  double _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is ReviewsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avaliação enviada!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ReviewsLoading;

        return Padding(
          // Padding para o teclado não cobrir
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Avaliar Viagem',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Estrelas
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Comentário
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escreva um comentário (opcional)...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || _rating == 0
                      ? null
                      : () {
                          context.read<ReviewsCubit>().submitReview(
                            booking: widget.booking,
                            rating: _rating.toInt(),
                            comment: _commentController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Enviar Avaliação'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
