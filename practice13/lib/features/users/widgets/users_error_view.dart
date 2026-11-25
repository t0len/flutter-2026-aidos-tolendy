import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prac13/core/api/api_exception.dart';

class UsersErrorView extends StatelessWidget {
  const UsersErrorView({super.key, required this.error, required this.onRetry});

  final ApiException error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: onRetry,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      error is NoConnectionException
                          ? Icons.wifi_off
                          : Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        messageFor(error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => unawaited(onRetry()),
                      child: const Text('Retry'),
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

String messageFor(ApiException error) {
  return switch (error) {
    NoConnectionException() => 'No connection',
    UnauthorizedException() => 'Unauthorized',
    NotFoundException() => 'Not found',
    ServerException(:final status) => 'Server error ($status)',
    BadResponseException(:final detail) =>
      (detail == null || detail.isEmpty) ? 'Bad response' : detail,
  };
}
